import 'package:flutter/material.dart';

class Payment {
  final int id;
  final int enrollmentId;
  final String applicantName;
  final String eventName;
  final double amount;
  final String? proofOfPaymentUrl;
  final String status;
  final String? rejectionReason;

  Payment({
    required this.id,
    required this.enrollmentId,
    required this.applicantName,
    required this.eventName,
    required this.amount,
    this.proofOfPaymentUrl,
    required this.status,
    this.rejectionReason,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      enrollmentId: json['enrollment'],
      applicantName: json['applicant_name'] ?? '',
      eventName: json['event_name'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      proofOfPaymentUrl: json['proof_of_payment'],
      status: json['status'] ?? 'PE',
      rejectionReason: json['rejection_reason'],
    );
  }

  String get statusDisplay => statusLabels[status] ?? status;
  Color get statusColor => statusColors[status] ?? Colors.grey;

  static const Map<String, String> statusLabels = {
    'PE': 'Pendiente de Verificación',
    'CO': 'Confirmada',
    'RE': 'Pago Rechazado',
    'RIP': 'Reembolso en proceso',
    'RC': 'Reembolso completado',
  };

  static const Map<String, Color> statusColors = {
    'PE': Colors.orange,
    'CO': Colors.green,
    'RE': Colors.red,
    'RIP': Colors.purple,
    'RC': Colors.teal,
  };
}
