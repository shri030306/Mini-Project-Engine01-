/**
 * =============================================================================
 * Tourist Place Search and Ranking System — Engine 2
 * Module  : db.js  (MySQL Connection Pool)
 * Purpose : Connects to Engine 1's tourist_db1 MySQL database.
 *           All credentials are read from engine2/.env — never hardcoded.
 * Team 02 | Theme 2: Search and Ranking System
 * Engine 1 DB Schema: https://github.com/shri030306/Mini-Project-Engine01-
 * =============================================================================
 */

require('dotenv').config();
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host:              process.env.DB_HOST     || 'localhost',
    port:              parseInt(process.env.DB_PORT || '3306', 10),
    user:              process.env.DB_USER     || 'root',
    password:          process.env.DB_PASSWORD || '',
    database:          process.env.DB_NAME     || 'tourist_db1',
    waitForConnections: true,
    connectionLimit:   10,
    queueLimit:        0
});

/**
 * Test DB connection on server startup.
 */
async function testConnection() {
    try {
        const conn = await pool.getConnection();
        console.log('[Engine 2] ✅ Connected to MySQL → tourist_db1 on port', process.env.DB_PORT || 3306);
        conn.release();
        return true;
    } catch (err) {
        console.error('[Engine 2] ❌ DB connection failed:', err.message);
        console.error('  → Check engine2/.env: DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME');
        return false;
    }
}

module.exports = { pool, testConnection };
