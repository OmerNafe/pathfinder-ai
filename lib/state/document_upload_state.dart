import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DocumentReviewStatus { pending, reviewing, reviewed, failed }

class UploadedDocument {
  const UploadedDocument({
    required this.fileName,
    required this.sizeBytes,
    this.documentId,
    this.reviewStatus = DocumentReviewStatus.pending,
    this.reviewResult,
    this.reviewError,
  });

  final String fileName;
  final int sizeBytes;

  /// Supabase `documents.id` — null until the upload actually reaches the
  /// backend (i.e. still null in local-only mode, see DocumentReviewService).
  final String? documentId;
  final DocumentReviewStatus reviewStatus;
  final Map<String, dynamic>? reviewResult;
  final String? reviewError;

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    final kb = sizeBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  UploadedDocument copyWith({
    String? documentId,
    DocumentReviewStatus? reviewStatus,
    Map<String, dynamic>? reviewResult,
    String? reviewError,
  }) {
    return UploadedDocument(
      fileName: fileName,
      sizeBytes: sizeBytes,
      documentId: documentId ?? this.documentId,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewResult: reviewResult ?? this.reviewResult,
      reviewError: reviewError ?? this.reviewError,
    );
  }
}

/// Keyed by [DocumentRequirement.id] so core, country-specific, and
/// occupation-specific requirements can all share one upload-status map.
class DocumentUploadNotifier extends Notifier<Map<String, UploadedDocument?>> {
  @override
  Map<String, UploadedDocument?> build() => {};

  void setUploaded(String requirementId, UploadedDocument document) {
    state = {...state, requirementId: document};
  }

  void clear(String requirementId) {
    state = {...state, requirementId: null};
  }

  void updateReview(
    String requirementId, {
    String? documentId,
    DocumentReviewStatus? status,
    Map<String, dynamic>? result,
    String? error,
  }) {
    final current = state[requirementId];
    if (current == null) return;
    state = {
      ...state,
      requirementId: current.copyWith(
        documentId: documentId,
        reviewStatus: status,
        reviewResult: result,
        reviewError: error,
      ),
    };
  }
}

final documentUploadProvider =
    NotifierProvider<DocumentUploadNotifier, Map<String, UploadedDocument?>>(
  DocumentUploadNotifier.new,
);

/// Null while the applicant hasn't submitted their checklist yet; holds the
/// submission timestamp once they have. This is a session-local "saved and
/// queued" marker — there's no backend yet, so nothing actually leaves the
/// browser. See DocumentUploadScreen for the honesty note shown to the user.
class DocumentSubmissionNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void submit() => state = DateTime.now();

  void unsubmit() => state = null;
}

final documentSubmissionProvider =
    NotifierProvider<DocumentSubmissionNotifier, DateTime?>(DocumentSubmissionNotifier.new);
