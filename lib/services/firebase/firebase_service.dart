import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _initialized = false;
  FirebaseAnalytics? _analytics;

  bool get isInitialized => _initialized;
  FirebaseAnalytics? get analytics => _analytics;

  Future<void> initializeSafely() async {
    try {
      await Firebase.initializeApp();
      _analytics = FirebaseAnalytics.instance;
      _initialized = true;
    } catch (_) {
      // Keep app functional when Firebase is not configured yet.
      _initialized = false;
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    if (!_initialized) return null;
    try {
      return await FirebaseAuth.instance.signInAnonymously();
    } catch (_) {
      return null;
    }
  }

  Future<String?> uploadPhotoIfAvailable(File file) async {
    if (!_initialized) return null;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    try {
      final ref = FirebaseStorage.instance
          .ref('users/${currentUser.uid}/photos/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(file);
      return ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<void> logAnalysis({
    required String speciesName,
    required double confidence,
    required bool usedCloudFallback,
  }) async {
    if (!_initialized || _analytics == null) return;
    await _analytics!.logEvent(
      name: 'plant_analysis_completed',
      parameters: {
        'species_name': speciesName,
        'confidence': confidence,
        'used_cloud_fallback': usedCloudFallback,
      },
    );
  }
}
