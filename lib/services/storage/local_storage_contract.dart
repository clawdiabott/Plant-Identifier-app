import '../../models/analysis_result.dart';

abstract class LocalStorageContract {
  Future<void> initialize();
  Future<void> savePlant(AnalysisResult result);
  List<AnalysisResult> getSavedPlants();
  Future<void> cacheApiResponse({
    required String key,
    required Map<String, dynamic> data,
    Duration ttl,
  });
  Map<String, dynamic>? getCachedApiResponse(String key);
  Future<void> setLastSync(DateTime timestamp);
  DateTime? getLastSync();
}
