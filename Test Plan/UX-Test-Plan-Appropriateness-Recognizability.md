# UX Test Plan — Appropriateness Recognizability (ISO 25010)
### Continuous Education Management System — FCA

---

## 1. Why Appropriateness Recognizability is the Most Relevant Attribute for This Project

**Appropriateness Recognizability** is defined by ISO 25010 as *"the degree to which users can recognize whether a product or system is appropriate for their needs,"* specifically whether users can correctly interpret the meaning of UI elements — such as status indicators, color codes, and icons — without external explanation.

This attribute is critical for the FCA project for the following reasons:

- **Status-driven workflow management.** Ana Ramírez's daily work revolves around monitoring the status of events, enrollments, and payments. If she cannot immediately recognize what state a record is in from its visual representation, she must open every record individually — multiplying her workload significantly.
- **Multi-status domain complexity.** The system exposes at least three distinct status domains (event statuses, enrollment statuses, payment statuses), each with multiple states. If color-coded badges are not immediately recognizable, coordinators risk misinterpreting a record's state, leading to incorrect administrative decisions (e.g., approving an enrollment that should be rejected).
- **No time for interpretation under workload.** Managing 15–20 simultaneous programs means Ana is constantly scanning lists, not reading details. She needs to decode a badge's meaning in 5 seconds or fewer — the precise metric defined by NFR-AR-1.
- **Accessibility intersection.** Color-coded indicators only work if they meet WCAG 2.1 AA contrast standards (≥4.5:1). Failing this not only violates accessibility norms but makes the status indicators unreadable in adverse display conditions, negating the recognizability gain entirely.

---

## 2. Appropriateness Recognizability-Related Non-Functional Requirements

One of the seven non-functional requirements maps to **Appropriateness Recognizability**:

| ID | Requirement | Related Use Case | Key Verification Metric |
|---|---|---|---|
| **NFR-AR-1** | Color-coded status badges shall allow ≥ 90% of participants to correctly identify the record status within 5 seconds, without guidance; all badge label–background color pairs must meet WCAG 2.1 AA contrast ratio (≥ 4.5:1). | CU-GE-002, CU-GE-009, CU-GE-010 | ≥ 90% correct identification in ≤ 5 s; ≥ 4.5:1 contrast ratio on all badges |

---

## 3. Test Plan

### 3.1 Objectives

1. Validate that ≥ 90% of participants correctly identify each record status from its color-coded badge within 5 seconds, without any verbal guidance.
2. Validate that all badge label–background color pairs pass the WCAG 2.1 AA contrast ratio requirement of ≥ 4.5:1.
3. Identify which specific status badges (if any) cause confusion, misidentification, or require more than 5 seconds — and provide actionable redesign priorities.

### 3.2 Participants

- **Profile:** FCA administrative staff (Continuous Education coordinators) or individuals with equivalent administrative system experience.
- **Sample size:** 5 participants (minimum) per ISO/IEC 25066 recommendations for moderated usability testing; this also aligns with the metrics stated in the project's own NFRs.
- **Recruiting criteria:**
  - Familiarity with administrative software (e.g., Excel, ERP-style tools).
  - No prior exposure to the prototype being tested.
  - Age range matching the defined persona (professional adults, 25–55).
  - Normal color vision, or documented color vision deficiency (to test inclusivity of the badge design).

### 3.3 Facilitator Setup

- **Environment:** Controlled lab session or remote moderated session via screen sharing.
- **Display:** 1920×1080 monitor, Google Chrome (latest stable), window maximized, no zoom — required to replicate the production display context.
- **Tools:** Screen recording + audio capture (e.g., OBS / Lookback.io), a per-badge stopwatch visible only to the facilitator, and a think-aloud protocol prompt sheet.
- **Data set pre-loaded in the prototype:**
  - ≥ 15 enrollment records spread across all statuses: Pendiente de Revisión (blue), Aprobada (green), Rechazada (red), Información Requerida (orange/amber).
  - ≥ 5 payment records spread across all statuses: Pendiente de Verificación de Pago (blue), Confirmada (green), Pago Rechazado (red).
  - Event records in all statuses: En fase de inscripciones (blue), Confirmado (green), Cancelado (red) — with at least one cancelled event displaying a cancellation reason tooltip.
- **Facilitator role:** Observe silently; use a stopwatch per badge identification. Do not explain badge meanings under any circumstance. Intervene only if the participant is blocked for > 3 minutes (mark as "task failure").
- **Facilitator-only contrast measurement:** Before the session, use a contrast checker tool (e.g., WebAIM Contrast Checker) to document the contrast ratio of each badge label color against its background color. This measurement is independent of participant tasks.

---

### 3.4 Scenarios and Tasks

---

#### **Scenario C — NFR-AR-1: Status Badge Identification**

> *Background given to participant:*
> "Voy a mostrarle diferentes pantallas del sistema. Para cada registro que señale, dígame rápidamente en qué estado se encuentra y cómo lo supo."

---

##### **Part 1 — Enrollment Statuses (CU-GE-009)**

The facilitator navigates to the Enrollments list and points to individual records in sequence. The participant must name the status without touching the system.

| Sub-step | Facilitator Action | Correct Answer | Time Limit | What the Facilitator Observes |
|---|---|---|---|---|
| C1 | Point to an enrollment with status "Pendiente de Revisión" (blue badge). | "Pendiente de Revisión" | 5 seconds | Does the participant answer immediately or hesitate? Do they look at the badge text or badge color first? |
| C2 | Point to an enrollment with status "Aprobada" (green badge). | "Aprobada" | 5 seconds | Is the green badge unambiguously positive? Does the participant express confidence? |
| C3 | Point to an enrollment with status "Rechazada" (red badge). | "Rechazada" | 5 seconds | Does the participant distinguish red from orange? Any hesitation between C3 and C4? |
| C4 | Point to an enrollment with status "Información Requerida" (orange/amber badge). | "Información Requerida" or equivalent (e.g., "requiere información", "pendiente de datos") | 5 seconds | Is the amber badge semantically distinct from the blue "Pendiente" badge? Does the participant express any confusion between them? |

---

##### **Part 2 — Payment Statuses (CU-GE-010)**

The facilitator navigates to the Payments list and points to individual records.

| Sub-step | Facilitator Action | Correct Answer | Time Limit | What the Facilitator Observes |
|---|---|---|---|---|
| C5 | Point to a payment with status "Pendiente de Verificación de Pago" (blue badge). | "Pendiente" or "Pendiente de Verificación" | 5 seconds | Does the blue badge carry over its meaning from Part 1? Is there cross-domain consistency? |
| C6 | Point to a payment with status "Confirmada" (green badge). | "Confirmada" | 5 seconds | Does the participant connect "Confirmada" (payments) with "Aprobada" (enrollments) semantically? |
| C7 | Point to a payment with status "Pago Rechazado" (red badge). | "Rechazado" or "Pago Rechazado" | 5 seconds | Does red consistently signal a rejected or failed state across domains? Any ambiguity? |

---

##### **Part 3 — Event Statuses (CU-GE-002)**

The facilitator navigates to the Events list.

| Sub-step | Facilitator Action | Correct Answer | Time Limit | What the Facilitator Observes |
|---|---|---|---|---|
| C8 | Point to an event with status "En fase de inscripciones" (blue badge). | "En fase de inscripciones" or "Inscripciones" | 5 seconds | Does the participant interpret blue as "active / in progress" consistently across all three domains? |
| C9 | Point to an event with status "Confirmado" (green badge). | "Confirmado" | 5 seconds | Confidence and response speed. |
| C10 | Point to a cancelled event (red badge) that has a cancellation reason tooltip. Ask: "¿Ve algo adicional aquí?" | Identifies the tooltip / additional icon indicating a cancellation reason exists | 10 seconds | Does the participant notice the secondary indicator (tooltip icon)? Do they attempt to hover over it? Does the extra affordance feel discoverable? |

**Post-task question (ask immediately after C10):**
- "¿Los colores le ayudaron a distinguir los estados? ¿Hubo alguno que le generó confusión?"

---

**Stop condition for each sub-step:** Sub-step declared complete when the participant names the status or 5 seconds (10 seconds for C10) elapse, whichever comes first. If time elapses without a correct answer, log as "failed."

---

### 3.5 Type of Data Collected

#### Quantitative Data

| Data Point | NFR Addressed | Collection Method |
|---|---|---|
| **Status identification accuracy** (correct / incorrect per sub-step) | NFR-AR-1 | Facilitator log per sub-step C1–C10 |
| **Status identification speed** (seconds per sub-step) | NFR-AR-1 | Stopwatch per sub-step, started when facilitator points to badge |
| **Badge color contrast ratio** (label text vs. badge background, per badge) | NFR-AR-1 | WebAIM Contrast Checker — facilitator-only measurement before or after session |
| **Number of sub-steps where participant expressed verbal uncertainty** | NFR-AR-1 | Facilitator field notes (coded as "U = uncertainty") |

#### Qualitative Data

| Data Point | NFR Addressed | Collection Method |
|---|---|---|
| **Think-aloud comments** during badge identification | NFR-AR-1 | Audio recording + transcription |
| **Verbal expressions of confusion or confidence** per badge | NFR-AR-1 | Facilitator field notes (shorthand: C = confusion, S = satisfaction) |
| **Cross-domain color meaning transfer** — does the participant apply learned meanings from Part 1 to Parts 2 and 3? | NFR-AR-1 | Facilitator observation narrative |
| **Post-task rating** (Single Ease Question, SEQ: 1–7 scale) | NFR-AR-1 | Short verbal rating: "En una escala del 1 al 7, ¿qué tan fácil le pareció identificar el estado de los registros?" |
| **Post-test semi-structured interview** (relevant questions) | NFR-AR-1 | Audio recording |

Sample post-test interview questions:
1. "¿Los colores de los estados le parecieron intuitivos? ¿Hubo alguno que no supo interpretar de inmediato?"
2. "¿Sintió que los colores significaban lo mismo en las secciones de inscripciones, pagos y eventos?"
3. "¿Notó el ícono adicional en el evento cancelado? ¿Le resultó claro qué indicaba?"
4. "¿Hay algún color o etiqueta que cambiaría para que fuera más fácil de entender?"

---

### 3.6 How the Data Would Be Analyzed

#### Quantitative Analysis

| Metric | Analysis Approach | Pass Threshold |
|---|---|---|
| Status identification accuracy | (Correct identifications / Total sub-steps) × 100, computed across all 5 participants × 10 sub-steps (50 total observations). | ≥ 90% correct (≥ 45 out of 50) |
| Per-badge accuracy | Accuracy computed per individual badge (C1–C10) to pinpoint which specific states cause failure. Any single badge below 80% accuracy flags a critical design issue regardless of overall score. | ≥ 80% per badge (≥ 4 out of 5 participants) |
| Status identification speed | Mean time per sub-step across 5 participants. Flag any sub-step where ≥ 2 participants exceed 5 seconds (signals a systemic recognition problem with that specific badge). | Mean ≤ 5 s per sub-step |
| Badge color contrast ratio | Pass / fail per badge against WCAG 2.1 AA ≥ 4.5:1. Any failing badge is a blocker regardless of user task results. | ≥ 4.5:1 on all badges |

Since the sample is small (n = 5), no inferential statistics are appropriate. The analysis is descriptive — accuracy rates, mean times, and pass/fail against the defined thresholds.

#### Qualitative Analysis

- **Affinity Mapping:** Think-aloud comments and interview responses are transcribed, coded by badge identity (e.g., "blue enrollment badge", "orange badge"), and grouped into themes (e.g., "blue badge color ambiguous between pending enrollment and pending payment", "tooltip on cancelled event not noticed by most users").
- **Severity Rating:** Each usability issue identified from observations and comments is rated by severity (Critical / Major / Minor) using Nielsen's 0–4 scale. A badge that causes task failure (no correct identification within time limit) is rated Critical.
- **SEQ Score Interpretation:** A mean SEQ score below 5 out of 7 signals that the badge system as a whole is not sufficiently recognizable and warrants redesign.
- **Cross-referencing:** Failed sub-steps (time exceeded or incorrect answer) are linked to corresponding think-aloud comments and post-test interview responses to understand *why* a badge was not recognized — e.g., whether the issue is the color choice, the label text, or the contrast level.
- **Color blindness cross-check:** If any participant discloses color vision deficiency, their results are analyzed separately to confirm whether the badge design is inclusive (relying on both color and label text, not color alone).

---

### 3.7 Test Deliverables

1. **Session recording files** (screen + audio) per participant.
2. **Facilitator observation log** (tabular, per sub-step C1–C10, per participant) — including time elapsed and correct/incorrect classification.
3. **Quantitative metrics summary table** — overall accuracy rate, per-badge accuracy, mean identification time, compared against NFR-AR-1 pass thresholds.
4. **Color contrast audit report** — WebAIM results for each badge (label text color, background color, contrast ratio, WCAG AA pass/fail).
5. **Affinity map / issue log** — qualitative themes per badge, with severity ratings.
6. **Validation checklist** — NFR-AR-1 metrics marked Pass / Fail / Partial with supporting evidence.
7. **Improvement recommendations** — prioritized list of badge redesign changes if any thresholds are not met, specifying which badge, what the problem is, and a suggested color or contrast correction.

---

## 4. Summary of Relevance

| Why Appropriateness Recognizability | Evidence from This Project |
|---|---|
| The user scans lists, not individual records | Ana Ramírez manages 15–20 simultaneous programs — she must decode a status in 5 seconds or fewer while reviewing dozens of records, making instant badge recognition a functional necessity |
| Multi-domain status complexity | Three separate domains (events, enrollments, payments) each carry their own status vocabulary; cross-domain color consistency is required so that learned meanings transfer automatically |
| Misidentification has direct administrative consequences | Misreading a badge could lead to approving an enrollment that should be rejected, or failing to act on a cancelled event — errors with real-world academic and financial impact |
| WCAG compliance is a baseline requirement | If badge colors fail the 4.5:1 contrast ratio, the entire visual-status system becomes inaccessible under sub-optimal display conditions, and the recognizability gain is lost entirely |
