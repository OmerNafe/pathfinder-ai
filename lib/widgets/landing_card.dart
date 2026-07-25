import 'package:flutter/material.dart';
import '../data/sample_dashboard_data.dart';
import '../theme/app_colors.dart';
import 'floating_card.dart';

class LandingCard extends StatelessWidget {
  const LandingCard({super.key, required this.item, required this.onTap});

  final SampleLandingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingCard(
      onTap: onTap,
      accentColor: AppColors.gold,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.flight_takeoff, color: AppColors.gold, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                // A fixed-height reservation (not just a maxLines cap) so a
                // one-line subtitle and a two-line subtitle take up the
                // exact same space — otherwise cards with shorter copy end
                // up visibly smaller than their neighbors in the grid.
                SizedBox(
                  height: 34,
                  child: Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
