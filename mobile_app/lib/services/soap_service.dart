import 'dart:async';
import '../config/app_config.dart';
import 'transcription/transcript_display_formatter.dart';
import 'soap/soap_models.dart';
import 'soap/llm/groq_clinical_extractor.dart';

class SOAPService {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  static Future<SOAPNotes> generateSOAPFromTranscript(String transcript) async {
    if (transcript.trim().isEmpty) {
      return SOAPNotes(
        subjective: '',
        objective: '',
        assessment: '',
        plan: '',
        createdAt: DateTime.now(),
      );
    }

    try {
      print('Generating SOAP from transcript (${transcript.length} characters)');
      
      // Clean transcript for processing
      final cleanedTranscript = TranscriptDisplayFormatter.formatForStorage(transcript);
      
      // Extract SOAP using Groq
      final soapNotes = await GroqClinicalExtractor.extractSOAPFromTranscript(cleanedTranscript);
      
      print('SOAP generation completed successfully');
      return soapNotes;
      
    } catch (e) {
      print('Error generating SOAP: $e');
      
      // Fallback to basic extraction
      return _fallbackSOAPExtraction(transcript);
    }
  }

  static Future<SOAPNotes> enhanceSOAPWithClinicalData(
    SOAPNotes initialSOAP,
    Map<String, dynamic> clinicalData,
  ) async {
    try {
      print('Enhancing SOAP with clinical data');
      
      final enhancedSOAP = await GroqClinicalExtractor.enhanceSOAPWithClinicalData(
        initialSOAP,
        clinicalData,
      );
      
      return enhancedSOAP;
    } catch (e) {
      print('Error enhancing SOAP: $e');
      return initialSOAP;
    }
  }

  static Future<SOAPExtractionResult> extractSOAPWithValidation(
    String transcript, {
    bool validateCompleteness = true,
  }) async {
    final errors = <String>[];
    
    try {
      final soapNotes = await generateSOAPFromTranscript(transcript);
      
      if (validateCompleteness) {
        errors.addAll(_validateSOAPCompleteness(soapNotes));
      }
      
      return SOAPExtractionResult(
        soapNotes: soapNotes,
        errors: errors,
        metadata: {
          'transcriptLength': transcript.length,
          'processedAt': DateTime.now().toIso8601String(),
          'validationEnabled': validateCompleteness,
        },
        confidence: _calculateConfidence(soapNotes, transcript),
      );
      
    } catch (e) {
      errors.add('SOAP extraction failed: ${e.toString()}');
      
      return SOAPExtractionResult(
        errors: errors,
        metadata: {
          'error': e.toString(),
          'failedAt': DateTime.now().toIso8601String(),
        },
        confidence: 0.0,
      );
    }
  }

  static SOAPNotes _fallbackSOAPExtraction(String transcript) {
    print('Using fallback SOAP extraction');
    
    // Basic pattern-based extraction as fallback
    final subjective = _extractSubjective(transcript);
    final objective = _extractObjective(transcript);
    final assessment = _extractAssessment(transcript);
    final plan = _extractPlan(transcript);
    
    return SOAPNotes(
      subjective: subjective,
      objective: objective,
      assessment: assessment,
      plan: plan,
      createdAt: DateTime.now(),
      metadata: {
        'extractionMethod': 'fallback',
        'fallbackReason': 'LLM extraction failed',
      },
    );
  }

  static String _extractSubjective(String transcript) {
    // Look for patient-reported symptoms and complaints
    final subjectivePatterns = [
      RegExp(r'patient\s+(?:reports|complains?|says?)\s+[:\-]?\s*([^\.!?]+)', caseSensitive: false),
      RegExp(r'(?:feeling|feels?|symptoms?|pain|discomfort)\s+[:\-]?\s*([^\.!?]+)', caseSensitive: false),
      RegExp(r'(?:i have|i am)\s+([^\.!?]+)', caseSensitive: false),
    ];
    
    for (final pattern in subjectivePatterns) {
      final match = pattern.firstMatch(transcript);
      if (match != null) {
        return match.group(1)?.trim() ?? '';
      }
    }
    
    return 'Patient complaints and symptoms extracted from transcript';
  }

  static String _extractObjective(String transcript) {
    // Look for vital signs and observable data
    final objectivePatterns = [
      RegExp(r'(?:temperature|temp|fever)\s+[:\-]?\s*(\d+(?:\.\d+)?)', caseSensitive: false),
      RegExp(r'(?:blood\s+pressure|bp)\s+[:\-]?\s*(\d+\/\d+)', caseSensitive: false),
      RegExp(r'(?:heart\s+rate|pulse)\s+[:\-]?\s*(\d+)', caseSensitive: false),
    ];
    
    final objectiveData = <String>[];
    for (final pattern in objectivePatterns) {
      final matches = pattern.allMatches(transcript);
      for (final match in matches) {
        objectiveData.add(match.group(0) ?? '');
      }
    }
    
    return objectiveData.isNotEmpty 
        ? objectiveData.join(', ')
        : 'Vital signs and objective findings from examination';
  }

  static String _extractAssessment(String transcript) {
    // Look for diagnostic terms and assessments
    final assessmentPatterns = [
      RegExp(r'(?:diagnosis|assessment|impression)\s+[:\-]?\s*([^\.!?]+)', caseSensitive: false),
      RegExp(r'(?:appears?|seems?|likely|probably)\s+([^\.!?]+)', caseSensitive: false),
    ];
    
    for (final pattern in assessmentPatterns) {
      final match = pattern.firstMatch(transcript);
      if (match != null) {
        return match.group(1)?.trim() ?? '';
      }
    }
    
    return 'Clinical assessment based on symptoms and examination';
  }

  static String _extractPlan(String transcript) {
    // Look for treatment plans and recommendations
    final planPatterns = [
      RegExp(r'(?:treatment|plan|recommend|prescribe)\s+[:\-]?\s*([^\.!?]+)', caseSensitive: false),
      RegExp(r'(?:will\s+(?:give|prescribe|recommend|start))\s+([^\.!?]+)', caseSensitive: false),
    ];
    
    for (final pattern in planPatterns) {
      final match = pattern.firstMatch(transcript);
      if (match != null) {
        return match.group(1)?.trim() ?? '';
      }
    }
    
    return 'Treatment plan and follow-up recommendations';
  }

  static List<String> _validateSOAPCompleteness(SOAPNotes soap) {
    final errors = <String>[];
    
    if (soap.subjective.trim().isEmpty) {
      errors.add('Subjective section is empty');
    }
    if (soap.objective.trim().isEmpty) {
      errors.add('Objective section is empty');
    }
    if (soap.assessment.trim().isEmpty) {
      errors.add('Assessment section is empty');
    }
    if (soap.plan.trim().isEmpty) {
      errors.add('Plan section is empty');
    }
    
    // Check minimum length requirements
    if (soap.subjective.length < 10) {
      errors.add('Subjective section too brief');
    }
    if (soap.plan.length < 10) {
      errors.add('Plan section too brief');
    }
    
    return errors;
  }

  static double _calculateConfidence(SOAPNotes soap, String transcript) {
    double confidence = 0.0;
    
    // Base confidence from content completeness
    if (soap.subjective.isNotEmpty) confidence += 0.25;
    if (soap.objective.isNotEmpty) confidence += 0.25;
    if (soap.assessment.isNotEmpty) confidence += 0.25;
    if (soap.plan.isNotEmpty) confidence += 0.25;
    
    // Adjust based on content quality
    final totalLength = soap.subjective.length + 
                     soap.objective.length + 
                     soap.assessment.length + 
                     soap.plan.length;
    
    if (totalLength > 100) confidence += 0.1;
    if (totalLength > 300) confidence += 0.1;
    
    // Ensure confidence doesn't exceed 1.0
    return confidence.clamp(0.0, 1.0);
  }
}
