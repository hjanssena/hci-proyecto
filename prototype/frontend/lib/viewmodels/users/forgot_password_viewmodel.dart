import 'package:bebeia_front/repositories/users/auth_repository.dart';
import 'package:flutter/material.dart';

enum ForgotPasswordState { initial, loading, codeSent, success, error }

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  ForgotPasswordViewModel(this._authRepository);

  ForgotPasswordState _state = ForgotPasswordState.initial;
  ForgotPasswordState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Track the UI step explicitly (1 = Email, 2 = Code/Password)
  int _step = 1;
  int get step => _step;

  // Clears the state so the screen is fresh next time
  void resetFlow() {
    _state = ForgotPasswordState.initial;
    _step = 1;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> requestReset(String email) async {
    if (email.isEmpty) {
      _setError("Email is required.");
      return;
    }

    _setLoading();
    try {
      await _authRepository.requestPasswordReset(email);
      _state = ForgotPasswordState.codeSent;
      _step = 2; // Advance to Step 2
      _errorMessage = null;
    } catch (e) {
      _setError("Failed to request password reset.");
    } finally {
      notifyListeners();
    }
  }

  Future<void> confirmReset(
    String code,
    String newPassword,
    String confirmPassword,
  ) async {
    if (newPassword != confirmPassword) {
      _setError("Passwords do not match.");
      return;
    }

    if (code.length != 6) {
      _setError("Verification code must be exactly 6 characters.");
      return;
    }

    _setLoading();
    try {
      await _authRepository.confirmPasswordReset(code, newPassword);
      _state = ForgotPasswordState.success;
      _errorMessage = null;
    } catch (e) {
      _setError("Failed to reset password. Please check your code.");
    } finally {
      notifyListeners();
    }
  }

  void _setLoading() {
    _state = ForgotPasswordState.loading;
    notifyListeners();
  }

  void _setError(String message) {
    _state = ForgotPasswordState.error;
    _errorMessage = message;
  }
}
