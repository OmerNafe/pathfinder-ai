import 'package:flutter/material.dart';
import '../data/processing_time_estimates.dart';
import '../theme/app_colors.dart';
import 'floating_card.dart';

/// A directional "how long will this actually take" answer — the single
/// most emotionally loaded question for this audience — built from sourced
/// public processing-time guidance (see processing_time_estimates.dart),
/// never a fabricated specific date. Deliberately a range with a visible
/// "directional, not a guarantee" caveat rather than false precision.
class EtaEstimateCard extends StatelessWidget {
  const EtaEstimateCard({super.key, required this.targetCountry, this.compact = false});

  final String targetCountry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final estimate = processingTimeEstimates[targetCountry];
    if (estimate == null) return const SizedBox.shrink();

    if (compact) {
      return FloatingCard(
        accentColor: AppColors.teal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.hourglass_top_rounded, color: AppColors.teal, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Typical timeline', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${estimate.rangeLabel} for ${estimate.programName}, once submitted.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return FloatingCard(
      accentColor: AppColors.teal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_top_rounded, color: AppColors.teal, size: 20),
              const SizedBox(width: 10),
              Text('Typical timeline', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                estimate.rangeLabel,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'for ${estimate.programName}, once your application is submitted',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            estimate.note,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Text(
            'Directional, from public guidance — not a guarantee. Always confirm current '
            'processing times on the official government portal.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 10.5,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}
