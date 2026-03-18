class SOAPNotes {
  final String subjective;
  final String objective;
  final String assessment;
  final String plan;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  SOAPNotes({
    required this.subjective,
    required this.objective,
    required this.assessment,
    required this.plan,
    this.createdAt,
    this.metadata,
  });

  factory SOAPNotes.fromJson(Map<String, dynamic> json) {
    return SOAPNotes(
      subjective: json['subjective'] as String? ?? '',
      objective: json['objective'] as String? ?? '',
      assessment: json['assessment'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjective': subjective,
      'objective': objective,
      'assessment': assessment,
      'plan': plan,
      'created_at': createdAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  SOAPNotes copyWith({
    String? subjective,
    String? objective,
    String? assessment,
    String? plan,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return SOAPNotes(
      subjective: subjective ?? this.subjective,
      objective: objective ?? this.objective,
      assessment: assessment ?? this.assessment,
      plan: plan ?? this.plan,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'SOAPNotes(subjective: "$subjective", objective: "$objective", assessment: "$assessment", plan: "$plan")';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SOAPNotes &&
        other.subjective == subjective &&
        other.objective == objective &&
        other.assessment == assessment &&
        other.plan == plan;
  }

  @override
  int get hashCode {
    return subjective.hashCode ^
        objective.hashCode ^
        assessment.hashCode ^
        plan.hashCode;
  }
}

class SOAPSection {
  final String title;
  final String content;
  final List<String> keywords;
  final double confidence;

  SOAPSection({
    required this.title,
    required this.content,
    this.keywords = const [],
    this.confidence = 0.0,
  });

  bool get isEmpty => content.trim().isEmpty;
  bool get hasContent => content.trim().isNotEmpty;
}

class SOAPExtractionResult {
  final SOAPNotes? soapNotes;
  final List<String> errors;
  final Map<String, dynamic> metadata;
  final double confidence;

  SOAPExtractionResult({
    this.soapNotes,
    this.errors = const [],
    this.metadata = const {},
    this.confidence = 0.0,
  });

  bool get isSuccess => soapNotes != null && errors.isEmpty;
  bool get hasWarnings => errors.isNotEmpty;
}
