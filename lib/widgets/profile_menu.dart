import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/profile_state.dart';
import '../theme/app_colors.dart';

enum ProfileMenuAction { editProfile, changePicture, accountSettings, signOut }

/// Clickable profile avatar. Opens a themed dropdown with account actions.
class ProfileMenu extends ConsumerWidget {
  const ProfileMenu({super.key});

  void _handleSelection(BuildContext context, ProfileMenuAction action) {
    switch (action) {
      case ProfileMenuAction.editProfile:
        context.go('/profile/edit');
      case ProfileMenuAction.changePicture:
        context.go('/profile/picture');
      case ProfileMenuAction.accountSettings:
        context.go('/settings/account');
      case ProfileMenuAction.signOut:
        context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarBytes = ref.watch(profileProvider).avatarBytes;

    return PopupMenuButton<ProfileMenuAction>(
      tooltip: 'Account menu',
      offset: const Offset(0, 46),
      color: AppColors.surfaceCardHover,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.hairlineStrong),
      ),
      onSelected: (action) => _handleSelection(context, action),
      itemBuilder: (context) => [
        _item(ProfileMenuAction.editProfile, Icons.person_outline, 'Edit profile'),
        _item(ProfileMenuAction.changePicture, Icons.image_outlined, 'Change profile picture'),
        _item(ProfileMenuAction.accountSettings, Icons.settings_outlined, 'Account settings'),
        const PopupMenuDivider(),
        _item(ProfileMenuAction.signOut, Icons.logout, 'Sign out'),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.surfaceCard,
          backgroundImage: avatarBytes != null ? MemoryImage(avatarBytes) : null,
          child: avatarBytes == null
              ? const Icon(Icons.person_outline, size: 18, color: AppColors.textSecondary)
              : null,
        ),
      ),
    );
  }

  PopupMenuItem<ProfileMenuAction> _item(
    ProfileMenuAction value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}
