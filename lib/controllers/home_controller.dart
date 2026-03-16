import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/analysis_result.dart';
import '../services/analysis/plant_analysis_contract.dart';

class HomeController extends ChangeNotifier {
  HomeController({required PlantAnalysisContract analysisService})
    : _analysisService = analysisService;

  final PlantAnalysisContract _analysisService;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  bool _isAnalyzing = false;
  String? _errorMessage;
  AnalysisResult? _latestResult;

  List<XFile> get selectedImages => List.unmodifiable(_selectedImages);
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;
  AnalysisResult? get latestResult => _latestResult;

  Future<void> captureFromCamera() async {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      _setError('Camera permission is required.');
      return;
    }
    final shot = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
    );
    if (shot != null) {
      _selectedImages.add(shot);
      _setError(null);
      notifyListeners();
    }
  }

  Future<void> pickFromGallery() async {
    final photos = await Permission.photos.request();
    final storage = await Permission.storage.request();
    final granted =
        photos.isGranted || photos.isLimited || storage.isGranted || storage.isLimited;
    if (!granted) {
      _setError('Gallery permission is required.');
      return;
    }
    final chosen = await _picker.pickMultiImage(imageQuality: 92);
    if (chosen.isNotEmpty) {
      _selectedImages.addAll(chosen);
      _setError(null);
      notifyListeners();
    }
  }

  void addCapturedImage(XFile image) {
    _selectedImages.add(image);
    _setError(null);
    notifyListeners();
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= _selectedImages.length) return;
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  void clearSelectedImages() {
    _selectedImages.clear();
    notifyListeners();
  }

  Future<AnalysisResult?> analyzeSelectedImages() async {
    if (_selectedImages.isEmpty) {
      _setError('Select at least one image to start analysis.');
      return null;
    }

    _isAnalyzing = true;
    _setError(null);
    notifyListeners();

    try {
      final result = await _analysisService.analyze(_selectedImages);
      if (result == null) {
        _setError('Unable to identify this plant confidently. Try clearer photos.');
        return null;
      }

      _latestResult = result;
      return result;
    } catch (e) {
      _setError('Analysis failed: $e');
      return null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void _setError(String? value) {
    _errorMessage = value;
  }
}
