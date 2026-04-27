import 'package:bebeia_front/core/api_client.dart';
import 'package:bebeia_front/models/users/user.dart';

class UserRepository {
  final ApiClient _api;

  UserRepository(this._api);

  /// Fetches the current user's profile data
  Future<User> getProfile(String userId) async {
    final response = await _api.get('/auth/users/$userId/');
    return User.fromJson(response.data);
  }

  /// Updates profile fields like name, last name, or logo
  Future<User> updateProfile(String userId, Map<String, dynamic> data) async {
    // Note: API ignores role_level or has_verified_email if sent
    final response = await _api.patch('/auth/users/$userId/', data: data);
    return User.fromJson(response.data);
  }

  /// Changes the password for an authenticated user
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _api.post(
      '/auth/password-change/',
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }

  /// Triggers account soft-deletion and PII anonymization
  Future<void> deleteAccount(String password) async {
    await _api.post(
      '/auth/users/delete-account/',
      data: {
        'password': password, // Confirmation required for deletion
      },
    );
  }
}
