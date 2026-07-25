import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/exam_prep.dart';
import '../data/occupation_registration_ledger.dart';
import '../services/app_sounds.dart';
import '../state/growth_state.dart';
import '../state/licensing_checklist_state.dart';
import '../state/pathway_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/confetti_burst.dart';
import '../widgets/elegant_progress_bar.dart';
import '../widgets/floating_card.dart';
import '../widgets/page_shell.dart';
import '../widgets/section_title.dart';

class ExamPrepScreen extends ConsumerWidget {
  const ExamPrepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathway = ref.watch(pathwayProvider);
    final englishTest = englishTestRequirements[pathway.targetCountry];
    final ledgerEntry = ledgerEntryFor(pathway.occupation, pathway.targetCountry);

    return PageShell(
      pageTitle: 'Exam & skill prep',
      builder: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to dashboard'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text('Exam & skill prep', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'What to study and which exams to sit for ${pathway.occupation} → '
            '${pathway.targetCountry}.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          const SectionTitle(
            label: 'English proficiency',
            subtitle: 'Accepted tests for your destination country — tap to open the IELTS prep guide',
            color: AppColors.gold,
          ),
          const SizedBox(height: 20),
          if (englishTest != null)
            _ExamCard(
              exam: englishTest,
              accentColor: AppColors.gold,
              onTap: () => _showIeltsGuide(context),
            )
          else
            FloatingCard(
              child: Text(
                'No English test data on file for ${pathway.targetCountry} yet.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          if (ledgerEntry != null) ...[
            const SizedBox(height: 32),
            SectionTitle(
              label: 'Professional registration & licensing',
              subtitle: ledgerEntry.applicable
                  ? 'What ${pathway.occupation} needs in ${pathway.targetCountry} — tap to open your prep checklist'
                  : 'Regulatory status for ${pathway.occupation} in ${pathway.targetCountry}',
              color: AppColors.amber,
            ),
            const SizedBox(height: 20),
            _LicensingCard(
              entry: ledgerEntry,
              onTap: ledgerEntry.applicable
                  ? () => _showLicensingDetail(
                        context,
                        occupation: pathway.occupation,
                        country: pathway.targetCountry,
                        entry: ledgerEntry,
                      )
                  : null,
            ),
          ],
          const SizedBox(height: 32),
          FloatingCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.textMuted, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Exam formats, accepted score combinations, and eligibility rules '
                    'change — always confirm current requirements directly with the test '
                    'provider or licensing body before booking.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                          height: 1.5,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showIeltsGuide(BuildContext context) {
  showDialog<void>(context: context, builder: (_) => const _IeltsGuideDialog());
}

void _showLicensingDetail(
  BuildContext context, {
  required String occupation,
  required String country,
  required LedgerEntry entry,
}) {
  showDialog<void>(
    context: context,
    builder: (_) => _LicensingDetailDialog(occupation: occupation, country: country, entry: entry),
  );
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam, required this.accentColor, this.onTap});

  final ExamInfo exam;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingCard(
      accentColor: accentColor,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: exam.acceptedTests
                      .map((test) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              test,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              if (onTap != null)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.chevron_right, color: AppColors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            exam.note,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                exam.verified ? Icons.verified_outlined : Icons.help_outline,
                size: 13,
                color: exam.verified ? AppColors.teal : AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  exam.verified
                      ? (exam.sourceNote ?? 'Checked against an official source')
                      : 'Not independently verified — confirm with the test/licensing '
                          'body directly',
                  style: TextStyle(
                    fontSize: 11,
                    color: exam.verified ? AppColors.teal : AppColors.textMuted,
                    fontStyle: exam.verified ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          if (onTap != null) ...[
            const SizedBox(height: 12),
            Text(
              'Tap for a comprehensive IELTS guide and where to prepare',
              style: TextStyle(color: accentColor, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class _LicensingCard extends StatelessWidget {
  const _LicensingCard({required this.entry, this.onTap});

  final LedgerEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = entry.applicable ? AppColors.amber : AppColors.textMuted;

    return FloatingCard(
      accentColor: entry.applicable ? accentColor : null,
      onTap: onTap,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(entry.body, style: Theme.of(context).textTheme.titleMedium),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: !entry.applicable
                                ? AppColors.hairline
                                : entry.mandatory
                                    ? AppColors.amberSoft
                                    : AppColors.tealSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            !entry.applicable ? 'NOT REGULATED' : (entry.mandatory ? 'REQUIRED' : 'VOLUNTARY'),
                            style: TextStyle(
                              color: !entry.applicable
                                  ? AppColors.textMuted
                                  : entry.mandatory
                                      ? AppColors.amber
                                      : AppColors.teal,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (entry.note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.note!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                const Padding(
                  padding: EdgeInsets.only(left: 8, top: 2),
                  child: Icon(Icons.chevron_right, color: AppColors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                entry.confidence == LedgerConfidence.verified ? Icons.verified_outlined : Icons.help_outline,
                size: 13,
                color: entry.confidence == LedgerConfidence.verified ? AppColors.teal : AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  entry.confidence == LedgerConfidence.verified
                      ? 'Checked against an official source'
                      : 'Not independently verified — confirm with the body directly',
                  style: TextStyle(
                    fontSize: 11,
                    color: entry.confidence == LedgerConfidence.verified ? AppColors.teal : AppColors.textMuted,
                    fontStyle: entry.confidence == LedgerConfidence.verified ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          if (onTap != null) ...[
            const SizedBox(height: 12),
            Text(
              'Tap to open your registration prep checklist',
              style: TextStyle(color: accentColor, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class _IeltsGuideDialog extends StatelessWidget {
  const _IeltsGuideDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceCardHover,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.hairlineStrong),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.menu_book_outlined, color: AppColors.gold, size: 20),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'IELTS preparation guide',
                      style: TextStyle(
                        fontFamily: AppTheme.displayFontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ieltsOverview,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.55),
                      ),
                      const SizedBox(height: 20),
                      for (final section in ieltsGuideSections) ...[
                        Text(
                          section.title,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...section.tips.map(
                          (tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 8, left: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Icon(Icons.circle, size: 4, color: AppColors.textMuted),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 6),
                      const Text(
                        'WHERE TO PREPARE',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...ieltsPrepResources.map((resource) => _PrepResourceRow(resource: resource)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrepResourceRow extends StatelessWidget {
  const _PrepResourceRow({required this.resource});

  final ExamPrepResource resource;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(resource.url), webOnlyWindowName: '_blank'),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.open_in_new, size: 14, color: AppColors.gold),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    resource.description,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LicensingDetailDialog extends ConsumerWidget {
  const _LicensingDetailDialog({required this.occupation, required this.country, required this.entry});

  final String occupation;
  final String country;
  final LedgerEntry entry;

  String get _cellKey => '$occupation|$country';

  void _toast(BuildContext context, String message) => AppSnackBar.show(context, message);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = entry.steps;
    final progress = ref.watch(licensingChecklistProgressProvider);
    final submittedAt = ref.watch(licensingChecklistSubmissionProvider)[_cellKey];
    final isSubmitted = submittedAt != null;

    final stepKeys = steps == null ? const <String>[] : List.generate(steps.length, (i) => '$_cellKey|$i');
    final checkedCount = stepKeys.where(progress.contains).length;
    final allChecked = steps != null && steps.isNotEmpty && checkedCount == steps.length;

    return Dialog(
      backgroundColor: AppColors.surfaceCardHover,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.hairlineStrong),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$occupation · $country',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, letterSpacing: 0.4),
              ),
              const SizedBox(height: 6),
              Text(
                entry.body,
                style: const TextStyle(
                  fontFamily: AppTheme.displayFontFamily,
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (entry.note != null) ...[
                const SizedBox(height: 8),
                Text(entry.note!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              ],
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (steps != null) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TO-DO TO REGISTER',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.amber),
                            ),
                            Text(
                              '$checkedCount of ${steps.length}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElegantProgressBar(value: steps.isEmpty ? 0 : checkedCount / steps.length, height: 5),
                        const SizedBox(height: 16),
                        for (var i = 0; i < steps.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ChecklistStepRow(
                              index: i,
                              label: steps[i],
                              checked: progress.contains(stepKeys[i]),
                              locked: isSubmitted,
                              onTap: () => ref.read(licensingChecklistProgressProvider.notifier).toggle(stepKeys[i]),
                            ),
                          ),
                      ] else ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Step-by-step requirements for this specific body haven\'t been researched '
                          'yet — check the official site below directly.',
                          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.5, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (steps != null) ...[
                const SizedBox(height: 16),
                if (isSubmitted)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.tealSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.teal, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => ref.read(licensingChecklistSubmissionProvider.notifier).unsubmit(_cellKey),
                            child: const Text(
                              'Submitted — edit checklist',
                              style: TextStyle(color: AppColors.teal, fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: allChecked
                          ? () {
                              ref.read(licensingChecklistSubmissionProvider.notifier).submit(_cellKey);
                              ref.read(growthProvider.notifier).recordAction();
                              AppSounds.celebrate();
                              ConfettiBurst.play(context);
                              _toast(context, 'Checklist submitted and saved');
                            }
                          : null,
                      icon: const Icon(Icons.send_outlined, size: 16),
                      label: Text(allChecked ? 'Submit checklist' : 'Check off all $checkedCount/${steps.length} steps to submit'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.backgroundDeep,
                        disabledBackgroundColor: AppColors.hairline,
                        disabledForegroundColor: AppColors.textMuted,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (entry.officialUrl != null)
                    TextButton.icon(
                      onPressed: () => launchUrl(Uri.parse(entry.officialUrl!), webOnlyWindowName: '_blank'),
                      icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.gold),
                      label: const Text('Open official site', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600)),
                    )
                  else
                    const SizedBox.shrink(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistStepRow extends StatelessWidget {
  const _ChecklistStepRow({
    required this.index,
    required this.label,
    required this.checked,
    required this.locked,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool checked;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: locked ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 1),
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? AppColors.amber : Colors.transparent,
                border: Border.all(color: checked ? AppColors.amber : AppColors.amber.withValues(alpha: 0.6)),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 13, color: AppColors.backgroundDeep)
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.amber),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: checked ? AppColors.textMuted : AppColors.textSecondary,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
