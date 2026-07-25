/// Fast, friendly pre-upload checks for the two places this app accepts
/// arbitrary files from a file picker (documents, avatars). This mirrors —
/// but does not replace — the allowed_mime_types/file_size_limit enforced
/// on the Storage buckets themselves (see the add_upload_limits
/// migration): that's the real boundary a malicious client can't bypass,
/// this is just the UI catching an obviously-wrong file before a network
/// round trip.
const documentMaxSizeBytes = 15 * 1024 * 1024; // 15 MB
const avatarMaxSizeBytes = 5 * 1024 * 1024; // 5 MB

const _documentExtensions = {'pdf', 'jpg', 'jpeg', 'png', 'heic', 'heif'};
const _imageExtensions = {'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'};

String? _extensionOf(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot == -1 || dot == fileName.length - 1) return null;
  return fileName.substring(dot + 1).toLowerCase();
}

const _mimeTypesByExtension = {
  'pdf': 'application/pdf',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'webp': 'image/webp',
  'heic': 'image/heic',
  'heif': 'image/heif',
};

/// The exact Content-Type to send with an upload, matching what the
/// documents/avatars Storage buckets' allowed_mime_types expect (see the
/// add_upload_limits migration). Passed explicitly rather than left for
/// the Supabase client to guess from the storage path — a mobile camera
/// capture can hand back a filename with no or an unrecognized extension,
/// in which case the client falls back to application/octet-stream, which
/// the bucket then rejects. Returns null (let the bucket's own rejection
/// surface the real error) only if the extension is genuinely unknown,
/// which validateDocumentFile/validateImageFile should already have
/// caught before this is ever called.
String? mimeTypeFor(String fileName) {
  final ext = _extensionOf(fileName);
  if (ext == null) return null;
  return _mimeTypesByExtension[ext];
}

/// Returns an error message if the file should be rejected, or null if
/// it's fine to upload.
String? validateDocumentFile({required String fileName, required int sizeBytes}) {
  final ext = _extensionOf(fileName);
  if (ext == null || !_documentExtensions.contains(ext)) {
    return "$fileName isn't a supported file type — upload a PDF, JPG, PNG, or HEIC file.";
  }
  if (sizeBytes > documentMaxSizeBytes) {
    return '$fileName is too large — documents must be under 15 MB.';
  }
  return null;
}

/// Returns an error message if the image should be rejected, or null if
/// it's fine to upload.
String? validateImageFile({required String fileName, required int sizeBytes}) {
  final ext = _extensionOf(fileName);
  if (ext == null || !_imageExtensions.contains(ext)) {
    return "That file isn't a supported image type — upload a JPG, PNG, WEBP, or HEIC image.";
  }
  if (sizeBytes > avatarMaxSizeBytes) {
    return 'That image is too large — profile pictures must be under 5 MB.';
  }
  return null;
}
