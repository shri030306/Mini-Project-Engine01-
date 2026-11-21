# Engine 2 — Logic & Algorithms (Node.js REST API)
## Tourist Place Search and Ranking System | Theme 2 | Team 02

### Team
| Role | Name | USN |
|------|------|-----|
| Engine 1 — Data & Integrity (MySQL) | Shrilakshmi G.S | 01FE24BCA314 |
| Engine 2 — Logic & Algorithms (Node API) | Vivek B M | _(your USN)_ |
| Engine 3 — Interface & Web | Gouri K | _(your USN)_ |

**Faculty Guides:** Prof. Pavankumar Vadavi | Prof. Sayeeda Anjum  
**Engine 1 Repository:** https://github.com/shri030306/Mini-Project-Engine01-

---

## Setup Instructions

### Step 1 — Install dependencies
```bash
cd engine2
npm install
```

### Step 2 — Configure your .env
```
# engine2/.env  (never commit this file)
PORT=5051
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password_here
DB_NAME=tourist_db1
```

### Step 3 — Run Engine 1 database first
Open MySQL Workbench → Run `../database_queries.sql` (lightning bolt ⚡)  
This creates `tourist_db1` with all 34 places, views, and ranking config.

### Step 4 — Start Engine 2 server
```bash
npm start
# Server starts at http://localhost:5051
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Health check |
| GET | `/api/places` | All 34 active places (ranked) |
| GET | `/api/places/top?n=5` | Top N by composite score |
| GET | `/api/places/search?q=falls` | Search by name |
| GET | `/api/places/filter?max_fee=50&min_rating=4.5` | Multi-condition filter |
| GET | `/api/places/:id` | Single place by ID |
| GET | `/api/categories` | All 6 categories |
| GET | `/api/ranking/weights` | Active ranking weights from DB |
| GET | `/api/summary` | Category-wise MIS summary |

---

## Ranking Formula

```
score = (rating_norm    × weight_rating)
      + (popularity/100 × weight_popularity)
      + ((1 - dist_norm) × weight_distance)
      + ((1 - fee_norm)  × weight_cost)
      + (preference      × weight_preference)
```

Weights are loaded **live from Engine 1's `ranking_config` table** (not hardcoded).  
Engine 1 enforces: all weights ≥ 0 and sum = 1.00 via CHECK constraint.

**Default weights (DEFAULT_4_FACTOR):**
| Factor | Weight |
|--------|--------|
| Rating | 0.35 |
| Popularity | 0.25 |
| Distance | 0.25 |
| Cost | 0.15 |
| Preference | 0.00 |
| **Total** | **1.00** |
