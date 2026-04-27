### API Testing Commands (cURL)

**Note:** Ensure your Django development server is running (`python manage.py runserver`) before executing these commands. Estas pruebas asumen que el servidor está en `http://localhost:8000` y utilizan los IDs generados por el script `seed_data`.

#### 1. Events Module

**List all events:**
```bash
curl -X GET http://localhost:8000/api/v1/events/
```

**Search events (Testing the "search-as-you-type" feature for "Finanzas"):**
```bash
curl -X GET "http://localhost:8000/api/v1/events/?search=Finanzas"
```

**Create a new event:**
```bash
curl -X POST http://localhost:8000/api/v1/events/ \
-H "Content-Type: application/json" \
-d '{
    "name": "Seminario de Ciberseguridad",
    "category": 2,
    "description": "Introducción al hacking ético y seguridad en redes.",
    "start_date": "2026-05-01",
    "end_date": "2026-05-15",
    "schedule": "Viernes 18:00 - 20:00",
    "duration_hours": 20,
    "modality": "VI",
    "location_or_link": "[https://zoom.us/j/ciberseguridad](https://zoom.us/j/ciberseguridad)",
    "max_capacity": 40,
    "min_inscriptions": 10,
    "price": "1200.00",
    "accreditation_requirements": "Aprobar el examen práctico final."
}'
```

**Cancel an event (Testing the custom action on Event ID 2):**
```bash
curl -X POST http://localhost:8000/api/v1/events/2/cancel/ \
-H "Content-Type: application/json" \
-d '{"reason": "Problemas técnicos con la plataforma de streaming."}'
```

#### 2. Enrollments Module

**List all pending enrollments:**
```bash
curl -X GET "http://localhost:8000/api/v1/enrollments/?status=PE"
```

**Approve an enrollment (Testing Enrollment ID 2):**
```bash
curl -X POST http://localhost:8000/api/v1/enrollments/2/approve/
```

#### 3. Payments Module

**Confirm a manual payment (Testing Payment ID 2):**
```bash
curl -X POST http://localhost:8000/api/v1/payments/2/confirm/
```

**Reject a payment (Testing the error handling for a missing reason):**
```bash
curl -X POST http://localhost:8000/api/v1/payments/2/reject/ \
-H "Content-Type: application/json" \
-d '{}'
```

#### 4. Attendance Module

**Download the Excel Attendance Template for Event ID 1:**
*(Uses the `--output` flag to save the incoming binary stream directly to a file)*
```bash
curl -X GET http://localhost:8000/api/v1/events/1/attendance_template/ --output plantilla_prueba.xlsx
```

**Upload and parse an attendance document:**
*(Simulates the multipart/form-data upload using the `-F` flag)*
```bash
curl -X POST http://localhost:8000/api/v1/attendance-documents/ \
-F "event=1" \
-F "file=@media/samples/asistencia.xlsx"
```
