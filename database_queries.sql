-- =======================================================================================
-- KLE TECHNOLOGICAL UNIVERSITY, HUBBALLI
-- DEPARTMENT OF BACHELOR OF COMPUTER APPLICATIONS
-- THEME 2: SEARCH AND RANKING SYSTEM
-- MASTER PRODUCTION DATABASE SCRIPT (100 KARNATAKA DESTINATIONS + AUDIT + ITINERARIES)
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
--   This single master script drops old tables in safe order and sets up the complete
--   schema (6 tables, 4 views, 2 triggers, 34 places, 4 curated itineraries).
-- =======================================================================================

-- #######################################################################################
-- PART 1: SAFE INITIALIZATION — Drop old tables and recreate clean
-- #######################################################################################

-- STEP 1: CREATE DATABASE SAFELY
CREATE DATABASE IF NOT EXISTS tourist_db1;
USE tourist_db1;

-- STEP 2: DROP OLD TABLES IN CORRECT ORDER (child tables first, then parent tables)
DROP TABLE IF EXISTS itinerary_places;
DROP TABLE IF EXISTS itineraries;
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

-- STEP 5: CREATE MAIN TOURIST PLACES TABLE (CORE RECORDS REGISTER)
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

-- STEP 7: CREATE ITINERARIES TABLE (TRIP PLANNER MASTER)
--   Enforces:
--     1. Positive duration (days >= 1)
--     2. Non-negative estimated budget
--     3. Valid difficulty level ('EASY', 'MODERATE', 'CHALLENGING')
--     4. Active status flag
CREATE TABLE itineraries (
    itinerary_id        INT AUTO_INCREMENT PRIMARY KEY,
    itinerary_name      VARCHAR(150)   NOT NULL UNIQUE,
    theme               VARCHAR(50)    NOT NULL DEFAULT 'General',
    duration_days       INT            NOT NULL DEFAULT 1,
    estimated_budget    DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    difficulty_level    VARCHAR(20)    NOT NULL DEFAULT 'EASY',
    target_audience     VARCHAR(50)    DEFAULT 'Family / Friends',
    status              VARCHAR(10)    NOT NULL DEFAULT 'ACTIVE',
    created_at          TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CHECK (duration_days >= 1),
    CHECK (estimated_budget >= 0),
    CHECK (difficulty_level IN ('EASY', 'MODERATE', 'CHALLENGING')),
    CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- STEP 8: CREATE ITINERARY_PLACES TABLE (ORDERED TRIP STOPS BRIDGE TABLE)
--   Enforces:
--     1. FOREIGN KEY to itineraries (ON DELETE CASCADE)
--     2. FOREIGN KEY to tourist_places (ON DELETE RESTRICT - protects catalog places)
--     3. UNIQUE (itinerary_id, day_number, stop_order) prevents ordering conflicts
--     4. Positive planned stay hours
CREATE TABLE itinerary_places (
    itinerary_place_id  INT AUTO_INCREMENT PRIMARY KEY,
    itinerary_id        INT            NOT NULL,
    place_id            INT            NOT NULL,
    day_number          INT            NOT NULL DEFAULT 1,
    stop_order          INT            NOT NULL DEFAULT 1,
    planned_stay_hours  DECIMAL(4,1)   NOT NULL DEFAULT 2.0,
    travel_mode         VARCHAR(30)    DEFAULT 'CAR / CAB',
    stop_notes          VARCHAR(255),
    created_at          TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (itinerary_id) REFERENCES itineraries(itinerary_id) ON DELETE CASCADE,
    FOREIGN KEY (place_id)     REFERENCES tourist_places(place_id)  ON DELETE RESTRICT,
    CONSTRAINT uq_itinerary_stop UNIQUE (itinerary_id, day_number, stop_order),
    CHECK (day_number >= 1),
    CHECK (stop_order >= 1),
    CHECK (planned_stay_hours > 0)
);


-- #######################################################################################
-- PART 2: SEED DATA
-- #######################################################################################

-- STEP 9: INSERT 6 MASTER CATEGORIES
INSERT INTO categories1 (category_id, category_name) VALUES
(1, 'Beach'),
(2, 'Historical'),
(3, 'Nature'),
(4, 'Temple'),
(5, 'Wildlife'),
(6, 'Hill Station');

-- STEP 10: INSERT DEFAULT RANKING WEIGHTS (Sum = 1.00)
INSERT INTO ranking_config
    (config_id, config_name, weight_rating, weight_popularity, weight_distance, weight_cost, weight_preference, is_active)
VALUES
    (1, 'DEFAULT_4_FACTOR',  0.35, 0.25, 0.25, 0.15, 0.00, TRUE),
    (2, 'EXTENDED_5_FACTOR', 0.30, 0.20, 0.20, 0.15, 0.15, FALSE);

-- STEP 11: INSERT ALL 100 KARNATAKA TOURIST PLACES (STATEWIDE CATALOG)
INSERT INTO tourist_places
    (place_id, place_name, city, state, category_id, entry_fee, distance_km, rating, popularity, description, best_time_to_visit, status)
VALUES
(1, 'Unkal Lake & Park', 'Hubballi', 'Karnataka', 3, 10.00, 6.0, 4.30, 82, 'Scenic urban lake with boating, garden walkways, and a statue of Swami Vivekananda.', 'July to October (Monsoon)', 'ACTIVE'),
(2, 'Chandramouleshwara Temple', 'Hubballi', 'Karnataka', 4, 0.00, 8.5, 4.50, 78, 'Chalukya-era 900-year-old carved black stone temple dedicated to Lord Shiva.', 'October to March', 'ACTIVE'),
(3, 'Nrupatunga Betta Viewpoint', 'Hubballi', 'Karnataka', 3, 20.00, 10.0, 4.40, 80, 'Elevated scenic hill park offering panoramic sunset views over the twin cities.', 'October to March', 'ACTIVE'),
(4, 'Sadhankeri Park & Lake', 'Dharwad', 'Karnataka', 3, 10.00, 22.0, 4.20, 72, 'Peaceful lakeside park and musical fountain commemorating poet Da Ra Bendre.', 'October to March', 'ACTIVE'),
(5, 'Gokarna Om Beach', 'Gokarna', 'Karnataka', 1, 0.00, 150.0, 4.60, 92, 'Famous Om-shaped shoreline with golden sand, rocky coves, and ocean waves.', 'November to February (Winter)', 'ACTIVE'),
(6, 'Murudeshwar Temple & Beach', 'Murudeshwar', 'Karnataka', 4, 0.00, 185.0, 4.70, 95, 'Colossal 123-foot Shiva statue perched on Kanduka Hill over the Arabian Sea.', 'October to March', 'ACTIVE'),
(7, 'Jog Falls Viewpoint', 'Shivamogga', 'Karnataka', 3, 50.00, 160.0, 4.70, 93, 'Second highest plunge waterfall in India where the Sharavathi river cascades.', 'July to October (Monsoon)', 'ACTIVE'),
(8, 'Virupaksha Temple & Hampi', 'Hampi', 'Karnataka', 2, 50.00, 165.0, 4.90, 98, 'UNESCO World Heritage monument showcasing Vijayanagara stone architecture.', 'October to March', 'ACTIVE'),
(9, 'Badami Cave Temples', 'Badami', 'Karnataka', 2, 30.00, 105.0, 4.70, 91, 'Four rock-cut sandstone cave shrines overlooking ancient Agastya Lake.', 'October to March', 'ACTIVE'),
(10, 'Mysore Palace', 'Mysuru', 'Karnataka', 2, 100.00, 410.0, 4.90, 98, 'Magnificent Indo-Saracenic royal palace renowned for illuminated night facades.', 'October to March', 'ACTIVE'),
(11, 'Dandeli River Rafting', 'Dandeli', 'Karnataka', 5, 250.00, 74.0, 4.60, 94, 'Whitewater rafting and wildlife safari amidst the dense Kali River forests.', 'October to May', 'ACTIVE'),
(12, 'Mullayanagiri Peak', 'Chikkamagaluru', 'Karnataka', 6, 0.00, 275.0, 4.80, 96, 'Highest peak in Karnataka offering mist-covered mountain trekking trails.', 'September to March', 'ACTIVE'),
(13, 'Kudle Beach', 'Gokarna', 'Karnataka', 1, 0.00, 152.0, 4.50, 88, 'Scenic coastal stretch ideal for sunsets and relaxed beachside cafes.', 'November to February (Winter)', 'ACTIVE'),
(14, 'Yana Rocks & Caves', 'Kumta', 'Karnataka', 3, 20.00, 140.0, 4.60, 85, 'Gigantic crystalline limestone rock formations surrounded by thick rainforest.', 'October to March', 'ACTIVE'),
(15, 'Sathodi Falls', 'Yellapur', 'Karnataka', 3, 30.00, 75.0, 4.50, 81, 'A picturesque rectangular forest waterfall formed by multiple tributaries.', 'July to October (Monsoon)', 'ACTIVE'),
(16, 'Magod Falls', 'Yellapur', 'Karnataka', 3, 20.00, 80.0, 4.30, 76, 'Bedthi river tumbling down two tiers amidst dense Western Ghats valleys.', 'July to October (Monsoon)', 'ACTIVE'),
(17, 'Sirsi Marikamba Temple', 'Sirsi', 'Karnataka', 4, 0.00, 102.0, 4.80, 89, 'Renowned 16th-century historic temple adorned with traditional wooden carvings.', 'October to March', 'ACTIVE'),
(18, 'Pattadakal UNESCO Monuments', 'Pattadakal', 'Karnataka', 2, 40.00, 128.0, 4.80, 90, 'UNESCO World Heritage cluster of 8th-century Rekha-Nagara and Dravidian temples.', 'October to March', 'ACTIVE'),
(19, 'Aihole Historical Complex', 'Aihole', 'Karnataka', 2, 30.00, 135.0, 4.50, 84, 'Known as the cradle of Hindu rock and structural temple architecture.', 'October to March', 'ACTIVE'),
(20, 'Gol Gumbaz', 'Vijayapura', 'Karnataka', 2, 25.00, 200.0, 4.60, 87, 'Massive domed mausoleum famous for its acoustical Whispering Gallery.', 'October to March', 'ACTIVE'),
(21, 'Chitradurga Fort', 'Chitradurga', 'Karnataka', 2, 25.00, 205.0, 4.70, 89, 'Impenetrable medieval stone fortress featuring seven circular walls and 19 gateways.', 'October to March', 'ACTIVE'),
(22, 'Agumbe Sunset Point', 'Shivamogga', 'Karnataka', 6, 0.00, 240.0, 4.50, 85, 'High Ghats viewpoint famous for panoramic sunset views over the Arabian Sea.', 'October to March', 'ACTIVE'),
(23, 'Abbey Falls', 'Madikeri', 'Karnataka', 3, 15.00, 360.0, 4.40, 86, 'Cascading waterfall amidst spice estates and coffee plantations in Coorg.', 'July to November', 'ACTIVE'),
(24, 'Raja Seat Viewpoint', 'Madikeri', 'Karnataka', 6, 10.00, 358.0, 4.50, 88, 'Historic garden viewpoint where Kodagu kings enjoyed seasonal sunsets.', 'October to March', 'ACTIVE'),
(25, 'Nagarhole National Park', 'Kodagu', 'Karnataka', 5, 300.00, 420.0, 4.70, 94, 'Dense Nilgiri biosphere reserve rich in tigers, elephants, and leopards.', 'October to May', 'ACTIVE'),
(26, 'Bandipur Tiger Reserve', 'Chamarajanagar', 'Karnataka', 5, 350.00, 470.0, 4.80, 97, 'Premier Project Tiger sanctuary with guided jungle safaris and open grasslands.', 'October to May', 'ACTIVE'),
(27, 'Bannerghatta Biological Park', 'Bengaluru', 'Karnataka', 5, 150.00, 415.0, 4.40, 91, 'Expansive zoological park, butterfly house, and lion/tiger rescue center.', 'Year Round', 'ACTIVE'),
(28, 'Lalbagh Botanical Garden', 'Bengaluru', 'Karnataka', 3, 30.00, 412.0, 4.60, 93, 'Historic 240-acre botanical reserve with iconic Glass House and ancient rock.', 'Year Round', 'ACTIVE'),
(29, 'Belur Chennakeshava Temple', 'Belur', 'Karnataka', 2, 0.00, 290.0, 4.80, 92, 'Masterpiece of 12th-century Hoysala architecture with intricate star-shaped friezes.', 'October to March', 'ACTIVE'),
(30, 'Halebidu Hoysaleshwara Temple', 'Halebidu', 'Karnataka', 2, 0.00, 285.0, 4.70, 90, 'Twin Shiva temples renowned for detailed stone reliefs and ornamental pillars.', 'October to March', 'ACTIVE'),
(31, 'Shravanabelagola Gommateshwara', 'Hassan', 'Karnataka', 4, 0.00, 345.0, 4.80, 93, 'World famous 57-foot monolithic granite statue of Lord Bahubali atop Vindhyagiri.', 'October to March', 'ACTIVE'),
(32, 'Panambur Beach', 'Mangaluru', 'Karnataka', 1, 0.00, 330.0, 4.40, 87, 'Popular coastal beach known for clean shores, kite festivals, and water sports.', 'November to February (Winter)', 'ACTIVE'),
(33, 'Tannirbhavi Beach', 'Mangaluru', 'Karnataka', 1, 0.00, 335.0, 4.50, 85, 'Tranquil beach with casuarina groves, ferry access, and sunset promenades.', 'November to February (Winter)', 'ACTIVE'),
(34, 'Kudremukh National Park', 'Chikkamagaluru', 'Karnataka', 6, 50.00, 310.0, 4.70, 91, 'Horse-face shaped peak known for rolling shola grasslands and bio-diverse valleys.', 'September to February', 'ACTIVE'),
(35, 'Malpe Beach & Sea Walk', 'Udupi', 'Karnataka', 1, 0.00, 290.0, 4.60, 90, 'Scenic shoreline featuring sea walk promenade, water sports, and boat trips to basaltic St. Mary''s Island.', 'October to March', 'ACTIVE'),
(36, 'St. Mary's Island', 'Malpe', 'Karnataka', 1, 300.00, 292.0, 4.70, 92, 'Unique geological monument of columnar hexagonal basalt rock formations in Arabian Sea.', 'October to April', 'ACTIVE'),
(37, 'Maravanthe Beach Highway', 'Kundapura', 'Karnataka', 1, 0.00, 245.0, 4.60, 88, 'Picturesque coastal highway with the Arabian Sea on one side and Souparnika River on the other.', 'October to March', 'ACTIVE'),
(38, 'Kaup Beach & Lighthouse', 'Udupi', 'Karnataka', 1, 20.00, 300.0, 4.50, 86, 'Historic 1901 British lighthouse atop coastal rocks offering panoramic Arabian sea views.', 'October to March', 'ACTIVE'),
(39, 'Devbagh Beach', 'Karwar', 'Karnataka', 1, 50.00, 165.0, 4.50, 84, 'Secluded private beach with casuarina groves, dolphin boat cruises, and snorkeling.', 'October to April', 'ACTIVE'),
(40, 'Someshwar Beach & Rudra Shila', 'Mangaluru', 'Karnataka', 1, 0.00, 340.0, 4.40, 83, 'Hidden rocky beach famous for colossal natural black rocks known as Rudra Shila.', 'October to March', 'ACTIVE'),
(41, 'Half Moon Beach', 'Gokarna', 'Karnataka', 1, 0.00, 153.0, 4.50, 85, 'Crescent-shaped cliff-side beach accessible only via trekking or scenic boat ride.', 'November to February', 'ACTIVE'),
(42, 'Rabindranath Tagore Beach', 'Karwar', 'Karnataka', 1, 0.00, 160.0, 4.40, 82, 'Wide city beach featuring INS Chapal warship museum, musical fountain, and promenade.', 'October to March', 'ACTIVE'),
(43, 'Bidar Fort & Solah Khamba', 'Bidar', 'Karnataka', 2, 25.00, 380.0, 4.70, 89, 'Magnificent Bahmani fortress with triple moat system, Mahmud Gawan Madrasa, and royal palaces.', 'October to March', 'ACTIVE'),
(44, 'Gulbarga Fort & Great Mosque', 'Kalaburagi', 'Karnataka', 2, 20.00, 310.0, 4.50, 82, 'Ancient 14th-century fortress featuring Persian-style roofed Jami Masjid and royal citadel.', 'October to March', 'ACTIVE'),
(45, 'Kittur Chennamma Fort & Palace', 'Belagavi', 'Karnataka', 2, 15.00, 55.0, 4.40, 80, 'Historical citadel of Queen Rani Chennamma who led the 1824 armed rebellion against British rule.', 'October to March', 'ACTIVE'),
(46, 'Srirangapatna Dariya Daulat Palace', 'Mandya', 'Karnataka', 2, 25.00, 395.0, 4.70, 92, 'Teakwood summer palace of Tipu Sultan adorned with intricate murals and battle frescoes.', 'Year Round', 'ACTIVE'),
(47, 'Bangalore Palace', 'Bengaluru', 'Karnataka', 2, 250.00, 410.0, 4.50, 93, 'Tudor-style royal estate with fortified towers, stained glass, and historic wood carvings.', 'Year Round', 'ACTIVE'),
(48, 'Tipu Sultan Summer Palace', 'Bengaluru', 'Karnataka', 2, 20.00, 414.0, 4.40, 86, 'Two-storey ornate wooden palace built with teak pillars, arches, and balconies in old city.', 'Year Round', 'ACTIVE'),
(49, 'Mirjan Fort', 'Kumta', 'Karnataka', 2, 0.00, 148.0, 4.60, 87, '16th-century laterite stone fortress built by Pepper Queen Rani Chennabhairadevi amidst rivers.', 'October to March', 'ACTIVE'),
(50, 'Madikeri Fort & Palace', 'Madikeri', 'Karnataka', 2, 20.00, 362.0, 4.40, 85, 'Elevated fort rebuilt by Tipu Sultan with stone elephants, clock tower, and museum.', 'July to March', 'ACTIVE'),
(51, 'Kavaledurga Fort', 'Thirthahalli', 'Karnataka', 2, 0.00, 195.0, 4.60, 84, 'Ancient misty hill fort built by Keladi Nayakas with nine defence gates amidst rainforest.', 'October to February', 'ACTIVE'),
(52, 'Basavakalyan Fort', 'Bidar', 'Karnataka', 2, 20.00, 350.0, 4.50, 81, 'Historic capital of Western Chalukyas and birthplace of 12th-century Sharana movement.', 'October to March', 'ACTIVE'),
(53, 'Melukote Cheluvanarayana Temple & Kalyani', 'Mandya', 'Karnataka', 2, 0.00, 375.0, 4.70, 88, 'Ancient hill town with Hoysala shrines, sacred stepped water tanks, and Sanskrit academy.', 'September to March', 'ACTIVE'),
(54, 'Talakadu Sand Dunes & Temples', 'Mysuru', 'Karnataka', 2, 0.00, 435.0, 4.50, 85, 'Historic township on Kaveri banks where ancient stone temples are buried under deep sand dunes.', 'October to March', 'ACTIVE'),
(55, 'Ibrahim Rauza Mausoleum', 'Vijayapura', 'Karnataka', 2, 25.00, 198.0, 4.70, 88, 'Twin-domed palatial tomb often hailed as the Taj Mahal of the Deccan for its symmetry.', 'October to March', 'ACTIVE'),
(56, 'Bellary Rock Fort', 'Ballari', 'Karnataka', 2, 20.00, 210.0, 4.40, 80, 'Imposing monolithic granite hill fort fortified by Vijayanagara kings and later by Haider Ali.', 'October to March', 'ACTIVE'),
(57, 'Somnathpur Keshava Temple', 'Mysuru', 'Karnataka', 2, 25.00, 430.0, 4.80, 91, 'Trikuta 13th-century Hoysala masterpiece covered in outer wall reliefs and ceiling stars.', 'October to March', 'ACTIVE'),
(58, 'Shivanasamudra Gaganachukki Falls', 'Mandya', 'Karnataka', 3, 20.00, 440.0, 4.70, 94, 'Twin torrential waterfalls where the Kaveri river splits across rocky ravines.', 'July to October (Monsoon)', 'ACTIVE'),
(59, 'Shivanasamudra Barachukki Falls', 'Chamarajanagar', 'Karnataka', 3, 20.00, 442.0, 4.60, 92, 'Wide cascading segment of the Kaveri river with coracle rides and mist viewpoints.', 'July to October (Monsoon)', 'ACTIVE'),
(60, 'Hebbe Falls', 'Chikkamagaluru', 'Karnataka', 3, 50.00, 260.0, 4.60, 89, 'Two-stage mountain waterfall inside private coffee estates reached by rugged 4x4 jeep trails.', 'August to January', 'ACTIVE'),
(61, 'Iruppu Falls', 'Kodagu', 'Karnataka', 3, 50.00, 385.0, 4.60, 90, 'Sacred Lakshmana Tirtha river waterfall dropping down Brahmagiri forest cliffs.', 'July to December', 'ACTIVE'),
(62, 'Gokak Falls', 'Belagavi', 'Karnataka', 3, 20.00, 145.0, 4.50, 87, 'Horse-shoe shaped gorge waterfall on Ghataprabha river featuring a century-old suspension bridge.', 'July to October (Monsoon)', 'ACTIVE'),
(63, 'Vibhooti Falls', 'Ankola', 'Karnataka', 3, 30.00, 135.0, 4.70, 91, 'Limestone forest waterfall with turquoise plunge pools perfect for natural swimming.', 'September to March', 'ACTIVE'),
(64, 'Kalhatti Falls', 'Chikkamagaluru', 'Karnataka', 3, 0.00, 255.0, 4.40, 82, 'Waterfall cascading over ancient Veerabhadra temple caves surrounded by lush cardamom hills.', 'July to November', 'ACTIVE'),
(65, 'Unchalli Falls', 'Sirsi', 'Karnataka', 3, 20.00, 125.0, 4.60, 86, '116-meter roaring plunge waterfall on Aghanashini river also called Lushington Falls.', 'July to December', 'ACTIVE'),
(66, 'Chunchi Falls', 'Ramanagara', 'Karnataka', 3, 30.00, 460.0, 4.30, 81, 'Terraced rocky gorge waterfall along Arkavathi river ideal for day trekking.', 'August to November', 'ACTIVE'),
(67, 'Mekedatu & Sangama Gorge', 'Ramanagara', 'Karnataka', 3, 20.00, 470.0, 4.50, 88, 'Deep narrow granite chasm where Kaveri and Arkavathi rivers converge fiercely.', 'September to February', 'ACTIVE'),
(68, 'Balmuri & Edmuri Falls', 'Mysuru', 'Karnataka', 3, 20.00, 405.0, 4.30, 82, 'Gentle check-dam waterfall steps popular for wading and picnic film shoots.', 'Year Round', 'ACTIVE'),
(69, 'Godchinamalaki Falls', 'Belagavi', 'Karnataka', 3, 10.00, 150.0, 4.40, 80, 'Picturesque step-wise waterfall on Markandeya river nestled within a green valley.', 'July to October (Monsoon)', 'ACTIVE'),
(70, 'Cubbon Park', 'Bengaluru', 'Karnataka', 3, 0.00, 410.0, 4.60, 94, 'Historic 300-acre green lung in central Bengaluru with century-old trees and colonial statues.', 'Year Round', 'ACTIVE'),
(71, 'Karanji Lake & Butterfly Park', 'Mysuru', 'Karnataka', 3, 50.00, 412.0, 4.50, 87, 'Scenic urban wetland with India''s largest walk-through aviary, butterfly park, and boating.', 'Year Round', 'ACTIVE'),
(72, 'Brindavan Gardens', 'Mandya', 'Karnataka', 3, 50.00, 398.0, 4.60, 95, 'Terraced symmetrical Mughal-style garden at the base of KRS Dam with musical fountains.', 'Year Round', 'ACTIVE'),
(73, 'Bheemeshwari Cauvery River Camp', 'Mandya', 'Karnataka', 3, 100.00, 450.0, 4.50, 85, 'Riparian forest banks known for nature walks, coracle rides, and Mahseer fish conservation.', 'August to February', 'ACTIVE'),
(74, 'Udupi Sri Krishna Matha', 'Udupi', 'Karnataka', 4, 0.00, 295.0, 4.80, 96, 'Renowned 13th-century Dvaita monastery founded by Saint Madhvacharya with Kanakana Kindi window.', 'Year Round', 'ACTIVE'),
(75, 'Dharmasthala Manjunatha Temple', 'Dharmasthala', 'Karnataka', 4, 0.00, 310.0, 4.80, 97, 'Renowned Shaiva shrine administered by Jain Pergade family famous for Annadana free meals.', 'Year Round', 'ACTIVE'),
(76, 'Kukke Subramanya Temple', 'Subrahmanya', 'Karnataka', 4, 0.00, 345.0, 4.80, 96, 'Spiritual pilgrimage site nestled under Kumara Parvatha famous for Sarpa Samskara rituals.', 'Year Round', 'ACTIVE'),
(77, 'Sringeri Sharada Peetham', 'Chikkamagaluru', 'Karnataka', 4, 0.00, 250.0, 4.90, 96, 'First of four cardinal Advaita mathas established by Adi Shankaracharya on Tunga river.', 'Year Round', 'ACTIVE'),
(78, 'Kollur Mookambika Temple', 'Udupi', 'Karnataka', 4, 0.00, 230.0, 4.80, 94, 'Ancient Shakta pilgrimage shrine located in the foothills of Kodachadri hill.', 'Year Round', 'ACTIVE'),
(79, 'Horanadu Annapoorneshwari Temple', 'Chikkamagaluru', 'Karnataka', 4, 0.00, 265.0, 4.80, 93, 'Sacred deity of nourishment seated in a lush valley along Bhadra river with free meals.', 'Year Round', 'ACTIVE'),
(80, 'Chamundeshwari Temple', 'Mysuru', 'Karnataka', 4, 0.00, 420.0, 4.80, 97, 'Dravidian hill temple dedicated to guardian deity of Mysuru atop Chamundi Hill.', 'Year Round', 'ACTIVE'),
(81, 'Kateel Durgaparameshwari Temple', 'Mangaluru', 'Karnataka', 4, 0.00, 325.0, 4.70, 90, 'Island temple in the middle of Nandini river surrounded by scenic western ghat streams.', 'Year Round', 'ACTIVE'),
(82, 'Kudalasangama Sangameshwara Temple', 'Bagalkote', 'Karnataka', 4, 0.00, 130.0, 4.70, 89, 'Sacred confluence of Krishna and Malaprabha rivers where philosopher Basavanna attained Samadhi.', 'October to March', 'ACTIVE'),
(83, 'Savadatti Renuka Yellamma Temple', 'Belagavi', 'Karnataka', 4, 0.00, 78.0, 4.60, 91, 'Historic hilltop shrine drawing millions of pilgrims for annual Banada Hunnime fairs.', 'October to March', 'ACTIVE'),
(84, 'Banavasi Madhukeshwara Temple', 'Uttara Kannada', 'Karnataka', 4, 0.00, 115.0, 4.70, 86, 'Ancient capital of Kadamba dynasty featuring intricate carved stone couch and Nritya Mantapa.', 'October to March', 'ACTIVE'),
(85, 'Siddaroodha Math', 'Hubballi', 'Karnataka', 4, 0.00, 4.0, 4.70, 91, 'Prominent spiritual monastery and samadhi of 19th-century saint Swami Siddharoodha.', 'Year Round', 'ACTIVE'),
(86, 'Ranganathittu Bird Sanctuary', 'Srirangapatna', 'Karnataka', 5, 100.00, 395.0, 4.70, 93, 'Kaveri river islet sanctuary hosting painted storks, spoonbills, and marsh crocodiles on boat tours.', 'November to June', 'ACTIVE'),
(87, 'Dubare Elephant Camp', 'Kodagu', 'Karnataka', 5, 150.00, 365.0, 4.50, 92, 'Kaveri river elephant interaction center offering bathing, feeding, and coracle boating.', 'September to March', 'ACTIVE'),
(88, 'Kali Tiger Reserve', 'Dandeli', 'Karnataka', 5, 300.00, 85.0, 4.70, 91, 'Dense evergreen reserve home to black panthers, hornbills, and Kali river ecosystems.', 'October to May', 'ACTIVE'),
(89, 'Bhadra Wildlife Sanctuary', 'Chikkamagaluru', 'Karnataka', 5, 350.00, 210.0, 4.60, 89, 'Project Tiger sanctuary surrounded by Mullayanagiri and Bababudan hill ranges on Bhadra reservoir.', 'October to March', 'ACTIVE'),
(90, 'Daroji Sloth Bear Sanctuary', 'Ballari', 'Karnataka', 5, 50.00, 170.0, 4.50, 85, 'Specialized rocky sanctuary near Hampi providing open watchtower views of wild sloth bears.', 'October to March', 'ACTIVE'),
(91, 'Tyavarekoppa Lion & Tiger Safari', 'Shivamogga', 'Karnataka', 5, 100.00, 165.0, 4.40, 84, 'Enclosed forest safari park housing lions, tigers, leopards, and zoo aviary.', 'Year Round', 'ACTIVE'),
(92, 'Someshwara Wildlife Sanctuary', 'Udupi', 'Karnataka', 5, 50.00, 275.0, 4.50, 82, 'Pristine Western Ghats evergreen forest rich in king cobras, barking deer, and endemic birds.', 'October to April', 'ACTIVE'),
(93, 'Magadi Bird Sanctuary', 'Gadag', 'Karnataka', 5, 20.00, 58.0, 4.50, 84, 'Protected wetland lake serving as major wintering ground for bar-headed geese from Mongolia.', 'November to February', 'ACTIVE'),
(94, 'Kemmangundi Hill Station', 'Chikkamagaluru', 'Karnataka', 6, 20.00, 255.0, 4.60, 91, 'Picturesque hill retreat once favoured by Mysore Maharaja with Z-point cliff trails and rose gardens.', 'September to March', 'ACTIVE'),
(95, 'Nandi Hills', 'Chikkaballapur', 'Karnataka', 6, 30.00, 435.0, 4.60, 96, 'Popular sunrise fortress hill with Tipu Drop, ancient Bhoga Nandeeshwara temple, and misty summits.', 'Year Round', 'ACTIVE'),
(96, 'Baba Budangiri Peak', 'Chikkamagaluru', 'Karnataka', 6, 0.00, 270.0, 4.60, 90, 'Historic crescent mountain range where coffee was first planted in India, with Dattatreya shrine.', 'September to March', 'ACTIVE'),
(97, 'Kodachadri Peak', 'Shivamogga', 'Karnataka', 6, 0.00, 215.0, 4.80, 93, 'Natural heritage peak overlooking thick Ghats rainforest with ancient Sarvajna Peetha.', 'October to March', 'ACTIVE'),
(98, 'Tadiandamol Peak', 'Kodagu', 'Karnataka', 6, 20.00, 380.0, 4.70, 91, 'Highest mountain peak in Kodagu with scenic shola grassland hiking trails.', 'October to March', 'ACTIVE'),
(99, 'Biligiriranga Hills (BR Hills)', 'Chamarajanagar', 'Karnataka', 6, 0.00, 475.0, 4.50, 88, 'Ecological bridge between Western and Eastern Ghats with Biligiriranganatha swamy temple.', 'October to May', 'ACTIVE'),
(100, 'Skandagiri Sunrise Trek', 'Chikkaballapur', 'Karnataka', 6, 250.00, 440.0, 4.60, 92, 'Night trek destination famous for walking above clouds at sunrise over ruined hill fort.', 'Year Round', 'ACTIVE');

-- STEP 12: INSERT CURATED TRAVEL ITINERARIES
INSERT INTO itineraries
    (itinerary_id, itinerary_name, theme, duration_days, estimated_budget, difficulty_level, target_audience, status)
VALUES
(1, 'North Karnataka Chalukya & UNESCO Heritage', 'Historical',  3, 3500.00, 'MODERATE',    'History & Architecture Lovers', 'ACTIVE'),
(2, 'Western Ghats Waterfalls & Kali Adventure',  'Adventure',   2, 4200.00, 'CHALLENGING', 'Youth & Nature Trekkers',       'ACTIVE'),
(3, 'Coastal Beach & Temple Pilgrimage Trail',    'Spiritual',   2, 2800.00, 'EASY',        'Families & Solo Travelers',     'ACTIVE'),
(4, 'Hubballi-Dharwad Twin Cities Heritage Walk', 'City Tour',   1,  800.00, 'EASY',        'Students & Weekend Tourists',   'ACTIVE');

-- STEP 13: INSERT ITINERARY STOPS (MAPPING TO TOURIST PLACES)
INSERT INTO itinerary_places
    (itinerary_id, place_id, day_number, stop_order, planned_stay_hours, travel_mode, stop_notes)
VALUES
-- Itinerary 1: North Karnataka Chalukya & UNESCO Heritage (3 Days)
(1, 9,  1, 1, 3.0, 'CAR', 'Morning explore rock-cut Cave Temples overlooking Agastya lake.'),
(1, 18, 1, 2, 2.5, 'CAR', 'Afternoon visit Rekha-Nagara UNESCO complex.'),
(1, 19, 1, 3, 2.0, 'CAR', 'Evening sunset study of Durga Temple architecture in Aihole.'),
(1, 8,  2, 1, 5.0, 'CAR', 'Full day Vijayanagara empire exploration at Virupaksha and Hampi ruins.'),
(1, 20, 3, 1, 3.5, 'CAR', 'Morning tour of massive Whispering Gallery dome at Gol Gumbaz.'),

-- Itinerary 2: Western Ghats Waterfalls & Adventure Trail (2 Days)
(2, 11, 1, 1, 5.0, 'JEEP / CAB', 'Kali river white water rafting and morning jungle safari.'),
(2, 15, 1, 2, 2.5, 'CAB',        'Picnic lunch and photography at Sathodi rectangular falls.'),
(2, 16, 2, 1, 2.0, 'CAB',        'Morning view of Bedthi river cascading down two tiers.'),
(2, 14, 2, 2, 3.5, 'TREK / CAB', 'Rainforest trek to giant crystalline limestone peaks.'),

-- Itinerary 3: Coastal Beach & Temple Pilgrimage Trail (2 Days)
(3, 17, 1, 1, 2.0, 'CAR', 'Morning darshan at 16th century wooden-carved Marikamba shrine.'),
(3, 6,  1, 2, 3.5, 'CAR', 'Afternoon darshan of 123-foot Shiva statue overlooking Arabian Sea.'),
(3, 5,  2, 1, 3.0, 'CAB', 'Morning beach walk along the iconic Om-shaped shoreline.'),
(3, 13, 2, 2, 2.5, 'CAB', 'Relaxed beachside cafe sunset at Kudle cove.'),

-- Itinerary 4: Hubballi-Dharwad Twin Cities Heritage Walk (1 Day)
(4, 2,  1, 1, 1.5, 'AUTO / CAB', 'Morning darshan at 900-year-old carved black stone temple.'),
(4, 1,  1, 2, 2.5, 'AUTO / CAB', 'Boating and lunch walk around Unkal Lake park.'),
(4, 3,  1, 3, 2.0, 'AUTO / CAB', 'Panoramic sunset viewpoint over the twin cities at Nrupatunga Betta.'),
(4, 4,  1, 4, 1.5, 'AUTO / CAB', 'Evening musical fountain at poet Da Ra Bendre park.');


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

-- VIEW 4: Itinerary Details View (Multi-Table Join: itineraries + stops + places)
CREATE OR REPLACE VIEW vw_itinerary_details AS
SELECT
    i.itinerary_id,
    i.itinerary_name,
    i.theme,
    i.duration_days,
    i.estimated_budget,
    i.difficulty_level,
    ip.day_number,
    ip.stop_order,
    p.place_name,
    p.city,
    c.category_name,
    p.entry_fee,
    p.rating,
    ip.planned_stay_hours,
    ip.travel_mode,
    ip.stop_notes
FROM itineraries i
JOIN itinerary_places ip ON i.itinerary_id = ip.itinerary_id
JOIN tourist_places p    ON ip.place_id = p.place_id
JOIN categories1 c       ON p.category_id = c.category_id
WHERE i.status = 'ACTIVE' AND p.status = 'ACTIVE'
ORDER BY i.itinerary_id, ip.day_number, ip.stop_order;


-- #######################################################################################
-- PART 5: DQL QUERIES (Day 3 & Advanced Project Queries)
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

-- TASK 3.7 (NEW): ITINERARY DETAILS QUERY — Day-by-day plan for Itinerary 1
SELECT
    itinerary_name,
    day_number,
    stop_order,
    place_name,
    city,
    category_name,
    entry_fee,
    planned_stay_hours,
    travel_mode,
    stop_notes
FROM vw_itinerary_details
WHERE itinerary_id = 1
ORDER BY day_number, stop_order;

-- TASK 3.8 (NEW): ITINERARY SUMMARY AGGREGATION — Total stops and total ticket cost per tour
SELECT
    i.itinerary_id,
    i.itinerary_name,
    i.duration_days,
    COUNT(ip.place_id)          AS total_stops,
    SUM(p.entry_fee)            AS total_entry_fees,
    ROUND(AVG(p.rating), 2)     AS avg_destination_rating,
    SUM(ip.planned_stay_hours)  AS total_sightseeing_hours
FROM itineraries i
JOIN itinerary_places ip ON i.itinerary_id = ip.itinerary_id
JOIN tourist_places p    ON ip.place_id = p.place_id
GROUP BY i.itinerary_id, i.itinerary_name, i.duration_days
ORDER BY total_stops DESC;

-- BONUS: Verify full catalog view
SELECT * FROM vw_tourist_catalog;

-- BONUS: Verify category summary
SELECT * FROM vw_category_summary;

-- BONUS: Verify ranking config weights
SELECT * FROM ranking_config;

-- =======================================================================================
-- END OF MASTER SCRIPT
-- 6 Tables | 4 Views | 2 Triggers | 100 Places | 4 Itineraries Loaded
-- GitHub: https://github.com/shri030306/Mini-Project-Engine01-
-- Student: Shrilakshmi G.S | USN: 01FE24BCA314 | Engine 1 | Team 02
-- =======================================================================================
