from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from django.utils import timezone
from .models import Event, Enrollment, Payment

@receiver(pre_save, sender=Event)
def capture_previous_status(sender, instance, **kwargs):
    """
    Captures the event's status before saving to the database. 
    This allows us to detect if the status is actively changing to 'Cancelado'.
    """
    if instance.pk:
        try:
            old_instance = Event.objects.get(pk=instance.pk)
            instance._previous_status = old_instance.status
        except Event.DoesNotExist:
            instance._previous_status = None
    else:
        instance._previous_status = None

@receiver(post_save, sender=Event)
def process_event_cancellation(sender, instance, created, **kwargs):
    """
    Triggers the cancellation workflow for confirmed participants.
    """
    # Check if the event already existed and the status just changed to CANCELED
    if not created and getattr(instance, '_previous_status', None) != Event.Status.CANCELED:
        if instance.status == Event.Status.CANCELED:
            
            # Automatically stamp the cancellation date if not provided manually
            if not instance.cancellation_date:
                Event.objects.filter(pk=instance.pk).update(cancellation_date=timezone.now())

            # Find participants with a confirmed payment
            confirmed_enrollments = instance.enrollments.filter(
                payment__status=Payment.Status.CONFIRMED
            )
            
            for enrollment in confirmed_enrollments:
                # 1. NOTIFY PARTICIPANT
                # El sistema notifica a los participantes afectados sobre la cancelación.
                # Here you would call your email or notification service:
                # send_cancellation_email(enrollment.applicant_name, instance.name)
                print(f"Notification queued for: {enrollment.applicant_name} regarding {instance.name}")

                # 2. PREPARE FOR RESOLUTION
                # You can optionally flag the payment or enrollment here to indicate 
                # that it is awaiting the user's choice (Voucher vs. Refund).
                # For example, adding a 'PENDING_RESOLUTION' status to Payment in models.py 
                # would be a great way to track who hasn't answered yet.