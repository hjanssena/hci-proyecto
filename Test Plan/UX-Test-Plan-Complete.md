# UX Testing Protocol — Complete ISO 25010 Usability Validation
### Continuous Education Management System — FCA

---

## Overview

This document is the **client-ready usability testing protocol.** It covers all seven Non-Functional Requirements defined in the README, mapped across four ISO 25010 usability attributes: **Operability**, **Accessibility**, **Appropriateness Recognizability**, and **User Error Protection**.

**Instructions for the facilitator:** follow each scenario exactly as written. Do not explain the interface to the participant. Intervene only if they are blocked for more than 3 minutes (mark the task as "failure").

---

## 1. Attribute-to-NFR Mapping

| # | NFR ID | ISO 25010 Attribute | What is Validated | Test Scenario |
|---|--------|---------------------|-------------------|---------------|
| 1 | NFR-OP-1 | Operability | Clone pre-fills ≥90% fields; mandatory variable fields highlighted yellow | **Scenario A** |
| 2 | NFR-AC-1 | Accessibility | Tabular design shows ≥10 records at 1080p without scrolling | **Scenario B** |
| 3 | NFR-AR-1 | Appropriateness Recognizability | Color-coded status badges identified correctly within 5 seconds | **Scenario C** |
| 4 | NFR-OP-2 | Operability | Search-as-you-type locates target record ≤30 seconds | **Scenario D** |
| 5 | NFR-UEP-1 | User Error Protection | Plain-language error messages; ≥80% self-correction rate | **Scenario E** |
| 6 | NFR-UEP-2 | User Error Protection | Inline field-level validation catches errors before submission | **Scenario F** |
| 7 | NFR-OP-3 | Operability | Standardized CRUD UI: ≥85% first-time task success rate | **Scenario G** |

---

## 2. Pre-Test Preparation

### 2.1 Environment Setup

- **Display:** 1920×1080 monitor (required for Scenario B measurement).
- **Browser:** Google Chrome (latest stable), window maximized, no zoom.
- **Recording:** Screen + audio capture (OBS Studio or Lookback.io). Microphone must capture the participant's think-aloud narration.
- **Timer:** Stopwatch visible only to the facilitator.
- **Network:** The prototype must be running locally or deployed at a known URL. Confirm connectivity before each session.

### 2.2 Data Pre-Seeding

The prototype database must contain the following before testing begins:

| Data Requirement | Purpose | Minimum Count |
|------------------|---------|---------------|
| Event records | Search performance testing | ≥ 500 |
| Archived events (suitable for cloning) | Scenario A | ≥ 1 |
| Active event categories | Scenarios D, G | ≥ 3 |
| Enrollment records (various statuses) | Scenarios C, E, F | ≥ 15 |
| Payment records (pending verification) | Scenarios C, E | ≥ 5 |
| One event at max capacity | Scenario F (capacity error) | 1 |

To seed data, run the backend seed command:
```bash
cd prototype/backend && python manage.py seed_data
```

### 2.3 Participant Profile

| Criterion | Requirement |
|-----------|-------------|
| Role | FCA administrative staff (Continuous Education coordinators) or equivalent |
| Experience with systems | Familiarity with administrative software (Excel, ERP-style) |
| Prior exposure to prototype | **None** |
| Age range | 25–55 (matching persona: Ana Ramírez) |
| Sample size | **5 participants** |

### 2.4 Facilitator Materials Checklist

- [ ] Printed scenario cards (one per participant, in Spanish)
- [ ] Observer log template (printed or digital)
- [ ] Stopwatch
- [ ] Screen recording started
- [ ] Consent form signed
- [ ] Post-test interview question sheet

---

## 3. Scenario Scripts

---

### Scenario A — NFR-OP-1 (Operability): Clone and Adapt an Existing Event

**Attribute:** Operability
**Metric:** Clone form pre-fills ≥90% of fields; mandatory variable fields highlighted in yellow; task completion ≤ 2 minutes.

> **Read to participant:**
> "Necesita programar una nueva edición del 'Diplomado en Gestión Empresarial' que se impartió el semestre pasado. En lugar de crearlo desde cero, use el sistema para clonar el evento anterior y actualice solo lo que cambió para la nueva edición."

| Step | Task Instruction | Facilitator Observes |
|------|-----------------|-----------------------|
| A1 | "Busque la edición anterior del 'Diplomado en Gestión Empresarial'." | Can the participant find the event list? Do they attempt to use the search field? Time to locate. |
| A2 | "Utilice la función de clonar para crear una nueva edición." | Does the participant locate the "Clonar evento" button? Do they understand the clone dialog with its own search? |
| A3 | "Revise el formulario clonado. Actualice la fecha de inicio a **15 de agosto de 2026** y asigne al profesor **Dr. Carlos Mendoza**." | Which fields are pre-filled? Are dates highlighted in yellow? Do they understand what is variable vs. pre-filled? |
| A4 | "Guarde el nuevo evento." | Time from A2 start to A4 completion. Think-aloud comments about field clarity. |

**Stop condition:** 5 minutes or when the participant sees the success message.

**Post-task questions (ask immediately):**
1. "¿Sintió que podía identificar fácilmente qué campos debía modificar?"
2. "¿Los campos resaltados en amarillo le ayudaron a entender qué información era variable?"

---

### Scenario B — NFR-AC-1 (Accessibility): Visible Record Density

**Attribute:** Accessibility
**Metric:** At 1920×1080 resolution and default browser settings, ≥10 event records visible without vertical scrolling.

> **Read to participant:**
> "Abra la lista de eventos y dígame cuántos eventos puede ver en la pantalla sin necesidad de hacer scroll."

| Step | Task Instruction | Facilitator Observes |
|------|-----------------|-----------------------|
| B1 | "Navegue a la sección de Eventos." | Confirms they are on the event list view. |
| B2 | "Cuente cuántos eventos ve visibles ahora mismo sin desplazarse." | Count visible rows. Check if the search bar, filters, and table header take excessive space. |
| B3 | "¿Puede leer cómodamente el texto en cada fila?" | Participant's subjective readability rating. |

**Facilitator measurement (do NOT tell participant):**
- Screenshot the viewport at 1920×1080.
- Count visible DataRows (excluding header row).
- Document row height in pixels (should be 36–42px per row based on implementation).

---

### Scenario C — NFR-AR-1 (Appropriateness Recognizability): Status Identification

**Attribute:** Appropriateness Recognizability
**Metric:** ≥90% of participants correctly identify record status within 5 seconds without guidance; status colors meet WCAG 2.1 AA contrast ratio (≥4.5:1).

> **Read to participant:**
> "Voy a mostrarle diferentes pantallas del sistema. Para cada registro que señale, dígame rápidamente en qué estado se encuentra y cómo lo supo."

**Part 1 — Enrollment Statuses (CU-GE-009):**

| Sub-step | Facilitator Action | Correct Answer | Time Limit |
|----------|-------------------|----------------|------------|
| C1 | Point to an enrollment with status "Pendiente de Revisión" (blue badge). | "Pendiente de Revisión" | 5 seconds |
| C2 | Point to an enrollment with status "Aprobada" (green badge). | "Aprobada" | 5 seconds |
| C3 | Point to an enrollment with status "Rechazada" (red badge). | "Rechazada" | 5 seconds |
| C4 | Point to an enrollment with status "Información Requerida" (orange/amber badge). | "Información Requerida" or similar | 5 seconds |

**Part 2 — Payment Statuses (CU-GE-010):**

| Sub-step | Facilitator Action | Correct Answer | Time Limit |
|----------|-------------------|----------------|------------|
| C5 | Point to a payment with status "Pendiente de Verificación de Pago" (blue badge). | "Pendiente" or "Pendiente de Verificación" | 5 seconds |
| C6 | Point to a payment with status "Confirmada" (green badge). | "Confirmada" | 5 seconds |
| C7 | Point to a payment with status "Pago Rechazado" (red badge). | "Rechazado" | 5 seconds |

**Part 3 — Event Statuses (CU-GE-002):**

| Sub-step | Facilitator Action | Correct Answer | Time Limit |
|----------|-------------------|----------------|------------|
| C8 | Point to an event with status "En fase de inscripciones" (blue badge). | "En fase de inscripciones" or "Inscripciones" | 5 seconds |
| C9 | Point to an event with status "Confirmado" (green badge). | "Confirmado" | 5 seconds |
| C10 | Point to a cancelled event (red badge) with cancellation reason tooltip. Ask: "¿Ve algo adicional aquí?" | Identifies the tooltip/icon indicating a cancellation reason exists | 10 seconds |

**Post-task question:**
- "¿Los colores le ayudaron a distinguir los estados? ¿Hubo alguno que le generó confusión?"

**Facilitator-only measurement:**
- Measure color contrast ratio of each badge label text against its background using a contrast checker tool (e.g., WebAIM Contrast Checker). Document pass/fail for ≥4.5:1.

---

### Scenario D — NFR-OP-2 (Operability): Search-as-You-Type

**Attribute:** Operability
**Metric:** Target record located ≤30 seconds; results appear within 300 ms of each keystroke.

> **Read to participant:**
> "Un director de departamento le ha pedido verificar los detalles de un evento llamado 'Taller de Liderazgo Organizacional' que se realizó a principios de este año. Localícelo en el sistema."

**Part 1 — Event Search:**

| Step | Task Instruction | Facilitator Observes |
|------|-----------------|-----------------------|
| D1 | "Navegue a la lista de eventos." | Can the participant find the list without assistance? |
| D2 | "Use la búsqueda para encontrar el evento." | Does the participant start typing without being prompted? Does the table update in real time? Count keystrokes typed before target appears. |
| D3 | "Abra los detalles del evento." | Time elapsed from D1 to D3. |

**Part 2 — Category Search:**

> "Ahora localice la categoría llamada 'Curso de Actualización Fiscal' en la sección de Categorías."

| Step | Task Instruction | Facilitator Observes |
|------|-----------------|-----------------------|
| D4 | "Navegue a la sección de Categorías." | Can they switch modules via the sidebar? |
| D5 | "Use la búsqueda para encontrar la categoría." | Same observations as D2. |
| D6 | "Confirme que la encontró señalándola." | Time elapsed from D4 to D6. |

**Stop condition:** 2 minutes per part.

**Facilitator-only measurement:**
- Open Browser DevTools Network tab. Type a search character. Measure time from keystroke to API response. Record for 3 separate keystrokes. Average must be ≤300 ms.

---

### Scenario E — NFR-UEP-1 (User Error Protection): Plain-Language Error Recovery

**Attribute:** User Error Protection
**Metric:** ≥80% of participants self-correct after reading an error message without external help.

> **Read to participant:**
> "Va a realizar algunas operaciones en el sistema. Si aparece algún mensaje de error, léalo en voz alta e intente resolverlo por su cuenta."

**Part 1 — Business Rule Errors:**

| Sub-step | Task Instruction | Expected Error | Facilitator Observes |
|----------|-----------------|----------------|-----------------------|
| E1 | "Intente archivar un evento que tenga inscripciones activas." | "El evento tenía inscripciones activas. Su estado ha cambiado a 'Cancelado' y se notificará a los usuarios." / "El evento ha sido archivado." (either path) | Does the participant read the response message? Do they understand what happened to the event? |
| E2 | "Intente archivar una categoría que esté siendo utilizada por eventos activos." | "La categoría está siendo utilizada por uno o más eventos activos. Reasigne los eventos antes de archivarla." | Does the participant understand the constraint? Do they attempt a workaround? |
| E3 | "Intente aprobar una inscripción para un evento que ya está en su capacidad máxima." | "El evento ha alcanzado su límite de cupo y no permite la aprobación." | Does the participant understand the capacity limit? |

**Part 2 — Validation Errors on Forms:**

| Sub-step | Task Instruction | Expected Error | Facilitator Observes |
|----------|-----------------|----------------|-----------------------|
| E4 | "Intente crear un evento nuevo con la fecha de fin anterior a la fecha de inicio." (Instruct: set start date to Dec 20, 2026 and end date to Dec 1, 2026) | "La fecha de fin no puede ser anterior a la de inicio" | Does the participant notice the inline error? Do they correct it? |
| E5 | "En el mismo formulario, ponga una cantidad mínima de inscripciones mayor que la capacidad máxima (ej: capacidad 10, mínimo 50) e intente guardar." | "No puede exceder la capacidad" | Does the participant understand the relationship between these two fields? |
| E6 | "Intente confirmar un pago que ya esté confirmado." | "El pago ya está confirmado." | Does the participant understand they are attempting a duplicate action? |

**Scoring (per sub-step):**
- **Self-corrected:** Participant read the error and fixed it without asking for help.
- **Needed hint:** Participant asked "what does this mean?" or looked at the facilitator.
- **Gave up:** Participant abandoned the task or needed explicit instruction.

**Target:** ≥80% of error encounters result in self-correction (i.e., ≥24 out of 30 across 5 participants × 6 error sub-steps).

---

### Scenario F — NFR-UEP-2 (User Error Protection): Inline Field Validation

**Attribute:** User Error Protection
**Metric:** Inline validation triggers within 500 ms of focus-out; 0% of invalid forms successfully submitted.

> **Read to participant:**
> "Vamos a llenar el formulario de creación de evento. Le voy a pedir que intente guardar el formulario en diferentes estados. Observe lo que el sistema le muestra en cada campo."

| Step | Task Instruction | Facilitator Observes |
|------|-----------------|-----------------------|
| F1 | "Abra el formulario para crear un evento nuevo. No llene nada y presione 'Guardar'." | Are required fields highlighted? Is a message shown per field? How many fields show errors? |
| F2 | "En el campo 'Duración (hrs)', escriba '-5'." | Does the field show "Debe ser mayor a 0"? At what moment does validation appear (on focus-out)? |
| F3 | "En el campo 'Precio ($)', escriba 'abc'." | Does the field show "Ingrese un monto válido"? |
| F4 | "Corrija el precio a '500.00' y la duración a '20'. Deje vacío el nombre del evento y presione 'Guardar'." | Does the system still block submission? Is the name field specifically highlighted? |
| F5 | "Complete todos los campos correctamente (con fechas válidas, horarios, profesores) y guarde." | Confirm the form can be successfully submitted when all validations pass. |

**Facilitator-only measurements:**
- For F2 and F3: measure time from focus-out (clicking/tabbing away from the field) to the appearance of the inline error message. Must be ≤500 ms.
- Confirm at F4: the form did NOT submit (0% invalid submission rate).

---

### Scenario G — NFR-OP-3 (Operability): First-Time CRUD Consistency

**Attribute:** Operability
**Metric:** ≥85% first-time task success rate across CRUD operations without training.

> **Read to participant:**
> "Usted nunca ha usado este sistema antes. Complete las siguientes tareas una después de otra. No le diré dónde están los botones — confíe en lo que le parece lógico."

| Step | Task Instruction | Module Tested | Facilitator Observes |
|------|-----------------|---------------|-----------------------|
| G1 | "Cree una nueva categoría de evento llamada 'Seminario Internacional'." | CU-GE-012 (Create) | Can they find the "Crear categoría" button? Do they complete the dialog? |
| G2 | "Cambie el nombre de la categoría que acaba de crear a 'Seminario Empresarial Internacional'." | CU-GE-014 (Modify) | **After G1, note where their eyes go first.** If they immediately look for the edit icon in the same table row, CRUD consistency is confirmed. If they search around, it signals a problem. |
| G3 | "Archive la categoría 'Seminario Empresarial Internacional'." | CU-GE-015 (Archive) | Do they find the archive (orange) icon? Do they confirm the dialog? |
| G4 | "Regrese a Eventos. Abra cualquier evento, vea sus detalles y luego regrese a la lista." | CU-GE-002 (Consult) | Is the navigation pattern consistent? Back button position? |

**Scoring (per participant):**
- G1 success: Created category with correct name.
- G2 success: Modified category without being told how. **Count as "first-time success" only if they initiated the edit without guidance.**
- G3 success: Archived the category with confirmation.
- G4 success: Navigated to detail and back.

**Overall:** (Number of successful task completions / Total task attempts) × 100 across all 5 participants. Target ≥85%.

---

## 4. Data Collection

### 4.1 Quantitative Data

| Data Point | NFR | Collection Method | Pass Threshold |
|------------|-----|-------------------|----------------|
| Clone task completion time (seconds) | NFR-OP-1 | Stopwatch, A1–A4 | Mean ≤ 120 s |
| Pre-fill rate on clone form | NFR-OP-1 | Post-test form audit: count pre-filled vs. total fields | ≥ 90% |
| Visible rows at 1920×1080 | NFR-AC-1 | Screenshot + count | ≥ 10 rows |
| Status identification accuracy | NFR-AR-1 | Facilitator log per sub-step C1–C10 | ≥ 90% correct |
| Status identification speed | NFR-AR-1 | Stopwatch per sub-step | ≤ 5 s each |
| Badge color contrast ratio | NFR-AR-1 | WebAIM Contrast Checker | ≥ 4.5:1 |
| Search-to-target time (seconds) | NFR-OP-2 | Stopwatch, D1–D6 | Mean ≤ 30 s |
| Search API latency (ms) | NFR-OP-2 | Browser DevTools Network tab | ≤ 300 ms per keystroke |
| Error self-correction rate | NFR-UEP-1 | Facilitator log per sub-step (Self-corrected / Needed hint / Gave up) | ≥ 80% self-corrected |
| Inline validation response time | NFR-UEP-2 | Stopwatch on focus-out to error display | ≤ 500 ms |
| Invalid form submission rate | NFR-UEP-2 | Binary: did an invalid form submit? | 0% |
| First-time CRUD task success rate | NFR-OP-3 | (Successful completions / Total attempts) × 100 | ≥ 85% |

### 4.2 Qualitative Data

| Data Point | Collection Method |
|------------|-------------------|
| Think-aloud narration during all scenarios | Audio recording + transcription |
| Expressions of confusion, frustration, or confidence | Facilitator field notes (use shorthand codes: C=confusion, F=frustration, S=satisfaction) |
| Single Ease Question (SEQ) after each scenario | Verbal 1–7 scale: "En una escala del 1 al 7, ¿qué tan fácil le pareció esta tarea?" |
| Post-test semi-structured interview | Audio recording (see Section 5) |

---

## 5. Post-Test Semi-Structured Interview

Ask all participants these questions after completing all scenarios:

1. "Cuando clonó el evento, ¿le quedó claro qué campos necesitaba cambiar?"
2. "¿Cómo se sintió usando la búsqueda comparado con cómo normalmente busca registros en otros sistemas?"
3. "¿Los colores de los estados le parecieron intuitivos? ¿Hubo alguno que no supo interpretar de inmediato?"
4. "Cuando apareció un mensaje de error, ¿le resultó claro qué debía hacer para corregirlo?"
5. "¿Sintió que los botones y menús eran consistentes al moverse entre las diferentes secciones (Eventos, Categorías, Inscripciones, Pagos)?"
6. "¿Hubo algo en la interfaz que le sorprendió o que sintió fuera de lugar?"
7. "Si pudiera cambiar una sola cosa del sistema para hacerlo más fácil de usar, ¿qué cambiaría?"

---

## 6. Analysis Plan

### 6.1 Quantitative Analysis

For each NFR, compute the metric against its pass threshold. Since n=5, use descriptive statistics (mean, range, pass/fail count). No inferential tests are appropriate.

**Example summary table:**

| NFR | Attribute | Metric | Mean | Pass Threshold | Result |
|-----|-----------|--------|------|----------------|--------|
| NFR-OP-1 | Operability | Clone time | 87 s | ≤120 s | ✅ PASS |
| NFR-OP-1 | Operability | Pre-fill rate | 93% | ≥90% | ✅ PASS |
| NFR-AC-1 | Accessibility | Visible rows | 12 | ≥10 | ✅ PASS |
| NFR-AR-1 | Appr. Recog. | Status accuracy | 94% | ≥90% | ✅ PASS |
| NFR-OP-2 | Operability | Search time | 18 s | ≤30 s | ✅ PASS |
| NFR-UEP-1 | Error Protection | Self-correction | 83% | ≥80% | ✅ PASS |
| NFR-UEP-2 | Error Protection | Invalid submits | 0% | 0% | ✅ PASS |
| NFR-OP-3 | Operability | CRUD success | 88% | ≥85% | ✅ PASS |

### 6.2 Qualitative Analysis

1. **Affinity Mapping:** Transcribe think-aloud and interview responses. Code each comment by NFR. Group into themes (e.g., "confusion about mandatory fields on clone", "search is fast and intuitive").
2. **Severity Rating:** Rate each usability issue using Nielsen's 0–4 scale:
   - **0** = Not a usability problem
   - **1** = Cosmetic problem (fix if time allows)
   - **2** = Minor problem (low priority)
   - **3** = Major problem (high priority, causes delay or confusion)
   - **4** = Usability catastrophe (task failure, must fix)
3. **SEQ Score Interpretation:** Mean SEQ below 5/7 for any scenario flags a meaningful operability problem.
4. **Cross-Reference:** For every task failure or metric below threshold, find the corresponding qualitative comments to explain *why*.

---

## 7. Client Validation Checklist

Deliver this completed checklist to the FCA Continuous Education department alongside the test results.

| NFR | ISO 25010 Attribute | Metric | Threshold | Measured Value | Pass / Fail |
|-----|---------------------|--------|-----------|----------------|-------------|
| NFR-OP-1 | Operability | Clone completion time | ≤ 2 min | ___ | ___ |
| NFR-OP-1 | Operability | Pre-filled fields on clone | ≥ 90% | ___ | ___ |
| NFR-AC-1 | Accessibility | Visible records at 1080p | ≥ 10 rows | ___ | ___ |
| NFR-AR-1 | Appr. Recognizability | Status identification accuracy | ≥ 90% | ___ | ___ |
| NFR-AR-1 | Appr. Recognizability | Color contrast ratio | ≥ 4.5:1 | ___ | ___ |
| NFR-OP-2 | Operability | Search target location time | ≤ 30 s | ___ | ___ |
| NFR-OP-2 | Operability | Search result latency | ≤ 300 ms | ___ | ___ |
| NFR-UEP-1 | User Error Protection | Self-correction rate | ≥ 80% | ___ | ___ |
| NFR-UEP-2 | User Error Protection | Inline validation response | ≤ 500 ms | ___ | ___ |
| NFR-UEP-2 | User Error Protection | Invalid form submission rate | 0% | ___ | ___ |
| NFR-OP-3 | Operability | First-time CRUD success rate | ≥ 85% | ___ | ___ |

**Overall Assessment:**

[ ] All NFRs pass — system is ready for deployment.
[ ] Some NFRs fail — see Section 8 (Improvement Recommendations).

---

## 8. Improvement Recommendations Template

For each NFR that does NOT meet its threshold, document:

| NFR | Failure Description | Root Cause (from observations) | Recommended Fix | Severity (0–4) |
|-----|---------------------|-------------------------------|-----------------|----------------|
| | | | | |

---

## 9. Test Deliverables

1. Session recording files (screen + audio) — 5 participants.
2. Completed facilitator observation logs — 5 logs.
3. Quantitative metrics summary table (Section 6.1).
4. Color contrast audit report (Scenario C, WebAIM).
5. Affinity map / issue log with severity ratings.
6. Completed validation checklist (Section 7).
7. Improvement recommendations (Section 8) if applicable.
8. Post-test interview transcript highlights.

---

## Appendix A: Observer Log Template

Photocopy one per participant:

```
Participant ID: ____   Date: ________   Facilitator: ________

SCENARIO A — Clone Event
A1: Found event? [ ] Yes [ ] No   Time: ___ s   Notes: _______
A2: Found clone button? [ ] Yes [ ] No   Time: ___ s   Notes: _______
A3: Understood highlighted fields? [ ] Yes [ ] Partially [ ] No   Notes: _______
A4: Save completed? [ ] Yes [ ] No   Total time A2→A4: ___ s
SEQ (1-7): ___

SCENARIO B — Record Density
B2 visible rows (count): ___   Readability (1-7): ___

SCENARIO C — Status Identification
C1: [ ] Correct [ ] Wrong   Time: ___ s
C2: [ ] Correct [ ] Wrong   Time: ___ s
C3: [ ] Correct [ ] Wrong   Time: ___ s
C4: [ ] Correct [ ] Wrong   Time: ___ s
C5: [ ] Correct [ ] Wrong   Time: ___ s
C6: [ ] Correct [ ] Wrong   Time: ___ s
C7: [ ] Correct [ ] Wrong   Time: ___ s
C8: [ ] Correct [ ] Wrong   Time: ___ s
C9: [ ] Correct [ ] Wrong   Time: ___ s
C10: [ ] Correct [ ] Wrong   Time: ___ s   Noticed tooltip? [ ] Yes [ ] No

SCENARIO D — Search
D1→D3 event search time: ___ s   Keystrokes to target: ___
D4→D6 category search time: ___ s   Keystrokes to target: ___
SEQ (1-7): ___

SCENARIO E — Error Recovery
E1: [ ] Self-corrected [ ] Needed hint [ ] Gave up   Notes: _______
E2: [ ] Self-corrected [ ] Needed hint [ ] Gave up   Notes: _______
E3: [ ] Self-corrected [ ] Needed hint [ ] Gave up   Notes: _______
E4: [ ] Self-corrected [ ] Needed hint [ ] Gave up   Notes: _______
E5: [ ] Self-corrected [ ] Needed hint [ ] Gave up   Notes: _______
E6: [ ] Self-corrected [ ] Needed hint [ ] Gave up   Notes: _______

SCENARIO F — Inline Validation
F1: Form blocked? [ ] Yes [ ] No   Fields highlighted? [ ] Yes [ ] No
F2: Validation appeared? [ ] Yes [ ] No   Time (ms): ___
F3: Validation appeared? [ ] Yes [ ] No   Time (ms): ___
F4: Form blocked? [ ] Yes [ ] No   (MUST be Yes)
F5: Form submitted? [ ] Yes [ ] No

SCENARIO G — CRUD Consistency
G1: [ ] Success [ ] Failure   Time: ___ s
G2: Found edit without guidance? [ ] Yes [ ] No   Time: ___ s
G3: [ ] Success [ ] Failure   Time: ___ s
G4: [ ] Success [ ] Failure   Time: ___ s
SEQ (1-7): ___

POST-TEST INTERVIEW NOTES:
Q1: _________________________________
Q2: _________________________________
Q3: _________________________________
Q4: _________________________________
Q5: _________________________________
Q6: _________________________________
Q7: _________________________________
```

---

## Appendix B: Participant Consent Script

> "Gracias por participar en esta prueba de usabilidad. El objetivo es evaluar el sistema, no a usted. No hay respuestas correctas o incorrectas. Le pediré que piense en voz alta mientras realiza las tareas — diga todo lo que pase por su mente. La sesión será grabada (pantalla y audio) únicamente para análisis interno del equipo. ¿Tiene alguna pregunta antes de comenzar?"

[ ] Consent form signed
[ ] Recording started
[ ] Scenario cards handed to participant
