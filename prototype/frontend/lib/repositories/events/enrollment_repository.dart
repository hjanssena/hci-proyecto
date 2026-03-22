import '../../core/api_client.dart';
import '../../models/events/enrollment.dart';

class EnrollmentRepository {
  final ApiClient _api;
  EnrollmentRepository(this._api);

  Future<List<Enrollment>> getEnrollments({int? eventId, String? status, String? search}) async {
    final params = <String, String>{};
    if (eventId != null) params['event'] = eventId.toString();
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final path = query.isEmpty ? '/enrollments/' : '/enrollments/?$query';
    final response = await _api.get(path);
    final results = response.data is List ? response.data : response.data['results'] ?? response.data;
    return (results as List).map((e) => Enrollment.fromJson(e)).toList();
  }

  Future<void> approveEnrollment(int id) async {
    await _api.post('/enrollments/$id/approve/');
  }

  Future<void> rejectEnrollment(int id, String reason) async {
    await _api.post('/enrollments/$id/reject/', data: {'reason': reason});
  }

  Future<void> requestInfo(int id, String details) async {
    await _api.post('/enrollments/$id/request_info/', data: {'details': details});
  }
}
