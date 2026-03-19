# Plant Identifier App (Flutter, MVC)

A complete, modular Flutter application for:

- Plant species identification (on-device TFLite)
- Disease / malnutrition detection (on-device TFLite + ML Kit fallback)
- Care guidance and treatment instructions
- Local plant tracking (Hive)
- Dynamic enrichment via API + RSS feed
- Optional Firebase analytics/auth/storage integration

> Architecture: **MVC** + **generated routing** + **DI container**.

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
  core/
    di/
      service_locator.dart
    routing/
      app_router.dart
      app_routes.g.dart
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
    analysis/
      plant_analysis_contract.dart
      plant_analysis_service.dart
    firebase/
      firebase_contract.dart
      firebase_service.dart
    location/
      location_service.dart
    ml/
      cloud_ml_fallback_service.dart
      tflite_service.dart
    storage/
      local_storage_contract.dart
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
tool/
  routes.json
  generate_routes.dart
test/
  controllers/
  services/
  widgets/
```

---

## Setup Instructions

### 1) Install Flutter (Linux)

You can run these commands from **any terminal directory** (not tied to this repo):

```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable "$HOME/development/flutter"
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
flutter --version
dart --version
```

Accept Android licenses after Android SDK install:

```bash
flutter doctor --android-licenses
flutter doctor -v
```

### 2) Download this project locally

You can clone into any folder you like:

```bash
cd ~/development
git clone https://github.com/clawdiabott/Plant-Identifier-app.git
cd Plant-Identifier-app
git checkout cursor/plant-identification-app-834f
```

### 3) Generate route constants (optional)

Routes are committed in `lib/core/routing/app_routes.g.dart`, but you can regenerate:

```bash
dart tool/generate_routes.dart
```

### 4) Generate Flutter platform scaffolding (first time only)

If your clone does not yet include complete native project files, run:

```bash
flutter create .
```

Then re-check hardened manifests in `android/` and `ios/`.

### 5) Get dependencies

Run this **inside the project folder**:

```bash
flutter --version
flutter pub get
```

### 6) Add ML assets

Put files in `assets/models/`:

- `plant_species_model.tflite`
- `disease_detector_model.tflite`

Labels are configured in:

- `assets/labels/plant_labels.txt`
- `assets/labels/disease_labels.txt`

### 7) Configure API key (Perenual)

Pass API key using Dart define:

```bash
flutter run --dart-define=PERENUAL_API_KEY=YOUR_KEY_HERE
```

### 8) (Recommended) Configure PlantNet key for smarter photo ID

Without this key, fallback may rely on generic on-device object labels.
Create a free key and run with:

```bash
flutter run --dart-define=PLANTNET_API_KEY=YOUR_KEY_HERE --dart-define=PERENUAL_API_KEY=YOUR_KEY_HERE
```

Cloud APK workflow users can add `PLANTNET_API_KEY` as a GitHub Actions secret
and pass it into build commands for best species accuracy.

### 9) Optional Firebase setup

1. Add Firebase configs:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
2. Initialize per platform as recommended by Firebase docs.
3. (Optional) Generate `firebase_options.dart` with FlutterFire CLI.

App behavior remains functional if Firebase is not configured.

### 10) iOS / Android permissions + production hardening

Hardened templates are included in this repository:

- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/xml/network_security_config.xml`
- `android/app/src/main/res/xml/backup_rules.xml`
- `android/app/src/main/res/xml/data_extraction_rules.xml`
- `ios/Runner/Info.plist`

These enforce:

- no cleartext traffic by default
- strict backup/data extraction exclusions
- explicit camera/photo/location usage descriptions

Always minimize requested permissions before release.

### 11) Run tests

```bash
flutter test
```

### 12) Run app

```bash
flutter run
```

### 13) Easiest low-storage Android testing (cloud APK)

If you do not want Android Studio/emulator files on your machine:

1. Push your branch to GitHub.
2. Open **GitHub → Actions → "Build Android APK (Cloud)"**.
3. Click **Run workflow** (choose branch if needed).
4. Wait for the job to complete.
5. Download artifact: `plant-identifier-debug-apk`.
6. On Android phone, install the extracted `app-debug.apk`
   (allow "Install unknown apps" for your file manager/browser).

This builds the APK in GitHub’s cloud runners, so your local disk usage stays minimal.

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
