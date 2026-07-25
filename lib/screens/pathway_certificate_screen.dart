import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/sample_dashboard_data.dart';
import '../services/certificate_share_service.dart';
import '../state/pathway_state.dart';
import '../state/pathway_tasks.dart';
import '../theme/app_colors.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/eta_estimate_card.dart';
import '../widgets/floating_card.dart';
import '../widgets/page_shell.dart';
import '../widgets/setup_required_card.dart';
import '../widgets/status_pill.dart';

/// A shareable, verifiable rollup of the applicant's progress — turns the
/// dashboard's internal verified/directional trust signal into something
/// they can actually hand to a recruiter or institution, not just view.
/// Built directly from [pathwayTasksProvider], so it reflects this specific
/// applicant's real document uploads and AI review results — nothing here
/// is pre-filled or illustrative.
class PathwayCertificateScreen extends ConsumerWidget {
  const PathwayCertificateScreen({super.key});

  void _showSnack(BuildContext context, String message) => AppSnackBar.show(context, message);

  Future<void> _copyShareLink(
    BuildContext context,
    PathwayData pathway,
    List<PathwayTask> requirements,
  ) async {
    try {
      final url = await CertificateShareService.publish(pathway: pathway, requirements: requirements);
      await Clipboard.setData(ClipboardData(text: url));
      if (!context.mounted) return;
      _showSnack(context, 'Link copied: $url');
    } on CertificateShareException catch (e) {
      if (!context.mounted) return;
      _showSnack(context, e.message);
    }
  }

  Future<void> _downloadPdf(
    BuildContext context,
    PathwayData pathway,
    List<PathwayTask> requirements,
  ) async {
    final verifiedCount = requirements.where((r) => r.status == TaskStatus.verified).length;
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('PathFinder AI', style: pw.TextStyle(fontSize: 12, color: PdfColor.fromHex('#C9A227'))),
            pw.SizedBox(height: 12),
            pw.Text('Pathway Certificate', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('${pathway.occupation} -> ${pathway.targetCountry}', style: const pw.TextStyle(fontSize: 13)),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generated ${DateTime.now().toLocal().toString().split(' ').first}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              '$verifiedCount of ${requirements.length} requirements verified',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            for (final req in requirements)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(child: pw.Text(req.title, style: const pw.TextStyle(fontSize: 11))),
                    pw.Text(
                      switch (req.status) {
                        TaskStatus.verified => 'VERIFIED',
                        TaskStatus.rejected => 'NEEDS ATTENTION',
                        TaskStatus.pending => 'PENDING',
                      },
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: switch (req.status) {
                          TaskStatus.verified => PdfColor.fromHex('#0D9488'),
                          TaskStatus.rejected => PdfColor.fromHex('#B3453A'),
                          TaskStatus.pending => PdfColor.fromHex('#D97706'),
                        },
                      ),
                    ),
                  ],
                ),
              ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Not a substitute for official registration, or the guidance of a licensed '
              'migration agent or immigration lawyer — a snapshot of real, self-reported '
              'progress against this applicant\'s own document checklist.',
              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'pathfinder-certificate.pdf',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathway = ref.watch(pathwayProvider);
    final requirements = ref.watch(pathwayTasksProvider);
    final verifiedCount = requirements.where((r) => r.status == TaskStatus.verified).length;
    final pendingCount = requirements.where((r) => r.status == TaskStatus.pending).length;
    final ratio = requirements.isEmpty ? 0.0 : verifiedCount / requirements.length;

    return PageShell(
      pageTitle: 'Pathway certificate',
      builder: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to dashboard'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          if (!pathway.hasCompletedSetup)
            const SetupRequiredCard(
              title: 'No certificate yet',
              message: 'Your Pathway Certificate is generated from your real, verified progress — '
                  'set up your pathway first so there\'s something genuine to certify.',
              buttonLabel: 'Set up your pathway',
            )
          else
            FloatingCard(
              accentColor: AppColors.gold,
              padding: EdgeInsets.all(isMobile ? 22 : 36),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pathway Certificate', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Text(
                            '${pathway.occupation} → ${pathway.targetCountry}. A live, shareable summary — '
                            'not a substitute for official registration, but proof of where things genuinely stand.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'PathFinder AI',
                      style: TextStyle(
                        fontFamily: Theme.of(context).textTheme.headlineSmall?.fontFamily,
                        color: AppColors.gold.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: 128,
                    height: 128,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 128,
                          height: 128,
                          child: CircularProgressIndicator(
                            value: ratio,
                            strokeWidth: 9,
                            backgroundColor: AppColors.hairlineStrong,
                            valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$verifiedCount/${requirements.length}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'VERIFIED',
                              style: TextStyle(fontSize: 10, letterSpacing: 0.6, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  requirements.isEmpty
                      ? 'No document requirements found for this pathway yet.'
                      : '$verifiedCount of ${requirements.length} requirements are confirmed so far.'
                          '${pendingCount > 0 ? ' $pendingCount still need${pendingCount == 1 ? 's' : ''} to be uploaded.' : ''}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                EtaEstimateCard(targetCountry: pathway.targetCountry),
                const SizedBox(height: 28),
                for (final req in requirements)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.hairline),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _reqColor(req.status).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              switch (req.status) {
                                TaskStatus.verified => Icons.check,
                                TaskStatus.rejected => Icons.priority_high_rounded,
                                TaskStatus.pending => Icons.more_horiz,
                              },
                              size: 17,
                              color: _reqColor(req.status),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(req.title, style: Theme.of(context).textTheme.titleMedium),
                                    ),
                                    StatusPill(
                                      label: switch (req.status) {
                                        TaskStatus.verified => 'Verified',
                                        TaskStatus.rejected => 'Needs attention',
                                        TaskStatus.pending => 'Pending',
                                      },
                                      color: _reqColor(req.status),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  req.description,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                                ),
                                if (req.statusNote != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    req.statusNote!,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.tealSoft,
                    border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5, height: 1.55),
                      children: const [
                        TextSpan(
                          text: 'What "verified" means here.  ',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: 'Checked against the regulator\'s or portal\'s own source this cycle, dated. '
                              '"In progress" items are directional until confirmed — this certificate updates '
                              'automatically as that changes, so it\'s never stale.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: isMobile ? double.infinity : 220,
                      child: FilledButton(
                        onPressed: () => _copyShareLink(context, pathway, requirements),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.backgroundDeep,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Copy share link', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    SizedBox(
                      width: isMobile ? double.infinity : 220,
                      child: OutlinedButton(
                        onPressed: () => _downloadPdf(context, pathway, requirements),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.hairlineStrong),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Download as PDF', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'The share link is public — anyone with it can view this snapshot, no account needed.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _reqColor(TaskStatus status) => switch (status) {
        TaskStatus.verified => AppColors.teal,
        TaskStatus.rejected => AppColors.danger,
        TaskStatus.pending => AppColors.amber,
      };
}
