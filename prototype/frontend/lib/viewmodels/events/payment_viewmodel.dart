import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/events/payment.dart';
import '../../repositories/events/payment_repository.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentRepository _repo;
  PaymentViewModel(this._repo);

  List<Payment> payments = [];
  bool isLoading = false;
  String? errorMessage;
  String? statusFilter;
  int? eventFilter;
  String searchQuery = '';

  Future<void> fetchPayments() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      payments = await _repo.getPayments(
        status: statusFilter,
        eventId: eventFilter,
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

  void setStatusFilter(String? filter) {
    statusFilter = filter;
    fetchPayments();
  }

  void setSearch(String query) {
    searchQuery = query;
    fetchPayments();
  }

  Future<String?> confirmPayment(int id) async {
    try {
      await _repo.confirmPayment(id);
      await fetchPayments();
      return null;
    } on DioException catch (e) {
      return _extractError(e);
    }
  }

  Future<String?> rejectPayment(int id, String reason) async {
    try {
      await _repo.rejectPayment(id, reason);
      await fetchPayments();
      return null;
    } on DioException catch (e) {
      return _extractError(e);
    }
  }

  Future<String?> requestVoucher(int id) async {
    try {
      await _repo.requestVoucher(id);
      await fetchPayments();
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
