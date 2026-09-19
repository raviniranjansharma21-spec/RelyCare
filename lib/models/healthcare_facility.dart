/// Facility types in the healthcare hierarchy.
enum FacilityType {
  phc, // Primary Health Centre
  chc, // Community Health Centre
  districtHospital, // District / Referral Hospital
}

/// Represents a healthcare facility (PHC, CHC, or District Hospital).
class HealthcareFacility {
  final String id;
  final String code; // e.g. "PHC-104", "DH-02"
  final String name;
  final FacilityType type;
  final String district;
  final String? contactPhone;

  const HealthcareFacility({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.district,
    this.contactPhone,
  });

  // TODO: Add toMap() / fromMap() and toJson() / fromJson() serialization methods.
}
