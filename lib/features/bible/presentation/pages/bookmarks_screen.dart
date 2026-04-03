import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_church/features/bible/presentation/providers/bible_controller.dart';
import 'package:share_plus/share_plus.dart';
// 1. IMPORT YOUR MODEL HERE

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This now watches a List<Verse> instead of List<String>
    final bookmarks = ref.watch(bookmarkProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Verses"),
        centerTitle: true,
      ),
      body: bookmarks.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final verse = bookmarks[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      verse.text, // Now Dart knows what '.text' is!
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "${verse.book} ${verse.chapter}:${verse.verse}",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'share') {
                          Share.share(
                            "${verse.text}\n— ${verse.book} ${verse.chapter}:${verse.verse}"
                          );
                        } else if (value == 'remove') {
                          // Pass the verse object to the notifier
                          ref.read(bookmarkProvider.notifier).toggleBookmark(verse);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'share', 
                          child: Text("Share"),
                        ),
                        const PopupMenuItem(
                          value: 'remove', 
                          child: Text("Remove"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline, 
            size: 80, 
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text("No bookmarks yet", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text("Verses you save will appear here."),
        ],
      ),
    );
  }
}