import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_church/core/di/providers.dart';
import 'package:gentle_church/core/theme/theme_provider.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("App Settings", style: theme.textTheme.titleMedium),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text("Dark Mode"),
              trailing: Switch(
                value: ref.watch(themeProvider) == ThemeMode.dark,
                onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(val),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Account", style: theme.textTheme.titleMedium),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text("Logout", style: TextStyle(color: theme.colorScheme.error)),
              subtitle: const Text("Sign out of your account"),
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) Navigator.pop(context); // Go back after logout
              },
            ),
          ),
        ],
      ),
    );
  }
}