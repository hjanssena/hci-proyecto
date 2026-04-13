import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/events/category.dart' as models;
import '../../models/events/event.dart';
import '../../models/events/professor.dart';
import '../../repositories/events/event_repository.dart';
import '../../repositories/events/category_repository.dart';
import '../../repositories/events/professor_repository.dart';

enum EventFormState { initial, loading, saving, saved, error }

class EventFormViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;
  final CategoryRepository _categoryRepo;
  final ProfessorRepository _professorRepo;

  EventFormViewModel(this._eventRepo, this._categoryRepo, this._professorRepo);

  EventFormState state = EventFormState.initial;
  String? errorMessage;
  List<models.Category> categories = [];
  List<Professor> professors = [];
  Event? editingEvent;
  bool isCloneMode = false;

  Future<void> loadFormData() async {
    state = EventFormState.loading;
    notifyListeners();
    try {
      categories = await _categoryRepo.getCategories(isActive: true);
      professors = await _professorRepo.getProfessors();
      state = EventFormState.initial;
      notifyListeners();
    } on DioException catch (e) {
      state = EventFormState.error;
      errorMessage = _extractError(e);
      notifyListeners();
    }
  }

  Future<void> loadEventForEdit(int id) async {
    state = EventFormState.loading;
    notifyListeners();
    try {
      categories = await _categoryRepo.getCategories(isActive: true);
      professors = await _professorRepo.getProfessors();
      editingEvent = await _eventRepo.getEvent(id);
      isCloneMode = false;
      state = EventFormState.initial;
      notifyListeners();
    } on DioException catch (e) {
      state = EventFormState.error;
      errorMessage = _extractError(e);
      notifyListeners();
    }
  }

  Future<void> loadEventForClone(int id) async {
    state = EventFormState.loading;
    notifyListeners();
    try {
      categories = await _categoryRepo.getCategories(isActive: true);
      professors = await _professorRepo.getProfessors();
      editingEvent = await _eventRepo.getEventForClone(id);
      isCloneMode = true;
      state = EventFormState.initial;
      notifyListeners();
    } on DioException catch (e) {
      state = EventFormState.error;
      errorMessage = _extractError(e);
      notifyListeners();
    }
  }

  Future<String?> saveEvent(Map<String, dynamic> data, {int? eventId}) async {
    state = EventFormState.saving;
    errorMessage = null;
    notifyListeners();
    try {
      if (eventId != null && !isCloneMode) {
        await _eventRepo.updateEvent(eventId, data);
      } else {
        await _eventRepo.createEvent(data);
      }
      state = EventFormState.saved;
      notifyListeners();
      return null;
    } on DioException catch (e) {
      state = EventFormState.error;
      errorMessage = _extractError(e);
      notifyListeners();
      return errorMessage;
    }
  }

  void reset() {
    editingEvent = null;
    isCloneMode = false;
    state = EventFormState.initial;
    errorMessage = null;
    notifyListeners();
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final messages = <String>[];
      data.forEach((key, value) {
        if (value is List) {
          messages.add('${_fieldLabel(key)}: ${value.join(", ")}');
        } else {
          messages.add(value.toString());
        }
      });
      return messages.join('\n');
    }
    return 'Error de conexión. Intente nuevamente.';
  }

  String _fieldLabel(String key) {
    const labels = {
      'name': 'Nombre',
      'category': 'Categoría',
      'start_date': 'Fecha de inicio',
      'end_date': 'Fecha de fin',
      'schedules_data': 'Horarios',
      'price': 'Precio',
      'max_capacity': 'Capacidad máxima',
      'min_inscriptions': 'Mínimo de inscripciones',
      'duration_hours': 'Duración',
    };
    return labels[key] ?? key;
  }
}
