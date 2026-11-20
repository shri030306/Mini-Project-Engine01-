# KLE TECHNOLOGICAL UNIVERSITY, HUBBALLI
## DEPARTMENT OF BACHELOR OF COMPUTER APPLICATIONS
### THEME 4: REPORTING AND MIS SYSTEM / RULES CHECK RECORDS REGISTER
### GATE 0: PROBLEM APPROVAL EVALUATION EVIDENCE (5 MARKS)
**Stage:** S0 | **Division:** E | **Team:** Team 02 | **Date:** November 2026  
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

## 2. Gate 0 Rubric Evaluation Matrix (5 Marks)

| Criterion | Rubric Requirement | CO | Student (Y/P/N) | Evidence Description & Document Mapping | Faculty (Y/P/N) | Marks (Max 1.0) |
| :---: | :--- | :---: | :---: | :--- | :---: | :---: |
| **A1** | **Problem statement with stakeholders named (who is affected, and how)** | CO1 | **Y** | **Stakeholders Identified:**<br>1. *Tourists/Travelers:* Struggle with scattered web information, unverified entrance fees, and biased reviews.<br>2. *Tourism Department / Administrators:* Lack a centralized, auditable register of places, fees, and operational status.<br>3. *Travel Planners/Curators:* Lack multi-factor ranked recommendations.<br>*Location:* Synopsis Sec 1.1 & SRS Sec 1.2. | **Y** | **1.0** |
| **A2** | **AS-IS workflow and TO-BE workflow drawn** | CO1 | **Y** | **AS-IS:** Manual search -> Unverified fees/ratings -> Subjective choice -> Untraceable travel plan.<br>**TO-BE:** Filter inputs (category, budget, distance) -> Engine 1 relational retrieval -> Engine 2 composite scoring -> Engine 3 ranked card display with MIS analytics.<br>*Location:* Synopsis Sec 3.2 & SRS Sec 2.3. | **Y** | **1.0** |
| **A3** | **Scope and out-of-scope list; feasibility and risk note** | CO1 | **Y** | **In Scope:** 34 Karnataka destinations, 6 categories, multi-factor ranking, audit trail triggers, MIS reporting views.<br>**Out of Scope:** Direct hotel booking, live GPS turn-by-turn navigation, real-time ticket payment gateway.<br>**Feasibility & Risk:** High technical feasibility using MySQL InnoDB + C++/Node; risk of seasonal fee staleness mitigated by administrative update triggers.<br>*Location:* Synopsis Sec 2.1 & SRS Sec 1.3. | **Y** | **1.0** |
| **A4** | **Integration Map v1 — which of the five course areas will appear, and where** | CO1 | **Y** | **5 Course Areas Integrated:**<br>1. *Data Structures & Algorithms (C++):* Max-heap priority queue and composite ranking in Engine 2.<br>2. *DBMS (MySQL):* Relational schema, CHECK rules, audit log table & triggers, MIS views in Engine 1.<br>3. *Web Technologies:* HTML5/CSS3/JS REST UI in Engine 3.<br>4. *Software Engineering:* Traceability matrix, acceptance criteria in Engine 4.<br>5. *Systems Programming:* Process IPC, file I/O, memory safety.<br>*Location:* Synopsis Sec 3.1 & Integration Map v1. | **Y** | **1.0** |
| **B1** | **THEME-SPECIFIC: What currently cannot be proved is named — a disputed balance, a mismatch, or an item nobody can trace** | CO1 | **Y** | **Unprovable Mismatch in AS-IS System:**<br>In traditional travel platforms, **destination entry fee revisions and rating updates have ZERO audit history**. When fees are changed (e.g., peak seasonal hikes) or ratings are updated, administrators cannot prove who made the change, when it was authorized, or what the prior value was. This creates untraceable discrepancies between online listings and on-ground ticket counters.<br>**Engine 1 Solution:** An automated **Audit Log Register** (`tourist_places_audit_log`) triggered on every INSERT and UPDATE capturing `performed_by`, `performed_at`, `old_value`, and `new_value`.<br>*Location:* Synopsis Sec 1.3 & `database_queries.sql` Sec 4 & 5. | **Y** | **1.0** |
| **TOTAL** | **Gate 0 Evaluation Total** | | | | | **5.0 / 5.0** |

---

## 3. Mandatory Gate 0 Review Statements

### Student’s Own Statement — The One Thing We Know is Weakest in This Gate
> *"The weakest point in our Gate 0 formulation was defining a standardized origin baseline for tourist distance calculations across Karnataka. In Gate 1, we resolved this by establishing Hubballi (KLE Tech campus) as the central regional reference coordinate with bounded distance scaling (0 to 500 km)."*

### Faculty Question Asked at Decision Level, and the Answer Given
- **Question:** *"Why does a Tourist Place Search and Ranking system belong under Theme 4 (Reporting and MIS System), and what specific unprovable mismatch does it solve?"*
- **Answer:** *"It belongs under Theme 4 because it acts as an administrative Records Register and Decision-Support MIS. In traditional travel blogs, fee revisions and ranking weights are ad-hoc and untraceable; our MIS system enforces non-violable data rules (preventing negative fees and duplicate records) and maintains an automated audit log registering every operational transaction with historical old-vs-new tracking."*

### One Sentence the Team Must Act on Before the Next Gate
> *"The team must freeze the relational database schema, specify measurable NFRs with acceptance criteria, and implement the audit trigger register in Engine 1 before presenting Gate 1."*

### Gate Decision
**Status:** **CLEARED** (5.0 / 5.0)  
**Student Sign:** Shrilakshmi G.S (`01FE24BCA314`)  
**Mentor Sign:** Prof. Pavankumar Vadavi / Prof. Sayeeda Anjum

