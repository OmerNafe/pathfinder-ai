-- Backs the Account settings toggles — previously local-only setState
-- bools that didn't persist or mean anything. A real reminder job needs
-- a real, persisted preference to check before ever sending anything.
alter table public.profiles
  add column email_notifications boolean not null default true,
  add column push_notifications boolean not null default true;
