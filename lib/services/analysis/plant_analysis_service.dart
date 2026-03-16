import 'package:image_picker/image_picker.dart';

import '../../models/analysis_result.dart';
import '../../models/disease_report.dart';
import '../../models/ml_prediction.dart';
import '../api/perenual_service.dart';
import '../firebase/firebase_contract.dart';
import '../location/location_service.dart';
import '../ml/cloud_ml_fallback_service.dart';
import '../ml/tflite_service.dart';
import 'plant_analysis_contract.dart';

class PlantAnalysisService implements PlantAnalysisContract {
  PlantAnalysisService({
    required TFLiteService tfliteService,
    required CloudMlFallbackService cloudFallbackService,
    required LocationService locationService,
    required FirebaseContract firebaseService,
  }) : _tfliteService = tfliteService,
       _cloudFallbackService = cloudFallbackService,
       _locationService = locationService,
       _firebaseService = firebaseService;

  final TFLiteService _tfliteService;
  final CloudMlFallbackService _cloudFallbackService;
  final LocationService _locationService;
  final FirebaseContract _firebaseService;

  @override
  Future<AnalysisResult?> analyze(List<XFile> images) async {
    if (images.isEmpty) return null;

    final locationHint = await _locationService.getLocationHint();
    final speciesVotes = <String, List<double>>{};
    final diseasePredictions = <DiseasePrediction>[];
    var usedCloudFallback = false;

    for (final image in images) {
      final bytes = await image.readAsBytes();
      final localPlantPrediction = await _tfliteService.identifyPlant(bytes);
      PlantPrediction? plantPrediction = localPlantPrediction;

      if (plantPrediction == null || plantPrediction.confidence < 0.45) {
        usedCloudFallback = true;
        plantPrediction = await _cloudFallbackService.identifyPlantWithMlKit(
          image.path,
        );
      }

      if (plantPrediction != null) {
        speciesVotes.putIfAbsent(plantPrediction.speciesName, () => []);
        speciesVotes[plantPrediction.speciesName]!.add(plantPrediction.confidence);
      }

      var diseaseBatch = await _tfliteService.detectDiseases(bytes);
      if (diseaseBatch.isEmpty) {
        usedCloudFallback = true;
        diseaseBatch = await _cloudFallbackService.detectIssuesWithMlKit(
          image.path,
        );
      }
      diseasePredictions.addAll(diseaseBatch);
    }

    if (speciesVotes.isEmpty) {
      return null;
    }

    final topSpeciesEntry = speciesVotes.entries.reduce((a, b) {
      final avgA = a.value.reduce((x, y) => x + y) / a.value.length;
      final avgB = b.value.reduce((x, y) => x + y) / b.value.length;
      return avgA >= avgB ? a : b;
    });

    final topSpecies = topSpeciesEntry.key;
    final topConfidence =
        topSpeciesEntry.value.reduce((x, y) => x + y) / topSpeciesEntry.value.length;

    final enrichedProfile = await PerenualService.instance.enrichPlantData(
      speciesGuess: topSpecies,
      locationHint: locationHint,
    );

    final diseaseReport = _buildDiseaseReport(diseasePredictions);
    final result = AnalysisResult(
      profile: enrichedProfile,
      diseaseReport: diseaseReport,
      confidence: topConfidence,
      usedCloudFallback: usedCloudFallback,
      analyzedAt: DateTime.now(),
      locationHint: locationHint,
      sourceImagePaths: images.map((e) => e.path).toList(),
    );

    await _firebaseService.logAnalysis(
      speciesName: result.profile.speciesName,
      confidence: result.confidence,
      usedCloudFallback: result.usedCloudFallback,
    );

    return result;
  }

  DiseaseReport _buildDiseaseReport(List<DiseasePrediction> predictions) {
    if (predictions.isEmpty) {
      return const DiseaseReport(
        issues: [],
        overallSeverity: SeverityLevel.low,
      );
    }

    final merged = <String, DiseasePrediction>{};
    for (final p in predictions) {
      final existing = merged[p.issueName];
      if (existing == null || p.confidence > existing.confidence) {
        merged[p.issueName] = p;
      }
    }

    final issues = merged.values.map((p) {
      final recommendation = _treatmentForIssue(p.issueName);
      return DiseaseIssue(
        issueName: p.issueName,
        severity: p.severity,
        symptoms: recommendation.symptoms,
        causes: recommendation.causes,
        treatments: recommendation.treatments,
      );
    }).toList();

    final overall = issues
        .map((i) => i.severity.index)
        .reduce((a, b) => a > b ? a : b);

    return DiseaseReport(
      issues: issues,
      overallSeverity: SeverityLevel.values[overall],
    );
  }

  ({List<String> symptoms, List<String> causes, List<String> treatments})
  _treatmentForIssue(String issueName) {
    final lower = issueName.toLowerCase();
    if (lower.contains('blight')) {
      return (
        symptoms: const ['Dark lesions', 'Rapid leaf wilting'],
        causes: const ['Fungal pathogen', 'High humidity and poor airflow'],
        treatments: const [
          'Remove infected leaves immediately.',
          'Apply copper-based fungicide every 7 days for 3 cycles.',
          'Improve airflow and avoid overhead watering.',
        ],
      );
    }
    if (lower.contains('mildew')) {
      return (
        symptoms: const ['White powdery coating on leaves'],
        causes: const ['Fungal spores in humid conditions'],
        treatments: const [
          'Prune crowded foliage.',
          'Spray sulfur or potassium bicarbonate every 7-10 days.',
          'Water at root level early in the day.',
        ],
      );
    }
    if (lower.contains('yellow') || lower.contains('nitrogen')) {
      return (
        symptoms: const ['Yellowing older leaves', 'Slowed growth'],
        causes: const ['Nitrogen deficiency', 'Nutrient lockout due to pH'],
        treatments: const [
          'Apply a nitrogen-rich fertilizer at half strength.',
          'Check soil pH and adjust toward species-appropriate range.',
          'Add compost to improve nutrient retention.',
        ],
      );
    }
    return (
      symptoms: const ['Visual stress signs on foliage'],
      causes: const ['Possible disease or nutrient imbalance'],
      treatments: const [
        'Isolate affected plant if needed.',
        'Inspect roots, drainage, and soil moisture.',
        'Apply broad-spectrum organic treatment and monitor weekly.',
      ],
    );
  }
}
