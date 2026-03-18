class Patient {
  final String id;
  final String fullName;
  final int? age;
  final String? gender;
  final String? phone;
  final String? address;
  final String? bloodGroup;
  final String? allergies;
  final String? chronicConditions;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Patient({
    required this.id,
    required this.fullName,
    this.age,
    this.gender,
    this.phone,
    this.address,
    this.bloodGroup,
    this.allergies,
    this.chronicConditions,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      bloodGroup: json['blood_group'] as String?,
      allergies: json['allergies'] as String?,
      chronicConditions: json['chronic_conditions'] as String?,
      notes: json['notes'] as String?,
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
      'full_name': fullName,
      'age': age,
      'gender': gender,
      'phone': phone,
      'address': address,
      'blood_group': bloodGroup,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
