import 'package:hive_flutter/hive_flutter.dart';

import '../../models/analysis_result.dart';
import 'local_storage_contract.dart';

class LocalStorageService implements LocalStorageContract {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const String _savedPlantsBoxName = 'saved_plants';
  static const String _apiCacheBoxName = 'api_cache';
  static const String _metaBoxName = 'meta_box';

  late Box _savedPlantsBox;
  late Box _apiCacheBox;
  late Box _metaBox;

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();
    _savedPlantsBox = await Hive.openBox(_savedPlantsBoxName);
    _apiCacheBox = await Hive.openBox(_apiCacheBoxName);
    _metaBox = await Hive.openBox(_metaBoxName);
  }

  @override
  Future<void> savePlant(AnalysisResult result) async {
    await _savedPlantsBox.put(
      DateTime.now().microsecondsSinceEpoch.toString(),
      result.toJson(),
    );
  }

  @override
  List<AnalysisResult> getSavedPlants() {
    final values = _savedPlantsBox.values.toList(growable: false);
    return values
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(AnalysisResult.fromJson)
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<void> cacheApiResponse({
    required String key,
    required Map<String, dynamic> data,
    Duration ttl = const Duration(days: 7),
  }) async {
    final payload = {
      'data': data,
      'expiresAt': DateTime.now().add(ttl).toIso8601String(),
    };
    await _apiCacheBox.put(key, payload);
  }

  @override
  Map<String, dynamic>? getCachedApiResponse(String key) {
    final value = _apiCacheBox.get(key);
    if (value is! Map) return null;
    final payload = Map<String, dynamic>.from(value);
    final expiresAtRaw = payload['expiresAt']?.toString();
    final expiresAt = DateTime.tryParse(expiresAtRaw ?? '');

    if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
      _apiCacheBox.delete(key);
      return null;
    }
    final data = payload['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  @override
  Future<void> setLastSync(DateTime timestamp) async {
    await _metaBox.put('last_sync', timestamp.toIso8601String());
  }

  @override
  DateTime? getLastSync() {
    final raw = _metaBox.get('last_sync')?.toString();
    return raw == null ? null : DateTime.tryParse(raw);
  }
}
