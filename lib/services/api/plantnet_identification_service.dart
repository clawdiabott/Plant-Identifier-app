import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/ml_prediction.dart';

class PlantNetIdentificationService {
  PlantNetIdentificationService._();
  static final PlantNetIdentificationService instance =
      PlantNetIdentificationService._();

  /// Free-tier capable API key (create at https://my.plantnet.org/).
  static const String _apiKey = String.fromEnvironment(
    'PLANTNET_API_KEY',
    defaultValue: '',
  );

  static const String _endpoint = 'https://my-api.plantnet.org/v2/identify/all';

  bool get isEnabled => _apiKey.isNotEmpty;

  Future<PlantPrediction?> identifyFromImage(String imagePath) async {
    if (_apiKey.isEmpty) return null;
    final file = File(imagePath);
    if (!file.existsSync()) return null;

    try {
      final uri = Uri.parse('$_endpoint?api-key=$_apiKey');
      final request = http.MultipartRequest('POST', uri)
        ..fields['include-related-images'] = 'false'
        ..fields['language'] = 'en'
        ..fields['organs'] = 'leaf'
        ..files.add(await http.MultipartFile.fromPath('images', imagePath));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) return null;
      final results = (body['results'] as List<dynamic>? ?? []);
      if (results.isEmpty) return null;

      final top = results.first;
      if (top is! Map<String, dynamic>) return null;
      final species = top['species'];
      if (species is! Map<String, dynamic>) return null;

      final scientific =
          species['scientificNameWithoutAuthor']?.toString().trim() ?? '';
      if (scientific.isEmpty) return null;

      final common = (species['commonNames'] as List<dynamic>? ?? [])
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final score = (top['score'] as num?)?.toDouble() ?? 0;

      return PlantPrediction(
        speciesName: common.isNotEmpty ? common.first : scientific,
        scientificName: scientific,
        confidence: score.clamp(0, 1),
      );
    } catch (_) {
      return null;
    }
  }
}
