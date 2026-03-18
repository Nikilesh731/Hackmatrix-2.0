class FhirResource {
  final String resourceType;
  final String id;
  final Map<String, dynamic> resource;
  final DateTime? timestamp;

  FhirResource({
    required this.resourceType,
    required this.id,
    required this.resource,
    this.timestamp,
  });

  factory FhirResource.fromJson(Map<String, dynamic> json) {
    return FhirResource(
      resourceType: json['resourceType'] as String,
      id: json['id'] as String,
      resource: json as Map<String, dynamic>,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': resourceType,
      'id': id,
      'resource': resource,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}

class FhirBundle {
  final String id;
  final String type;
  final DateTime timestamp;
  final List<FhirEntry> entry;
  final Map<String, dynamic>? metadata;

  FhirBundle({
    required this.id,
    this.type = 'collection',
    required this.timestamp,
    required this.entry,
    this.metadata,
  });

  factory FhirBundle.fromJson(Map<String, dynamic> json) {
    return FhirBundle(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'collection',
      timestamp: DateTime.parse(json['timestamp'] as String),
      entry: (json['entry'] as List)
          .map((e) => FhirEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'Bundle',
      'id': id,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'entry': entry.map((e) => e.toJson()).toList(),
      'metadata': metadata,
    };
  }
}

class FhirEntry {
  final String fullUrl;
  final FhirResource resource;
  final Map<String, dynamic>? search;

  FhirEntry({
    required this.fullUrl,
    required this.resource,
    this.search,
  });

  factory FhirEntry.fromJson(Map<String, dynamic> json) {
    return FhirEntry(
      fullUrl: json['fullUrl'] as String,
      resource: FhirResource.fromJson(json['resource'] as Map<String, dynamic>),
      search: json['search'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullUrl': fullUrl,
      'resource': resource.toJson(),
      'search': search,
    };
  }
}

class FhirPatient {
  final String id;
  final String name;
  final String? gender;
  final DateTime? birthDate;
  final String? telecom;
  final List<FhirIdentifier>? identifier;

  FhirPatient({
    required this.id,
    required this.name,
    this.gender,
    this.birthDate,
    this.telecom,
    this.identifier,
  });

  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'Patient',
      'id': id,
      'name': [{'text': name}],
      'gender': gender,
      'birthDate': birthDate?.toIso8601String(),
      'telecom': telecom != null ? [{'value': telecom}] : null,
      'identifier': identifier?.map((i) => i.toJson()).toList(),
    };
  }
}

class FhirObservation {
  final String id;
  final String status;
  final String? code;
  final String? subject;
  final dynamic value;
  final DateTime? effectiveDateTime;
  final String? category;

  FhirObservation({
    required this.id,
    this.status = 'final',
    this.code,
    this.subject,
    this.value,
    this.effectiveDateTime,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'Observation',
      'id': id,
      'status': status,
      'code': code != null ? {'text': code} : null,
      'subject': {'reference': 'Patient/$subject'},
      'valueQuantity': value != null ? {'value': value} : null,
      'effectiveDateTime': effectiveDateTime?.toIso8601String(),
      'category': category != null ? [{'text': category}] : null,
    };
  }
}

class FhirCondition {
  final String id;
  final String? code;
  final String? subject;
  final String? verificationStatus;
  final String? severity;
  final String? category;

  FhirCondition({
    required this.id,
    this.code,
    this.subject,
    this.verificationStatus = 'confirmed',
    this.severity,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'Condition',
      'id': id,
      'code': code != null ? {'text': code} : null,
      'subject': {'reference': 'Patient/$subject'},
      'verificationStatus': {'coding': [{'code': verificationStatus}]},
      'severity': severity != null ? {'coding': [{'code': severity}]} : null,
      'category': category != null ? [{'coding': [{'code': category}]}] : null,
    };
  }
}

class FhirIdentifier {
  final String? system;
  final String? value;
  final String? type;

  FhirIdentifier({
    this.system,
    this.value,
    this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'system': system,
      'value': value,
      'type': type != null ? {'text': type} : null,
    };
  }
}
