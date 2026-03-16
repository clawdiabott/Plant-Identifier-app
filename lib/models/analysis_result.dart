import 'disease_report.dart';
import 'plant_profile.dart';

class AnalysisResult {
  const AnalysisResult({
    required this.profile,
    required this.diseaseReport,
    required this.confidence,
    required this.usedCloudFallback,
    required this.analyzedAt,
    this.locationHint,
    this.sourceImagePaths = const [],
  });

  final PlantProfile profile;
  final DiseaseReport diseaseReport;
  final double confidence;
  final bool usedCloudFallback;
  final DateTime analyzedAt;
  final String? locationHint;
  final List<String> sourceImagePaths;

  Map<String, dynamic> toJson() {
    return {
      'profile': profile.toJson(),
      'diseaseReport': diseaseReport.toJson(),
      'confidence': confidence,
      'usedCloudFallback': usedCloudFallback,
      'analyzedAt': analyzedAt.toIso8601String(),
      'locationHint': locationHint,
      'sourceImagePaths': sourceImagePaths,
    };
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      profile: PlantProfile.fromJson(
        (json['profile'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      diseaseReport: DiseaseReport.fromJson(
        (json['diseaseReport'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      usedCloudFallback: json['usedCloudFallback'] as bool? ?? false,
      analyzedAt: DateTime.tryParse(json['analyzedAt']?.toString() ?? '') ??
          DateTime.now(),
      locationHint: json['locationHint']?.toString(),
      sourceImagePaths:
          (json['sourceImagePaths'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }
}
