import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:plant_identifier_app/controllers/results_controller.dart';
import 'package:plant_identifier_app/models/analysis_result.dart';
import 'package:plant_identifier_app/models/care_guide.dart';
import 'package:plant_identifier_app/models/disease_report.dart';
import 'package:plant_identifier_app/models/plant_profile.dart';
import 'package:plant_identifier_app/services/firebase/firebase_contract.dart';
import 'package:plant_identifier_app/services/storage/local_storage_contract.dart';

class _FakeLocalStorage implements LocalStorageContract {
  int saveCalls = 0;

  @override
  Future<void> cacheApiResponse({
    required String key,
    required Map<String, dynamic> data,
    Duration ttl = const Duration(days: 7),
  }) async {}

  @override
  List<AnalysisResult> getSavedPlants() => const [];

  @override
  Map<String, dynamic>? getCachedApiResponse(String key) => null;

  @override
  DateTime? getLastSync() => null;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> savePlant(AnalysisResult result) async {
    saveCalls += 1;
  }

  @override
  Future<void> setLastSync(DateTime timestamp) async {}
}

class _FakeFirebase implements FirebaseContract {
  int uploadCalls = 0;

  @override
  Future<void> initializeSafely() async {}

  @override
  Future<void> logAnalysis({
    required String speciesName,
    required double confidence,
    required bool usedCloudFallback,
  }) async {}

  @override
  Future<void> signInAnonymously() async {}

  @override
  Future<String?> uploadPhotoIfAvailable(File file) async {
    uploadCalls += 1;
    return null;
  }
}

void main() {
  test('savePlant stores locally and reports success message', () async {
    final storage = _FakeLocalStorage();
    final firebase = _FakeFirebase();
    final controller = ResultsController(
      localStorage: storage,
      firebaseService: firebase,
    );

    final result = AnalysisResult(
      profile: PlantProfile(
        speciesName: 'Rose',
        scientificName: 'Rosa',
        commonNames: const ['Rose'],
        careGuide: const CareGuide(
          watering: 'Medium',
          soilType: 'Loamy',
          sunlight: 'Partial sun',
          temperature: '18-28C',
          pruning: 'Seasonal',
          fertilizing: 'Monthly',
        ),
        growthStages: const ['Seedling'],
        potentialUses: const ['Ornamental'],
      ),
      diseaseReport: const DiseaseReport(
        issues: [],
        overallSeverity: SeverityLevel.low,
      ),
      confidence: 0.91,
      usedCloudFallback: false,
      analyzedAt: DateTime(2026, 2, 1),
      sourceImagePaths: const [],
    );

    await controller.savePlant(result);

    expect(storage.saveCalls, 1);
    expect(controller.message, contains('saved successfully'));
    expect(controller.isSaving, isFalse);
  });
}
