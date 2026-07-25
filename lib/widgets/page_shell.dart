import 'package:flutter/material.dart';
import 'app_shell_header.dart';

/// Shared premium background + responsive layout used by every page,
/// so the dashboard and every sub-page look and feel like one product.
class PageShell extends StatelessWidget {
  const PageShell({super.key, required this.builder, this.pageTitle});

  final Widget Function(BuildContext context, bool isMobile) builder;
  final String? pageTitle;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isMobile = width < 700;
          final isTablet = width >= 700 && width < 1100;
          final horizontalPadding = isMobile ? 20.0 : (isTablet ? 40.0 : 80.0);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShellHeader(isMobile: isMobile, pageTitle: pageTitle),
                      const SizedBox(height: 40),
                      builder(context, isMobile),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    // The rotating backdrop lives once, above the router (see main.dart) —
    // this Scaffold stays transparent so that single instance shows through
    // instead of every page drawing (and resetting) its own.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: content,
    );
  }
}
