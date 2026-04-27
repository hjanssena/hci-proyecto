import uuid
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager

class RoleLevel(models.TextChoices):
    PUBLIC = 'usuario_publico', 'Usuario Público'
    STAFF = 'staff_soporte', 'Staff Soporte'
    ADMIN = 'administrador', 'Administrador'

class CustomUserManager(BaseUserManager):
    def create_user(self, email, name, last_name, password=None, **extra_fields):
        if not email:
            raise ValueError('El usuario debe tener un correo electrónico')
        
        email = self.normalize_email(email)
        user = self.model(email=email, name=name, last_name=last_name, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, name, last_name, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role_level', RoleLevel.ADMIN)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser debe tener is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser debe tener is_superuser=True.')

        return self.create_user(email, name, last_name, password, **extra_fields)

class User(AbstractBaseUser, PermissionsMixin):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True, max_length=255)
    has_verified_email = models.BooleanField(default=False)
    customer_token = models.CharField(max_length=255, null=True, blank=True)
    role_level = models.CharField(max_length=50, choices=RoleLevel.choices, default=RoleLevel.PUBLIC)
    
    name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    
    has_accepted_terms = models.BooleanField(default=False)
    time_terms_accepted = models.DateTimeField(null=True, blank=True)
    logo_url = models.TextField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_updated_by = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True)

    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['name', 'last_name']

    objects = CustomUserManager()

    def __str__(self):
        return self.email

class PasswordChangePetition(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='password_petitions')
    validation_code = models.CharField(max_length=100)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    created_at = models.DateTimeField(auto_now_add=True)