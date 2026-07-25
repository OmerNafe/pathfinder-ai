import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/document_requirements.dart';
import '../data/registration_bodies.dart';
import '../services/app_sounds.dart';
import '../services/document_review_service.dart';
import '../state/document_upload_state.dart';
import '../state/growth_state.dart';
import '../state/pathway_state.dart';
import '../theme/app_colors.dart';
import '../utils/file_upload_validation.dart';
import '../widgets/ai_processing_consent_dialog.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/confetti_burst.dart';
import '../widgets/elegant_progress_bar.dart';
import '../widgets/floating_card.dart';
import '../widgets/ghost_button.dart';
import '../widgets/page_shell.dart';
import '../widgets/section_title.dart';
import '../widgets/status_pill.dart';

class DocumentUploadScreen extends ConsumerWidget {
  const DocumentUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(documentUploadProvider);
    final submittedAt = ref.watch(documentSubmissionProvider);
    final pathway = ref.watch(pathwayProvider);
    final category = occupationCategoryFor(pathway.occupation);
    final isSubmitted = submittedAt != null;

    final countryRequirements = countryDocumentRequirements[pathway.targetCountry] ?? [];
    final occupationRequirements = occupationCategoryDocumentRequirements[category] ?? [];
    final allRequirements = [...coreDocuments, ...countryRequirements, ...occupationRequirements];
    final registration = registrationRequirementForOccupation(pathway.occupation, pathway.targetCountry, category);

    final uploadedCount = allRequirements.where((r) => documents[r.id] != null).length;
    final total = allRequirements.length;
    final allUploaded = total > 0 && uploadedCount == total;

    return PageShell(
      pageTitle: 'Upload documents',
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
          Text('Document checklist', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Tailored to ${pathway.occupation} → ${pathway.targetCountry}: the universal '
            'baseline, plus what this destination and this profession specifically ask for.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                '$uploadedCount of $total uploaded',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElegantProgressBar(value: total == 0 ? 0 : uploadedCount / total),
          const SizedBox(height: 40),
          const SectionTitle(
            label: 'Core documents',
            subtitle: 'Required for every pathway, regardless of destination or occupation',
            color: AppColors.gold,
          ),
          const SizedBox(height: 20),
          ...coreDocuments.map((r) => Padding(
                key: ValueKey(r.id),
                padding: const EdgeInsets.only(bottom: 16),
                child: _DocumentUploadCard(
                  requirement: r,
                  uploaded: documents[r.id],
                  isLocked: isSubmitted,
                ),
              )),
          if (countryRequirements.isNotEmpty) ...[
            const SizedBox(height: 32),
            SectionTitle(
              label: 'Required for ${pathway.targetCountry}',
              subtitle: 'General visa/immigration requirements for this destination',
              color: AppColors.teal,
            ),
            const SizedBox(height: 20),
            ...countryRequirements.map((r) => Padding(
                  key: ValueKey(r.id),
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _DocumentUploadCard(
                    requirement: r,
                    uploaded: documents[r.id],
                    isLocked: isSubmitted,
                  ),
                )),
          ],
          if (occupationRequirements.isNotEmpty) ...[
            const SizedBox(height: 32),
            SectionTitle(
              label: 'Required for ${pathway.occupation}',
              subtitle: 'Professional assessment & registration paperwork for this occupation',
              color: AppColors.amber,
            ),
            const SizedBox(height: 20),
            ...occupationRequirements.map((r) => Padding(
                  key: ValueKey(r.id),
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _DocumentUploadCard(
                    requirement: r,
                    uploaded: documents[r.id],
                    isLocked: isSubmitted,
                  ),
                )),
          ],
          if (registration != null) ...[
            const SizedBox(height: 32),
            const SectionTitle(
              label: 'Regulatory body registration',
              subtitle: 'Registering with the licensing/assessing body for this profession',
              color: AppColors.teal,
            ),
            const SizedBox(height: 20),
            _RegistrationCard(registration: registration),
          ],
          const SizedBox(height: 32),
          if (isSubmitted)
            _SubmittedCard(submittedAt: submittedAt)
          else
            _SubmitSection(allUploaded: allUploaded, uploadedCount: uploadedCount, total: total),
          const SizedBox(height: 24),
          FloatingCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.textMuted, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This checklist is a directional synthesis of public guidance, not a live '
                    'regulatory feed — always confirm current requirements with the relevant '
                    'government agency or licensing body before relying on it for an actual '
                    'application.',
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

class _SubmitSection extends ConsumerWidget {
  const _SubmitSection({
    required this.allUploaded,
    required this.uploadedCount,
    required this.total,
  });

  final bool allUploaded;
  final int uploadedCount;
  final int total;

  void _submit(BuildContext context, WidgetRef ref) {
    ref.read(documentSubmissionProvider.notifier).submit();
    ref.read(growthProvider.notifier).recordAction();
    AppSounds.celebrate();
    ConfettiBurst.play(context);
    AppSnackBar.show(context, 'Documents submitted and saved');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingCard(
      accentColor: allUploaded ? AppColors.teal : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Submit for analysis', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            allUploaded
                ? 'All $total documents are uploaded. Submitting saves your checklist so it\'s '
                    'ready for analysis.'
                : 'Upload all $total documents ($uploadedCount done so far) to submit your '
                    'checklist.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: allUploaded ? () => _submit(context, ref) : null,
              icon: const Icon(Icons.send_outlined, size: 18),
              label: const Text('Submit for analysis'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.backgroundDeep,
                disabledBackgroundColor: AppColors.hairline,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmittedCard extends ConsumerWidget {
  const _SubmittedCard({required this.submittedAt});

  final DateTime submittedAt;

  String get _formatted {
    final d = submittedAt;
    final date = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final time = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$date at $time';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingCard(
      accentColor: AppColors.teal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.teal, size: 20),
              const SizedBox(width: 10),
              Text('Submitted for analysis', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Saved on $_formatted. Your checklist is complete and locked in for this pathway.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.amberSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.amber, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Submitting locks this checklist for your pathway. Each document was already "
                    "reviewed by AI as you uploaded it — see the status on each item above, not here.",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GhostButton(
            label: 'Edit documents',
            color: AppColors.teal,
            onPressed: () => ref.read(documentSubmissionProvider.notifier).unsubmit(),
          ),
        ],
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({required this.registration});

  final RegistrationRequirement registration;

  @override
  Widget build(BuildContext context) {
    if (!registration.applicable) {
      return FloatingCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                registration.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      );
    }

    return FloatingCard(
      accentColor: AppColors.teal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.tealSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_outlined, color: AppColors.teal, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(registration.bodyName, style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: registration.mandatory ? AppColors.amberSoft : AppColors.hairline,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        registration.mandatory ? 'REQUIRED' : 'OPTIONAL',
                        style: TextStyle(
                          color: registration.mandatory ? AppColors.amber : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                if (registration.bodyFullName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    registration.bodyFullName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      registration.verified ? Icons.verified_outlined : Icons.help_outline,
                      size: 13,
                      color: registration.verified ? AppColors.teal : AppColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        registration.verified
                            ? 'Checked against an official source'
                            : 'Not independently verified — confirm with the body directly',
                        style: TextStyle(
                          fontSize: 11,
                          color: registration.verified ? AppColors.teal : AppColors.textMuted,
                          fontStyle: registration.verified ? FontStyle.normal : FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  registration.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5, height: 1.5),
                ),
                const SizedBox(height: 14),
                GhostButton(
                  label: 'View registration steps',
                  color: AppColors.teal,
                  onPressed: () => context.go('/registration'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentUploadCard extends ConsumerWidget {
  const _DocumentUploadCard({
    required this.requirement,
    required this.uploaded,
    required this.isLocked,
  });

  final DocumentRequirement requirement;
  final UploadedDocument? uploaded;
  final bool isLocked;

  void _toast(BuildContext context, String message) => AppSnackBar.show(context, message);

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(type: FileType.any, withData: true);
    } catch (e) {
      debugPrint('Document upload: file picker threw: $e');
      if (!context.mounted) return;
      _toast(context, 'Upload failed: $e');
      return;
    }

    if (result == null || result.files.isEmpty) {
      // User closed the dialog without choosing a file — not an error.
      return;
    }

    final file = result.files.first;
    final validationError = validateDocumentFile(fileName: file.name, sizeBytes: file.size);
    if (validationError != null) {
      if (!context.mounted) return;
      _toast(context, validationError);
      return;
    }

    if (!context.mounted) return;
    final consented = await ensureAiProcessingConsent(context);
    if (!consented) {
      if (!context.mounted) return;
      _toast(context, 'Upload cancelled — AI review requires agreeing to how your document is processed.');
      return;
    }
    if (!context.mounted) return;

    final notifier = ref.read(documentUploadProvider.notifier);
    notifier.setUploaded(
      requirement.id,
      UploadedDocument(fileName: file.name, sizeBytes: file.size),
    );

    final bytes = file.bytes;
    if (bytes == null) {
      if (!context.mounted) return;
      _toast(context, '${file.name} uploaded');
      return;
    }

    notifier.updateReview(requirement.id, status: DocumentReviewStatus.reviewing);
    if (!context.mounted) return;
    _toast(context, '${file.name} uploaded — reviewing…');

    final uploadResult = await DocumentReviewService.uploadAndReview(
      requirementId: requirement.id,
      fileName: file.name,
      bytes: bytes,
    );

    if (!context.mounted) return;

    if (uploadResult.isLocalOnly) {
      // Backend not configured yet — same local-only behavior this screen
      // always had, no error surfaced for something that isn't wired up.
      return;
    }

    if (uploadResult.error != null) {
      notifier.updateReview(
        requirement.id,
        storagePath: uploadResult.storagePath,
        status: DocumentReviewStatus.failed,
        error: uploadResult.error,
      );
      _toast(context, uploadResult.error!);
      return;
    }

    notifier.updateReview(
      requirement.id,
      documentId: uploadResult.documentId,
      storagePath: uploadResult.storagePath,
      status: DocumentReviewStatus.reviewed,
      result: uploadResult.reviewResult,
    );
  }

  Future<void> _removeFile(BuildContext context, WidgetRef ref) async {
    await ref.read(documentUploadProvider.notifier).removeDocument(requirement.id);
    if (!context.mounted) return;
    _toast(context, 'Document removed');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUploaded = uploaded != null;

    return FloatingCard(
      accentColor: isUploaded ? AppColors.teal : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_file_outlined,
            color: isUploaded ? AppColors.teal : AppColors.textMuted,
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(requirement.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  requirement.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 10),
                if (isUploaded)
                  Text(
                    '${uploaded!.fileName} · ${uploaded!.formattedSize}',
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    'Recommended formats: PDF, PNG, JPEG',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                  ),
                if (isUploaded && uploaded!.reviewStatus != DocumentReviewStatus.pending) ...[
                  const SizedBox(height: 8),
                  _AiReviewNote(document: uploaded!),
                ],
                const SizedBox(height: 12),
                if (isLocked)
                  Row(
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Locked — submitted',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      GhostButton(
                        label: isUploaded ? 'Replace file' : 'Upload file',
                        color: isUploaded ? AppColors.teal : AppColors.gold,
                        onPressed: () => _pickFile(context, ref),
                      ),
                      if (isUploaded) ...[
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () => _removeFile(context, ref),
                          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                          child: const Text('Remove', style: TextStyle(fontSize: 13)),
                        ),
                      ],
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

/// Shows the real analyze-document Edge Function result once it comes
/// back — this replaces the old "documents saved" fiction with actual
/// feedback (or an honest failure/in-progress state), per the document
/// upload screen's own disclaimer about what used to not be connected.
class _AiReviewNote extends StatelessWidget {
  const _AiReviewNote({required this.document});

  final UploadedDocument document;

  @override
  Widget build(BuildContext context) {
    switch (document.reviewStatus) {
      case DocumentReviewStatus.pending:
        return const SizedBox.shrink();

      case DocumentReviewStatus.reviewing:
        return const Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.amber),
            ),
            SizedBox(width: 8),
            Text('AI reviewing…', style: TextStyle(color: AppColors.amber, fontSize: 12)),
          ],
        );

      case DocumentReviewStatus.failed:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusPill(label: 'Review failed', color: AppColors.danger),
            if (document.reviewError != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  document.reviewError!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 11.5, height: 1.4),
                ),
              ),
            ],
          ],
        );

      case DocumentReviewStatus.reviewed:
        final result = document.reviewResult;
        final extracted = result?['extracted'] as Map<String, dynamic>?;
        final legible = extracted?['legible'] as bool? ?? true;

        if (!legible) {
          final issue = result?['mismatchReason'] as String? ?? 'Document is not legible.';
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StatusPill(
                label: 'Needs attention',
                color: AppColors.danger,
                icon: Icons.warning_amber_rounded,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(issue, style: const TextStyle(color: AppColors.danger, fontSize: 11.5, height: 1.4)),
              ),
            ],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusPill(label: 'AI reviewed', color: AppColors.teal, icon: Icons.check),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Looks legible — full requirement match check is next.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11.5, height: 1.4),
              ),
            ),
          ],
        );
    }
  }
}
