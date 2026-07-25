import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuickNavItem {
  const QuickNavItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

/// Slim pill bar for jumping directly to a section further down the page.
class QuickNavBar extends StatelessWidget {
  const QuickNavBar({super.key, required this.items});

  final List<QuickNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.hairline),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _QuickNavChip(item: items[i]),
              if (i != items.length - 1) const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }
}

/// Same [QuickNavItem]s, collapsed into a single dropdown button anchored
/// to the top-left corner — an alternative to the horizontal [QuickNavBar]
/// pill row, tried as a more compact, less "status bar"-like presentation.
class QuickNavMenu extends StatelessWidget {
  const QuickNavMenu({super.key, required this.items});

  final List<QuickNavItem> items;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VoidCallback>(
      tooltip: 'Jump to a section',
      offset: const Offset(0, 46),
      color: AppColors.surfaceCardHover,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.hairlineStrong),
      ),
      onSelected: (onTap) => onTap(),
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem<VoidCallback>(
            value: item.onTap,
            child: Row(
              children: [
                Icon(item.icon, size: 17, color: item.color),
                const SizedBox(width: 12),
                Text(item.label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5)),
              ],
            ),
          ),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hairline),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_rounded, size: 18, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('Menu', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickNavChip extends StatefulWidget {
  const _QuickNavChip({required this.item});

  final QuickNavItem item;

  @override
  State<_QuickNavChip> createState() => _QuickNavChipState();
}

class _QuickNavChipState extends State<_QuickNavChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: item.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _hovering ? item.color.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: _hovering ? item.color.withValues(alpha: 0.4) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 15, color: item.color),
              const SizedBox(width: 7),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: _hovering ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
