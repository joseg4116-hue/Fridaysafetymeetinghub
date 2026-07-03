-- Run this once in Supabase: Project → SQL Editor → New Query → paste → Run
-- Adds the draft/approval workflow: meetings are edited as drafts through the
-- week, then a single PIN-gated "Approve" click in the app moves them into
-- Meeting History.

alter table safety_meetings add column if not exists status text not null default 'draft';
alter table safety_meetings add column if not exists approved_at timestamptz;

-- Rows that existed before this migration were already-held meetings —
-- mark them approved so they keep showing up in Meeting History under the
-- new status filter (History now only lists status = 'approved').
update safety_meetings set status = 'approved' where status = 'draft';
