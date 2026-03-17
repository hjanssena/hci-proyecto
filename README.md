
# Continuous Education Management System - FCA

### Team
* Hugo de Jesús Janssen Aguilar
* Jesse Oswaldo Martin Jimenez
* Waldo Camara Villacis
* Jose Elias Novelo Collí

##  Project Overview
This system is an internal administrative platform designed for the **Staff of the FCA Continuous Education Department**. It focuses on streamlining the complete lifecycle of educational events, from initial creation and scheduling to formal conclusion or cancellation.

The platform centralizes administrative tasks, replacing manual tracking with a digital workflow to manage courses, workshops and diplomas.

[Click here for more information about the project](https://github.com/Proyectos-Vinculacion-FMAT/ECFCA)

##  Target User
* **FCA Continuous Education Staff (Coordinators):** Users responsible for setting up the educational offer and managing post-event data.

[Click here to see our Persona specification](https://github.com/hjanssena/hci-proyecto/blob/97920b055d7ff2ed91a164167daa1bf3a51b1894/UserPersona.pdf)

##  Project Scope

### **Core Features (Implemented)**
* **Event Lifecycle Management:**
    * Creation of events from scratch or by cloning previous ones.
    * Modification of event details like teachers, dates, and modalities.
    * Archiving events for historical reporting.
    * Formal cancellation with automated voucher/refund workflows.

### **Out of Scope**
* **Public Portal:** No external interface for student self-registration or automated payment gateways.
* **Instructor Tools:** No dedicated views for instructors to check payment details or assigned courses.
* **Certification:** Automated generation of participant or instructor certificates is not supported.
* **Discount Management:** No tools for managing discounts for each course.
* **Category Management:** Managing event categories is no longer a core function of this project.
* **Enrollment & Payment Processing:** Reviewing applications or validating manual payments.
* **Post-Event Attendance:** Loading and managing attendance records.


##  Implemented Use Cases

| ID | Name | Description |
| :--- | :--- | :--- |
| **CU-GE-001** | **Create Event** | Create new events or clone previous ones to reuse configurations. |
| **CU-GE-002** | **Consult Events** | Search and filter the list of registered events. |
| **CU-GE-003** | **Modify Event** | Update information for existing events (dates, modality, etc.). |
| **CU-GE-004** | **Archive Event** | Move events to a historical state; triggers cancellation if active. |
| **CU-GE-025** | **Cancel Event** | Formally cancel events.|

## Non-Functional Requirements

|     Requirement                                                                              |     Usability Attribute            |     Metric                                                             |
|----------------------------------------------------------------------------------------------|------------------------------------|------------------------------------------------------------------------|
| System pre-fills ~90% of fields when cloning an event, highlighting only variable fields.    |     Efficiency                     | Pre-fill rate ≥90%. Time to complete clone < 2 minutes.                |
| Primary event list displays ≥10 records on a 1080p screen without vertical scrolling.        |     Efficiency                     | Visible rows ≥10%.                                                     |
| Event statuses use high-contrast color codes for instant recognition.                        |     Visibility of System Status    | Identification accuracy ≥90%. Avg response time < 2 seconds.           |
| Typing filters the event list in real time.                                                  |     Efficiency / Findability       | Response time < 300 ms for   1,000 events. User satisfaction (1–5).    |
| Error messages use plain administrative language.                                            |     Error Recovery                 | Correct understanding ≥80%. Support requests near zero.                |
| Invalid inputs flagged before submission.                                                    |     Error Prevention               | Error prevention rate ≥95%.                                            |
| All screens share identical layout, icons, and button placement.                             |     Consistency / Learnability     | Visual consistency score (yes/no). Task time ±10%.                     |
| Hoverable info icons explain ambiguous fields.                                               |     Learnability                   | Help usage rate (%). Task confidence (1–5) before/after.               |

## UX Testing and Validation Methodology

#### Objective
The goal is to validate that the system enables staff to manage the lifecycle of 15-20 simultaneous programs (events) with high speed and zero data loss. Testing will ensure the digital workflow matches or exceeds the efficiency of the current administrative methods.

#### Iterative Cycle
We follow a lean UX process to refine the user experience:
* **Think (Context & Requirements):** We begin by defining assumptions based on the coordinators' actual workflow.
* **Make (AI-Driven Prototyping):** We accelerate the "Design Solutions" phase by using **AI-generated high-fidelity prototypes**.
* **Check (Tangible Validation):** We can then validate the functional prototype with our end user.

[Click here for more information about our approach to UCD and how the team is organizing](https://github.com/hjanssena/hci-proyecto/blob/97920b055d7ff2ed91a164167daa1bf3a51b1894/user-centered-design.md)

[Click here to go to our Github Project](https://github.com/users/hjanssena/projects/4)
