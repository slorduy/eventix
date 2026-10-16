-- Category/city lookup tables and a compatibility-preserving event backfill.
begin;

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.cities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  country_code char(2) not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint cities_country_name_unique unique (country_code, name)
);

alter table public.categories enable row level security;
alter table public.cities enable row level security;

revoke all on table public.categories from public, anon, authenticated;
revoke all on table public.cities from public, anon, authenticated;
grant select on table public.categories to authenticated;
grant select on table public.cities to authenticated;

create policy "Authenticated users can read active categories"
  on public.categories for select to authenticated
  using (is_active);

create policy "Authenticated users can read active cities"
  on public.cities for select to authenticated
  using (is_active);

insert into public.categories (name) values
  ('Música en vivo'),
  ('Tecnología'),
  ('Teatro'),
  ('Deportes'),
  ('Gastronomía')
on conflict (name) do nothing;

insert into public.cities (name, country_code) values
  ('Bogotá', 'CO'),
  ('Medellín', 'CO'),
  ('Cali', 'CO'),
  ('Barranquilla', 'CO')
on conflict (country_code, name) do nothing;

alter table public.events
  add column category_id uuid,
  add column city_id uuid;

update public.events as event
   set category_id = category.id
  from public.categories as category
 where event.category_id is null
   and lower(btrim(event.category)) = lower(category.name);

update public.events as event
   set city_id = city.id
  from public.cities as city
 where event.city_id is null
   and city.country_code = 'CO'
   and lower(btrim(event.city)) = lower(city.name);

do $migration$
begin
  if exists (
    select 1 from public.events
     where category_id is null or city_id is null
     limit 1
  ) then
    raise exception
      'An event category/city did not match the reference seed; backfill missing values before continuing';
  end if;
end
$migration$;

alter table public.events
  alter column category_id set not null,
  alter column city_id set not null,
  add constraint events_category_id_fkey
    foreign key (category_id) references public.categories(id) on delete restrict,
  add constraint events_city_id_fkey
    foreign key (city_id) references public.cities(id) on delete restrict;

create index events_category_id_idx on public.events (category_id);
create index events_city_id_idx on public.events (city_id);

-- Keep the legacy text columns during the app transition. The new view exposes
-- lookup IDs and canonical labels, and remains invoker-secured by RLS.
drop view public.event_catalog;
create view public.event_catalog
  with (security_barrier = true, security_invoker = true)
as
select
  event.id,
  event.title,
  event.description,
  event.image_url,
  category.name as category,
  city.name as city,
  event.location_name,
  event.address,
  event.event_date,
  event.price,
  event.currency_code,
  event.capacity,
  event.available_tickets,
  event.is_published,
  event.category_id,
  event.city_id
from public.events as event
join public.categories as category on category.id = event.category_id
join public.cities as city on city.id = event.city_id
where event.is_published and category.is_active and city.is_active;

revoke all on public.event_catalog from public, anon, authenticated;
grant select on public.event_catalog to authenticated;

notify pgrst, 'reload schema';
commit;
