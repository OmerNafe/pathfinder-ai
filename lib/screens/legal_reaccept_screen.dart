import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/legal_acceptance_service.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_card.dart';
import '../widgets/journey_backdrop.dart';

/// Shown when a signed-in applicant's recorded acceptance of Terms or
/// Privacy is older than the current version — top-tier apps (banking,
/// KYC) re-gate access on a material policy change rather than silently
/// assuming an old acceptance still covers new terms. Not persistently
/// skippable; the only way past it is to agree, or sign out.
class LegalReacceptScreen extends StatefulWidget {
  const LegalReacceptScreen({super.key});

  @override
  State<LegalReacceptScreen> createState() => _LegalReacceptScreenState();
}

class _LegalReacceptScreenState extends State<LegalReacceptScreen> {
  bool _agreed = false;
  bool _submitting = false;

  Future<void> _continue() async {
    setState(() => _submitting = true);
    await LegalAcceptanceService.recordAcceptance(LegalDocument.terms);
    await LegalAcceptanceService.recordAcceptance(LegalDocument.privacy);
    if (!mounted) return;
    context.go('/');
  }

  Future<void> _signOutInstead() async {
    await AuthService.signOut();
    if (!mounted) return;
    context.go('/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JourneyBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FloatingCard(
                  accentColor: AppColors.gold,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our terms have been updated',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'We\'ve updated our Terms of Service and/or Privacy Policy since you last '
                        'agreed to them. Please review and re-accept to continue using PathFinder AI.',
                        style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 13.5),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 20,
                        runSpacing: 8,
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/terms'),
                            child: const Text(
                              'Terms of Service',
                              style: TextStyle(
                                color: AppColors.teal,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/privacy'),
                            child: const Text(
                              'Privacy Policy',
                              style: TextStyle(
                                color: AppColors.teal,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _agreed,
                              onChanged: (v) => setState(() => _agreed = v ?? false),
                              activeColor: AppColors.teal,
                              side: const BorderSide(color: AppColors.hairlineStrong),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'I agree to the updated Terms of Service and Privacy Policy.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: (_agreed && !_submitting) ? _continue : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.backgroundDeep,
                            disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.35),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            _submitting ? 'Continuing…' : 'Continue',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: _submitting ? null : _signOutInstead,
                          child: const Text(
                            'Sign out instead',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
