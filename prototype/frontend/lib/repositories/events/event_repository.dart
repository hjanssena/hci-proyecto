import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../models/events/event.dart';

class EventRepository {
  final ApiClient _api;
  EventRepository(this._api);

  Future<List<Event>> getEvents({String? search, String? status, String? modality}) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (modality != null && modality.isNotEmpty) params['modality'] = modality;
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final path = query.isEmpty ? '/events/' : '/events/?$query';
    final response = await _api.get(path);
    final results = response.data is List ? response.data : response.data['results'] ?? response.data;
    return (results as List).map((e) => Event.fromJson(e)).toList();
  }

  Future<Event> getEvent(int id) async {
    final response = await _api.get('/events/$id/');
    return Event.fromJson(response.data);
  }

  Future<Event> createEvent(Map<String, dynamic> data) async {
    final response = await _api.post('/events/', data: data);
    return Event.fromJson(response.data);
  }

  Future<Event> updateEvent(int id, Map<String, dynamic> data) async {
    final response = await _api.put('/events/$id/', data: data);
    return Event.fromJson(response.data);
  }

  Future<void> archiveEvent(int id) async {
    await _api.post('/events/$id/archive/');
  }

  Future<void> cancelEvent(int id, String reason) async {
    await _api.post('/events/$id/cancel/', data: {'reason': reason});
  }

  Future<Event> getEventForClone(int id) async {
    final response = await _api.get('/events/$id/clone/');
    return Event.fromJson(response.data);
  }

  Future<Uint8List> downloadAttendanceTemplate(int id) async {
    final response = await _api.get(
      '/events/$id/attendance_template/',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data);
  }
}
