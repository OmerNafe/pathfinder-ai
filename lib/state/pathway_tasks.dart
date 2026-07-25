import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/document_requirements.dart';
import '../data/sample_dashboard_data.dart' show TaskStatus;
import 'document_upload_state.dart';
import 'pathway_state.dart';

/// One real, per-applicant task — generated from the actual document
/// requirements for their chosen occupation/country, with status reflecting
/// their actual upload/review state. Replaces the old hardcoded
/// sampleTasks, which showed identical canned progress (one task already
/// verified, one already rejected) to every applicant regardless of what
/// they'd actually done.
class PathwayTask {
  const PathwayTask({
    required this.step,
    required this.requirementId,
    required this.title,
    required this.description,
    required this.status,
    this.statusNote,
  });

  final int step;
  final String requirementId;
  final String title;
  final String description;
  final TaskStatus status;
  final String? statusNote;
}

/// The real, ordered document-requirement list for a pathway — core, then
/// destination-specific, then occupation-specific. Same composition
/// document_upload_screen.dart already uses, so the two screens always
/// agree on what's actually required.
List<DocumentRequirement> requirementsFor(String occupation, String targetCountry) {
  final category = occupationCategoryFor(occupation);
  return [
    ...coreDocuments,
    ...(countryDocumentRequirements[targetCountry] ?? const []),
    ...(occupationCategoryDocumentRequirements[category] ?? const []),
  ];
}

final pathwayTasksProvider = Provider<List<PathwayTask>>((ref) {
  final pathway = ref.watch(pathwayProvider);
  final uploads = ref.watch(documentUploadProvider);
  final requirements = requirementsFor(pathway.occupation, pathway.targetCountry);

  return [
    for (var i = 0; i < requirements.length; i++)
      _toTask(step: i + 1, requirement: requirements[i], uploaded: uploads[requirements[i].id]),
  ];
});

PathwayTask _toTask({
  required int step,
  required DocumentRequirement requirement,
  required UploadedDocument? uploaded,
}) {
  if (uploaded == null) {
    return PathwayTask(
      step: step,
      requirementId: requirement.id,
      title: requirement.title,
      description: requirement.description,
      status: TaskStatus.pending,
      statusNote: 'Not uploaded yet',
    );
  }

  switch (uploaded.reviewStatus) {
    case DocumentReviewStatus.pending:
    case DocumentReviewStatus.reviewing:
      return PathwayTask(
        step: step,
        requirementId: requirement.id,
        title: requirement.title,
        description: requirement.description,
        status: TaskStatus.pending,
        statusNote: '${uploaded.fileName} — reviewing…',
      );
    case DocumentReviewStatus.failed:
      return PathwayTask(
        step: step,
        requirementId: requirement.id,
        title: requirement.title,
        description: requirement.description,
        status: TaskStatus.rejected,
        statusNote: uploaded.reviewError ?? 'Review failed — try re-uploading.',
      );
    case DocumentReviewStatus.reviewed:
      final extracted = uploaded.reviewResult?['extracted'];
      final legible = extracted is Map ? (extracted['legible'] as bool? ?? true) : true;
      if (!legible) {
        final issue = uploaded.reviewResult?['mismatchReason'] as String?;
        return PathwayTask(
          step: step,
          requirementId: requirement.id,
          title: requirement.title,
          description: requirement.description,
          status: TaskStatus.rejected,
          statusNote: issue ?? 'Document could not be read — try re-uploading.',
        );
      }
      return PathwayTask(
        step: step,
        requirementId: requirement.id,
        title: requirement.title,
        description: requirement.description,
        status: TaskStatus.verified,
        statusNote: '${uploaded.fileName} · ${uploaded.formattedSize}',
      );
  }
}
