# Data Collection Plan: Validating the Operability Usability Attribute

### Team

- Hugo de Jesús Janssen Aguilar
- Jesse Oswaldo Martin Jimenez
- Waldo Camara Villacis
- Jose Elias Novelo Collí

---

## 1. Definition of Operability in Context

**Operability** (ISO 25010) is the degree to which the system has attributes that make it easy to operate and control. For the FCA administrative system, this translates into:

| Sub-attribute | What it means in this system |
|---|---|
| **Controllability** | The user can start, pause, and cancel actions at will (e.g., cancel event creation, close forms) |
| **Operational consistency** | Buttons, icons, and interaction patterns are identical across the 5 modules (Events, Categories, Enrollments, Payments, My Account) |
| **System feedback** | The system communicates status and results in natural administrative language, without technical codes |
| **Operational error tolerance** | Errors are flagged at the field level before submission; messages guide self-correction |
| **Ease of navigation** | The user finds the necessary functions without extensive searching or ambiguity |

---

## 2. Data Collection Methods

Three complementary methods are proposed (triangulation):

### A. Moderated Usability Testing (Primary method)
- **Type**: Direct observation with think-aloud protocol
- **Participants**: 3–5 real FCA coordinators
- **Format**: Individual 30–40 minute sessions
- **Tools**: Screen + audio recording, moderator notes

### B. Post-Task Questionnaire
- **Instrument**: SUS (System Usability Scale) + operability-specific items
- **Application**: Immediately after all tasks are completed

### C. Observation Checklist
- **Instrument**: Checklist of observable behaviors related to operability
- **Application**: During the session by a dedicated observer

---

## 3. Test Tasks (Scenarios)

Each task is designed to expose a specific aspect of operability:

| # | Task | Related UC | Operability aspect evaluated |
|---|---|---|---|
| T1 | Create an "Advanced Excel Course" event from scratch, category "Course", in-person modality, capacity 25, with 2 instructors | CU-GE-001 | Form controllability, real-time validation, clarity of required fields |
| T2 | Clone the "Advanced Excel Course" event and modify only the dates and instructor | CU-GE-001 | Operability in clone flow, identification of variable fields (highlighted in yellow) |
| T3 | Search for an event by partial name and change its modality from in-person to virtual | CU-GE-002, CU-GE-003 | Findability of search-as-you-type, search→edit navigation |
| T4 | Archive a category that has active events and observe the system response | CU-GE-015 | Error tolerance, clarity of the blocking message |
| T5 | Review 3 pending enrollment applications: approve one, reject another (with reason), request more information from the third | CU-GE-009 | Consistency across actions (approve/reject/request info), per-action feedback |
| T6 | Confirm a manual payment, then attempt to confirm the same payment again (duplicate) | CU-GE-010 | Error prevention, invalid-operation message |
| T7 | Cancel an active event providing a reason | CU-GE-025 | Controllability of irreversible actions, confirmation before execution |

---

## 4. Metrics to Collect

### Quantitative (per task)

| Metric | Definition | Instrument | Target value |
|---|---|---|---|
| **Success rate** | % of users who complete the task without assistance | Observation | ≥ 80% |
| **Time on task** | Seconds from start to declared completion | Recording/stopwatch | Compare against moderator benchmark |
| **Operational errors** | Number of clicks in wrong places, failed submission attempts, incorrect navigation | Observation + recording | ≤ 2 per task |
| **Assists requested** | Number of times the user asks the moderator for help | Observation | ≤ 1 per session |
| **SUS score** | 0–100 (standard perceived usability scale) | Post-session questionnaire | ≥ 68 (average) |

### Qualitative (observation + think-aloud)

| Data point | How it is collected |
|---|---|
| Confusion/frustration comments | Think-aloud transcript |
| Hesitation before controls (hover without click, erratic scrolling) | Moderator observation + recording |
| Interpretation of system messages | Post-task verification question: "What did the system tell you?" |
| Ease of locating functions in the NavigationRail | Observation: navigates directly to module or hesitates? |

---

## 5. Operability Questionnaire (specific items)

Likert scale 1–5 (1 = Strongly disagree, 5 = Strongly agree), administered after completing all tasks:

1. "I was able to navigate between the different modules (Events, Categories, Enrollments, Payments) without difficulty"
2. "Buttons and icons work consistently across all sections of the system"
3. "The system clearly informed me when an action was completed successfully"
4. "When I made a mistake, the system told me what to fix in understandable language"
5. "I was able to cancel or undo actions when I changed my mind"
6. "I found the functions I needed without having to search too much"
7. "The forms adequately guided me on which fields to fill in and in what order"
8. "I felt in control of what the system was doing at all times"

---

## 6. Observation Checklist

The observer checks off during the session:

- [ ] User correctly identifies the NavigationRail section for each task
- [ ] User uses search-as-you-type without hesitation
- [ ] User recognizes status badges by color without reading the text
- [ ] User locates primary action buttons (Create, Save, Confirm) in ≤ 3 seconds
- [ ] User correctly interprets form validation messages
- [ ] User cancels/closes dialogs and forms without asking how
- [ ] User completes the clone→modify→save flow without missteps
- [ ] User does not attempt blocked actions (e.g., archiving a category with active events without reading the message)

---

## 7. Session Procedure (30–40 min)

| Phase | Duration | Activity |
|---|---|---|
| 1. Introduction | 3 min | Explain purpose (the user is not being tested, the system is), informed consent, explain think-aloud |
| 2. Pre-test | 2 min | Brief demographics, prior experience with administrative systems |
| 3. Task execution | 20 min | 7 tasks in fixed order. Moderator reads each scenario, gives no hints. User verbalizes their thoughts |
| 4. Questionnaire | 5 min | SUS + operability items |
| 5. Debriefing | 5 min | Open-ended questions: "What was the hardest part?" "What would you like to work differently?" |

---

## 8. Data Analysis

1. **Per task**: Calculate success rate, average time, average errors. Flag critical tasks (success < 70%).
2. **Per user**: Individual SUS score. Correlate low SUS with tasks where they had the most errors.
3. **Per sub-attribute**: Group qualitative findings under each operability sub-attribute (controllability, consistency, feedback, error tolerance, navigation).
4. **Severity rating**: Classify each issue found as:
   - **Critical**: Prevents task completion (requires immediate fix)
   - **Major**: Causes frustration or significant delay (fix in next iteration)
   - **Minor**: Cosmetic annoyance (fix if time permits)
5. **Final report**: Findings table with evidence (video timestamp, verbatim user quote) → prioritized recommendations for the fourth delivery.

---

## 9. Logistics

| Requirement | Detail |
|---|---|
| **Environment** | Quiet office/room, preferably the coordinator's actual workspace (contextual testing) |
| **Equipment** | 2 laptops (1 for the system, 1 for recording/streaming), microphone, screen recording software (OBS) |
| **Test data** | Pre-populate the system with: 10 events in various statuses, 5 categories, 20 enrollments, 10 pending payments |
| **Consent** | Signed form authorizing recording and academic use of anonymized data |
| **Pilot** | 1 dry-run session with a teammate to calibrate timing and instruments before real sessions |
