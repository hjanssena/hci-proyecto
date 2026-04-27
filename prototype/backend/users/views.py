import uuid
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from django.core.signing import TimestampSigner
from django.conf import settings
from .serializers import UserSerializer, AccountDeletionSerializer

User = get_user_model()

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    
    def get_permissions(self):
        """
        Allow anyone to register (POST), but require authentication for everything else.
        """
        if self.action == 'create':
            return [AllowAny()]
        return [IsAuthenticated()]

    def get_queryset(self):
        user = self.request.user
        if user.role_level == 'administrador':
            return User.objects.all()
        return User.objects.filter(id=user.id)

    def perform_create(self, serializer):
        # 1. Save user and set audit values
        user = serializer.save()

        if self.request.user and self.request.user.is_authenticated:
            user.last_updated_by = self.request.user
        else:
            user.last_updated_by = user 
        
        user.save(update_fields=['last_updated_by'])

        # 2. Generate token
        signer = TimestampSigner()
        token = signer.sign(str(user.id))

        # 3. Send the email
        send_mail(
            subject='Verifica tu cuenta de médico',
            message=f'Hola {user.name},\n\nGracias por registrarte. Tu token de verificación es:\n\n{token}\n\nEste token es válido por 24 horas.',
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            fail_silently=False,
        )
    
    def perform_update(self, serializer):
        serializer.save(last_updated_by=self.request.user)
    
    @action(detail=False, methods=['post'], url_path='delete-account', permission_classes=[IsAuthenticated], serializer_class=AccountDeletionSerializer)
    def delete_account(self, request):
        user = request.user
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # 1. Verify password
        if not user.check_password(serializer.validated_data['password']):
            return Response(
                {"password": ["La contraseña es incorrecta. No se puede eliminar la cuenta."]}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        # 2. Anonymize PII
        random_suffix = str(uuid.uuid4())[:8]
        user.email = f"deleted_{random_suffix}@anonymized.local"
        user.name = "Usuario"
        user.last_name = "Eliminado"
        user.customer_token = None
        user.logo_url = None
        
        # 3. Soft Delete and scramble password
        user.is_active = False
        user.set_unusable_password() 
        user.save()

        return Response(
            {"detail": "Tu cuenta y tus datos personales han sido eliminados permanentemente."}, 
            status=status.HTTP_200_OK
        )