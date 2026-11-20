# SHEETS FOR THEME 2 / THEME 2 — SEARCH AND RANKING SYSTEM
## Gate 1 — Requirements Baseline (10 marks) | Stage: S1

| Division | E | Team No. | 02 | Date | 20-11-2026 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Project title** | **Tourist Place Search and Ranking System** |
| **Member 1** | Shrilakshmi (01fe24bca314) | **Member 2** | — | **Member 3** | — | **Member 4** | — |
| **Engine 1** | Data and Integrity | **Engine 2** | — | **Engine 3** | — | **Engine 4** | — |
| **Faculty mentor** | Prof. Pavan Vadavi, Prof. Sayeda Anjum |

---

### Evidence Verification Matrix

| # | Evidence to be produced | CO | Student Y / P / N | Student — where the evidence is | Faculty Y / P / N | Marks | Max |
| :-: | :--- | :-: | :-: | :--- | :-: | :-: | :-: |
| **A1** | **Functional requirements with IDs (FR-01, FR-02 …)** | CO2 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/blob/main/Team02_Tourist_place_search_and%20_ranking_SRS.docx<br>• Formally defines 9 functional requirements (FR-01 to FR-09) with unique IDs covering multi-filter search, composite scoring, and radius filtering.<br>• Specifies core Engine 1 functional requirements including FR-08 (Database Integrity & Constraints) and FR-09 (Automated Audit Trail Logging). | | | **1.0** |
| **A2** | **Non-functional requirements stated and measurable** | CO2 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/blob/main/Team02_Tourist_place_search_and%20_ranking_SRS.docx<br>• Establishes measurable latency metrics: query response under 100ms for 34 places and under 250ms under 50 concurrent searches (NFR-01).<br>• Enforces 99.9% uptime with zero silent database drops (NFR-02) and strict SQL injection defense via parameterized queries (NFR-03). | | | **1.0** |
| **A3** | **Acceptance criterion written for every key FR** | CO2 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/blob/main/Team02_Tourist_place_search_and%20_ranking_SRS.docx<br>• Formulates testable Given-When-Then acceptance criteria (AC-01 to AC-09) mapped to all functional requirements.<br>• Verifies that AC-08 rejects negative/invalid fees and ratings at the database level and AC-09 enforces automated audit logging on all mutations. | | | **1.0** |
| **A4** | **Use cases or user stories for each stakeholder role** | CO2 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/blob/main/Team02_Tourist_place_search_and%20_ranking_SRS.docx<br>• Details 5 core use cases (UC-01 to UC-05) covering traveler destination discovery, budget/distance filtering, and administrative place management.<br>• Specifies administrative use cases UC-04 (Fee & Rating Updates) and UC-05 (Audit Trail Inspection) demonstrating full MIS governance. | | | **1.0** |
| **A5** | **Traceability: every FR traced back to a stakeholder need** | CO2 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/blob/main/Team02_Tourist_place_search_and%20_ranking_SRS.docx<br>• Provides a Requirements Traceability Matrix (RTM) linking traveler needs (SN-01, SN-02) to search and ranking requirements (FR-01 to FR-05).<br>• Traces administrator governance needs (SN-03) directly to database integrity constraints and audit registers in `database_queries.sql`. | | | **1.5** |
| **B1** | **THEME-SPECIFIC: Every transaction type listed with its effect on the balance** | CO2 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/blob/main/database_queries.sql<br>• Categorizes 5 distinct operational transaction types: `INSERT_RECORD`, `UPDATE_ENTRY_FEE`, `UPDATE_RATING`, `STATUS_DEACTIVATE`, and `STATUS_REACTIVATE`.<br>• Documents the exact database effect for each transaction, recording prior and new values into the `tourist_places_audit_log` register. | | | **1.5** |
| **B2** | **THEME-SPECIFIC: The rules that must never be violated stated — negative balance, duplicate posting, orphan transaction** | CO2 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/blob/main/database_queries.sql<br>• Enforces non-violable database rules: `CHECK (entry_fee >= 0)`, `CHECK (distance_km >= 0)`, `CHECK (rating BETWEEN 1 AND 5)`, and `CHECK (popularity BETWEEN 0 AND 100)`.<br>• Prevents duplicate postings via `UNIQUE (place_name, city)` and rejects orphan transactions via foreign key constraint referencing `categories1(category_id)`. | | | **1.5** |
| **B3** | **THEME-SPECIFIC: Acceptance criterion written for the audit trail — what every posting must record** | CO2 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/blob/main/database_queries.sql<br>• Defines acceptance criteria for `tourist_places_audit_log` requiring capture of `audit_id`, `place_id`, `action_type`, `old_value`, `new_value`, `performed_by`, and `performed_at`.<br>• Implements automated database triggers (`trg_audit_insert`, `trg_audit_update`) guaranteeing immutable audit capture even if application-level UI is bypassed. | | | **1.5** |
| | **TOTAL** | | | | | | **10.0** |

---

### Review Statements

| Item | Details |
| :--- | :--- |
| **Student’s own statement — the one thing we know is weakest in this gate** | Our weakest requirement was that destination ratings originally lacked historical audit tracking when seasonal user reviews shifted. In Gate 1, we hardened this by creating an automated audit register (`tourist_places_audit_log`) and triggers capturing every rating and fee modification. |
| **Faculty question asked at Decision level, and the answer given** | |
| **One sentence the team must act on before the next gate** | Freeze and lock the relational schema with Engine 2 (C++ ranking engine), ensuring the 34-place dataset passes through parameterized queries without any impedance mismatch before benchmarking indexing performance. |
| **GATE DECISION** | **CLEARED** &nbsp;&nbsp;/&nbsp;&nbsp; **HELD** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Student sign:** Shrilakshmi G.S &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Mentor sign:** ____________________ |
