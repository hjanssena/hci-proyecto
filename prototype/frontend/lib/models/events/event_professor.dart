import 'professor.dart';

class EventProfessor {
  final int? id;
  final Professor professor;
  final int hours;

  EventProfessor({
    this.id,
    required this.professor,
    required this.hours,
  });

  factory EventProfessor.fromJson(Map<String, dynamic> json) {
    return EventProfessor(
      id: json['id'],
      professor: Professor.fromJson(json['professor']),
      hours: json['hours'],
    );
  }

  Map<String, dynamic> toWritableJson() => {
    'professor_id': professor.id,
    'hours': hours,
  };
}
