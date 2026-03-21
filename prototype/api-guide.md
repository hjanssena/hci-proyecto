# FCA Continuous Education API
## Events Module

Base URL: `/api/v1/events/`

This API handles the core lifecycle of educational events, supporting the primary administrative tasks for the FCA Continuous Education Staff.

## Standard Operations

### 1. List & Search Events (CU-GE-002)
Retrieves a paginated list of all events, ordered by `start_date` descending.

* **Endpoint:** `GET /api/v1/events/`
* **Query Parameters:**
  * `search`: Performs a "search-as-you-type" query against the event `name`.
  * `status`: Filters by exact status (e.g., `?status=IN` for "En fase de inscripciones").
  * `modality`: Filters by modality (e.g., `?modality=PR` for "Presencial").
* **Response:** `200 OK` with an array of event objects.

### 2. Retrieve a Single Event
Fetches the full details of a specific event. This endpoint is also used by the frontend to fetch data for "cloning" an event.

* **Endpoint:** `GET /api/v1/events/{id}/`
* **Response:** `200 OK` with the event object.

### 3. Create Event (CU-GE-001)
Creates a new event. The system forces the initial status to "En fase de inscripciones". 

* **Endpoint:** `POST /api/v1/events/`
* **Payload Fields:**
  * `name` *(string, required)*: Nombre del evento.
  * `category` *(integer, required)*: ID of the selected category.
  * `description` *(string, required)*: Descripción general.
  * `start_date` *(string YYYY-MM-DD, required)*: Fecha de inicio.
  * `end_date` *(string YYYY-MM-DD, required)*: Fecha de fin.
  * `schedule` *(string, required)*: Horario del evento.
  * `duration_hours` *(integer, required)*: Duración en horas.
  * `modality` *(string, required)*: `PR` (Presencial), `VI` (Virtual), or `HY` (Híbrida).
  * `location_or_link` *(string, required)*: Aula o enlace de acceso.
  * `max_capacity` *(integer, required)*: Capacidad máxima.
  * `min_inscriptions` *(integer, required)*: Cantidad mínima de inscripciones requeridas.
  * `price` *(decimal, required)*: Importe o precio base.
  * `accreditation_requirements` *(string, required)*: Requisitos de acreditación.
  * `epc_points` *(boolean, optional)*: Puntos EPC. Defaults to `false`.
  * `by_contract` *(boolean, optional)*: Por contrato. Defaults to `false`.
  * `with_organization` *(string, optional)*: Con organización. Can be null/blank.

*(Note: `status`, `cancellation_reason`, and `cancellation_date` are generated or managed by the system and will be ignored if sent in the payload).*

* **Response:** `201 Created` with the new event object.

### 4. Update Event (CU-GE-003)
Modifies an existing event's details. 

* **Endpoint:** `PUT /api/v1/events/{id}/` (Full update, all required fields from POST must be included) or `PATCH /api/v1/events/{id}/` (Partial update, only send the fields you want to change).
* **Payload:** Same fields as the POST request. Protected fields (`status`, `cancellation_reason`, `cancellation_date`) cannot be directly updated through this endpoint.
* **Response:** `200 OK` with the updated event object.

---

## Custom Actions

### 5. Archive Event (CU-GE-004)
Archives an event to hide it from active lists while preserving historical data. If the event has active enrollments, the system automatically converts this action into a Cancellation workflow.

* **Endpoint:** `POST /api/v1/events/{id}/archive/`
* **Payload:** None required.
* **Responses:**
  * `200 OK` (Archived successfully): `{"detail": "Evento archivado exitosamente."}`
  * `200 OK` (Converted to Cancelled due to active enrollments): `{"detail": "El evento tenía inscripciones activas. Su estado ha cambiado a 'Cancelado' y se notificará a los usuarios."}`
  * `400 Bad Request`: If the event is already archived.

### 6. Cancel Event (CU-GE-025)
Formally cancels an event. This triggers the notification system. Participants can then choose between a discount voucher or a refund.

* **Endpoint:** `POST /api/v1/events/{id}/cancel/`
* **Payload:** json
```
  
  {
    "reason": "El profesor titular reportó incapacidad médica."
  }
```
  _(Note: The `reason` field is mandatory to complete the cancellation)_

* **Responses:**

  * `200 OK`: `{"detail": "Evento cancelado exitosamente. Se ha notificado a los participantes."}`

  * `400 Bad Request`: If the `reason` is missing, or if the event is already cancelled.

---

## Categories Module

Base URL: `/api/v1/categories/`

This module manages the classification of educational events (e.g., "Diplomado", "Taller"). Categories can be created, modified, and archived, but they cannot be archived if they are currently assigned to active events.

## Standard Operations

### 1. List & Search Categories (CU-GE-013)
Retrieves a list of all categories.

* **Endpoint:** `GET /api/v1/categories/`
* **Query Parameters:**
  * `search`: Performs a "search-as-you-type" query against the category `name`.
  * `is_active`: Filters by status (e.g., `?is_active=true` for active categories, `?is_active=false` for archived).
* **Response:** `200 OK` with an array of category objects.

### 2. Retrieve a Single Category
Fetches the details of a specific category.

* **Endpoint:** `GET /api/v1/categories/{id}/`
* **Response:** `200 OK` with the category object.

### 3. Create Category (CU-GE-012)
Creates a new category. By default, newly created categories are active.

* **Endpoint:** `POST /api/v1/categories/`
* **Payload Fields:**
  * `name` *(string, required)*: El nombre de la nueva categoría (ejemplo: "Diplomado"). Must be unique.
  * `is_active` *(boolean, optional)*: Defaults to `true`.
* **Responses:**
  * `201 Created` with the new category object.
  * `400 Bad Request` if the name is empty, exceeds length, or already exists.

### 4. Update Category (CU-GE-014)
Modifies an existing category's name or status.

* **Endpoint:** `PUT /api/v1/categories/{id}/` or `PATCH /api/v1/categories/{id}/`
* **Payload Fields:**
  * `name` *(string, optional in PATCH)*: The updated name. Must be unique.
  * `is_active` *(boolean, optional in PATCH)*: The updated status.
* **Responses:**
  * `200 OK` with the updated category object.
  * `400 Bad Request` if attempting to change `is_active` to `false` while active events are still linked to this category.

---

## Custom Actions

### 5. Archive Category (CU-GE-015)
A dedicated endpoint to archive a category, removing it from active assignment options while preserving historical links. 

* **Endpoint:** `POST /api/v1/categories/{id}/archive/`
* **Payload:** None required.
* **Responses:**
  * `200 OK`: `{"detail": "Categoría archivada exitosamente."}`
  * `400 Bad Request`: `{"error": "La categoría está siendo utilizada por uno o más eventos activos. Reasigne los eventos antes de archivarla."}`.

---

## Enrollments Module

Base URL: `/api/v1/enrollments/`

This module manages participant applications, allowing coordination staff to review documents and either approve, reject, or request more information.

## Standard Operations

### 1. List & Search Enrollments (CU-GE-009)
Retrieves a list of enrollment applications.

* **Endpoint:** `GET /api/v1/enrollments/`
* **Query Parameters:**
  * `search`: Performs a "search-as-you-type" query against the `applicant_name`.
  * `event`: Filters applications by a specific event ID.
  * `status`: Filters by application status (e.g., `?status=PE` for "Pendiente de Revisión" or `?status=IR` for "Información Requerida").
* **Response:** `200 OK` with an array of enrollment objects.

### 2. Retrieve a Single Enrollment
Fetches the full details of a specific application, including the uploaded document link.

* **Endpoint:** `GET /api/v1/enrollments/{id}/`
* **Response:** `200 OK` with the enrollment object.

---

## Custom Actions (Workflow Processing)

### 3. Approve Enrollment
Approves an application. The system will block the approval if the event has reached its maximum capacity.

* **Endpoint:** `POST /api/v1/enrollments/{id}/approve/`
* **Payload:** None required.
* **Responses:**
  * `200 OK`: `{"detail": "Solicitud aprobada exitosamente. El usuario ha sido notificado."}`.
  * `400 Bad Request`: `{"error": "El evento ha alcanzado su límite de cupo y no permite la aprobación."}`.
  * `400 Bad Request`: If the application is already processed.

### 4. Reject Enrollment
Rejects an application. A specific reason must be provided.

* **Endpoint:** `POST /api/v1/enrollments/{id}/reject/`
* **Payload Fields:**
  * `reason` *(string, required)*: El motivo de rechazo.
* **Responses:**
  * `200 OK`: `{"detail": "Solicitud rechazada exitosamente."}`.
  * `400 Bad Request`: If the `reason` is missing or if the application is already processed.

### 5. Request More Information
Flags the application as needing more documentation or clarification from the applicant.

* **Endpoint:** `POST /api/v1/enrollments/{id}/request_info/`
* **Payload Fields:**
  * `details` *(string, required)*: El detalle de la información requerida.
* **Responses:**
  * `200 OK`: `{"detail": "Se ha solicitado más información al usuario."}`.
  * `400 Bad Request`: If `details` are missing or if the application is already processed.

---

## Payments Module

Base URL: `/api/v1/payments/`

This module allows the coordination staff to review and validate manual payments (e.g., bank transfers, cash deposits) associated with enrollments.

## Standard Operations

### 1. List & Search Payments
Retrieves a list of payment records. 

* **Endpoint:** `GET /api/v1/payments/`
* **Query Parameters:**
  * `search`: Performs a "search-as-you-type" query against the applicant's name.
  * `enrollment__event`: Filters payments by a specific event ID.
  * `status`: Filters by payment status (e.g., `?status=PE` for "Pendiente de Verificación de Pago").
* **Response:** `200 OK` with an array of payment objects. Includes nested `applicant_name` and `event_name` for easy UI rendering.

### 2. Retrieve a Single Payment
Fetches the full details of a specific payment, including the URL to download the uploaded payment voucher (`proof_of_payment`).

* **Endpoint:** `GET /api/v1/payments/{id}/`
* **Response:** `200 OK` with the payment object.

---

## Custom Actions (Workflow Processing)

### 3. Confirm Payment
Confirms that the manual payment has been verified. Updates the status to "Confirmada".

* **Endpoint:** `POST /api/v1/payments/{id}/confirm/`
* **Payload:** None required.
* **Responses:**
  * `200 OK`: `{"detail": "Pago confirmado exitosamente. El participante ha sido notificado."}`.
  * `400 Bad Request`: `{"error": "El pago ya está confirmado."}` (Prevents duplicate processing).

### 4. Reject Payment
Rejects a payment if the transfer cannot be found or the amount is incorrect. Updates the status to "Pago Rechazado".

* **Endpoint:** `POST /api/v1/payments/{id}/reject/`
* **Payload Fields:**
  * `reason` *(string, required)*: El motivo de rechazo (e.g., "Monto incorrecto", "Transferencia no reflejada").
* **Responses:**
  * `200 OK`: `{"detail": "Pago rechazado exitosamente. Se ha notificado al participante."}`.
  * `400 Bad Request`: If `reason` is missing, or if attempting to reject an already confirmed payment.

### 5. Request Voucher
Notifies the participant to upload their payment voucher if they haven't done so yet.

* **Endpoint:** `POST /api/v1/payments/{id}/request_voucher/`
* **Payload:** None required.
* **Responses:**
  * `200 OK`: `{"detail": "Se ha notificado al participante para que cargue el comprobante."}`.

---
   
## Attendance Module

Base URL: `/api/v1/`

This module allows the coordination staff to manage and load attendance records for concluded events. It includes a workflow to download a pre-filled template and upload the completed file for automatic parsing.

## 1. Attendance Workflow

### Step 1: Download Attendance Template
Generates and downloads a pre-formatted Excel (`.xlsx`) template for a specific event. The file includes instructions and a pre-filled list of participants whose enrollment status is "Aprobada".

* **Endpoint:** `GET /api/v1/events/{id}/attendance_template/`
* **Response:** `200 OK` 
  * **Content-Type:** `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
  * **Behavior:** Triggers a file download named `Plantilla_Asistencia_Evento_{id}.xlsx`.

### Step 2: Upload & Parse Attendance Document (CU-GE-016)
Uploads the completed Excel (`.xlsx`) or CSV (`.csv`) attendance file. The system automatically reads the file, normalizes the data, and populates the individual attendance records for the event.

* **Endpoint:** `POST /api/v1/attendance-documents/`
* **Headers:** `Content-Type: multipart/form-data`
* **Payload Fields (Form Data):**
  * `event` *(integer, required)*: El ID del evento al que pertenece el documento.
  * `file` *(file, required)*: El archivo físico a cargar.
* **Responses:**
  * `201 Created`: When the document is successfully uploaded and parsed.
    ```json
    {
      "detail": "Asistencias cargadas exitosamente. Se procesaron 15 registros.",
      "document": {
        "id": 1,
        "event": 5,
        "event_name": "Diplomado en Finanzas",
        "file": "[http://domain.com/media/attendance_docs/file.xlsx](http://domain.com/media/attendance_docs/file.xlsx)",
        "uploaded_at": "2026-03-09T10:00:00Z"
      }
    }
    ```
  * `400 Bad Request`: If the event has not concluded, if the file format is unsupported, or if parsing fails (Excepción B).

---

## 2. Read-Only Consultations

### List Uploaded Documents
Retrieves a history of all uploaded physical attendance documents.

* **Endpoint:** `GET /api/v1/attendance-documents/`
* **Query Parameters:**
  * `event`: Filters documents by a specific event ID.
* **Response:** `200 OK` with a paginated array of document objects.

### Consult Individual Attendance Records
Retrieves the granular, row-by-row list of participants and their parsed attendance status.

* **Endpoint:** `GET /api/v1/attendance-records/`
* **Query Parameters:**
  * `event`: Filters records by a specific event ID.
  * `attended`: Filters by attendance status (`?attended=true` or `?attended=false`).
  * `search`: Searches by `participant_name`.
* **Response:** `200 OK` with a paginated array of individual attendance records.