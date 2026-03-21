from rest_framework import serializers
from .models import Attendance, AttendanceDocument, Category, Event, Enrollment, Payment

class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = '__all__'
        # We protect these fields from direct manual updates via PUT/PATCH
        read_only_fields = ('status', 'cancellation_reason', 'cancellation_date')

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'is_active']

class EnrollmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Enrollment
        fields = '__all__'
        read_only_fields = ('status', 'rejection_reason')

class PaymentSerializer(serializers.ModelSerializer):
    # Pulling related data for convenience on the frontend
    applicant_name = serializers.CharField(source='enrollment.applicant_name', read_only=True)
    event_name = serializers.CharField(source='enrollment.event.name', read_only=True)

    class Meta:
        model = Payment
        fields = [
            'id', 'enrollment', 'applicant_name', 'event_name', 
            'amount', 'proof_of_payment', 'status', 'rejection_reason'
        ]
        # Protect status and reason from generic updates
        read_only_fields = ('status', 'rejection_reason')

class AttendanceDocumentSerializer(serializers.ModelSerializer):
    event_name = serializers.CharField(source='event.name', read_only=True)

    class Meta:
        model = AttendanceDocument
        fields = ['id', 'event', 'event_name', 'file', 'uploaded_at']
        read_only_fields = ['uploaded_at']

class AttendanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attendance
        fields = ['id', 'event', 'participant_name', 'attended']