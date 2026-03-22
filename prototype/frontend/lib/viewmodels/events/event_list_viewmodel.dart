import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/events/event.dart';
import '../../repositories/events/event_repository.dart';

class EventListViewModel extends ChangeNotifier {
  final EventRepository _repo;
  EventListViewModel(this._repo);

  List<Event> events = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  String? statusFilter;
  String? modalityFilter;

  Future<void> fetchEvents() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      events = await _repo.getEvents(
        search: searchQuery,
        status: statusFilter,
        modality: modalityFilter,
      );
      isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      isLoading = false;
      errorMessage = _extractError(e);
      notifyListeners();
    }
  }

  void setSearch(String query) {
    searchQuery = query;
    fetchEvents();
  }

  void setStatusFilter(String? filter) {
    statusFilter = filter;
    fetchEvents();
  }

  void setModalityFilter(String? filter) {
    modalityFilter = filter;
    fetchEvents();
  }

  Future<String?> archiveEvent(int id) async {
    try {
      await _repo.archiveEvent(id);
      await fetchEvents();
      return null;
    } on DioException catch (e) {
      return _extractError(e);
    }
  }

  Future<String?> cancelEvent(int id, String reason) async {
    try {
      await _repo.cancelEvent(id, reason);
      await fetchEvents();
      return null;
    } on DioException catch (e) {
      return _extractError(e);
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['error'] ?? data['detail'] ?? data.values.first?.toString() ?? 'Error inesperado';
    }
    return 'Error de conexión. Intente nuevamente.';
  }
}
