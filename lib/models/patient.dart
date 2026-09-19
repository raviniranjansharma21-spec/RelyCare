/// Represents basic demographic information for a patient.
/// Strictly respects data minimization principles.
class Patient {
  final String id;
  final String fullName;
  final int age;
  final String gender;
  final String villageOrLocation;
  final String? contactNumber;
  final String? emergencyContact;
  final DateTime createdAt;

  const Patient({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.villageOrLocation,
    this.contactNumber,
    this.emergencyContact,
    required this.createdAt,
  });

  // TODO: Add toMap() / fromMap() serialization for SQLite.
  // TODO: Add toJson() / fromJson() serialization for FastAPI backend.
  // TODO: Add copyWith() for immutability.
}
