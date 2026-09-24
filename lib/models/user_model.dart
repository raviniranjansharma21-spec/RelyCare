/// Represents an authenticated RelyCare staff user returned by FastAPI backend.
class UserModel {
  final int id;
  final String username;
  final String? email;
  final String? phone;
  final String role;
  final String facilityId;
  final bool isActive;
  final String? facilityName;
  final String? facilityType;

  const UserModel({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    required this.role,
    required this.facilityId,
    required this.isActive,
    this.facilityName,
    this.facilityType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final facility = json['facility'] as Map<String, dynamic>?;
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: (json['username'] ?? '').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: (json['role'] ?? 'PHC_STAFF').toString(),
      facilityId: (json['facility_id'] ?? '').toString(),
      isActive: json['is_active'] as bool? ?? true,
      facilityName: facility?['name']?.toString(),
      facilityType: facility?['facility_type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'facility_id': facilityId,
      'is_active': isActive,
      'facility': facilityName != null
          ? {
              'facility_code': facilityId,
              'name': facilityName,
              'facility_type': facilityType,
            }
          : null,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, role: $role, facilityId: $facilityId)';
  }
}
