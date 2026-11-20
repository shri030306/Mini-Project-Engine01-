# Database Testing Report – Tourist Place Search and Ranking System

**Date:** 17 November 2026  
**Database:** `tourist_db1`  
**Engine 1:** Data and Integrity  
**Student:** Shrilakshmi G.S (USN: `01FE24BCA314`)  
**DBMS:** MySQL InnoDB (utf8mb4)  
**Environment:** MySQL Workbench 8.0 / MySQL Server  

---

## 1. Testing Scope

The database was tested for table creation, primary keys, foreign key cascading, unique constraints, check constraints, audit trail triggers, schema evolution (`ALTER TABLE`), and data integrity rejection under invalid input.

---

## 2. Integrity Constraint & Negative Rejection Testing

| Test Case | Description | Query / Action | Expected Result | Actual Result | Status |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **TC-01** | Primary Key Uniqueness | Duplicate insert with existing `place_id` | Error: Duplicate entry | Error 1062 (Duplicate entry) | **PASS** |
| **TC-02** | City Duplicate Check | Insert same `(place_name, city)` twice | Error: Duplicate entry for key `uq_place_city` | Error 1062 | **PASS** |
| **TC-03** | Negative Entry Fee Check | `entry_fee = -50.00` | Error: Check constraint `chk_entry_fee` violated | Error 3819 (Check constraint violated) | **PASS** |
| **TC-04** | Invalid Rating Upper Bound | `rating = 6.00` | Error: Check constraint `chk_rating` violated | Error 3819 | **PASS** |
| **TC-05** | Invalid Rating Lower Bound | `rating = -1.00` | Error: Check constraint `chk_rating` violated | Error 3819 | **PASS** |
| **TC-06** | Negative Distance Check | `distance_km = -25.0` | Error: Check constraint `chk_distance` violated | Error 3819 | **PASS** |
| **TC-07** | Orphan Record Rejection | Insert with `category_id = 999` | Error: Cannot add or update a child row (FK fails) | Error 1452 (Foreign key constraint fails) | **PASS** |
| **TC-08** | Orphan Deletion Rejection | Delete referenced category with active places | Error: Cannot delete or update a parent row | Error 1451 (Cannot delete or update a parent row) | **PASS** |
| **TC-09** | Empty Name Rejection | `place_name = ''` | Error: Check constraint violated | Error 3819 | **PASS** |
| **TC-10** | Invalid Status Check | `status = 'DELETED'` | Error: Check constraint `chk_status` violated | Error 3819 | **PASS** |

---

## 3. Trigger & Audit Trail Testing

| Test Case | Description | Expected Result | Actual Result | Status |
| :---: | :--- | :--- | :--- | :---: |
| **TRG-01** | `trg_audit_insert` | New row created in `tourist_places_audit_log` with `action_type = 'INSERT_RECORD'` and timestamp | Audit row created with `CURRENT_USER()` | **PASS** |
| **TRG-02** | `trg_audit_update` (Fee) | Update entry fee: logs `old_entry_fee` and `new_entry_fee` with `action_type = 'UPDATE_ENTRY_FEE'` | Old and new fee captured with exact delta | **PASS** |
| **TRG-03** | `trg_audit_update` (Rating) | Update rating: logs `old_rating` and `new_rating` | Old and new rating captured | **PASS** |
| **TRG-04** | `trg_audit_update` (Status) | Deactivate place: logs `old_status = 'ACTIVE'`, `new_status = 'INACTIVE'` | Status change audit row recorded | **PASS** |

---

## 4. Conclusion

All 10 integrity constraints and 4 trigger audit operations successfully passed verification, confirming full compliance with Theme 2 database requirements.

