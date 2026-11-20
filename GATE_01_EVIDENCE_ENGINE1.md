# KLE TECHNOLOGICAL UNIVERSITY, HUBBALLI
## DEPARTMENT OF BACHELOR OF COMPUTER APPLICATIONS
### THEME 4: REPORTING AND MIS SYSTEM / RULES CHECK RECORDS REGISTER
### GATE 1: REQUIREMENTS BASELINE EVALUATION EVIDENCE (10 MARKS)
**Stage:** S1 | **Division:** E | **Team:** Team 02 | **Date:** November 2026  
**Project Title:** Tourist Place Search and Ranking System  
**Engine 1 (Data & Integrity):** Shrilakshmi G.S (USN: `01FE24BCA314`)  
**Faculty Mentors:** Prof. Pavankumar Vadavi, Prof. Sayeeda Anjum  
**Repository:** [https://github.com/shri030306/Mini-Project-Engine01-](https://github.com/shri030306/Mini-Project-Engine01-)

---

## 1. Team & Engine Architecture Mapping

| Engine | Technical Focus Area | Team Member | USN | Core Deliverable |
| :--- | :--- | :--- | :--- | :--- |
| **Engine 1** | **Data & Integrity** | **Shrilakshmi G.S** | **01FE24BCA314** | **MySQL relational schema, CHECK constraints, audit triggers, 34 Karnataka records, MIS views** |
| Engine 2 | Logic & Algorithms | Vivek B M | 01FE24BCA266 | C++ multi-criteria ranking algorithm, heap sort, scoring pipeline |
| Engine 3 | Interface & Web | Gouri K | 01FE24BCA312 | Web UI, responsive filter controls, REST client presentation |
| Engine 4 | Testing & SDLC | Team 02 | — | Requirements traceability matrix (RTM), acceptance testing suite |

---

## 2. Gate 1 Rubric Evaluation Matrix (10 Marks)

| Criterion | Rubric Requirement | CO | Student (Y/P/N) | Evidence Description & Document Mapping | Faculty (Y/P/N) | Marks (Max) |
| :---: | :--- | :---: | :---: | :--- | :---: | :---: |
| **A1** | **Functional requirements with IDs (FR-01, FR-02 …)** | CO2 | **Y** | **FR-01 to FR-09 Defined:** FR-01 Search & Multi-filter, FR-02 Score Computation, FR-03 Category Browsing, FR-04 Detailed Card View, FR-05 Distance Radius, FR-06 Sorting Modes, FR-07 Dynamic Threshold, FR-08 Database Consistency Register, FR-09 Audit Trail Logging. Location: SRS Sec 3.2. | **Y** | **1.0** (1.0) |
| **A2** | **Non-functional requirements stated and measurable** | CO2 | **Y** | **NFR-01 to NFR-04 Measurable:** Latency < 100ms for 34 places, < 250ms under 50 concurrent queries (NFR-01); 99.9% uptime, zero silent database transaction drops (NFR-02); SQL injection defense via parameterized queries (NFR-03); ANSI SQL / InnoDB engine (NFR-04). Location: SRS Sec 3.3. | **Y** | **1.0** (1.0) |
| **A3** | **Acceptance criterion written for every key FR** | CO2 | **Y** | **Given-When-Then Format (AC-01 to AC-09):** E.g., AC-01: GIVEN valid budget/category, WHEN user submits filter, THEN results display matching spots sorted by composite score within 100ms. Location: SRS Sec 3.2. | **Y** | **1.0** (1.0) |
| **A4** | **Use cases or user stories for each stakeholder role** | CO2 | **Y** | **5 Use Cases:** UC-01 Filter & Discover Destinations, UC-02 Destination Inspection, UC-03 Distance Radius Search, UC-04 Administrative Fee & Rating Update, UC-05 Audit Trail Log Inspection. Location: SRS Sec 3.1. | **Y** | **1.0** (1.0) |
| **A5** | **Traceability: every FR traced back to a stakeholder need** | CO2 | **Y** | **Requirements Traceability Matrix (RTM):** SN-01 (Reliable discovery) -> FR-01/03/04 -> UC-01/02; SN-02 (Budget & distance adherence) -> FR-01/05 -> UC-03; SN-03 (Auditable records & data integrity) -> FR-08/09 -> UC-04/05 -> database_queries.sql. Location: SRS Sec 4.0. | **Y** | **1.5** (1.5) |
| **B1** | **THEME-SPECIFIC: Every transaction type listed with its effect on the balance / records** | CO2 | **Y** | **5 Transaction Types:**<br>1. `INSERT_RECORD`: Creates destination record and initializes audit history.<br>2. `UPDATE_ENTRY_FEE`: Revises entry fee, logs old vs new value.<br>3. `UPDATE_RATING`: Modifies rating score and increments popularity.<br>4. `STATUS_DEACTIVATE`: Soft delete, removes from active view without data loss.<br>5. `STATUS_REACTIVATE`: Restores destination to active search.<br>Location: `database_queries.sql` Sec 8. | **Y** | **1.5** (1.5) |
| **B2** | **THEME-SPECIFIC: The rules that must never be violated stated — negative balance, duplicate posting, orphan transaction** | CO2 | **Y** | **Non-Violable Rules:**<br>1. *No Negative Values:* `chk_entry_fee >= 0`, `chk_distance >= 0`, `chk_rating BETWEEN 0 AND 5`, `chk_popularity >= 0`.<br>2. *No Duplicate Postings:* `UNIQUE(place_name, city)`.<br>3. *No Orphan Records:* `fk_places_category ON DELETE RESTRICT`.<br>4. *Positive Strings:* `CHECK(CHAR_LENGTH(TRIM(place_name)) > 0)`.<br>Negative rejection tests provided in `database_queries.sql` Sec 10. | **Y** | **1.5** (1.5) |
| **B3** | **THEME-SPECIFIC: Acceptance criterion written for the audit trail — what every posting must record** | CO2 | **Y** | **Audit Trail Register:** `tourist_places_audit_log` records `audit_id`, `place_id`, `action_type`, `old_entry_fee`, `new_entry_fee`, `old_rating`, `new_rating`, `old_status`, `new_status`, `performed_by` (`CURRENT_USER()`), and `performed_at`. Automated database triggers `trg_audit_insert` and `trg_audit_update` guarantee audit entry even if admin UI is bypassed. Location: `database_queries.sql` Sec 4 & 5. | **Y** | **1.5** (1.5) |
| **TOTAL** | **Gate 1 Evaluation Total** | | | | | **10.0 / 10.0** |

---

## 3. Mandatory Gate 1 Review Statements

### Student’s Own Statement — The One Thing We Know is Weakest in This Gate
> *"Our weakest requirement was that the system originally tracked ratings as a static number between 0 and 5 without an audit history of how seasonal demand or user reviews modify that value over time. We hardened this in Gate 1 by creating a dedicated Audit Log register (`tourist_places_audit_log`) and triggers that record every single rating update, fee revision, and timestamp."*

### Faculty Question Asked at Decision Level, and the Answer Given
- **Question:** *"How does your database register ensure non-violable rules (Rubric B2) and audit logging (Rubric B3)?"*
- **Answer:** *"In Theme 4, our non-violable rules are enforced at the database engine level using InnoDB CHECK constraints and Foreign Keys: entry fees and distances can never be negative (`CHECK >= 0`), ratings are bounded between 0 and 5.0, and places cannot be duplicated within the same city (`UNIQUE(place_name, city)`). Furthermore, automated database triggers capture every INSERT and UPDATE into an immutable audit register recording who executed the operation, the exact timestamp, and both old and new values."*

### One Sentence the Team Must Act on Before the Next Gate
> *"Freeze and lock the relational schema with Engine 2 (Vivek's C++ / JS API layer), ensuring the 34-place dataset passes through parameterized queries without any impedance mismatch before we benchmark indexing performance."*

### Gate Decision
**Status:** **CLEARED** (10.0 / 10.0)  
**Student Sign:** Shrilakshmi G.S (`01FE24BCA314`)  
**Mentor Sign:** Prof. Pavankumar Vadavi / Prof. Sayeeda Anjum

