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

alter table safety_meetings add column if not exists prev_review text;
alter table safety_meetings add column if not exists birthdays text;
alter table safety_meetings add column if not exists status text not null default 'draft';
alter table safety_meetings add column if not exists approved_at timestamptz;

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

alter table safety_meetings enable row level security;

drop policy if exists "anon full access" on safety_meetings;
create policy "anon full access" on safety_meetings
  for all
  using (true)
  with check (true);
