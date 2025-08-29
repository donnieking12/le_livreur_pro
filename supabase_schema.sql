-- Le Livreur Pro Database Schema
-- Run this SQL in your Supabase SQL Editor
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
-- Create custom types
CREATE TYPE user_type AS ENUM ('customer', 'courier', 'partner', 'admin');
CREATE TYPE delivery_status AS ENUM (
    'pending',
    'assigned',
    'courier_en_route',
    'picked_up',
    'in_transit',
    'arrived_destination',
    'delivered',
    'cancelled',
    'disputed'
);
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
CREATE TYPE payment_method AS ENUM (
    'orange_money',
    'mtn_money',
    'moov_money',
    'wave',
    'cash_on_delivery'
);
CREATE TYPE order_type AS ENUM ('package', 'marketplace');
CREATE TYPE address_type AS ENUM ('home', 'work', 'other');
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    user_type user_type NOT NULL DEFAULT 'customer',
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    is_online BOOLEAN DEFAULT false,
    profile_image_url TEXT,
    preferred_language VARCHAR(5) DEFAULT 'fr',
    rating DECIMAL(3, 2) DEFAULT 0.0,
    total_orders INTEGER DEFAULT 0,
    total_deliveries INTEGER DEFAULT 0,
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- Addresses table
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    label VARCHAR(100) NOT NULL,
    full_address TEXT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    street_number VARCHAR(10),
    street_name VARCHAR(255),
    neighborhood VARCHAR(255),
    commune VARCHAR(255),
    city VARCHAR(255) NOT NULL,
    postal_code VARCHAR(10),
    nearby_landmark TEXT,
    additional_instructions TEXT,
    type address_type DEFAULT 'other',
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    contact_name VARCHAR(255),
    contact_phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- Restaurants table
CREATE TABLE restaurants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    description TEXT,
    business_address TEXT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    business_phone VARCHAR(20),
    business_email VARCHAR(255),
    business_registration_number VARCHAR(100),
    business_license_url TEXT,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    accepts_orders BOOLEAN DEFAULT true,
    preparation_time_minutes INTEGER DEFAULT 30,
    minimum_order_xof INTEGER DEFAULT 5000,
    delivery_fee_xof INTEGER DEFAULT 0,
    operating_hours JSONB,
    cuisine_types TEXT [] DEFAULT '{}',
    categories TEXT [] DEFAULT '{}',
    rating DECIMAL(3, 2) DEFAULT 0.0,
    total_orders INTEGER DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    logo_url TEXT,
    banner_url TEXT,
    gallery_urls TEXT [] DEFAULT '{}',
    last_order_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- Menu categories table
CREATE TABLE menu_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- Menu items table
CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    category_id UUID REFERENCES menu_categories(id) ON DELETE
    SET NULL,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        price_xof INTEGER NOT NULL,
        preparation_time_minutes INTEGER DEFAULT 15,
        image_url TEXT,
        is_available BOOLEAN DEFAULT true,
        is_featured BOOLEAN DEFAULT false,
        allergens TEXT [] DEFAULT '{}',
        ingredients TEXT [] DEFAULT '{}',
        nutritional_info JSONB,
        variations JSONB DEFAULT '[]',
        addons JSONB DEFAULT '[]',
        sort_order INTEGER DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- Delivery orders table
CREATE TABLE delivery_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    courier_id UUID REFERENCES users(id) ON DELETE
    SET NULL,
        restaurant_id UUID REFERENCES restaurants(id) ON DELETE
    SET NULL,
        order_type order_type NOT NULL,
        -- Package/item details
        package_description TEXT,
        package_value_xof INTEGER DEFAULT 0,
        fragile BOOLEAN DEFAULT false,
        requires_signature BOOLEAN DEFAULT false,
        -- Status and tracking
        status delivery_status DEFAULT 'pending',
        payment_status payment_status DEFAULT 'pending',
        priority_level INTEGER DEFAULT 1,
        -- Location details
        pickup_latitude DECIMAL(10, 8) NOT NULL,
        pickup_longitude DECIMAL(11, 8) NOT NULL,
        delivery_latitude DECIMAL(10, 8) NOT NULL,
        delivery_longitude DECIMAL(11, 8) NOT NULL,
        pickup_address TEXT NOT NULL,
        delivery_address TEXT NOT NULL,
        -- Pricing breakdown
        base_price_xof INTEGER NOT NULL,
        base_zone_radius_km DECIMAL(5, 2) DEFAULT 4.5,
        additional_distance_price_xof INTEGER DEFAULT 0,
        urgency_price_xof INTEGER DEFAULT 0,
        fragile_price_xof INTEGER DEFAULT 0,
        total_price_xof INTEGER NOT NULL,
        currency VARCHAR(5) DEFAULT 'XOF',
        -- Timing
        estimated_pickup_time TIMESTAMP WITH TIME ZONE,
        estimated_delivery_time TIMESTAMP WITH TIME ZONE,
        actual_pickup_time TIMESTAMP WITH TIME ZONE,
        actual_delivery_time TIMESTAMP WITH TIME ZONE,
        -- Contact details
        recipient_name VARCHAR(255) NOT NULL,
        recipient_phone VARCHAR(20) NOT NULL,
        recipient_email VARCHAR(255),
        -- Additional info
        special_instructions TEXT,
        payment_method payment_method NOT NULL,
        status_history JSONB DEFAULT '[]',
        -- Reviews and ratings
        customer_rating INTEGER CHECK (
            customer_rating >= 1
            AND customer_rating <= 5
        ),
        customer_review TEXT,
        courier_rating INTEGER CHECK (
            courier_rating >= 1
            AND courier_rating <= 5
        ),
        courier_review TEXT,
        -- Verification
        requires_id BOOLEAN DEFAULT false,
        photo_urls TEXT [] DEFAULT '{}',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- Order items table (for marketplace orders)
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES delivery_orders(id) ON DELETE CASCADE,
    menu_item_id UUID REFERENCES menu_items(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price_xof INTEGER NOT NULL,
    total_price_xof INTEGER NOT NULL,
    selected_variations JSONB DEFAULT '[]',
    selected_addons JSONB DEFAULT '[]',
    special_instructions TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES delivery_orders(id) ON DELETE CASCADE,
    payment_ref VARCHAR(100) UNIQUE NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    provider payment_method NOT NULL,
    status payment_status DEFAULT 'pending',
    amount_xof INTEGER NOT NULL,
    currency VARCHAR(5) DEFAULT 'XOF',
    external_transaction_id VARCHAR(255),
    provider_transaction_ref VARCHAR(255),
    customer_details JSONB,
    provider_details JSONB,
    failure_reason TEXT,
    processing_fee_xof INTEGER DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- User analytics table
CREATE TABLE user_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(100) NOT NULL,
    screen VARCHAR(100),
    metadata JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- Create indexes for better performance
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_is_online ON users(is_online)
WHERE user_type = 'courier';
CREATE INDEX idx_delivery_orders_customer ON delivery_orders(customer_id);
CREATE INDEX idx_delivery_orders_courier ON delivery_orders(courier_id);
CREATE INDEX idx_delivery_orders_status ON delivery_orders(status);
CREATE INDEX idx_delivery_orders_created_at ON delivery_orders(created_at);
CREATE INDEX idx_delivery_orders_order_number ON delivery_orders(order_number);
CREATE INDEX idx_restaurants_owner ON restaurants(owner_id);
CREATE INDEX idx_restaurants_location ON restaurants USING GIST(ST_Point(longitude, latitude));
CREATE INDEX idx_restaurants_is_active ON restaurants(is_active);
CREATE INDEX idx_menu_items_restaurant ON menu_items(restaurant_id);
CREATE INDEX idx_menu_items_category ON menu_items(category_id);
CREATE INDEX idx_menu_items_available ON menu_items(is_available);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);
-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_analytics ENABLE ROW LEVEL SECURITY;
-- Basic RLS policies (you can customize these based on your security requirements)
-- Users can read their own data
CREATE POLICY "Users can view own profile" ON users FOR
SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users FOR
UPDATE USING (auth.uid() = id);
-- Allow public read access to restaurants and menu items
CREATE POLICY "Public can view active restaurants" ON restaurants FOR
SELECT USING (is_active = true);
CREATE POLICY "Public can view menu categories" ON menu_categories FOR
SELECT USING (true);
CREATE POLICY "Public can view available menu items" ON menu_items FOR
SELECT USING (is_available = true);
-- Users can manage their own orders
CREATE POLICY "Users can view own orders" ON delivery_orders FOR
SELECT USING (
        auth.uid() = customer_id
        OR auth.uid() = courier_id
    );
-- Insert some initial data
INSERT INTO users (id, phone, full_name, user_type, is_verified)
VALUES (
        '00000000-0000-0000-0000-000000000001',
        '+22505000001',
        'Admin User',
        'admin',
        true
    ),
    (
        '00000000-0000-0000-0000-000000000002',
        '+22505000002',
        'Test Customer',
        'customer',
        true
    ),
    (
        '00000000-0000-0000-0000-000000000003',
        '+22505000003',
        'Test Courier',
        'courier',
        true
    ),
    (
        '00000000-0000-0000-0000-000000000004',
        '+22505000004',
        'Test Partner',
        'partner',
        true
    );