/**
 * =============================================================================
 * Tourist Place Search and Ranking System — Engine 2
 * Module  : server.js  (Express REST API — PORT 5051)
 * Team 02 | Theme 2: Search and Ranking System | KLE Tech University
 *
 * Engine 1 (DB)  : Shrilakshmi G.S  (tourist_db1 MySQL)
 * Engine 2 (API) : Vivek B M        (Node.js + Ranking Logic)
 * Engine 3 (UI)  : Gouri K          (Web Interface)
 *
 * Endpoints:
 *   GET  /                        → Health check
 *   GET  /api/places              → All 34 active places (ranked)
 *   GET  /api/places/top          → Top 5 by composite score
 *   GET  /api/places/search       → Search by name (LIKE query)
 *   GET  /api/places/filter       → Filter by category, fee, distance, rating
 *   GET  /api/places/:id          → Single place by ID
 *   GET  /api/categories          → All 6 categories
 *   GET  /api/ranking/weights     → Active ranking weights from DB
 *   GET  /api/summary             → Category-wise MIS summary
 * =============================================================================
 */

require('dotenv').config();
const express  = require('express');
const cors     = require('cors');
const { pool, testConnection } = require('./db');
const { rankPlaces, getWeights } = require('./ranking');

const app  = express();
const PORT = process.env.PORT || 5051;

app.use(cors());
app.use(express.json());

// ---------------------------------------------------------------------------
// HEALTH CHECK
// ---------------------------------------------------------------------------
app.get('/', (req, res) => {
    res.json({
        status:  'OK',
        engine:  'Engine 2 — Logic & Algorithms (Node.js API)',
        project: 'Tourist Place Search and Ranking System',
        theme:   'Theme 2: Search and Ranking System',
        team:    'Team 02 | KLE Technological University, Hubballi',
        db:      process.env.DB_NAME || 'tourist_db1',
        port:    PORT
    });
});

// ---------------------------------------------------------------------------
// GET /api/places — All active places, ranked by composite score
// ---------------------------------------------------------------------------
app.get('/api/places', async (req, res) => {
    try {
        const [places] = await pool.query(
            'SELECT * FROM vw_tourist_catalog ORDER BY place_id ASC'
        );
        const ranked = await rankPlaces(places);
        res.json({ count: ranked.length, places: ranked });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ---------------------------------------------------------------------------
// GET /api/places/top?n=5 — Top N places by composite ranking score
// ---------------------------------------------------------------------------
app.get('/api/places/top', async (req, res) => {
    try {
        const n = parseInt(req.query.n) || 5;
        const [places] = await pool.query('SELECT * FROM vw_tourist_catalog');
        const ranked   = await rankPlaces(places);
        res.json({ count: n, top_places: ranked.slice(0, n) });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ---------------------------------------------------------------------------
// GET /api/places/search?q=falls — Search by place name (LIKE)
// ---------------------------------------------------------------------------
app.get('/api/places/search', async (req, res) => {
    try {
        const q = `%${req.query.q || ''}%`;
        const [places] = await pool.query(
            'SELECT * FROM vw_tourist_catalog WHERE place_name LIKE ? ORDER BY rating DESC',
            [q]
        );
        const ranked = await rankPlaces(places);
        res.json({ query: req.query.q, count: ranked.length, places: ranked });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ---------------------------------------------------------------------------
// GET /api/places/filter — Multi-condition filter
//   Query params: category_id, max_fee, max_distance, min_rating
// ---------------------------------------------------------------------------
app.get('/api/places/filter', async (req, res) => {
    try {
        let query  = 'SELECT * FROM vw_tourist_catalog WHERE 1=1';
        const vals = [];

        if (req.query.category_id) {
            query += ' AND category_id = ?';
            vals.push(parseInt(req.query.category_id));
        }
        if (req.query.max_fee !== undefined) {
            query += ' AND entry_fee <= ?';
            vals.push(parseFloat(req.query.max_fee));
        }
        if (req.query.max_distance !== undefined) {
            query += ' AND distance_km <= ?';
            vals.push(parseFloat(req.query.max_distance));
        }
        if (req.query.min_rating !== undefined) {
            query += ' AND rating >= ?';
            vals.push(parseFloat(req.query.min_rating));
        }

        query += ' ORDER BY rating DESC';
        const [places] = await pool.query(query, vals);
        const ranked   = await rankPlaces(places);
        res.json({ filters: req.query, count: ranked.length, places: ranked });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ---------------------------------------------------------------------------
// GET /api/places/:id — Single place details
// ---------------------------------------------------------------------------
app.get('/api/places/:id', async (req, res) => {
    try {
        const [rows] = await pool.query(
            'SELECT * FROM vw_tourist_catalog WHERE place_id = ?',
            [parseInt(req.params.id)]
        );
        if (rows.length === 0) return res.status(404).json({ error: 'Place not found' });
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ---------------------------------------------------------------------------
// GET /api/categories — All 6 categories from Engine 1 DB
// ---------------------------------------------------------------------------
app.get('/api/categories', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM categories1 ORDER BY category_id');
        res.json({ count: rows.length, categories: rows });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ---------------------------------------------------------------------------
// GET /api/ranking/weights — Active ranking weights from Engine 1 DB
// ---------------------------------------------------------------------------
app.get('/api/ranking/weights', async (req, res) => {
    try {
        const weights = await getWeights();
        res.json({ source: 'ranking_config (tourist_db1)', weights });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ---------------------------------------------------------------------------
// GET /api/summary — Category-wise MIS summary (from vw_category_summary)
// ---------------------------------------------------------------------------
app.get('/api/summary', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM vw_category_summary');
        res.json({ summary: rows });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ---------------------------------------------------------------------------
// START SERVER
// ---------------------------------------------------------------------------
app.listen(PORT, async () => {
    console.log('=============================================================');
    console.log(' Engine 2 — Tourist Place Search & Ranking API');
    console.log(` Server running at: http://localhost:${PORT}`);
    console.log(' Theme 2 | Team 02 | KLE Technological University');
    console.log('=============================================================');
    await testConnection();
    console.log(' Available endpoints:');
    console.log(`   GET http://localhost:${PORT}/api/places`);
    console.log(`   GET http://localhost:${PORT}/api/places/top?n=5`);
    console.log(`   GET http://localhost:${PORT}/api/places/search?q=falls`);
    console.log(`   GET http://localhost:${PORT}/api/places/filter?max_fee=50&min_rating=4.5`);
    console.log(`   GET http://localhost:${PORT}/api/places/:id`);
    console.log(`   GET http://localhost:${PORT}/api/categories`);
    console.log(`   GET http://localhost:${PORT}/api/ranking/weights`);
    console.log(`   GET http://localhost:${PORT}/api/summary`);
    console.log('=============================================================');
});
