import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/notification_prefs_state.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_card.dart';
import '../widgets/page_shell.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    return PageShell(
      pageTitle: 'Account settings',
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
          Text('Account settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          FloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications', style: _label(context)),
                const SizedBox(height: 12),
                _SettingsSwitchRow(
                  label: 'Email notifications',
                  value: prefs.emailEnabled,
                  onChanged: (v) => ref.read(notificationPrefsProvider.notifier).setEmailEnabled(v),
                ),
                const SizedBox(height: 12),
                _SettingsSwitchRow(
                  label: 'Push notifications',
                  value: prefs.pushEnabled,
                  onChanged: (v) => ref.read(notificationPrefsProvider.notifier).setPushEnabled(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FloatingCard(
            accentColor: AppColors.danger,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete account',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.danger),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Permanently remove your account and all uploaded documents.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.surfaceCard,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Delete account?', style: TextStyle(color: AppColors.textPrimary)),
                      content: const Text(
                        'This action is irreversible in the real product. Not wired up yet.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _label(BuildContext context) => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.6);
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.teal,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
