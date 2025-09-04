import 'dart:io';
import 'package:le_livreur_pro/core/config/app_config.dart';

void main() {
  print('=== Le Livreur Pro Setup Checker ===\n');

  // Check if .env file exists
  final envFile = File('.env');
  if (envFile.existsSync()) {
    print('✅ .env file exists');
  } else {
    print('❌ .env file not found');
    print('   Please create .env file with your configuration');
    return;
  }

  // Check Supabase configuration
  print('\n--- Supabase Configuration ---');
  print('SUPABASE_URL: ${AppConfig.supabaseUrl}');
  print('SUPABASE_ANON_KEY: ${AppConfig.supabaseAnonKey}');

  if (AppConfig.isValidSupabaseConfig) {
    print('✅ Supabase configuration is valid');
  } else {
    print('❌ Supabase configuration is invalid');
    if (AppConfig.supabaseUrl.contains('demo.supabase.co')) {
      print('   - Using demo URL instead of real Supabase URL');
    }
    if (AppConfig.supabaseAnonKey == 'demo-key' ||
        AppConfig.supabaseAnonKey.startsWith('ey') == false) {
      print('   - Invalid anon key format');
    }
  }

  // Check other configurations
  print('\n--- Other Configuration ---');
  print('GOOGLE_MAPS_API_KEY: ${AppConfig.googleMapsApiKey}');
  if (AppConfig.isValidGoogleMapsConfig) {
    print('✅ Google Maps configuration is valid');
  } else {
    print('⚠️  Google Maps configuration is not set (optional for now)');
  }

  // App information
  print('\n--- App Information ---');
  print('App Name: ${AppConfig.appName}');
  print('App Version: ${AppConfig.appVersion}');
  print('Production Mode: ${AppConfig.isProduction}');

  // Business configuration
  print('\n--- Business Configuration ---');
  print('Default Country Code: ${AppConfig.defaultCountryCode}');
  print('Default Currency: ${AppConfig.defaultCurrency}');
  print('Default Language: ${AppConfig.defaultLanguage}');
  print('Platform Commission Rate: ${AppConfig.platformCommissionRate}');

  print('\n=== Setup Check Complete ===');
  print('\nNext steps:');
  print('1. Execute database schema in Supabase SQL Editor');
  print('2. Run: dart test_supabase_connection.dart');
  print('3. Configure Google Maps API key');
  print('4. Run: flutter pub get');
  print('5. Run: flutter run');
}
