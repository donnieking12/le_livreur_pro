import 'dart:io';
import 'package:le_livreur_pro/core/config/app_config.dart';

void main() async {
  print('=== Le Livreur Pro Simple Configuration Check ===');

  // Initialize the configuration
  await AppConfig.init();

  // Check if .env file exists
  final envFile = File('.env');
  if (envFile.existsSync()) {
    print('✅ .env file exists');
  } else {
    print('❌ .env file not found');
    print('   Please create a .env file with your configuration');
    return;
  }

  // Display configuration
  print('\n--- Configuration Values ---');
  print('SUPABASE_URL: ${AppConfig.supabaseUrl}');
  print('SUPABASE_ANON_KEY: ${AppConfig.supabaseAnonKey}');
  print('GOOGLE_MAPS_API_KEY: ${AppConfig.googleMapsApiKey}');

  // Check if configuration is valid
  print('\n--- Validation Results ---');
  if (AppConfig.isValidSupabaseConfig) {
    print('✅ Supabase configuration is VALID');
  } else {
    print('❌ Supabase configuration is INVALID');
    if (AppConfig.supabaseUrl.contains('demo') ||
        AppConfig.supabaseUrl.contains('your-project')) {
      print('   - SUPABASE_URL is still using a placeholder value');
    }
    if (AppConfig.supabaseAnonKey == 'demo-key' ||
        AppConfig.supabaseAnonKey.startsWith('ey') == false) {
      print('   - SUPABASE_ANON_KEY is still using a placeholder value');
    }
  }

  if (AppConfig.isValidGoogleMapsConfig) {
    print('✅ Google Maps configuration is VALID');
  } else {
    print('⚠️  Google Maps configuration is using placeholder value');
    print('   - GOOGLE_MAPS_API_KEY needs to be set for map functionality');
  }

  print('\n--- Next Steps ---');
  if (!AppConfig.isValidSupabaseConfig) {
    print('1. Update your .env file with real Supabase credentials');
    print('   - Get your Project URL and Anon Key from Supabase dashboard');
  }
  if (!AppConfig.isValidGoogleMapsConfig) {
    print('2. Get a Google Maps API key and update your .env file');
    print('   - Visit https://console.cloud.google.com/');
  }

  print('\n=== Configuration Check Complete ===');
}
