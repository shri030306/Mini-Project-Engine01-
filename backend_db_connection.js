/**
 * =======================================================================================
 * Tourist Place Search and Ranking System — Engine 1 to Engine 2 Database Connector
 * Module: backend_db_connection.js
 * Description: Production MySQL connection pool for Node.js Express backend.
 * Replaces in-memory mock array with live queries to `tourist_db1`.
 * =======================================================================================
 */

const mysql = require('mysql2/promise');

// MySQL Connection Pool Configuration
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'tourist_db1',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

/**
 * Test Database Connection on Server Startup
 */
async function testConnection() {
    try {
        const connection = await pool.getConnection();
        console.log('[Engine 1] Successfully connected to MySQL database: tourist_db1');
        connection.release();
        return true;
    } catch (err) {
        console.error('[Engine 1 Error] Database connection failed:', err.message);
        return false;
    }
}

/**
 * Fetch all active tourist destinations (34 places)
 * Replaces hardcoded in-memory array in Node API
 */
async function getAllActivePlaces() {
    const [rows] = await pool.query('SELECT * FROM vw_tourist_catalog ORDER BY place_id ASC');
    return rows;
}

/**
 * Fetch dynamic ranking weights from ranking_config table
 * Used by Engine 2 (C++) / Node ranking calculation
 */
async function getActiveRankingWeights() {
    const [rows] = await pool.query('SELECT * FROM ranking_config WHERE is_active = TRUE LIMIT 1');
    if (rows.length > 0) {
        return rows[0];
    }
    // Fallback default weights (sum = 1.00)
    return {
        weight_rating: 0.35,
        weight_popularity: 0.25,
        weight_distance: 0.25,
        weight_cost: 0.15,
        weight_preference: 0.00
    };
}

/**
 * Filter destinations by category, max entry fee, and max distance
 * @param {Object} filters { category_id, max_fee, max_distance, min_rating }
 */
async function searchPlaces(filters = {}) {
    let query = 'SELECT * FROM vw_tourist_catalog WHERE 1=1';
    const params = [];

    if (filters.category_id) {
        query += ' AND category_id = ?';
        params.push(filters.category_id);
    }
    if (filters.max_fee !== undefined) {
        query += ' AND entry_fee <= ?';
        params.push(filters.max_fee);
    }
    if (filters.max_distance !== undefined) {
        query += ' AND distance_km <= ?';
        params.push(filters.max_distance);
    }
    if (filters.min_rating !== undefined) {
        query += ' AND rating >= ?';
        params.push(filters.min_rating);
    }

    query += ' ORDER BY rating DESC';
    const [rows] = await pool.query(query, params);
    return rows;
}

module.exports = {
    pool,
    testConnection,
    getAllActivePlaces,
    getActiveRankingWeights,
    searchPlaces
};
