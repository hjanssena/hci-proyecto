import 'dart:typed_data';
import 'package:bebeia_front/core/api_client.dart';
import 'package:dio/dio.dart';

class MediaRepository {
  final ApiClient _api;
  final String _baseUrl = "http://127.0.0.1:8000";

  // 1. Create the in-memory cache
  final Map<String, Uint8List> _imageCache = {};

  MediaRepository(this._api);

  Future<Uint8List> fetchSecureImage(String relativeUrl) async {
    final String fullUrl = relativeUrl.startsWith('http')
        ? relativeUrl
        : '$_baseUrl${relativeUrl.startsWith('/') ? '' : '/'}$relativeUrl';

    // 2. Check the cache FIRST before hitting the network
    if (_imageCache.containsKey(fullUrl)) {
      return _imageCache[fullUrl]!;
    }

    try {
      final response = await _api.get(
        fullUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = Uint8List.fromList(response.data);

      // 3. Save the downloaded bytes to the cache
      _imageCache[fullUrl] = bytes;

      return bytes;
    } catch (e) {
      throw Exception('Failed to fetch secure image: $e');
    }
  }
}
