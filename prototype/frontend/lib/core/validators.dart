class Validators {
  /// Enforces: 10+ chars, Upper/Lower case, Numbers, and Symbols.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }

    // Pattern: 10+ chars, at least one: lower, upper, digit, and symbol
    final passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{10,}$',
    );

    if (!passwordRegExp.hasMatch(value)) {
      return 'Tu contraseña debe contener lo siguiente:';
    }

    return null;
  }

  /// Basic Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Correo electrónico requerido';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Requerido';
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? validateName(
    String? value, {
    String fieldName = 'Este campo',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return '$fieldName debe tener al menos 2 letras';
    }

    // Regex breakdown:
    // ^[a-zA-Zàáâäãåą...]+$ : Allows Latin letters and common international accents
    // [ \-'] : Allows spaces, hyphens, and apostrophes (e.g., "O'Connor" or "Jean-Luc")
    final nameRegExp = RegExp(
      r"^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð \-']+$",
    );

    if (!nameRegExp.hasMatch(trimmedValue)) {
      return '$fieldName no debe contener números o símbolos especiales';
    }

    return null;
  }
}

class PasswordRequirements {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSymbol;

  PasswordRequirements({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSymbol,
  });

  bool get isAllValid =>
      hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSymbol;

  static PasswordRequirements check(String value) {
    return PasswordRequirements(
      hasMinLength: value.length >= 10,
      hasUppercase: value.contains(RegExp(r'[A-Z]')),
      hasLowercase: value.contains(RegExp(r'[a-z]')),
      hasNumber: value.contains(RegExp(r'[0-9]')),
      hasSymbol: value.contains(RegExp(r'[!@#\$&*~]')),
    );
  }
}
