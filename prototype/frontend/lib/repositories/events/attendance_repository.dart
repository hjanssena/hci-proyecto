import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../models/events/attendance.dart';

class AttendanceRepository {
  final ApiClient _api;
  AttendanceRepository(this._api);

  Future<List<AttendanceDocument>> getDocuments() async {
    final response = await _api.get('/attendance-documents/');
    final results = response.data is List ? response.data : response.data['results'] ?? response.data;
    return (results as List).map((d) => AttendanceDocument.fromJson(d)).toList();
  }

  Future<Map<String, dynamic>> uploadAttendance(int eventId, List<int> fileBytes, String fileName) async {
    final formData = FormData.fromMap({
      'event': eventId,
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _api.post('/attendance-documents/', data: formData);
    return response.data;
  }

  Future<List<Attendance>> getRecords({int? eventId, bool? attended, String? search}) async {
    final params = <String, String>{};
    if (eventId != null) params['event'] = eventId.toString();
    if (attended != null) params['attended'] = attended.toString().capitalize();
    if (search != null && search.isNotEmpty) params['search'] = search;
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final path = query.isEmpty ? '/attendance-records/' : '/attendance-records/?$query';
    final response = await _api.get(path);
    final results = response.data is List ? response.data : response.data['results'] ?? response.data;
    return (results as List).map((r) => Attendance.fromJson(r)).toList();
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
