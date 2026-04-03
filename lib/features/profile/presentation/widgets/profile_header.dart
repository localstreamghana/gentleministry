import 'package:flutter/material.dart';
import 'package:gentle_church/features/auth/domain/entities/user_entity.dart'; // Using User for consistency

class ProfileHeader extends StatelessWidget {
  final UserEntity user; // Ensure this matches your entity/user type
  final VoidCallback onEditImage;

  const ProfileHeader({
    super.key, 
    required this.user, 
    required this.onEditImage
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: onEditImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
                  child: !hasPhoto 
                    ? Icon(Icons.person, size: 50, color: colorScheme.primary) 
                    : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primary,
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // PRIORITY: Display Name -> Email Prefix -> "Member"
          Text(
            (user.displayName != null && user.displayName!.isNotEmpty)
                ? user.displayName!
                : (user.email?.split('@')[0] ?? "Member"),
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(user.email ?? "", style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}