import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/document_requirements.dart';
import '../data/milestone_messages.dart';
import '../data/occupation_registration_ledger.dart';
import '../data/sample_dashboard_data.dart';
import '../services/app_sounds.dart';
import '../state/growth_state.dart';
import '../state/licensing_checklist_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_banner.dart';
import '../widgets/elegant_progress_bar.dart';
import '../widgets/page_shell.dart';
import '../widgets/section_title.dart';

const Map<OccupationCategory, IconData> _categoryIcons = {
  OccupationCategory.healthcare: Icons.medical_services_outlined,
  OccupationCategory.engineering: Icons.precision_manufacturing_outlined,
  OccupationCategory.trades: Icons.build_outlined,
  OccupationCategory.education: Icons.school_outlined,
  OccupationCategory.transport: Icons.flight_outlined,
};

const Map<String, String> _countryAbbreviations = {
  'Canada': 'CA',
  'Australia': 'AU',
  'New Zealand': 'NZ',
  'Germany': 'DE',
  'United Kingdom': 'UK',
  'Netherlands': 'NL',
  'Ireland': 'IE',
  'Singapore': 'SG',
  'United States': 'US',
  'United Arab Emirates': 'AE',
};

const Map<OccupationCategory, String> _categoryFootnotes = {
  OccupationCategory.healthcare:
      'Medical Laboratory Scientist and Paramedic diverge sharply from the rest of "Healthcare" — neither shares a body with doctors or nurses in several countries.',
  OccupationCategory.engineering:
      'Most countries treat "Engineer" as one protected title regardless of discipline. Singapore and Australia are the exceptions — both split by specific branch.',
  OccupationCategory.trades:
      'Aircraft Mechanic is regulated by the national aviation authority everywhere — the same body as Commercial Pilot — not by the generic trades body used for the rest of this list.',
  OccupationCategory.education:
      'Primary, Secondary, and Special Needs Teacher share one body per country. Early Childhood Teacher is the exception — a different regulator, credential type, or no personal registration at all in half of these countries.',
  OccupationCategory.transport:
      'One occupation, one aviation authority per country — already verified and consistent with the Aircraft Mechanic entries on the Trades page.',
};

/// Occupation-level registration/licensing reference, replacing the earlier
/// category-only assumption ("Healthcare" registers everyone with the same
/// body) with a real per-occupation answer. Reachable from the top nav via
/// a category picker or the search field below — this is a browsable
/// reference, not filtered to the applicant's own pathway.
class LicensingRegistryScreen extends StatefulWidget {
  const LicensingRegistryScreen({super.key, this.initialCategory});

  final OccupationCategory? initialCategory;

  @override
  State<LicensingRegistryScreen> createState() => _LicensingRegistryScreenState();
}

class _LicensingRegistryScreenState extends State<LicensingRegistryScreen> {
  late OccupationCategory _selected;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCategory ?? licensedOccupationCategories.first;
  }

  @override
  void didUpdateWidget(covariant LicensingRegistryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != null && widget.initialCategory != oldWidget.initialCategory) {
      _selected = widget.initialCategory!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRows = occupationRegistrationLedger[_selected] ?? const [];
    final query = _query.trim().toLowerCase();
    final rows = query.isEmpty
        ? allRows
        : allRows.where((r) => r.occupation.toLowerCase().contains(query)).toList();

    return PageShell(
      pageTitle: 'Licensing registry',
      builder: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            label: 'Licensing registry',
            subtitle: 'Which body you\'d actually register with — occupation by occupation, not just category by category',
            color: AppColors.teal,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in licensedOccupationCategories)
                _CategoryChip(
                  label: occupationCategoryLabels[category]!,
                  icon: _categoryIcons[category]!,
                  selected: category == _selected,
                  onTap: () => setState(() {
                    _selected = category;
                    _searchController.clear();
                    _query = '';
                  }),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _SearchField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 24),
          const _ConfidenceLegend(),
          const SizedBox(height: 10),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(Icons.checklist, size: 13, color: AppColors.teal),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Cells marked with this icon have a registration to-do list and an official link — tap to open',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (rows.isEmpty)
            const _EmptyState()
          else
            _LedgerTableCard(rows: rows),
          const SizedBox(height: 20),
          _FootnoteBox(text: _categoryFootnotes[_selected]!),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovering;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppColors.teal.withValues(alpha: 0.16)
                : (active ? AppColors.surfaceCardHover : AppColors.surfaceCard),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.selected ? AppColors.teal.withValues(alpha: 0.55) : AppColors.hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: widget.selected ? AppColors.teal : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.selected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
        decoration: InputDecoration(
          hintText: 'Search occupations in this category…',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.surfaceCard,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.hairline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.hairline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.teal),
          ),
        ),
      ),
    );
  }
}

class _ConfidenceLegend extends StatelessWidget {
  const _ConfidenceLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 8,
      children: const [
        _LegendItem(color: AppColors.teal, label: 'Verified against a primary source'),
        _LegendItem(color: AppColors.amber, label: 'Directional — not independently re-checked'),
        _LegendItem(color: AppColors.textMuted, label: 'Confirmed: not a regulated profession'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: const Text(
        'No occupations in this category match your search.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
      ),
    );
  }
}

class _LedgerTableCard extends StatelessWidget {
  const _LedgerTableCard({required this.rows});

  final List<OccupationLedgerRow> rows;

  static const double _occupationColWidth = 220;
  static const double _countryColWidth = 148;

  Color _confidenceColor(LedgerConfidence confidence) {
    switch (confidence) {
      case LedgerConfidence.verified:
        return AppColors.teal;
      case LedgerConfidence.directional:
        return AppColors.amber;
      case LedgerConfidence.notRegulated:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          border: Border.all(color: AppColors.hairlineStrong),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            columnWidths: {
              0: const FixedColumnWidth(_occupationColWidth),
              for (var i = 0; i < targetCountryOptions.length; i++)
                i + 1: const FixedColumnWidth(_countryColWidth),
            },
            border: const TableBorder(
              horizontalInside: BorderSide(color: AppColors.hairline),
              verticalInside: BorderSide(color: AppColors.hairline),
            ),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: AppColors.surfaceCardHover),
                children: [
                  const _HeaderCell('Occupation'),
                  for (final country in targetCountryOptions)
                    _HeaderCell(_countryAbbreviations[country] ?? country, tooltip: country),
                ],
              ),
              for (final row in rows)
                TableRow(
                  children: [
                    _OccupationCell(row.occupation),
                    for (final country in targetCountryOptions)
                      _EntryCell(
                        occupation: row.occupation,
                        country: country,
                        entry: row.byCountry[country],
                        stripeColor: row.byCountry[country] == null
                            ? AppColors.hairline
                            : _confidenceColor(row.byCountry[country]!.confidence),
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

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {this.tooltip});
  final String label;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.gold,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: tooltip != null ? Tooltip(message: tooltip!, child: text) : text,
    );
  }
}

class _OccupationCell extends StatelessWidget {
  const _OccupationCell(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTheme.displayFontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
          color: AppColors.textPrimary,
          height: 1.25,
        ),
      ),
    );
  }
}

class _EntryCell extends StatelessWidget {
  const _EntryCell({
    required this.occupation,
    required this.country,
    required this.entry,
    required this.stripeColor,
  });

  final String occupation;
  final String country;
  final LedgerEntry? entry;
  final Color stripeColor;

  @override
  Widget build(BuildContext context) {
    if (entry == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text('—', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
      );
    }
    final hasDetail = entry!.steps != null || entry!.officialUrl != null;
    final content = Container(
      padding: const EdgeInsets.only(left: 9, right: 10, top: 11, bottom: 12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: stripeColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entry!.body,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
              if (hasDetail) ...[
                const SizedBox(width: 4),
                const Icon(Icons.checklist, size: 13, color: AppColors.teal),
              ],
            ],
          ),
          if (entry!.note != null) ...[
            const SizedBox(height: 3),
            Text(
              entry!.note!,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, height: 1.3),
            ),
          ],
        ],
      ),
    );

    if (!hasDetail) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => _RegistrationDetailDialog(occupation: occupation, country: country, entry: entry!),
        ),
        child: content,
      ),
    );
  }
}

class _RegistrationDetailDialog extends ConsumerWidget {
  const _RegistrationDetailDialog({required this.occupation, required this.country, required this.entry});

  final String occupation;
  final String country;
  final LedgerEntry entry;

  String get _cellKey => '$occupation|$country';

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
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.teal),
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
                          'Step-by-step requirements for this specific body haven\'t been researched yet — check the official site below directly.',
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
                  _SubmittedRow(
                    submittedAt: submittedAt,
                    onEdit: () => ref.read(licensingChecklistSubmissionProvider.notifier).unsubmit(_cellKey),
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
                              showAppBanner(context, message: randomMilestoneMessage());
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
                color: checked ? AppColors.teal : Colors.transparent,
                border: Border.all(color: checked ? AppColors.teal : AppColors.teal.withValues(alpha: 0.6)),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 13, color: AppColors.backgroundDeep)
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.teal),
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

class _SubmittedRow extends StatelessWidget {
  const _SubmittedRow({required this.submittedAt, required this.onEdit});

  final DateTime submittedAt;
  final VoidCallback onEdit;

  String get _formatted {
    final d = submittedAt;
    final date = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final time = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$date at $time';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Submitted on $_formatted', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onEdit,
                  child: const Text(
                    'Edit checklist',
                    style: TextStyle(color: AppColors.teal, fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
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

class _FootnoteBox extends StatelessWidget {
  const _FootnoteBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tealSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
