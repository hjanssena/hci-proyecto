from django.db import models

class Category(models.Model):
    name = models.CharField(max_length=255, unique=True)
    # acts as the Activa/Archivada toggle
    is_active = models.BooleanField(default=True) 

    def __str__(self):
        return self.name

class Event(models.Model):
    class Modality(models.TextChoices):
        PRESENTIAL = 'PR', 'Presencial'
        VIRTUAL = 'VI', 'Virtual'
        HYBRID = 'HY', 'Híbrida'

    class Status(models.TextChoices):
        INSCRIPTIONS = 'IN', 'En fase de inscripciones'
        CONFIRMED = 'CO', 'Confirmado'
        ARCHIVED = 'AR', 'Archivado'
        CANCELED = 'CA', 'Cancelado'

    name = models.CharField(max_length=255)
    category = models.ForeignKey(Category, on_delete=models.PROTECT)
    description = models.TextField()
    status = models.CharField(max_length=2, choices=Status.choices, default=Status.INSCRIPTIONS)
    start_date = models.DateField()
    end_date = models.DateField()
    schedule = models.CharField(max_length=255)
    duration_hours = models.PositiveIntegerField()
    modality = models.CharField(max_length=2, choices=Modality.choices)
    location_or_link = models.CharField(max_length=255)
    max_capacity = models.PositiveIntegerField()
    min_inscriptions = models.PositiveIntegerField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    epc_points = models.BooleanField(default=False)
    accreditation_requirements = models.TextField()
    by_contract = models.BooleanField(default=False)
    with_organization = models.CharField(max_length=255, blank=True, null=True)
    
    # Cancellation tracking
    cancellation_reason = models.TextField(blank=True, null=True)
    cancellation_date = models.DateTimeField(blank=True, null=True)

    def __str__(self):
        return self.name

class Enrollment(models.Model):
    class Status(models.TextChoices):
        PENDING = 'PE', 'Pendiente de Revisión'
        INFO_REQUIRED = 'IR', 'Información Requerida'
        APPROVED = 'AP', 'Aprobada'
        REJECTED = 'RE', 'Rechazada'

    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='enrollments')
    applicant_name = models.CharField(max_length=255)
    documents = models.FileField(upload_to='enrollment_docs/', blank=True, null=True)
    status = models.CharField(max_length=2, choices=Status.choices, default=Status.PENDING)
    rejection_reason = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.applicant_name} - {self.event.name}"

class Payment(models.Model):
    class Status(models.TextChoices):
        PENDING = 'PE', 'Pendiente de Verificación de Pago'
        CONFIRMED = 'CO', 'Confirmada'
        REJECTED = 'RE', 'Pago Rechazado'
        REFUND_IN_PROGRESS = 'RIP', 'Reembolso en proceso' 
        REFUND_COMPLETED = 'RC', 'Reembolso completado' 

    enrollment = models.OneToOneField(Enrollment, on_delete=models.CASCADE, related_name='payment')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    proof_of_payment = models.FileField(upload_to='payment_proofs/')
    status = models.CharField(max_length=3, choices=Status.choices, default=Status.PENDING)
    rejection_reason = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"Payment for {self.enrollment.applicant_name}"

class Voucher(models.Model):
    enrollment = models.OneToOneField(Enrollment, on_delete=models.CASCADE, related_name='voucher')
    code = models.CharField(max_length=50, unique=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    is_used = models.BooleanField(default=False)
    expiration_date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Voucher {self.code} - {self.amount}"

class AttendanceDocument(models.Model):
    event = models.OneToOneField(Event, on_delete=models.CASCADE, related_name='attendance_document')
    file = models.FileField(upload_to='attendance_docs/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Documento de asistencia - {self.event.name}"

class Attendance(models.Model):
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='attendance_records')
    participant_name = models.CharField(max_length=255)
    attended = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.participant_name} - {self.event.name} - {'Attended' if self.attended else 'Absent'}"