from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth import get_user_model
from django.urls import reverse

User = get_user_model()

class UserViewSetTests(APITestCase):
    
    def setUp(self):
        # 1. Create a standard medical user
        self.standard_user = User.objects.create_user(
            email='doctor@gmail.com',
            password='ValidPass123!',
            name='Juan',
            last_name='Pérez',
            role_level='usuario_publico'
        )
        
        # 2. Create another standard user to test data isolation
        self.other_user = User.objects.create_user(
            email='otherdoctor@gmail.com',
            password='ValidPass123!',
            name='Ana',
            last_name='López',
            role_level='usuario_publico'
        )

        # 3. Create an administrator
        self.admin_user = User.objects.create_user(
            email='admin@gmail.com',
            password='ValidPass123!',
            name='Admin',
            last_name='Super',
            role_level='administrador'
        )

        # URLs for the ViewSet
        self.list_url = reverse('user-list')
        self.detail_url = reverse('user-detail', kwargs={'pk': self.standard_user.id})
        self.other_detail_url = reverse('user-detail', kwargs={'pk': self.other_user.id})

    def test_unauthenticated_access_is_denied(self):
        """Ensure unauthenticated users cannot access the endpoint."""
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_standard_user_can_only_see_themselves(self):
        """A standard user should only see their own profile in the list view."""
        self.client.force_authenticate(user=self.standard_user)
        response = self.client.get(self.list_url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Should only return 1 record (themselves)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['email'], self.standard_user.email)

    def test_admin_user_can_see_everyone(self):
        """An administrator should see all registered users."""
        self.client.force_authenticate(user=self.admin_user)
        response = self.client.get(self.list_url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # We created 3 users in setUp
        self.assertEqual(len(response.data), 3)

    def test_user_can_update_own_profile(self):
        """A user should be able to update their allowed fields (like name)."""
        self.client.force_authenticate(user=self.standard_user)
        
        update_data = {
            'name': 'Juan Carlos'
        }
        
        response = self.client.patch(self.detail_url, update_data)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.standard_user.refresh_from_db()
        self.assertEqual(self.standard_user.name, 'Juan Carlos')

    def test_user_cannot_update_read_only_fields(self):
        """Ensure a user cannot maliciously elevate their privileges or verify their own email."""
        self.client.force_authenticate(user=self.standard_user)
        
        malicious_data = {
            'role_level': 'administrador',
            'has_verified_email': True
        }
        
        response = self.client.patch(self.detail_url, malicious_data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify the database hasn't changed despite the request
        self.standard_user.refresh_from_db()
        self.assertEqual(self.standard_user.role_level, 'usuario_publico')
        self.assertFalse(self.standard_user.has_verified_email)

    def test_password_is_write_only(self):
        """Ensure passwords are never returned in the API response."""
        self.client.force_authenticate(user=self.standard_user)
        response = self.client.get(self.detail_url)
        
        self.assertNotIn('password', response.data)

    def test_user_can_change_password(self):
        """Ensure the password serializer override successfully hashes the new password."""
        self.client.force_authenticate(user=self.standard_user)
        
        update_data = {
            'password': 'ValidPass123!'
        }
        
        response = self.client.patch(self.detail_url, update_data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        self.standard_user.refresh_from_db()
        self.assertTrue(self.standard_user.check_password('ValidPass123!'))

    def test_standard_user_cannot_access_other_user_detail(self):
        """Ensure a user cannot view or edit another user's profile using their UUID."""
        self.client.force_authenticate(user=self.standard_user)
        
        # Attempt to GET the other user's profile
        response = self.client.get(self.other_detail_url)
        
        # Because our ViewSet's `get_queryset()` filters by the logged-in user's ID, 
        # DRF will return a 404 Not Found instead of 403 Forbidden. This is excellent 
        # for security as it doesn't even acknowledge the other user's existence.
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        
        # Attempt to PATCH the other user's profile
        patch_response = self.client.patch(self.other_detail_url, {'name': 'Hacked Name'})
        self.assertEqual(patch_response.status_code, status.HTTP_404_NOT_FOUND)

    def test_admin_can_access_other_user_detail(self):
        """An administrator should be able to view and edit any user's profile."""
        self.client.force_authenticate(user=self.admin_user)
        
        # Admin requests another user's profile
        response = self.client.get(self.other_detail_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['email'], self.other_user.email)

    def test_unauthenticated_user_can_register(self):
        """Ensure unauthenticated users can create a new account via POST."""
        new_user_data = {
            'email': 'new_registration@gmail.com',
            'password': 'ValidPass123!',
            'name': 'Nuevo',
            'last_name': 'Doctor'
        }
        
        # POSTing to the list URL triggers the `create` action
        response = self.client.post(self.list_url, new_user_data)
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(User.objects.filter(email='new_registration@gmail.com').exists())

class AccountDeletionTests(APITestCase):
    
    def setUp(self):
        self.email = 'doctor_to_delete@gmail.com'
        self.password = 'ValidPass123!'
        self.name = 'Héctor'
        
        self.user = User.objects.create_user(
            email=self.email,
            password=self.password,
            name=self.name,
            last_name='García'
        )
        
        self.delete_url = reverse('user-delete-account')

    def test_soft_delete_success(self):
        """Providing the correct password should anonymize and deactivate the account."""
        self.client.force_authenticate(user=self.user)
        
        response = self.client.post(self.delete_url, {'password': self.password})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        self.user.refresh_from_db()
        
        # Verify deactivation
        self.assertFalse(self.user.is_active)
        
        # Verify PII anonymization
        self.assertNotEqual(self.user.email, self.email)
        self.assertTrue(self.user.email.startswith('deleted_'))
        self.assertEqual(self.user.name, 'Usuario')
        
        # Verify the password was scrambled
        self.assertFalse(self.user.has_usable_password())

    def test_soft_delete_wrong_password(self):
        """Providing the wrong password should reject the deletion request."""
        self.client.force_authenticate(user=self.user)
        
        response = self.client.post(self.delete_url, {'password': 'WrongPassword123!'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        
        self.user.refresh_from_db()
        
        # Verify the account is still active and data is untouched
        self.assertTrue(self.user.is_active)
        self.assertEqual(self.user.email, self.email)
        self.assertEqual(self.user.name, self.name)

    def test_soft_delete_unauthenticated(self):
        """An unauthenticated user cannot trigger a deletion."""
        response = self.client.post(self.delete_url, {'password': self.password})
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)