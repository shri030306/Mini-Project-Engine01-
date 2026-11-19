-- =======================================================================================
-- KLE TECHNOLOGICAL UNIVERSITY, HUBBALLI
-- DEPARTMENT OF BACHELOR OF COMPUTER APPLICATIONS
-- THEME 4: REPORTING AND MIS SYSTEM / RULES CHECK RECORDS REGISTER
-- MASTER DATABASE SCRIPT: DAY 1 BASELINE + DAY 2 SCHEMA EVOLUTION & AUDIT REGISTER
-- Project: Tourist Place Search and Ranking System
-- Engine 1: Data & Integrity (Database Management Systems)
-- Student: Shrilakshmi G.S (USN: 01FE24BCA314)
-- Faculty Guides: Prof. Pavankumar Vadavi, Prof. Sayeeda Anjum
-- Repository: https://github.com/shri030306/Mini-Project-Engine01-
-- =======================================================================================

-- #######################################################################################
-- PART 1: [DAY 1 TASK] - INITIAL DATABASE & TABLE CREATION
-- #######################################################################################

-- STEP 1: INITIALIZE DATABASE
DROP DATABASE IF EXISTS tourist_db1;
CREATE DATABASE tourist_db1;
USE tourist_db1;

-- STEP 2: CREATE MASTER CATEGORIES TABLE (LOOKUP)
-- Ensures duplicate categories cannot be created (UNIQUE constraint)
CREATE TABLE categories1 (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- STEP 3: CREATE TOURIST PLACES TABLE (CORE RECORDS REGISTER)
-- Enforces Non-Violable Rules at the database level:
-- 1. Foreign Key rejects orphan records
-- 2. Unique constraint prevents duplicate destinations within the same city
-- 3. CHECK constraints prevent negative fees, negative distances, and out-of-bounds ratings
CREATE TABLE tourist_places (
    place_id INT AUTO_INCREMENT PRIMARY KEY,
    place_name VARCHAR(120) NOT NULL,
    city VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    entry_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    distance_km DOUBLE NOT NULL DEFAULT 0.0,
    rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    popularity INT NOT NULL DEFAULT 0,
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Referential Integrity (Foreign Key)
    FOREIGN KEY (category_id) REFERENCES categories1(category_id),

    -- Domain & Business Rules Integrity
    CONSTRAINT uq_place_city UNIQUE (place_name, city),
    CHECK (entry_fee >= 0),
    CHECK (distance_km >= 0),
    CHECK (rating BETWEEN 0 AND 5),
    CHECK (popularity >= 0),
    CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- STEP 4: SEED MASTER CATEGORIES
INSERT INTO categories1 (category_name) VALUES
('Beach'),
('Historical'),
('Nature'),
('Temple'),
('Wildlife'),
('Hill Station');

-- STEP 5: SEED INITIAL PROTOTYPE DESTINATIONS (12 KEY KARNATAKA SPOTS)
INSERT INTO tourist_places 
(place_name, city, category_id, entry_fee, distance_km, rating, popularity)
VALUES
('Unkal Lake & Park', 'Hubballi', 3, 10.00, 6.0, 4.30, 82),
('Chandramouleshwara Temple', 'Hubballi', 4, 0.00, 8.5, 4.50, 78),
('Nrupatunga Betta Viewpoint', 'Hubballi', 3, 20.00, 10.0, 4.40, 80),
('Sadhankeri Park & Lake', 'Dharwad', 3, 10.00, 22.0, 4.20, 72),
('Gokarna Om Beach', 'Gokarna', 1, 0.00, 150.0, 4.60, 92),
('Murudeshwar Temple & Beach', 'Murudeshwar', 4, 0.00, 185.0, 4.70, 95),
('Jog Falls Viewpoint', 'Shivamogga', 3, 50.00, 160.0, 4.70, 93),
('Virupaksha Temple & Hampi', 'Hampi', 2, 50.00, 165.0, 4.90, 98),
('Badami Cave Temples', 'Badami', 2, 30.00, 105.0, 4.70, 91),
('Mysore Palace', 'Mysuru', 2, 100.00, 410.0, 4.90, 98),
('Dandeli River Rafting', 'Dandeli', 5, 250.00, 74.0, 4.60, 94),
('Mullayanagiri Peak', 'Chikkamagaluru', 6, 0.00, 275.0, 4.80, 96);

-- STEP 6: VIEW INITIAL DATA REGISTER
SELECT * FROM tourist_places;

-- STEP 7: SCHEMA EVOLUTION (ALTER TABLE OPERATIONS)
-- 1. Adding audit update timestamp
-- 2. Adding seasonal recommendation attribute
-- 3. Expanding character length for descriptive place names
ALTER TABLE tourist_places 
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE tourist_places 
ADD COLUMN best_time_to_visit VARCHAR(50) DEFAULT 'October to March';

ALTER TABLE tourist_places 
MODIFY COLUMN place_name VARCHAR(150) NOT NULL;

-- Verify Schema Changes
DESCRIBE tourist_places;

-- STEP 8: DATA UPDATES (SEASONAL RULES)
UPDATE tourist_places 
SET best_time_to_visit = 'July to October (Monsoon)' 
WHERE category_id = 3; -- Nature spots best in monsoon

UPDATE tourist_places 
SET best_time_to_visit = 'November to February (Winter)' 
WHERE category_id = 1; -- Beaches best in winter

-- STEP 9: GATE 0 - THEME 4 EVIDENCE (CRITERION B1)
-- Demonstrating the unprovable overwrite problem in traditional tables:
UPDATE tourist_places 
SET entry_fee = 75.00 
WHERE place_name = 'Jog Falls Viewpoint';

SELECT place_id, place_name, city, entry_fee, updated_at 
FROM tourist_places 
WHERE place_name = 'Jog Falls Viewpoint';

-- STEP 10: DAY 1 FINAL VERIFICATION QUERY
SELECT 
    p.place_id,
    p.place_name,
    p.city,
    c.category_name,
    p.entry_fee,
    p.distance_km,
    p.rating,
    p.popularity,
    p.best_time_to_visit,
    p.status,
    p.created_at,
    p.updated_at
FROM tourist_places p
JOIN categories1 c ON p.category_id = c.category_id
ORDER BY p.rating DESC;


-- #######################################################################################
-- PART 2: [DAY 2 TASK] - ADVANCED SCHEMA EVOLUTION, DATA EXPANSION & AUDIT REGISTER
-- Continuing directly on top of Day 1 database without separate files:
-- #######################################################################################

-- STEP 11: ALTER TABLE - ADD STATE AND DESCRIPTION ATTRIBUTES
ALTER TABLE tourist_places 
ADD COLUMN state VARCHAR(50) NOT NULL DEFAULT 'Karnataka';

ALTER TABLE tourist_places 
ADD COLUMN description TEXT;

-- STEP 12: ALTER TABLE - ADD STRING INTEGRITY CONSTRAINTS
ALTER TABLE tourist_places 
ADD CONSTRAINT chk_place_name_not_empty CHECK (CHAR_LENGTH(TRIM(place_name)) > 0);

ALTER TABLE tourist_places 
ADD CONSTRAINT chk_city_not_empty CHECK (CHAR_LENGTH(TRIM(city)) > 0);

-- STEP 13: UPDATE DESCRIPTIONS FOR EXISTING 12 DESTINATIONS
UPDATE tourist_places 
SET description = 'A calm lakeside escape for an evening walk, a quiet pause or a family outing in Hubballi.' 
WHERE place_name = 'Unkal Lake & Park';

UPDATE tourist_places 
SET description = 'Discover the stone carvings and Chalukyan architecture of this historic temple.' 
WHERE place_name = 'Chandramouleshwara Temple';

UPDATE tourist_places 
SET description = 'Scenic hillock offering panoramic viewpoints across Hubballi-Dharwad twin cities.' 
WHERE place_name = 'Nrupatunga Betta Viewpoint';

UPDATE tourist_places 
SET description = 'Serene garden memorial commemorating national poet Da. Ra. Bendre.' 
WHERE place_name = 'Sadhankeri Park & Lake';

UPDATE tourist_places 
SET description = 'A sweeping coastline, rocky coves and a laid-back beach town atmosphere.' 
WHERE place_name = 'Gokarna Om Beach';

UPDATE tourist_places 
SET description = 'A dramatic coastal landmark combining temple architecture with Arabian Sea views.' 
WHERE place_name = 'Murudeshwar Temple & Beach';

UPDATE tourist_places 
SET description = 'Take in a dramatic waterfall framed by the forested Western Ghats.' 
WHERE place_name = 'Jog Falls Viewpoint';

UPDATE tourist_places 
SET description = 'Walk through an extraordinary landscape of temples, stone streets and Vijayanagara ruins.' 
WHERE place_name = 'Virupaksha Temple & Hampi';

UPDATE tourist_places 
SET description = 'Explore rock-cut cave shrines overlooking red sandstone cliffs and Agastya Lake.' 
WHERE place_name = 'Badami Cave Temples';

UPDATE tourist_places 
SET description = 'Visit an ornate royal residence known for its grand halls and illuminated facade.' 
WHERE place_name = 'Mysore Palace';

UPDATE tourist_places 
SET description = 'River scenery, forest trails and outdoor adventures along the Kali River.' 
WHERE place_name = 'Dandeli River Rafting';

UPDATE tourist_places 
SET description = 'A high mountain viewpoint with winding roads, cool air and wide hill-country views.' 
WHERE place_name = 'Mullayanagiri Peak';

-- STEP 14: DATA EXPANSION - INSERT 10 NEW KARNATAKA DESTINATIONS (CATALOG GROWS TO 22)
INSERT INTO tourist_places 
(place_name, city, state, category_id, entry_fee, distance_km, rating, popularity, description, best_time_to_visit)
VALUES
('Kudle Beach', 'Gokarna', 'Karnataka', 1, 0.00, 152.0, 4.50, 88, 'Scenic coastal stretch ideal for sunsets and relaxed beachside cafes.', 'November to February (Winter)'),
('Yana Rocks & Caves', 'Kumta', 'Karnataka', 3, 20.00, 140.0, 4.60, 85, 'Gigantic crystalline limestone rock formations surrounded by thick rainforest.', 'October to March'),
('Sathodi Falls', 'Yellapur', 'Karnataka', 3, 30.00, 75.0, 4.50, 81, 'A picturesque rectangular forest waterfall formed by multiple tributaries.', 'July to October (Monsoon)'),
('Magod Falls', 'Yellapur', 'Karnataka', 3, 20.00, 80.0, 4.30, 76, 'Bedthi river tumbling down two tiers amidst dense Western Ghats valleys.', 'July to October (Monsoon)'),
('Sirsi Marikamba Temple', 'Sirsi', 'Karnataka', 4, 0.00, 102.0, 4.80, 89, 'Renowned 16th-century historic temple adorned with traditional wooden carvings.', 'October to March'),
('Pattadakal UNESCO Monuments', 'Pattadakal', 'Karnataka', 2, 40.00, 128.0, 4.80, 90, 'UNESCO World Heritage cluster of 8th-century Rekha-Nagara and Dravidian temples.', 'October to March'),
('Aihole Historical Complex', 'Aihole', 'Karnataka', 2, 30.00, 135.0, 4.50, 84, 'Known as the cradle of Hindu rock and structural temple architecture.', 'October to March'),
('Gol Gumbaz', 'Vijayapura', 'Karnataka', 2, 25.00, 200.0, 4.60, 87, 'Massive domed mausoleum famous for its acoustical Whispering Gallery.', 'October to March'),
('Chitradurga Fort', 'Chitradurga', 'Karnataka', 2, 25.00, 205.0, 4.70, 89, 'Impenetrable medieval stone fortress featuring seven circular walls and 19 gateways.', 'October to March'),
('Agumbe Sunset Point', 'Shivamogga', 'Karnataka', 6, 0.00, 240.0, 4.50, 85, 'High Ghats viewpoint famous for panoramic sunset views over the Arabian Sea.', 'October to March');

-- STEP 15: CREATE AUDIT TRAIL REGISTER TABLE (THEME 4 COMPLIANCE)
CREATE TABLE IF NOT EXISTS tourist_places_audit_log (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    place_id INT NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    old_entry_fee DECIMAL(10, 2) DEFAULT NULL,
    new_entry_fee DECIMAL(10, 2) DEFAULT NULL,
    old_rating DECIMAL(3, 2) DEFAULT NULL,
    new_rating DECIMAL(3, 2) DEFAULT NULL,
    old_status VARCHAR(10) DEFAULT NULL,
    new_status VARCHAR(10) DEFAULT NULL,
    performed_by VARCHAR(50) NOT NULL DEFAULT 'SYSTEM_ADMIN',
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- STEP 16: CREATE AUTOMATED AUDIT TRIGGERS (CLEAN STANDARD SYNTAX)
DROP TRIGGER IF EXISTS trg_audit_insert;

CREATE TRIGGER trg_audit_insert
AFTER INSERT ON tourist_places
FOR EACH ROW
INSERT INTO tourist_places_audit_log 
(place_id, action_type, new_entry_fee, new_rating, new_status, performed_by)
VALUES 
(NEW.place_id, 'INSERT_RECORD', NEW.entry_fee, NEW.rating, NEW.status, CURRENT_USER());

DROP TRIGGER IF EXISTS trg_audit_update;

CREATE TRIGGER trg_audit_update
AFTER UPDATE ON tourist_places
FOR EACH ROW
INSERT INTO tourist_places_audit_log 
(place_id, action_type, old_entry_fee, new_entry_fee, old_rating, new_rating, old_status, new_status, performed_by)
VALUES 
(NEW.place_id, 'RECORD_UPDATE', OLD.entry_fee, NEW.entry_fee, OLD.rating, NEW.rating, OLD.status, NEW.status, CURRENT_USER());

-- STEP 17: CREATE MIS REPORTING VIEWS
CREATE OR REPLACE VIEW vw_tourist_catalog AS
SELECT 
    p.place_id,
    p.place_name,
    p.city,
    p.state,
    c.category_name,
    p.entry_fee,
    p.distance_km,
    p.rating,
    p.popularity,
    p.best_time_to_visit,
    p.status
FROM tourist_places p
JOIN categories1 c ON p.category_id = c.category_id
WHERE p.status = 'ACTIVE';

CREATE OR REPLACE VIEW vw_category_summary AS
SELECT 
    c.category_name,
    COUNT(p.place_id) AS total_places,
    ROUND(AVG(p.rating), 2) AS avg_rating,
    ROUND(AVG(p.entry_fee), 2) AS avg_entry_fee,
    MIN(p.distance_km) AS nearest_km,
    MAX(p.distance_km) AS farthest_km
FROM categories1 c
LEFT JOIN tourist_places p ON c.category_id = p.category_id AND p.status = 'ACTIVE'
GROUP BY c.category_id, c.category_name;

-- STEP 18: DAY 2 FINAL VERIFICATION
DESCRIBE tourist_places;

-- View all 22 destinations enriched with state and descriptions
SELECT place_id, place_name, city, state, entry_fee, rating, description 
FROM tourist_places;

-- View Executive Category Summary
SELECT * FROM vw_category_summary;

-- View Audit Log
SELECT * FROM tourist_places_audit_log ORDER BY performed_at DESC;
