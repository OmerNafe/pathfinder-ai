import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

enum DocumentReviewStatus { pending, reviewing, reviewed, failed }

DocumentReviewStatus _statusFromString(String value) => switch (value) {
      'reviewing' => DocumentReviewStatus.reviewing,
      'reviewed' => DocumentReviewStatus.reviewed,
      'failed' => DocumentReviewStatus.failed,
      _ => DocumentReviewStatus.pending,
    };

class UploadedDocument {
  const UploadedDocument({
    required this.fileName,
    required this.sizeBytes,
    this.documentId,
    this.storagePath,
    this.reviewStatus = DocumentReviewStatus.pending,
    this.reviewResult,
    this.reviewError,
  });

  final String fileName;
  final int sizeBytes;

  /// Supabase `documents.id` — null until the upload actually reaches the
  /// backend (i.e. still null in local-only mode, see DocumentReviewService).
  final String? documentId;

  /// Storage object path, needed to actually delete the file on remove —
  /// null only in local-only mode, same as [documentId].
  final String? storagePath;
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
    String? storagePath,
    DocumentReviewStatus? reviewStatus,
    Map<String, dynamic>? reviewResult,
    String? reviewError,
  }) {
    return UploadedDocument(
      fileName: fileName,
      sizeBytes: sizeBytes,
      documentId: documentId ?? this.documentId,
      storagePath: storagePath ?? this.storagePath,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewResult: reviewResult ?? this.reviewResult,
      reviewError: reviewError ?? this.reviewError,
    );
  }
}

/// Keyed by [DocumentRequirement.id] so core, country-specific, and
/// occupation-specific requirements can all share one upload-status map.
/// Same sync hydrate/persist pattern as the rest of this app's Notifiers —
/// previously this never hydrated at all, so uploads that were genuinely
/// saved server-side vanished from the UI on every refresh.
class DocumentUploadNotifier extends Notifier<Map<String, UploadedDocument?>> {
  @override
  Map<String, UploadedDocument?> build() {
    _hydrate();
    return {};
  }

  Future<void> _hydrate() async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      final rows = await SupabaseService.client.from('documents').select().eq('user_id', userId);
      final hydrated = <String, UploadedDocument?>{};
      for (final row in rows as List) {
        final status = _statusFromString(row['ai_review_status'] as String);
        final result = row['ai_review_result'] as Map<String, dynamic>?;
        hydrated[row['requirement_id'] as String] = UploadedDocument(
          fileName: row['file_name'] as String,
          sizeBytes: (row['size_bytes'] as num).toInt(),
          documentId: row['id'] as String,
          storagePath: row['storage_path'] as String,
          reviewStatus: status,
          reviewResult: result,
          reviewError: status == DocumentReviewStatus.failed ? (result?['error'] as String?) : null,
        );
      }
      if (hydrated.isNotEmpty) state = {...state, ...hydrated};
    } catch (_) {
      // Stay on defaults — a failed hydrate shouldn't block the page.
    }
  }

  void setUploaded(String requirementId, UploadedDocument document) {
    state = {...state, requirementId: document};
  }

  void clear(String requirementId) {
    state = {...state, requirementId: null};
  }

  /// Clears local state immediately, then deletes the real Storage object
  /// and documents row — previously this only cleared local state,
  /// leaving the file and row orphaned server-side (invisible to the
  /// applicant, but still there).
  Future<void> removeDocument(String requirementId) async {
    final current = state[requirementId];
    state = {...state, requirementId: null};

    if (!SupabaseService.isReady || current?.documentId == null) return;
    try {
      final client = SupabaseService.client;
      if (current!.storagePath != null) {
        await client.storage.from('documents').remove([current.storagePath!]);
      }
      await client.from('documents').delete().eq('id', current.documentId!);
    } catch (_) {
      // Local state already reflects the removal; a failed remote delete
      // just leaves an orphaned row/file rather than reverting the UI.
    }
  }

  void updateReview(
    String requirementId, {
    String? documentId,
    String? storagePath,
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
        storagePath: storagePath,
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
