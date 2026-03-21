import os
from datetime import timedelta
from django.core.management.base import BaseCommand
from django.core.files import File
from django.utils import timezone
from django.conf import settings
from events.models import Category, Event, Enrollment, Payment, Attendance, AttendanceDocument

class Command(BaseCommand):
    help = 'Seeds the database with dummy data for FCA Continuous Education'

    def handle(self, *args, **kwargs):
        self.stdout.write("Borrando datos antiguos...")
        Category.objects.all().delete()
        # Cascades will delete events, enrollments, payments, etc.

        # 1. Paths to the sample files you placed in media/samples/
        sample_doc_path = os.path.join(settings.MEDIA_ROOT, 'samples', 'documento.pdf')
        sample_receipt_path = os.path.join(settings.MEDIA_ROOT, 'samples', 'comprobante.png')
        sample_attendance_path = os.path.join(settings.MEDIA_ROOT, 'samples', 'asistencia.xlsx')

        # Check if files exist before proceeding to avoid errors
        if not all(os.path.exists(p) for p in [sample_doc_path, sample_receipt_path, sample_attendance_path]):
            self.stderr.write(self.style.ERROR(
                "¡Faltan archivos de muestra! Asegúrate de tener documento.pdf, "
                "comprobante.jpg y asistencia.xlsx dentro de media/samples/"
            ))
            return

        self.stdout.write("Creando Categorías...")
        cat_diplomado = Category.objects.create(name="Diplomado", is_active=True)
        cat_taller = Category.objects.create(name="Taller", is_active=True)
        cat_curso = Category.objects.create(name="Curso", is_active=True)

        self.stdout.write("Creando Eventos...")
        now = timezone.now()
        
        event_finanzas = Event.objects.create(
            name="Diplomado en Finanzas y Alta Dirección",
            category=cat_diplomado,
            description="Programa integral para la gestión financiera de empresas en Yucatán.",
            status=Event.Status.CONFIRMED,
            start_date=(now - timedelta(days=10)).date(),
            end_date=(now + timedelta(days=50)).date(),
            schedule="Viernes 17:00 - 21:00, Sábados 09:00 - 13:00",
            duration_hours=120,
            modality=Event.Modality.PRESENTIAL,
            location_or_link="Aula Magna, FCA UADY",
            max_capacity=30,
            min_inscriptions=15,
            price=15000.00,
            accreditation_requirements="Asistencia del 80% y proyecto final aprobado."
        )

        event_automatizacion = Event.objects.create(
            name="Taller de Automatización Administrativa con n8n y Odoo",
            category=cat_taller,
            description="Aprende a conectar flujos de trabajo, crear chatbots para WhatsApp y gestionar bases de datos empresariales.",
            status=Event.Status.INSCRIPTIONS,
            start_date=(now + timedelta(days=20)).date(),
            end_date=(now + timedelta(days=25)).date(),
            schedule="Lunes a Viernes 18:00 - 20:00",
            duration_hours=10,
            modality=Event.Modality.VIRTUAL,
            location_or_link="https://zoom.us/j/ejemplo123",
            max_capacity=20,
            min_inscriptions=5,
            price=2500.00,
            accreditation_requirements="Entrega de flujo automatizado funcional."
        )

        self.stdout.write("Creando Solicitudes de Inscripción y Pagos...")
        
        # Open files once to use across multiple instances
        with open(sample_doc_path, 'rb') as f_doc, open(sample_receipt_path, 'rb') as f_receipt:
            
            # Hugo: Approved and Paid (Confirmed)
            enr_hugo = Enrollment.objects.create(
                event=event_finanzas,
                applicant_name="Hugo de Jesús Janssen Aguilar",
                status=Enrollment.Status.APPROVED
            )
            enr_hugo.documents.save('documento.pdf', File(f_doc))
            
            pay_hugo = Payment.objects.create(
                enrollment=enr_hugo,
                amount=15000.00,
                status=Payment.Status.CONFIRMED
            )
            pay_hugo.proof_of_payment.save('comprobante.png', File(f_receipt))

            # Jesse: Pending Review
            enr_jesse = Enrollment.objects.create(
                event=event_automatizacion,
                applicant_name="Jesse Oswaldo Martin Jimenez",
                status=Enrollment.Status.PENDING
            )
            enr_jesse.documents.save('documento.pdf', File(f_doc))

            # Waldo: Approved, Payment Pending Verification
            enr_waldo = Enrollment.objects.create(
                event=event_automatizacion,
                applicant_name="Waldo Camara Villacis",
                status=Enrollment.Status.APPROVED
            )
            enr_waldo.documents.save('documento.pdf', File(f_doc))
            
            pay_waldo = Payment.objects.create(
                enrollment=enr_waldo,
                amount=2500.00,
                status=Payment.Status.PENDING
            )
            pay_waldo.proof_of_payment.save('comprobante.png', File(f_receipt))

            # Jose: Rejected Enrollment
            enr_jose = Enrollment.objects.create(
                event=event_finanzas,
                applicant_name="Jose Elias Novelo Collí",
                status=Enrollment.Status.REJECTED,
                rejection_reason="El documento de identificación no es legible."
            )
            enr_jose.documents.save('documento.pdf', File(f_doc))

        self.stdout.write("Creando Documento de Asistencia...")
        
        with open(sample_attendance_path, 'rb') as f_attendance:
            att_doc = AttendanceDocument.objects.create(
                event=event_finanzas
            )
            att_doc.file.save('asistencia.xlsx', File(f_attendance))
            
            # Create some granular attendance rows
            Attendance.objects.create(event=event_finanzas, participant_name="Hugo de Jesús Janssen Aguilar", attended=True)
            Attendance.objects.create(event=event_finanzas, participant_name="Estudiante Muestra Dos", attended=False)

        self.stdout.write(self.style.SUCCESS("¡Base de datos poblada exitosamente con datos de prueba!"))