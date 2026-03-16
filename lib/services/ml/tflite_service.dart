import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../models/disease_report.dart';
import '../../models/ml_prediction.dart';

class TFLiteService {
  TFLiteService._();
  static final TFLiteService instance = TFLiteService._();

  Interpreter? _plantInterpreter;
  Interpreter? _diseaseInterpreter;
  List<String> _plantLabels = const [];
  List<String> _diseaseLabels = const [];
  bool _isLoaded = false;

  Future<void> loadModelsIfNeeded() async {
    if (_isLoaded) return;

    try {
      _plantInterpreter = await Interpreter.fromAsset(
        'assets/models/plant_species_model.tflite',
      );
      _diseaseInterpreter = await Interpreter.fromAsset(
        'assets/models/disease_detector_model.tflite',
      );
      _plantLabels = await _loadLabels('assets/labels/plant_labels.txt');
      _diseaseLabels = await _loadLabels('assets/labels/disease_labels.txt');
      _isLoaded = true;
    } catch (_) {
      // Keep running in degraded mode where fallback heuristics/cloud model
      // can still provide useful behavior in development or initial setup.
      _isLoaded = false;
    }
  }

  Future<PlantPrediction?> identifyPlant(Uint8List imageBytes) async {
    await loadModelsIfNeeded();
    if (_plantInterpreter == null) return null;

    final tensor = _preprocess(imageBytes, imageSize: 224);
    if (tensor == null) return null;

    final outputLength = max(1, _plantLabels.isEmpty ? 1000 : _plantLabels.length);
    final output = [List<double>.filled(outputLength, 0)];

    try {
      _plantInterpreter!.run(tensor, output);
      final probabilities = output.first;
      int topIndex = 0;
      double topScore = probabilities.first;
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > topScore) {
          topScore = probabilities[i];
          topIndex = i;
        }
      }

      final label = _safeLabel(_plantLabels, topIndex, fallback: 'Unknown Plant');
      return PlantPrediction(
        speciesName: label,
        scientificName: _toScientificGuess(label),
        confidence: topScore.clamp(0, 1).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<DiseasePrediction>> detectDiseases(Uint8List imageBytes) async {
    await loadModelsIfNeeded();
    if (_diseaseInterpreter == null) return const [];

    final tensor = _preprocess(imageBytes, imageSize: 224);
    if (tensor == null) return const [];

    final outputLength =
        max(1, _diseaseLabels.isEmpty ? 256 : _diseaseLabels.length);
    final output = [List<double>.filled(outputLength, 0)];

    try {
      _diseaseInterpreter!.run(tensor, output);
      final probabilities = output.first;

      final ranked = List<int>.generate(probabilities.length, (i) => i)
        ..sort((a, b) => probabilities[b].compareTo(probabilities[a]));

      // Take the top disease candidates and map confidence to severity.
      return ranked.take(3).map((index) {
        final confidence = probabilities[index].clamp(0, 1).toDouble();
        return DiseasePrediction(
          issueName: _safeLabel(
            _diseaseLabels,
            index,
            fallback: 'Potential foliar issue',
          ),
          confidence: confidence,
          severity: _severityFromConfidence(confidence),
        );
      }).where((d) => d.confidence >= 0.2).toList();
    } catch (_) {
      return const [];
    }
  }

  List<List<List<List<double>>>>? _preprocess(
    Uint8List bytes, {
    required int imageSize,
  }) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final resized = img.copyResize(decoded, width: imageSize, height: imageSize);
    final input = List.generate(
      1,
      (_) => List.generate(
        imageSize,
        (y) => List.generate(imageSize, (x) {
          final pixel = resized.getPixel(x, y);
          // Normalize to [0, 1] for MobileNet-like float models.
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        }),
      ),
    );
    return input;
  }

  Future<List<String>> _loadLabels(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      return raw
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  String _safeLabel(List<String> labels, int index, {required String fallback}) {
    if (index < 0 || index >= labels.length) return fallback;
    return labels[index];
  }

  String _toScientificGuess(String speciesName) {
    if (speciesName.contains(' ')) {
      final parts = speciesName.split(' ');
      if (parts.length >= 2) {
        return '${parts.first} ${parts[1]}';
      }
    }
    return speciesName;
  }

  SeverityLevel _severityFromConfidence(double confidence) {
    if (confidence >= 0.85) return SeverityLevel.critical;
    if (confidence >= 0.65) return SeverityLevel.high;
    if (confidence >= 0.4) return SeverityLevel.medium;
    return SeverityLevel.low;
  }
}
