import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/sample_dashboard_data.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_card.dart';
import '../widgets/ghost_button.dart';
import '../widgets/page_shell.dart';

class LandingItemDetailScreen extends StatelessWidget {
  const LandingItemDetailScreen({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final item = sampleLandingItems[index];

    return PageShell(
      pageTitle: 'Soft landing hub',
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flight_takeoff, color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
                    Text(item.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FloatingCard(
            accentColor: AppColors.gold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 24),
                GhostButton(label: 'Explore providers', color: AppColors.gold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
