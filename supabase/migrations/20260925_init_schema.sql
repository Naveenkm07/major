-- Supabase Migration: 20260925_init_schema.sql
-- This creates the relational equivalent of the MongoDB collections.

-- 1. Profiles (replaces Farmer)
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    name TEXT NOT NULL,
    phone_number TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE,
    village TEXT,
    district TEXT,
    state TEXT,
    farm_size NUMERIC,
    crop_types TEXT[] DEFAULT '{}',
    soil_type TEXT,
    irrigation_type TEXT,
    preferred_language TEXT DEFAULT 'en',
    avatar TEXT DEFAULT 'default-avatar.png',
    fcm_token TEXT,
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Equipment (Marketplace)
CREATE TABLE equipment (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    owner_name TEXT NOT NULL,
    description TEXT,
    price_per_hour NUMERIC NOT NULL,
    availability BOOLEAN DEFAULT true,
    village TEXT,
    district TEXT,
    state TEXT,
    contact_phone TEXT NOT NULL,
    images TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Market Prices
CREATE TABLE market_prices (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    state TEXT NOT NULL,
    district TEXT NOT NULL,
    market TEXT NOT NULL,
    commodity TEXT NOT NULL,
    variety TEXT,
    min_price NUMERIC,
    max_price NUMERIC,
    modal_price NUMERIC,
    arrival_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Pest Scans
CREATE TABLE pest_scans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    farmer_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    detected_disease TEXT,
    confidence NUMERIC,
    recommendation TEXT,
    scan_date TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Government Schemes
CREATE TABLE schemes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    eligibility TEXT,
    benefits TEXT,
    application_link TEXT,
    state TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipment ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles are viewable by everyone." ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile." ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile." ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Equipment is viewable by everyone." ON equipment FOR SELECT USING (true);
CREATE POLICY "Users can insert their own equipment." ON equipment FOR INSERT WITH CHECK (auth.uid() = owner_id);
