/**
 * =============================================================================
 * Tourist Place Search and Ranking System — Engine 2
 * Module  : ranking.js  (Composite Ranking Logic)
 * Purpose : Calculates composite ranking score for each tourist place.
 *           Weights are loaded LIVE from Engine 1's ranking_config table.
 *
 * Formula :
 *   score = (rating      × weight_rating)
 *         + (popularity  × weight_popularity / 100)   ← normalize 0-100 to 0-1
 *         + (1 - dist_norm × weight_distance)         ← closer = better
 *         + (1 - fee_norm  × weight_cost)             ← cheaper = better
 *         + (preference    × weight_preference)
 *
 * Engine 1 schema guarantees:
 *   - rating     ∈ [1.00, 5.00]
 *   - popularity ∈ [0, 100]
 *   - all weights sum = 1.00  (CHECK constraint in ranking_config)
 * =============================================================================
 */

const { pool } = require('./db');

/**
 * Load active ranking weights from Engine 1 database.
 * Falls back to defaults if DB query fails.
 */
async function getWeights() {
    try {
        const [rows] = await pool.query(
            'SELECT * FROM ranking_config WHERE is_active = TRUE LIMIT 1'
        );
        if (rows.length > 0) return rows[0];
    } catch (err) {
        console.warn('[Engine 2 Ranking] Could not load weights from DB, using defaults:', err.message);
    }
    // Default weights (sum = 1.00) — matches Engine 1 DEFAULT_4_FACTOR row
    return {
        weight_rating:     0.35,
        weight_popularity: 0.25,
        weight_distance:   0.25,
        weight_cost:       0.15,
        weight_preference: 0.00
    };
}

/**
 * Compute composite ranking score for one place.
 * @param {Object} place    - Row from tourist_places / vw_tourist_catalog
 * @param {Object} weights  - Row from ranking_config
 * @param {Object} maxVals  - { maxDist, maxFee } for normalization
 */
function computeScore(place, weights, maxVals) {
    const { maxDist = 500, maxFee = 500 } = maxVals;

    const ratingNorm     = (place.rating - 1) / 4;           // map 1-5 → 0-1
    const popularityNorm = place.popularity / 100;            // already 0-100
    const distNorm       = place.distance_km / maxDist;       // 0-1 (closer=better)
    const feeNorm        = place.entry_fee   / maxFee;        // 0-1 (cheaper=better)
    const prefScore      = 0;                                 // user preference (future)

    const score =
        (ratingNorm     * weights.weight_rating)      +
        (popularityNorm * weights.weight_popularity)  +
        ((1 - distNorm) * weights.weight_distance)    +
        ((1 - feeNorm)  * weights.weight_cost)        +
        (prefScore      * weights.weight_preference);

    return parseFloat(score.toFixed(4));
}

/**
 * Rank all given places using live weights from DB.
 * @param {Array} places - Array of tourist place objects
 */
async function rankPlaces(places) {
    const weights  = await getWeights();
    const maxDist  = Math.max(...places.map(p => p.distance_km), 1);
    const maxFee   = Math.max(...places.map(p => p.entry_fee),   1);

    return places
        .map(p => ({
            ...p,
            composite_score: computeScore(p, weights, { maxDist, maxFee })
        }))
        .sort((a, b) => b.composite_score - a.composite_score);
}

module.exports = { rankPlaces, getWeights };
