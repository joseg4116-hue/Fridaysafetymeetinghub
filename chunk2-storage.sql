insert into storage.buckets (id, name, public)
values ('near-miss-attachments', 'near-miss-attachments', true)
on conflict (id) do nothing;

drop policy if exists "anon upload near-miss pdfs" on storage.objects;
create policy "anon upload near-miss pdfs" on storage.objects
  for insert
  with check (bucket_id = 'near-miss-attachments');

drop policy if exists "anon read near-miss pdfs" on storage.objects;
create policy "anon read near-miss pdfs" on storage.objects
  for select
  using (bucket_id = 'near-miss-attachments');
