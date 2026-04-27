
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
| **CU-GE-009** | **Manage Enrollment** | Review applicant documents and approve/reject participants. |
| **CU-GE-010** | **Validate Manual Payments** | Verify external transfers/deposits to confirm inscriptions. |
| **CU-GE-012** | **Create Category** | Define new classifications like "Diplomado" or "Curso". |
| **CU-GE-013** | **Consult Categories** | View all active and archived event categories. |
| **CU-GE-014** | **Modify Category** | Edit category names or change their status. |
| **CU-GE-015** | **Archive Category** | Disable categories from future use while maintaining history. |
| **CU-GE-025** | **Cancel Event** | Formally cancel events and process vouchers or refunds. |

## Non-Functional Requirements

| Requirement | Related Functional Requirements | ISO 25010 Usability Attribute | Verification Metric |
| :--- | :--- | :--- | :--- |
| The system shall pre-fill approximately 90% of fields when cloning an event, visually highlighting only the mandatory variable fields (e.g., dates, instructors) to minimize data entry effort. | **CU-GE-001** (Create Event) | **Operability** | Automated form audit: at least 90% of fields are pre-filled on clone; task completion time for cloning ≤ 2 minutes in usability test with 5 representative users. |
| The primary administrative interface shall utilize a compact, tabular design capable of displaying at least 10 simultaneous records on a 1080p resolution without requiring vertical scrolling. | **CU-GE-002** (Consult Events) | **Accessibility** | Browser rendering test at 1920×1080: measure visible rows without scrolling; acceptance threshold ≥ 10 rows. |
| All event and enrollment records shall feature high-contrast, color-coded visual indicators (e.g., "Pending," "Confirmed," "Archived") to allow for immediate identification of record status. | **CU-GE-009** (Manage Enrollment), **CU-GE-010** (Validate Payments) | **Appropriateness Recognizability** | User test: ≥ 90% of participants correctly identify the status of a record within 5 seconds without guidance; color contrast ratio meets WCAG 2.1 AA (≥ 4.5:1). |
| The system shall provide "search-as-you-type" functionality across event and category lists to facilitate rapid retrieval of historical and active data. | **CU-GE-002** (Consult Events), **CU-GE-013** (Consult Categories) | **Operability** | Functional test: results appear within 300 ms of each keystroke across a dataset of ≥ 500 records; user locates a target record in ≤ 30 seconds in usability test. |
| System errors shall be presented in natural administrative language (e.g., "Instructor schedule conflict") rather than technical or numeric codes to facilitate self-correction. | **All CRUD Operations** | **User Error Protection** | Expert review: 100% of error messages reviewed against plain-language checklist; user test: ≥ 80% of participants self-correct after reading an error message without external help. |
| The system shall provide real-time visual feedback for data entry errors (e.g., incorrect date formats or duplicate vouchers) at the field level before form submission. | **CU-GE-003** (Modify Event), **CU-GE-010** (Validate Payments) | **User Error Protection** | Automated test: inline validation triggers within 500 ms of focus-out on invalid fields; 0% of invalid forms successfully submitted in regression tests. |
| All administrative modules shall utilize a standardized UI library for CRUD operations, ensuring identical button placements, icon sets, and interaction patterns. | **CU-GE-012, 014, 015** (Category Management) | **Learnability** | UI audit: 100% of CRUD screens share identical primary-action button position and icon set; first-time task success rate ≥ 85% without training in usability test with new users. |

### ISO 25010 Usability Attribute Definitions

| Attribute | Definition |
| :--- | :--- |
| **Operability** | Degree to which a product or system has attributes that make it easy to operate and control. |
| **Accessibility** | Degree to which a product or system can be used by people with the widest range of characteristics and capabilities to achieve a specified goal in a specified context of use. |
| **Appropriateness Recognizability** | Degree to which users can recognize whether a product or system is appropriate for their needs. |
| **User Error Protection** | Degree to which a system protects users against making errors. |
| **Learnability** | Degree to which a product or system can be used by specified users to achieve specified goals of learning to use the product or system with effectiveness, efficiency, freedom from risk, and satisfaction in a specified context of use. |

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
