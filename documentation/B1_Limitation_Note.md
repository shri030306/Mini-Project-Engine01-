# B1 – Identified Project Limitation Note

## Project
Tourist Place Search and Ranking System (Engine 1: Data & Integrity)  
**Student:** Shrilakshmi G.S (USN: `01FE24BCA314`)  
**Theme:** Theme 2 — Search and Ranking System  

---

## 1. What Currently Cannot Be Proved
In existing travel platforms, static databases, and travel blogs, the system **cannot prove historical entry fee revisions, prior rating records, or administrator update accountability**. 

When a tourist destination's entrance ticket fee is modified (e.g. from ₹50 to ₹75 during peak holiday seasons) or visitor ratings are updated, the standard database overwrites the existing row, permanently destroying the prior record.

---

## 2. Why This Cannot Be Proved
1. **Destructive Updates:** Standard SQL `UPDATE` operations replace old attribute values with new values without archiving.
2. **Missing Actor Tracking:** Basic tables do not capture `CURRENT_USER()` or session identity during update executions.
3. **No Immutable Ledger:** Without a dedicated Audit Trail Register and automated database triggers, administrators cannot verify whether a pricing discrepancy reported at the ticket counter was an authorized change or an unauthorized data entry mistake.

---

## 3. How the Limitation Is Addressed in Our MIS System
1. **Automated Audit Register:** An immutable `tourist_places_audit_log` table tracks every insert, update, and status change.
2. **Automated Database Triggers:** `trg_audit_insert` and `trg_audit_update` automatically record:
   - `place_id`: Destination affected
   - `action_type`: `INSERT_RECORD`, `UPDATE_ENTRY_FEE`, `UPDATE_RATING`, `STATUS_CHANGE`
   - `old_entry_fee` vs `new_entry_fee`: Exact financial delta
   - `old_rating` vs `new_rating`: Exact rating revision
   - `performed_by`: System user who authorized the transaction
   - `performed_at`: Precise timestamp of operation
3. **MIS Executive Views:** Reporting views provide historical summaries and variance tracking for tourism department administrators.

---

## 4. Evidence
- **Gate 0 Evidence:** Step 9 in `gate_0_database.sql` demonstrates the unprovable overwrite problem where updating Jog Falls fee from ₹50.00 to ₹75.00 leaves no audit trace.
- **Gate 1 Evidence:** Sections 4, 5, and 8 in `database_queries.sql` demonstrate the automated trigger audit register resolving this limitation permanently.

