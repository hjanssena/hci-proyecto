from rest_framework import serializers
from django.db import transaction
from .models import Attendance, AttendanceDocument, Category, Event, EventSchedule, Enrollment, Payment, Professor, EventProfessor

class ProfessorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Professor
        fields = ['id', 'name', 'email']

class EventProfessorSerializer(serializers.ModelSerializer):
    professor = ProfessorSerializer(read_only=True)

    class Meta:
        model = EventProfessor
        fields = ['id', 'professor', 'hours']

class EventScheduleSerializer(serializers.ModelSerializer):
    day_display = serializers.CharField(source='get_day_display', read_only=True)

    class Meta:
        model = EventSchedule
        fields = ['id', 'day', 'day_display', 'start_time', 'end_time']

class EventSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    event_professors = EventProfessorSerializer(many=True, read_only=True)
    schedules = EventScheduleSerializer(many=True, read_only=True)
    professors_data = serializers.ListField(
        child=serializers.DictField(), write_only=True, required=False
    )
    schedules_data = serializers.ListField(
        child=serializers.DictField(), write_only=True, required=False
    )

    class Meta:
        model = Event
        fields = '__all__'
        read_only_fields = ('status', 'cancellation_reason', 'cancellation_date')

    def _save_professors(self, event, professors_data):
        event.event_professors.all().delete()
        for prof_data in professors_data:
            EventProfessor.objects.create(
                event=event,
                professor_id=prof_data['professor_id'],
                hours=prof_data['hours']
            )

    def _save_schedules(self, event, schedules_data):
        event.schedules.all().delete()
        for sched in schedules_data:
            EventSchedule.objects.create(
                event=event,
                day=sched['day'],
                start_time=sched['start_time'],
                end_time=sched['end_time']
            )

    def create(self, validated_data):
        professors_data = validated_data.pop('professors_data', [])
        schedules_data = validated_data.pop('schedules_data', [])
        with transaction.atomic():
            event = super().create(validated_data)
            if professors_data:
                self._save_professors(event, professors_data)
            if schedules_data:
                self._save_schedules(event, schedules_data)
        return event

    def update(self, instance, validated_data):
        professors_data = validated_data.pop('professors_data', None)
        schedules_data = validated_data.pop('schedules_data', None)
        with transaction.atomic():
            event = super().update(instance, validated_data)
            if professors_data is not None:
                self._save_professors(event, professors_data)
            if schedules_data is not None:
                self._save_schedules(event, schedules_data)
        return event

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'is_active']

class EnrollmentSerializer(serializers.ModelSerializer):
    event_name = serializers.CharField(source='event.name', read_only=True)

    class Meta:
        model = Enrollment
        fields = '__all__'
        read_only_fields = ('status', 'rejection_reason')

class PaymentSerializer(serializers.ModelSerializer):
    applicant_name = serializers.CharField(source='enrollment.applicant_name', read_only=True)
    event_name = serializers.CharField(source='enrollment.event.name', read_only=True)

    class Meta:
        model = Payment
        fields = [
            'id', 'enrollment', 'applicant_name', 'event_name',
            'amount', 'proof_of_payment', 'status', 'rejection_reason'
        ]
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
