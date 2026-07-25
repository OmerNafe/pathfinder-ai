-- Profile picture upload was local-only (Uint8List held in memory, never
-- persisted) despite the screen looking like a real save. Public bucket
-- (unlike the private documents bucket) -- profile pictures are low
-- sensitivity and a public URL means the client never needs signed URLs
-- to display one.
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

create policy "Users can upload to their own avatar folder"
  on storage.objects for insert
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "Users can update their own avatar folder"
  on storage.objects for update
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "Users can delete their own avatar folder"
  on storage.objects for delete
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

-- No explicit select policy needed -- the bucket is public, so reads go
-- through the public URL endpoint rather than RLS-gated table access.
