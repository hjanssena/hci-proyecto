import 'package:bebeia_front/core/api_client.dart';
import 'package:bebeia_front/models/users/auth_tokens.dart';
import 'package:bebeia_front/models/users/register_request.dart';
import 'package:bebeia_front/models/users/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final ApiClient _api;
  final _storage = const FlutterSecureStorage();

  AuthRepository(this._api);

  /// Registers a new user and returns the created User object
  Future<User> register(RegisterRequest request) async {
    final response = await _api.post('/auth/users/', data: request.toJson());
    return User.fromJson(response.data);
  }

  /// Verifies email using the token sent via email
  Future<void> verifyEmail(String token) async {
    await _api.post('/auth/verify-email/', data: {'token': token});
  }

  /// Performs login and persists tokens in secure storage
  Future<AuthTokens> login(String email, String password) async {
    final response = await _api.post(
      '/auth/login/',
      data: {'email': email, 'password': password},
    );

    final tokens = AuthTokens.fromJson(response.data);

    // Persist tokens for the ApiClient interceptor [cite: 21]
    await _storage.write(key: 'access_token', value: tokens.accessToken);
    await _storage.write(key: 'refresh_token', value: tokens.refreshToken);

    return tokens;
  }

  /// Blacklists the refresh token and clears local storage
  Future<void> logout() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken != null) {
      await _api.post('/auth/logout/', data: {'refresh': refreshToken});
    }
    await _storage.deleteAll();
  }

  /// Initiates password reset by sending a code to email
  Future<void> requestPasswordReset(String email) async {
    await _api.post('/auth/password-reset/', data: {'email': email});
  }

  /// Completes password reset with the 6-character code
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    await _api.post(
      '/auth/password-reset/confirm/',
      data: {'code': code, 'new_password': newPassword},
    );
  }

  Future<String> resendVerificationEmail() async {
    final response = await _api.post('/auth/request-verification/');
    return response.data['detail'] ?? 'Enlace enviado';
  }
}
