import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/events/attendance.dart';
import '../../models/events/event.dart';
import '../../repositories/events/attendance_repository.dart';
import '../../repositories/events/event_repository.dart';

class AttendanceViewModel extends ChangeNotifier {
  final AttendanceRepository _attendanceRepo;
  final EventRepository _eventRepo;
  AttendanceViewModel(this._attendanceRepo, this._eventRepo);

  List<Event> events = [];
  List<Attendance> records = [];
  bool isLoading = false;
  bool isUploading = false;
  String? errorMessage;
  String? successMessage;
  int? selectedEventId;

  Future<void> loadEvents() async {
    isLoading = true;
    notifyListeners();
    try {
      events = await _eventRepo.getEvents();
      isLoading = false;
      notifyListeners();
    } catch (_) {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecords(int eventId) async {
    selectedEventId = eventId;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      records = await _attendanceRepo.getRecords(eventId: eventId);
      isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      isLoading = false;
      errorMessage = _extractError(e);
      notifyListeners();
    }
  }

  Future<Uint8List?> downloadTemplate(int eventId) async {
    try {
      return await _eventRepo.downloadAttendanceTemplate(eventId);
    } on DioException catch (e) {
      errorMessage = _extractError(e);
      notifyListeners();
      return null;
    }
  }

  Future<String?> uploadAttendance(int eventId, List<int> fileBytes, String fileName) async {
    isUploading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
    try {
      final result = await _attendanceRepo.uploadAttendance(eventId, fileBytes, fileName);
      successMessage = result['detail'] ?? 'Asistencias cargadas exitosamente.';
      isUploading = false;
      await fetchRecords(eventId);
      return null;
    } on DioException catch (e) {
      isUploading = false;
      errorMessage = _extractError(e);
      notifyListeners();
      return errorMessage;
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
