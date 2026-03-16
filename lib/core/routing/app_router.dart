import 'package:go_router/go_router.dart';

import '../../models/analysis_result.dart';
import '../../views/camera_capture_screen.dart';
import '../../views/chatbot_screen.dart';
import '../../views/home_screen.dart';
import '../../views/results_screen.dart';
import '../../views/saved_plants_screen.dart';
import '../../views/splash_screen.dart';
import 'app_routes.g.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter buildRouter() {
    return GoRouter(
      initialLocation: AppRoutes.splashPath,
      routes: [
        GoRoute(
          name: AppRoutes.splashName,
          path: AppRoutes.splashPath,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          name: AppRoutes.homeName,
          path: AppRoutes.homePath,
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          name: AppRoutes.resultsName,
          path: AppRoutes.resultsPath,
          builder: (_, state) {
            final result = state.extra;
            if (result is! AnalysisResult) {
              return const HomeScreen();
            }
            return ResultsScreen(analysisResult: result);
          },
        ),
        GoRoute(
          name: AppRoutes.savedPlantsName,
          path: AppRoutes.savedPlantsPath,
          builder: (_, __) => const SavedPlantsScreen(),
        ),
        GoRoute(
          name: AppRoutes.chatbotName,
          path: AppRoutes.chatbotPath,
          builder: (_, __) => const ChatbotScreen(),
        ),
        GoRoute(
          name: AppRoutes.cameraName,
          path: AppRoutes.cameraPath,
          builder: (_, __) => const CameraCaptureScreen(),
        ),
      ],
    );
  }
}
