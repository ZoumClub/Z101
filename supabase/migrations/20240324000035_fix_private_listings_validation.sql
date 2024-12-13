-- Update phone number validation in private_listings table
alter table private_listings 
  drop constraint if exists private_listings_client_phone_check;

alter table private_listings
  add constraint private_listings_client_phone_check 
  check (client_phone ~ '^\+?[0-9][0-9\s-()]{8,}$');

-- Create or replace the process_private_listing function with improved validation
create or replace function process_private_listing(
  p_listing_id uuid,
  p_status text,
  p_features text[] default null
) returns jsonb as $$
declare
  v_listing private_listings;
  v_car_id uuid;
  v_result jsonb;
begin
  -- Validate status
  if p_status not in ('approved', 'rejected') then
    raise exception 'Invalid status. Must be either approved or rejected.';
  end if;

  -- Get and lock the listing
  select * into v_listing
  from private_listings
  where id = p_listing_id
  for update;

  if not found then
    raise exception 'Listing not found';
  end if;

  if v_listing.status != 'pending' then
    raise exception 'Listing has already been processed';
  end if;

  -- Update listing status
  update private_listings
  set 
    status = p_status,
    updated_at = now()
  where id = p_listing_id
  returning * into v_listing;

  -- If features are provided, manage them
  if p_features is not null then
    perform manage_private_listing_features(p_listing_id, p_features);
  end if;

  -- If approved, create car listing
  if p_status = 'approved' then
    insert into cars (
      brand_id, make, model, year, price, image,
      video_url, condition, mileage, fuel_type,
      transmission, body_type, exterior_color,
      interior_color, number_of_owners, savings,
      is_sold
    )
    values (
      v_listing.brand_id, v_listing.make, v_listing.model,
      v_listing.year, v_listing.price, v_listing.image,
      v_listing.video_url, v_listing.condition, v_listing.mileage,
      v_listing.fuel_type, v_listing.transmission, v_listing.body_type,
      v_listing.exterior_color, v_listing.interior_color,
      v_listing.number_of_owners, floor(v_listing.price * 0.1),
      false
    )
    returning id into v_car_id;

    -- Copy features to car if they exist
    insert into car_features (car_id, name, available)
    select v_car_id, name, available
    from private_listing_features
    where listing_id = p_listing_id;
  end if;

  -- Prepare result
  v_result := jsonb_build_object(
    'success', true,
    'listing_id', p_listing_id,
    'car_id', v_car_id,
    'status', p_status
  );

  return v_result;
exception
  when others then
    raise exception '%', sqlerrm;
end;
$$ language plpgsql security definer;

-- Refresh schema cache
notify pgrst, 'reload schema';