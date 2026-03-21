from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import AttendanceDocumentViewSet, AttendanceViewSet, EnrollmentViewSet, EventViewSet, CategoryViewSet, PaymentViewSet

# Initialize the router
router = DefaultRouter()

# Register the viewsets
router.register(r'events', EventViewSet, basename='event')
router.register(r'categories', CategoryViewSet, basename='category')
router.register(r'enrollments', EnrollmentViewSet, basename='enrollment')
router.register(r'payments', PaymentViewSet, basename='payment')
router.register(r'attendance-documents', AttendanceDocumentViewSet, basename='attendance-document')
router.register(r'attendance-records', AttendanceViewSet, basename='attendance-record')

urlpatterns = [
    # Include all auto-generated URLs from the router
    path('', include(router.urls)),
]