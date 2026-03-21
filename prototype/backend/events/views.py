from rest_framework import viewsets, status
from rest_framework.decorators import action
from django.db import transaction
from rest_framework.response import Response
from rest_framework.filters import SearchFilter
from django_filters.rest_framework import DjangoFilterBackend
from .models import Attendance, Category, Event, Enrollment, Payment, AttendanceDocument, Attendance
from .serializers import AttendanceSerializer, CategorySerializer, EnrollmentSerializer, EventSerializer, PaymentSerializer, AttendanceDocumentSerializer, AttendanceSerializer
from django.utils import timezone
from rest_framework.parsers import MultiPartParser, FormParser

class EventViewSet(viewsets.ModelViewSet):
    queryset = Event.objects.all().order_by('-start_date')
    serializer_class = EventSerializer
    
    # Enables the "search-as-you-type" functionality and filtering
    filter_backends = [DjangoFilterBackend, SearchFilter]
    filterset_fields = ['status', 'modality'] 
    search_fields = ['name'] 

    def perform_create(self, serializer):
        """
        CU-GE-001: Creates a new event.
        Forces the initial status to "En fase de inscripciones" as required.
        """
        serializer.save(status=Event.Status.INSCRIPTIONS)

    # CU-GE-002 (Read) and CU-GE-003 (Update) are handled natively by DRF 
    # via the list(), retrieve(), update(), and partial_update() methods.

    @action(detail=True, methods=['post'])
    def archive(self, request, pk=None):
        """
        CU-GE-004: Archive Event.
        """
        event = self.get_object()

        if event.status == Event.Status.ARCHIVED:
            return Response(
                {"detail": "El evento ya se encuentra archivado."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        # Alternativa B: Check if there are active enrollments
        has_active_enrollments = event.enrollments.filter(
            status__in=[Enrollment.Status.PENDING, Enrollment.Status.APPROVED]
        ).exists()

        if has_active_enrollments:
            # Changes status to canceled if it has active inscriptions
            event.status = Event.Status.CANCELED
            event.cancellation_reason = "Cancelado automáticamente al intentar archivar con inscripciones activas."
            event.save()
            # Note: The signals.py we wrote earlier will catch this save() and trigger notifications!
            return Response(
                {"detail": "El evento tenía inscripciones activas. Su estado ha cambiado a 'Cancelado' y se notificará a los usuarios."}, 
                status=status.HTTP_200_OK
            )

        # Happy Path: Mark as archived
        event.status = Event.Status.ARCHIVED
        event.save()
        return Response({"detail": "Evento archivado exitosamente."}, status=status.HTTP_200_OK)

    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        """
        CU-GE-025: Cancel Event.
        Requires a cancellation reason from the request body.
        """
        event = self.get_object()
        reason = request.data.get('reason', '').strip()

        if not reason:
            return Response(
                {"error": "Debe proporcionar un motivo de cancelación."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        if event.status == Event.Status.CANCELED:
            return Response(
                {"detail": "El evento ya se encuentra cancelado."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        # Update event data
        event.status = Event.Status.CANCELED
        event.cancellation_reason = reason
        event.save() 
        # Again, signals.py will intercept this and prepare the voucher/refund workflow

        return Response(
            {"detail": "Evento cancelado exitosamente. Se ha notificado a los participantes."}, 
            status=status.HTTP_200_OK
        )
    
    @action(detail=True, methods=['get'])
    def attendance_template(self, request, pk=None):
        """
        Generates and serves a pre-formatted Excel template for attendance tracking.
        Pre-fills the 'Participante' column with approved applicants.
        """
        event = self.get_object()

        # Retrieve participants whose enrollment was approved
        approved_participants = event.enrollments.filter(
            status=Enrollment.Status.APPROVED
        ).values_list('applicant_name', flat=True)

        # Create a new Excel workbook and select the active worksheet
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "Lista de Asistencia"

        # 1. Add the Explanatory Header
        instructions = [
            "INSTRUCCIONES DE LLENADO PARA COORDINACIÓN:",
            "- Columna 'Participante': Contiene los nombres de los alumnos inscritos (no modificar).",
            "- Columna 'Asistio': Escriba 'Si', '1', o 'True' si el alumno asistió.",
            "- Si el alumno faltó, deje la celda en blanco o escriba 'No', '0', o 'False'."
        ]

        for row_num, text in enumerate(instructions, start=1):
            cell = ws.cell(row=row_num, column=1, value=text)
            cell.font = Font(italic=True, color="00555555")
            # Merge columns A and B for the instruction rows so the text doesn't bleed weirdly
            ws.merge_cells(start_row=row_num, start_column=1, end_row=row_num, end_column=2)

        # 2. Add the Table Headers
        header_row_num = len(instructions) + 2
        
        participant_header = ws.cell(row=header_row_num, column=1, value="Participante")
        participant_header.font = Font(bold=True)
        
        attended_header = ws.cell(row=header_row_num, column=2, value="Asistio")
        attended_header.font = Font(bold=True)

        # 3. Populate the Participants
        current_row = header_row_num + 1
        for participant_name in approved_participants:
            ws.cell(row=current_row, column=1, value=participant_name)
            current_row += 1

        # 4. Format Column Widths for readability
        ws.column_dimensions['A'].width = 50  # Wide enough for full names
        ws.column_dimensions['B'].width = 15  # Wide enough for "Si"/"No"

        # 5. Prepare the HTTP Response as an Excel attachment
        response = HttpResponse(
            content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )
        # Create a safe filename using the event's ID
        filename = f"Plantilla_Asistencia_Evento_{event.id}.xlsx"
        response['Content-Disposition'] = f'attachment; filename="{filename}"'
        
        # Save the workbook directly to the response
        wb.save(response)

        return response
    
class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all().order_by('name')
    serializer_class = CategorySerializer
    
    # Enables search by name and filtering by active/archived status
    filter_backends = [DjangoFilterBackend, SearchFilter]
    filterset_fields = ['is_active']
    search_fields = ['name']

    def update(self, request, *args, **kwargs):
        """
        CU-GE-014: Modificar Categoría de Evento
        Prevents changing 'is_active' to False if there are active events.
        """
        instance = self.get_object()
        is_active_payload = request.data.get('is_active')
        
        # Check if the request is attempting to archive the category
        if is_active_payload is False or str(is_active_payload).lower() == 'false':
            # Identify if there are events using this category that are not archived or canceled
            active_events = instance.event_set.filter(
                status__in=[Event.Status.INSCRIPTIONS, Event.Status.CONFIRMED]
            ).exists()
            
            if active_events:
                return Response(
                    {"error": "El cambio de estado a 'Archivada' no puede completarse porque existen eventos activos asociados."},
                    status=status.HTTP_400_BAD_REQUEST
                )
                
        return super().update(request, *args, **kwargs)

    @action(detail=True, methods=['post'])
    def archive(self, request, pk=None):
        """
        CU-GE-015: Archivar Categoría
        Dedicated endpoint to archive a category.
        """
        category = self.get_object()

        if not category.is_active:
            return Response(
                {"detail": "La categoría ya se encuentra archivada."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check for active events before archiving
        active_events = category.event_set.filter(
            status__in=[Event.Status.INSCRIPTIONS, Event.Status.CONFIRMED]
        ).exists()

        if active_events:
            return Response(
                {"error": "La categoría está siendo utilizada por uno o más eventos activos. Reasigne los eventos antes de archivarla."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Archive the category
        category.is_active = False
        category.save()
        return Response(
            {"detail": "Categoría archivada exitosamente."}, 
            status=status.HTTP_200_OK
        )
    
class EnrollmentViewSet(viewsets.ModelViewSet):
    queryset = Enrollment.objects.all().order_by('-id')
    serializer_class = EnrollmentSerializer
    
    filter_backends = [DjangoFilterBackend, SearchFilter]
    # Allows filtering by specific event or by status (e.g., to find "Pendientes")
    filterset_fields = ['event', 'status']
    search_fields = ['applicant_name']

    def _check_processable(self, enrollment):
        """Helper to verify if a request can be processed (Exception C)"""
        valid_statuses = [Enrollment.Status.PENDING, Enrollment.Status.INFO_REQUIRED]
        if enrollment.status not in valid_statuses:
            return False, f"La solicitud ya ha sido procesada. Estado actual: {enrollment.get_status_display()}"
        return True, ""

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        """
        CU-GE-009: Aprobar Solicitud
        """
        enrollment = self.get_object()
        
        can_process, msg = self._check_processable(enrollment)
        if not can_process:
            return Response({"error": msg}, status=status.HTTP_400_BAD_REQUEST)

        # Check event capacity (Exception B)
        event = enrollment.event
        current_approved = event.enrollments.filter(status=Enrollment.Status.APPROVED).count()
        
        if current_approved >= event.max_capacity:
            return Response(
                {"error": "El evento ha alcanzado su límite de cupo y no permite la aprobación."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        enrollment.status = Enrollment.Status.APPROVED
        enrollment.save()
        
        # Here you would trigger the notification:
        # send_approval_notification(enrollment)

        return Response({"detail": "Solicitud aprobada exitosamente. El usuario ha sido notificado."}, status=status.HTTP_200_OK)

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        """
        CU-GE-009: Rechazar Solicitud
        """
        enrollment = self.get_object()
        reason = request.data.get('reason', '').strip()

        can_process, msg = self._check_processable(enrollment)
        if not can_process:
            return Response({"error": msg}, status=status.HTTP_400_BAD_REQUEST)

        if not reason:
            return Response(
                {"error": "Debe proporcionar un motivo de rechazo."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        enrollment.status = Enrollment.Status.REJECTED
        enrollment.rejection_reason = reason
        enrollment.save()

        # Trigger notification:
        # send_rejection_notification(enrollment, reason)

        return Response({"detail": "Solicitud rechazada exitosamente."}, status=status.HTTP_200_OK)

    @action(detail=True, methods=['post'])
    def request_info(self, request, pk=None):
        """
        CU-GE-009: Solicitar Más Información
        """
        enrollment = self.get_object()
        details = request.data.get('details', '').strip()

        can_process, msg = self._check_processable(enrollment)
        if not can_process:
            return Response({"error": msg}, status=status.HTTP_400_BAD_REQUEST)

        if not details:
            return Response(
                {"error": "Debe proporcionar el detalle de la información requerida."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        enrollment.status = Enrollment.Status.INFO_REQUIRED
        enrollment.save()

        # Trigger notification sending the requested 'details' to the user:
        # send_info_required_notification(enrollment, details)

        return Response({"detail": "Se ha solicitado más información al usuario."}, status=status.HTTP_200_OK)
    
class PaymentViewSet(viewsets.ModelViewSet):
    queryset = Payment.objects.all().order_by('-id')
    serializer_class = PaymentSerializer
    
    filter_backends = [DjangoFilterBackend, SearchFilter]
    # Filter by status to easily find "Pendiente de Verificación de Pago"
    filterset_fields = ['status', 'enrollment__event']
    search_fields = ['enrollment__applicant_name']

    def _check_already_confirmed(self, payment):
        """Helper to prevent duplicate confirmations (Exception B)"""
        if payment.status == Payment.Status.CONFIRMED:
            return True
        return False

    @action(detail=True, methods=['post'])
    def confirm(self, request, pk=None):
        """
        CU-GE-010: Confirmar Pago
        """
        payment = self.get_object()

        # Exception B: Pago Duplicado
        if self._check_already_confirmed(payment):
            return Response(
                {"error": "El pago ya está confirmado."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        payment.status = Payment.Status.CONFIRMED
        payment.save()

        # Trigger notification:
        # send_payment_confirmation_notification(payment.enrollment)

        return Response(
            {"detail": "Pago confirmado exitosamente. El participante ha sido notificado."}, 
            status=status.HTTP_200_OK
        )

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        """
        CU-GE-010: Rechazar Pago
        """
        payment = self.get_object()
        reason = request.data.get('reason', '').strip()

        if self._check_already_confirmed(payment):
            return Response(
                {"error": "No se puede rechazar un pago que ya está confirmado."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        if not reason:
            return Response(
                {"error": "Debe proporcionar un motivo de rechazo."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        payment.status = Payment.Status.REJECTED
        payment.rejection_reason = reason
        payment.save()

        # Trigger notification:
        # send_payment_rejection_notification(payment.enrollment, reason)

        return Response(
            {"detail": "Pago rechazado exitosamente. Se ha notificado al participante."}, 
            status=status.HTTP_200_OK
        )

    @action(detail=True, methods=['post'])
    def request_voucher(self, request, pk=None):
        """
        CU-GE-010: Solicitar Comprobante (Alternativa A)
        """
        payment = self.get_object()

        if self._check_already_confirmed(payment):
            return Response(
                {"error": "El pago ya está confirmado, no es necesario solicitar comprobante."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        # Trigger notification instructing the user to upload their voucher
        # send_voucher_request_notification(payment.enrollment)

        return Response(
            {"detail": "Se ha notificado al participante para que cargue el comprobante."}, 
            status=status.HTTP_200_OK
        )
    
class AttendanceDocumentViewSet(viewsets.ModelViewSet):
    queryset = AttendanceDocument.objects.all().order_by('-uploaded_at')
    serializer_class = AttendanceDocumentSerializer
    
    # Crucial for handling file uploads
    parser_classes = (MultiPartParser, FormParser)

    def create(self, request, *args, **kwargs):
        """
        CU-GE-016: Cargar Asistencias
        """
        event_id = request.data.get('event')
        uploaded_file = request.FILES.get('file')

        # 1. Validate Event
        if not event_id:
            return Response({"error": "Debe especificar el ID del evento."}, status=status.HTTP_400_BAD_REQUEST)
            
        try:
            event = Event.objects.get(id=event_id)
            # Ensure the event has concluded before allowing uploads
            if event.end_date > timezone.now().date():
                return Response(
                    {"error": "No se pueden cargar asistencias para un evento que aún no ha finalizado."}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        except Event.DoesNotExist:
            return Response({"error": "El evento especificado no existe."}, status=status.HTTP_404_NOT_FOUND)

        if not uploaded_file:
            return Response({"error": "No se proporcionó ningún archivo."}, status=status.HTTP_400_BAD_REQUEST)

        # 2. Process File and Save Data
        try:
            # transaction.atomic() ensures that if parsing fails, the document isn't saved either.
            with transaction.atomic():
                # Save the physical document via the serializer
                serializer = self.get_serializer(data=request.data)
                serializer.is_valid(raise_exception=True)
                attendance_doc = serializer.save()

                # Determine file type and read into a pandas DataFrame
                filename = uploaded_file.name.lower()
                if filename.endswith('.csv'):
                    df = pd.read_csv(uploaded_file)
                elif filename.endswith(('.xlsx', '.xls')):
                    df = pd.read_excel(uploaded_file)
                else:
                    raise ValueError("Formato de archivo no soportado. Utilice .csv o .xlsx")

                # Parse the DataFrame
                # Assumption: The file has columns named 'Participante' and 'Asistio'
                attendance_records = []
                for index, row in df.iterrows():
                    # Fallback to the first column if 'Participante' header is missing
                    participant_name = row.get('Participante', str(row.iloc[0])) 
                    raw_attended = row.get('Asistio', False)

                    # Normalize the boolean value (handles 'Si', 'Yes', '1', True, etc.)
                    attended = str(raw_attended).strip().lower() in ['true', '1', 'si', 'yes', 's']

                    attendance_records.append(
                        Attendance(
                            event=event,
                            participant_name=participant_name,
                            attended=attended
                        )
                    )

                # Optional: Clear previous attendance records for this event in case of a re-upload
                Attendance.objects.filter(event=event).delete()
                
                # Bulk insert all records efficiently
                Attendance.objects.bulk_create(attendance_records)

            return Response(
                {
                    "detail": f"Asistencias cargadas exitosamente. Se procesaron {len(attendance_records)} registros.",
                    "document": serializer.data
                },
                status=status.HTTP_201_CREATED
            )

        except Exception as e:
            # Excepción B: Error handling. El sistema informa a la Coordinadora.
            return Response(
                {"error": f"Error al procesar el documento: {str(e)}. Verifique el formato del archivo."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

class AttendanceViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Read-only viewset to query individual participant attendance records.
    """
    queryset = Attendance.objects.all()
    serializer_class = AttendanceSerializer
    filterset_fields = ['event', 'attended']
    search_fields = ['participant_name']