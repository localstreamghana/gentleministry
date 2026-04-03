import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_church/core/di/providers.dart';

class SermonListView extends ConsumerWidget {
  const SermonListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sermonsAsync = ref.watch(sermonsProvider);
    final theme = Theme.of(context); // Pull the theme context

    return sermonsAsync.when(
      data: (sermons) {
        if (sermons.isEmpty) {
          return const Center(child: Text("No sermons available yet."));
        }
        return ListView.builder(
          itemCount: sermons.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemBuilder: (context, index) {
            final sermon = sermons[index];
            
            // The Card now automatically uses the shape/elevation from your AppTheme
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.play_circle_fill, // Switched to filled for better brand visibility
                  color: theme.colorScheme.primary, // Dynamically uses Church Blue
                  size: 40,
                ),
                title: Text(
                  sermon.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${sermon.speaker} • ${sermon.date.day}/${sermon.date.month}",
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios, 
                  size: 16, 
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                onTap: () {
                  // Logic to play sermon
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Error: $e")),
    );
  }
}