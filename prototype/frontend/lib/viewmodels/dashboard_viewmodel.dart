import 'package:bebeia_front/repositories/users/auth_repository.dart';
import 'package:flutter/material.dart';

enum DashboardState { initial, loading, success, error }

class DashboardViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  DashboardViewModel(this._authRepository);

  DashboardState _state = DashboardState.initial;
  DashboardState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage; // Added missing getter

  String? _successMessage;
  String? get successMessage => _successMessage; // Added for the API response

  Future<void> resendVerification() async {
    _state = DashboardState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Stores the success detail from the backend
      _successMessage = await _authRepository.resendVerificationEmail();
      _state = DashboardState.success;
    } catch (e) {
      _errorMessage = "No se pudo reenviar el enlace. Intenta más tarde.";
      _state = DashboardState.error;
    } finally {
      notifyListeners();
    }
  }

  void resetState() {
    _state = DashboardState.initial;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
