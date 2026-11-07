-- VitatrustHealth initial PostgreSQL schema (Supabase)
create extension if not exists pgcrypto;

create type public.app_role as enum ('owner','admin','pharmacist','sales_staff','inventory_staff','customer_support');
create type public.order_channel as enum ('online','in_store');
create type public.order_status as enum ('pending','awaiting_pharmacist_review','confirmed','processing','ready_for_pickup','dispatched','completed','cancelled');
create type public.payment_status as enum ('unpaid','pending','paid','failed','refunded');

create table public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text not null,
 phone text,
 role public.app_role not null default 'customer_support',
 is_active boolean not null default true,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.customers (
 id uuid primary key default gen_random_uuid(),
 auth_user_id uuid unique references auth.users(id) on delete set null,
 full_name text not null, phone text not null, email text,
 address_line text, city text, state text default 'Lagos',
 created_at timestamptz not null default now()
);

create table public.categories (
 id uuid primary key default gen_random_uuid(), name text not null unique,
 slug text not null unique, description text, is_active boolean not null default true
);

create table public.products (
 id uuid primary key default gen_random_uuid(),
 category_id uuid references public.categories(id), sku text unique,
 name text not null, slug text not null unique, description text,
 product_type text not null check (product_type in ('medicine','wellness','skincare','medical_supply','service')),
 requires_prescription boolean not null default false,
 pharmacist_review_required boolean not null default false,
 is_controlled_or_restricted boolean not null default false,
 is_active boolean not null default false,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.locations (
 id uuid primary key default gen_random_uuid(), name text not null,
 location_type text not null check (location_type in ('physical_pharmacy','warehouse')),
 address text, city text, state text, is_active boolean not null default true
);

create table public.inventory_batches (
 id uuid primary key default gen_random_uuid(), product_id uuid not null references public.products(id),
 location_id uuid not null references public.locations(id), batch_number text not null,
 expiry_date date, quantity_on_hand integer not null default 0 check (quantity_on_hand >= 0),
 cost_price_kobo bigint not null default 0, selling_price_kobo bigint not null default 0,
 received_at timestamptz not null default now(), unique(product_id,location_id,batch_number)
);

create table public.stock_movements (
 id uuid primary key default gen_random_uuid(), batch_id uuid not null references public.inventory_batches(id),
 movement_type text not null check (movement_type in ('opening','purchase','sale','return','adjustment','transfer_out','transfer_in','expired','damaged')),
 quantity_delta integer not null, reference text, notes text,
 performed_by uuid references public.profiles(id), created_at timestamptz not null default now()
);

create table public.orders (
 id uuid primary key default gen_random_uuid(), order_number text not null unique,
 customer_id uuid references public.customers(id), location_id uuid references public.locations(id),
 channel public.order_channel not null, status public.order_status not null default 'pending',
 payment_status public.payment_status not null default 'unpaid',
 subtotal_kobo bigint not null default 0, delivery_fee_kobo bigint not null default 0,
 total_kobo bigint not null default 0, currency char(3) not null default 'NGN',
 customer_notes text, reviewed_by uuid references public.profiles(id),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.order_items (
 id uuid primary key default gen_random_uuid(), order_id uuid not null references public.orders(id) on delete cascade,
 product_id uuid not null references public.products(id), quantity integer not null check (quantity > 0),
 unit_price_kobo bigint not null, line_total_kobo bigint not null
);

create table public.prescription_records (
 id uuid primary key default gen_random_uuid(), order_id uuid references public.orders(id),
 customer_id uuid not null references public.customers(id), file_path text,
 review_status text not null default 'pending' check (review_status in ('pending','approved','rejected','more_information_required')),
 reviewed_by uuid references public.profiles(id), review_notes text,
 created_at timestamptz not null default now(), reviewed_at timestamptz
);

create table public.payments (
 id uuid primary key default gen_random_uuid(), order_id uuid not null references public.orders(id),
 provider text not null, provider_reference text unique, amount_kobo bigint not null,
 currency char(3) not null default 'NGN', status public.payment_status not null default 'pending',
 paid_at timestamptz, created_at timestamptz not null default now()
);

create table public.audit_logs (
 id uuid primary key default gen_random_uuid(), actor_id uuid references public.profiles(id),
 action text not null, entity_type text not null, entity_id uuid,
 details jsonb not null default '{}'::jsonb, created_at timestamptz not null default now()
);

create index products_category_idx on public.products(category_id);
create index batches_product_location_idx on public.inventory_batches(product_id,location_id);
create index batches_expiry_idx on public.inventory_batches(expiry_date);
create index orders_created_idx on public.orders(created_at desc);
create index orders_customer_idx on public.orders(customer_id);
create index stock_movements_batch_idx on public.stock_movements(batch_id,created_at desc);

-- IMPORTANT: Enable RLS on every exposed table and add role/ownership policies
-- before connecting the public client or deploying. Do not expose service-role keys.
-- Prescription files must live in a private storage bucket with signed access.
