-- Security audit finding: every UPDATE policy had a USING clause but no
-- explicit WITH CHECK. Postgres's documented behavior (when WITH CHECK is
-- omitted, USING is reused as the check on the post-update row too) means
-- this was NOT actually exploitable -- a user genuinely could not repoint
-- a row's user_id to someone else's via UPDATE -- but relying on that
-- implicit fallback is fragile: it's easy for a future policy to be added
-- without USING, or for a reader to assume "no WITH CHECK" means
-- unchecked. Every UPDATE policy now says exactly what it means.
alter policy "Users can update their own profile" on public.profiles
  with check (auth.uid() = id);

alter policy "Users can update their own pathway" on public.pathways
  with check (auth.uid() = user_id);

alter policy "Users can update their own documents" on public.documents
  with check (auth.uid() = user_id);

alter policy "Users can update their own gaps" on public.gaps
  with check (auth.uid() = user_id);

alter policy "Users can update their own tasks" on public.tasks
  with check (auth.uid() = user_id);

alter policy "Users can update their own growth state" on public.growth_state
  with check (auth.uid() = user_id);

alter policy "Users can update their own checklist submissions" on public.checklist_submissions
  with check (auth.uid() = user_id);

alter policy "Users can update their own avatar folder" on storage.objects
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
