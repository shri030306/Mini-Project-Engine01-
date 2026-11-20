-- =======================================================================================
-- [INCREMENTAL PATCH SCRIPT ONLY - DAY 2 SCHEMA EVOLUTION]
-- =======================================================================================
-- NOTICE FOR ENGINE 2 (C++) & BACKEND DEVELOPERS:
-- If you are setting up the system from scratch, DO NOT run this file!
-- Run 'database_queries.sql' instead, which contains the complete, unified 34-place schema.
-- This file is solely for demonstrating incremental Day 2 schema evolution (ALTER TABLE,
-- audit triggers, and places 13-22) on top of an existing Day 1 database.
-- =======================================================================================

USE tourist_db1;

-- Add state and description columns
ALTER TABLE tourist_places 
ADD COLUMN IF NOT EXISTS state VARCHAR(50) NOT NULL DEFAULT 'Karnataka';

ALTER TABLE tourist_places 
ADD COLUMN IF NOT EXISTS description TEXT;

-- Verify schema changes
DESCRIBE tourist_places;
