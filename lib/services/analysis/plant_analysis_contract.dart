import 'package:image_picker/image_picker.dart';

import '../../models/analysis_result.dart';

abstract class PlantAnalysisContract {
  Future<AnalysisResult?> analyze(List<XFile> images);
}
