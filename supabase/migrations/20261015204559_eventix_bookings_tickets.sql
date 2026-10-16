-- Reviewed migration. Apply through Supabase migration tooling after its
-- preflight checks and explicit environment approval.
begin;

-- The audited tables are empty. Refuse to detach any future legacy tickets from
-- their purchases; if records appear, provide a reviewed data backfill first.
do $migration$
begin
  if exists (select 1 from public.bookings limit 1)
     or exists (select 1 from public.tickets limit 1) then
    raise exception
      'bookings/tickets contain data; add a reviewed booking and ticket backfill before this migration';
  end if;
end
$migration$;

alter table public.bookings
  add column request_id uuid not null,
  add column unit_price numeric(12, 2) not null,
  add column currency_code text not null,
  add column status text not null default 'confirmed',
  add column confirmed_at timestamptz not null default now(),
  add constraint bookings_user_request_unique unique (user_id, request_id),
  add constraint bookings_status_valid
    check (status in ('confirmed', 'cancelled')),
  add constraint bookings_unit_price_nonnegative check (unit_price >= 0),
  add constraint bookings_total_nonnegative check (total_amount >= 0);

alter table public.tickets
  add column booking_id uuid not null
    references public.bookings(id) on delete cascade,
  add column issued_at timestamptz not null default now();

create index bookings_user_created_at_idx
  on public.bookings (user_id, created_at desc);
create index bookings_event_id_idx on public.bookings (event_id);
create index tickets_booking_id_idx on public.tickets (booking_id);
create index tickets_event_id_idx on public.tickets (event_id);
create index tickets_user_id_idx on public.tickets (user_id);

-- Expose only the published catalog and a derived availability count; raw
-- booking rows remain protected by RLS and are never aggregated client-side.
create view public.event_catalog
  with (security_barrier = true)
as
select
  e.id,
  e.title,
  e.description,
  e.image_url,
  e.category,
  e.city,
  e.location_name,
  e.address,
  e.event_date,
  e.price,
  e.currency_code,
  e.capacity,
  greatest(
    e.capacity - coalesce(sum(b.quantity) filter (where b.status = 'confirmed'), 0),
    0
  )::integer as available_tickets,
  e.is_published
from public.events as e
left join public.bookings as b on b.event_id = e.id
where e.is_published
group by e.id;

revoke all on public.event_catalog from public, anon, authenticated;
grant select on public.event_catalog to authenticated;

commit;
