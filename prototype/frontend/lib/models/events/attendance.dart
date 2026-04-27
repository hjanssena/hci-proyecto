class Attendance {
  final int id;
  final int eventId;
  final String participantName;
  final bool attended;

  Attendance({
    required this.id,
    required this.eventId,
    required this.participantName,
    required this.attended,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      eventId: json['event'],
      participantName: json['participant_name'] ?? '',
      attended: json['attended'] ?? false,
    );
  }
}

class AttendanceDocument {
  final int id;
  final int eventId;
  final String eventName;
  final String fileUrl;
  final String uploadedAt;

  AttendanceDocument({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.fileUrl,
    required this.uploadedAt,
  });

  factory AttendanceDocument.fromJson(Map<String, dynamic> json) {
    return AttendanceDocument(
      id: json['id'],
      eventId: json['event'],
      eventName: json['event_name'] ?? '',
      fileUrl: json['file'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }
}
