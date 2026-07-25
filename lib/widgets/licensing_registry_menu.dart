import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/document_requirements.dart';
import '../data/occupation_registration_ledger.dart';
import '../theme/app_colors.dart';

/// Top-nav entry point for the occupation-level Licensing Registry —
/// a dropdown so any page can jump straight to a category's ledger
/// without first landing on the dashboard.
class LicensingRegistryMenu extends StatelessWidget {
  const LicensingRegistryMenu({super.key, required this.isMobile});

  final bool isMobile;

  IconData _iconFor(OccupationCategory category) {
    switch (category) {
      case OccupationCategory.healthcare:
        return Icons.medical_services_outlined;
      case OccupationCategory.engineering:
        return Icons.precision_manufacturing_outlined;
      case OccupationCategory.trades:
        return Icons.build_outlined;
      case OccupationCategory.education:
        return Icons.school_outlined;
      case OccupationCategory.transport:
        return Icons.flight_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  PopupMenuItem<OccupationCategory?> _item(IconData icon, String label, OccupationCategory? value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<OccupationCategory?>(
      tooltip: 'Licensing registry',
      offset: const Offset(0, 46),
      color: AppColors.surfaceCardHover,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.hairlineStrong),
      ),
      onSelected: (category) {
        if (category == null) {
          context.go('/licensing-registry');
        } else {
          context.go('/licensing-registry/${category.name}');
        }
      },
      itemBuilder: (context) => [
        _item(Icons.search, 'Browse all categories', null),
        const PopupMenuDivider(),
        for (final category in licensedOccupationCategories)
          _item(_iconFor(category), occupationCategoryLabels[category]!, category),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.badge_outlined, size: isMobile ? 20 : 16, color: AppColors.teal),
              const SizedBox(width: 8),
              Text(
                isMobile ? 'Licensing' : 'Licensing registry',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.expand_more, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
