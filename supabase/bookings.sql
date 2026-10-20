-- PawLocal NZ booking requests. Run once after sitter_profiles setup.
create table if not exists public.booking_requests (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 sitter_id uuid not null references public.sitter_profiles(user_id) on delete cascade,
 booking_date date not null,
 message text not null check (char_length(message) between 10 and 1000),
 status text not null default 'pending' check (status in ('pending','accepted','declined','cancelled')),
 created_at timestamptz not null default now(),
 constraint different_parties check (owner_id <> sitter_id)
);
alter table public.booking_requests enable row level security;
grant select,insert,update on public.booking_requests to authenticated;
create policy "Participants view booking" on public.booking_requests for select to authenticated
using ((select auth.uid())=owner_id or (select auth.uid())=sitter_id);
create policy "Owners request pending booking" on public.booking_requests for insert to authenticated
with check ((select auth.uid())=owner_id and status='pending' and booking_date >= current_date);
-- Status changes are deliberately performed via constrained RPC functions, not raw updates.
revoke update on public.booking_requests from authenticated;
create or replace function public.respond_to_booking(p_booking_id uuid,p_action text)
returns void language plpgsql security definer set search_path='' as $$
begin
 if p_action not in ('accepted','declined') then raise exception 'Invalid action'; end if;
 update public.booking_requests set status=p_action
 where id=p_booking_id and sitter_id=(select auth.uid()) and status='pending';
 if not found then raise exception 'Booking unavailable or not yours'; end if;
end $$;
revoke all on function public.respond_to_booking(uuid,text) from public,anon;
grant execute on function public.respond_to_booking(uuid,text) to authenticated;
create or replace function public.cancel_my_booking(p_booking_id uuid)
returns void language plpgsql security definer set search_path='' as $$
begin
 update public.booking_requests set status='cancelled'
 where id=p_booking_id and owner_id=(select auth.uid()) and status='pending';
 if not found then raise exception 'Booking unavailable or not yours'; end if;
end $$;
revoke all on function public.cancel_my_booking(uuid) from public,anon;
grant execute on function public.cancel_my_booking(uuid) to authenticated;