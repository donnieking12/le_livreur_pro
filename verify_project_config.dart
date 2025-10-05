import 'dart:io';
import 'package:le_livreur_pro/core/config/app_config.dart';

void main() async {
  print('=== Le Livreur Pro - Project Configuration Verification ===\n');

  try {
    // Initialize the configuration
    await AppConfig.init();
    print('✅ Configuration loaded successfully\n');
    
    // Check if .env file exists
    final envFile = File('.env');
    if (envFile.existsSync()) {
      print('✅ .env file exists');
    } else {
      print('❌ .env file not found');
      print('   Please create a .env file with your configuration');
      return;
    }

    // Display and validate configuration
    print('--- Configuration Values ---');
    print('App Name: ${AppConfig.appName}');
    print('App Version: ${AppConfig.appVersion}');
    print('Production Mode: ${AppConfig.isProduction}');
    
    print('\n--- Supabase Configuration ---');
    print('SUPABASE_URL: ${AppConfig.supabaseUrl}');
    print('SUPABASE_ANON_KEY: ${AppConfig.supabaseAnonKey.substring(0, 20)}...');
    
    if (AppConfig.isValidSupabaseConfig) {
      print('✅ Supabase configuration is VALID');
    } else {
      print('❌ Supabase configuration is INVALID');
    }
    
    print('\n--- Google Maps Configuration ---');
    if (AppConfig.isValidGoogleMapsConfig) {
      print('✅ Google Maps configuration is VALID');
    } else {
      print('⚠️  Google Maps configuration is using placeholder value');
      print('   (This is fine for development, but needs real key for production)');
    }
    
    print('\n--- Business Configuration ---');
    print('Default Country Code: ${AppConfig.defaultCountryCode}');
    print('Default Currency: ${AppConfig.defaultCurrency}');
    print('Default Language: ${AppConfig.defaultLanguage}');
    print('Platform Commission Rate: ${AppConfig.platformCommissionRate}');
    
    print('\n--- Feature Flags ---');
    print('Push Notifications Enabled: ${AppConfig.isValidGoogleMapsConfig}');
    print('Location Tracking Enabled: ${AppConfig.isValidGoogleMapsConfig}');
    print('Payment Processing Enabled: ${AppConfig.isValidGoogleMapsConfig}');
    print('Analytics Enabled: ${AppConfig.isValidGoogleMapsConfig}');
    
    print('\n=== Configuration Verification Complete ===');
    
  } catch (e) {
    print('❌ Failed to load configuration: $e');
    print('\n=== Configuration Verification Failed ===');
  }
}