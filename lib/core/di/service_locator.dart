import 'package:get_it/get_it.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/results_controller.dart';
import '../../controllers/saved_plants_controller.dart';
import '../../services/analysis/plant_analysis_contract.dart';
import '../../services/analysis/plant_analysis_service.dart';
import '../../services/chatbot/chatbot_service.dart';
import '../../services/firebase/firebase_contract.dart';
import '../../services/firebase/firebase_service.dart';
import '../../services/location/location_service.dart';
import '../../services/ml/cloud_ml_fallback_service.dart';
import '../../services/ml/tflite_service.dart';
import '../../services/storage/local_storage_contract.dart';
import '../../services/storage/local_storage_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  if (sl.isRegistered<HomeController>()) {
    return;
  }

  // Service contracts.
  sl.registerLazySingleton<LocalStorageContract>(() => LocalStorageService.instance);
  sl.registerLazySingleton<FirebaseContract>(() => FirebaseService.instance);

  // Concrete services.
  sl.registerLazySingleton<TFLiteService>(() => TFLiteService.instance);
  sl.registerLazySingleton<CloudMlFallbackService>(
    () => CloudMlFallbackService.instance,
  );
  sl.registerLazySingleton<LocationService>(() => LocationService.instance);
  sl.registerLazySingleton<ChatbotService>(() => ChatbotService.instance);

  sl.registerLazySingleton<PlantAnalysisContract>(
    () => PlantAnalysisService(
      tfliteService: sl<TFLiteService>(),
      cloudFallbackService: sl<CloudMlFallbackService>(),
      locationService: sl<LocationService>(),
      firebaseService: sl<FirebaseContract>(),
    ),
  );

  // Controllers as factories for clean lifecycle with Provider.
  sl.registerFactory<HomeController>(
    () => HomeController(analysisService: sl<PlantAnalysisContract>()),
  );
  sl.registerFactory<ResultsController>(
    () => ResultsController(
      localStorage: sl<LocalStorageContract>(),
      firebaseService: sl<FirebaseContract>(),
    ),
  );
  sl.registerFactory<SavedPlantsController>(
    () => SavedPlantsController(localStorage: sl<LocalStorageContract>()),
  );
}
