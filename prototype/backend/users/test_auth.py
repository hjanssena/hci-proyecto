from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import AccessToken
from django.core import mail
from users.models import PasswordChangePetition
from unittest.mock import patch
from django.core.signing import TimestampSigner, SignatureExpired

User = get_user_model()

class AuthenticationTests(APITestCase):
    
    def setUp(self):
        self.email = 'doctor@gmail.com'
        self.password = 'ValidPass123!'
        self.name = 'Juan'
        self.last_name = 'Pérez'
        self.role_level = 'usuario_publico'
        
        self.user = User.objects.create_user(
            email=self.email,
            password=self.password,
            name=self.name,
            last_name=self.last_name,
            role_level=self.role_level
        )
        
        self.login_url = reverse('token_obtain_pair')
        self.refresh_url = reverse('token_refresh')

    def test_login_with_valid_credentials(self):
        """Ensure a user can log in and receive access/refresh tokens."""
        data = {
            'email': self.email,
            'password': self.password
        }
        
        response = self.client.post(self.login_url, data)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)

    def test_login_with_invalid_credentials(self):
        """Ensure invalid passwords are rejected with a 401."""
        data = {
            'email': self.email,
            'password': 'WrongPassword123!'
        }
        
        response = self.client.post(self.login_url, data)
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertNotIn('access', response.data)

    def test_custom_claims_in_token(self):
        """Ensure the generated access token contains the custom profile data."""
        data = {
            'email': self.email,
            'password': self.password
        }
        
        response = self.client.post(self.login_url, data)
        access_token_str = response.data['access']
        
        decoded_token = AccessToken(access_token_str)
        
        self.assertEqual(decoded_token['email'], self.email)
        self.assertEqual(decoded_token['name'], self.name)
        self.assertEqual(decoded_token['last_name'], self.last_name)
        self.assertEqual(decoded_token['role_level'], self.role_level)

    def test_token_refresh(self):
        """Ensure a valid refresh token can be used to get a new access token."""
        login_data = {
            'email': self.email,
            'password': self.password
        }
        login_response = self.client.post(self.login_url, login_data)
        refresh_token = login_response.data['refresh']
        
        refresh_data = {
            'refresh': refresh_token
        }
        refresh_response = self.client.post(self.refresh_url, refresh_data)
        
        self.assertEqual(refresh_response.status_code, status.HTTP_200_OK)
        self.assertIn('access', refresh_response.data)

class PasswordResetTests(APITestCase):
    
    def setUp(self):
        self.email = 'doctor_reset@gmail.com'
        self.password = 'ValidPass123!'
        
        self.user = User.objects.create_user(
            email=self.email,
            password=self.password,
            name='Carlos',
            last_name='Medina',
            role_level='usuario_publico'
        )
        
        self.request_url = reverse('password_reset_request')
        self.confirm_url = reverse('password_reset_confirm')

    def test_request_reset_valid_email(self):
        """A valid email should create a petition and send an email."""
        response = self.client.post(self.request_url, {'email': self.email})
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify the database record was created
        self.assertEqual(PasswordChangePetition.objects.count(), 1)
        petition = PasswordChangePetition.objects.first()
        self.assertTrue(petition.is_active)
        
        # Verify the email was "sent" to the outbox
        self.assertEqual(len(mail.outbox), 1)
        self.assertEqual(mail.outbox[0].to, [self.email])
        
        # Verify the code is actually inside the email body
        self.assertIn(petition.validation_code, mail.outbox[0].body)

    def test_request_reset_invalid_email(self):
        """An invalid email should return 200 OK for security, but do nothing else."""
        response = self.client.post(self.request_url, {'email': 'no_existo@gmail.com'})
        
        # Should still be 200 OK to prevent email enumeration
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # But no petition should be created and no email sent
        self.assertEqual(PasswordChangePetition.objects.count(), 0)
        self.assertEqual(len(mail.outbox), 0)

    def test_confirm_reset_valid_code(self):
        """A valid code should update the password and deactivate the petition."""
        # Create a manual petition to test the confirmation
        petition = PasswordChangePetition.objects.create(
            user=self.user, 
            validation_code='SECURE123'
        )
        
        new_password = 'NewSecurePassword456!'
        data = {
            'code': 'SECURE123',
            'new_password': new_password
        }
        
        response = self.client.post(self.confirm_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify the password was actually changed
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password(new_password))
        
        # Verify the petition can no longer be used
        petition.refresh_from_db()
        self.assertFalse(petition.is_active)

    def test_confirm_reset_invalid_code(self):
        """An invalid code should fail and leave the password unchanged."""
        data = {
            'code': 'WRONGCODE',
            'new_password': 'NewSecurePassword456!'
        }
        
        response = self.client.post(self.confirm_url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        
        # Verify the old password is still active
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password(self.password))

def test_confirm_reset_deactivates_previous_petitions(self):
        """Requesting a new reset should invalidate any older, unused codes."""
        # User requests a reset
        self.client.post(self.request_url, {'email': self.email})
        
        # Get the only petition that exists in the database right now
        first_petition = PasswordChangePetition.objects.first()
        
        # User requests ANOTHER reset because they didn't get the first email
        self.client.post(self.request_url, {'email': self.email})
        
        # Refresh the old petition to see its new state
        first_petition.refresh_from_db()
        
        # Find the NEW petition by explicitly excluding the ID of the first one
        second_petition = PasswordChangePetition.objects.exclude(id=first_petition.id).first()
        
        self.assertFalse(first_petition.is_active)
        self.assertTrue(second_petition.is_active)

class EmailVerificationTests(APITestCase):
    
    def setUp(self):
        # Create an unverified user
        self.email = 'unverified_doctor@gmail.com'
        self.password = 'ValidPass123!'
        
        self.user = User.objects.create_user(
            email=self.email,
            password=self.password,
            name='Laura',
            last_name='Gómez',
            role_level='usuario_publico'
            # has_verified_email defaults to False
        )
        
        self.register_url = reverse('user-list') # The ModelViewSet create endpoint
        self.verify_url = reverse('verify_email')
        self.signer = TimestampSigner()

    def test_registration_triggers_verification_email(self):
        """Ensure that creating a new user sends the verification email."""
        # Clear outbox from any previous tests
        mail.outbox = [] 
        
        data = {
            'email': 'new_doctor@gmail.com',
            'password': 'ValidPass123!',
            'name': 'Roberto',
            'last_name': 'Silva'
        }
        
        response = self.client.post(self.register_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Verify the email was sent
        self.assertEqual(len(mail.outbox), 1)
        self.assertEqual(mail.outbox[0].to, ['new_doctor@gmail.com'])
        self.assertIn('Verifica tu cuenta', mail.outbox[0].subject)

    def test_verify_with_valid_token(self):
        """A valid token should mark the user's email as verified."""
        # Generate a real, valid token for our test user
        valid_token = self.signer.sign(str(self.user.id))
        
        response = self.client.post(self.verify_url, {'token': valid_token})
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify the database was updated
        self.user.refresh_from_db()
        self.assertTrue(self.user.has_verified_email)

    def test_verify_with_invalid_token(self):
        """A tampered or malformed token should fail gracefully."""
        response = self.client.post(self.verify_url, {'token': 'fake:tampered:token123'})
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        
        # Verify the user is still unverified
        self.user.refresh_from_db()
        self.assertFalse(self.user.has_verified_email)

    @patch('django.core.signing.TimestampSigner.unsign')
    def test_verify_with_expired_token(self, mock_unsign):
        """A token older than 24 hours should be rejected."""
        # Force the unsign method to raise a SignatureExpired exception
        mock_unsign.side_effect = SignatureExpired("Signature expired")
        
        # Generate a structurally valid token, but our mock will treat it as expired
        token = self.signer.sign(str(self.user.id))
        
        response = self.client.post(self.verify_url, {'token': token})
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('expirado', response.data['detail'])
        
        # Verify the user is still unverified
        self.user.refresh_from_db()
        self.assertFalse(self.user.has_verified_email)

    def test_verify_already_verified_user(self):
        """If a user clicks the link twice, they should just get a success message."""
        # Verify them first
        self.user.has_verified_email = True
        self.user.save()
        
        valid_token = self.signer.sign(str(self.user.id))
        response = self.client.post(self.verify_url, {'token': valid_token})
        
        # It shouldn't crash or throw an error, just return 200 OK
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('ya ha sido verificado', response.data['detail'])

class AuthenticatedPasswordChangeTests(APITestCase):
    
    def setUp(self):
        self.email = 'doctor_auth_change@gmail.com'
        self.old_password = 'ValidPass123!'
        self.new_password = 'NewSecurePassword456!'
        
        self.user = User.objects.create_user(
            email=self.email,
            password=self.old_password,
            name='Elena',
            last_name='Ríos'
        )
        
        self.change_url = reverse('password_change')

    def test_change_password_success(self):
        """A logged-in user with the correct old password can change it."""
        self.client.force_authenticate(user=self.user)
        
        data = {
            'old_password': self.old_password,
            'new_password': self.new_password
        }
        
        response = self.client.post(self.change_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify the database updated the password
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password(self.new_password))

    def test_change_password_wrong_old_password(self):
        """Providing the wrong old password should fail."""
        self.client.force_authenticate(user=self.user)
        
        data = {
            'old_password': 'wrong_password_guess',
            'new_password': self.new_password
        }
        
        response = self.client.post(self.change_url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('old_password', response.data)
        
        # Verify the password remained unchanged
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password(self.old_password))

    def test_change_password_unauthenticated(self):
        """An unauthenticated user cannot access the endpoint."""
        data = {
            'old_password': self.old_password,
            'new_password': self.new_password
        }
        
        # We DO NOT call force_authenticate here
        response = self.client.post(self.change_url, data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

class LogoutTests(APITestCase):
    
    def setUp(self):
        self.email = 'doctor_logout@gmail.com'
        self.password = 'ValidPass123!'
        
        self.user = User.objects.create_user(
            email=self.email,
            password=self.password,
            name='Miguel',
            last_name='Sánchez'
        )
        
        self.login_url = reverse('token_obtain_pair')
        self.refresh_url = reverse('token_refresh')
        self.logout_url = reverse('logout')

    def test_secure_logout_blacklists_token(self):
        """Ensure a valid refresh token is blacklisted upon logout."""
        # 1. Log in to get tokens
        login_response = self.client.post(self.login_url, {
            'email': self.email,
            'password': self.password
        })
        
        access_token = login_response.data['access']
        refresh_token = login_response.data['refresh']
        
        # 2. Authenticate and call the logout endpoint
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')
        logout_response = self.client.post(self.logout_url, {'refresh': refresh_token})
        
        self.assertEqual(logout_response.status_code, status.HTTP_205_RESET_CONTENT)
        
        # 3. Attempt to use the blacklisted token to get a new access token
        refresh_response = self.client.post(self.refresh_url, {'refresh': refresh_token})
        
        # It should be rejected because it is now on the blacklist
        self.assertEqual(refresh_response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertIn('lista negra', str(refresh_response.data).lower())

    def test_logout_without_refresh_token_fails(self):
        """Ensure the endpoint demands a refresh token."""
        self.client.force_authenticate(user=self.user)
        
        response = self.client.post(self.logout_url, {})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('requiere', response.data['detail'])

    def test_logout_with_invalid_token_fails(self):
        """Ensure fake tokens are rejected gracefully."""
        self.client.force_authenticate(user=self.user)
        
        response = self.client.post(self.logout_url, {'refresh': 'fake_token_data'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class RequestVerificationTests(APITestCase):
    
    def setUp(self):
        # Create an unverified user
        self.unverified_user = User.objects.create_user(
            email='needs_verification@gmail.com',
            password='ValidPass123!',
            name='Pedro',
            last_name='Páramo',
            # has_verified_email defaults to False
        )

        # Create an already verified user
        self.verified_user = User.objects.create_user(
            email='already_verified@gmail.com',
            password='ValidPass123!',
            name='Susana',
            last_name='San Juan'
        )
        self.verified_user.has_verified_email = True
        self.verified_user.save()
        
        self.request_url = reverse('request_verification')

    def test_request_verification_unauthenticated(self):
        """Unauthenticated users cannot request a new token."""
        response = self.client.post(self.request_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_request_verification_already_verified(self):
        """Users who are already verified should be rejected gracefully."""
        self.client.force_authenticate(user=self.verified_user)
        
        response = self.client.post(self.request_url)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('ya está verificada', response.data['detail'])
        
        # Verify no email was actually sent
        self.assertEqual(len(mail.outbox), 0)

    def test_request_verification_success(self):
        """Unverified users should trigger a new email with a valid token."""
        self.client.force_authenticate(user=self.unverified_user)
        
        # Clear outbox from any previous tests
        mail.outbox = [] 
        
        response = self.client.post(self.request_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify the email was dispatched
        self.assertEqual(len(mail.outbox), 1)
        self.assertEqual(mail.outbox[0].to, [self.unverified_user.email])
        self.assertIn('Verifica tu cuenta', mail.outbox[0].subject)