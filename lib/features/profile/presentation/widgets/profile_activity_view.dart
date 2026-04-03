import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_church/features/bible/presentation/providers/bible_controller.dart';
import 'package:go_router/go_router.dart';

class ProfileActivityView extends ConsumerWidget {
  const ProfileActivityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Watching the bookmark provider for the count
    final bookmarkCount = ref.watch(bookmarkProvider).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Library", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.collections_bookmark, color: colorScheme.primary, size: 20),
            ),
            title: const Text("Saved Verses"),
            subtitle: Text("$bookmarkCount items"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => context.push('/bookmarks'),
          ),
        ),
      ],
    );
  }
}