import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/legal_acceptance_service.dart';
import '../theme/app_colors.dart';

/// Ensures the signed-in applicant has explicitly agreed to AI-assisted
/// document processing before their first upload — a distinct, specific
/// consent from "I agree to the Terms of Service," required both by
/// GDPR's specific-consent principle and Apple's 2026 App Store rules on
/// sharing personal data with third-party AI systems. Returns true if
/// it's fine to proceed with the upload, false if the applicant declined
/// (or wanted to read the Privacy Policy first — treated as "not this
/// time," not a permanent refusal; the next upload attempt asks again).
Future<bool> ensureAiProcessingConsent(BuildContext context) async {
  final alreadyAccepted = await LegalAcceptanceService.hasAcceptedCurrentVersion(LegalDocument.aiProcessing);
  if (alreadyAccepted) return true;
  if (!context.mounted) return false;

  final agreed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _AiProcessingConsentDialog(),
  );
  if (agreed != true) return false;

  await LegalAcceptanceService.recordAcceptance(LegalDocument.aiProcessing);
  return true;
}

class _AiProcessingConsentDialog extends StatelessWidget {
  const _AiProcessingConsentDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.hairlineStrong),
      ),
      title: const Text('Before your first AI review', style: TextStyle(color: AppColors.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To review a document, its contents are sent to OpenAI\'s API to extract visible '
            'fields — like a name or a date — and compare them against the requirement you\'re '
            'satisfying. The AI only extracts facts; it never makes the final decision on your '
            'application, and every result is clearly marked as provisional.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 13),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(false);
              context.push('/privacy');
            },
            child: const Text(
              'Read the full Privacy Policy first',
              style: TextStyle(
                color: AppColors.teal,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Not now', style: TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.backgroundDeep,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('I agree, continue', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
