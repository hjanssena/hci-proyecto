from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django.core.mail import send_mail
from django.utils.crypto import get_random_string
from django.conf import settings
from django.contrib.auth import get_user_model
from .models import PasswordChangePetition
from .serializers import PasswordChangeSerializer, PasswordResetRequestSerializer, PasswordResetConfirmSerializer
from django.core.signing import TimestampSigner, BadSignature, SignatureExpired
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework.throttling import ScopedRateThrottle
from datetime import timedelta
from django.utils import timezone

User = get_user_model()

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)

        token['email'] = user.email
        token['name'] = user.name
        token['last_name'] = user.last_name
        token['role_level'] = user.role_level
        token['has_verified_email'] = user.has_verified_email

        return token

class CustomLoginView(TokenObtainPairView):
    """
    Takes a set of user credentials and returns an access and refresh JSON web
    token to prove the authentication of those credentials.
    """
    serializer_class = CustomTokenObtainPairSerializer

    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'login_attempts'

class PasswordResetRequestView(generics.GenericAPIView):
    permission_classes = [AllowAny]
    serializer_class = PasswordResetRequestSerializer
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'password_reset'

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']

        try:
            user = User.objects.get(email=email)
            
            # 1. Invalidate any existing active reset petitions for this user
            PasswordChangePetition.objects.filter(user=user, is_active=True).update(is_active=False)

            # 2. Generate a secure 6-character alphanumeric code (or a UUID if you prefer links)
            validation_code = get_random_string(length=6, allowed_chars='ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')
            
            # 3. Save the petition to the database
            PasswordChangePetition.objects.create(
                user=user,
                validation_code=validation_code
            )

            # 4. Send the email
            send_mail(
                subject='Recuperación de Contraseña',
                message=f'Tu código de recuperación es: {validation_code}',
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[user.email],
                fail_silently=False,
            )
            
        except User.DoesNotExist:
            # We return 200 OK even if the user doesn't exist to prevent email enumeration attacks
            pass 

        return Response(
            {"detail": "Si el correo está registrado, se han enviado las instrucciones."}, 
            status=status.HTTP_200_OK
        )

class PasswordResetConfirmView(generics.GenericAPIView):
    permission_classes = [AllowAny]
    serializer_class = PasswordResetConfirmSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        code = serializer.validated_data['code']
        new_password = serializer.validated_data['new_password']

        # 1. Find the active petition
        try:
            petition = PasswordChangePetition.objects.get(validation_code=code, is_active=True)
        except PasswordChangePetition.DoesNotExist:
            return Response(
                {"detail": "El código es inválido o ya ha sido utilizado."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 2. Check for expiration (e.g., 15 minutes)
        expiration_time = petition.created_at + timedelta(minutes=15)
        
        if timezone.now() > expiration_time:
            # Invalidate the expired code so it can't be guessed later
            petition.is_active = False
            petition.save()
            return Response(
                {"detail": "El código ha expirado. Por favor, solicita uno nuevo."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 3. Apply the new password
        user = petition.user
        user.set_password(new_password)
        user.save()

        # 4. Invalidate the code so it can't be reused
        petition.is_active = False
        petition.save()

        # 4. Invalidate the current code and ALL other active petitions for this user
        PasswordChangePetition.objects.filter(
            user=user, 
            is_active=True
        ).update(is_active=False)

        return Response(
            {"detail": "Tu contraseña ha sido actualizada exitosamente."},
            status=status.HTTP_200_OK
        )
        
class VerifyEmailView(generics.GenericAPIView):
    permission_classes = [AllowAny]
    
    def post(self, request, *args, **kwargs):
        token = request.data.get('token')
        
        if not token:
            return Response({"detail": "El token es requerido."}, status=status.HTTP_400_BAD_REQUEST)

        signer = TimestampSigner()
        try:
            # Unsign the token. max_age is in seconds (86400 = 24 hours)
            user_id = signer.unsign(token, max_age=86400)
            
            user = User.objects.get(id=user_id)

            if user.has_verified_email:
                return Response({"detail": "El correo ya ha sido verificado anteriormente."}, status=status.HTTP_200_OK)

            # Update the status
            user.has_verified_email = True
            user.save()
            
            return Response({"detail": "Correo verificado exitosamente. Ya puedes acceder a todas las funciones."}, status=status.HTTP_200_OK)

        except SignatureExpired:
            return Response(
                {"detail": "El token ha expirado. Por favor solicita uno nuevo."}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        except (BadSignature, User.DoesNotExist):
            return Response(
                {"detail": "El token es inválido o está corrupto."}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
class PasswordChangeView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PasswordChangeSerializer

    def post(self, request, *args, **kwargs):
        user = request.user
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        old_password = serializer.validated_data['old_password']
        new_password = serializer.validated_data['new_password']

        # Verify the old password is correct
        if not user.check_password(old_password):
            return Response(
                {"old_password": ["La contraseña actual es incorrecta."]}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        # Hash and save the new password
        user.set_password(new_password)
        user.save()

        return Response(
            {"detail": "Contraseña actualizada exitosamente."}, 
            status=status.HTTP_200_OK
        )
    
class LogoutView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        try:
            refresh_token = request.data.get('refresh')
            
            if not refresh_token:
                return Response(
                    {"detail": "Se requiere el token de refresco (refresh)."}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
                
            token = RefreshToken(refresh_token)
            token.blacklist()
            
            return Response(
                {"detail": "Sesión cerrada exitosamente."}, 
                status=status.HTTP_205_RESET_CONTENT
            )
        except TokenError:
            return Response(
                {"detail": "El token es inválido o ya ha expirado."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

class RequestVerificationView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user

        # 1. Check if they actually need an email
        if user.has_verified_email:
            return Response(
                {"detail": "Tu cuenta ya está verificada."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        # 2. Generate token
        signer = TimestampSigner()
        token = signer.sign(str(user.id))

        # 3. Send the email
        send_mail(
            subject='Verifica tu cuenta',
            message=f'Hola {user.name},\n\nGracias por registrarte. Tu token de verificación es:\n\n{token}\n\nEste token es válido por 24 horas.',
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            fail_silently=False,
        )

        # 4. Return a successful response
        return Response(
            {"detail": "Se ha enviado un nuevo enlace de verificación a tu correo."},
            status=status.HTTP_200_OK
        )