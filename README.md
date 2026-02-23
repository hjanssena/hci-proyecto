
# Continuous Education Management System - FCA

### Team
* Hugo de Jesús Janssen Aguilar
* Jesse Oswaldo Martin Jimenez
* Waldo Camara Villacis
* Jose Elias Novelo Collí

##  Project Overview
This system is an internal administrative platform designed for the **Staff of the FCA Continuous Education Department**. It streamlines the lifecycle of educational events, from initial creation and categorization to the management of participant applications, attendance, and financial resolutions.

The platform centralizes administrative tasks, replacing manual tracking with a digital workflow to manage courses, workshops and diplomas.


##  Target User
* **FCA Continuous Education Staff (Coordinators):** Users responsible for setting up the educational offer, reviewing applicant documentation, confirming registrations, and managing post-event data.


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


