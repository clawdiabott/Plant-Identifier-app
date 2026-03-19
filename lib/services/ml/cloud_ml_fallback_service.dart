import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../../models/disease_report.dart';
import '../../models/ml_prediction.dart';

class CloudMlFallbackService {
  CloudMlFallbackService._();
  static final CloudMlFallbackService instance = CloudMlFallbackService._();

  /// Fallback inference path when on-device TFLite model is missing,
  /// corrupted, or returns very low confidence.
  Future<PlantPrediction?> identifyPlantWithMlKit(
    String imagePath,
  ) async {
    final options = ImageLabelerOptions(confidenceThreshold: 0.5);
    final labeler = ImageLabeler(options: options);
    try {
      final labels = await labeler.processImage(InputImage.fromFilePath(imagePath));
      if (labels.isEmpty) return null;
      final top = labels.first;
      final label = top.label.isEmpty ? 'Unknown Plant' : top.label;
      if (_isGenericObjectLabel(label)) {
        // MLKit image labeling is object-centric and often returns generic
        // labels like "flowerpot". Ignore those for species identification.
        return null;
      }
      return PlantPrediction(
        speciesName: label,
        scientificName: label,
        confidence: top.confidence.clamp(0, 1).toDouble(),
      );
    } catch (_) {
      return null;
    } finally {
      labeler.close();
    }
  }

  Future<List<DiseasePrediction>> detectIssuesWithMlKit(
    String imagePath,
  ) async {
    final options = ImageLabelerOptions(confidenceThreshold: 0.35);
    final labeler = ImageLabeler(options: options);
    try {
      final labels = await labeler.processImage(InputImage.fromFilePath(imagePath));
      return labels.take(3).map((label) {
        return DiseasePrediction(
          issueName: _normalizeIssueLabel(label.label),
          confidence: label.confidence.clamp(0, 1).toDouble(),
          severity: _severityFromConfidence(label.confidence),
        );
      }).toList();
    } catch (_) {
      return const [];
    } finally {
      labeler.close();
    }
  }

  String _normalizeIssueLabel(String rawLabel) {
    final lower = rawLabel.toLowerCase();
    if (lower.contains('spot')) return 'Leaf spots (possible fungal infection)';
    if (lower.contains('yellow')) return 'Yellowing (possible nitrogen deficiency)';
    if (lower.contains('mildew')) return 'Powdery mildew risk';
    if (lower.contains('blight')) return 'Blight symptoms';
    return rawLabel;
  }

  SeverityLevel _severityFromConfidence(double confidence) {
    if (confidence >= 0.85) return SeverityLevel.critical;
    if (confidence >= 0.65) return SeverityLevel.high;
    if (confidence >= 0.4) return SeverityLevel.medium;
    return SeverityLevel.low;
  }

  bool _isGenericObjectLabel(String label) {
    final lower = label.toLowerCase();
    const generic = {
      'flower pot',
      'flowerpot',
      'plant',
      'potted plant',
      'houseplant',
      'leaf',
      'flora',
      'greenery',
      'tree',
      'shrub',
      'vegetation',
    };
    return generic.contains(lower);
  }
}
