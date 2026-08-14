-- ============================================================
-- Blockwave global leaderboard — Supabase setup
-- Paste this whole file into the Supabase SQL Editor and Run.
-- ============================================================

create table if not exists public.blockwave_scores (
  device      text primary key,
  name        text        not null default 'Player',
  score       bigint      not null default 0,
  day         integer     not null default 0,
  prestige    smallint    not null default 0,
  level       integer     not null default 1,
  colour      text        not null default '#FFFFFF',
  grad        text        not null default '',
  gspd        smallint    not null default 4,
  crest       smallint    not null default 0,
  updated_at  timestamptz not null default now(),

  -- light sanity limits so a bad client cannot write nonsense
  constraint blockwave_name_len  check (char_length(name) between 1 and 12),
  constraint blockwave_score_ok  check (score >= 0 and score <= 1000000000000),
  constraint blockwave_prestige_ok check (prestige between 0 and 11),
  constraint blockwave_level_ok  check (level between 1 and 1000000),
  constraint blockwave_grad_len  check (char_length(grad) <= 400)
);

-- fast ordering for both boards
create index if not exists blockwave_day_score_idx on public.blockwave_scores (day, score desc);
create index if not exists blockwave_rank_idx      on public.blockwave_scores (prestige desc, level desc);

-- Row Level Security: the anon key can only do these three things.
alter table public.blockwave_scores enable row level security;

drop policy if exists "anyone can read the board"   on public.blockwave_scores;
drop policy if exists "anyone can add their row"    on public.blockwave_scores;
drop policy if exists "anyone can update their row" on public.blockwave_scores;

create policy "anyone can read the board"
  on public.blockwave_scores for select
  to anon using (true);

create policy "anyone can add their row"
  on public.blockwave_scores for insert
  to anon with check (true);

create policy "anyone can update their row"
  on public.blockwave_scores for update
  to anon using (true) with check (true);

-- If you already created the table before crests existed, run this once:
alter table public.blockwave_scores add column if not exists crest smallint not null default 0;

-- Optional housekeeping: forget score rows nobody has touched in 30 days.
-- delete from public.blockwave_scores where updated_at < now() - interval '30 days';
