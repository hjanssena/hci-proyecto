# UX Test Plan — Operability (ISO 25010)
### Continuous Education Management System — FCA

---

## 1. Why Operability is the Most Relevant Attribute for This Project

**Operability** is defined by ISO 25010 as *"the degree to which a product or system has attributes that make it easy to operate and control."*

This attribute is the most critical one for the FCA project for the following reasons:

- **Power user context, not casual users.** The sole target user is Ana Ramírez — an FCA Continuous Education Coordinator. She is not an occasional visitor; she operates the system daily to manage 15–20 simultaneous programs. Errors and friction don't just cause frustration — they directly delay official academic processes.
- **High-volume, repetitive administrative tasks.** The core workflows (creating events, querying lists, modifying records) are repeated constantly. Even small inefficiencies per action compound into significant operational costs over time.
- **Digital replacement of a manual process.** The system replaces manual tracking. If the digital tool is not more operable than the previous manual workflow, there is no adoption incentive. Operability is the primary competitive value proposition of the system.
- **No training budget assumed.** The requirement for a first-time task success rate ≥ 85% without training confirms the team's expectation that the interface must be self-evident to an administrative professional without onboarding.

---

## 2. Operability-Related Non-Functional Requirements

Three of the seven non-functional requirements map to **Operability**:

| ID | Requirement | Related Use Case | Key Verification Metric |
|---|---|---|---|
| **NFR-OP-1** | The system shall pre-fill ≥ 90% of fields when cloning an event, visually highlighting only mandatory variable fields. | CU-GE-001 | Clone task completed ≤ 2 min; ≥ 90% fields pre-filled |
| **NFR-OP-2** | "Search-as-you-type" across event and category lists for rapid record retrieval. | CU-GE-002, CU-GE-013 | Target record located in ≤ 30 s; results appear within 300 ms |
| **NFR-OP-3** | Standardized UI library for all CRUD operations — identical button placement, icons, and interaction patterns. | CU-GE-012, CU-GE-014, CU-GE-015 | ≥ 85% first-time task success rate; 100% CRUD screens share button position/icon |

---

## 3. Test Plan

### 3.1 Objectives

1. Validate that cloning an event reduces data entry effort to ≤ 2 minutes for a returning coordinator.
2. Validate that the search-as-you-type feature allows a coordinator to locate any record in ≤ 30 seconds.
3. Validate that a new coordinator can complete a CRUD task without training at a success rate ≥ 85%, demonstrating UI consistency.

### 3.2 Participants

- **Profile:** FCA administrative staff (Continuous Education coordinators) or individuals with equivalent administrative system experience.
- **Sample size:** 5 participants (minimum) per ISO/IEC 25066 recommendations for moderated usability testing; this also aligns with the metrics stated in the project's own NFRs.
- **Recruiting criteria:**
  - Familiarity with administrative software (e.g., Excel, ERP-style tools).
  - No prior exposure to the prototype being tested.
  - Age range matching the defined persona (professional adults, 25–55).

### 3.3 Facilitator Setup

- **Environment:** Controlled lab session or remote moderated session via screen sharing.
- **Tools:** Screen recording + audio capture (e.g., OBS / Lookback.io), a timer visible only to the facilitator, and a think-aloud protocol prompt sheet.
- **Data set pre-loaded in the prototype:**
  - ≥ 500 event records (required by NFR-OP-2 metric).
  - At least 1 previously archived event suitable for cloning (NFR-OP-1).
  - At least 3 active event categories (NFR-OP-3).
- **Facilitator role:** Observe silently; intervene only if the participant is blocked for > 3 minutes (mark as "task failure").

---

### 3.4 Scenarios and Tasks

---

#### **Scenario A — NFR-OP-1: Clone and Adapt an Existing Event**

> *Background given to participant:*
> "You need to schedule a new offering of the 'Diplomado en Gestión Empresarial' that was run last semester. Instead of creating it from scratch, use the system to clone the previous event and update only what has changed for the new edition."

| Step | Task Instruction | What the Facilitator Observes |
|---|---|---|
| A1 | "Find the previous edition of 'Diplomado en Gestión Empresarial' in the system." | Time to locate the event. |
| A2 | "Clone it to create a new edition." | Whether the user finds the clone action without guidance. |
| A3 | "Review the cloned form and update the start date to [given date] and assign a new instructor [given name]." | Which fields are pre-filled. Are mandatory fields visually distinguished? Does the user feel uncertain about any field? |
| A4 | "Save the new event." | Time to complete from A2 to A4. Think-aloud observations about field clarity. |

**Stop condition:** Task declared complete when participant saves the cloned event, or after 5 minutes (whichever comes first).

---

#### **Scenario B — NFR-OP-2: Locate a Record Using Search**

> *Background given to participant:*
> "A department director has asked you to check the details of an event called 'Taller de Liderazgo Organizacional' that took place earlier this year. Find it in the system."

| Step | Task Instruction | What the Facilitator Observes |
|---|---|---|
| B1 | "Navigate to the events list." | Can the user find the list without assistance? |
| B2 | "Use the search feature to find the event." | Does the user start typing without instruction? Does the search field update results in real time? Any hesitation? |
| B3 | "Open the event details." | Time elapsed from B1 to B3. Number of keystrokes before results narrow to target. |

**Repeat with a category search (CU-GE-013):**

> "Now locate the category called 'Curso de Actualización Fiscal' in the categories section."

Same observation structure as B1–B3.

**Stop condition:** Task declared complete when participant opens the record's detail view, or after 2 minutes (whichever comes first).

---

#### **Scenario C — NFR-OP-3: First-Time CRUD Tasks Across Modules (UI Consistency)**

> *Background given to participant:*
> "You have never used this system before. Complete the following tasks in sequence:"

| Step | Task Instruction | Module Tested |
|---|---|---|
| C1 | "Create a new event category called 'Seminario Internacional'." | CU-GE-012 |
| C2 | "Change the name of the category you just created to 'Seminario Empresarial Internacional'." | CU-GE-014 |
| C3 | "Archive the category 'Seminario Empresarial Internacional'." | CU-GE-015 |

**Observation focus:** After C1, the facilitator notes where the participant looks first to begin C2 (without being told). If they immediately locate the edit button in the same position as in the previous module, it confirms UI consistency. If they search around, it signals inconsistency.

**Stop condition:** Each sub-task declared complete on action confirmation, or after 3 minutes per step.

---

### 3.5 Type of Data Collected

#### Quantitative Data

| Data Point | NFR Addressed | Collection Method |
|---|---|---|
| **Task completion time** (seconds) | NFR-OP-1, NFR-OP-2 | Stopwatch / screen recording timestamp |
| **Task success rate** (binary: success / failure) | NFR-OP-1, NFR-OP-2, NFR-OP-3 | Facilitator log |
| **Number of pre-filled fields vs. total fields on clone form** | NFR-OP-1 | Post-task UI audit / form inspection |
| **Search result appearance latency** (ms per keystroke) | NFR-OP-2 | Browser DevTools (Network tab) / performance test |
| **Number of errors made per task** | NFR-OP-3 | Screen recording review |
| **Number of navigational wrong turns** (wrong clicks before reaching the target) | NFR-OP-3 | Screen recording review |

#### Qualitative Data

| Data Point | NFR Addressed | Collection Method |
|---|---|---|
| **Think-aloud comments** during clone flow | NFR-OP-1 | Audio recording + transcription |
| **Verbal expressions of confusion or confidence** | NFR-OP-2, NFR-OP-3 | Facilitator field notes |
| **Post-task satisfaction rating** (Single Ease Question, SEQ: 1–7 scale) | All | Short verbal/written rating |
| **Post-test semi-structured interview** (3–5 questions) | All | Audio recording |

Sample post-test interview questions:
1. "When you cloned the event, did it feel clear which fields you needed to change?"
2. "How did searching feel compared to how you normally look for records?"
3. "Did the buttons and menus feel consistent across the different sections?"
4. "Was there anything in the interface that surprised you or felt out of place?"

---

### 3.6 How the Data Would Be Analyzed

#### Quantitative Analysis

| Metric | Analysis Approach | Pass Threshold |
|---|---|---|
| Task completion time (clone) | Calculate mean and standard deviation across 5 participants. Flag if any participant exceeds 2 min. | Mean ≤ 2 min |
| Pre-fill rate | Count pre-filled fields / total fields on the cloned form. Verify highlighted mandatory fields programmatically. | ≥ 90% |
| Record location time (search) | Calculate mean time from opening list to opening record detail. | Mean ≤ 30 s |
| Search latency | Measured via browser DevTools during a functional test with 500+ records; not a user task measurement. | ≤ 300 ms per keystroke |
| First-time CRUD task success rate | (Successful task completions / Total task attempts) × 100 across all 5 participants for Scenario C. | ≥ 85% |
| Error rate | Errors per task; plotted per participant to find outliers and pain points. | Informs redesign priority |

Since the sample is small (n = 5), no inferential statistics are appropriate. The analysis is descriptive — means, frequencies, and pass/fail against the defined thresholds.

#### Qualitative Analysis

- **Affinity Mapping:** Think-aloud comments and interview responses are transcribed, coded with color-coded sticky notes (or a tool like Miro), and grouped into themes (e.g., "confusion about mandatory fields", "confident search usage").
- **Severity Rating:** Each usability issue identified from observations and comments is rated by severity (Critical / Major / Minor) using Nielsen's 0–4 scale. Issues that cause task failure are rated Critical.
- **SEQ Score Interpretation:** A mean SEQ score below 5 out of 7 for any task signals a meaningful operability problem that warrants investigation.
- **Cross-referencing:** Quantitative failures (task time exceeded, wrong clicks) are linked to corresponding qualitative comments to understand *why* a failure occurred, not just *that* it occurred.

---

### 3.7 Test Deliverables

1. **Session recording files** (screen + audio) per participant.
2. **Facilitator observation log** (tabular, per task per participant).
3. **Quantitative metrics summary table** — compared against NFR pass thresholds.
4. **Affinity map / issue log** — qualitative themes and severity ratings.
5. **Validation checklist** — each NFR-OP metric marked Pass / Fail / Partial with supporting evidence.
6. **Improvement recommendations** — prioritized list of UI changes if any thresholds are not met.

---

## 4. Summary of Relevance

| Why Operability | Evidence from This Project |
|---|---|
| The user is a daily power user, not an occasional visitor | Ana Ramírez manages 15–20 programs simultaneously — efficiency directly impacts her daily throughput |
| The system must justify replacing an existing manual workflow | If the digital tool is slower or harder to control than the previous method, it will be abandoned |
| No assumed training | NFR-OP-3 explicitly mandates ≥ 85% success for first-time users, confirming that self-evident operability is a design requirement, not a "nice to have" |
| High-volume repetitive actions | Clone, search, and CRUD operations are performed multiple times per day — even 30 seconds of friction per action becomes hours of lost productivity per month |
