-- Corrective migration: expose only published rows while honoring underlying
-- table grants/RLS, and maintain availability as a server-controlled cache.
begin;

do $migration$
begin
  if exists (
    select 1 from public.events where available_tickets is null limit 1
  ) then
    raise exception
      'events contain null availability; reconcile the values before enabling the catalog cache';
  end if;
end
$migration$;

alter table public.events
  alter column available_tickets set default 0,
  alter column available_tickets set not null;

create or replace function public.sync_event_availability()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $function$
declare
  v_reserved integer;
begin
  if tg_op = 'INSERT' then
    new.available_tickets := new.capacity;
  elsif new.capacity is distinct from old.capacity then
    select coalesce(sum(b.quantity), 0)::integer
      into v_reserved
      from public.bookings as b
     where b.event_id = new.id
       and b.status = 'confirmed';
    new.available_tickets := greatest(new.capacity - v_reserved, 0);
  end if;

  return new;
end;
$function$;

drop trigger if exists sync_event_availability_on_event_write on public.events;
create trigger sync_event_availability_on_event_write
  before insert or update on public.events
  for each row execute function public.sync_event_availability();

create or replace view public.event_catalog
  with (security_barrier = true, security_invoker = true)
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
  e.available_tickets,
  e.is_published
from public.events as e
where e.is_published;

revoke all on public.event_catalog from public, anon, authenticated;
grant select on public.event_catalog to authenticated;

commit;
