-- Run this once in Supabase: Project → SQL Editor → New Query → paste → Run

create table if not exists safety_meetings (
  id uuid primary key default gen_random_uuid(),
  meeting_date date not null,
  presenter text,
  safety_topic text,
  prev_review text,
  birthdays text,
  tl_items jsonb not null default '[]',
  ft_items jsonb not null default '[]',
  nm_items jsonb not null default '[]',
  assignments text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- If you already ran this script before (old project), just add the new columns:
alter table safety_meetings add column if not exists prev_review text;
alter table safety_meetings add column if not exists birthdays text;
alter table safety_meetings add column if not exists status text not null default 'draft';
alter table safety_meetings add column if not exists approved_at timestamptz;

-- Keep updated_at current on edits
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_safety_meetings_updated on safety_meetings;
create trigger trg_safety_meetings_updated
before update on safety_meetings
for each row execute function set_updated_at();

-- Enable Row-Level Security
alter table safety_meetings enable row level security;

-- Since this is an internal leadership tool with no login screen,
-- allow the anon key full read/write. (Anyone with the app URL can use it —
-- fine for a small trusted team, but say the word if you want auth added later.)
drop policy if exists "anon full access" on safety_meetings;
create policy "anon full access" on safety_meetings
  for all
  using (true)
  with check (true);

-- Storage bucket for near-miss PDF attachments
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

-- ---------------------------------------------------------------
-- Presentations library (PowerPoint files)
-- ---------------------------------------------------------------
create table if not exists public.presentations (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  file_name text not null,
  storage_path text not null,
  file_url text not null,
  file_size bigint,
  created_at timestamptz not null default now()
);

alter table public.presentations enable row level security;

drop policy if exists "anon full access" on public.presentations;
create policy "anon full access" on public.presentations
  for all
  to anon
  using (true)
  with check (true);

insert into storage.buckets (id, name, public)
values ('presentations', 'presentations', true)
on conflict (id) do nothing;

drop policy if exists "anon manage presentations" on storage.objects;
create policy "anon manage presentations" on storage.objects
  for all
  to anon
  using (bucket_id = 'presentations')
  with check (bucket_id = 'presentations');
