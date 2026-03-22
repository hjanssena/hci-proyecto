import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/events/enrollment.dart';
import '../../models/events/event.dart';
import '../../repositories/events/enrollment_repository.dart';
import '../../repositories/events/event_repository.dart';

class EnrollmentViewModel extends ChangeNotifier {
  final EnrollmentRepository _enrollmentRepo;
  final EventRepository _eventRepo;
  EnrollmentViewModel(this._enrollmentRepo, this._eventRepo);

  List<Enrollment> enrollments = [];
  List<Event> events = [];
  bool isLoading = false;
  String? errorMessage;
  int? selectedEventId;
  String? statusFilter;
  String searchQuery = '';

  Future<void> loadEvents() async {
    try {
      events = await _eventRepo.getEvents();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchEnrollments() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      enrollments = await _enrollmentRepo.getEnrollments(
        eventId: selectedEventId,
        status: statusFilter,
        search: searchQuery,
      );
      isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      isLoading = false;
      errorMessage = _extractError(e);
      notifyListeners();
    }
  }

  void setEventFilter(int? eventId) {
    selectedEventId = eventId;
    fetchEnrollments();
  }

  void setStatusFilter(String? filter) {
    statusFilter = filter;
    fetchEnrollments();
  }

  void setSearch(String query) {
    searchQuery = query;
    fetchEnrollments();
  }

  Future<String?> approveEnrollment(int id) async {
    try {
      await _enrollmentRepo.approveEnrollment(id);
      await fetchEnrollments();
      return null;
    } on DioException catch (e) {
      return _extractError(e);
    }
  }

  Future<String?> rejectEnrollment(int id, String reason) async {
    try {
      await _enrollmentRepo.rejectEnrollment(id, reason);
      await fetchEnrollments();
      return null;
    } on DioException catch (e) {
      return _extractError(e);
    }
  }

  Future<String?> requestInfo(int id, String details) async {
    try {
      await _enrollmentRepo.requestInfo(id, details);
      await fetchEnrollments();
      return null;
    } on DioException catch (e) {
      return _extractError(e);
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['error'] ?? data['detail'] ?? 'Error inesperado';
    }
    return 'Error de conexión. Intente nuevamente.';
  }
}
