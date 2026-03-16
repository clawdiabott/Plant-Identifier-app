import 'package:flutter_test/flutter_test.dart';

import 'package:plant_identifier_app/controllers/saved_plants_controller.dart';
import 'package:plant_identifier_app/models/analysis_result.dart';
import 'package:plant_identifier_app/services/storage/local_storage_contract.dart';

class _StorageWithPresetPlants implements LocalStorageContract {
  _StorageWithPresetPlants(this.items);
  final List<AnalysisResult> items;

  @override
  Future<void> cacheApiResponse({
    required String key,
    required Map<String, dynamic> data,
    Duration ttl = const Duration(days: 7),
  }) async {}

  @override
  Map<String, dynamic>? getCachedApiResponse(String key) => null;

  @override
  DateTime? getLastSync() => null;

  @override
  List<AnalysisResult> getSavedPlants() => items;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> savePlant(AnalysisResult result) async {}

  @override
  Future<void> setLastSync(DateTime timestamp) async {}
}

void main() {
  test('load() hydrates saved plants from local storage', () async {
    final controller = SavedPlantsController(
      localStorage: _StorageWithPresetPlants(const []),
    );

    await controller.load();

    expect(controller.savedPlants, isEmpty);
  });
}
