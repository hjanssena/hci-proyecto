import '../../core/api_client.dart';
import '../../models/events/category.dart';

class CategoryRepository {
  final ApiClient _api;
  CategoryRepository(this._api);

  Future<List<Category>> getCategories({String? search, bool? isActive}) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (isActive != null) params['is_active'] = isActive.toString().capitalize();
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final path = query.isEmpty ? '/categories/' : '/categories/?$query';
    final response = await _api.get(path);
    final results = response.data is List ? response.data : response.data['results'] ?? response.data;
    return (results as List).map((c) => Category.fromJson(c)).toList();
  }

  Future<Category> createCategory(String name) async {
    final response = await _api.post('/categories/', data: {'name': name});
    return Category.fromJson(response.data);
  }

  Future<Category> updateCategory(int id, {String? name, bool? isActive}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (isActive != null) data['is_active'] = isActive;
    final response = await _api.patch('/categories/$id/', data: data);
    return Category.fromJson(response.data);
  }

  Future<void> archiveCategory(int id) async {
    await _api.post('/categories/$id/archive/');
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
