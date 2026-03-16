class CareGuide {
  const CareGuide({
    required this.watering,
    required this.soilType,
    required this.sunlight,
    required this.temperature,
    required this.pruning,
    required this.fertilizing,
  });

  final String watering;
  final String soilType;
  final String sunlight;
  final String temperature;
  final String pruning;
  final String fertilizing;

  factory CareGuide.fromJson(Map<String, dynamic> json) {
    return CareGuide(
      watering: json['watering']?.toString() ?? 'Unknown',
      soilType: json['soilType']?.toString() ?? 'Unknown',
      sunlight: json['sunlight']?.toString() ?? 'Unknown',
      temperature: json['temperature']?.toString() ?? 'Unknown',
      pruning: json['pruning']?.toString() ?? 'As needed',
      fertilizing: json['fertilizing']?.toString() ?? 'Balanced fertilizer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'watering': watering,
      'soilType': soilType,
      'sunlight': sunlight,
      'temperature': temperature,
      'pruning': pruning,
      'fertilizing': fertilizing,
    };
  }
}
