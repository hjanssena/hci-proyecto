# UX Test Plan — User Error Protection (ISO 25010)
### Continuous Education Management System — FCA

---

## 1. Why User Error Protection is the Most Relevant Attribute for This Project

**User Error Protection** is defined by ISO 25010 as *"the degree to which a system protects users against making errors,"* covering both the system's ability to prevent errors before they are submitted and its ability to help users recover from errors through clear, actionable feedback.

This attribute is critical for the FCA project for the following reasons:

- **Administrative data has zero-error tolerance.** Enrollment approvals, payment confirmations, and event records feed into official academic processes. An invalid date range saved in an event, or an enrollment approved for an already-full program, has direct downstream consequences — affecting students, instructors, and financial records that cannot be casually undone.
- **No dedicated support channel assumed.** Ana Ramírez operates without a helpdesk for the system she uses daily. If an error message does not clearly explain what went wrong and how to fix it, she has no fallback other than trial-and-error — adding friction and risk to every form interaction.
- **High-frequency form use compounds error risk.** Creating events, managing enrollments, and processing payments all involve multi-field forms completed repeatedly throughout the day. Even a modest error rate per form interaction becomes a significant operational burden when multiplied across dozens of submissions per week.
- **Two complementary protection layers are required.** NFR-UEP-1 focuses on *recovery* — ensuring that when a business rule is violated, the plain-language error message is clear enough for ≥ 80% of users to self-correct without help. NFR-UEP-2 focuses on *prevention* — ensuring inline field validation catches structural errors (invalid values, missing required fields) before they ever reach the server, with zero invalid form submissions getting through.

---

## 2. User Error Protection-Related Non-Functional Requirements

Two of the seven non-functional requirements map to **User Error Protection**:

| ID | Requirement | Related Use Case | Key Verification Metric |
|---|---|---|---|
| **NFR-UEP-1** | Plain-language error messages shall enable ≥ 80% of users to self-correct after a business rule violation, without external help. | CU-GE-001, CU-GE-006, CU-GE-007, CU-GE-009, CU-GE-010 | ≥ 80% self-correction rate across all error scenarios |
| **NFR-UEP-2** | Inline field-level validation shall trigger within 500 ms of focus-out and prevent 100% of invalid form submissions. | CU-GE-001, CU-GE-009 | ≤ 500 ms validation response time; 0% invalid form submission rate |

---

## 3. Test Plan

### 3.1 Objectives

1. Validate that plain-language error messages allow ≥ 80% of participants to self-correct after triggering a business rule error, without facilitator guidance.
2. Validate that inline field validation appears within 500 ms of a user leaving an invalid field (focus-out), providing immediate feedback before form submission.
3. Validate that 0% of invalid form states can be successfully submitted — confirming that server-side logic and client-side validation together constitute a complete error prevention layer.

### 3.2 Participants

- **Profile:** FCA administrative staff (Continuous Education coordinators) or individuals with equivalent administrative system experience.
- **Sample size:** 5 participants (minimum) per ISO/IEC 25066 recommendations for moderated usability testing; this also aligns with the metrics stated in the project's own NFRs.
- **Recruiting criteria:**
  - Familiarity with administrative software (e.g., Excel, ERP-style tools).
  - No prior exposure to the prototype being tested.
  - Age range matching the defined persona (professional adults, 25–55).

### 3.3 Facilitator Setup

- **Environment:** Controlled lab session or remote moderated session via screen sharing.
- **Tools:** Screen recording + audio capture (e.g., OBS / Lookback.io), a stopwatch visible only to the facilitator, and a think-aloud protocol prompt sheet.
- **Data set pre-loaded in the prototype:**
  - ≥ 1 event with active enrollments (required to trigger the active-enrollment archive business rule in NFR-UEP-1, Scenario E).
  - ≥ 1 event at maximum enrollment capacity (required to trigger the capacity error in NFR-UEP-1, Scenario E).
  - ≥ 1 category currently assigned to active events (required to trigger the category-in-use business rule in NFR-UEP-1, Scenario E).
  - At least 3 enrollment records in a state that allows approval attempts.
  - At least 1 payment record with status "Confirmada" (to trigger the duplicate confirmation error in NFR-UEP-1, Scenario E).
- **Facilitator role:** Observe silently. Do not interpret error messages for the participant under any circumstance — doing so would invalidate the NFR-UEP-1 self-correction metric. Intervene only if the participant is completely blocked for > 3 minutes (mark as "task failure"). For Scenario F (NFR-UEP-2), additionally open Browser DevTools (Network tab) to measure API response timing for inline validation.

---

### 3.4 Scenarios and Tasks

---

#### **Scenario E — NFR-UEP-1: Plain-Language Error Recovery**

> *Background given to participant:*
> "Va a realizar algunas operaciones en el sistema. Si aparece algún mensaje de error, léalo en voz alta e intente resolverlo por su cuenta."

The facilitator observes whether the participant reads the error message, correctly interprets it, and takes the corrective action on their own — without asking the facilitator for clarification.

---

##### **Part 1 — Business Rule Errors**

| Sub-step | Task Instruction | Expected System Response | What the Facilitator Observes |
|---|---|---|---|
| E1 | "Intente archivar un evento que tenga inscripciones activas." | Message confirming the event has been cancelled (not archived) and users will be notified — *or* a message explaining the constraint. | Does the participant read the message aloud? Do they understand what happened to the event's status? Do they express surprise or confidence? |
| E2 | "Intente archivar una categoría que esté siendo utilizada por eventos activos." | "La categoría está siendo utilizada por uno o más eventos activos. Reasigne los eventos antes de archivarla." | Does the participant understand the constraint? Do they attempt to reasign events as the message instructs, or do they give up? |
| E3 | "Intente aprobar una inscripción para un evento que ya está en su capacidad máxima." | "El evento ha alcanzado su límite de cupo y no permite la aprobación." | Does the participant understand the capacity limit? Do they attempt to find a workaround (e.g., increasing capacity) or accept the block? |

---

##### **Part 2 — Form Validation Errors**

| Sub-step | Task Instruction | Expected System Response | What the Facilitator Observes |
|---|---|---|---|
| E4 | "Intente crear un evento nuevo con la fecha de fin anterior a la fecha de inicio." (Set start date to Dec 20, 2026 and end date to Dec 1, 2026.) | "La fecha de fin no puede ser anterior a la de inicio." | Does the participant notice the inline error before trying to save? Do they correct the dates without help? |
| E5 | "En el mismo formulario, ponga una cantidad mínima de inscripciones mayor que la capacidad máxima (ej: capacidad 10, mínimo 50) e intente guardar." | "No puede exceder la capacidad." | Does the participant understand the relationship between these two fields? Can they correct both fields independently? |
| E6 | "Intente confirmar un pago que ya esté confirmado." | "El pago ya está confirmado." | Does the participant understand they are attempting a duplicate action? Do they navigate away without further confusion? |

---

**Scoring per sub-step (logged by facilitator):**

| Outcome | Definition |
|---|---|
| **Self-corrected** | Participant read the message and fixed the issue without asking for help or external clarification. |
| **Needed hint** | Participant asked "what does this mean?" or looked at the facilitator for guidance before correcting. |
| **Gave up** | Participant abandoned the task or required explicit instruction to proceed. |

**Target:** ≥ 80% self-correction rate across all error encounters — i.e., ≥ 24 out of 30 total sub-step evaluations (5 participants × 6 sub-steps).

**Stop condition per sub-step:** Sub-step declared complete when the participant corrects the error or abandons, or after 3 minutes (whichever comes first).

**Post-task question (ask immediately after E6):**
1. "Cuando apareció un mensaje de error, ¿le resultó claro qué debía hacer para corregirlo?"
2. "¿Hubo algún mensaje que le costó trabajo entender?"

---

#### **Scenario F — NFR-UEP-2: Inline Field Validation**

> *Background given to participant:*
> "Vamos a llenar el formulario de creación de evento. Le voy a pedir que intente guardar el formulario en diferentes estados. Observe lo que el sistema le muestra en cada campo."

---

| Step | Task Instruction | What the Facilitator Observes |
|---|---|---|
| F1 | "Abra el formulario para crear un evento nuevo. No llene ningún campo y presione 'Guardar'." | Are required fields highlighted immediately? Is a specific inline error shown per field? How many fields show error states simultaneously? Does the form block submission? |
| F2 | "En el campo 'Duración (hrs)', escriba '-5' y luego haga clic en el siguiente campo." | Does the field display "Debe ser mayor a 0" within 500 ms of focus-out? At what exact moment does the error appear — on keypress, on focus-out, or on save attempt? |
| F3 | "En el campo 'Precio ($)', escriba 'abc' y luego haga clic en el siguiente campo." | Does the field display "Ingrese un monto válido" within 500 ms of focus-out? |
| F4 | "Corrija el precio a '500.00' y la duración a '20'. Deje el nombre del evento en blanco y presione 'Guardar'." | Does the system still block submission with only the name field invalid? Is the name field specifically highlighted? Does any other field incorrectly show an error? |
| F5 | "Complete todos los campos correctamente (con fechas válidas, horarios y profesor asignado) y guarde." | Does the form submit successfully? Is a success confirmation displayed? |

**Facilitator-only measurements (do not narrate to participant):**

- **F2 and F3:** Open Browser DevTools before the session. Measure time from the focus-out event (clicking/tabbing away from the field) to the appearance of the inline error message. Record for each step. Must be ≤ 500 ms.
- **F1 and F4:** Confirm the form did NOT submit. Log as binary: submitted (failure) / blocked (pass). Target: 0% invalid submission rate.

**Stop condition:** Each step declared complete when the participant performs the specified action, or after 5 minutes total for Scenario F.

**Post-task question (ask immediately after F5):**
1. "¿Los mensajes de error en los campos le ayudaron a entender qué corregir antes de guardar?"
2. "¿El momento en que apareció el error le pareció oportuno, o hubiera preferido verlo antes o después?"

---

### 3.5 Type of Data Collected

#### Quantitative Data

| Data Point | NFR Addressed | Collection Method |
|---|---|---|
| **Error self-correction rate** (Self-corrected / Total encounters) × 100 | NFR-UEP-1 | Facilitator log per sub-step E1–E6, per participant |
| **Per-error-type self-correction rate** | NFR-UEP-1 | Breakdown by sub-step to identify which specific error message causes the most failures |
| **Inline validation response time** (ms from focus-out to error display) | NFR-UEP-2 | Browser DevTools / stopwatch at steps F2 and F3 |
| **Invalid form submission rate** (binary: submitted / blocked) | NFR-UEP-2 | Facilitator observation at steps F1 and F4 |
| **Number of errors per task** (wrong actions before self-correction) | NFR-UEP-1 | Screen recording review |

#### Qualitative Data

| Data Point | NFR Addressed | Collection Method |
|---|---|---|
| **Think-aloud comments** during error recovery attempts | NFR-UEP-1 | Audio recording + transcription |
| **Verbal expressions of confusion, frustration, or confidence** during error encounters | NFR-UEP-1, NFR-UEP-2 | Facilitator field notes (shorthand: C = confusion, F = frustration, S = satisfaction) |
| **Think-aloud comments** when inline validation appears or fails to appear | NFR-UEP-2 | Audio recording + facilitator notes |
| **Post-task satisfaction rating** (Single Ease Question, SEQ: 1–7 scale) per scenario | NFR-UEP-1, NFR-UEP-2 | Short verbal rating after each scenario |
| **Post-test semi-structured interview** (relevant questions) | NFR-UEP-1, NFR-UEP-2 | Audio recording |

Sample post-test interview questions:
1. "Cuando apareció un mensaje de error, ¿le resultó claro qué debía hacer para corregirlo?"
2. "¿Hubo algún mensaje de error que le costó trabajo entender?"
3. "¿Los mensajes de error en los campos le ayudaron a entender qué corregir antes de guardar?"
4. "¿El momento en que apareció el error en el campo le pareció oportuno, o hubiera preferido verlo antes o después?"
5. "¿Hubo alguna situación en la que el sistema le impidió hacer algo que usted pensó que debería poder hacer?"

---

### 3.6 How the Data Would Be Analyzed

#### Quantitative Analysis

| Metric | Analysis Approach | Pass Threshold |
|---|---|---|
| Overall self-correction rate | (Total self-corrected encounters / Total sub-step evaluations) × 100 across 5 participants × 6 sub-steps (50 total observations). | ≥ 80% (≥ 24 out of 30) |
| Per-error-message self-correction rate | Compute separately for each sub-step (E1–E6) across all 5 participants. Any single message below 60% correct self-correction flags a critical wording or placement problem regardless of overall score. | ≥ 60% per message (≥ 3 out of 5 participants) |
| Inline validation response time | Calculate mean and range of focus-out-to-error-display time at F2 and F3 across 5 participants. | Mean ≤ 500 ms; no single measurement > 800 ms |
| Invalid form submission rate | Binary count of any F1 or F4 step where the form submitted despite invalid state, across all 5 participants. | 0% (0 invalid submissions out of 10 attempts) |
| Error rate per task | Mean number of incorrect actions before self-correction, per sub-step. Used to rank which error scenarios require the most effort to recover from. | Informs redesign priority |

Since the sample is small (n = 5), no inferential statistics are appropriate. The analysis is descriptive — rates, means, and pass/fail against the defined thresholds.

#### Qualitative Analysis

- **Affinity Mapping:** Think-aloud comments and interview responses are transcribed, coded by error message identity (e.g., "capacity limit message", "category in-use message", "date range inline error"), and grouped into themes (e.g., "business rule messages understood immediately", "inline validation timing felt too late", "capacity error caused confusion about next steps").
- **Severity Rating:** Each usability issue identified from observations and comments is rated by severity (Critical / Major / Minor) using Nielsen's 0–4 scale. An error message that results in task abandonment (Gave up) is rated Critical. An error message that required a hint is rated Major.
- **SEQ Score Interpretation:** A mean SEQ score below 5 out of 7 for either scenario (E or F) signals a meaningful user error protection problem requiring redesign.
- **Cross-referencing:** Sub-steps where self-correction failed (Needed hint / Gave up) are linked to the corresponding think-aloud transcript and post-test interview to understand *why* the message failed — e.g., whether the wording was unclear, the error appeared in an unexpected location, or the required corrective action was not obvious from the message.
- **NFR-UEP-1 vs. NFR-UEP-2 interaction:** If inline validation in Scenario F is late or missing (NFR-UEP-2 failure), the same participant may encounter more business-rule errors in Scenario E (NFR-UEP-1). Cross-reference the two scenarios to determine whether a weak validation layer is causing downstream recovery failures.

---

### 3.7 Test Deliverables

1. **Session recording files** (screen + audio) per participant.
2. **Facilitator observation log** (tabular, per sub-step E1–E6 and F1–F5, per participant) — including self-correction outcome (Self-corrected / Needed hint / Gave up) for E, and submission outcome (blocked / submitted) for F.
3. **Quantitative metrics summary table** — overall and per-message self-correction rate, inline validation response times, invalid submission count, compared against NFR pass thresholds.
4. **Browser DevTools measurement log** — timestamped focus-out and error-display events for F2 and F3.
5. **Affinity map / issue log** — qualitative themes per error scenario, with severity ratings.
6. **Validation checklist** — NFR-UEP-1 and NFR-UEP-2 metrics marked Pass / Fail / Partial with supporting evidence.
7. **Improvement recommendations** — prioritized list of error message wording changes and/or validation timing/placement fixes if any thresholds are not met, specifying the exact message or field, the observed problem, and the recommended correction.

---

## 4. Summary of Relevance

| Why User Error Protection | Evidence from This Project |
|---|---|
| Administrative data has zero-error tolerance | Enrollment approvals, payment confirmations, and event records feed directly into official academic processes — invalid data saved has real downstream consequences for students and finances |
| No assumed support channel | Ana Ramírez has no helpdesk for the system; if an error message does not self-explain the corrective action, she has no fallback — NFR-UEP-1 mandates ≥ 80% self-correction precisely to account for this |
| High-frequency form use multiplies error risk | Events, enrollments, and payments are created and modified multiple times per day; even a low per-form error rate becomes a significant burden at scale |
| Two protection layers are required | NFR-UEP-2 (inline validation, 0% invalid submissions) prevents structural errors from reaching the server at all; NFR-UEP-1 (plain-language recovery messages) handles business-rule violations that can only be caught at the application logic level — both layers are necessary and complementary |
