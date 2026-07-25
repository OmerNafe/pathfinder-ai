import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'floating_card.dart';

/// Shown wherever a screen would otherwise display gap/task/certificate
/// content before the applicant has actually completed pathway setup —
/// no sample occupation, country, or progress presented as if it were
/// real. Used by the dashboard, gaps/tasks overviews, and the certificate
/// screen so the empty state reads the same everywhere.
class SetupRequiredCard extends StatelessWidget {
  const SetupRequiredCard({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel = 'Set up your pathway',
  });

  final String title;
  final String message;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return FloatingCard(
      accentColor: AppColors.gold,
      onTap: () => context.go('/pathway/edit'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.route_outlined, color: AppColors.gold, size: 20),
          ),
          const SizedBox(height: 18),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go('/pathway/edit'),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.backgroundDeep,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
