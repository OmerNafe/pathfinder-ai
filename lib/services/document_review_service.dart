import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/file_upload_validation.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

class DocumentUploadResult {
  const DocumentUploadResult({this.documentId, this.storagePath, this.reviewResult, this.error});

  final String? documentId;
  final String? storagePath;
  final Map<String, dynamic>? reviewResult;
  final String? error;

  bool get isLocalOnly => documentId == null && error == null;
}

/// Uploads to Storage, records the row, then invokes the analyze-document
/// Edge Function — the real pipeline behind what document_upload_screen
/// shows. When Supabase isn't configured yet, returns a result the caller
/// recognizes as "stay in local-only mode" rather than throwing, so the
/// existing offline behavior keeps working exactly as it did before.
class DocumentReviewService {
  DocumentReviewService._();

  static Future<DocumentUploadResult> uploadAndReview({
    required String requirementId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (!SupabaseService.isReady) {
      return const DocumentUploadResult();
    }
    final userId = AuthService.currentUser?.id;
    if (userId == null) {
      return const DocumentUploadResult(error: 'Sign in to upload documents.');
    }

    final client = SupabaseService.client;
    final storagePath = '$userId/$requirementId-$fileName';

    try {
      await client.storage.from('documents').uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: mimeTypeFor(fileName)),
          );

      final row = await client
          .from('documents')
          .upsert(
            {
              'user_id': userId,
              'requirement_id': requirementId,
              'file_name': fileName,
              'storage_path': storagePath,
              'size_bytes': bytes.length,
              'ai_review_status': 'pending',
              'ai_review_result': null,
            },
            onConflict: 'user_id,requirement_id',
          )
          .select()
          .single();

      final documentId = row['id'] as String;

      final response = await client.functions.invoke(
        'analyze-document',
        body: {'documentId': documentId},
      );

      final data = response.data;
      if (response.status != 200) {
        final message = (data is Map && data['error'] is String)
            ? data['error'] as String
            : 'Document review failed.';
        return DocumentUploadResult(documentId: documentId, storagePath: storagePath, error: message);
      }

      final result = data is Map ? data['result'] as Map<String, dynamic>? : null;
      return DocumentUploadResult(documentId: documentId, storagePath: storagePath, reviewResult: result);
    } catch (e) {
      return DocumentUploadResult(error: 'Upload failed: $e');
    }
  }
}
