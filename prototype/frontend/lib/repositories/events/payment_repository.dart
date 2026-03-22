import '../../core/api_client.dart';
import '../../models/events/payment.dart';

class PaymentRepository {
  final ApiClient _api;
  PaymentRepository(this._api);

  Future<List<Payment>> getPayments({String? status, int? eventId, String? search}) async {
    final params = <String, String>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (eventId != null) params['enrollment__event'] = eventId.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final path = query.isEmpty ? '/payments/' : '/payments/?$query';
    final response = await _api.get(path);
    final results = response.data is List ? response.data : response.data['results'] ?? response.data;
    return (results as List).map((p) => Payment.fromJson(p)).toList();
  }

  Future<void> confirmPayment(int id) async {
    await _api.post('/payments/$id/confirm/');
  }

  Future<void> rejectPayment(int id, String reason) async {
    await _api.post('/payments/$id/reject/', data: {'reason': reason});
  }

  Future<void> requestVoucher(int id) async {
    await _api.post('/payments/$id/request_voucher/');
  }
}
