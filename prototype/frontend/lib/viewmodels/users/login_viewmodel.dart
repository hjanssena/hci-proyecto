import 'package:bebeia_front/models/users/user.dart';
import 'package:bebeia_front/repositories/users/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

enum LoginState { initial, loading, success, error }

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository);

  User? _currentUser;
  User? get currentUser => _currentUser;

  // State properties
  LoginState _state = LoginState.initial;
  LoginState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  /// Toggles the password visibility for the Login Screen
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Handles the login logic using email and password [cite: 20]
  Future<void> login(String email, String password) async {
    // 1. Basic validation before calling the API [cite: 20]
    if (email.isEmpty || password.isEmpty) {
      _setServiceError("Email and password are required.");
      return;
    }

    _setLoading(true);

    try {
      // 2. Call the repository to exchange credentials for JWT
      final tokens = await _authRepository.login(email, password);

      _state = LoginState.success;
      _errorMessage = null;

      Map<String, dynamic> payload = JwtDecoder.decode(tokens.accessToken);
      _currentUser = User.fromJwt(payload);
    } catch (e) {
      _state = LoginState.error;
      _errorMessage = "Login failed. Please check your credentials."; //
    } finally {
      _setLoading(false);
    }
  }

  void updateUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _state = loading ? LoginState.loading : _state;
    notifyListeners();
  }

  void _setServiceError(String message) {
    _state = LoginState.error;
    _errorMessage = message;
    notifyListeners();
  }
}
