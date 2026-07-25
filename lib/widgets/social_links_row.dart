import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/social_links.dart';
import '../theme/app_colors.dart';

/// True once at least one real handle is set in social_links.dart — lets
/// callers skip rendering an empty "Get in touch" heading with nothing
/// under it.
bool get hasAnySocialLinks =>
    SocialLinks.linkedIn != null || SocialLinks.instagram != null || SocialLinks.x != null || SocialLinks.email != null;

class _SocialLink {
  const _SocialLink({required this.icon, required this.url, required this.label});
  final IconData icon;
  final String url;
  final String label;
}

/// Renders nothing until real accounts exist — see social_links.dart.
/// Nothing here ever links to a placeholder or a dead page.
class SocialLinksRow extends StatelessWidget {
  const SocialLinksRow({super.key, this.iconSize = 18});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final links = [
      if (SocialLinks.linkedIn != null)
        _SocialLink(icon: Icons.business_center_outlined, url: SocialLinks.linkedIn!, label: 'LinkedIn'),
      if (SocialLinks.instagram != null)
        _SocialLink(icon: Icons.camera_alt_outlined, url: SocialLinks.instagram!, label: 'Instagram'),
      if (SocialLinks.x != null) _SocialLink(icon: Icons.alternate_email, url: SocialLinks.x!, label: 'X'),
      if (SocialLinks.email != null)
        _SocialLink(icon: Icons.mail_outline, url: 'mailto:${SocialLinks.email}', label: 'Email'),
    ];

    if (links.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final link in links)
          Tooltip(
            message: link.label,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse(link.url), webOnlyWindowName: '_blank'),
                child: Container(
                  width: iconSize + 20,
                  height: iconSize + 20,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Icon(link.icon, size: iconSize, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
