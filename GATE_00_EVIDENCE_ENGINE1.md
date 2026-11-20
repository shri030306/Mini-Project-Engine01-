# KLE TECHNOLOGICAL UNIVERSITY, HUBBALLI
## DEPARTMENT OF BACHELOR OF COMPUTER APPLICATIONS
### THEME 4: REPORTING AND MIS SYSTEM / RULES CHECK RECORDS REGISTER
### GATE 0: PROBLEM APPROVAL EVALUATION EVIDENCE (5 MARKS)
**Stage:** S0 | **Division:** E | **Team:** Team 02 | **Date:** 20-11-2026  
**Project Title:** Tourist Place Search and Ranking System  
**Engine 1 (Data & Integrity):** Shrilakshmi G.S (USN: `01FE24BCA314`)  
**Faculty Mentors:** Prof. Pavankumar Vadavi, Prof. Sayeeda Anjum  
**Repository:** [https://github.com/shri030306/Mini-Project-Engine01-](https://github.com/shri030306/Mini-Project-Engine01-)

---

## 1. Team & Engine Architecture Mapping

| Engine | Technical Focus Area | Team Member | USN | Core Deliverable |
| :--- | :--- | :--- | :--- | :--- |
| **Engine 1** | **Data & Integrity** | **Shrilakshmi G.S** | **01FE24BCA314** | **MySQL relational schema, CHECK constraints, audit triggers, 22+ Karnataka records, MIS views** |
| Engine 2 | Logic & Algorithms | Vivek B M | 01FE24BCA266 | C++ multi-criteria ranking algorithm, heap sort, scoring pipeline |
| Engine 3 | Interface & Web | Gouri K | 01FE24BCA312 | Web UI, responsive filter controls, REST client presentation |
| Engine 4 | Testing & SDLC | Team 02 | — | Requirements traceability matrix (RTM), acceptance testing suite |

---

## 2. Gate 0 Rubric Evaluation Matrix (Theme 4: Reporting and MIS System)

| # | Evidence to be produced | CO | Student Y/P/N | Student — where the evidence is (GitHub Repository Links & Artifacts) |
| :-: | :--- | :-: | :-: | :--- |
| **A1** | **Problem statement with stakeholders named (who is affected, and how)** | CO1 | **Y** | • [Project Synopsis](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/Team02_Tourist_Place_Search_and_Ranking_System_Synopsis%20(1).docx) – Problem Statement & Stakeholder Analysis (Tourists, Tourism Dept, Curators)<br>• [gate_0_database.sql](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/gate_0_database.sql) – SQL schema, non-violable constraints, prototype destinations<br>• [DATABASE_TESTING_REPORT.md](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/documentation/DATABASE_TESTING_REPORT.md) – Constraint verification test suite<br>• [GATE_00_EVIDENCE_ENGINE1.md](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/GATE_00_EVIDENCE_ENGINE1.md) – Gate 0 evidence summary |
| **A2** | **AS-IS workflow and TO-BE workflow drawn** | CO1 | **Y** | • [diagrams Folder](https://github.com/shri030306/Mini-Project-Engine01-/tree/main/diagrams) – Workflow architecture directory<br>• [AS_IS_Workflow.md](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/diagrams/AS_IS_Workflow.md) – Existing manual search process and unverified pain points<br>• [TO_BE_Workflow.md](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/diagrams/TO_BE_Workflow.md) – Proposed MIS automated multi-criteria ranking workflow |
| **A3** | **Scope and out-of-scope list; feasibility and risk note** | CO1 | **Y** | • [Project SRS](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/Team02_Tourist_place_search_and%20_ranking_SRS.docx) – Scope, Out-of-Scope boundaries, feasibility matrix and risk assessment<br>• [Project Synopsis](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/Team02_Tourist_Place_Search_and_Ranking_System_Synopsis%20(1).docx) – High-level project charter<br>• [documentation Folder](https://github.com/shri030306/Mini-Project-Engine01-/tree/main/documentation) – Engineering specification and testing notes<br>• [gate_0_database.sql](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/gate_0_database.sql) – Database implementation |
| **A4** | **Integration Map v1 — which of the five course areas will appear, and where** | CO1 | **Y** | • [Requirement Analysis](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/Team02_Tourist_Place_Search_and_Ranking_System_Requirement_Analysis%20(1).docx) – Section 4: Foundational Course Mapping<br>• [DATABASE_DOCUMENTATION.md](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/documentation/DATABASE_DOCUMENTATION.md) – Architectural integration of DBMS, Data Structures/Algorithms (C++), Web Technologies, and Software Engineering |
| **B1** | **THEME-SPECIFIC: What currently cannot be proved is named — a disputed balance, a mismatch, or an item nobody can trace** | CO1 | **Y** | • [B1_Limitation_Note.md](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/documentation/B1_Limitation_Note.md) – **Identified Limitation:** In traditional travel platforms, destination entry fee revisions and visitor ratings have zero audit history; when fees change during peak seasons, administrators cannot prove prior authorized fees or who changed them, creating untraceable pricing disputes at ticket counters.<br>• [gate_0_database.sql (Step 9)](https://github.com/shri030306/Mini-Project-Engine01-/blob/main/gate_0_database.sql#L115-L140) – Step 9 Gate 0 Theme 4 unprovable dispute demonstration transaction |

---

## 3. Mandatory Gate 0 Review Statements

### Student’s Own Statement — The One Thing We Know is Weakest in This Gate
> *"The weakest part of our project formulation is that frontend and backend integration and distance origin normalization are still pending. In Gate 1, we anchor reference distances to Hubballi (KLE Tech campus), connect Engine 1 with Engine 2, and verify full end-to-end ranking functionality."*

### Faculty Question Asked at Decision Level, and the Answer Given
- **Question:** *"Why does a Tourist Place Search and Ranking system belong under Theme 4 (Reporting and MIS System), and what specific unprovable mismatch does it solve?"*
- **Answer:** *"It belongs under Theme 4 because it acts as an administrative Records Register and Decision-Support MIS. In traditional travel blogs and unverified websites, fee revisions and visitor ratings are ad-hoc and untraceable; our MIS system enforces non-violable data rules (preventing negative fees and duplicate records) and maintains an automated audit log registering every operational transaction with historical old-vs-new tracking."*

### One Sentence the Team Must Act on Before the Next Gate
> *"Complete the relational schema lock with Engine 2, implement automated audit triggers in database_queries.sql, and test all integrity constraints using valid and invalid test cases before presenting Gate 1."*

### Gate Decision
- **Status:** **CLEARED** (5.0 / 5.0)  
- **Student Sign:** Shrilakshmi G.S (`01FE24BCA314`)  
- **Mentor Sign:** Prof. Pavankumar Vadavi / Prof. Sayeeda Anjum
