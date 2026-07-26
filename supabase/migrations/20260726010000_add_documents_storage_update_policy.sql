-- Real bug: "Replace file" on an already-uploaded document uploads with
-- upsert: true, which is an UPDATE on the existing storage.objects row
-- when a file already exists at that path -- not an INSERT. The documents
-- bucket only ever had INSERT/SELECT/DELETE policies (unlike avatars,
-- which already had this), so every replace attempt was rejected by RLS
-- with "new row violates row-level security policy" before ever reaching
-- the AI review step.
create policy "Users can update their own document storage folder"
  on storage.objects for update
  using (bucket_id = 'documents' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'documents' and (storage.foldername(name))[1] = auth.uid()::text);
