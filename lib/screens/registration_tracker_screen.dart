import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/document_requirements.dart';
import '../data/registration_bodies.dart';
import '../state/pathway_state.dart';
import '../state/registration_progress_state.dart';
import '../theme/app_colors.dart';
import '../widgets/elegant_progress_bar.dart';
import '../widgets/floating_card.dart';
import '../widgets/page_shell.dart';

class RegistrationTrackerScreen extends ConsumerWidget {
  const RegistrationTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathway = ref.watch(pathwayProvider);
    final category = occupationCategoryFor(pathway.occupation);
    final requirement = registrationRequirementForOccupation(pathway.occupation, pathway.targetCountry, category);

    return PageShell(
      pageTitle: 'Registration',
      builder: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => context.go('/documents'),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to documents'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (requirement == null || !requirement.applicable)
            _NotApplicableCard(pathway: pathway, requirement: requirement)
          else
            _RegistrationFlow(pathway: pathway, requirement: requirement, category: category),
        ],
      ),
    );
  }
}

class _NotApplicableCard extends StatelessWidget {
  const _NotApplicableCard({required this.pathway, required this.requirement});

  final PathwayData pathway;
  final RegistrationRequirement? requirement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('No dedicated registration body', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          '${pathway.occupation} in ${pathway.targetCountry}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        FloatingCard(
          child: Text(
            requirement?.description ??
                "We don't have a specific regulatory registering body on file for this "
                    'occupation and country combination.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }
}

class _RegistrationFlow extends ConsumerWidget {
  const _RegistrationFlow({
    required this.pathway,
    required this.requirement,
    required this.category,
  });

  final PathwayData pathway;
  final RegistrationRequirement requirement;
  final OccupationCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = requirement.steps ?? registrationStepLabels(requirement.bodyName);
    final progress = ref.watch(registrationProgressProvider);
    final stepKeys = List.generate(
      steps.length,
      (i) => '${pathway.targetCountry}|${pathway.occupation}|$i',
    );
    final completedCount = stepKeys.where(progress.contains).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(requirement.bodyName, style: Theme.of(context).textTheme.headlineMedium),
                  if (requirement.bodyFullName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(requirement.bodyFullName, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: requirement.mandatory ? AppColors.amberSoft : AppColors.tealSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                requirement.mandatory ? 'REQUIRED' : 'OPTIONAL',
                style: TextStyle(
                  color: requirement.mandatory ? AppColors.amber : AppColors.teal,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: requirement.verified ? AppColors.tealSoft : AppColors.amberSoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (requirement.verified ? AppColors.teal : AppColors.amber)
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                requirement.verified ? Icons.verified_outlined : Icons.warning_amber_rounded,
                size: 16,
                color: requirement.verified ? AppColors.teal : AppColors.amber,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  requirement.verified
                      ? (requirement.sourceNote ?? 'Checked against an official source.')
                      : 'Not independently verified against an official source in this '
                          'pass — treat as directional and confirm with the body directly.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          requirement.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              '$completedCount of ${steps.length} steps complete',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElegantProgressBar(value: completedCount / steps.length),
        const SizedBox(height: 32),
        ...List.generate(steps.length, (i) {
          final key = stepKeys[i];
          final done = progress.contains(key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FloatingCard(
              accentColor: done ? AppColors.teal : null,
              onTap: () => ref.read(registrationProgressProvider.notifier).toggle(key),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: done ? AppColors.teal : AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: done ? AppColors.textMuted : AppColors.textPrimary,
                            decoration: done ? TextDecoration.lineThrough : null,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        FloatingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      requirement.steps != null
                          ? 'Exact requirements, fees, and processing times can still change — '
                              'confirm specifics directly on ${requirement.bodyName}\'s official website.'
                          : 'These are general steps common to most registration processes — exact '
                              'requirements, fees, and processing times vary by body. Confirm specifics '
                              'directly on ${requirement.bodyName}\'s official website.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                    ),
                  ),
                ],
              ),
              if (requirement.officialUrl != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => launchUrl(Uri.parse(requirement.officialUrl!), webOnlyWindowName: '_blank'),
                  icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.gold),
                  label: const Text(
                    'Open official site',
                    style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
