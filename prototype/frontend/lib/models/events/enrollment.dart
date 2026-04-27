import 'package:flutter/material.dart';

class Enrollment {
  final int id;
  final int eventId;
  final String? eventName;
  final String applicantName;
  final String? documentsUrl;
  final String status;
  final String? rejectionReason;

  Enrollment({
    required this.id,
    required this.eventId,
    this.eventName,
    required this.applicantName,
    this.documentsUrl,
    required this.status,
    this.rejectionReason,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'],
      eventId: json['event'],
      eventName: json['event_name'],
      applicantName: json['applicant_name'] ?? '',
      documentsUrl: json['documents'],
      status: json['status'] ?? 'PE',
      rejectionReason: json['rejection_reason'],
    );
  }

  String get statusDisplay => statusLabels[status] ?? status;
  Color get statusColor => statusColors[status] ?? Colors.grey;

  static const Map<String, String> statusLabels = {
    'PE': 'Pendiente de Revisión',
    'IR': 'Información Requerida',
    'AP': 'Aprobada',
    'RE': 'Rechazada',
  };

  static const Map<String, Color> statusColors = {
    'PE': Colors.orange,
    'IR': Colors.blue,
    'AP': Colors.green,
    'RE': Colors.red,
  };
}
