-- =======================================================================================
-- KLE TECHNOLOGICAL UNIVERSITY, HUBBALLI
-- DEPARTMENT OF BACHELOR OF COMPUTER APPLICATIONS
-- THEME 4: REPORTING AND MIS SYSTEM / RULES CHECK RECORDS REGISTER
-- [DAY 2 TASK]: SCHEMA EVOLUTION, INTEGRITY CONSTRAINTS & AUDIT TRAIL
-- Project: Tourist Place Search and Ranking System
-- Engine 1: Data & Integrity (Database Management Systems)
-- Student: Shrilakshmi G.S (USN: 01FE24BCA314)
-- Faculty Guides: Prof. Pavankumar Vadavi, Prof. Sayeeda Anjum
-- Repository: https://github.com/shri030306/Mini-Project-Engine01-
-- =======================================================================================

USE tourist_db1;

-- =======================================================================================
-- SECTION 1: SCHEMA EVOLUTION (ALTER TABLE OPERATIONS)
-- =======================================================================================

-- 1. Add state column (Default: Karnataka)
ALTER TABLE tourist_places 
ADD COLUMN state VARCHAR(50) NOT NULL DEFAULT 'Karnataka';

-- 2. Add description text column
ALTER TABLE tourist_places 
ADD COLUMN description TEXT;

-- 3. Add string validation check constraints
ALTER TABLE tourist_places 
ADD CONSTRAINT chk_place_name_not_empty CHECK (CHAR_LENGTH(TRIM(place_name)) > 0);

ALTER TABLE tourist_places 
ADD CONSTRAINT chk_city_not_empty CHECK (CHAR_LENGTH(TRIM(city)) > 0);

-- =======================================================================================
-- SECTION 2: ENRICH EXISTING DESTINATIONS WITH DESCRIPTIONS
-- =======================================================================================
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

-- =======================================================================================
-- SECTION 3: DATA EXPANSION (10 NEW KARNATAKA DESTINATIONS)
-- =======================================================================================
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

-- =======================================================================================
-- SECTION 4: AUDIT TRAIL REGISTER TABLE (THEME 4 COMPLIANCE)
-- =======================================================================================
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

-- =======================================================================================
-- SECTION 5: AUTOMATED AUDIT TRIGGERS (CLEAN SYNTAX WITHOUT DELIMITER ERRORS)
-- =======================================================================================
DROP TRIGGER IF EXISTS trg_audit_insert;

CREATE TRIGGER trg_audit_insert
AFTER INSERT ON tourist_places
FOR EACH ROW
INSERT INTO tourist_places_audit_log 
(place_id, action_type, new_entry_fee, new_rating, new_status, performed_by)
VALUES 
(NEW.place_id, 'INSERT_RECORD', NEW.entry_fee, NEW.rating, NEW.status, CURRENT_USER());

-- Trigger for UPDATE tracking
DROP TRIGGER IF EXISTS trg_audit_update;

CREATE TRIGGER trg_audit_update
AFTER UPDATE ON tourist_places
FOR EACH ROW
INSERT INTO tourist_places_audit_log 
(place_id, action_type, old_entry_fee, new_entry_fee, old_rating, new_rating, old_status, new_status, performed_by)
VALUES 
(NEW.place_id, 'RECORD_UPDATE', OLD.entry_fee, NEW.entry_fee, OLD.rating, NEW.rating, OLD.status, NEW.status, CURRENT_USER());

-- =======================================================================================
-- SECTION 6: MIS REPORTING VIEWS
-- =======================================================================================
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

-- =======================================================================================
-- SECTION 7: DAY 2 VERIFICATION QUERIES
-- =======================================================================================
-- 1. View table schema (shows all columns including state and description)
DESCRIBE tourist_places;

-- 2. View all 22 destinations
SELECT place_id, place_name, city, state, entry_fee, rating, description 
FROM tourist_places;

-- 3. View Executive Summary by Category
SELECT * FROM vw_category_summary;

-- 4. View Audit Log
SELECT * FROM tourist_places_audit_log ORDER BY performed_at DESC;
