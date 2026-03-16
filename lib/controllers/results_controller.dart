import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/analysis_result.dart';
import '../services/firebase/firebase_contract.dart';
import '../services/storage/local_storage_contract.dart';

class ResultsController extends ChangeNotifier {
  ResultsController({
    required LocalStorageContract localStorage,
    required FirebaseContract firebaseService,
  }) : _localStorage = localStorage,
       _firebaseService = firebaseService;

  final LocalStorageContract _localStorage;
  final FirebaseContract _firebaseService;

  bool _isSaving = false;
  String? _message;

  bool get isSaving => _isSaving;
  String? get message => _message;

  Future<void> savePlant(AnalysisResult result) async {
    _isSaving = true;
    _message = null;
    notifyListeners();

    try {
      await _localStorage.savePlant(result);

      // Optional cloud backup of the first source image.
      if (result.sourceImagePaths.isNotEmpty) {
        final firstPath = result.sourceImagePaths.first;
        await _firebaseService.uploadPhotoIfAvailable(File(firstPath));
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
