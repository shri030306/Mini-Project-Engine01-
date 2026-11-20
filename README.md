# Tourist Place Search and Ranking System – Engine 1 (Data & Integrity)

**Department:** Bachelor of Computer Applications, KLE Technological University, Hubballi  
**Theme:** **Theme 2 — Search and Ranking System**  
**Student:** Shrilakshmi G.S (USN: `01FE24BCA314`)  
**Faculty Guides:** Prof. Pavankumar Vadavi, Prof. Sayeeda Anjum  
**Repository:** [https://github.com/shri030306/Mini-Project-Engine01-](https://github.com/shri030306/Mini-Project-Engine01-)  

---

## 1. Project Overview

The **Tourist Place Search and Ranking System** is a multi-engine decision-support system designed to eliminate unverified travel information, arbitrary entrance fees, and uncurated ratings for destinations across Karnataka.

This repository hosts **Engine 1: Data and Integrity**, responsible for:
- Core relational database architecture in MySQL 8.0 / InnoDB.
- Complete verified dataset of **34 Karnataka tourist destinations** across 6 categories.
- Enforcing non-violable data integrity rules (CHECK constraints, unique keys, foreign keys).
- Implementing an automated Audit Trail Register (`tourist_places_audit_log`) and triggers.
- Managing dynamic ranking weights via the `ranking_config` table (weights guaranteed to sum to 1.00).
- Providing live database connection modules and exports for **Engine 2 (C++ / Node API)**.

---

## 2. Team Architecture & Responsibilities

- **Shrilakshmi G.S (Engine 1):** Database Management Systems – Data and Integrity
- **Vivek B M (Engine 2):** Logic & Algorithms – C++ Multi-Factor Ranking & Heap Sort
- **Gouri K (Engine 3):** Web Technologies – Client Interface & Interactive Presentation
- **Team 02 (Engine 4):** Testing & SDLC – System Verification & Traceability

---

## 3. Database Scripts & Run Order Guide

To ensure smooth integration without duplicate columns or schema errors, follow this run guide:

| Script File | Type | Description | Run Order |
| :--- | :--- | :--- | :--- |
| **`database_queries.sql`** | **Master Script (Recommended)** | **All-in-one production database.** Sets up `tourist_db1`, seeds all 34 places, creates `ranking_config`, audit log, triggers, and DQL views. | **Run ONLY this file for fresh/complete setup.** |
| **`gate_0_database.sql`** | Prototype Script | Gate 0 baseline demonstration containing initial 12 places and B1 unprovable fee dispute proof. | Historical Gate 0 academic evaluation record. |
| **`day_2_database_alter_queries.sql`** | Incremental Patch | Demonstrates Day 2 `ALTER TABLE` evolution. | **Do NOT run** if running master `database_queries.sql`. |

### Quick Setup in MySQL Workbench:
1. Open MySQL Workbench.
2. Open **`database_queries.sql`**.
3. Execute all statements (⚡).
4. All 34 places, audit triggers, and `ranking_config` weights are instantly active!

---

## 4. Cross-Engine Integration Details (For Engine 2 & Backend)

### Database Connection Parameters:
- **Host:** `localhost` (127.0.0.1)
- **Port:** `3306`
- **Database Name:** `tourist_db1`
- **User:** `root`
- **Password:** *(Your local MySQL root password)*

### Connecting Node.js Express Backend:
A drop-in MySQL connection module is provided at **[`backend_db_connection.js`](backend_db_connection.js)**.
```javascript
const { getAllActivePlaces, getActiveRankingWeights } = require('./backend_db_connection');

// Example: Replace in-memory mock data with live database records
app.get('/api/places', async (req, res) => {
    try {
        const places = await getAllActivePlaces();
        res.json(places);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});
```

### Ranking Weights Alignment (`ranking_config`):
The `ranking_config` table enforces `ROUND(weight_rating + weight_popularity + weight_distance + weight_cost + weight_preference, 2) = 1.00`.
- **Default 4-Factor Weights:**
  - `weight_rating`: **0.35**
  - `weight_popularity`: **0.25**
  - `weight_distance`: **0.25**
  - `weight_cost`: **0.15**
  - `weight_preference`: **0.00**
  - **Total Sum:** **1.00**

---

## 5. Repository Structure

```
├── README.md                                          # Master architecture and setup guide
├── database_queries.sql                               # ALL-IN-ONE MASTER SCRIPT (34 places + triggers + config)
├── gate_0_database.sql                                # Gate 0 prototype script (12 baseline places)
├── day_2_database_alter_queries.sql                   # Incremental Day 2 patch script
├── backend_db_connection.js                           # Node.js MySQL connection module for Engine 2
├── tourist_places_34.csv                              # 34-place dataset for C++ Engine
├── tourist_places_34.json                             # 34-place dataset for Node API
├── Engine1_Data_and_Integrity_Logs.xlsx               # Official multi-sheet Excel logs workbook
├── GATE_00_EVIDENCE_ENGINE1.md                        # Gate 0 evaluation evidence matrix
├── GATE_01_EVIDENCE_ENGINE1.md                        # Gate 1 evaluation evidence matrix
├── diagrams/
│   ├── AS_IS_Workflow.md                              # Mermaid chart of manual AS-IS process
│   └── TO_BE_Workflow.md                              # Mermaid chart of 4-engine TO-BE system
└── documentation/
    ├── B1_Limitation_Note.md                          # Theme 2 B1 Limitation Note
    ├── DATABASE_DOCUMENTATION.md                      # Comprehensive schema and constraint dictionary
    └── DATABASE_TESTING_REPORT.md                     # 10 integrity tests and trigger validation results
```
