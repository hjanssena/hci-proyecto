# apps/users/validators.py
import re
from django.core.exceptions import ValidationError

class ComplexPasswordValidator:
    def validate(self, password, user=None):
        if not re.search(r'[A-Z]', password):
            raise ValidationError("La contraseña debe contener al menos una letra mayúscula.")
        
        if not re.search(r'[a-z]', password):
            raise ValidationError("La contraseña debe contener al menos una letra minúscula.")
        
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            raise ValidationError("La contraseña debe contener al menos un carácter especial.")

    def get_help_text(self):
        return "Tu contraseña debe contener al menos una mayúscula, una minúscula y un carácter especial."

class NameValidator:
    def __call__(self, value):
        # Allow letters (including accents like á, é, í, ó, ú, ñ), spaces, and hyphens.
        # Disallow numbers and most special characters.
        if not re.match(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-]+$', value):
            raise ValidationError(
                "El nombre solo puede contener letras, espacios y guiones."
            )
        
        # Prevent very short names (e.g., "A")
        if len(value.strip()) < 2:
            raise ValidationError("El nombre es demasiado corto.")

    def get_help_text(self):
        return "El nombre no debe contener números ni caracteres especiales."
    
class AdvancedEmailValidator:
    def __call__(self, value):
        # 1. Basic format check (redundant but safe)
        if not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', value):
            raise ValidationError("Ingresa un correo electrónico válido.")

        # 2. Block common burner/disposable email domains
        # This prevents users from creating infinite "free" accounts
        disposable_domains = [
            'mailinator.com', 'yopmail.com', 'tempmail.com', 
            'guerrillamail.com', '10minutemail.com'
        ]
        domain = value.split('@')[-1].lower()
        if domain in disposable_domains:
            raise ValidationError(
                "No se permiten correos temporales. Por favor usa un correo institucional o personal."
            )

    def get_help_text(self):
        return "El correo debe ser una dirección válida y no temporal."