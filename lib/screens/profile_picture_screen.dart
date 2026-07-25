import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../state/profile_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/floating_card.dart';
import '../widgets/page_shell.dart';

class ProfilePictureScreen extends ConsumerStatefulWidget {
  const ProfilePictureScreen({super.key});

  @override
  ConsumerState<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends ConsumerState<ProfilePictureScreen> {
  bool _picking = false;

  Future<void> _pickPhoto() async {
    setState(() => _picking = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      ref.read(profileProvider.notifier).updateAvatar(bytes);

      if (!mounted) return;
      AppSnackBar.show(context, 'Profile picture updated');
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, "Couldn't open the photo picker. Please try again.");
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarBytes = ref.watch(profileProvider).avatarBytes;

    return PageShell(
      pageTitle: 'Profile picture',
      builder: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to dashboard'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text('Change profile picture', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'This photo appears on your profile and account menu.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          FloatingCard(
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceCardHover,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(BorderSide(color: AppColors.hairlineStrong)),
                  ),
                  child: avatarBytes != null
                      ? Image.memory(avatarBytes, fit: BoxFit.cover)
                      : const Icon(Icons.person_outline, size: 40, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _picking ? null : _pickPhoto,
                  icon: _picking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.backgroundDeep,
                          ),
                        )
                      : const Icon(Icons.upload_outlined, size: 18),
                  label: Text(_picking ? 'Opening picker…' : 'Upload new photo'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.backgroundDeep,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
