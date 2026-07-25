import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_card.dart';

/// Where Supabase's confirmation email actually lands — it redirects to
/// the app's origin with a `?code=` query param (not a hash route), so
/// this reads it straight from Uri.base rather than go_router's own
/// query-param passing. Exchanges the code for a real session, then
/// either continues into the app or shows a clear failure with a way
/// back to sign-in.
class EmailConfirmedScreen extends StatefulWidget {
  const EmailConfirmedScreen({super.key});

  @override
  State<EmailConfirmedScreen> createState() => _EmailConfirmedScreenState();
}

enum _ConfirmStatus { working, success, failed, missingCode }

class _EmailConfirmedScreenState extends State<EmailConfirmedScreen> {
  _ConfirmStatus _status = _ConfirmStatus.working;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _confirm();
  }

  Future<void> _confirm() async {
    final code = Uri.base.queryParameters['code'];
    if (code == null || code.isEmpty) {
      setState(() => _status = _ConfirmStatus.missingCode);
      return;
    }
    try {
      await AuthService.exchangeCodeForSession(code);
      if (!mounted) return;
      setState(() => _status = _ConfirmStatus.success);
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go('/pathway/edit');
    } on AppAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _ConfirmStatus.failed;
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FloatingCard(
              accentColor: _status == _ConfirmStatus.failed ? AppColors.danger : AppColors.gold,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _icon(),
                  const SizedBox(height: 20),
                  Text(
                    _title(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.displayFontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _message(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.5),
                  ),
                  if (_status == _ConfirmStatus.failed || _status == _ConfirmStatus.missingCode) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.go('/sign-in'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.backgroundDeep,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Back to sign in', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    switch (_status) {
      case _ConfirmStatus.working:
        return const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.gold),
        );
      case _ConfirmStatus.success:
        return Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(color: AppColors.tealSoft, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: AppColors.teal, size: 26),
        );
      case _ConfirmStatus.failed:
      case _ConfirmStatus.missingCode:
        return Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(color: AppColors.dangerSoft, shape: BoxShape.circle),
          child: const Icon(Icons.close, color: AppColors.danger, size: 26),
        );
    }
  }

  String _title() {
    switch (_status) {
      case _ConfirmStatus.working:
        return 'Confirming your email…';
      case _ConfirmStatus.success:
        return 'Email confirmed';
      case _ConfirmStatus.failed:
        return 'Confirmation link didn\'t work';
      case _ConfirmStatus.missingCode:
        return 'Nothing to confirm here';
    }
  }

  String _message() {
    switch (_status) {
      case _ConfirmStatus.working:
        return 'One moment.';
      case _ConfirmStatus.success:
        return 'You\'re all set — taking you to set up your pathway now.';
      case _ConfirmStatus.failed:
        return _errorMessage ?? 'This link may have expired. Try signing in, or request a new confirmation email.';
      case _ConfirmStatus.missingCode:
        return 'This page is only meant to be opened from a confirmation email link.';
    }
  }
}
