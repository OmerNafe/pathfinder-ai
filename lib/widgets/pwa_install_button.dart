import 'dart:async';

import 'package:flutter/material.dart';
import '../services/pwa_install_service.dart';
import '../theme/app_colors.dart';

/// The "download the app" touchpoint referenced everywhere on this app's
/// marketing copy — honestly, since there's no published native app yet,
/// this triggers a real PWA install (a genuine home-screen app with no
/// browser chrome) rather than linking to an App/Play Store listing that
/// doesn't exist. Hides itself entirely once installed, or if the browser
/// never made an install available and isn't iOS Safari either.
class PwaInstallButton extends StatefulWidget {
  const PwaInstallButton({super.key, this.size = 36});

  final double size;

  @override
  State<PwaInstallButton> createState() => _PwaInstallButtonState();
}

class _PwaInstallButtonState extends State<PwaInstallButton> {
  bool _visible = false;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    if (PwaInstallService.isStandalone) return;
    // beforeinstallprompt fires shortly after load -- a short delay lets it
    // land before deciding whether this button has anything to do. Kept as
    // a cancelable Timer (not a bare Future.delayed) so disposing this
    // widget before the delay elapses cleanly cancels it instead of
    // leaving a dangling timer -- flutter_test asserts none are still
    // pending once a test's widget tree is torn down.
    _checkTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _visible = PwaInstallService.isPromptAvailable || PwaInstallService.isIOSSafari);
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (PwaInstallService.isPromptAvailable) {
      final accepted = await PwaInstallService.promptInstall();
      if (!mounted) return;
      if (accepted) setState(() => _visible = false);
    } else if (PwaInstallService.isIOSSafari) {
      showDialog<void>(context: context, builder: (_) => const _IOSInstallInstructionsDialog());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Zero-width when hidden (not just invisible) so it never leaves a
    // stray gap in the header's fixed-spacing Row.
    if (!_visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Tooltip(
        message: 'Install PathFinder AI on your device',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: AppColors.tealSoft,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.install_mobile_outlined, size: 18, color: AppColors.teal),
            ),
          ),
        ),
      ),
    );
  }
}

class _IOSInstallInstructionsDialog extends StatelessWidget {
  const _IOSInstallInstructionsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.hairlineStrong),
      ),
      title: const Text('Install on iPhone or iPad', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text(
        'Tap the Share icon in Safari\'s toolbar, then choose "Add to Home Screen." '
        'PathFinder AI will appear as its own icon, with no browser bar — the closest thing '
        'to the real app until a native version ships.',
        style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it', style: TextStyle(color: AppColors.teal)),
        ),
      ],
    );
  }
}
