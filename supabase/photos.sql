-- Run in Supabase SQL Editor after the existing sitter_profiles schema.
alter table public.sitter_profiles add column if not exists photo_path text;
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('sitter-photos','sitter-photos',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public=true,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
drop policy if exists "Sitter photos are public" on storage.objects;
create policy "Sitter photos are public" on storage.objects for select to anon, authenticated using (bucket_id='sitter-photos');
drop policy if exists "Sitters upload their photos" on storage.objects;
create policy "Sitters upload their photos" on storage.objects for insert to authenticated
with check (bucket_id='sitter-photos' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists "Sitters update their photos" on storage.objects;
create policy "Sitters update their photos" on storage.objects for update to authenticated
using (bucket_id='sitter-photos' and (storage.foldername(name))[1]=(select auth.uid())::text)
with check (bucket_id='sitter-photos' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists "Sitters delete their photos" on storage.objects;
create policy "Sitters delete their photos" on storage.objects for delete to authenticated
using (bucket_id='sitter-photos' and (storage.foldername(name))[1]=(select auth.uid())::text);