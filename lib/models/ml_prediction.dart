import 'disease_report.dart';

class PlantPrediction {
  const PlantPrediction({
    required this.speciesName,
    required this.scientificName,
    required this.confidence,
  });

  final String speciesName;
  final String scientificName;
  final double confidence;
}

class DiseasePrediction {
  const DiseasePrediction({
    required this.issueName,
    required this.confidence,
    required this.severity,
  });

  final String issueName;
  final double confidence;
  final SeverityLevel severity;
}
