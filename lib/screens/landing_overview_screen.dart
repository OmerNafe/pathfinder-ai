import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/sample_dashboard_data.dart';
import '../widgets/landing_card.dart';
import '../widgets/page_shell.dart';
import '../widgets/stage_rail.dart';

class LandingOverviewScreen extends StatelessWidget {
  const LandingOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      pageTitle: 'Soft landing hub',
      builder: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageRail(items: buildStageRailItems('/landing')),
          const SizedBox(height: 28),
          Text('Soft landing hub', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Practical services for settling in once your visa comes through.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          ...sampleLandingItems.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LandingCard(
                  item: entry.value,
                  onTap: () => context.go('/landing/${entry.key}'),
                ),
              )),
        ],
      ),
    );
  }
}
