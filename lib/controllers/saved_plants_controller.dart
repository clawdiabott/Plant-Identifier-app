import 'package:flutter/foundation.dart';

import '../models/analysis_result.dart';
import '../services/storage/local_storage_contract.dart';

class SavedPlantsController extends ChangeNotifier {
  SavedPlantsController({required LocalStorageContract localStorage})
    : _localStorage = localStorage;

  final LocalStorageContract _localStorage;
  List<AnalysisResult> _savedPlants = const [];

  List<AnalysisResult> get savedPlants => _savedPlants;

  Future<void> load() async {
    _savedPlants = _localStorage.getSavedPlants();
    notifyListeners();
  }
}
