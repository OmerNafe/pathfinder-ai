-- checklist_submissions had insert/select/delete policies but no update
-- one, while LicensingChecklistSubmissionNotifier._persistSubmit uses
-- upsert() -- a resubmission (hitting the ON CONFLICT branch, which is an
-- UPDATE under the hood) was silently rejected by RLS with no policy to
-- allow it, swallowed by the notifier's catch-all.
create policy "Users can update their own checklist submissions"
  on public.checklist_submissions for update
  using (auth.uid() = user_id);
