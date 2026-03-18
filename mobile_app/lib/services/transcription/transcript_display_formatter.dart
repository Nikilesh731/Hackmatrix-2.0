class TranscriptDisplayFormatter {
  static String formatForDisplay(String rawTranscript) {
    if (rawTranscript.isEmpty) return '';

    // Clean up common transcription artifacts
    String cleaned = rawTranscript.trim();
    
    // Remove multiple consecutive spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    // Add proper spacing after punctuation
    cleaned = cleaned.replaceAll(RegExp(r'([.!?])\s*([a-zA-Z])'), r'$1 $2');
    
    // Capitalize first letter of sentences
    final sentences = cleaned.split(RegExp(r'[.!?]+'));
    for (int i = 0; i < sentences.length; i++) {
      if (sentences[i].isNotEmpty) {
        sentences[i] = sentences[i][0].toUpperCase() + sentences[i].substring(1).toLowerCase();
      }
    }
    
    // Rejoin with proper punctuation
    return sentences.join('. ').replaceAll(RegExp(r'\.\s*\.'), '.');
  }

  static String formatForStorage(String rawTranscript) {
    if (rawTranscript.isEmpty) return '';

    // More aggressive cleaning for storage
    String cleaned = rawTranscript.trim();
    
    // Remove filler words and repeated phrases
    final fillerWords = ['um', 'uh', 'er', 'like', 'you know', 'I mean'];
    for (final filler in fillerWords) {
      cleaned = cleaned.replaceAll(RegExp('\\b$filler\\b', caseSensitive: false), '');
    }
    
    // Normalize whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    // Fix common transcription errors
    cleaned = cleaned.replaceAll(RegExp(r'\b(\w+)\s+\1\b', caseSensitive: false), r'$1'); // Remove repeated words
    
    return cleaned.trim();
  }

  static String extractKeyPhrases(String transcript) {
    if (transcript.isEmpty) return '';

    // Simple keyword extraction for medical terms
    final medicalKeywords = [
      'pain', 'headache', 'fever', 'cough', 'nausea', 'vomiting',
      'fatigue', 'weakness', 'dizziness', 'chest pain', 'shortness of breath',
      'medication', 'prescription', 'treatment', 'symptoms', 'diagnosis',
      'blood pressure', 'heart rate', 'temperature', 'allergic', 'allergy'
    ];

    final foundPhrases = <String>[];
    final words = transcript.toLowerCase().split(RegExp(r'\W+'));
    
    for (final keyword in medicalKeywords) {
      if (transcript.toLowerCase().contains(keyword)) {
        foundPhrases.add(keyword);
      }
    }

    return foundPhrases.join(', ');
  }

  static Map<String, dynamic> extractMetadata(String transcript) {
    return {
      'wordCount': transcript.split(RegExp(r'\s+')).length,
      'characterCount': transcript.length,
      'estimatedDuration': _estimateDuration(transcript),
      'keyPhrases': extractKeyPhrases(transcript),
      'hasMedicalTerms': _containsMedicalTerms(transcript),
      'formattedAt': DateTime.now().toIso8601String(),
    };
  }

  static Duration _estimateDuration(String transcript) {
    // Average speaking rate is ~150 words per minute
    final wordCount = transcript.split(RegExp(r'\s+')).length;
    final estimatedMinutes = wordCount / 150.0;
    return Duration(seconds: (estimatedMinutes * 60).round());
  }

  static bool _containsMedicalTerms(String transcript) {
    final medicalTerms = [
      'pain', 'ache', 'discomfort', 'symptom', 'diagnosis', 'treatment',
      'medication', 'prescription', 'therapy', 'condition', 'disease',
      'infection', 'inflammation', 'fever', 'temperature', 'pressure',
      'allergy', 'allergic', 'reaction', 'side effect', 'dosage'
    ];

    final lowerTranscript = transcript.toLowerCase();
    return medicalTerms.any((term) => lowerTranscript.contains(term));
  }
}
