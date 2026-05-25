# Usability Test Report
### Continuous Education Management System — FCA

---

## 1. Objective

Validate, through a moderated think-aloud test, whether the prototype meets its
Operability-focused usability requirements (ISO 25010) for an FCA Continuous
Education coordinator — a daily power user managing 15–20 simultaneous programs.

## 2. Methodology

- **Technique:** Moderated think-aloud test. Participants narrated their reasoning
  while completing tasks; the facilitator observed silently and intervened only
  after 3 minutes blocked.
- **Recording:** Screen + audio captured for post-session analysis. No SEQ survey
  and no post-test interview were run (see §3).
- **Why think-aloud:** with a small sample, qualitative signal (where users
  hesitate and why) is more useful than statistics.

## 3. Participants & Setup

- **Participants:** 2 testers, administrative-software users, no prior exposure to
  the prototype.
- **Instrumentation:** screen + audio recording and a facilitator observation log;
  prototype pre-loaded with sample events, categories, and a clonable past edition.


## 4. Scenarios and Requirement Mapping

| # | Scenario | Primary NFR (Attribute) | Also exercises |
|---|---|---|---|
| A | Clone & adapt an existing event | NFR-1 (Operability) | NFR-6 (User Error Protection) |
| B | Create a new event from scratch | NFR-5 (User Error Protection) | NFR-1 (Operability) baseline, NFR-7 (Operability) |
| C | First-time CRUD on categories | NFR-7 (Operability) | NFR-5 (User Error Protection) |


## 5. Results Summary

| Scenario | NFR (Attribute) | Metric | Threshold | P1 | P2 | Verdict |
|---|---|---|---|---|---|---|
| A | NFR-1 (Operability) | Clone deviations (wrong turns) | ≤ 2 | 9 *(7:25+)* | 3 *(5:14)* | **Both Fail** |
| B | NFR-1 (Operability) | Create-from-scratch deviations | ≤ 2 | 2 *(15:10)* | 1 *(8:51)* | **Both Pass** |
| B | NFR-7 (Operability) | Field-entry errors | descriptive | 3 | 1 | — |
| C | NFR-7 (Operability) | Category CRUD sub-task success | ≥ 85% | 3/3 | 3/3 | **Pass (100%, 6/6)** |
| All | NFR-5/6/7 | Navigational wrong turns (A/B/C) | descriptive | 9 / 2 / 1 | 3 / 2 / 2 | — |
| All | NFR-7 (Operability) | Think-aloud confusion (count) | qualitative | 7 | 3 | — |

**Pass rule for NFR-1 is navigation deviations** (≤ 2 wrong turns), not completion
time; time is reported for context only. Scenario A fails on both participants
(9 and 3 deviations); Scenario B passes on both (2 and 1 deviations).

## 6. Key Findings

**What worked**
- Visual design (color, contrast, modern feel) guided users effectively.
- Sidebar navigation behaved as intended.
- Only one functional defect surfaced during the entire test.
- Category CRUD (Scenario C) passed cleanly for both participants.

**Friction points**
- **Clone discoverability (NFR-1):** the clone action was expected on the event
  *detail* page, not in the dashboard header; users confused **Clone** with
  **Edit**. This drove the high Scenario A deviation counts.
- **Event-creation form layout (NFR-1 / NFR-7):** adding schedule and instructor
  details was not intuitive; the EPC-points and contract fields felt detached from
  the rest of the form; no way to repeat weekly time slots made scheduling slow.
- **Lack of save/edit feedback (NFR-7):** after editing a category, users were
  unsure whether changes were saved or discarded — compounded when an active
  filter hid the affected row.
- **Filtering:** single-filter behavior and the volume of information on the home
  screen left users slightly disoriented.
- **Layout inconsistency** between some screens (notably Scenario B) added
  confusion; users fell back on search/filter when information was unclear.

**Terminology surprises (think-aloud)**
- **"Archive"** reads as *save/store* to administrative users, not *temporarily remove* — a meaning mismatch that created doubt about the function.
- **"Price"** would read better as **"Cost"** in this academic context.
- Users wanted to choose the **event type first**, before seeing the full list.
- Prices should be formatted (e.g., `$1,000.00 MXN`) in both input and display.
- The **TimePicker** reduced entry errors but raised the learning curve for some.
- A real data gap: discrepancies between **instructor hours and course hours** were
  not validated by the system.

## 8. Recommendations

**High priority (address before the next prototype version)**
1. Make **Clone** reachable from the event detail page and visually distinct from
   **Edit** *(NFR-1)*.
2. Redesign the **create-event form**: surface schedule/instructor entry, group
   EPC/contract fields coherently, and add repeatable weekly time slots
   *(NFR-1, NFR-7)*.
3. Add explicit **save/discard confirmation feedback** on category and event edits
   *(NFR-7)*.
4. Reconsider terminology: rename **"Archive"** and **"Price"** to match user
   vocabulary *(NFR-5 / Recognizability)*.

**Medium priority**
5. Enable **multiple simultaneous filters** and an **event-type pre-filter** before
   the full list loads.
6. Format monetary values consistently across input and display.
7. Resolve **layout inconsistencies** across management screens *(NFR-7)*.
8. Validate **instructor-hours vs. course-hours** consistency.

**Process / next round**
9. Expand to 5 participants and restore the **search scenario (NFR-4)**, SEQ, and a
   post-test interview.
10. Tighten the usability-test plan: missing instructions caused steps to be
    skipped and contributed to participant confusion.
