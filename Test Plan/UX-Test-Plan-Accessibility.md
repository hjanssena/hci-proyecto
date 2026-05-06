# UX Test Plan — Accessibility (ISO 25010)
### Continuous Education Management System — FCA

---

## 1. Why Accessibility is the Most Relevant Attribute for This Project

**Accessibility** is defined by ISO 25010 as *"the degree to which a product or system can be used by people with the widest range of characteristics and capabilities to achieve a specified goal in a specified context of use."*

While Operability addresses how efficiently a power user performs tasks, Accessibility addresses whether the interface can be used effectively by any qualified person assigned to that role — regardless of individual differences in visual acuity, display configuration, or information density preference. For the FCA project, this attribute matters for the following reasons:

- **Dense information environment.** The coordinator manages 15–20 simultaneous programs. The core interface is a record-dense administrative table. If the system requires constant scrolling to read even a partial record list, it breaks the cognitive flow of a coordinator who needs to scan many rows at once to make decisions.
- **Institutional context with standardized workstations.** FCA administrative offices operate on institutional computers, typically running 1920×1080 displays. The system must be optimized for the actual hardware environment, not an idealized high-DPI display. A tabular design that wastes vertical space forces unnecessary scrolling on the target hardware.
- **Readability as a prerequisite to all other tasks.** Before a coordinator can clone an event (NFR-OP-1), search for a record (NFR-OP-2), or perform any CRUD operation (NFR-OP-3), they must be able to read the list. Accessibility in this system is not a supplement to usability — it is its foundation.
- **No zoom or font-size adjustments assumed.** The non-functional requirement explicitly defines the test condition as "default browser settings," confirming the team's expectation that the interface must be accessible without any user-initiated accommodation.

---

## 2. Accessibility-Related Non-Functional Requirements

One of the seven non-functional requirements maps to **Accessibility**:

| ID | Requirement | Related Use Case | Key Verification Metric |
|---|---|---|---|
| **NFR-AC-1** | At 1920×1080 resolution and default browser settings, the tabular design shall display ≥ 10 event records simultaneously without vertical scrolling. | CU-GE-002 | ≥ 10 DataRows visible in the viewport at 1080p without scrolling; row height 36–42 px |

---

## 3. Test Plan

### 3.1 Objectives

1. Validate that the events list view displays at least 10 records simultaneously at 1920×1080 without requiring the user to scroll vertically.
2. Validate that the text within each visible row is legible at default browser zoom (100%) without assistive adjustment.
3. Confirm that the table header, navigation elements, and filters do not consume so much vertical space that they reduce the visible record count below the threshold.

### 3.2 Participants

- **Profile:** FCA administrative staff (Continuous Education coordinators) or individuals with equivalent administrative system experience.
- **Sample size:** 5 participants (minimum) per ISO/IEC 25066 recommendations for moderated usability testing; this also aligns with the metrics stated in the project's own NFRs.
- **Recruiting criteria:**
  - Familiarity with administrative software (e.g., Excel, ERP-style tools).
  - No prior exposure to the prototype being tested.
  - Age range matching the defined persona (professional adults, 25–55).
  - Normal or corrected-to-normal vision; no assistive zoom or large-text OS settings active during the session.

### 3.3 Facilitator Setup

- **Environment:** Controlled lab session or remote moderated session with screen sharing on a 1920×1080 display.
- **Display requirement:** The test monitor must be confirmed at 1920×1080 resolution before each session. OS display scaling must be set to 100%. Browser window must be maximized with no zoom applied (Ctrl+0 to reset).
- **Tools:** Screen recording + audio capture (e.g., OBS / Lookback.io), a timer visible only to the facilitator, a think-aloud protocol prompt sheet, and a contrast checker tool (e.g., WebAIM Contrast Checker).
- **Data set pre-loaded in the prototype:**
  - ≥ 500 event records (to ensure the list is populated beyond the visible threshold — NFR-AC-1).
  - Records must include a variety of names and statuses to represent typical real-world density.
- **Facilitator role:** Observe silently; intervene only if the participant is blocked for > 3 minutes (mark as "task failure"). For the facilitator-only measurements (row count, row height), perform them independently after the participant has completed the task — do not involve the participant.

---

### 3.4 Scenarios and Tasks

---

#### **Scenario B — NFR-AC-1: Visible Record Density**

> *Background given to participant:*
> "Abra la lista de eventos y dígame cuántos eventos puede ver en la pantalla sin necesidad de hacer scroll."

| Step | Task Instruction | What the Facilitator Observes |
|---|---|---|
| B1 | "Navegue a la sección de Eventos." | Confirms the participant is on the event list view. Notes whether they find the section without assistance. |
| B2 | "Cuente cuántos eventos ve visibles ahora mismo sin desplazarse hacia abajo." | Participant counts visible rows aloud. Facilitator independently counts DataRows (excluding header) visible in the viewport. |
| B3 | "¿Puede leer cómodamente el texto en cada fila?" | Participant gives a subjective readability rating (1–7). Facilitator notes whether they lean in, squint, or express any strain. |

**Facilitator-only measurements (do NOT tell participant):**
- Take a screenshot of the viewport at 1920×1080 immediately after step B2.
- Count visible DataRows (excluding the header row and any filter/toolbar rows).
- Measure row height in pixels using browser DevTools (right-click a row → Inspect → Box Model). Target: 36–42 px per row.
- Document how many pixels the table header, navigation sidebar, top bar, and filter bar consume in total. This identifies whether chrome elements are the cause if the row count falls below 10.

**Stop condition:** Scenario declared complete once B3 is answered and facilitator screenshot is captured.

---

#### **Extended Verification — Facilitator-Only Technical Audit**

This step is performed by the facilitator after all participant sessions, not during participant observation:

| Check | Method | Pass Threshold |
|---|---|---|
| Visible DataRows at 1920×1080 | Screenshot + manual row count | ≥ 10 rows |
| Row height | Browser DevTools → Box Model on a `<tr>` element | 36–42 px |
| Total non-table vertical chrome | Sum of: top navigation bar + sidebar header + table toolbar + column header row (in pixels) | ≤ available viewport − (10 × 42 px) |
| Text contrast of row content | WebAIM Contrast Checker on row text vs. row background | ≥ 4.5:1 (WCAG 2.1 AA) |
| Horizontal overflow | Resize browser to 1920 px wide; confirm no horizontal scrollbar appears and no column text truncates critically | No overflow |

---

### 3.5 Type of Data Collected

#### Quantitative Data

| Data Point | NFR Addressed | Collection Method |
|---|---|---|
| **Participant-reported visible row count** | NFR-AC-1 | Think-aloud count during step B2 |
| **Facilitator-measured visible DataRow count** | NFR-AC-1 | Viewport screenshot + manual count |
| **Row height in pixels** | NFR-AC-1 | Browser DevTools (Box Model) |
| **Vertical chrome consumption** (px) | NFR-AC-1 | DevTools measurement of non-table UI elements |
| **Text contrast ratio** (row content vs. background) | NFR-AC-1 | WebAIM Contrast Checker |
| **Participant readability rating** (1–7 Likert scale) | NFR-AC-1 | Verbal rating at step B3 |

#### Qualitative Data

| Data Point | NFR Addressed | Collection Method |
|---|---|---|
| **Think-aloud comments** while scanning the list | NFR-AC-1 | Audio recording + transcription |
| **Verbal or behavioral signs of readability difficulty** | NFR-AC-1 | Facilitator field notes (e.g., participant leans toward screen, squints, mentions text is small) |
| **Post-task satisfaction rating** (Single Ease Question, SEQ: 1–7 scale) | NFR-AC-1 | Verbal rating after completing scenario |
| **Post-test semi-structured interview** (selected questions) | NFR-AC-1 | Audio recording |

Sample post-test interview questions:
1. "Al ver la lista de eventos, ¿sintió que podía ver suficientes registros a la vez sin necesidad de desplazarse?"
2. "¿El texto en las filas le resultó fácil de leer o tuvo que esforzarse para distinguir la información?"
3. "¿Hay elementos en la pantalla (barras, encabezados, filtros) que sienta que ocupan demasiado espacio y le impiden ver más registros?"
4. "¿Cómo compara la densidad de información de esta pantalla con otras herramientas administrativas que usa?"

---

### 3.6 How the Data Would Be Analyzed

#### Quantitative Analysis

| Metric | Analysis Approach | Pass Threshold |
|---|---|---|
| Visible DataRow count | Compare facilitator-measured count against threshold. If any participant session yields fewer than 10, inspect DevTools measurements to diagnose root cause (oversized chrome, excessive row height, etc.). | ≥ 10 rows |
| Row height | Compare measured row height (px) against the design specification. Flag if rows exceed 42 px or fall below 36 px. | 36–42 px |
| Text contrast ratio | Record pass/fail per element audited with WebAIM. | ≥ 4.5:1 |
| Participant readability rating | Calculate mean and range across 5 participants. | Mean ≥ 5 / 7 |

Since the sample is small (n = 5), no inferential statistics are appropriate. The analysis is descriptive — means, frequencies, and pass/fail against the defined thresholds.

The facilitator-measured row count is the authoritative metric for NFR-AC-1 compliance. The participant-reported count serves as corroborating evidence, not the primary measurement, since participants may miscount or include partially visible rows.

#### Qualitative Analysis

- **Affinity Mapping:** Think-aloud comments and interview responses are transcribed, coded with color-coded sticky notes (or a tool like Miro), and grouped into themes (e.g., "text too small at default zoom", "scrolling felt necessary", "adequate density for the task").
- **Severity Rating:** Each accessibility issue identified from observations and comments is rated by severity (Critical / Major / Minor) using Nielsen's 0–4 scale. A row count below 10 confirmed by the screenshot audit is rated Critical, as it directly violates the NFR.
- **SEQ Score Interpretation:** A mean SEQ score below 5 out of 7 for the scenario signals a meaningful accessibility problem that warrants investigation.
- **Cross-referencing:** If the facilitator-measured row count fails the threshold, the DevTools measurement of chrome consumption is used to determine whether the fix is a UI layout issue (e.g., reduce top bar height) or a table row height issue.

---

### 3.7 Test Deliverables

1. **Session recording files** (screen + audio) per participant.
2. **Facilitator observation log** (tabular, per task per participant).
3. **Viewport screenshot** at 1920×1080 with annotated row count — one per session.
4. **DevTools measurement report** — row height, chrome consumption, and any overflow findings.
5. **Contrast audit report** — WebAIM results for row text and badge elements.
6. **Quantitative metrics summary table** — compared against NFR-AC-1 pass thresholds.
7. **Affinity map / issue log** — qualitative themes and severity ratings.
8. **Validation checklist** — NFR-AC-1 metric marked Pass / Fail / Partial with supporting evidence.
9. **Improvement recommendations** — prioritized list of layout changes if any thresholds are not met.

---

## 4. Summary of Relevance

| Why Accessibility | Evidence from This Project |
|---|---|
| The interface is a record-dense administrative table viewed on institutional 1080p monitors | The primary data surface is a list of 15–20 simultaneous programs — the coordinator must scan rows, not read one record at a time |
| Scrolling to view a partial list breaks the coordinator's decision-making flow | If fewer than 10 rows are visible, the coordinator cannot compare records side-by-side in a single glance, slowing every list-based task |
| Default browser settings are the explicitly required test condition | NFR-AC-1 mandates compliance without any user-initiated accommodation, confirming that accessibility must be built into the design — not delegated to the user |
| Accessibility is the prerequisite to all other usability attributes | The coordinator cannot clone, search, or manage records efficiently if the list itself is not readable and sufficiently dense at the target resolution |
