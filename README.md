# Plant Identifier App (Flutter, MVC)

A complete, modular Flutter application for:

- Plant species identification (on-device TFLite)
- Disease / malnutrition detection (on-device TFLite + ML Kit fallback)
- Care guidance and treatment instructions
- Local plant tracking (Hive)
- Dynamic enrichment via API + RSS feed
- Optional Firebase analytics/auth/storage integration

> Architecture: **MVC** with `models/`, `views/`, `controllers/`, and `services/`.

---

## Features Included

### 1) UI/UX

- Splash screen with logo-style branding
- Home screen with:
  - Quick camera capture (`image_picker`)
  - Advanced camera capture (`camera`)
  - Gallery multi-select
- Results screen with:
  - Species + scientific name + confidence
  - Care details (watering, soil, sunlight, temperature, pruning, fertilizing)
  - Growth stages + potential uses
  - Disease/malnutrition cards:
    - Symptoms
    - Causes
    - Severity level
    - Step-by-step treatment
- Interactive image zoom (`InteractiveViewer`)
- Expandable information sections (`ExpansionTile`)
- Save Plant feature (Hive local storage)
- Dark mode support (`ThemeMode.system`)
- Responsive layout (single-column + wide-screen side panel)

### 2) Core ML & Data

- On-device inference with `tflite_flutter`:
  - `plant_species_model.tflite` for species classification
  - `disease_detector_model.tflite` for disease/deficiency detection
- Image preprocessing:
  - Resize to `224x224`
  - Normalize RGB to `[0,1]`
- Multi-photo analysis:
  - Aggregates species confidence across selected images
- Region-aware hints:
  - Optional geolocation used for context
- Fallback ML:
  - Uses `google_mlkit_image_labeling` when local TFLite is unavailable/low confidence
- Dynamic enrichment:
  - Perenual API integration (with cached fallback)
- Emerging disease/treatment updates:
  - RSS feed ingestion + cache
- Offline mode:
  - Core ML local
  - Cached API/news via Hive

### 3) Advanced/Backend Integrations

- Firebase (optional):
  - Core initialization
  - Anonymous auth
  - Analytics events
  - Optional photo upload to Firebase Storage
- Rule-based chatbot service for follow-up plant care Q&A
- Weekly background sync scaffold using `workmanager`
- Permission handling for camera/gallery/location

---

## Project Structure

```text
lib/
  controllers/
    home_controller.dart
    results_controller.dart
    saved_plants_controller.dart
  models/
    analysis_result.dart
    care_guide.dart
    disease_report.dart
    ml_prediction.dart
    news_item.dart
    plant_profile.dart
  services/
    api/
      news_service.dart
      perenual_service.dart
    chatbot/
      chatbot_service.dart
    firebase/
      firebase_service.dart
    location/
      location_service.dart
    ml/
      cloud_ml_fallback_service.dart
      tflite_service.dart
    storage/
      local_storage_service.dart
    sync/
      background_sync_service.dart
  theme/
    app_theme.dart
  views/
    camera_capture_screen.dart
    chatbot_screen.dart
    home_screen.dart
    results_screen.dart
    saved_plants_screen.dart
    splash_screen.dart
  widgets/
    expandable_info_section.dart
    photo_preview.dart
    severity_chip.dart
  main.dart
```

---

## Setup Instructions

### 1) Install Flutter

Install a current stable Flutter SDK and verify:

```bash
flutter --version
dart --version
```

### 2) Get dependencies

```bash
flutter pub get
```

### 3) Add ML assets

Put files in `assets/models/`:

- `plant_species_model.tflite`
- `disease_detector_model.tflite`

Labels are configured in:

- `assets/labels/plant_labels.txt`
- `assets/labels/disease_labels.txt`

### 4) Configure API key (Perenual)

Pass API key using Dart define:

```bash
flutter run --dart-define=PERENUAL_API_KEY=YOUR_KEY_HERE
```

### 5) Optional Firebase setup

1. Add Firebase configs:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
2. Initialize per platform as recommended by Firebase docs.
3. (Optional) Generate `firebase_options.dart` with FlutterFire CLI.

App behavior remains functional if Firebase is not configured.

### 6) iOS / Android permissions

Add runtime permission declarations in platform manifests:

- Camera
- Photos/Storage
- Location (when in use)

### 7) Run app

```bash
flutter run
```

---

## Accuracy Notes (95%+ Target)

Hitting 95%+ real-world accuracy depends on:

- Model quality (properly fine-tuned datasets)
- Label quality and class balance
- Domain coverage (species and disease variety)
- Inference calibration and threshold tuning
- Input image quality and multi-photo aggregation

This project includes:

- Multi-photo confidence voting
- Cloud fallback when local confidence is weak
- Region context enrichment
- Dynamic care/treatment API enrichment

For production-level 95%+ targets, retrain with strong augmentation and per-crop calibration.

---

## Expansion Ideas

- AR plant overlays via `ar_flutter_plugin`
- Personalized reminders (watering/fertilizer schedule)
- Cloud model serving for heavier ensemble inference
- Disease progression timeline from user image history
- Human-in-the-loop correction workflow to improve model labels
