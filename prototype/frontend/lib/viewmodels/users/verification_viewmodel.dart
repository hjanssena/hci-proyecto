// Inside your Auth/Login ViewModel
import 'package:bebeia_front/repositories/users/auth_repository.dart';
import 'package:flutter/material.dart';

enum VerificationState { initial, loading, success, error }

class VerificationViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  VerificationState _state = VerificationState.initial;
  String? _message;

  VerificationViewModel(this._authRepository);

  VerificationState get state => _state;
  String? get message => _message;

  Future<void> verifyToken(String token) async {
    _state = VerificationState.loading;
    notifyListeners();

    try {
      await _authRepository.verifyEmail(token);
      _state = VerificationState.success;
      _message =
          "¡Correo verificado con éxito! Ahora puedes acceder a todas las funciones.";
    } catch (e) {
      _state = VerificationState.error;
      _message = "El enlace ha expirado o no es válido.";
    } finally {
      notifyListeners();
    }
  }
}
