# 🚀 Le Livreur Pro - Advanced Features Setup Guide

## 📋 Overview

This guide will help you set up all the advanced features we've implemented for your delivery platform:

- ✅ **Supabase Backend Integration**
- ✅ **Google Maps & Location Services**
- ✅ **Payment Integration (Mobile Money + Cards)**
- ✅ **Push Notifications (Firebase)**
- ✅ **Analytics & User Behavior Tracking**

## 🔧 Prerequisites

- Flutter SDK 3.0.0 or higher
- Android Studio / VS Code
- Git
- Supabase account
- Google Cloud Platform account
- Firebase account

## 🗄️ 1. Supabase Backend Setup

### 1.1 Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note down your project URL and anon key

### 1.2 Database Schema

Run these SQL commands in your Supabase SQL editor:

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone VARCHAR(20) UNIQUE NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('customer', 'courier', 'partner', 'admin')),
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  preferred_language VARCHAR(5) DEFAULT 'fr',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Delivery orders table
CREATE TABLE delivery_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES users(id),
  courier_id UUID REFERENCES users(id),
  pickup_address TEXT NOT NULL,
  delivery_address TEXT NOT NULL,
  description TEXT,
  amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  payment_status VARCHAR(20) DEFAULT 'pending',
  estimated_delivery_time TIMESTAMP WITH TIME ZONE,
  actual_delivery_time TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payments table
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES delivery_orders(id),
  user_id UUID REFERENCES users(id),
  amount DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(50) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  transaction_id VARCHAR(100),
  error_message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notifications table
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  title VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50) NOT NULL,
  data JSONB,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Analytics tables
CREATE TABLE user_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  screen VARCHAR(100),
  metadata JSONB,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE order_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type VARCHAR(50) NOT NULL,
  order_id UUID REFERENCES delivery_orders(id),
  user_id UUID REFERENCES users(id),
  amount DECIMAL(10,2),
  metadata JSONB,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_events ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own orders" ON delivery_orders
  FOR SELECT USING (auth.uid() = customer_id OR auth.uid() = courier_id);

CREATE POLICY "Users can create orders" ON delivery_orders
  FOR INSERT WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "Couriers can update assigned orders" ON delivery_orders
  FOR UPDATE USING (auth.uid() = courier_id);
```

### 1.3 Update Environment Variables

Create a `.env` file in your project root:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Update `lib/core/services/supabase_service.dart`:

```dart
static const String _supabaseUrl = 'YOUR_SUPABASE_URL';
static const String _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

## 🗺️ 2. Google Maps Setup

### 2.1 Google Cloud Platform Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Directions API
   - Geocoding API

### 2.2 Get API Keys

1. Go to "Credentials" → "Create Credentials" → "API Key"
2. Restrict the key to your app's package name
3. Enable billing (required for these APIs)

### 2.3 Update Configuration

Update `lib/core/services/maps_service.dart`:

```dart
static const String _googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

### 2.4 Android Configuration

Update `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <application ...>
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
  </application>
  
  <!-- Location permissions -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <uses-permission android:name="android.permission.INTERNET" />
</manifest>
```

### 2.5 iOS Configuration

Update `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to provide delivery services</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to provide delivery services</string>
<key>io.flutter.embedded_views_preview</key>
<true/>
```

## 💳 3. Payment Integration Setup

### 3.1 Mobile Money APIs

#### Orange Money (Côte d'Ivoire)
1. Contact Orange Money for business partnership
2. Get API credentials and endpoints
3. Update `lib/core/services/payment_service.dart`

#### MTN MoMo (Côte d'Ivoire)
1. Contact MTN for business partnership
2. Get API credentials and endpoints
3. Update payment service

#### Moov Money (Côte d'Ivoire)
1. Contact Moov for business partnership
2. Get API credentials and endpoints
3. Update payment service

### 3.2 Card Payment Gateway

#### Option 1: Stripe
1. Create Stripe account
2. Get API keys
3. Add to payment service

#### Option 2: PayPal
1. Create PayPal Business account
2. Get API credentials
3. Add to payment service

### 3.3 Update Payment Service

Update the payment methods in `lib/core/services/payment_service.dart`:

```dart
// Replace placeholder implementations with real API calls
case 'orange_money':
  result = await _processOrangeMoneyPayment(
    amount: amount,
    phoneNumber: paymentDetails['phone_number'],
    paymentRef: paymentRef,
  );
  break;
```

## 🔔 4. Push Notifications Setup

### 4.1 Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project
3. Add Android and iOS apps
4. Download configuration files

### 4.2 Android Configuration

1. Place `google-services.json` in `android/app/`
2. Update `android/build.gradle`:

```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

3. Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
  implementation platform('com.google.firebase:firebase-bom:32.7.0')
  implementation 'com.google.firebase:firebase-messaging'
  implementation 'com.google.firebase:firebase-analytics'
}
```

### 4.3 iOS Configuration

1. Place `GoogleService-Info.plist` in `ios/Runner/`
2. Update `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 4.4 Update Notification Service

Update `lib/core/services/notification_service.dart` with your Firebase configuration.

## 📊 5. Analytics Setup

### 5.1 Firebase Analytics

Firebase Analytics is automatically configured with the previous setup.

### 5.2 Custom Analytics Dashboard

1. Create analytics views in Supabase
2. Set up data retention policies
3. Configure real-time dashboards

### 5.3 Update Analytics Service

Update `lib/core/services/analytics_service.dart` with your specific tracking requirements.

## 🚀 6. Running the App

### 6.1 Install Dependencies

```bash
flutter clean
flutter pub get
```

### 6.2 Generate Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 6.3 Run the App

```bash
# For web (recommended for testing)
flutter run -d chrome --web-port 8080

# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

## 🧪 7. Testing Features

### 7.1 Test Different User Profiles

In `lib/features/home/presentation/screens/home_screen.dart`, change the user type:

```dart
final User _currentUser = const User(
  id: '1',
  phone: '+2250700000000',
  fullName: 'John Doe',
  userType: UserType.courier, // Try: customer, courier, partner, admin
  createdAt: null,
  updatedAt: null,
);
```

### 7.2 Test Payment Methods

1. Navigate to order creation
2. Select different payment methods
3. Test with test credentials

### 7.3 Test Notifications

1. Enable notifications in app
2. Create test orders
3. Check notification delivery

### 7.4 Test Maps

1. Grant location permissions
2. Navigate to tracking screen
3. Test location services

## 🔒 8. Security Considerations

### 8.1 API Key Security

- Never commit API keys to version control
- Use environment variables
- Restrict API keys to specific domains/IPs

### 8.2 Data Privacy

- Implement proper user consent
- Follow GDPR/local privacy laws
- Secure sensitive user data

### 8.3 Payment Security

- Use HTTPS for all API calls
- Implement proper authentication
- Follow PCI DSS guidelines

## 📱 9. Mobile Testing with Chrome DevTools

### 9.1 Enable Device Simulation

1. Open Chrome DevTools (F12)
2. Click the device icon (📱)
3. Select device type (iPhone, Android, etc.)
4. Test responsive design

### 9.2 Test Touch Events

1. Enable touch simulation
2. Test gestures and interactions
3. Verify mobile-specific features

### 9.3 Performance Testing

1. Use Lighthouse for performance audit
2. Test on different network conditions
3. Monitor memory usage

## 🚨 10. Troubleshooting

### Common Issues

1. **Maps not loading**: Check API key and billing
2. **Notifications not working**: Verify Firebase setup
3. **Payment failures**: Check API credentials
4. **Location errors**: Verify permissions

### Debug Mode

Enable debug logging in services:

```dart
// Add to service files
static const bool _debugMode = true;

if (_debugMode) {
  print('Debug: $message');
}
```

## 📞 11. Support & Resources

- **Flutter Documentation**: [flutter.dev](https://flutter.dev)
- **Supabase Documentation**: [supabase.com/docs](https://supabase.com/docs)
- **Google Maps API**: [developers.google.com/maps](https://developers.google.com/maps)
- **Firebase Documentation**: [firebase.google.com/docs](https://firebase.google.com/docs)

## 🎯 12. Next Steps

1. **Production Deployment**: Deploy to app stores
2. **Monitoring**: Set up crash reporting and monitoring
3. **Scaling**: Optimize for high user loads
4. **Features**: Add more advanced features like:
   - Real-time chat
   - Advanced routing algorithms
   - Multi-language support expansion
   - AI-powered delivery optimization

---

**🎉 Congratulations!** Your Le Livreur Pro app now has enterprise-grade features ready for the Côte d'Ivoire market.

**Built with ❤️ for Côte d'Ivoire's delivery ecosystem**
