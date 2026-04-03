import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_church/core/di/providers.dart';
import 'package:gentle_church/core/utils/app_utils.dart';
import 'package:gentle_church/features/profile/presentation/widgets/profile_header.dart';
import 'package:gentle_church/features/profile/presentation/widgets/settings_view.dart';
import 'package:gentle_church/features/profile/presentation/widgets/profile_activity_view.dart'; // Imported the separated logic
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  String _generateGravatar(String email) {
    final hash = md5.convert(utf8.encode(email.trim().toLowerCase())).toString();
    return "https://www.gravatar.com/avatar/$hash?s=200&d=mp";
  }

  Future<void> _pickImage(WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 70);
    if (image != null) {
      await ref.read(authRepositoryProvider).updateProfileImage(File(image.path));
    }
  }

  // Logic to handle Name Editing
  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Name"),
        content: TextField(
          controller: controller, 
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter your name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).updateDisplayName(controller.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, WidgetRef ref, String email) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Upload from Gallery'),
              onTap: () { Navigator.pop(context); _pickImage(ref, ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () { Navigator.pop(context); _pickImage(ref, ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Use Gravatar (Email Photo)'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authRepositoryProvider).updatePhotoUrl(_generateGravatar(email));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final theme = Theme.of(context);

    return authState.when(
      data: (user) {
        if (user == null) return const Center(child: Text("Please Login"));
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Profile Header (Avatar & Email)
            ProfileHeader(
              user: user,
              onEditImage: () => _showImageSourceSheet(context, ref, user.email ?? ""),
            ),

            // 2. Edit Name Action
            Center(
              child: TextButton.icon(
                onPressed: () => _showEditNameDialog(context, ref, user.displayName ?? ""),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text("Edit Username"),
              ),
            ),
            
            const SizedBox(height: 24),

            // 3. Activity / Library Section (The separated file)
            const ProfileActivityView(),

            const SizedBox(height: 24),

            // 4. General Settings Section
            Text("General", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text("Settings"),
                    subtitle: const Text("Theme and Account"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const SettingsView()),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.power_settings_new),
                    title: const Text("Exit Application"),
                    onTap: () => AppUtils.confirmExit(context),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
    );
  }
}