// lib/widgets/common/profile_avatar.dart
import 'package:dhyana/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return userProfileAsync.when(
      data: (user) {
        // Check if the user has a valid network image
        final hasProfileImage = user?.profilePictureUrl != null && user!.profilePictureUrl!.startsWith('http');

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () => context.go('/profile'),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: hasProfileImage ? NetworkImage(user!.profilePictureUrl!) : null,
              child: !hasProfileImage
                  ? const Icon(Icons.person_outline, size: 24)
                  : null,
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, st) => IconButton(
        icon: const Icon(Icons.person_outline),
        onPressed: () => context.go('/profile'),
        tooltip: 'Profile',
      ),
    );
  }
}