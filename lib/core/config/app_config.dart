// lib/core/config/app_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Load environment variables from .env file
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  // Supabase Configuration
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://demo.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'demo-key';

  static String get supabaseServiceRoleKey =>
      dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? 'demo-service-key';

  // Google Maps Configuration
  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'your-google-maps-api-key';

  // OneSignal Configuration (for push notifications)
  static String get oneSignalAppId =>
      dotenv.env['ONESIGNAL_APP_ID'] ?? 'your-onesignal-app-id';

  // Payment Gateway Configuration
  static String get waveApiKey =>
      dotenv.env['WAVE_API_KEY'] ?? 'your-wave-api-key';

  static String get orangeMoneyApiKey =>
      dotenv.env['ORANGE_MONEY_API_KEY'] ?? 'your-orange-money-api-key';

  static String get mtnMoneyApiKey =>
      dotenv.env['MTN_MONEY_API_KEY'] ?? 'your-mtn-money-api-key';

  // App Configuration
  static const String appName = 'Le Livreur Pro';
  static const String appVersion = '1.0.0+1';
  static bool get isProduction =>
      (dotenv.env['PRODUCTION'] ?? 'false') == 'true';

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
    final url = dotenv.env['SUPABASE_URL'] ?? 'https://demo.supabase.co';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? 'demo-key';

    return url.isNotEmpty &&
        !url.contains('demo.supabase.co') &&
        !url.contains('your-project.supabase.co') &&
        key.isNotEmpty &&
        key != 'demo-key' &&
        key != 'your-anon-key-here' &&
        key.startsWith('eyJ'); // JWT format validation
  }

  static bool get isValidGoogleMapsConfig {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'your-google-maps-api-key';
    return key.isNotEmpty && key != 'your-google-maps-api-key';
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
