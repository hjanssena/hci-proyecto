class EventSchedule {
  final int? id;
  final int day; // 0=Lunes, 1=Martes, ..., 6=Domingo
  final String? dayDisplay;
  final String startTime; // HH:MM
  final String endTime; // HH:MM

  EventSchedule({
    this.id,
    required this.day,
    this.dayDisplay,
    required this.startTime,
    required this.endTime,
  });

  factory EventSchedule.fromJson(Map<String, dynamic> json) {
    return EventSchedule(
      id: json['id'],
      day: json['day'] ?? 0,
      dayDisplay: json['day_display'],
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  Map<String, dynamic> toWritableJson() => {
    'day': day,
    'start_time': startTime,
    'end_time': endTime,
  };

  static const Map<int, String> dayLabels = {
    0: 'Lunes',
    1: 'Martes',
    2: 'Miércoles',
    3: 'Jueves',
    4: 'Viernes',
    5: 'Sábado',
    6: 'Domingo',
  };

  String get dayLabel => dayDisplay ?? dayLabels[day] ?? 'Día $day';
}
