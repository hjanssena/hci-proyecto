import 'package:bebeia_front/models/users/register_request.dart';
import 'package:bebeia_front/repositories/users/auth_repository.dart';
import 'package:flutter/material.dart';

enum RegisterState { initial, loading, success, error }

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  RegisterViewModel(this._authRepository);

  RegisterState _state = RegisterState.initial;
  RegisterState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Main registration logic with client-side validation
  Future<void> register({
    required String email,
    required String name,
    required String lastName,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.trim().isEmpty || lastName.trim().isEmpty) {
      _setError("Name and last name cannot be empty.");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _setError("Please enter a valid email address.");
      return;
    }

    if (!validatePassword(password)) return;

    if (password != confirmPassword) {
      _setError("Passwords do not match.");
      return;
    }

    _setLoading(true);

    try {
      final request = RegisterRequest(
        email: email,
        name: name,
        lastName: lastName,
        password: password,
        hasAcceptedTerms: true,
        timeTermsAccepted: DateTime.now(),
      );

      // Call repository to create account
      await _authRepository.register(request);

      _state = RegisterState.success;
      _errorMessage = null;
    } catch (e) {
      _state = RegisterState.error;
      _errorMessage =
          "Registration failed. This email might already be in use.";
    } finally {
      _setLoading(false);
    }
  }

  bool validatePassword(String password) {
    final passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{10,}$',
    );

    if (!passwordRegExp.hasMatch(password)) {
      _setError(
        "Password must be at least 10 characters, include uppercase, lowercase, numbers, and a symbol (!@#\$&*~).",
      );
      return false;
    }
    return true;
  }

  void _setLoading(bool loading) {
    _state = loading ? RegisterState.loading : _state;
    notifyListeners();
  }

  void _setError(String message) {
    _state = RegisterState.error;
    _errorMessage = message;
    notifyListeners();
  }
}
