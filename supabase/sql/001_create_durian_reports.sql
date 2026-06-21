-- Durian Radar
-- CP16: Create durian_reports table
-- Purpose: Prepare Supabase database table that matches Flutter DurianReport model.

create table if not exists public.durian_reports (
  id text primary key,

  marker_label text not null default 'NEW',
  stall_name text not null,
  area text not null,
  variety text not null,
  price text not null,

  stock_status text not null default 'available',
  status_text text not null default 'Masih Ada',
  updated_time text not null default 'Baru sahaja',

  created_at timestamptz not null default now(),
  updated_at timestamptz,

  note text,
  latitude double precision,
  longitude double precision,

  reporter_id uuid references auth.users(id) on delete set null,
  is_approved boolean not null default false,

  constraint durian_reports_stock_status_check
    check (stock_status in ('available', 'low_stock', 'sold_out')),

  constraint durian_reports_latitude_check
    check (latitude is null or (latitude >= -90 and latitude <= 90)),

  constraint durian_reports_longitude_check
    check (longitude is null or (longitude >= -180 and longitude <= 180))
);

create index if not exists durian_reports_created_at_idx
  on public.durian_reports (created_at desc);

create index if not exists durian_reports_stock_status_idx
  on public.durian_reports (stock_status);

create index if not exists durian_reports_is_approved_idx
  on public.durian_reports (is_approved);

create index if not exists durian_reports_area_idx
  on public.durian_reports (area);

create index if not exists durian_reports_variety_idx
  on public.durian_reports (variety);

alter table public.durian_reports enable row level security;

drop policy if exists "Anyone can read approved durian reports"
  on public.durian_reports;

create policy "Anyone can read approved durian reports"
  on public.durian_reports
  for select
  to anon, authenticated
  using (is_approved = true);

drop policy if exists "Anyone can submit unapproved durian reports"
  on public.durian_reports;

create policy "Anyone can submit unapproved durian reports"
  on public.durian_reports
  for insert
  to anon, authenticated
  with check (is_approved = false);

insert into public.durian_reports (
  id,
  marker_label,
  stall_name,
  area,
  variety,
  price,
  stock_status,
  status_text,
  updated_time,
  created_at,
  updated_at,
  note,
  latitude,
  longitude,
  reporter_id,
  is_approved
)
values
  (
    'DR001',
    'MK',
    'Gerai Durian Bukit Rotan',
    'Bukit Rotan, Kuala Selangor',
    'Musang King',
    'RM38/kg',
    'available',
    'Masih Ada',
    '12 min lepas',
    '2026-06-21 08:30:00+08',
    '2026-06-21 08:42:00+08',
    'Gerai tepi jalan utama. Stok nampak masih banyak.',
    3.3186,
    101.3129,
    null,
    true
  ),
  (
    'DR002',
    'D24',
    'Durian Tepi Jalan Assam Jawa',
    'Assam Jawa, Selangor',
    'D24',
    'RM28/kg',
    'low_stock',
    'Stok Sikit',
    '25 min lepas',
    '2026-06-21 08:15:00+08',
    '2026-06-21 08:35:00+08',
    'Pilihan D24 masih ada tetapi tidak banyak.',
    3.3408,
    101.2506,
    null,
    true
  ),
  (
    'DR003',
    'KG',
    'Durian Kampung Fresh',
    'Kuala Selangor',
    'Kampung',
    'RM15/kg',
    'available',
    'Masih Ada',
    '2 jam lepas',
    '2026-06-21 06:45:00+08',
    '2026-06-21 07:15:00+08',
    'Harga paling murah dalam dummy data buat masa ini.',
    3.3496,
    101.2460,
    null,
    true
  ),
  (
    'DR004',
    'Habis',
    'Warung Durian Bestari',
    'Puncak Alam',
    'XO',
    'RM22/kg',
    'sold_out',
    'Dah Habis',
    '1 jam lepas',
    '2026-06-21 07:10:00+08',
    '2026-06-21 08:05:00+08',
    'Stok XO habis untuk sesi pagi.',
    3.2254,
    101.4271,
    null,
    true
  )
on conflict (id) do update set
  marker_label = excluded.marker_label,
  stall_name = excluded.stall_name,
  area = excluded.area,
  variety = excluded.variety,
  price = excluded.price,
  stock_status = excluded.stock_status,
  status_text = excluded.status_text,
  updated_time = excluded.updated_time,
  created_at = excluded.created_at,
  updated_at = excluded.updated_at,
  note = excluded.note,
  latitude = excluded.latitude,
  longitude = excluded.longitude,
  reporter_id = excluded.reporter_id,
  is_approved = excluded.is_approved;