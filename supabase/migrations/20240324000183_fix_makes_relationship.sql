-- Drop existing views
drop view if exists cars_with_make cascade;
drop view if exists private_listings_with_make cascade;

-- Create cars_with_make view
create view cars_with_make as
select 
  c.*,
  m.name as make_name,
  m.logo_url as make_logo_url
from cars c
join makes m on m.id = c.make_id;

-- Create private_listings_with_make view
create view private_listings_with_make as
select 
  pl.*,
  m.name as make_name,
  m.logo_url as make_logo_url
from private_listings pl
join makes m on m.id = pl.make_id;

-- Grant permissions
grant select on cars_with_make to anon, authenticated;
grant select on private_listings_with_make to anon, authenticated;

-- Create indexes
create index if not exists idx_cars_make_id on cars(make_id);
create index if not exists idx_private_listings_make_id on private_listings(make_id);

-- Refresh schema cache
notify pgrst, 'reload schema';