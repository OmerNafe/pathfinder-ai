import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/floating_card.dart';
import '../widgets/reactive_background.dart';

enum _Stage { form, checking, noAccount, sent }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  _Stage _stage = _Stage.form;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      AppSnackBar.show(context, 'Please enter your email.');
      return;
    }

    setState(() => _stage = _Stage.checking);
    try {
      final exists = await AuthService.checkEmailExists(email);
      if (!mounted) return;
      if (!exists) {
        setState(() => _stage = _Stage.noAccount);
        return;
      }
      await AuthService.sendPasswordReset(email);
      if (!mounted) return;
      setState(() => _stage = _Stage.sent);
    } on AppAuthException catch (e) {
      if (!mounted) return;
      setState(() => _stage = _Stage.form);
      AppSnackBar.show(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReactiveBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            gradient: const LinearGradient(
                              colors: [AppColors.gold, AppColors.teal],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Icons.explore_outlined,
                              size: 18, color: AppColors.backgroundDeep),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'PathFinder AI',
                          style: TextStyle(
                            fontFamily: AppTheme.displayFontFamily,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    FloatingCard(child: _buildBody(context)),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () => context.go('/sign-in'),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Back to sign in'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_stage) {
      case _Stage.form:
      case _Stage.checking:
        return _buildForm(context);
      case _Stage.noAccount:
        return _buildNoAccount(context);
      case _Stage.sent:
        return _buildConfirmation(context);
    }
  }

  Widget _buildForm(BuildContext context) {
    final checking = _stage == _Stage.checking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reset your password', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          "Enter the email on your account and we'll send you a reset link.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          enabled: !checking,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.backgroundElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: checking ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.backgroundDeep,
              disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: checking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.backgroundDeep),
                  )
                : const Text('Send reset link', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildNoAccount(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.person_search_outlined, color: AppColors.amber, size: 28),
        const SizedBox(height: 16),
        Text('No account with that email', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          "We couldn't find an account for ${_emailController.text.trim()}. "
          "Double-check the address, or start your journey instead.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.go('/sign-in'),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Start your journey', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => setState(() => _stage = _Stage.form),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            child: const Text('Try a different email'),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.mark_email_read_outlined, color: AppColors.teal, size: 28),
        const SizedBox(height: 16),
        Text('Check your inbox', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'A reset link is on its way to ${_emailController.text.trim()}.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
