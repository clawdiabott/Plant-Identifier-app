import 'dart:io';

abstract class FirebaseContract {
  Future<void> initializeSafely();
  Future<void> signInAnonymously();
  Future<String?> uploadPhotoIfAvailable(File file);
  Future<void> logAnalysis({
    required String speciesName,
    required double confidence,
    required bool usedCloudFallback,
  });
}
