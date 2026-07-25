import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'licensing_registry_menu.dart';
import 'notification_bell.dart';
import 'profile_menu.dart';
import 'pwa_install_button.dart';

/// Persistent header shown at the top of every page. The logo always
/// navigates back to the dashboard, and an optional [pageTitle] renders
/// a small breadcrumb next to it so users know where they are.
class AppShellHeader extends StatelessWidget {
  const AppShellHeader({super.key, required this.isMobile, this.pageTitle});

  final bool isMobile;
  final String? pageTitle;

  @override
  Widget build(BuildContext context) {
    final logo = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.explore_outlined, size: 20, color: AppColors.backgroundDeep),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'PathFinder AI',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: AppTheme.displayFontFamily,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
            ),
            if (pageTitle != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted.withValues(alpha: 0.6)),
              ),
              Flexible(
                child: Text(
                  pageTitle!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // Only the lower-priority items scroll away if space is tight —
    // notifications and the profile menu (sign-out lives there) must always
    // stay fully visible, never pushed off the edge of a scroll strip with
    // no visual hint that there's more to the right.
    final overflowActions = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LicensingRegistryMenu(isMobile: isMobile),
          const SizedBox(width: 8),
          _QuestionsButton(isMobile: isMobile),
        ],
      ),
    );

    // Bigger, properly touch-sized on mobile (44px meets the standard
    // minimum tap target) rather than the same compact size used for a
    // mouse pointer on desktop.
    final actionSize = isMobile ? 44.0 : 36.0;
    final pinnedActions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PwaInstallButton(size: actionSize),
        NotificationBell(size: actionSize),
        const SizedBox(width: 12),
        ProfileMenu(size: actionSize),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          logo,
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: overflowActions),
              const SizedBox(width: 12),
              pinnedActions,
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: logo),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: overflowActions),
              const SizedBox(width: 12),
              pinnedActions,
            ],
          ),
        ),
      ],
    );
  }
}

/// Direct link to the searchable help center — a plain button rather than
/// a dropdown like [LicensingRegistryMenu], since there's one destination,
/// not a category to pick first.
class _QuestionsButton extends StatelessWidget {
  const _QuestionsButton({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/questions'),
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
              Icon(Icons.help_outline, size: isMobile ? 20 : 16, color: AppColors.gold),
              const SizedBox(width: 8),
              const Text(
                'Questions',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
