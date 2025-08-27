// lib/core/config/app_config.dart
class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue:
        'https://your-project.supabase.co', // Replace with your actual URL
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key-here', // Replace with your actual anon key
  );

  // Google Maps Configuration
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue:
        'your-google-maps-api-key', // Replace with your actual API key
  );

  // OneSignal Configuration (for push notifications)
  static const String oneSignalAppId = String.fromEnvironment(
    'ONESIGNAL_APP_ID',
    defaultValue: 'your-onesignal-app-id',
  );

  // Payment Gateway Configuration
  static const String waveApiKey = String.fromEnvironment(
    'WAVE_API_KEY',
    defaultValue: 'your-wave-api-key',
  );

  static const String orangeMoneyApiKey = String.fromEnvironment(
    'ORANGE_MONEY_API_KEY',
    defaultValue: 'your-orange-money-api-key',
  );

  static const String mtnMoneyApiKey = String.fromEnvironment(
    'MTN_MONEY_API_KEY',
    defaultValue: 'your-mtn-money-api-key',
  );

  // App Configuration
  static const String appName = 'Le Livreur Pro';
  static const String appVersion = '1.0.0+1';
  static const bool isProduction =
      bool.fromEnvironment('PRODUCTION', defaultValue: false);

  // Business Configuration for Côte d'Ivoire
  static const String defaultCountryCode = '+225';
  static const String defaultCurrency = 'XOF'; // CFA Franc
  static const String defaultLanguage = 'fr'; // French default
  static const double platformCommissionRate = 0.10; // 10% commission

  // San-Pedro specific configuration
  static const double sanPedroLatitude = 4.7467;
  static const double sanPedroLongitude = -6.6364;
  static const double defaultDeliveryRadius = 15.0; // 15km radius
  static const int baseDeliveryPriceXof = 500; // Base delivery price in CFA
  static const double baseDeliveryZoneKm = 4.5; // Base zone in km

  // Validation helpers
  static bool get isValidSupabaseConfig {
    return supabaseUrl.isNotEmpty &&
        supabaseUrl != 'https://your-project.supabase.co' &&
        supabaseAnonKey.isNotEmpty &&
        supabaseAnonKey != 'your-anon-key-here';
  }

  static bool get isValidGoogleMapsConfig {
    return googleMapsApiKey.isNotEmpty &&
        googleMapsApiKey != 'your-google-maps-api-key';
  }

  // Environment-specific configurations
  static String get apiBaseUrl {
    if (isProduction) {
      return 'https://api.lelivreurpro.ci';
    } else {
      return 'https://dev-api.lelivreurpro.ci';
    }
  }

  static Duration get httpTimeout {
    return const Duration(seconds: 30);
  }

  static int get maxRetryAttempts {
    return isProduction ? 3 : 1;
  }
}
