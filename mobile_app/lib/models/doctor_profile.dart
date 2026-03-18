class DoctorProfile {
  final String id;
  final String? authId;
  final String fullName;
  final String email;
  final String? phone;
  final String? specialization;
  final String? hospitalName;
  final String? registrationNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DoctorProfile({
    required this.id,
    this.authId,
    required this.fullName,
    required this.email,
    this.phone,
    this.specialization,
    this.hospitalName,
    this.registrationNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'] as String,
      authId: json['auth_id'] as String?,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      specialization: json['specialization'] as String?,
      hospitalName: json['hospital_name'] as String?,
      registrationNumber: json['registration_number'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_id': authId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'hospital_name': hospitalName,
      'registration_number': registrationNumber,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
