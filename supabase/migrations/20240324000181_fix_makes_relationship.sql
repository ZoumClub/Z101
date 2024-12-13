-- Drop existing views
drop view if exists cars_with_make cascade;
drop view if exists private_listings_with_make cascade;

-- Create makes table if not exists
create table if not exists makes (
  id uuid default gen_random_uuid() primary key,
  name text not null unique,
  logo_url text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Insert default makes
insert into makes (name, logo_url) values
  ('BMW', 'https://images.unsplash.com/photo-1617886903355-9354bb57751f'),
  ('Mercedes', 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8'),
  ('Audi', 'https://images.unsplash.com/photo-1610768764270-790fbec18178'),
  ('Toyota', 'https://images.unsplash.com/photo-1629897048514-3dd7414fe72a'),
  ('Honda', 'https://images.unsplash.com/photo-1618843479619-f3d0d81e4d10'),
  ('Ford', 'https://images.unsplash.com/photo-1612825173281-9a193378527e'),
  ('Volkswagen', 'https://images.unsplash.com/photo-1622353219448-46a009f0d44f')
on conflict (name) do update set logo_url = excluded.logo_url;

-- Add make_id to cars if not exists
alter table cars 
  add column if not exists make_id uuid references makes(id);

-- Add make_id to private_listings if not exists
alter table private_listings
  add column if not exists make_id uuid references makes(id);

-- Update existing records
update cars c
set make_id = m.id
from makes m
where c.make = m.name;

update private_listings pl
set make_id = m.id
from makes m
where pl.make = m.name;

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

-- Create indexes
create index if not exists idx_cars_make_id on cars(make_id);
create index if not exists idx_private_listings_make_id on private_listings(make_id);

-- Grant permissions
grant select on makes to anon, authenticated;
grant select on cars_with_make to anon, authenticated;
grant select on private_listings_with_make to anon, authenticated;

-- Refresh schema cache
notify pgrst, 'reload schema';