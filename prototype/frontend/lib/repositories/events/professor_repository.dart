import '../../core/api_client.dart';
import '../../models/events/professor.dart';

class ProfessorRepository {
  final ApiClient _api;
  ProfessorRepository(this._api);

  Future<List<Professor>> getProfessors() async {
    final response = await _api.get('/professors/');
    final results = response.data is List ? response.data : response.data['results'] ?? response.data;
    return (results as List).map((p) => Professor.fromJson(p)).toList();
  }
}
