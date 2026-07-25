import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/push_notification_service.dart';
import '../state/notification_prefs_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/floating_card.dart';
import '../widgets/page_shell.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  bool _requestingPush = false;

  Future<void> _showDeleteDialog(BuildContext context) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (deleted == true && context.mounted) {
      context.go('/sign-in');
      AppSnackBar.show(context, 'Your account has been deleted.');
    }
  }

  /// Turning push ON has to actually request browser permission and
  /// register a real device token before the preference is allowed to
  /// flip true — otherwise this is the exact "looks enabled but isn't"
  /// trap already fixed elsewhere in this screen tonight. Turning it off
  /// never fails, so it just updates the preference directly.
  Future<void> _setPushEnabled(bool value) async {
    if (!value) {
      ref.read(notificationPrefsProvider.notifier).setPushEnabled(false);
      return;
    }
    setState(() => _requestingPush = true);
    try {
      await PushNotificationService.requestAndRegister();
      ref.read(notificationPrefsProvider.notifier).setPushEnabled(true);
    } on PushNotificationException catch (e) {
      if (mounted) AppSnackBar.show(context, e.message);
    } finally {
      if (mounted) setState(() => _requestingPush = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onChanged: _requestingPush ? null : _setPushEnabled,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Legal', style: _label(context)),
                const SizedBox(height: 12),
                _LegalLinkRow(label: 'Terms of Service', onTap: () => context.go('/terms')),
                const SizedBox(height: 10),
                _LegalLinkRow(label: 'Privacy Policy', onTap: () => context.go('/privacy')),
                const SizedBox(height: 10),
                _LegalLinkRow(label: 'About us', onTap: () => context.go('/about')),
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
                        'Permanently remove your account and all uploaded documents. This cannot be undone.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _showDeleteDialog(context),
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

class _LegalLinkRow extends StatelessWidget {
  const _LegalLinkRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

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

/// Requires typing DELETE before the confirm button even enables — a real
/// irreversible action deserves more friction than a single click through
/// a dialog. Pops with `true` only once the account is actually gone.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _deleting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canConfirm => _controller.text.trim() == 'DELETE' && !_deleting;

  Future<void> _confirm() async {
    setState(() {
      _deleting = true;
      _error = null;
    });
    try {
      await AuthService.deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.hairlineStrong),
      ),
      title: const Text('Delete account?', style: TextStyle(color: AppColors.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This permanently deletes your account, pathway, uploaded documents, and all '
            'progress. There is no way to undo this.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Type DELETE to confirm',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5, letterSpacing: 0.4),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            enabled: !_deleting,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.backgroundElevated,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.hairline),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12.5)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canConfirm ? _confirm : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            disabledBackgroundColor: AppColors.danger.withValues(alpha: 0.3),
          ),
          child: _deleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Delete permanently'),
        ),
      ],
    );
  }
}
