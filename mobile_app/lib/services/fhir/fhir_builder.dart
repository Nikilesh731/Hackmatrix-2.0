import 'dart:math';
import '../soap/soap_models.dart';
import 'fhir_models.dart';

class FhirBuilder {
  static FhirBundle buildBundle(SOAPNotes soapNotes) {
    final bundleId = _generateId();
    final timestamp = DateTime.now();

    final entries = <FhirEntry>[];

    // Add Patient resource
    final patientResource = _buildPatientResource(soapNotes);
    entries.add(FhirEntry(
      fullUrl: 'urn:uuid:$bundleId-patient',
      resource: FhirResource(
        resourceType: 'Patient',
        id: patientResource.id,
        resource: patientResource.toJson(),
      ),
    ));

    // Add Observation resources from subjective data
    final subjectiveObservations = _buildObservationsFromSubjective(soapNotes.subjective);
    entries.addAll(subjectiveObservations.map((obs) => FhirEntry(
      fullUrl: 'urn:uuid:${_generateId()}-observation',
      resource: FhirResource(
        resourceType: 'Observation',
        id: obs.id,
        resource: obs.toJson(),
      ),
    )));

    // Add Condition resources from assessment
    final assessmentConditions = _buildConditionsFromAssessment(soapNotes.assessment);
    entries.addAll(assessmentConditions.map((condition) => FhirEntry(
      fullUrl: 'urn:uuid:${_generateId()}-condition',
      resource: FhirResource(
        resourceType: 'Condition',
        id: condition.id,
        resource: condition.toJson(),
      ),
    )));

    // Add ServiceRequest resources from plan
    final planServices = _buildServiceRequestsFromPlan(soapNotes.plan);
    entries.addAll(planServices.map((service) => FhirEntry(
      fullUrl: 'urn:uuid:${_generateId()}-service',
      resource: FhirResource(
        resourceType: 'ServiceRequest',
        id: _generateId(),
        resource: {
          'resourceType': 'ServiceRequest',
          'status': 'active',
          'intent': 'order',
          'code': {'text': service},
          'subject': {'reference': 'Patient/patient'},
          'occurrenceDateTime': DateTime.now().toIso8601String(),
        },
        timestamp: DateTime.now(),
      ),
    )));

    return FhirBundle(
      id: bundleId,
      timestamp: timestamp,
      entry: entries,
      metadata: {
        'source': 'Ambient AI Scribe',
        'generatedAt': timestamp.toIso8601String(),
        'soapVersion': '1.0',
        'totalEntries': entries.length,
      },
    );
  }

  static FhirPatient _buildPatientResource(SOAPNotes soapNotes) {
    return FhirPatient(
      id: _generateId(),
      name: 'Patient from consultation',
      gender: 'unknown',
      birthDate: DateTime.now().subtract(const Duration(days: 365 * 30)), // Default age
    );
  }

  static List<FhirObservation> _buildObservationsFromSubjective(String subjective) {
    final observations = <FhirObservation>[];

    // Extract symptoms as observations
    final symptoms = _extractSymptoms(subjective);
    for (int i = 0; i < symptoms.length; i++) {
      observations.add(FhirObservation(
        id: _generateId(),
        code: symptoms[i],
        subject: 'patient',
        value: 'present',
        effectiveDateTime: DateTime.now(),
        category: 'symptom',
      ));
    }

    // Add general subjective observation
    observations.add(FhirObservation(
      id: _generateId(),
      code: 'Subjective complaints',
      subject: 'patient',
      value: subjective,
      effectiveDateTime: DateTime.now(),
      category: 'subjective',
    ));

    return observations;
  }

  static List<FhirCondition> _buildConditionsFromAssessment(String assessment) {
    final conditions = <FhirCondition>[];

    // Extract potential diagnoses
    final diagnoses = _extractDiagnoses(assessment);
    for (int i = 0; i < diagnoses.length; i++) {
      conditions.add(FhirCondition(
        id: _generateId(),
        code: diagnoses[i],
        subject: 'patient',
        severity: _determineSeverity(diagnoses[i]),
        category: 'diagnosis',
      ));
    }

    return conditions;
  }

  static List<FhirResource> _buildServiceRequestsFromPlan(String plan) {
    final services = <FhirResource>[];

    // Extract treatment recommendations
    final treatments = _extractTreatments(plan);
    for (int i = 0; i < treatments.length; i++) {
      services.add(FhirResource(
        resourceType: 'ServiceRequest',
        id: _generateId(),
        resource: {
          'status': 'active',
          'intent': 'order',
          'code': {'text': treatments[i]},
          'subject': {'reference': 'Patient/patient'},
          'occurrenceDateTime': DateTime.now().toIso8601String(),
        },
        timestamp: DateTime.now(),
      ));
    }

    return services;
  }

  static List<String> _extractSymptoms(String subjective) {
    final symptoms = <String>[];
    
    // Common symptom patterns
    final symptomPatterns = [
      RegExp(r'(?:pain|ache|discomfort|soreness)\s+(?:in|of)?\s*(\w+)', caseSensitive: false),
      RegExp(r'(?:fever|temperature|temp)\s+(?:of)?\s*(\d+(?:\.\d+)?)', caseSensitive: false),
      RegExp(r'(?:cough|coughing|breathing|shortness\s+of\s+breath)', caseSensitive: false),
      RegExp(r'(?:nausea|vomiting|dizziness|headache)', caseSensitive: false),
    ];

    for (final pattern in symptomPatterns) {
      final matches = pattern.allMatches(subjective);
      for (final match in matches) {
        final symptom = match.group(0) ?? match.group(1) ?? '';
        if (symptom.isNotEmpty && !symptoms.contains(symptom)) {
          symptoms.add(symptom);
        }
      }
    }

    return symptoms;
  }

  static List<String> _extractDiagnoses(String assessment) {
    final diagnoses = <String>[];
    
    // Common diagnosis patterns
    final diagnosisPatterns = [
      RegExp(r'(?:diagnosis|assessment|impression)\s+(?:is|:)?\s*([^.!?]+)', caseSensitive: false),
      RegExp(r'(?:likely|probably|suggests?)\s+([^.!?]+)', caseSensitive: false),
      RegExp(r'(?:consistent\s+with|indicates?)\s+([^.!?]+)', caseSensitive: false),
    ];

    for (final pattern in diagnosisPatterns) {
      final matches = pattern.allMatches(assessment);
      for (final match in matches) {
        final diagnosis = match.group(1) ?? match.group(0) ?? '';
        if (diagnosis.isNotEmpty && !diagnoses.contains(diagnosis)) {
          diagnoses.add(diagnosis);
        }
      }
    }

    return diagnoses;
  }

  static List<String> _extractTreatments(String plan) {
    final treatments = <String>[];
    
    // Common treatment patterns
    final treatmentPatterns = [
      RegExp(r'(?:prescribe|prescription|give)\s+([^.!?]+)', caseSensitive: false),
      RegExp(r'(?:recommend|suggest|advise)\s+([^.!?]+)', caseSensitive: false),
      RegExp(r'(?:treatment|therapy|medication)\s*[:\-]?\s*([^.!?]+)', caseSensitive: false),
    ];

    for (final pattern in treatmentPatterns) {
      final matches = pattern.allMatches(plan);
      for (final match in matches) {
        final treatment = match.group(1) ?? match.group(0) ?? '';
        if (treatment.isNotEmpty && !treatments.contains(treatment)) {
          treatments.add(treatment);
        }
      }
    }

    return treatments;
  }

  static String _determineSeverity(String diagnosis) {
    final lowerDiagnosis = diagnosis.toLowerCase();
    
    if (lowerDiagnosis.contains(RegExp(r'(?:severe|acute|emergency|critical)', caseSensitive: false))) {
      return 'severe';
    } else if (lowerDiagnosis.contains(RegExp(r'(?:moderate|mild|chronic)', caseSensitive: false))) {
      return 'moderate';
    } else {
      return 'mild';
    }
  }

  static String _generateId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${timestamp}_${random.nextInt(10000)}';
  }

  static Map<String, dynamic> buildDiagnosticReport(SOAPNotes soapNotes) {
    return {
      'soapNotes': soapNotes.toJson(),
      'fhirBundle': buildBundle(soapNotes).toJson(),
      'summary': {
        'totalSymptoms': _extractSymptoms(soapNotes.subjective).length,
        'totalDiagnoses': _extractDiagnoses(soapNotes.assessment).length,
        'totalTreatments': _extractTreatments(soapNotes.plan).length,
        'generatedAt': DateTime.now().toIso8601String(),
      },
    };
  }
}
