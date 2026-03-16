import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/care_guide.dart';
import '../../models/plant_profile.dart';
import '../storage/local_storage_service.dart';

class PerenualService {
  PerenualService._();
  static final PerenualService instance = PerenualService._();

  static const String _baseUrl = 'https://perenual.com/api/species-list';
  static const String _apiKey = String.fromEnvironment(
    'PERENUAL_API_KEY',
    defaultValue: '',
  );

  Future<PlantProfile> enrichPlantData({
    required String speciesGuess,
    String? locationHint,
  }) async {
    final cacheKey = 'perenual_${speciesGuess.toLowerCase()}';
    final cached = LocalStorageService.instance.getCachedApiResponse(cacheKey);
    if (cached != null) {
      return PlantProfile.fromJson(cached);
    }

    if (_apiKey.isEmpty) {
      return _fallbackProfile(speciesGuess, locationHint);
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl?key=$_apiKey&q=${Uri.encodeQueryComponent(speciesGuess)}',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return _fallbackProfile(speciesGuess, locationHint);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = (body['data'] as List<dynamic>? ?? []);
      if (data.isEmpty) {
        return _fallbackProfile(speciesGuess, locationHint);
      }
      final top = data.first as Map<String, dynamic>;

      final profile = PlantProfile(
        speciesName: top['common_name']?.toString() ?? speciesGuess,
        scientificName:
            (((top['scientific_name'] as List<dynamic>?)?.isNotEmpty ?? false)
                ? (top['scientific_name'] as List<dynamic>).first.toString()
                : speciesGuess),
        commonNames: _coerceNames(top['other_name']),
        careGuide: CareGuide(
          watering: 'Moderate; adjust by soil moisture and season',
          soilType: 'Well-draining loam, rich in organic matter',
          sunlight: top['sunlight']?.toString() ?? 'Partial to full sun',
          temperature: '15-30°C (species dependent)',
          pruning: 'Remove dead foliage and shape in growing season',
          fertilizing: 'Balanced NPK every 2-4 weeks in active growth',
        ),
        growthStages: const [
          'Seed germination',
          'Vegetative growth',
          'Flowering or reproductive stage',
          'Maturity and dormancy',
        ],
        potentialUses: const ['Ornamental', 'Edible', 'Medicinal'],
        description:
            'Enriched from live API data. Validate with local climate conditions.',
      );

      await LocalStorageService.instance.cacheApiResponse(
        key: cacheKey,
        data: profile.toJson(),
      );

      return profile;
    } catch (_) {
      return _fallbackProfile(speciesGuess, locationHint);
    }
  }

  List<String> _coerceNames(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String && raw.isNotEmpty) return [raw];
    return const ['Unknown common names'];
  }

  PlantProfile _fallbackProfile(String speciesGuess, String? locationHint) {
    final locationNote = locationHint == null
        ? ''
        : ' Region hint: $locationHint. Tune watering and disease treatment '
            'for local humidity.';
    return PlantProfile(
      speciesName: speciesGuess,
      scientificName: speciesGuess,
      commonNames: const ['Local variety'],
      careGuide: const CareGuide(
        watering: 'Water when top soil layer is dry',
        soilType: 'Well-draining soil with compost',
        sunlight: '4-6 hours bright light daily',
        temperature: '18-28°C preferred',
        pruning: 'Prune dead/diseased leaves weekly',
        fertilizing: 'Use balanced fertilizer every 3 weeks',
      ),
      growthStages: const [
        'Germination',
        'Seedling',
        'Vegetative growth',
        'Maturity',
      ],
      potentialUses: const ['Ornamental', 'Possible edible use'],
      description:
          'Offline fallback profile used because live API is unavailable.'
          '$locationNote',
    );
  }
}
