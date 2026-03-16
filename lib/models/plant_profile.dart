import 'care_guide.dart';

class PlantProfile {
  const PlantProfile({
    required this.speciesName,
    required this.scientificName,
    required this.commonNames,
    required this.careGuide,
    required this.growthStages,
    required this.potentialUses,
    this.description,
  });

  final String speciesName;
  final String scientificName;
  final List<String> commonNames;
  final CareGuide careGuide;
  final List<String> growthStages;
  final List<String> potentialUses;
  final String? description;

  factory PlantProfile.fromJson(Map<String, dynamic> json) {
    return PlantProfile(
      speciesName: json['speciesName']?.toString() ?? 'Unknown Plant',
      scientificName: json['scientificName']?.toString() ?? 'Unknown',
      commonNames:
          (json['commonNames'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      careGuide: CareGuide.fromJson(
        (json['careGuide'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      growthStages:
          (json['growthStages'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      potentialUses:
          (json['potentialUses'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speciesName': speciesName,
      'scientificName': scientificName,
      'commonNames': commonNames,
      'careGuide': careGuide.toJson(),
      'growthStages': growthStages,
      'potentialUses': potentialUses,
      'description': description,
    };
  }
}
