import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/sample_dashboard_data.dart';
import '../state/pathway_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/autocomplete_text_field.dart';
import '../widgets/floating_card.dart';
import '../widgets/page_shell.dart';
import '../widgets/stage_rail.dart';

class PathwayEditScreen extends ConsumerStatefulWidget {
  const PathwayEditScreen({super.key});

  @override
  ConsumerState<PathwayEditScreen> createState() => _PathwayEditScreenState();
}

class _PathwayEditScreenState extends ConsumerState<PathwayEditScreen> {
  late final _occupationController =
      TextEditingController(text: ref.read(pathwayProvider).occupation)
        ..addListener(() => setState(() {}));
  late final _targetCountryController =
      TextEditingController(text: ref.read(pathwayProvider).targetCountry)
        ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _occupationController.dispose();
    _targetCountryController.dispose();
    super.dispose();
  }

  void _confirm() {
    final occupation = _occupationController.text.trim();
    final targetCountry = _targetCountryController.text.trim();

    if (!occupationOptions.contains(occupation) ||
        !targetCountryOptions.contains(targetCountry)) {
      AppSnackBar.show(context, 'Please pick an occupation and country from the suggested list.');
      return;
    }

    ref.read(pathwayProvider.notifier).updatePathway(
          occupation: occupation,
          targetCountry: targetCountry,
        );

    AppSnackBar.show(context, 'Pathway set: $occupation → $targetCountry');
    context.go('/documents');
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(pathwayProvider);
    final isFirstTimeSetup = !current.hasCompletedSetup;
    final hasChanged = _occupationController.text != current.occupation ||
        _targetCountryController.text != current.targetCountry;
    final canConfirm = isFirstTimeSetup || hasChanged;

    return PageShell(
      pageTitle: 'Edit pathway',
      builder: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageRail(items: buildStageRailItems('/pathway/edit')),
          const SizedBox(height: 28),
          Text(
            isFirstTimeSetup ? 'Set up your pathway' : 'Update your pathway',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isFirstTimeSetup
                ? 'Tell us your target occupation and destination country so we can identify '
                    'your eligibility gaps and build your document checklist.'
                : 'Change your target occupation or destination country. This restarts your '
                    'eligibility verification from scratch.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          FloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutocompleteTextField(
                  label: 'Occupation',
                  controller: _occupationController,
                  options: occupationOptions,
                ),
                const SizedBox(height: 16),
                AutocompleteTextField(
                  label: 'Target country',
                  controller: _targetCountryController,
                  options: targetCountryOptions,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isFirstTimeSetup ? AppColors.tealSoft : AppColors.amberSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isFirstTimeSetup ? AppColors.teal : AppColors.amber)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isFirstTimeSetup ? Icons.info_outline : Icons.warning_amber_rounded,
                        color: isFirstTimeSetup ? AppColors.teal : AppColors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isFirstTimeSetup
                              ? "Next, you'll upload the core documents required for every "
                                  'pathway — after that, we tailor the checklist to your specific '
                                  'occupation and country.'
                              : 'Changing your pathway restarts your eligibility verification — '
                                  'your progress, gaps, and task timeline will be recalculated '
                                  'from scratch.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.go('/'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: !canConfirm ? null : _confirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.backgroundDeep,
                        disabledBackgroundColor: AppColors.hairline,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        isFirstTimeSetup ? 'Confirm' : 'Confirm & restart verification',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
