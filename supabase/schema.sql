create table if not exists public.sitter_profiles (
 user_id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null check (char_length(display_name) between 2 and 80),
 suburb text not null check (suburb in ('Mount Eden','Ponsonby','Grey Lynn','Newmarket','Other Auckland')),
 service text not null check (service in ('Dog walking','Pet sitting','Boarding')),
 rate_nzd integer not null check (rate_nzd between 1 and 1000),
 bio text not null check (char_length(bio) between 15 and 500),
 created_at timestamptz not null default now()
);
alter table public.sitter_profiles enable row level security;
grant select on public.sitter_profiles to anon, authenticated;
grant insert, update on public.sitter_profiles to authenticated;
create policy "Public can browse sitters" on public.sitter_profiles for select to anon, authenticated using (true);
create policy "Owners can create profile" on public.sitter_profiles for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Owners can edit profile" on public.sitter_profiles for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);