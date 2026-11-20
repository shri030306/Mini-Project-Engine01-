-- =======================================================================================
-- KLE TECHNOLOGICAL UNIVERSITY, HUBBALLI
-- DEPARTMENT OF BACHELOR OF COMPUTER APPLICATIONS
-- THEME 2: SEARCH AND RANKING SYSTEM
-- GATE 0 PROTOTYPE DATABASE SCRIPT (12 BASELINE KARNATAKA DESTINATIONS)
-- Project: Tourist Place Search and Ranking System
-- Engine 1: Data & Integrity (Database Management Systems)
-- Student: Shrilakshmi G.S (USN: 01FE24BCA314)
-- Faculty Guides: Prof. Pavankumar Vadavi, Prof. Sayeeda Anjum
-- Repository: https://github.com/shri030306/Mini-Project-Engine01-
-- =======================================================================================

-- STEP 1: INITIALIZE PROTOTYPE DATABASE
DROP DATABASE IF EXISTS tourist_db1;
CREATE DATABASE tourist_db1;
USE tourist_db1;

-- STEP 2: CREATE MASTER CATEGORIES TABLE (LOOKUP)
CREATE TABLE categories1 (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- STEP 3: CREATE TOURIST PLACES TABLE (GATE 0 PROTOTYPE SCHEMA)
CREATE TABLE tourist_places (
    place_id INT AUTO_INCREMENT PRIMARY KEY,
    place_name VARCHAR(120) NOT NULL,
    city VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    entry_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    distance_km DOUBLE NOT NULL DEFAULT 0.0,
    rating DECIMAL(3,2) NOT NULL DEFAULT 1.00,
    popularity INT NOT NULL DEFAULT 0,
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (category_id) REFERENCES categories1(category_id),
    CONSTRAINT uq_place_city UNIQUE (place_name, city),
    CHECK (entry_fee >= 0),
    CHECK (distance_km >= 0),
    CHECK (rating BETWEEN 1.00 AND 5.00),
    CHECK (popularity BETWEEN 0 AND 100),
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

-- STEP 6: VIEW INITIAL PROTOTYPE DATA
SELECT * FROM tourist_places;

-- STEP 7: SCHEMA EVOLUTION (GATE 0 EXPLORATION)
ALTER TABLE tourist_places 
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE tourist_places 
ADD COLUMN best_time_to_visit VARCHAR(50) DEFAULT 'October to March';

-- STEP 8: UPDATE SEASONAL RULES
UPDATE tourist_places 
SET best_time_to_visit = 'July to October (Monsoon)' 
WHERE category_id = 3;

UPDATE tourist_places 
SET best_time_to_visit = 'November to February (Winter)' 
WHERE category_id = 1;

-- STEP 9: GATE 0 LIMITATION PROOF (CRITERION B1)
-- Demonstrating the unprovable dispute in traditional travel systems:
UPDATE tourist_places 
SET entry_fee = 75.00 
WHERE place_name = 'Jog Falls Viewpoint';

-- The table shows 75.00, but there is NO audit record of the old fee (50.00) or WHO changed it!
-- This justifies introducing the automated Audit Trail Register in Gate 1.
SELECT place_id, place_name, city, entry_fee, updated_at 
FROM tourist_places 
WHERE place_name = 'Jog Falls Viewpoint';

-- STEP 10: GATE 0 FINAL VERIFICATION
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
    p.status
FROM tourist_places p
JOIN categories1 c ON p.category_id = c.category_id
ORDER BY p.rating DESC;
