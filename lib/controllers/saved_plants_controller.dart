import 'package:flutter/foundation.dart';

import '../models/analysis_result.dart';
import '../services/storage/local_storage_service.dart';

class SavedPlantsController extends ChangeNotifier {
  List<AnalysisResult> _savedPlants = const [];

  List<AnalysisResult> get savedPlants => _savedPlants;

  Future<void> load() async {
    _savedPlants = LocalStorageService.instance.getSavedPlants();
    notifyListeners();
  }
}
