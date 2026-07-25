import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

class AvatarUploadException implements Exception {
  const AvatarUploadException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Uploads to the public avatars bucket under a fixed per-user filename
/// (so re-uploading replaces rather than accumulating orphaned files),
/// then persists the resulting public URL to profiles.avatar_url.
class AvatarUploadService {
  AvatarUploadService._();

  static Future<String> upload({required Uint8List bytes, required String fileExt}) async {
    if (!SupabaseService.isReady) {
      throw const AvatarUploadException("The backend isn't connected yet, so this can't be saved for real.");
    }
    final userId = AuthService.currentUser?.id;
    if (userId == null) {
      throw const AvatarUploadException('Sign in to save a profile picture.');
    }

    final client = SupabaseService.client;
    final ext = fileExt.isEmpty ? 'jpg' : fileExt;
    final storagePath = '$userId/avatar.$ext';

    try {
      await client.storage.from('avatars').uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = client.storage.from('avatars').getPublicUrl(storagePath);
      // Cache-bust so the new image actually shows instead of a stale
      // browser-cached copy at the same URL.
      final bustedUrl = '$url?v=${DateTime.now().millisecondsSinceEpoch}';

      await client.from('profiles').update({'avatar_url': bustedUrl}).eq('id', userId);

      return bustedUrl;
    } catch (e) {
      throw AvatarUploadException('Could not save your photo right now: $e');
    }
  }
}
