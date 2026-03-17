import 'package:workmanager/workmanager.dart';

import '../api/news_service.dart';
import '../storage/local_storage_service.dart';

@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task == BackgroundSyncService.weeklySyncTaskName) {
      await LocalStorageService.instance.initialize();
      await NewsService.instance.fetchPlantNews();
      await LocalStorageService.instance.setLastSync(DateTime.now());
    }
    return Future.value(true);
  });
}

class BackgroundSyncService {
  BackgroundSyncService._();
  static final BackgroundSyncService instance = BackgroundSyncService._();

  static const String weeklySyncTaskName = 'weekly_plant_data_sync';

  Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        backgroundSyncDispatcher,
        isInDebugMode: false,
      );
      await Workmanager().registerPeriodicTask(
        weeklySyncTaskName,
        weeklySyncTaskName,
        // Weekly refresh is requested; platform can coalesce execution.
        frequency: const Duration(days: 7),
        initialDelay: const Duration(minutes: 5),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    } catch (_) {
      // Ignore on unsupported platforms or incomplete native setup.
    }
  }
}
