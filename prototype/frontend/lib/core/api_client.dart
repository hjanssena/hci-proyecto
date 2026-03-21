import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  final String baseUrl = "http://127.0.0.1:8000/api/v1"; //

  ApiClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Better Public Route Check
          bool isPublicRoute() {
            final path = options.path;
            final method = options.method.toUpperCase();

            // Create Account is strictly POST to /users/
            if (path.endsWith('/users/') && method == 'POST') return true;

            // Other public endpoints
            if (path.contains('/login/')) return true;
            if (path.contains('/verify-email/')) return true;
            if (path.endsWith('/password-reset/')) return true;
            if (path.contains('/password-reset/confirm/')) return true;

            return false;
          }

          // 2. Add Token for Private Routes
          if (!isPublicRoute()) {
            String? token = await _storage.read(key: 'access_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          return handler.next(options);
        },

        // MISSING CODE RESTORED: The Token Refresh Logic
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            String? refreshToken = await _storage.read(key: 'refresh_token');

            if (refreshToken != null) {
              try {
                // Use a separate clean Dio instance to avoid interceptor infinite loops
                final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

                final response = await refreshDio.post(
                  '/token/refresh/',
                  data: {'refresh': refreshToken},
                );

                // Save the new access token
                final newAccessToken = response.data['access'];
                await _storage.write(
                  key: 'access_token',
                  value: newAccessToken,
                );

                // Retry the original failed request with the new token
                e.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final retryResponse = await _dio.fetch(e.requestOptions);

                return handler.resolve(retryResponse);
              } catch (refreshError) {
                // If the refresh token is also expired/invalid, wipe storage
                await _storage.deleteAll();
                // Depending on your setup, you might want to trigger a redirect to /login here
              }
            }
          }
          // Pass the error along if it wasn't a 401 or if refresh failed
          return handler.next(e);
        },
      ),
    );
  }

  // Wrapper methods for common HTTP verbs
  Future<Response> get(String path, {Options? options}) async {
    return await _dio.get(path, options: options);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data); //
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(path, data: data);
  }
}
