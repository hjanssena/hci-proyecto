from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet
from rest_framework_simplejwt.views import TokenRefreshView
from .auth_views import (
    CustomLoginView, PasswordResetRequestView, 
    PasswordResetConfirmView, VerifyEmailView, PasswordChangeView,
    LogoutView, RequestVerificationView
)


router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')

urlpatterns = [
    path('', include(router.urls)),
    path('login/', CustomLoginView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('password-reset/', PasswordResetRequestView.as_view(), name='password_reset_request'),
    path('password-reset/confirm/', PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('verify-email/', VerifyEmailView.as_view(), name='verify_email'),
    path('password-change/', PasswordChangeView.as_view(), name='password_change'),
    path('request-verification/', RequestVerificationView.as_view(), name='request_verification'),
    path('logout/', LogoutView.as_view(), name='logout'),
]