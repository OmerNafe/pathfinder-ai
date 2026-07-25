-- ProfileNotifier (lib/state/profile_state.dart) previously returned
-- hardcoded placeholder data ("Applicant Name", "Qatar", etc.) for every
-- signed-in user and never persisted edits — the same class of bug as the
-- fake dashboard tasks/gaps fixed earlier, just in the profile screen.
alter table public.profiles
  add column phone text,
  add column date_of_birth date,
  add column nationality text,
  add column country_of_residence text,
  add column marital_status text,
  add column years_of_experience int,
  add column highest_qualification text;
