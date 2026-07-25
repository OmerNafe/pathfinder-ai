import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../data/sample_dashboard_data.dart';
import '../services/app_sounds.dart';
import '../services/document_review_service.dart';
import '../state/document_upload_state.dart';
import '../state/growth_state.dart';
import '../state/pathway_tasks.dart';
import '../theme/app_colors.dart';
import '../utils/file_upload_validation.dart';
import '../widgets/ai_processing_consent_dialog.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/confetti_burst.dart';
import '../widgets/floating_card.dart';
import '../widgets/status_pill.dart';

/// The mobile home screen's single focal point — one real task, a camera
/// aimed at it. This is the one place in the app where mobile is
/// deliberately *better* than desktop: people photograph passports and
/// certificates with their phones in real life, not scan them at a desk.
/// Uploading here uses the exact same DocumentReviewService/
/// documentUploadProvider pipeline as the full /documents checklist, so
/// progress made here shows up everywhere else immediately.
class TodayTaskCard extends ConsumerStatefulWidget {
  const TodayTaskCard({super.key, required this.task});

  final PathwayTask task;

  @override
  ConsumerState<TodayTaskCard> createState() => _TodayTaskCardState();
}

class _TodayTaskCardState extends ConsumerState<TodayTaskCard> {
  bool _busy = false;

  void _toast(String message) => AppSnackBar.show(context, message);

  Future<void> _captureAndUpload({required bool useCamera}) async {
    setState(() => _busy = true);
    try {
      String fileName;
      Uint8List bytes;

      if (useCamera) {
        final photo = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
        if (photo == null) return;
        fileName = photo.name;
        bytes = await photo.readAsBytes();
      } else {
        final result = await FilePicker.pickFiles(type: FileType.any, withData: true);
        if (result == null || result.files.isEmpty) return;
        final file = result.files.first;
        if (file.bytes == null) return;
        fileName = file.name;
        bytes = file.bytes!;
      }

      final validationError = validateDocumentFile(fileName: fileName, sizeBytes: bytes.length);
      if (validationError != null) {
        _toast(validationError);
        return;
      }

      if (!mounted) return;
      final consented = await ensureAiProcessingConsent(context);
      if (!consented) {
        if (mounted) _toast('Upload cancelled — AI review requires agreeing to how your document is processed.');
        return;
      }
      if (!mounted) return;

      final requirementId = widget.task.requirementId;
      final notifier = ref.read(documentUploadProvider.notifier);
      notifier.setUploaded(requirementId, UploadedDocument(fileName: fileName, sizeBytes: bytes.length));
      notifier.updateReview(requirementId, status: DocumentReviewStatus.reviewing);
      if (!mounted) return;
      _toast('$fileName uploaded — reviewing…');

      final uploadResult = await DocumentReviewService.uploadAndReview(
        requirementId: requirementId,
        fileName: fileName,
        bytes: bytes,
      );

      if (!mounted) return;
      if (uploadResult.isLocalOnly) return;

      if (uploadResult.error != null) {
        notifier.updateReview(requirementId, status: DocumentReviewStatus.failed, error: uploadResult.error);
        _toast(uploadResult.error!);
        return;
      }

      notifier.updateReview(
        requirementId,
        documentId: uploadResult.documentId,
        status: DocumentReviewStatus.reviewed,
        result: uploadResult.reviewResult,
      );
      ref.read(growthProvider.notifier).recordAction();
      AppSounds.celebrate();
      if (mounted) ConfettiBurst.play(context);
    } catch (e) {
      if (mounted) _toast('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDone = task.status == TaskStatus.verified;

    if (isDone) {
      return FloatingCard(
        accentColor: AppColors.teal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: AppColors.teal, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("You're all caught up", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Nothing needs your attention right now — check back tomorrow.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final color = task.status == TaskStatus.rejected ? AppColors.danger : AppColors.gold;

    return FloatingCard(
      accentColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(
                label: task.status == TaskStatus.rejected ? 'Needs attention' : "Today's task",
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(task.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
          if (task.statusNote != null) ...[
            const SizedBox(height: 10),
            Text(
              task.statusNote!,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _busy ? null : () => _captureAndUpload(useCamera: true),
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.backgroundDeep),
                    )
                  : const Icon(Icons.camera_alt_outlined, size: 18),
              label: Text(_busy ? 'Uploading…' : 'Take a photo'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.backgroundDeep,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                onPressed: _busy ? null : () => _captureAndUpload(useCamera: false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Choose a file instead', style: TextStyle(fontSize: 12.5)),
              ),
              const Text('·', style: TextStyle(color: AppColors.textMuted)),
              TextButton(
                onPressed: () => context.go('/tasks/${task.step}'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View details', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
