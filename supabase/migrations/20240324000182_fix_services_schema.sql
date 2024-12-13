-- Drop existing tables
drop table if exists main_services cascade;

-- Create main_services table
create table main_services (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text not null,
  price numeric not null check (price >= 0),
  image text not null,
  category text not null check (category in (
    'Maintenance',
    'Repair',
    'Inspection',
    'Customization',
    'Cleaning',
    'Insurance',
    'Warranty',
    'Other'
  )),
  duration text not null,
  available boolean not null default true,
  visible boolean not null default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create indexes
create index idx_main_services_category on main_services(category);
create index idx_main_services_available on main_services(available);
create index idx_main_services_visible on main_services(visible);

-- Enable RLS
alter table main_services enable row level security;

-- Create RLS policies
create policy "Public can view visible services"
  on main_services for select
  using (
    visible = true
    or
    auth.role() = 'authenticated'
  );

create policy "Authenticated users can manage services"
  on main_services for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- Insert sample services
insert into main_services (name, description, price, image, category, duration) values
  ('Full Service', 'Complete car service including oil change, filters, and inspection', 299.99, 'https://images.unsplash.com/photo-1625047509168-a7026f36de04', 'Maintenance', '3-4 hours'),
  ('Wheel Alignment', 'Professional wheel alignment service', 89.99, 'https://images.unsplash.com/photo-1621939514649-280e2ee25f60', 'Maintenance', '1 hour'),
  ('Paint Protection', 'Ceramic coating paint protection service', 599.99, 'https://images.unsplash.com/photo-1621963417481-fb4984a4b9a4', 'Customization', '1-2 days'),
  ('Interior Detailing', 'Complete interior cleaning and detailing service', 199.99, 'https://images.unsplash.com/photo-1607860108855-64acf2078ed9', 'Cleaning', '4-5 hours'),
  ('Engine Diagnostics', 'Full engine diagnostic scan and report', 99.99, 'https://images.unsplash.com/photo-1622186477895-f2af6a0f5a97', 'Inspection', '1 hour'),
  ('Window Tinting', 'Professional window tinting service', 299.99, 'https://images.unsplash.com/photo-1619725002198-6a689b72f41d', 'Customization', '2-3 hours');

-- Grant permissions
grant select on main_services to anon, authenticated;

-- Refresh schema cache
notify pgrst, 'reload schema';