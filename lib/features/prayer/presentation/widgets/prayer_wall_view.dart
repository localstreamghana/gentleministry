import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_church/core/di/providers.dart';

class PrayerWallView extends ConsumerWidget {
  const PrayerWallView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayersAsync = ref.watch(prayersStreamProvider);
    // Access the current theme's color scheme
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: prayersAsync.when(
        data: (prayers) {
          if (prayers.isEmpty) {
            return const Center(child: Text("No prayer requests yet. Be the first!"));
          }
          return ListView.builder(
            itemCount: prayers.length,
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemBuilder: (context, index) {
              final prayer = prayers[index];
              final prayerId = prayer['id'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                // Card colors/shapes are now handled by cardTheme in AppTheme
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        // Uses primaryBlue from theme
                        backgroundColor: colorScheme.primary,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        prayer['text'] ?? "",
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text("By ${prayer['userName'] ?? 'Anonymous'}"),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${prayer['amenCount'] ?? 0} others are praying",
                            style: TextStyle(
                              // Uses the tertiary (Green) or a subtle surface variant
                              color: colorScheme.onSurfaceVariant, 
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => ref.read(authRepositoryProvider).addAmen(prayerId),
                            icon: const Icon(Icons.front_hand_outlined, size: 18),
                            label: const Text("Amen"),
                            style: TextButton.styleFrom(
                              // Pulls from primaryBlue (Light) or Light Blue (Dark)
                              foregroundColor: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text("Connection error. Check your internet.")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPrayerDialog(context, ref),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  void _showPrayerDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Prayer Request"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "How can we pray for you?",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                await ref.read(authRepositoryProvider).addPrayerRequest(text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Prayer request posted.")),
                  );
                }
              }
            },
            // The style for ElevatedButton is inherited automatically from primary color
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }
}