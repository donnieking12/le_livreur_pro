import 'package:le_livreur_pro/core/config/app_config.dart';

void main() {
  print('=== Le Livreur Pro Configuration Verification ===\n');

  // Check Supabase configuration
  print('Supabase Configuration:');
  print('  URL: ${AppConfig.supabaseUrl}');
  print('  Anon Key: ${AppConfig.supabaseAnonKey}');
  print('  Valid: ${AppConfig.isValidSupabaseConfig}\n');

  // Check other configurations
  print('Google Maps Configuration:');
  print('  API Key: ${AppConfig.googleMapsApiKey}');
  print('  Valid: ${AppConfig.isValidGoogleMapsConfig}\n');

  // Check payment configurations
  print('Payment Gateway Configuration:');
  print('  Wave API Key: ${AppConfig.waveApiKey}');
  print('  Orange Money API Key: ${AppConfig.orangeMoneyApiKey}');
  print('  MTN Money API Key: ${AppConfig.mtnMoneyApiKey}\n');

  // Check app configuration
  print('App Configuration:');
  print('  App Name: ${AppConfig.appName}');
  print('  App Version: ${AppConfig.appVersion}');
  print('  Production Mode: ${AppConfig.isProduction}\n');

  // Check business configuration
  print('Business Configuration:');
  print('  Default Country Code: ${AppConfig.defaultCountryCode}');
  print('  Default Currency: ${AppConfig.defaultCurrency}');
  print('  Default Language: ${AppConfig.defaultLanguage}');
  print('  Platform Commission Rate: ${AppConfig.platformCommissionRate}\n');

  print('=== Configuration Verification Complete ===');
}
