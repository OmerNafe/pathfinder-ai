import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/certificate_share_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_card.dart';
import '../widgets/reactive_background.dart';
import '../widgets/status_pill.dart';

/// Reachable by anyone with the link, signed in or not — the destination
/// of every certificate someone shares. Read-only, no account/session
/// required: it fetches one published snapshot via the public
/// get-public-certificate Edge Function and renders it, then offers a
/// clear path back into the product for whoever's looking at it.
class PublicCertificateScreen extends StatefulWidget {
  const PublicCertificateScreen({super.key, required this.token});

  final String token;

  @override
  State<PublicCertificateScreen> createState() => _PublicCertificateScreenState();
}

class _PublicCertificateScreenState extends State<PublicCertificateScreen> {
  late Future<PublicCertificateSnapshot?> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchPublicCertificate(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReactiveBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: FutureBuilder<PublicCertificateSnapshot?>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
                      );
                    }
                    final data = snapshot.data;
                    if (data == null) {
                      return _NotFoundCard();
                    }
                    return _CertificateCard(data: data);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotFoundCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Wordmark(),
        const SizedBox(height: 32),
        FloatingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.link_off, color: AppColors.textMuted, size: 28),
              const SizedBox(height: 16),
              Text("This link isn't valid", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                "The certificate this link points to doesn't exist, or hasn't been published.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _StartJourneyButton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.data});
  final PublicCertificateSnapshot data;

  Color _statusColor(String status) => switch (status) {
        'verified' => AppColors.teal,
        'rejected' => AppColors.danger,
        _ => AppColors.amber,
      };

  String _statusLabel(String status) => switch (status) {
        'verified' => 'Verified',
        'rejected' => 'Needs attention',
        _ => 'Pending',
      };

  @override
  Widget build(BuildContext context) {
    final ratio = data.totalCount == 0 ? 0.0 : data.verifiedCount / data.totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Wordmark(),
        const SizedBox(height: 32),
        FloatingCard(
          accentColor: AppColors.gold,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pathway Certificate', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                '${data.occupation} → ${data.targetCountry}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 28),
              Center(
                child: SizedBox(
                  width: 112,
                  height: 112,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 112,
                        height: 112,
                        child: CircularProgressIndicator(
                          value: ratio,
                          strokeWidth: 8,
                          backgroundColor: AppColors.hairlineStrong,
                          valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${data.verifiedCount}/${data.totalCount}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'VERIFIED',
                            style: TextStyle(fontSize: 9.5, letterSpacing: 0.6, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              for (final req in data.requirements)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(req.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      StatusPill(label: _statusLabel(req.status), color: _statusColor(req.status)),
                    ],
                  ),
                ),
              if (data.publishedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Published ${data.publishedAt!.toLocal().toString().split(' ').first}',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.tealSoft,
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Not a substitute for official registration — a live snapshot of real, '
                  "self-reported progress against this applicant's own document checklist.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11.5, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(child: _StartJourneyButton()),
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: const LinearGradient(
              colors: [AppColors.gold, AppColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.explore_outlined, size: 18, color: AppColors.backgroundDeep),
        ),
        const SizedBox(width: 10),
        const Text(
          'PathFinder AI',
          style: TextStyle(
            fontFamily: AppTheme.displayFontFamily,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _StartJourneyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => context.go('/sign-in'),
      icon: const Icon(Icons.arrow_forward, size: 16),
      label: const Text('Start your own journey', style: TextStyle(fontWeight: FontWeight.w600)),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.backgroundDeep,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
