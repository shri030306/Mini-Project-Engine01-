-- =======================================================================================
-- KLE TECHNOLOGICAL UNIVERSITY, HUBBALLI
-- DEPARTMENT OF BACHELOR OF COMPUTER APPLICATIONS
-- THEME 2: SEARCH AND RANKING SYSTEM
-- MASTER PRODUCTION DATABASE SCRIPT (34 KARNATAKA DESTINATIONS + AUDIT REGISTERS)
-- Project  : Tourist Place Search and Ranking System
-- Engine 1 : Data & Integrity (Database Management Systems)
-- Student  : Shrilakshmi G.S  |  USN: 01FE24BCA314  |  Team 02  |  Division E
-- Engine 2 : Vivek B M  (Logic & Algorithms / Node API)
-- Engine 3 : Gouri K    (Interface & Web)
-- Guides   : Prof. Pavankumar Vadavi  |  Prof. Sayeeda Anjum
-- GitHub   : https://github.com/shri030306/Mini-Project-Engine01-
-- =======================================================================================
-- HOW TO RUN:
--   Open this file in MySQL Workbench → Click the LIGHTNING BOLT (⚡) to run ALL.
--   This is the ONLY script you need. Do NOT run day_2_database_alter_queries.sql
--   separately on a fresh database — this master script already includes everything.
-- =======================================================================================

-- #######################################################################################
-- PART 1: SAFE INITIALIZATION — Drop old tables and recreate clean
-- #######################################################################################

-- STEP 1: CREATE DATABASE SAFELY
CREATE DATABASE IF NOT EXISTS tourist_db1;
USE tourist_db1;

-- STEP 2: DROP OLD TABLES IN CORRECT ORDER (child tables first, then parent)
--         This fixes the Error 1054 (unknown column 'state') from old incomplete tables
DROP TABLE IF EXISTS tourist_places_audit_log;
DROP TABLE IF EXISTS tourist_places;
DROP TABLE IF EXISTS ranking_config;
DROP TABLE IF EXISTS categories1;

-- STEP 3: CREATE CATEGORIES LOOKUP TABLE
CREATE TABLE categories1 (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- STEP 4: CREATE RANKING CONFIG TABLE (ENGINE 2 WEIGHTS)
--   Rules:
--     - All weights must be >= 0
--     - All weights MUST sum to exactly 1.00
CREATE TABLE ranking_config (
    config_id          INT AUTO_INCREMENT PRIMARY KEY,
    config_name        VARCHAR(50)    NOT NULL UNIQUE,
    weight_rating      DECIMAL(3,2)   NOT NULL DEFAULT 0.35,
    weight_popularity  DECIMAL(3,2)   NOT NULL DEFAULT 0.25,
    weight_distance    DECIMAL(3,2)   NOT NULL DEFAULT 0.25,
    weight_cost        DECIMAL(3,2)   NOT NULL DEFAULT 0.15,
    weight_preference  DECIMAL(3,2)   NOT NULL DEFAULT 0.00,
    is_active          BOOLEAN        NOT NULL DEFAULT TRUE,
    updated_at         TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CHECK (weight_rating >= 0 AND weight_popularity >= 0 AND weight_distance >= 0
           AND weight_cost >= 0 AND weight_preference >= 0),
    CHECK (ROUND(weight_rating + weight_popularity + weight_distance + weight_cost + weight_preference, 2) = 1.00)
);

-- STEP 5: CREATE MAIN TOURIST PLACES TABLE
--   Integrity rules enforced:
--     1. FOREIGN KEY  → category_id must exist in categories1
--     2. UNIQUE       → no duplicate place_name + city combination
--     3. CHECK        → entry_fee >= 0  (never negative)
--     4. CHECK        → distance_km >= 0
--     5. CHECK        → rating BETWEEN 1.00 AND 5.00  (matches C++ Engine expectation)
--     6. CHECK        → popularity BETWEEN 0 AND 100  (Engine 2 normalized percentile)
--     7. CHECK        → status only 'ACTIVE' or 'INACTIVE'
CREATE TABLE tourist_places (
    place_id           INT AUTO_INCREMENT PRIMARY KEY,
    place_name         VARCHAR(150)   NOT NULL,
    city               VARCHAR(100)   NOT NULL,
    state              VARCHAR(50)    NOT NULL DEFAULT 'Karnataka',
    category_id        INT            NOT NULL,
    entry_fee          DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    distance_km        DOUBLE         NOT NULL DEFAULT 0.0,
    rating             DECIMAL(3,2)   NOT NULL DEFAULT 1.00,
    popularity         INT            NOT NULL DEFAULT 0,
    description        TEXT,
    best_time_to_visit VARCHAR(50)    DEFAULT 'October to March',
    status             VARCHAR(10)    NOT NULL DEFAULT 'ACTIVE',
    created_at         TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (category_id) REFERENCES categories1(category_id),
    CONSTRAINT uq_place_city UNIQUE (place_name, city),
    CHECK (entry_fee >= 0),
    CHECK (distance_km >= 0),
    CHECK (rating BETWEEN 1.00 AND 5.00),
    CHECK (popularity BETWEEN 0 AND 100),
    CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- STEP 6: CREATE AUDIT LOG TABLE (MIS Compliance / Change History Register)
CREATE TABLE tourist_places_audit_log (
    audit_id      INT AUTO_INCREMENT PRIMARY KEY,
    place_id      INT           NOT NULL,
    action_type   VARCHAR(20)   NOT NULL,
    old_entry_fee DECIMAL(10,2) DEFAULT NULL,
    new_entry_fee DECIMAL(10,2) DEFAULT NULL,
    old_rating    DECIMAL(3,2)  DEFAULT NULL,
    new_rating    DECIMAL(3,2)  DEFAULT NULL,
    old_status    VARCHAR(10)   DEFAULT NULL,
    new_status    VARCHAR(10)   DEFAULT NULL,
    performed_by  VARCHAR(50)   NOT NULL DEFAULT 'SYSTEM_ADMIN',
    performed_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- #######################################################################################
-- PART 2: SEED DATA
-- #######################################################################################

-- STEP 7: INSERT 6 CATEGORIES
INSERT INTO categories1 (category_id, category_name) VALUES
(1, 'Beach'),
(2, 'Historical'),
(3, 'Nature'),
(4, 'Temple'),
(5, 'Wildlife'),
(6, 'Hill Station');

-- STEP 8: INSERT DEFAULT RANKING WEIGHTS (Sum = 1.00)
INSERT INTO ranking_config
    (config_id, config_name, weight_rating, weight_popularity, weight_distance, weight_cost, weight_preference, is_active)
VALUES
    (1, 'DEFAULT_4_FACTOR',  0.35, 0.25, 0.25, 0.15, 0.00, TRUE),
    (2, 'EXTENDED_5_FACTOR', 0.30, 0.20, 0.20, 0.15, 0.15, FALSE);

-- STEP 9: INSERT ALL 34 KARNATAKA TOURIST PLACES
INSERT INTO tourist_places
    (place_id, place_name, city, state, category_id, entry_fee, distance_km, rating, popularity, description, best_time_to_visit, status)
VALUES
(1,  'Unkal Lake & Park',              'Hubballi',       'Karnataka', 3,  10.00,   6.0, 4.30, 82, 'Scenic urban lake with boating, garden walkways, and a statue of Swami Vivekananda.',              'July to October (Monsoon)',    'ACTIVE'),
(2,  'Chandramouleshwara Temple',      'Hubballi',       'Karnataka', 4,   0.00,   8.5, 4.50, 78, 'Chalukya-era 900-year-old carved black stone temple dedicated to Lord Shiva.',                   'October to March',            'ACTIVE'),
(3,  'Nrupatunga Betta Viewpoint',     'Hubballi',       'Karnataka', 3,  20.00,  10.0, 4.40, 80, 'Elevated scenic hill park offering panoramic sunset views over the twin cities.',                 'October to March',            'ACTIVE'),
(4,  'Sadhankeri Park & Lake',         'Dharwad',        'Karnataka', 3,  10.00,  22.0, 4.20, 72, 'Peaceful lakeside park and musical fountain commemorating poet Da Ra Bendre.',                   'October to March',            'ACTIVE'),
(5,  'Gokarna Om Beach',               'Gokarna',        'Karnataka', 1,   0.00, 150.0, 4.60, 92, 'Famous Om-shaped shoreline with golden sand, rocky coves, and ocean waves.',                     'November to February (Winter)','ACTIVE'),
(6,  'Murudeshwar Temple & Beach',     'Murudeshwar',    'Karnataka', 4,   0.00, 185.0, 4.70, 95, 'Colossal 123-foot Shiva statue perched on Kanduka Hill over the Arabian Sea.',                   'October to March',            'ACTIVE'),
(7,  'Jog Falls Viewpoint',            'Shivamogga',     'Karnataka', 3,  50.00, 160.0, 4.70, 93, 'Second highest plunge waterfall in India where the Sharavathi river cascades.',                  'July to October (Monsoon)',    'ACTIVE'),
(8,  'Virupaksha Temple & Hampi',      'Hampi',          'Karnataka', 2,  50.00, 165.0, 4.90, 98, 'UNESCO World Heritage monument showcasing Vijayanagara stone architecture.',                     'October to March',            'ACTIVE'),
(9,  'Badami Cave Temples',            'Badami',         'Karnataka', 2,  30.00, 105.0, 4.70, 91, 'Four rock-cut sandstone cave shrines overlooking ancient Agastya Lake.',                         'October to March',            'ACTIVE'),
(10, 'Mysore Palace',                  'Mysuru',         'Karnataka', 2, 100.00, 410.0, 4.90, 98, 'Magnificent Indo-Saracenic royal palace renowned for illuminated night facades.',                 'October to March',            'ACTIVE'),
(11, 'Dandeli River Rafting',          'Dandeli',        'Karnataka', 5, 250.00,  74.0, 4.60, 94, 'Whitewater rafting and wildlife safari amidst the dense Kali River forests.',                   'October to May',              'ACTIVE'),
(12, 'Mullayanagiri Peak',             'Chikkamagaluru', 'Karnataka', 6,   0.00, 275.0, 4.80, 96, 'Highest peak in Karnataka offering mist-covered mountain trekking trails.',                      'September to March',          'ACTIVE'),
(13, 'Kudle Beach',                    'Gokarna',        'Karnataka', 1,   0.00, 152.0, 4.50, 88, 'Scenic coastal stretch ideal for sunsets and relaxed beachside cafes.',                          'November to February (Winter)','ACTIVE'),
(14, 'Yana Rocks & Caves',             'Kumta',          'Karnataka', 3,  20.00, 140.0, 4.60, 85, 'Gigantic crystalline limestone rock formations surrounded by thick rainforest.',                  'October to March',            'ACTIVE'),
(15, 'Sathodi Falls',                  'Yellapur',       'Karnataka', 3,  30.00,  75.0, 4.50, 81, 'A picturesque rectangular forest waterfall formed by multiple tributaries.',                     'July to October (Monsoon)',    'ACTIVE'),
(16, 'Magod Falls',                    'Yellapur',       'Karnataka', 3,  20.00,  80.0, 4.30, 76, 'Bedthi river tumbling down two tiers amidst dense Western Ghats valleys.',                       'July to October (Monsoon)',    'ACTIVE'),
(17, 'Sirsi Marikamba Temple',         'Sirsi',          'Karnataka', 4,   0.00, 102.0, 4.80, 89, 'Renowned 16th-century historic temple adorned with traditional wooden carvings.',                'October to March',            'ACTIVE'),
(18, 'Pattadakal UNESCO Monuments',    'Pattadakal',     'Karnataka', 2,  40.00, 128.0, 4.80, 90, 'UNESCO World Heritage cluster of 8th-century Rekha-Nagara and Dravidian temples.',               'October to March',            'ACTIVE'),
(19, 'Aihole Historical Complex',      'Aihole',         'Karnataka', 2,  30.00, 135.0, 4.50, 84, 'Known as the cradle of Hindu rock and structural temple architecture.',                          'October to March',            'ACTIVE'),
(20, 'Gol Gumbaz',                     'Vijayapura',     'Karnataka', 2,  25.00, 200.0, 4.60, 87, 'Massive domed mausoleum famous for its acoustical Whispering Gallery.',                         'October to March',            'ACTIVE'),
(21, 'Chitradurga Fort',               'Chitradurga',    'Karnataka', 2,  25.00, 205.0, 4.70, 89, 'Impenetrable medieval stone fortress featuring seven circular walls and 19 gateways.',           'October to March',            'ACTIVE'),
(22, 'Agumbe Sunset Point',            'Shivamogga',     'Karnataka', 6,   0.00, 240.0, 4.50, 85, 'High Ghats viewpoint famous for panoramic sunset views over the Arabian Sea.',                   'October to March',            'ACTIVE'),
(23, 'Abbey Falls',                    'Madikeri',       'Karnataka', 3,  15.00, 360.0, 4.40, 86, 'Cascading waterfall amidst spice estates and coffee plantations in Coorg.',                      'July to November',            'ACTIVE'),
(24, 'Raja Seat Viewpoint',            'Madikeri',       'Karnataka', 6,  10.00, 358.0, 4.50, 88, 'Historic garden viewpoint where Kodagu kings enjoyed seasonal sunsets.',                         'October to March',            'ACTIVE'),
(25, 'Nagarhole National Park',        'Kodagu',         'Karnataka', 5, 300.00, 420.0, 4.70, 94, 'Dense Nilgiri biosphere reserve rich in tigers, elephants, and leopards.',                       'October to May',              'ACTIVE'),
(26, 'Bandipur Tiger Reserve',         'Chamarajanagar', 'Karnataka', 5, 350.00, 470.0, 4.80, 97, 'Premier Project Tiger sanctuary with guided jungle safaris and open grasslands.',                'October to May',              'ACTIVE'),
(27, 'Bannerghatta Biological Park',   'Bengaluru',      'Karnataka', 5, 150.00, 415.0, 4.40, 91, 'Expansive zoological park, butterfly house, and lion/tiger rescue center.',                      'Year Round',                  'ACTIVE'),
(28, 'Lalbagh Botanical Garden',       'Bengaluru',      'Karnataka', 3,  30.00, 412.0, 4.60, 93, 'Historic 240-acre botanical reserve with iconic Glass House and ancient rock.',                  'Year Round',                  'ACTIVE'),
(29, 'Belur Chennakeshava Temple',     'Belur',          'Karnataka', 2,   0.00, 290.0, 4.80, 92, 'Masterpiece of 12th-century Hoysala architecture with intricate star-shaped friezes.',          'October to March',            'ACTIVE'),
(30, 'Halebidu Hoysaleshwara Temple',  'Halebidu',       'Karnataka', 2,   0.00, 285.0, 4.70, 90, 'Twin Shiva temples renowned for detailed stone reliefs and ornamental pillars.',                 'October to March',            'ACTIVE'),
(31, 'Shravanabelagola Gommateshwara', 'Hassan',         'Karnataka', 4,   0.00, 345.0, 4.80, 93, 'World famous 57-foot monolithic granite statue of Lord Bahubali atop Vindhyagiri.',             'October to March',            'ACTIVE'),
(32, 'Panambur Beach',                 'Mangaluru',      'Karnataka', 1,   0.00, 330.0, 4.40, 87, 'Popular coastal beach known for clean shores, kite festivals, and water sports.',                'November to February (Winter)','ACTIVE'),
(33, 'Tannirbhavi Beach',              'Mangaluru',      'Karnataka', 1,   0.00, 335.0, 4.50, 85, 'Tranquil beach with casuarina groves, ferry access, and sunset promenades.',                    'November to February (Winter)','ACTIVE'),
(34, 'Kudremukh National Park',        'Chikkamagaluru', 'Karnataka', 6,  50.00, 310.0, 4.70, 91, 'Horse-face shaped peak known for rolling shola grasslands and bio-diverse valleys.',             'September to February',       'ACTIVE');


-- #######################################################################################
-- PART 3: TRIGGERS — Automatic Audit Logging
-- #######################################################################################

-- TRIGGER 1: Fires automatically AFTER every INSERT into tourist_places
DROP TRIGGER IF EXISTS trg_audit_insert;
CREATE TRIGGER trg_audit_insert
AFTER INSERT ON tourist_places
FOR EACH ROW
INSERT INTO tourist_places_audit_log
    (place_id, action_type, new_entry_fee, new_rating, new_status, performed_by)
VALUES
    (NEW.place_id, 'INSERT_RECORD', NEW.entry_fee, NEW.rating, NEW.status, CURRENT_USER());

-- TRIGGER 2: Fires automatically AFTER every UPDATE on tourist_places
DROP TRIGGER IF EXISTS trg_audit_update;
CREATE TRIGGER trg_audit_update
AFTER UPDATE ON tourist_places
FOR EACH ROW
INSERT INTO tourist_places_audit_log
    (place_id, action_type, old_entry_fee, new_entry_fee, old_rating, new_rating, old_status, new_status, performed_by)
VALUES
    (NEW.place_id, 'RECORD_UPDATE', OLD.entry_fee, NEW.entry_fee, OLD.rating, NEW.rating, OLD.status, NEW.status, CURRENT_USER());


-- #######################################################################################
-- PART 4: MIS REPORTING VIEWS
-- #######################################################################################

-- VIEW 1: Full active catalog with category name (not number)
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

-- VIEW 2: Category-wise MIS summary report
CREATE OR REPLACE VIEW vw_category_summary AS
SELECT
    c.category_name,
    COUNT(p.place_id)          AS total_places,
    ROUND(AVG(p.rating), 2)    AS avg_rating,
    ROUND(AVG(p.entry_fee), 2) AS avg_entry_fee,
    MIN(p.distance_km)         AS nearest_km,
    MAX(p.distance_km)         AS farthest_km
FROM categories1 c
LEFT JOIN tourist_places p ON c.category_id = p.category_id AND p.status = 'ACTIVE'
GROUP BY c.category_id, c.category_name;

-- VIEW 3: Budget-friendly places (entry fee <= Rs.25)
CREATE OR REPLACE VIEW vw_budget_friendly_places AS
SELECT
    place_id,
    place_name,
    city,
    entry_fee,
    rating,
    best_time_to_visit
FROM tourist_places
WHERE entry_fee <= 25.00 AND status = 'ACTIVE';


-- #######################################################################################
-- PART 5: DQL QUERIES (Day 3 Tasks)
-- #######################################################################################

-- TASK 3.1: INNER JOIN — Show category NAME instead of category number
SELECT
    p.place_name,
    p.city,
    c.category_name,
    p.entry_fee,
    p.rating,
    p.popularity
FROM tourist_places p
JOIN categories1 c ON p.category_id = c.category_id
ORDER BY p.city;

-- TASK 3.2: WHERE + AND — Budget & high-rating filter
SELECT
    place_name,
    city,
    entry_fee,
    rating,
    best_time_to_visit
FROM tourist_places
WHERE entry_fee <= 30.00 AND rating >= 4.50
ORDER BY rating DESC;

-- TASK 3.3: GROUP BY + COUNT/AVG/MAX — Category-wise MIS aggregation
SELECT
    c.category_name,
    COUNT(p.place_id)          AS total_places,
    ROUND(AVG(p.rating), 2)    AS average_rating,
    MAX(p.entry_fee)           AS max_entry_fee
FROM categories1 c
LEFT JOIN tourist_places p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name;

-- TASK 3.4: LIKE — Pattern search for Falls and Temples
SELECT
    place_name,
    city,
    entry_fee,
    rating
FROM tourist_places
WHERE place_name LIKE '%Falls%' OR place_name LIKE '%Temple%'
ORDER BY place_name;

-- TASK 3.5: ORDER BY + LIMIT — Top 5 most popular destinations
SELECT
    place_name,
    city,
    rating,
    popularity,
    best_time_to_visit
FROM tourist_places
ORDER BY popularity DESC
LIMIT 5;

-- TASK 3.6: Verify budget-friendly view
SELECT * FROM vw_budget_friendly_places;

-- BONUS: Verify full catalog view
SELECT * FROM vw_tourist_catalog;

-- BONUS: Verify category summary
SELECT * FROM vw_category_summary;

-- BONUS: Verify ranking config weights
SELECT * FROM ranking_config;

-- =======================================================================================
-- END OF MASTER SCRIPT
-- All 34 places loaded. All constraints, triggers, and views active.
-- GitHub: https://github.com/shri030306/Mini-Project-Engine01-
-- Student: Shrilakshmi G.S | USN: 01FE24BCA314 | Engine 1 | Team 02
-- =======================================================================================
