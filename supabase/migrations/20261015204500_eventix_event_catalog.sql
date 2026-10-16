-- Reviewed migration. Apply through Supabase migration tooling after its
-- preflight checks and explicit environment approval.
begin;

-- The current events table has no rows. Refuse to guess category/city/currency
-- for any events added after the audit; create an explicit backfill first.
do $migration$
begin
  if exists (select 1 from public.events limit 1) then
    raise exception
      'public.events is not empty; add an explicit category/city/currency backfill before this migration';
  end if;
end
$migration$;

alter table public.events
  add column category text not null,
  add column city text not null,
  add column currency_code text not null,
  add column is_published boolean not null default false;

alter table public.events
  alter column price set not null,
  alter column capacity set not null;

alter table public.events
  add constraint events_price_nonnegative check (price >= 0),
  add constraint events_capacity_positive check (capacity > 0);

create index events_event_date_idx on public.events (event_date);
create index events_category_idx on public.events (category);
create index events_city_idx on public.events (city);

create policy "Authenticated users can view published events"
  on public.events
  for select
  to authenticated
  using (is_published);

grant select on table public.events to authenticated;

commit;
