import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../controllers/home_controller.dart';
import '../controllers/saved_plants_controller.dart';
import 'camera_capture_screen.dart';
import 'chatbot_screen.dart';
import 'results_screen.dart';
import 'saved_plants_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Scanner'),
        actions: [
          IconButton(
            tooltip: 'Saved plants',
            onPressed: () async {
              await context.read<SavedPlantsController>().load();
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SavedPlantsScreen()),
              );
            },
            icon: const Icon(Icons.bookmark_outline),
          ),
          IconButton(
            tooltip: 'Ask assistant',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChatbotScreen()),
              );
            },
            icon: const Icon(Icons.smart_toy_outlined),
          ),
        ],
      ),
      body: Consumer<HomeController>(
        builder: (context, controller, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final section = _HomeContent(controller: controller);
              if (!isWide) return section;
              return Row(
                children: [
                  Expanded(flex: 2, child: section),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: _QuickTipsPanel(errorMessage: controller.errorMessage),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: controller.isAnalyzing
                      ? null
                      : () => controller.captureFromCamera(),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Quick Camera (image_picker)'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.isAnalyzing
                      ? null
                      : () async {
                          final image = await Navigator.of(context).push<XFile>(
                            MaterialPageRoute(
                              builder: (_) => const CameraCaptureScreen(),
                            ),
                          );
                          if (image != null) controller.addCapturedImage(image);
                        },
                  icon: const Icon(Icons.camera),
                  label: const Text('Advanced Camera (camera)'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.isAnalyzing
                      ? null
                      : () => controller.pickFromGallery(),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Pick from gallery'),
                ),
                TextButton.icon(
                  onPressed: controller.selectedImages.isEmpty
                      ? null
                      : controller.clearSelectedImages,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (controller.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              controller.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        _SelectedImagesStrip(controller: controller),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: controller.isAnalyzing
              ? null
              : () async {
                  final result = await controller.analyzeSelectedImages();
                  if (result == null || !context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResultsScreen(analysisResult: result),
                    ),
                  );
                },
          icon: controller.isAnalyzing
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.science_outlined),
          label: Text(
            controller.isAnalyzing
                ? 'Analyzing with on-device + fallback ML...'
                : 'Analyze Plant',
          ),
        ),
      ],
    );
  }
}

class _SelectedImagesStrip extends StatelessWidget {
  const _SelectedImagesStrip({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final images = controller.selectedImages;
    if (images.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('No images selected yet. Add one or more photos.'),
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final image = images[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(image.path),
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 14,
                    onPressed: () => controller.removeImageAt(index),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: images.length,
      ),
    );
  }
}

class _QuickTipsPanel extends StatelessWidget {
  const _QuickTipsPanel({this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Capture Tips',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text('• Use natural light and avoid glare.'),
        const Text('• Capture leaf + stem + surrounding context.'),
        const Text('• Take multiple photos for better confidence.'),
        const Text('• Include diseased area close-ups when present.'),
        if (errorMessage != null) ...[
          const SizedBox(height: 18),
          Text(
            errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}
