import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../soap_models.dart';

class GroqClinicalExtractor {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  static Future<SOAPNotes> extractSOAPFromTranscript(String transcript) async {
    if (transcript.trim().isEmpty) {
      return _emptySOAP();
    }

    print('Extracting SOAP from transcript using Groq');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _makeGroqRequest(_buildSOAPExtractionPrompt(transcript));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final soapData = _parseSOAPResponse(data);
          
          print('SOAP extraction successful on attempt $attempt');
          return soapData;
        } else {
          throw Exception('Groq API error: ${response.statusCode}');
        }
      } catch (e) {
        print('SOAP extraction attempt $attempt failed: $e');
        
        if (attempt == _maxRetries) {
          return _fallbackSOAPExtraction(transcript);
        }
        
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    return _emptySOAP();
  }

  static Future<SOAPNotes> enhanceSOAPWithClinicalData(
    SOAPNotes initialSOAP,
    Map<String, dynamic> clinicalData,
  ) async {
    print('Enhancing SOAP with clinical data');

    try {
      final response = await _makeGroqRequest(_buildEnhancementPrompt(initialSOAP, clinicalData));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final enhancedSOAP = _parseSOAPResponse(data);
        
        print('SOAP enhancement successful');
        return enhancedSOAP;
      } else {
        print('Enhancement failed, returning original SOAP');
        return initialSOAP;
      }
    } catch (e) {
      print('SOAP enhancement error: $e');
      return initialSOAP;
    }
  }

  static Future<http.Response> _makeGroqRequest(String prompt) async {
    final headers = {
      'Authorization': 'Bearer ${AppConfig.groqApiKey}',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'model': 'llama3-70b-8192',
      'messages': [
        {
          'role': 'system',
          'content': _getSystemPrompt(),
        },
        {
          'role': 'user',
          'content': prompt,
        }
      ],
      'max_tokens': 2000,
      'temperature': 0.3,
    });

    return await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: headers,
      body: body,
    ).timeout(_timeout);
  }

  static String _buildSOAPExtractionPrompt(String transcript) {
    return '''
Please analyze the following medical consultation transcript and extract structured SOAP notes.

TRANSCRIPT:
"""
$transcript
"""

Extract the following sections:
1. Subjective (S): Patient's reported symptoms, complaints, and feelings
2. Objective (O): Observable clinical findings, vital signs, examination results
3. Assessment (A): Clinical diagnosis, interpretation of findings
4. Plan (P): Treatment recommendations, medications, follow-up instructions

Return ONLY a valid JSON object with this exact structure:
{
  "subjective": "patient's reported symptoms and complaints",
  "objective": "observable clinical findings and vital signs",
  "assessment": "clinical diagnosis and interpretation",
  "plan": "treatment recommendations and follow-up"
}

Important:
- Be concise but comprehensive
- Use medical terminology appropriately
- If information is not available for a section, use "Not specified"
- Do not invent information not present in the transcript
- Return only the JSON object, no additional text
''';
  }

  static String _buildEnhancementPrompt(SOAPNotes soap, Map<String, dynamic> clinicalData) {
    return '''
Please enhance the following SOAP notes with additional clinical context and ensure medical accuracy.

CURRENT SOAP NOTES:
${_formatSOAPForPrompt(soap)}

ADDITIONAL CLINICAL DATA:
${json.encode(clinicalData)}

Please:
1. Review and enhance each SOAP section for clinical accuracy
2. Add relevant medical details that might be missing
3. Ensure consistency between sections
4. Improve medical terminology and phrasing
5. Maintain the original meaning while enhancing quality

Return ONLY a valid JSON object with the enhanced SOAP structure:
{
  "subjective": "enhanced subjective section",
  "objective": "enhanced objective section", 
  "assessment": "enhanced assessment section",
  "plan": "enhanced plan section"
}

Do not invent new symptoms or findings. Only enhance what's already present.
''';
  }

  static String _getSystemPrompt() {
    return '''
You are a medical AI assistant specialized in extracting structured SOAP (Subjective, Objective, Assessment, Plan) notes from medical consultation transcripts.

Your role is to:
1. Accurately extract patient-reported information for Subjective section
2. Identify objective clinical findings and observations
3. Formulate appropriate clinical assessment based on findings
4. Recommend appropriate treatment plans and follow-up care

Guidelines:
- Use precise medical terminology
- Be thorough but concise
- Maintain professional medical documentation standards
- Ensure all sections are clinically coherent
- Do not invent information not present in the transcript
- Prioritize patient safety and evidence-based recommendations
''';
  }

  static SOAPNotes _parseSOAPResponse(Map<String, dynamic> data) {
    try {
      final content = data['choices'][0]['message']['content'] as String;
      
      // Extract JSON from the response
      final jsonMatch = RegExp(r'\{.*\}').firstMatch(content);
      if (jsonMatch != null) {
        final soapJson = json.decode(jsonMatch.group(0)!) as Map<String, dynamic>;
        
        return SOAPNotes(
          subjective: soapJson['subjective'] as String? ?? '',
          objective: soapJson['objective'] as String? ?? '',
          assessment: soapJson['assessment'] as String? ?? '',
          plan: soapJson['plan'] as String? ?? '',
          createdAt: DateTime.now(),
          metadata: {
            'extractionMethod': 'groq_llm',
            'model': 'llama3-70b-8192',
            'extractedAt': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      print('Error parsing SOAP response: $e');
    }

    return _emptySOAP();
  }

  static SOAPNotes _fallbackSOAPExtraction(String transcript) {
    print('Using fallback SOAP extraction');
    
    // Simple rule-based extraction
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
        'extractionMethod': 'fallback_rules',
        'fallbackReason': 'LLM extraction failed',
      },
    );
  }

  static String _extractSubjective(String transcript) {
    final patterns = [
      RegExp(r'patient\s+(?:reports|complains?|says?)\s+[:\-]?\s*([^.!?]+)', caseSensitive: false),
      RegExp(r'(?:feeling|feels?|symptoms?)\s+[:\-]?\s*([^.!?]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(transcript);
      if (match != null) {
        return match.group(1)?.trim() ?? 'Patient symptoms from consultation';
      }
    }
    
    return 'Patient complaints and symptoms from consultation';
  }

  static String _extractObjective(String transcript) {
    final patterns = [
      RegExp(r'(?:temperature|vitals?|examination)\s+[:\-]?\s*([^.!?]+)', caseSensitive: false),
      RegExp(r'(?:blood\s+pressure|pulse|heart\s+rate)\s+[:\-]?\s*([^.!?]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(transcript);
      if (match != null) {
        return match.group(1)?.trim() ?? 'Clinical examination findings';
      }
    }
    
    return 'Clinical examination findings';
  }

  static String _extractAssessment(String transcript) {
    final patterns = [
      RegExp(r'(?:diagnosis|assessment|impression)\s+[:\-]?\s*([^.!?]+)', caseSensitive: false),
      RegExp(r'(?:likely|probably|appears?)\s+([^.!?]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(transcript);
      if (match != null) {
        return match.group(1)?.trim() ?? 'Clinical assessment';
      }
    }
    
    return 'Clinical assessment based on findings';
  }

  static String _extractPlan(String transcript) {
    final patterns = [
      RegExp(r'(?:treatment|plan|recommend|prescribe)\s+[:\-]?\s*([^.!?]+)', caseSensitive: false),
      RegExp(r'(?:will\s+(?:give|prescribe|recommend))\s+([^.!?]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(transcript);
      if (match != null) {
        return match.group(1)?.trim() ?? 'Treatment plan';
      }
    }
    
    return 'Treatment and follow-up plan';
  }

  static SOAPNotes _emptySOAP() {
    return SOAPNotes(
      subjective: '',
      objective: '',
      assessment: '',
      plan: '',
      createdAt: DateTime.now(),
    );
  }

  static String _formatSOAPForPrompt(SOAPNotes soap) {
    return '''
Subjective: ${soap.subjective}
Objective: ${soap.objective}
Assessment: ${soap.assessment}
Plan: ${soap.plan}
''';
  }
}
