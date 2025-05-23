class Visit {
  final String id;
  final String chiefComplaint;
  final String diagnosis;
  final String? doctorNotes;
  final DateTime visitDate;
  final String userId;

  Visit({
    String? id,
    required this.chiefComplaint,
    required this.diagnosis,
    this.doctorNotes,
    required this.visitDate,
    required this.userId,
  }) : id = id ?? 'VST-${DateTime.now().millisecondsSinceEpoch}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chiefComplaint': chiefComplaint,
      'diagnosis': diagnosis,
      'doctorNotes': doctorNotes,
      'visitDate': visitDate.toIso8601String(),
      'userId': userId,
    };
  }

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      chiefComplaint: json['chiefComplaint'],
      diagnosis: json['diagnosis'],
      doctorNotes: json['doctorNotes'],
      visitDate: DateTime.parse(json['visitDate']),
      userId: json['userId'],
    );
  }

  Visit copyWith({
    String? id,
    String? chiefComplaint,
    String? diagnosis,
    String? doctorNotes,
    DateTime? visitDate,
    String? userId,
  }) {
    return Visit(
      id: id ?? this.id,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      diagnosis: diagnosis ?? this.diagnosis,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      visitDate: visitDate ?? this.visitDate,
      userId: userId ?? this.userId,
    );
  }
}
