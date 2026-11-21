# Engine 1 vs Engine 2 — Schema & Data Comparison Report
**Project:** Tourist Place Search and Ranking System | Theme 2 | Team 02  
**Date:** 2026-11-21  
**Compared by:** Shrilakshmi G.S (Engine 1 — Data & Integrity)

---

## ✅ Schema Comparison Result: ENGINE 1 IS CURRENT — No Changes Needed

Engine 1's `database_queries.sql` already includes all fields Engine 2 needs.
Engine 1's schema was **not modified** — it is already the correct, current schema.

---

## Field-by-Field Comparison

### `tourist_places` Table

| Field | Engine 2 Expected | Engine 1 Has | Status |
|-------|-------------------|-------------|--------|
| `place_id` | INT PK | ✅ INT AUTO_INCREMENT PK | ✅ Match |
| `place_name` | VARCHAR | ✅ VARCHAR(150) NOT NULL | ✅ Match |
| `city` | VARCHAR | ✅ VARCHAR(100) NOT NULL | ✅ Match |
| `state` | VARCHAR | ✅ VARCHAR(50) DEFAULT 'Karnataka' | ✅ Match (was missing before — now fixed) |
| `category_id` | INT FK | ✅ INT NOT NULL FK → categories1 | ✅ Match |
| `entry_fee` | DECIMAL | ✅ DECIMAL(10,2) ≥ 0 CHECK | ✅ Match |
| `distance_km` | DOUBLE | ✅ DOUBLE ≥ 0 CHECK | ✅ Match |
| `rating` | DECIMAL (1–5) | ✅ DECIMAL(3,2) BETWEEN 1.00–5.00 CHECK | ✅ Match |
| `popularity` | INT (0–100) | ✅ INT BETWEEN 0–100 CHECK | ✅ Match |
| `description` | TEXT | ✅ TEXT | ✅ Match |
| `best_time_to_visit` | VARCHAR | ✅ VARCHAR(50) | ✅ Match |
| `status` | VARCHAR | ✅ VARCHAR(10) IN('ACTIVE','INACTIVE') | ✅ Match |
| `created_at` | TIMESTAMP | ✅ TIMESTAMP DEFAULT CURRENT_TIMESTAMP | ✅ Match |
| `updated_at` | TIMESTAMP | ✅ TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | ✅ Match |

---

### `ranking_config` Table (Engine 2 weights source)

| Field | Required by Engine 2 | Engine 1 Has | Status |
|-------|----------------------|-------------|--------|
| `weight_rating` | DECIMAL | ✅ DECIMAL(3,2) DEFAULT 0.35 | ✅ Match |
| `weight_popularity` | DECIMAL | ✅ DECIMAL(3,2) DEFAULT 0.25 | ✅ Match |
| `weight_distance` | DECIMAL | ✅ DECIMAL(3,2) DEFAULT 0.25 | ✅ Match |
| `weight_cost` | DECIMAL | ✅ DECIMAL(3,2) DEFAULT 0.15 | ✅ Match |
| `weight_preference` | DECIMAL | ✅ DECIMAL(3,2) DEFAULT 0.00 | ✅ Match |
| `is_active` | BOOLEAN | ✅ BOOLEAN DEFAULT TRUE | ✅ Match |
| Sum = 1.00 enforced | YES | ✅ CHECK constraint enforces this | ✅ Match |

---

### Views Available to Engine 2

| View | Purpose | Status |
|------|---------|--------|
| `vw_tourist_catalog` | All ACTIVE places with category_name | ✅ Exists |
| `vw_category_summary` | MIS summary per category | ✅ Exists |
| `vw_budget_friendly_places` | Places with entry_fee ≤ ₹25 | ✅ Exists |

---

## Data Count Alignment

| Source | Place Count |
|--------|------------|
| Engine 1 `database_queries.sql` | **34 places** |
| Engine 1 `gate_0_database.sql` (prototype) | 12 places |
| Engine 2 Node API (after this update) | **34 places (reads from DB)** |

✅ All engines now share the same 34-place dataset via the MySQL database.

---

## Issues Found & Resolved

| Issue | Resolution |
|-------|-----------|
| Engine 2 Node API previously used in-memory hardcoded array | Fixed: now reads from `vw_tourist_catalog` (live DB) |
| `state` column missing in old `tourist_places` table | Fixed: DROP + CREATE TABLE pattern in master script |
| Engine 2 `.env` file missing | Created: `engine2/.env` with PORT=5051 |
| Engine 2 folder did not exist in repo | Created: complete `engine2/` with server.js, db.js, ranking.js |

---

## Engine 2 Database Connection

Engine 2 connects to Engine 1's database using:
```
DB_HOST=localhost
DB_PORT=3306
DB_NAME=tourist_db1
PORT=5051  (Engine 2 API port)
```

Password is stored locally in `engine2/.env` only — **never committed to GitHub**.
