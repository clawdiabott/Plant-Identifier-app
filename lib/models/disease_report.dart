enum SeverityLevel { low, medium, high, critical }

class DiseaseIssue {
  const DiseaseIssue({
    required this.issueName,
    required this.severity,
    required this.symptoms,
    required this.causes,
    required this.treatments,
  });

  final String issueName;
  final SeverityLevel severity;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatments;

  factory DiseaseIssue.fromJson(Map<String, dynamic> json) {
    return DiseaseIssue(
      issueName: json['issueName']?.toString() ?? 'Unknown issue',
      severity: _severityFromString(json['severity']?.toString()),
      symptoms:
          (json['symptoms'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      causes:
          (json['causes'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      treatments:
          (json['treatments'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issueName': issueName,
      'severity': severity.name,
      'symptoms': symptoms,
      'causes': causes,
      'treatments': treatments,
    };
  }

  static SeverityLevel _severityFromString(String? value) {
    switch (value) {
      case 'low':
        return SeverityLevel.low;
      case 'medium':
        return SeverityLevel.medium;
      case 'high':
        return SeverityLevel.high;
      case 'critical':
        return SeverityLevel.critical;
      default:
        return SeverityLevel.medium;
    }
  }
}

class DiseaseReport {
  const DiseaseReport({required this.issues, required this.overallSeverity});

  final List<DiseaseIssue> issues;
  final SeverityLevel overallSeverity;

  bool get hasIssues => issues.isNotEmpty;

  factory DiseaseReport.fromJson(Map<String, dynamic> json) {
    return DiseaseReport(
      issues:
          (json['issues'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(DiseaseIssue.fromJson)
              .toList(),
      overallSeverity: DiseaseIssue._severityFromString(
        json['overallSeverity']?.toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issues': issues.map((e) => e.toJson()).toList(),
      'overallSeverity': overallSeverity.name,
    };
  }
}
