import 'package:bebeia_front/models/users/user.dart';
import 'package:bebeia_front/repositories/users/user_repository.dart';
import 'package:flutter/material.dart';

enum ProfileState { initial, loading, success, error, deleted }

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  ProfileViewModel(this._userRepository);

  User? _user;
  User? get user => _user;

  ProfileState _state = ProfileState.initial;
  ProfileState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Fetches the current profile data [cite: 31]
  Future<void> fetchProfile(String userId) async {
    _setLoading(true);
    try {
      _user = await _userRepository.getProfile(userId);
      _state = ProfileState.success;
    } catch (e) {
      _setError("Could not load profile data.");
    } finally {
      _setLoading(false);
    }
  }

  /// Updates Name and Last Name
  Future<bool> updateBasicInfo(
    String userId,
    String name,
    String lastName,
  ) async {
    if (name.trim().isEmpty || lastName.trim().isEmpty) {
      _errorMessage = "Los campos no pueden estar vacíos.";
      _state = ProfileState.error;
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      await _userRepository.updateProfile(userId, {
        'name': name.trim(),
        'last_name': lastName.trim(),
      });

      _state = ProfileState.success;
      return true;
    } catch (e) {
      _errorMessage = "No se pudo actualizar la información.";
      _state = ProfileState.error;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Handles the authenticated password change
  Future<bool> changePassword(
    String current,
    String next,
    String confirm,
  ) async {
    _setLoading(true);
    try {
      await _userRepository.changePassword(current, next);
      _state = ProfileState.success;
      return true;
    } catch (e) {
      // If backend returns 401, it means "Contraseña actual incorrecta"
      _errorMessage =
          "La contraseña actual es incorrecta o los datos son inválidos.";
      _state = ProfileState.error;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Triggers account soft-deletion and PII anonymization [cite: 54, 57]
  Future<void> deleteAccount(String password, bool confirmed) async {
    if (!confirmed) {
      _setError("You must check the confirmation box.");
      return;
    }

    _setLoading(true);
    try {
      await _userRepository.deleteAccount(password);
      _state = ProfileState.deleted; // Triggers navigation to login/welcome
    } catch (e) {
      _setError("Incorrect password. Account could not be deleted.");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (loading) _state = ProfileState.loading;
    notifyListeners();
  }

  void _setError(String message) {
    _state = ProfileState.error;
    _errorMessage = message;
    notifyListeners();
  }
}
