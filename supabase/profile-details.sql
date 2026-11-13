-- Run in Supabase SQL Editor after schema.sql and photos.sql.
-- Additive migration: existing profiles, RLS policies and bookings are preserved.
-- Safe to run again. Empty arrays / NULL mean not specified, not unavailable.
begin;
alter table public.sitter_profiles
  add column if not exists pet_types text[] not null default '{}',
  add column if not exists experience_years smallint,
  add column if not exists available_days smallint[] not null default '{}';

alter table public.sitter_profiles drop constraint if exists sitter_pet_types_valid;
alter table public.sitter_profiles add constraint sitter_pet_types_valid check (
  pet_types <@ array['Dogs','Cats','Small pets']::text[]
  and array_position(pet_types, null) is null and cardinality(pet_types) <= 3
);
alter table public.sitter_profiles drop constraint if exists sitter_experience_valid;
alter table public.sitter_profiles add constraint sitter_experience_valid
  check (experience_years is null or experience_years between 0 and 80);
alter table public.sitter_profiles drop constraint if exists sitter_days_valid;
alter table public.sitter_profiles add constraint sitter_days_valid check (
  available_days <@ array[1,2,3,4,5,6,7]::smallint[]
  and array_position(available_days, null) is null and cardinality(available_days) <= 7
);
notify pgrst, 'reload schema';
commit;
