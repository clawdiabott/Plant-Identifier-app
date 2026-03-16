import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/analysis_result.dart';
import '../services/firebase/firebase_service.dart';
import '../services/storage/local_storage_service.dart';

class ResultsController extends ChangeNotifier {
  bool _isSaving = false;
  String? _message;

  bool get isSaving => _isSaving;
  String? get message => _message;

  Future<void> savePlant(AnalysisResult result) async {
    _isSaving = true;
    _message = null;
    notifyListeners();

    try {
      await LocalStorageService.instance.savePlant(result);

      // Optional cloud backup of the first source image.
      if (result.sourceImagePaths.isNotEmpty) {
        final firstPath = result.sourceImagePaths.first;
        await FirebaseService.instance.uploadPhotoIfAvailable(File(firstPath));
      }
      _message = 'Plant saved successfully.';
    } catch (e) {
      _message = 'Failed to save plant: $e';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
