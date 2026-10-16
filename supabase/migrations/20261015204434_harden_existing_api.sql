-- Reviewed migration. Apply through Supabase migration tooling after its
-- preflight checks and explicit environment approval.
begin;

-- Preserve the Auth UUID relationship without deleting or silently orphaning
-- profiles if data has been added since the audit.
do $migration$
begin
  if exists (
    select 1
      from public.users as profile
      left join auth.users as auth_user on auth_user.id = profile.id
     where auth_user.id is null
  ) then
    raise exception
      'public.users contains profiles without auth.users rows; reconcile them before adding the foreign key';
  end if;

  if not exists (
    select 1
      from pg_constraint
     where conrelid = 'public.users'::regclass
       and conname = 'users_auth_user_fkey'
  ) then
    alter table public.users
      add constraint users_auth_user_fkey
      foreign key (id) references auth.users(id) on delete cascade;
  end if;
end
$migration$;

-- The profile row is created by the Auth trigger. API clients only need to read
-- safe profile fields and update a small set of profile fields.
drop policy if exists "Acceso público usuarios" on public.users;
drop policy if exists "Los usuarios pueden ver su propio perfil" on public.users;
drop policy if exists "Los usuarios pueden actualizar su propio perfil" on public.users;

create policy "Authenticated users can read their own profile"
  on public.users
  for select
  to authenticated
  using ((select auth.uid()) = id);

create policy "Authenticated users can update their own profile"
  on public.users
  for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

revoke all on table public.users from public, anon, authenticated;
grant select (id, first_name, last_name, email, phone, created_at)
  on table public.users to authenticated;
grant update (first_name, last_name, phone)
  on table public.users to authenticated;

-- Do not allow public catalog edits. The published-event read policy is added
-- by the following catalog migration after is_published exists.
drop policy if exists "Acceso público eventos" on public.events;
revoke all on table public.events from public, anon, authenticated;

-- Booking/ticket writes will be performed by the restricted confirmation RPC,
-- not by direct table mutations from a client.
drop policy if exists "Users can view their own bookings" on public.bookings;
create policy "Authenticated users can view their own bookings"
  on public.bookings
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

revoke all on table public.bookings from public, anon, authenticated;
grant select on table public.bookings to authenticated;

drop policy if exists "Users can insert their own tickets" on public.tickets;
drop policy if exists "Users can view their own tickets" on public.tickets;
create policy "Authenticated users can view their own tickets"
  on public.tickets
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

revoke all on table public.tickets from public, anon, authenticated;
grant select on table public.tickets to authenticated;

-- The profile trigger remains usable by Auth, but must not be callable as an
-- arbitrary RPC and must not resolve unqualified names through a mutable path.
alter function public.handle_new_user()
  set search_path = pg_catalog, public;
revoke all on function public.handle_new_user() from public, anon, authenticated;
grant execute on function public.handle_new_user() to supabase_auth_admin;

commit;
