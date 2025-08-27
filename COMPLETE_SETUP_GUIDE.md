# 🚀 Le Livreur Pro - Complete Setup Guide

This guide will help you set up the development environment for Le Livreur Pro MVP.

## 📋 Prerequisites

- Flutter SDK 3.0.0+
- Dart SDK 3.0.0+
- Android Studio / VS Code
- Git
- Node.js (for Supabase CLI)

## 🔧 1. Supabase Backend Setup

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Choose region closest to Côte d'Ivoire (Europe West recommended)
4. Copy your project URL and anon key

### Step 2: Database Schema Setup

Run the following SQL in your Supabase SQL editor:

```sql
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Create enum types
CREATE TYPE user_type AS ENUM ('customer', 'courier', 'partner', 'admin');
CREATE TYPE delivery_status AS ENUM ('pending', 'assigned', 'courier_en_route', 'picked_up', 'in_transit', 'arrived_destination', 'delivered', 'cancelled', 'disputed');
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
CREATE TYPE payment_method AS ENUM ('orange_money', 'mtn_money', 'moov_money', 'wave', 'cash_on_delivery');
CREATE TYPE order_type AS ENUM ('package', 'marketplace');
CREATE TYPE address_type AS ENUM ('home', 'work', 'other');

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    user_type user_type NOT NULL DEFAULT 'customer',
    email TEXT,
    profile_image_url TEXT,
    preferred_language TEXT DEFAULT 'fr',
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    last_login_at TIMESTAMPTZ,
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    is_online BOOLEAN DEFAULT false,
    rating DECIMAL(3, 2) DEFAULT 0.0,
    total_deliveries INTEGER DEFAULT 0,
    vehicle_type TEXT,
    driver_license_url TEXT,
    national_id_url TEXT,
    restaurant_id UUID,
    business_address TEXT,
    business_registration_url TEXT,
    fcm_token TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Restaurants table
CREATE TABLE restaurants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    business_address TEXT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    business_phone TEXT,
    business_email TEXT,
    business_registration_number TEXT,
    business_license_url TEXT,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    accepts_orders BOOLEAN DEFAULT true,
    preparation_time_minutes INTEGER DEFAULT 30,
    minimum_order_xof INTEGER DEFAULT 5000,
    delivery_fee_xof INTEGER DEFAULT 0,
    operating_hours JSONB,
    cuisine_types TEXT[] DEFAULT '{}',
    categories TEXT[] DEFAULT '{}',
    rating DECIMAL(3, 2) DEFAULT 0.0,
    total_orders INTEGER DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    logo_url TEXT,
    banner_url TEXT,
    gallery_urls TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_order_at TIMESTAMPTZ
);

-- Menu categories table
CREATE TABLE menu_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    icon_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Menu items table
CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    price_xof INTEGER NOT NULL,
    category_id UUID REFERENCES menu_categories(id),
    category_name TEXT,
    is_available BOOLEAN DEFAULT true,
    is_popular BOOLEAN DEFAULT false,
    is_spicy BOOLEAN DEFAULT false,
    is_vegetarian BOOLEAN DEFAULT false,
    is_vegan BOOLEAN DEFAULT false,
    is_halal BOOLEAN DEFAULT false,
    has_unlimited_stock BOOLEAN DEFAULT true,
    stock_quantity INTEGER DEFAULT 0,
    minimum_order_quantity INTEGER DEFAULT 0,
    ingredients TEXT,
    allergens TEXT,
    calories INTEGER,
    preparation_time_minutes INTEGER,
    variations JSONB DEFAULT '[]',
    addons JSONB DEFAULT '[]',
    image_url TEXT,
    gallery_urls TEXT[] DEFAULT '{}',
    rating DECIMAL(3, 2) DEFAULT 0.0,
    total_orders INTEGER DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Addresses table
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    full_address TEXT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    street_number TEXT,
    street_name TEXT,
    neighborhood TEXT,
    commune TEXT,
    city TEXT,
    postal_code TEXT,
    nearby_landmark TEXT,
    additional_instructions TEXT,
    type address_type NOT NULL,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    contact_name TEXT,
    contact_phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Delivery orders table
CREATE TABLE delivery_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number TEXT UNIQUE NOT NULL,
    customer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    courier_id UUID REFERENCES users(id),
    partner_id UUID REFERENCES users(id),
    restaurant_id UUID REFERENCES restaurants(id),
    order_type order_type NOT NULL,
    package_description TEXT,
    package_value_xof INTEGER DEFAULT 0,
    fragile BOOLEAN DEFAULT false,
    requires_signature BOOLEAN DEFAULT false,
    cart JSONB,
    items JSONB DEFAULT '[]',
    status delivery_status NOT NULL DEFAULT 'pending',
    payment_status payment_status NOT NULL DEFAULT 'pending',
    priority_level INTEGER DEFAULT 1,
    pickup_latitude DECIMAL(10, 8) NOT NULL,
    pickup_longitude DECIMAL(11, 8) NOT NULL,
    delivery_latitude DECIMAL(10, 8) NOT NULL,
    delivery_longitude DECIMAL(11, 8) NOT NULL,
    pickup_address TEXT,
    delivery_address TEXT,
    base_price_xof INTEGER DEFAULT 500,
    base_zone_radius_km DECIMAL(5, 2) DEFAULT 4.5,
    additional_distance_price_xof INTEGER DEFAULT 0,
    urgency_price_xof INTEGER DEFAULT 0,
    fragile_price_xof INTEGER DEFAULT 0,
    total_price_xof INTEGER NOT NULL,
    currency TEXT DEFAULT 'XOF',
    estimated_pickup_time TIMESTAMPTZ,
    estimated_delivery_time TIMESTAMPTZ,
    actual_pickup_time TIMESTAMPTZ,
    actual_delivery_time TIMESTAMPTZ,
    recipient_name TEXT NOT NULL,
    recipient_phone TEXT NOT NULL,
    recipient_email TEXT,
    special_instructions TEXT,
    payment_method payment_method NOT NULL,
    status_history JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_restaurants_location ON restaurants USING GIST(point(longitude, latitude));
CREATE INDEX idx_restaurants_categories ON restaurants USING GIN(categories);
CREATE INDEX idx_menu_items_restaurant_id ON menu_items(restaurant_id);
CREATE INDEX idx_delivery_orders_customer_id ON delivery_orders(customer_id);
CREATE INDEX idx_delivery_orders_courier_id ON delivery_orders(courier_id);
CREATE INDEX idx_delivery_orders_status ON delivery_orders(status);
CREATE INDEX idx_addresses_user_id ON addresses(user_id);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_orders ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (basic examples - customize as needed)
CREATE POLICY "Users can view their own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Public restaurants are viewable by everyone" ON restaurants FOR SELECT USING (is_active = true AND is_verified = true);
CREATE POLICY "Partners can manage their restaurants" ON restaurants FOR ALL USING (auth.uid() = owner_id);
CREATE POLICY "Public menu items are viewable by everyone" ON menu_items FOR SELECT USING (is_available = true);
CREATE POLICY "Users can view their own addresses" ON addresses FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own addresses" ON addresses FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view their own orders" ON delivery_orders FOR SELECT USING (auth.uid() = customer_id OR auth.uid() = courier_id);
```

### Step 3: Configure Environment Variables

Create a `.env` file in your project root:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
ONESIGNAL_APP_ID=your-onesignal-app-id
WAVE_API_KEY=your-wave-api-key
ORANGE_MONEY_API_KEY=your-orange-money-api-key
MTN_MONEY_API_KEY=your-mtn-money-api-key
PRODUCTION=false
```

## 🗺️ 2. Google Maps Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Maps JavaScript API
   - Places API
   - Directions API
   - Geocoding API
4. Create API credentials and add your API key to `.env`

### Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_API_KEY_HERE"/>
```

### iOS Configuration

Add to `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 🔐 3. Authentication Setup

The app uses phone-based authentication. Configure in Supabase:

1. Go to Authentication > Settings
2. Enable Phone provider
3. Configure SMS provider (Twilio recommended for Côte d'Ivoire)
4. Set up custom SMS templates in French

## 💳 4. Payment Integration Setup

### Wave API (Recommended for Côte d'Ivoire)

1. Register at [wave.com](https://wave.com) for business account
2. Get API credentials
3. Configure webhook endpoints

### Orange Money & MTN Money

1. Contact Orange Côte d'Ivoire and MTN for API access
2. Complete merchant onboarding process
3. Get API credentials and configure sandbox environment

## 🔔 5. Push Notifications Setup

1. Create OneSignal account
2. Add your app
3. Configure for both Android and iOS
4. Add OneSignal App ID to environment variables

## 🏃‍♂️ 6. Running the Application

```bash
# Install dependencies
flutter pub get

# Generate code (for Freezed models)
dart run build_runner build --delete-conflicting-outputs

# Run on web (for testing)
flutter run -d chrome --web-port 8080

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios
```

## 🧪 7. Testing Setup

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run web tests
flutter test --platform chrome
```

## 📱 8. Production Setup

### Android

1. Configure signing keys
2. Update `android/app/build.gradle` with release configuration
3. Build: `flutter build apk --release`

### iOS

1. Configure provisioning profiles
2. Update `ios/Runner.xcodeproj` settings
3. Build: `flutter build ios --release`

### Web

1. Configure Firebase Hosting or similar
2. Build: `flutter build web --release`

## 🔧 9. CI/CD with Codemagic

The project includes `codemagic.yaml` configuration. Update it with your:

- Supabase credentials
- Google Maps API key
- Signing certificates
- Distribution settings

## 📊 10. Monitoring & Analytics

1. Set up Supabase Analytics
2. Configure crash reporting
3. Set up performance monitoring
4. Create admin dashboards for business metrics

## 🚀 Next Steps

After setup:

1. Test the marketplace interface
2. Configure real restaurant data
3. Test payment flows
4. Set up courier onboarding
5. Configure admin panels
6. Launch pilot in San-Pedro

## 🆘 Troubleshooting

### Common Issues:

- **Build failures**: Check Flutter and Dart versions
- **Network errors**: Verify API keys and endpoints
- **Permission issues**: Check Android/iOS permissions in manifests
- **Database errors**: Verify RLS policies and authentication

For support, check the project documentation or create an issue in the repository.
