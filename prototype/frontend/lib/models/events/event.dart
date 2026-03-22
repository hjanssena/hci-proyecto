import 'package:flutter/material.dart';
import 'event_professor.dart';

class Event {
  final int? id;
  final String name;
  final int categoryId;
  final String? categoryName;
  final String description;
  final String status;
  final String startDate;
  final String endDate;
  final String schedule;
  final int durationHours;
  final String modality;
  final String locationOrLink;
  final int maxCapacity;
  final int minInscriptions;
  final double price;
  final bool epcPoints;
  final String accreditationRequirements;
  final bool byContract;
  final String? withOrganization;
  final String? cancellationReason;
  final String? cancellationDate;
  final List<EventProfessor> professors;

  Event({
    this.id,
    required this.name,
    required this.categoryId,
    this.categoryName,
    required this.description,
    this.status = 'IN',
    required this.startDate,
    required this.endDate,
    required this.schedule,
    required this.durationHours,
    required this.modality,
    required this.locationOrLink,
    required this.maxCapacity,
    required this.minInscriptions,
    required this.price,
    this.epcPoints = false,
    required this.accreditationRequirements,
    this.byContract = false,
    this.withOrganization,
    this.cancellationReason,
    this.cancellationDate,
    this.professors = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'] ?? '',
      categoryId: json['category'] is int ? json['category'] : 0,
      categoryName: json['category_name'],
      description: json['description'] ?? '',
      status: json['status'] ?? 'IN',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      schedule: json['schedule'] ?? '',
      durationHours: json['duration_hours'] ?? 0,
      modality: json['modality'] ?? 'PR',
      locationOrLink: json['location_or_link'] ?? '',
      maxCapacity: json['max_capacity'] ?? 0,
      minInscriptions: json['min_inscriptions'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      epcPoints: json['epc_points'] ?? false,
      accreditationRequirements: json['accreditation_requirements'] ?? '',
      byContract: json['by_contract'] ?? false,
      withOrganization: json['with_organization'],
      cancellationReason: json['cancellation_reason'],
      cancellationDate: json['cancellation_date'],
      professors: (json['event_professors'] as List?)
              ?.map((p) => EventProfessor.fromJson(p))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': categoryId,
    'description': description,
    'start_date': startDate,
    'end_date': endDate,
    'schedule': schedule,
    'duration_hours': durationHours,
    'modality': modality,
    'location_or_link': locationOrLink,
    'max_capacity': maxCapacity,
    'min_inscriptions': minInscriptions,
    'price': price.toStringAsFixed(2),
    'epc_points': epcPoints,
    'accreditation_requirements': accreditationRequirements,
    'by_contract': byContract,
    'with_organization': withOrganization,
    'professors_data': professors.map((p) => p.toWritableJson()).toList(),
  };

  String get statusDisplay => statusLabels[status] ?? status;
  String get modalityDisplay => modalityLabels[modality] ?? modality;
  Color get statusColor => statusColors[status] ?? Colors.grey;

  static const Map<String, String> statusLabels = {
    'IN': 'En fase de inscripciones',
    'CO': 'Confirmado',
    'AR': 'Archivado',
    'CA': 'Cancelado',
  };

  static const Map<String, Color> statusColors = {
    'IN': Colors.blue,
    'CO': Colors.green,
    'AR': Colors.grey,
    'CA': Colors.red,
  };

  static const Map<String, String> modalityLabels = {
    'PR': 'Presencial',
    'VI': 'Virtual',
    'HY': 'Híbrida',
  };
}
