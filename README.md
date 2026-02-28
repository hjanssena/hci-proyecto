
# Continuous Education Management System - FCA

### Team
* Hugo de Jesús Janssen Aguilar
* Jesse Oswaldo Martin Jimenez
* Waldo Camara Villacis
* Jose Elias Novelo Collí

##  Project Overview
This system is an internal administrative platform designed for the **Staff of the FCA Continuous Education Department**. It streamlines the lifecycle of educational events, from initial creation and categorization to the management of participant applications, attendance, and financial resolutions.

The platform centralizes administrative tasks, replacing manual tracking with a digital workflow to manage courses, workshops and diplomas.

Click here for more information about the project

##  Target User
* **FCA Continuous Education Staff (Coordinators):** Users responsible for setting up the educational offer, reviewing applicant documentation, confirming registrations, and managing post-event data.

Click here to see our Persona specification

##  Project Scope

### **Core Features (Implemented)**
* **Event Lifecycle Management:**
    * Creation of events from scratch or by cloning previous ones.
    * Modification of event details like teachers, dates, and modalities.
    * Archiving events for historical reporting.
    * Formal cancellation with automated voucher/refund workflows.
* **Category Management:**
    * Standardization of event types (e.g., "Diplomado", "Taller").
    * Full management (CRUD) and archiving of categories.
* **Enrollment & Payment Operations:**
    * Reviewing and approving/rejecting enrollment requests.
    * Manual validation of bank transfers and cash deposits.
* **Post-Event Administration:**
    * Loading and managing attendance records for concluded events.

### **Out of Scope**
* **Public Portal:** No external interface for student self-registration or automated payment gateways.
* **Instructor Tools:** No dedicated views for instructors to check payment details or assigned courses.
* **Certification:** Automated generation of participant or instructor certificates is not supported.
* **Discount Management:** No tools for managing discounts for each course.


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
| **CU-GE-016** | **Manage Attendance** | Upload attendance records for events that have concluded. |
| **CU-GE-025** | **Cancel Event** | Formally cancel events and process vouchers or refunds. |

## Non-Functional Requirements

| Requirement | Related Functional Requirements | Usability Attribute |
| :--- | :--- | :--- |
| The system shall pre-fill approximately 90% of fields when cloning an event, visually highlighting only the mandatory variable fields (e.g., dates, instructors) to minimize data entry effort. | **CU-GE-001** (Create Event) | Efficiency / Cognitive Load |
| The primary administrative interface shall utilize a compact, tabular design capable of displaying at least 10 simultaneous records on a 1080p resolution without requiring vertical scrolling. | **CU-GE-002** (Consult Events) | Visibility / Accessibility |
| All event and enrollment records shall feature high-contrast, color-coded visual indicators (e.g., "Pending," "Confirmed," "Archived") to allow for immediate identification of record status. | **CU-GE-009** (Manage Enrollment), **CU-GE-010** (Validate Payments) | Memorability / Perception |
| The system shall provide "search-as-you-type" functionality across event and category lists to facilitate rapid retrieval of historical and active data. | **CU-GE-002** (Consult Events), **CU-GE-013** (Consult Categories) | Efficiency / Findability |
| System errors shall be presented in natural administrative language (e.g., "Instructor schedule conflict") rather than technical or numeric codes to facilitate self-correction. | **All CRUD Operations** | Error Recovery |
| The system shall provide real-time visual feedback for data entry errors (e.g., incorrect date formats or duplicate vouchers) at the field level before form submission. | **CU-GE-003** (Modify Event), **CU-GE-010** (Validate Payments) | Error Prevention |
| All administrative modules shall utilize a standardized UI library for CRUD operations, ensuring identical button placements, icon sets, and interaction patterns. | **CU-GE-012, 014, 015** (Category Management) | Consistency / Learnability |
| Hoverable information icons shall be present for complex tasks (e.g., attendance file uploads) to explain specific data formats and process requirements. | **CU-GE-016** (Manage Attendance) | Learnability / Help |

## UX Testing and Validation Methodology

#### Objective
The goal is to validate that the system enables staff to manage 15-20 simultaneous programs with high speed and zero data loss. Testing will ensure the digital workflow matches or exceeds the efficiency of the current administrative methods.

#### Iterative Cycle
We follow a lean UX process to refine the user experience:
* **Think (Context & Requirements):** We begin by defining assumptions based on the coordinators' actual workflow.
* **Make (AI-Driven Prototyping):** We accelerate the "Design Solutions" phase by using **AI-generated high-fidelity prototypes**.
* **Check (Tangible Validation):** We can then validate the functional prototype with our end user.

Click here for more information about our UCD approach.
