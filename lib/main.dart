import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/home_controller.dart';
import 'controllers/results_controller.dart';
import 'controllers/saved_plants_controller.dart';
import 'services/chatbot/chatbot_service.dart';
import 'services/firebase/firebase_service.dart';
import 'services/location/location_service.dart';
import 'services/ml/cloud_ml_fallback_service.dart';
import 'services/ml/tflite_service.dart';
import 'services/storage/local_storage_service.dart';
import 'services/sync/background_sync_service.dart';
import 'theme/app_theme.dart';
import 'views/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistence first because the app uses it for
  // offline mode, cached API responses, and saved plants.
  await LocalStorageService.instance.initialize();

  // Initialize Firebase in "safe mode" (non-fatal if config is missing),
  // allowing local-only deployments and simple onboarding.
  await FirebaseService.instance.initializeSafely();
  await FirebaseService.instance.signInAnonymously();

  // Prepare background refresh jobs for periodic disease/treatment updates.
  await BackgroundSyncService.instance.initialize();

  runApp(const PlantIdentifierApp());
}

class PlantIdentifierApp extends StatelessWidget {
  const PlantIdentifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TFLiteService>(create: (_) => TFLiteService.instance),
        Provider<CloudMlFallbackService>(
          create: (_) => CloudMlFallbackService.instance,
        ),
        Provider<LocationService>(create: (_) => LocationService.instance),
        Provider<ChatbotService>(create: (_) => ChatbotService.instance),
        ChangeNotifierProvider<HomeController>(
          create: (context) => HomeController(
            tfliteService: context.read<TFLiteService>(),
            cloudFallbackService: context.read<CloudMlFallbackService>(),
            locationService: context.read<LocationService>(),
          ),
        ),
        ChangeNotifierProvider<ResultsController>(
          create: (_) => ResultsController(),
        ),
        ChangeNotifierProvider<SavedPlantsController>(
          create: (_) => SavedPlantsController(),
        ),
      ],
      child: MaterialApp(
        title: 'Plant Identifier',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
