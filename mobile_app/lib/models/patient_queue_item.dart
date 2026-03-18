import 'patient.dart';

class PatientQueueItem {
  final String id;
  final String patientId;
  final String? assignedDoctorId;
  final String queueStatus;
  final String priorityLabel;
  final int? tokenNumber;
  final String? reasonForVisit;
  final DateTime? scheduledFor;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Patient? patient;

  PatientQueueItem({
    required this.id,
    required this.patientId,
    this.assignedDoctorId,
    required this.queueStatus,
    required this.priorityLabel,
    this.tokenNumber,
    this.reasonForVisit,
    this.scheduledFor,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.patient,
  });

  factory PatientQueueItem.fromJson(Map<String, dynamic> json) {
    return PatientQueueItem(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      assignedDoctorId: json['assigned_doctor_id'] as String?,
      queueStatus: json['queue_status'] as String,
      priorityLabel: json['priority_label'] as String,
      tokenNumber: json['token_number'] as int?,
      reasonForVisit: json['reason_for_visit'] as String?,
      scheduledFor: json['scheduled_for'] != null 
          ? DateTime.parse(json['scheduled_for'] as String) 
          : null,
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at'] as String) 
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      patient: json['patients'] != null ? Patient.fromJson(json['patients']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'assigned_doctor_id': assignedDoctorId,
      'queue_status': queueStatus,
      'priority_label': priorityLabel,
      'token_number': tokenNumber,
      'reason_for_visit': reasonForVisit,
      'scheduled_for': scheduledFor?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
