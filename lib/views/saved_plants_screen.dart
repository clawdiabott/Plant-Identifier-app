import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/saved_plants_controller.dart';
import 'results_screen.dart';

class SavedPlantsScreen extends StatelessWidget {
  const SavedPlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Plants')),
      body: Consumer<SavedPlantsController>(
        builder: (context, controller, _) {
          final plants = controller.savedPlants;
          if (plants.isEmpty) {
            return const Center(
              child: Text('No saved plants yet. Analyze and save your first one.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plants.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = plants[index];
              return Card(
                child: ListTile(
                  title: Text(item.profile.speciesName),
                  subtitle: Text(
                    '${item.profile.scientificName}\n'
                    '${DateFormat.yMMMd().add_jm().format(item.analyzedAt)}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ResultsScreen(analysisResult: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
