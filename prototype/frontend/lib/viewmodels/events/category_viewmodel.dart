import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/events/category.dart' as models;
import '../../repositories/events/category_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repo;
  CategoryViewModel(this._repo);

  List<models.Category> categories = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  bool? activeFilter;

  Future<void> fetchCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      categories = await _repo.getCategories(search: searchQuery, isActive: activeFilter);
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
    fetchCategories();
  }

  void setActiveFilter(bool? filter) {
    activeFilter = filter;
    fetchCategories();
  }

  Future<String?> createCategory(String name) async {
    try {
      await _repo.createCategory(name);
      await fetchCategories();
      return null;
    } on DioException catch (e) {
      return _extractError(e);
    }
  }

  Future<String?> updateCategory(int id, {String? name, bool? isActive}) async {
    try {
      await _repo.updateCategory(id, name: name, isActive: isActive);
      await fetchCategories();
      return null;
    } on DioException catch (e) {
      return _extractError(e);
    }
  }

  Future<String?> archiveCategory(int id) async {
    try {
      await _repo.archiveCategory(id);
      await fetchCategories();
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
