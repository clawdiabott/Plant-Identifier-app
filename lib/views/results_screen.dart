import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/results_controller.dart';
import '../models/analysis_result.dart';
import '../models/disease_report.dart';
import '../models/news_item.dart';
import '../services/api/news_service.dart';
import '../widgets/expandable_info_section.dart';
import '../widgets/photo_preview.dart';
import '../widgets/severity_chip.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.analysisResult});
  final AnalysisResult analysisResult;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<List<NewsItem>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsService.instance.fetchPlantNews();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.analysisResult;
    final profile = result.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (result.sourceImagePaths.isNotEmpty)
            PhotoPreview(imagePath: result.sourceImagePaths.first),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.speciesName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.scientificName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.verified_outlined, size: 16),
                        label: Text(
                          'Confidence ${(result.confidence * 100).toStringAsFixed(1)}%',
                        ),
                      ),
                      if (result.usedCloudFallback)
                        const Chip(
                          avatar: Icon(Icons.cloud_outlined, size: 16),
                          label: Text('Cloud ML fallback used'),
                        ),
                      if (result.locationHint != null)
                        Chip(
                          avatar: const Icon(Icons.place_outlined, size: 16),
                          label: Text(result.locationHint!),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ExpandableInfoSection(
            title: 'Common Names',
            children: [
              Text(
                profile.commonNames.isEmpty
                    ? 'No common names available'
                    : profile.commonNames.join(', '),
              ),
            ],
          ),
          ExpandableInfoSection(
            title: 'Detailed Care Guide',
            initiallyExpanded: true,
            children: [
              _bullet('Watering', profile.careGuide.watering),
              _bullet('Soil', profile.careGuide.soilType),
              _bullet('Sunlight', profile.careGuide.sunlight),
              _bullet('Temperature', profile.careGuide.temperature),
              _bullet('Pruning', profile.careGuide.pruning),
              _bullet('Fertilizing', profile.careGuide.fertilizing),
            ],
          ),
          ExpandableInfoSection(
            title: 'Growth Stages',
            children: profile.growthStages.map((g) => _bulletSimple(g)).toList(),
          ),
          ExpandableInfoSection(
            title: 'Potential Uses',
            children: profile.potentialUses.map((u) => _bulletSimple(u)).toList(),
          ),
          if (result.diseaseReport.hasIssues) ...[
            const SizedBox(height: 6),
            Text(
              'Detected Disease/Malnutrition Issues',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            ...result.diseaseReport.issues.map(_issueCard),
          ] else ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No major disease or nutrient deficiency detected in sampled images.',
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          ExpandableInfoSection(
            title: 'Emerging Plant Health News',
            children: [
              FutureBuilder<List<NewsItem>>(
                future: _newsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    );
                  }
                  final data = snapshot.data ?? const [];
                  if (data.isEmpty) {
                    return const Text('No updates available (offline/cache miss).');
                  }
                  return Column(
                    children: data.take(5).map((item) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.title),
                        subtitle: Text(item.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.open_in_new),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Consumer<ResultsController>(
            builder: (context, controller, _) {
              return FilledButton.icon(
                onPressed: controller.isSaving
                    ? null
                    : () async {
                        await controller.savePlant(result);
                        if (!context.mounted) return;
                        final message = controller.message;
                        if (message != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      },
                icon: controller.isSaving
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bookmark_add_outlined),
                label: const Text('Save Plant'),
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Analyzed ${DateFormat.yMMMd().add_jm().format(result.analyzedAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _bullet(String title, String value) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: textStyle,
          children: [
            TextSpan(
              text: '$title: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _bulletSimple(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _issueCard(DiseaseIssue issue) {
    return Card(
      color: Colors.red.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    issue.issueName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SeverityChip(severity: issue.severity),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Symptoms', style: TextStyle(fontWeight: FontWeight.w600)),
            ...issue.symptoms.map((s) => _bulletSimple(s)),
            const Text('Likely Causes', style: TextStyle(fontWeight: FontWeight.w600)),
            ...issue.causes.map((c) => _bulletSimple(c)),
            const Text('Step-by-step Fix', style: TextStyle(fontWeight: FontWeight.w600)),
            ...issue.treatments.map((t) => _bulletSimple(t)),
          ],
        ),
      ),
    );
  }
}
