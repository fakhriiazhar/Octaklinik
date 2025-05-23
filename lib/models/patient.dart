import 'visit.dart';

class Patient {
  final String id;
  final String fullName;
  final DateTime dateOfBirth;
  final String gender;
  final String phoneNumber;
  final String address;
  final String? medicalHistory;
  final List<Visit> visits;
  final DateTime createdAt;
  final String userId;

  Patient({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.phoneNumber,
    required this.address,
    this.medicalHistory,
    List<Visit>? visits,
    DateTime? createdAt,
    required this.userId,
  })  : visits = visits ?? [],
        createdAt = createdAt ?? DateTime.now();

  String get age {
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    return '$age y/o';
  }

  DateTime get lastVisit {
    return visits.isNotEmpty ? visits.first.visitDate : DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'phoneNumber': phoneNumber,
      'address': address,
      'medicalHistory': medicalHistory,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      fullName: json['fullName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      medicalHistory: json['medicalHistory'],
      visits: json['visits'] == null
          ? []
          : (json['visits'] as List)
              .map((v) => Visit.fromJson(v as Map<String, dynamic>))
              .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      userId: json['userId'],
    );
  }

  Patient copyWith({
    String? id,
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? phoneNumber,
    String? address,
    String? medicalHistory,
    List<Visit>? visits,
    DateTime? createdAt,
    String? userId,
  }) {
    return Patient(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      visits: visits ?? this.visits,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
