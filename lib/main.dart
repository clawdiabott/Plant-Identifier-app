import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/service_locator.dart';
import 'core/routing/app_router.dart';
import 'controllers/home_controller.dart';
import 'controllers/results_controller.dart';
import 'controllers/saved_plants_controller.dart';
import 'services/chatbot/chatbot_service.dart';
import 'services/firebase/firebase_contract.dart';
import 'services/storage/local_storage_contract.dart';
import 'services/sync/background_sync_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServiceLocator();

  // Initialize local persistence first because the app uses it for
  // offline mode, cached API responses, and saved plants.
  await sl<LocalStorageContract>().initialize();

  // Initialize Firebase in "safe mode" (non-fatal if config is missing),
  // allowing local-only deployments and simple onboarding.
  await sl<FirebaseContract>().initializeSafely();
  await sl<FirebaseContract>().signInAnonymously();

  // Prepare background refresh jobs for periodic disease/treatment updates.
  await BackgroundSyncService.instance.initialize();

  runApp(const PlantIdentifierApp());
}

class PlantIdentifierApp extends StatelessWidget {
  const PlantIdentifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.buildRouter();
    return MultiProvider(
      providers: [
        Provider<ChatbotService>(create: (_) => sl<ChatbotService>()),
        ChangeNotifierProvider<HomeController>(
          create: (_) => sl<HomeController>(),
        ),
        ChangeNotifierProvider<ResultsController>(
          create: (_) => sl<ResultsController>(),
        ),
        ChangeNotifierProvider<SavedPlantsController>(
          create: (_) => sl<SavedPlantsController>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Plant Identifier',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
