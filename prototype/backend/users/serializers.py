from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password

from users.validators import AdvancedEmailValidator, NameValidator

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(
        write_only=True, 
        validators=[validate_password] 
    )
    name = serializers.CharField(validators=[NameValidator()])
    last_name = serializers.CharField(validators=[NameValidator()])
    email = serializers.EmailField(validators=[AdvancedEmailValidator()])
    class Meta:
        model = User
        fields = [
            'id', 'email', 'name', 'last_name', 'role_level', 
            'has_verified_email', 'logo_url', 'password', 'is_active',
            'created_at', 'updated_at', 'last_updated_by'
        ]
        # Prevent these from being modified directly via the standard CRUD
        read_only_fields = ['id', 'has_verified_email', 'role_level', 'created_at', 'updated_at', 'last_updated_by'] 
        
        # Ensure the password is never sent back in the API response
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def create(self, validated_data):
        # Override create to ensure the password is encrypted using create_user
        password = validated_data.pop('password', None)
        user = User.objects.create_user(**validated_data)
        if password:
            user.set_password(password)
        user.save()
        return user

    def update(self, instance, validated_data):
        # Override update to handle password changes properly if provided
        password = validated_data.pop('password', None)
        if password:
            instance.set_password(password)
        return super().update(instance, validated_data)

class PasswordResetRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()

class PasswordResetConfirmSerializer(serializers.Serializer):
    code = serializers.CharField(max_length=100)
    new_password = serializers.CharField(
        write_only=True, 
        validators=[validate_password] # Enforces Django's built-in password strength rules
    )

class PasswordChangeSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True, write_only=True)
    new_password = serializers.CharField(
        required=True, 
        write_only=True, 
        validators=[validate_password]
    )

class AccountDeletionSerializer(serializers.Serializer):
    password = serializers.CharField(required=True, write_only=True)