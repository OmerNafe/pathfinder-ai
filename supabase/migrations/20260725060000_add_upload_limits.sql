-- Security audit finding: the documents/avatars buckets had no
-- file_size_limit or allowed_mime_types, so RLS (which only governs *who*
-- can write to a path) was the only thing standing between a signed-in
-- user and uploading an arbitrarily large or arbitrarily typed file to
-- their own folder. The Flutter client now rejects obviously-wrong files
-- before upload (see lib/utils/file_upload_validation.dart), but that's a
-- UX nicety, not a boundary -- anyone calling the Storage API directly
-- bypasses it entirely. This is the boundary that can't be bypassed.
update storage.buckets
set file_size_limit = 15 * 1024 * 1024, -- 15 MB
    allowed_mime_types = array[
      'application/pdf',
      'image/jpeg',
      'image/png',
      'image/heic',
      'image/heif'
    ]
where id = 'documents';

update storage.buckets
set file_size_limit = 5 * 1024 * 1024, -- 5 MB
    allowed_mime_types = array[
      'image/jpeg',
      'image/png',
      'image/webp',
      'image/heic',
      'image/heif'
    ]
where id = 'avatars';
