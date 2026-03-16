import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:plant_identifier_app/controllers/home_controller.dart';
import 'package:plant_identifier_app/models/analysis_result.dart';
import 'package:plant_identifier_app/models/care_guide.dart';
import 'package:plant_identifier_app/models/disease_report.dart';
import 'package:plant_identifier_app/models/plant_profile.dart';
import 'package:plant_identifier_app/services/analysis/plant_analysis_contract.dart';

class _FakeAnalysisService implements PlantAnalysisContract {
  _FakeAnalysisService({this.result});
  final AnalysisResult? result;
  int calls = 0;

  @override
  Future<AnalysisResult?> analyze(List<XFile> images) async {
    calls += 1;
    return result;
  }
}

void main() {
  group('HomeController', () {
    test('returns error when no images selected', () async {
      final fake = _FakeAnalysisService();
      final controller = HomeController(analysisService: fake);

      final result = await controller.analyzeSelectedImages();

      expect(result, isNull);
      expect(controller.errorMessage, contains('Select at least one image'));
      expect(fake.calls, 0);
    });

    test('analyzes selected images and stores latest result', () async {
      final expected = AnalysisResult(
        profile: PlantProfile(
          speciesName: 'Tomato',
          scientificName: 'Solanum lycopersicum',
          commonNames: const ['Tomato'],
          careGuide: const CareGuide(
            watering: 'Moderate',
            soilType: 'Well-draining',
            sunlight: 'Full sun',
            temperature: '20-30C',
            pruning: 'As needed',
            fertilizing: 'Balanced NPK',
          ),
          growthStages: const ['Seedling', 'Vegetative', 'Maturity'],
          potentialUses: const ['Edible'],
        ),
        diseaseReport: const DiseaseReport(
          issues: [],
          overallSeverity: SeverityLevel.low,
        ),
        confidence: 0.9,
        usedCloudFallback: false,
        analyzedAt: DateTime(2026, 1, 1),
        sourceImagePaths: const ['fake.jpg'],
      );
      final fake = _FakeAnalysisService(result: expected);
      final controller = HomeController(analysisService: fake);
      controller.addCapturedImage(
        XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          name: 'leaf.jpg',
          mimeType: 'image/jpeg',
        ),
      );

      final result = await controller.analyzeSelectedImages();

      expect(result, isNotNull);
      expect(result!.profile.speciesName, 'Tomato');
      expect(controller.latestResult, isNotNull);
      expect(fake.calls, 1);
    });
  });
}
