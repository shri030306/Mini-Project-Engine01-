# Tourist Place Search and Ranking System – Database Documentation

**Project:** Tourist Place Search and Ranking System  
**Engine 1:** Data and Integrity  
**Student:** Shrilakshmi G.S (USN: `01FE24BCA314`)  
**Database Name:** `tourist_db1`  
**Database Engine:** MySQL InnoDB (utf8mb4)  

---

## 1. Tables Overview

### 1. `categories1`
Stores destination categories and classification metadata.
- `category_id` (INT, Primary Key, Auto Increment)
- `category_name` (VARCHAR(100), NOT NULL, UNIQUE)

### 2. `tourist_places`
Stores core destination records, entrance fees, ratings, distance, and operational status.
- `place_id` (INT, Primary Key, Auto Increment)
- `place_name` (VARCHAR(150), NOT NULL)
- `city` (VARCHAR(100), NOT NULL)
- `state` (VARCHAR(50), NOT NULL DEFAULT 'Karnataka')
- `category_id` (INT, Foreign Key referencing `categories1.category_id`)
- `description` (TEXT)
- `entry_fee` (DECIMAL(10,2), NOT NULL DEFAULT 0.00)
- `distance_km` (DOUBLE, NOT NULL DEFAULT 0.0)
- `rating` (DECIMAL(3,2), NOT NULL DEFAULT 0.00)
- `popularity` (INT, NOT NULL DEFAULT 0)
- `status` (VARCHAR(10), NOT NULL DEFAULT 'ACTIVE')
- `best_time_to_visit` (VARCHAR(50), DEFAULT 'October to March')
- `created_at` (TIMESTAMP DEFAULT CURRENT_TIMESTAMP)
- `updated_at` (TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP)

### 3. `tourist_places_audit_log`
Immutable audit register tracking every insertion and update for Theme 2 compliance.
- `audit_id` (INT, Primary Key, Auto Increment)
- `place_id` (INT, NOT NULL)
- `action_type` (VARCHAR(20), NOT NULL) – `INSERT_RECORD`, `UPDATE_ENTRY_FEE`, `UPDATE_RATING`, `STATUS_CHANGE`
- `old_entry_fee` (DECIMAL(10,2))
- `new_entry_fee` (DECIMAL(10,2))
- `old_rating` (DECIMAL(3,2))
- `new_rating` (DECIMAL(3,2))
- `old_status` (VARCHAR(10))
- `new_status` (VARCHAR(10))
- `performed_by` (VARCHAR(50), NOT NULL DEFAULT 'SYSTEM_ADMIN')
- `performed_at` (TIMESTAMP DEFAULT CURRENT_TIMESTAMP)

---

## 2. Integrity Constraints & Rules

1. **Foreign Key Rule:** `fk_places_category` references `categories1(category_id)` `ON UPDATE CASCADE ON DELETE RESTRICT` (prevents orphan records).
2. **Duplicate Prevention:** `UNIQUE(place_name, city)` ensures no duplicate place is registered in the same city.
3. **Domain Constraints:**
   - `CHECK (entry_fee >= 0)`: Entry fees can never be negative.
   - `CHECK (distance_km >= 0)`: Distances can never be negative.
   - `CHECK (rating >= 0 AND rating <= 5)`: Ratings bounded between 0.00 and 5.00.
   - `CHECK (popularity >= 0)`: Popularity index non-negative.
   - `CHECK (status IN ('ACTIVE', 'INACTIVE'))`: Only valid operational statuses accepted.
   - `CHECK (CHAR_LENGTH(TRIM(place_name)) > 0)`: Place names cannot be blank.

---

## 3. Database Triggers

1. **`trg_audit_insert`**: Automatically captures new destination postings into `tourist_places_audit_log` with `CURRENT_USER()` and timestamp.
2. **`trg_audit_update`**: Automatically captures updates to entry fees, ratings, and status, recording both `OLD` and `NEW` values.

