from datetime import timedelta
from django.core.management.base import BaseCommand
from django.utils import timezone
from django.core.files.base import ContentFile
from events.models import (
    Category, Event, EventSchedule, Enrollment, Payment, Attendance,
    AttendanceDocument, Professor, EventProfessor, Voucher
)


class Command(BaseCommand):
    help = 'Seeds the database with comprehensive dummy data for FCA Continuous Education'

    def handle(self, *args, **kwargs):
        self.stdout.write("Borrando datos antiguos...")
        Event.objects.all().delete()
        Professor.objects.all().delete()
        Category.objects.all().delete()
        # Cascades will delete events, enrollments, payments, etc.

        now = timezone.now()

        # ── Categories ──
        self.stdout.write("Creando Categorías...")
        cats = {
            'diplomado': Category.objects.create(name="Diplomado", is_active=True),
            'taller': Category.objects.create(name="Taller", is_active=True),
            'curso': Category.objects.create(name="Curso", is_active=True),
            'maestria': Category.objects.create(name="Maestría", is_active=True),
            'seminario': Category.objects.create(name="Seminario", is_active=False),  # Archived
        }

        # ── Professors ──
        self.stdout.write("Creando Profesores...")
        profs = []
        prof_data = [
            ("Dr. Carlos Alberto Pérez López", "carlos.perez@uady.mx"),
            ("Mtra. Ana María González Ruiz", "ana.gonzalez@uady.mx"),
            ("Dr. Roberto Hernández Sánchez", "roberto.hernandez@uady.mx"),
            ("Mtra. Laura Beatriz Chávez Mendoza", "laura.chavez@uady.mx"),
            ("Mtro. Fernando José Castillo Díaz", "fernando.castillo@uady.mx"),
        ]
        for name, email in prof_data:
            profs.append(Professor.objects.create(name=name, email=email))

        # ── Events ──
        self.stdout.write("Creando Eventos...")
        events = []

        # CONFIRMED events (5)
        e1 = Event.objects.create(
            name="Diplomado en Finanzas y Alta Dirección",
            category=cats['diplomado'], description="Programa integral para la gestión financiera de empresas en Yucatán.",
            status=Event.Status.CONFIRMED, start_date=(now - timedelta(days=10)).date(),
            end_date=(now + timedelta(days=50)).date(),
            duration_hours=120, modality=Event.Modality.PRESENTIAL, location_or_link="Aula Magna, FCA UADY",
            max_capacity=30, min_inscriptions=15, price=15000.00,
            accreditation_requirements="Asistencia del 80% y proyecto final aprobado."
        )
        events.append(e1)

        e2 = Event.objects.create(
            name="Curso de Contabilidad Gubernamental",
            category=cats['curso'], description="Normas y procedimientos contables del sector público mexicano.",
            status=Event.Status.CONFIRMED, start_date=(now - timedelta(days=5)).date(),
            end_date=(now + timedelta(days=25)).date(),
            duration_hours=40, modality=Event.Modality.HYBRID, location_or_link="Sala B2, FCA / https://meet.google.com/abc-def",
            max_capacity=25, min_inscriptions=10, price=5500.00,
            accreditation_requirements="Examen final aprobado con 70% mínimo.", epc_points=True
        )
        events.append(e2)

        e3 = Event.objects.create(
            name="Diplomado en Gestión de Recursos Humanos",
            category=cats['diplomado'], description="Desarrollo de habilidades en la gestión del talento humano.",
            status=Event.Status.CONFIRMED, start_date=(now + timedelta(days=5)).date(),
            end_date=(now + timedelta(days=90)).date(),
            duration_hours=100, modality=Event.Modality.PRESENTIAL, location_or_link="Aula 201, FCA UADY",
            max_capacity=35, min_inscriptions=12, price=18000.00,
            accreditation_requirements="Asistencia del 80%, presentación de proyecto final.",
            by_contract=True, with_organization="Gobierno del Estado de Yucatán"
        )
        events.append(e3)

        e4 = Event.objects.create(
            name="Taller de Liderazgo Organizacional",
            category=cats['taller'], description="Técnicas y herramientas para el liderazgo efectivo en organizaciones.",
            status=Event.Status.CONFIRMED, start_date=(now + timedelta(days=2)).date(),
            end_date=(now + timedelta(days=4)).date(),
            duration_hours=16, modality=Event.Modality.PRESENTIAL, location_or_link="Sala de Usos Múltiples, FCA",
            max_capacity=20, min_inscriptions=8, price=3000.00,
            accreditation_requirements="Asistencia completa."
        )
        events.append(e4)

        e5 = Event.objects.create(
            name="Curso de Análisis de Datos con Python",
            category=cats['curso'], description="Introducción al análisis de datos usando Python, Pandas y visualización.",
            status=Event.Status.CONFIRMED, start_date=(now - timedelta(days=15)).date(),
            end_date=(now + timedelta(days=15)).date(),
            duration_hours=24, modality=Event.Modality.VIRTUAL, location_or_link="https://zoom.us/j/python-analisis",
            max_capacity=40, min_inscriptions=10, price=4000.00,
            accreditation_requirements="Entrega de proyecto de análisis de datos.", epc_points=True
        )
        events.append(e5)

        # INSCRIPTIONS events (6)
        e6 = Event.objects.create(
            name="Taller de Automatización Administrativa con n8n y Odoo",
            category=cats['taller'], description="Aprende a conectar flujos de trabajo, crear chatbots y gestionar bases de datos empresariales.",
            status=Event.Status.INSCRIPTIONS, start_date=(now + timedelta(days=20)).date(),
            end_date=(now + timedelta(days=25)).date(),
            duration_hours=10, modality=Event.Modality.VIRTUAL, location_or_link="https://zoom.us/j/ejemplo123",
            max_capacity=20, min_inscriptions=5, price=2500.00,
            accreditation_requirements="Entrega de flujo automatizado funcional."
        )
        events.append(e6)

        e7 = Event.objects.create(
            name="Diplomado en Marketing Digital y Redes Sociales",
            category=cats['diplomado'], description="Estrategias de marketing digital, SEO, SEM y gestión de redes sociales para negocios.",
            status=Event.Status.INSCRIPTIONS, start_date=(now + timedelta(days=30)).date(),
            end_date=(now + timedelta(days=150)).date(),
            duration_hours=96, modality=Event.Modality.HYBRID, location_or_link="Aula 105, FCA / https://meet.google.com/mktg",
            max_capacity=30, min_inscriptions=12, price=14000.00,
            accreditation_requirements="Asistencia del 80% y entrega de plan de marketing."
        )
        events.append(e7)

        e8 = Event.objects.create(
            name="Curso de Excel Avanzado para Negocios",
            category=cats['curso'], description="Fórmulas avanzadas, tablas dinámicas, macros y dashboards en Excel.",
            status=Event.Status.INSCRIPTIONS, start_date=(now + timedelta(days=15)).date(),
            end_date=(now + timedelta(days=22)).date(),
            duration_hours=14, modality=Event.Modality.PRESENTIAL, location_or_link="Laboratorio de Cómputo 3, FCA",
            max_capacity=25, min_inscriptions=8, price=1800.00,
            accreditation_requirements="Examen práctico aprobado."
        )
        events.append(e8)

        e9 = Event.objects.create(
            name="Taller de Negociación y Resolución de Conflictos",
            category=cats['taller'], description="Habilidades prácticas para la negociación efectiva en entornos profesionales.",
            status=Event.Status.INSCRIPTIONS, start_date=(now + timedelta(days=40)).date(),
            end_date=(now + timedelta(days=42)).date(),
            duration_hours=24, modality=Event.Modality.PRESENTIAL, location_or_link="Sala de Conferencias, FCA",
            max_capacity=15, min_inscriptions=6, price=3500.00,
            accreditation_requirements="Participación activa en simulaciones."
        )
        events.append(e9)

        e10 = Event.objects.create(
            name="Maestría en Administración de Empresas (Módulo Introductorio)",
            category=cats['maestria'], description="Módulo introductorio para aspirantes a la Maestría en Administración.",
            status=Event.Status.INSCRIPTIONS, start_date=(now + timedelta(days=60)).date(),
            end_date=(now + timedelta(days=65)).date(),
            duration_hours=36, modality=Event.Modality.PRESENTIAL, location_or_link="Auditorio FCA UADY",
            max_capacity=50, min_inscriptions=20, price=8000.00,
            accreditation_requirements="Entrevista y examen de admisión aprobados.",
            by_contract=True, with_organization="CONACYT"
        )
        events.append(e10)

        e11 = Event.objects.create(
            name="Curso de Derecho Fiscal Empresarial",
            category=cats['curso'], description="Marco legal y obligaciones fiscales de las empresas en México.",
            status=Event.Status.INSCRIPTIONS, start_date=(now + timedelta(days=35)).date(),
            end_date=(now + timedelta(days=70)).date(),
            duration_hours=36, modality=Event.Modality.VIRTUAL, location_or_link="https://teams.microsoft.com/fiscal",
            max_capacity=35, min_inscriptions=10, price=6000.00,
            accreditation_requirements="Examen final y entrega de caso práctico.", epc_points=True
        )
        events.append(e11)

        # ARCHIVED events (3)
        e12 = Event.objects.create(
            name="Taller de Inteligencia Artificial para Negocios",
            category=cats['taller'], description="Aplicaciones prácticas de IA y machine learning en la toma de decisiones empresariales.",
            status=Event.Status.ARCHIVED, start_date=(now - timedelta(days=90)).date(),
            end_date=(now - timedelta(days=80)).date(),
            duration_hours=10, modality=Event.Modality.VIRTUAL, location_or_link="https://zoom.us/j/ia-negocios",
            max_capacity=30, min_inscriptions=8, price=3000.00,
            accreditation_requirements="Entrega de caso de uso de IA."
        )
        events.append(e12)

        e13 = Event.objects.create(
            name="Diplomado en Comercio Internacional",
            category=cats['diplomado'], description="Estrategias y normativas para la exportación e importación de bienes.",
            status=Event.Status.ARCHIVED, start_date=(now - timedelta(days=200)).date(),
            end_date=(now - timedelta(days=80)).date(),
            duration_hours=100, modality=Event.Modality.PRESENTIAL, location_or_link="Aula 302, FCA UADY",
            max_capacity=25, min_inscriptions=10, price=16000.00,
            accreditation_requirements="Asistencia del 80% y proyecto de investigación."
        )
        events.append(e13)

        e14 = Event.objects.create(
            name="Curso de Estadística Aplicada",
            category=cats['curso'], description="Fundamentos de estadística descriptiva e inferencial para investigación.",
            status=Event.Status.ARCHIVED, start_date=(now - timedelta(days=120)).date(),
            end_date=(now - timedelta(days=90)).date(),
            duration_hours=24, modality=Event.Modality.HYBRID, location_or_link="Lab. Cómputo 2 / https://meet.google.com/stats",
            max_capacity=20, min_inscriptions=8, price=2800.00,
            accreditation_requirements="Examen final aprobado."
        )
        events.append(e14)

        # CANCELED events (2)
        e15 = Event.objects.create(
            name="Seminario de Ética Profesional y Responsabilidad Social",
            category=cats['curso'], description="Reflexión sobre la ética en los negocios y la responsabilidad social empresarial.",
            status=Event.Status.CANCELED, start_date=(now + timedelta(days=10)).date(),
            end_date=(now + timedelta(days=12)).date(),
            duration_hours=16, modality=Event.Modality.PRESENTIAL, location_or_link="Sala B1, FCA UADY",
            max_capacity=40, min_inscriptions=15, price=0.00,
            accreditation_requirements="Asistencia completa.",
            cancellation_reason="No se alcanzó el mínimo de inscripciones requerido.",
            cancellation_date=now - timedelta(days=2)
        )
        events.append(e15)

        e16 = Event.objects.create(
            name="Taller de Fotografía Comercial para Emprendedores",
            category=cats['taller'], description="Técnicas de fotografía de producto y branding visual para emprendedores.",
            status=Event.Status.CANCELED, start_date=(now + timedelta(days=5)).date(),
            end_date=(now + timedelta(days=7)).date(),
            duration_hours=8, modality=Event.Modality.PRESENTIAL, location_or_link="Estudio Fotográfico FCA",
            max_capacity=12, min_inscriptions=5, price=1500.00,
            accreditation_requirements="Entrega de portafolio fotográfico.",
            cancellation_reason="El instructor canceló por motivos personales.",
            cancellation_date=now - timedelta(days=1)
        )
        events.append(e16)

        # ── Schedules ──
        self.stdout.write("Creando Horarios de Eventos...")
        D = EventSchedule.DayOfWeek
        from datetime import time
        schedule_data = [
            # e1: Viernes 17-21, Sábados 9-13
            (e1, D.FRIDAY, time(17, 0), time(21, 0)),
            (e1, D.SATURDAY, time(9, 0), time(13, 0)),
            # e2: Martes y Jueves 18-20
            (e2, D.TUESDAY, time(18, 0), time(20, 0)),
            (e2, D.THURSDAY, time(18, 0), time(20, 0)),
            # e3: Sábados 9-14
            (e3, D.SATURDAY, time(9, 0), time(14, 0)),
            # e4: Lun-Mié 9-17 (3-day workshop)
            (e4, D.MONDAY, time(9, 0), time(17, 0)),
            (e4, D.TUESDAY, time(9, 0), time(17, 0)),
            (e4, D.WEDNESDAY, time(9, 0), time(17, 0)),
            # e5: Lunes y Miércoles 19-21
            (e5, D.MONDAY, time(19, 0), time(21, 0)),
            (e5, D.WEDNESDAY, time(19, 0), time(21, 0)),
            # e6: Lunes a Viernes 18-20
            (e6, D.MONDAY, time(18, 0), time(20, 0)),
            (e6, D.TUESDAY, time(18, 0), time(20, 0)),
            (e6, D.WEDNESDAY, time(18, 0), time(20, 0)),
            (e6, D.THURSDAY, time(18, 0), time(20, 0)),
            (e6, D.FRIDAY, time(18, 0), time(20, 0)),
            # e7: Viernes 16-20
            (e7, D.FRIDAY, time(16, 0), time(20, 0)),
            # e8: Lunes a Viernes 9-11
            (e8, D.MONDAY, time(9, 0), time(11, 0)),
            (e8, D.TUESDAY, time(9, 0), time(11, 0)),
            (e8, D.WEDNESDAY, time(9, 0), time(11, 0)),
            (e8, D.THURSDAY, time(9, 0), time(11, 0)),
            (e8, D.FRIDAY, time(9, 0), time(11, 0)),
            # e9: Lun-Mié 9-18 (3-day workshop)
            (e9, D.MONDAY, time(9, 0), time(18, 0)),
            (e9, D.TUESDAY, time(9, 0), time(18, 0)),
            (e9, D.WEDNESDAY, time(9, 0), time(18, 0)),
            # e10: Sábados 8-14
            (e10, D.SATURDAY, time(8, 0), time(14, 0)),
            # e11: Miércoles 17-20
            (e11, D.WEDNESDAY, time(17, 0), time(20, 0)),
            # e12: Lunes a Viernes 10-12
            (e12, D.MONDAY, time(10, 0), time(12, 0)),
            (e12, D.TUESDAY, time(10, 0), time(12, 0)),
            (e12, D.WEDNESDAY, time(10, 0), time(12, 0)),
            (e12, D.THURSDAY, time(10, 0), time(12, 0)),
            (e12, D.FRIDAY, time(10, 0), time(12, 0)),
            # e13: Sábados 9-14
            (e13, D.SATURDAY, time(9, 0), time(14, 0)),
            # e14: Martes y Jueves 16-18
            (e14, D.TUESDAY, time(16, 0), time(18, 0)),
            (e14, D.THURSDAY, time(16, 0), time(18, 0)),
            # e15: Lun-Mié 9-17 (workshop-style)
            (e15, D.MONDAY, time(9, 0), time(17, 0)),
            (e15, D.TUESDAY, time(9, 0), time(17, 0)),
            # e16: Sábado y Domingo 10-14
            (e16, D.SATURDAY, time(10, 0), time(14, 0)),
            (e16, D.SUNDAY, time(10, 0), time(14, 0)),
        ]
        for event, day, start, end in schedule_data:
            EventSchedule.objects.create(event=event, day=day, start_time=start, end_time=end)

        # ── Professor Assignments ──
        self.stdout.write("Asignando profesores a eventos...")
        assignments = [
            (e1, profs[0], 60), (e1, profs[1], 60),
            (e2, profs[2], 40),
            (e3, profs[1], 50), (e3, profs[3], 50),
            (e4, profs[3], 16),
            (e5, profs[4], 24),
            (e6, profs[4], 10),
            (e7, profs[0], 48), (e7, profs[3], 48),
            (e8, profs[2], 14),
            (e9, profs[3], 24),
            (e10, profs[0], 18), (e10, profs[1], 18),
            (e11, profs[2], 36),
            (e12, profs[4], 10),
            (e13, profs[0], 50), (e13, profs[1], 50),
            (e14, profs[2], 24),
            (e15, profs[3], 16),
            (e16, profs[4], 8),
        ]
        for event, prof, hours in assignments:
            EventProfessor.objects.create(event=event, professor=prof, hours=hours)

        # ── Enrollments & Payments ──
        self.stdout.write("Creando Solicitudes de Inscripción y Pagos...")

        dummy_pdf = ContentFile(b'%PDF-1.4 dummy document content', name='documento.pdf')
        dummy_receipt = ContentFile(b'\x89PNG dummy receipt content', name='comprobante.png')

        applicants = [
            "Hugo de Jesús Janssen Aguilar",
            "Jesse Oswaldo Martin Jimenez",
            "Waldo Camara Villacis",
            "Jose Elias Novelo Collí",
            "María Fernanda López Castillo",
            "Diego Alejandro Ruiz Torres",
            "Andrea Paola Méndez Gutiérrez",
            "Jorge Luis Vázquez Herrera",
            "Gabriela Sofía Ramírez Pech",
            "Luis Enrique Cetina Cámara",
            "Paola Andrea Salazar Medina",
            "Ricardo Emilio Cruz Domínguez",
            "Valentina Guzmán Serrano",
            "Sebastián Morales Ek",
            "Camila Esperanza Díaz Flores",
            "Daniel Arturo Canul Poot",
            "Isela Patricia Kumul Tec",
            "Ángel Eduardo Balam Chi",
            "Mariana Guadalupe May Pat",
            "Fernando Xavier Cocom Noh",
        ]

        enrollment_configs = [
            # event, applicant_idx, enrollment_status, payment_status
            # ── e1 (Finanzas - Confirmed) ──
            (e1, 0, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 1, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 4, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 5, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 6, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 7, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 8, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 9, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 10, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 11, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 12, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 13, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 14, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 15, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 16, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e1, 3, Enrollment.Status.REJECTED, None),
            # ── e2 (Contabilidad - Confirmed) ──
            (e2, 2, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e2, 6, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e2, 7, Enrollment.Status.APPROVED, Payment.Status.PENDING),
            (e2, 8, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e2, 9, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e2, 10, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e2, 11, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e2, 12, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e2, 13, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e2, 14, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e2, 15, Enrollment.Status.PENDING, None),
            # ── e3 (RRHH - Confirmed) ──
            (e3, 0, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e3, 4, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e3, 5, Enrollment.Status.APPROVED, Payment.Status.PENDING),
            (e3, 17, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e3, 18, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e3, 19, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e3, 16, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e3, 13, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e3, 14, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e3, 15, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e3, 11, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e3, 12, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e3, 1, Enrollment.Status.INFO_REQUIRED, None),
            # ── e5 (Python - Confirmed) ──
            (e5, 3, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e5, 6, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e5, 7, Enrollment.Status.APPROVED, Payment.Status.REJECTED),
            (e5, 8, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e5, 9, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e5, 10, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e5, 11, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e5, 12, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e5, 13, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e5, 14, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e5, 2, Enrollment.Status.PENDING, None),
            # ── e6 (Automatización - Inscriptions) ──
            (e6, 1, Enrollment.Status.PENDING, None),
            (e6, 2, Enrollment.Status.APPROVED, Payment.Status.PENDING),
            (e6, 3, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            (e6, 4, Enrollment.Status.INFO_REQUIRED, None),
            # ── e7 (Marketing - Inscriptions) ──
            (e7, 5, Enrollment.Status.PENDING, None),
            (e7, 6, Enrollment.Status.PENDING, None),
            (e7, 7, Enrollment.Status.APPROVED, Payment.Status.PENDING),
            (e7, 8, Enrollment.Status.REJECTED, None),
            # ── e8 (Excel - Inscriptions) ──
            (e8, 9, Enrollment.Status.PENDING, None),
            (e8, 10, Enrollment.Status.PENDING, None),
            (e8, 11, Enrollment.Status.APPROVED, Payment.Status.CONFIRMED),
            # ── e10 (Maestría - Inscriptions) ──
            (e10, 0, Enrollment.Status.PENDING, None),
            (e10, 17, Enrollment.Status.PENDING, None),
            (e10, 18, Enrollment.Status.PENDING, None),
            (e10, 19, Enrollment.Status.APPROVED, Payment.Status.PENDING),
            # ── e11 (Derecho Fiscal - Inscriptions) ──
            (e11, 2, Enrollment.Status.PENDING, None),
            (e11, 3, Enrollment.Status.PENDING, None),
        ]

        for event, app_idx, enr_status, pay_status in enrollment_configs:
            enr = Enrollment.objects.create(
                event=event,
                applicant_name=applicants[app_idx],
                status=enr_status,
                rejection_reason="El documento de identificación no es legible." if enr_status == Enrollment.Status.REJECTED else None,
            )
            enr.documents.save('documento.pdf', ContentFile(b'%PDF-1.4 dummy', name='doc.pdf'))

            if pay_status is not None:
                pay = Payment.objects.create(
                    enrollment=enr,
                    amount=event.price,
                    status=pay_status,
                    rejection_reason="El monto transferido no coincide con el importe del evento." if pay_status == Payment.Status.REJECTED else None,
                )
                pay.proof_of_payment.save('comprobante.png', ContentFile(b'\x89PNG dummy', name='comp.png'))

        # ── Attendance for archived events ──
        self.stdout.write("Creando registros de asistencia para eventos concluidos...")

        # e12 (IA - archived, past dates)
        for i, name in enumerate(applicants[:8]):
            Attendance.objects.create(event=e12, participant_name=name, attended=(i % 3 != 0))

        # e13 (Comercio Internacional - archived)
        for i, name in enumerate(applicants[2:12]):
            Attendance.objects.create(event=e13, participant_name=name, attended=(i % 4 != 0))

        # e14 (Estadística - archived)
        for i, name in enumerate(applicants[5:13]):
            Attendance.objects.create(event=e14, participant_name=name, attended=(i % 2 == 0))

        # ── Vouchers for canceled event ──
        self.stdout.write("Creando vouchers para evento cancelado...")
        canceled_enrollments = Enrollment.objects.filter(event=e15)
        for i, enr in enumerate(canceled_enrollments):
            if hasattr(enr, 'payment') and enr.payment.status == Payment.Status.CONFIRMED:
                Voucher.objects.create(
                    enrollment=enr,
                    code=f"VOUCHER-{e15.id}-{i+1:03d}",
                    amount=e15.price,
                    is_used=False,
                    expiration_date=(now + timedelta(days=365)).date(),
                )

        # ── Test User ──
        self.stdout.write("Creando usuario de prueba...")
        from users.models import User
        if not User.objects.filter(email='admin@fca.uady.mx').exists():
            u = User.objects.create_user(
                email='admin@fca.uady.mx',
                name='Coordinadora',
                last_name='FCA',
                password='Admin123!@#',
            )
            u.has_verified_email = True
            u.save()

        self.stdout.write(self.style.SUCCESS(
            f"\n¡Base de datos poblada exitosamente!\n"
            f"  Categorías: {Category.objects.count()}\n"
            f"  Profesores: {Professor.objects.count()}\n"
            f"  Eventos: {Event.objects.count()}\n"
            f"  Inscripciones: {Enrollment.objects.count()}\n"
            f"  Pagos: {Payment.objects.count()}\n"
            f"  Asistencias: {Attendance.objects.count()}\n"
            f"\n  Usuario de prueba: admin@fca.uady.mx / Admin123!@#\n"
        ))
