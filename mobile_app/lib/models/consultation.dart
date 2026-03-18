class Consultation {
  final String id;
  final String doctorId;
  final String patientId;
  final String? queueItemId;
  final String status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? finalTranscript;
  final String? soapSubjective;
  final String? soapObjective;
  final String? soapAssessment;
  final String? soapPlan;
  final Map<String, dynamic>? structuredExtraction;
  final Map<String, dynamic>? specialistRecommendations;
  final Map<String, dynamic>? medicationSuggestions;
  final List<Map<String, dynamic>>? confirmedMedications;
  final Map<String, dynamic>? prescriptionPayload;
  final DateTime createdAt;
  final DateTime updatedAt;

  Consultation({
    required this.id,
    required this.doctorId,
    required this.patientId,
    this.queueItemId,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.finalTranscript,
    this.soapSubjective,
    this.soapObjective,
    this.soapAssessment,
    this.soapPlan,
    this.structuredExtraction,
    this.specialistRecommendations,
    this.medicationSuggestions,
    this.confirmedMedications,
    this.prescriptionPayload,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      patientId: json['patient_id'] as String,
      queueItemId: json['queue_item_id'] as String?,
      status: json['status'] as String,
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at'] as String) 
          : null,
      endedAt: json['ended_at'] != null 
          ? DateTime.parse(json['ended_at'] as String) 
          : null,
      finalTranscript: json['final_transcript'] as String?,
      soapSubjective: json['soap_subjective'] as String?,
      soapObjective: json['soap_objective'] as String?,
      soapAssessment: json['soap_assessment'] as String?,
      soapPlan: json['soap_plan'] as String?,
      structuredExtraction: json['structured_extraction'] as Map<String, dynamic>?,
      specialistRecommendations: json['specialist_recommendations'] as Map<String, dynamic>?,
      medicationSuggestions: json['medication_suggestions'] as Map<String, dynamic>?,
      confirmedMedications: json['confirmed_medications'] as List<Map<String, dynamic>>?,
      prescriptionPayload: json['prescription_payload'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'queue_item_id': queueItemId,
      'status': status,
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'final_transcript': finalTranscript,
      'soap_subjective': soapSubjective,
      'soap_objective': soapObjective,
      'soap_assessment': soapAssessment,
      'soap_plan': soapPlan,
      'structured_extraction': structuredExtraction,
      'specialist_recommendations': specialistRecommendations,
      'medication_suggestions': medicationSuggestions,
      'confirmed_medications': confirmedMedications,
      'prescription_payload': prescriptionPayload,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
