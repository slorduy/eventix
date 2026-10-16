-- Reviewed migration. Apply through Supabase migration tooling after its
-- preflight checks and explicit environment approval.
begin;

create or replace function public.confirm_event_booking(
  p_event_id uuid,
  p_quantity integer,
  p_request_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_user_id uuid := auth.uid();
  v_event_price numeric(12, 2);
  v_currency_code text;
  v_capacity integer;
  v_is_published boolean;
  v_event_date timestamptz;
  v_reserved integer;
  v_booking_id uuid;
  v_result jsonb;
begin
  if v_user_id is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  if p_quantity is null or p_quantity < 1 then
    raise exception 'Quantity must be at least one' using errcode = '22023';
  end if;

  if p_request_id is null then
    raise exception 'Request ID is required' using errcode = '22023';
  end if;

  -- A stable key makes an ambiguous network retry return the original booking.
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_user_id::text || p_request_id::text, 0)
  );

  select b.id
    into v_booking_id
    from public.bookings as b
   where b.user_id = v_user_id
     and b.request_id = p_request_id;

  if found then
    select pg_catalog.jsonb_build_object(
      'booking', pg_catalog.to_jsonb(b),
      'tickets', coalesce(
        pg_catalog.jsonb_agg(pg_catalog.to_jsonb(t) order by t.created_at),
        '[]'::jsonb
      )
    )
      into v_result
      from public.bookings as b
      left join public.tickets as t on t.booking_id = b.id
     where b.id = v_booking_id
     group by b.id;

    return v_result;
  end if;

  -- Locking the event row serializes purchases for this event. The capacity
  -- check and inserts therefore run atomically relative to other confirmations.
  select e.price, e.currency_code, e.capacity, e.is_published, e.event_date
    into v_event_price, v_currency_code, v_capacity, v_is_published, v_event_date
    from public.events as e
   where e.id = p_event_id
   for update;

  if not found then
    raise exception 'Event not found' using errcode = 'P0002';
  end if;

  if not v_is_published or v_event_date <= pg_catalog.now() then
    raise exception 'Event is not available for booking' using errcode = '22023';
  end if;

  select coalesce(pg_catalog.sum(b.quantity), 0)::integer
    into v_reserved
    from public.bookings as b
   where b.event_id = p_event_id
     and b.status = 'confirmed';

  if p_quantity > v_capacity - v_reserved then
    raise exception 'Not enough tickets available' using errcode = 'P0001';
  end if;

  insert into public.bookings (
    user_id,
    event_id,
    request_id,
    quantity,
    unit_price,
    total_amount,
    currency_code,
    status,
    confirmed_at
  ) values (
    v_user_id,
    p_event_id,
    p_request_id,
    p_quantity,
    v_event_price,
    v_event_price * p_quantity,
    v_currency_code,
    'confirmed',
    pg_catalog.now()
  )
  returning id into v_booking_id;

  insert into public.tickets (
    booking_id,
    event_id,
    user_id,
    price_paid,
    status
  )
  select
    v_booking_id,
    p_event_id,
    v_user_id,
    v_event_price,
    'valid'
  from pg_catalog.generate_series(1, p_quantity);

  update public.events
     set available_tickets = greatest(v_capacity - v_reserved - p_quantity, 0)
   where id = p_event_id;

  select pg_catalog.jsonb_build_object(
      'booking', pg_catalog.to_jsonb(b),
      'tickets', coalesce(
      pg_catalog.jsonb_agg(pg_catalog.to_jsonb(t) order by t.created_at),
      '[]'::jsonb
    )
  )
    into v_result
    from public.bookings as b
    left join public.tickets as t on t.booking_id = b.id
   where b.id = v_booking_id
   group by b.id;

  return v_result;
end;
$function$;

revoke all on function public.confirm_event_booking(uuid, integer, uuid)
  from public, anon, authenticated;
grant execute on function public.confirm_event_booking(uuid, integer, uuid)
  to authenticated;

commit;
