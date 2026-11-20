
# SHEETS FOR THEME 2 — SEARCH AND RANKING SYSTEM
## Gate 0 — Problem Approval (5 marks) | Stage: S0

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
| **A1** | **Problem statement with stakeholders named (who is affected, and how)** | CO1 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/blob/main/Team02_Tourist_Place_Search_and_Ranking_System_Synopsis%20(1).docx<br>• Identifies three core stakeholders: travelers struggling with fragmented information, travel curators needing objective rankings, and tourism administrators lacking centralized registers.<br>• Formulates the core problem statement addressing unverified entrance fees, unstandardized ratings, and lack of distance transparency from regional origins. | | | **1.0** |
| **A2** | **AS-IS workflow and TO-BE workflow drawn** | CO1 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/tree/main/diagrams<br>• AS-IS workflow illustrates the current manual, fragmented search process leading to unverified fee discrepancies and untraceable travel decisions.<br>• TO-BE workflow defines the proposed automated MIS architecture where user preferences trigger database filtering, C++ ranking logic, and verified UI display. | | | **1.0** |
| **A3** | **Scope and out-of-scope list; feasibility and risk note** | CO1 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/blob/main/Team02_Tourist_place_search_and%20_ranking_SRS.docx<br>• Explicitly scopes 34 verified Karnataka destinations across 6 categories while setting direct hotel booking and live turn-by-turn navigation out of scope.<br>• Documents technical feasibility using MySQL InnoDB with relational integrity constraints and provides a risk analysis on seasonal fee volatility. | | | **1.0** |
| **A4** | **Integration Map v1 — which of the five course areas will appear, and where** | CO1 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/blob/main/Team02_Tourist_Place_Search_and_Ranking_System_Requirement_Analysis%20(1).docx<br>• Maps 5 foundational course areas across engines: DBMS (Engine 1 data integrity), DSA (Engine 2 heap sorting & ranking), and Web Technologies (Engine 3 UI).<br>• Establishes Software Engineering SDLC traceability and Systems Programming IPC data exchange between database and ranking modules. | | | **1.0** |
| **B1** | **THEME-SPECIFIC EVIDENCE: What currently cannot be proved is named — a disputed balance, a mismatch, or an item nobody can trace** | CO1 | **Y** | **Repository:** https://github.com/shri030306/Mini-Project-Engine01-/blob/main/documentation/B1_Limitation_Note.md<br>• Identifies the unprovable flaw where traditional travel blogs revise entry fees and ratings without any audit logging, creating ticket-counter pricing disputes.<br>• Demonstrates in `gate_0_database.sql` (Step 9) how updates without an audit trail leave administrators unable to trace who changed a fee or prove prior rates. | | | **1.0** |
| | **TOTAL** | | | | | | **5.0** |

---

### Review Statements

| Item | Details |
| :--- | :--- |
| **Student’s own statement — the one thing we know is weakest in this gate** | The weakest part of our project in Gate 0 is that distance calculations lacked a standardized geographic origin. In Gate 1, we anchor all destination distances to Hubballi (KLE Tech campus) as the central regional origin coordinate. |
| **Faculty question asked at Decision level, and the answer given** | |
| **One sentence the team must act on before the next gate** | Complete the relational schema lock with Engine 2, implement automated audit triggers in database_queries.sql, and test all integrity constraints using valid and invalid test cases before presenting Gate 1. |
| **GATE DECISION** | **CLEARED** &nbsp;&nbsp;/&nbsp;&nbsp; **HELD** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Student sign:** Shrilakshmi G.S &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Mentor sign:** ____________________ |
