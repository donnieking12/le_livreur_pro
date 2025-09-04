import 'dart:io';

void main() {
  print('=== Le Livreur Pro Simple .env Check ===');

  // Check if .env file exists
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ .env file not found');
    print('   Please create a .env file with your configuration');
    return;
  }

  print('✅ .env file exists');

  // Read the .env file
  final lines = envFile.readAsLinesSync();

  String? supabaseUrl;
  String? supabaseAnonKey;
  String? googleMapsApiKey;

  // Parse the .env file
  for (var line in lines) {
    line = line.trim();
    // Skip comments and empty lines
    if (line.startsWith('#') || line.isEmpty) {
      continue;
    }

    // Parse key=value pairs
    if (line.contains('=')) {
      final parts = line.split('=');
      final key = parts[0].trim();
      final value = parts.length > 1 ? parts[1].trim() : '';

      if (key == 'SUPABASE_URL') {
        supabaseUrl = value;
      } else if (key == 'SUPABASE_ANON_KEY') {
        supabaseAnonKey = value;
      } else if (key == 'GOOGLE_MAPS_API_KEY') {
        googleMapsApiKey = value;
      }
    }
  }

  // Display configuration
  print('\n--- Configuration Values ---');
  print('SUPABASE_URL: $supabaseUrl');
  print('SUPABASE_ANON_KEY: $supabaseAnonKey');
  print('GOOGLE_MAPS_API_KEY: $googleMapsApiKey');

  // Check if configuration is valid
  print('\n--- Validation Results ---');
  bool isValidSupabase = true;
  if (supabaseUrl != null &&
      supabaseUrl.isNotEmpty &&
      !supabaseUrl.contains('demo.supabase.co') &&
      !supabaseUrl.contains('your-project')) {
    print('✅ Supabase URL is VALID');
  } else {
    print('❌ Supabase URL is INVALID');
    isValidSupabase = false;
    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      print('   - SUPABASE_URL is missing');
    } else if (supabaseUrl.contains('demo') ||
        supabaseUrl.contains('your-project')) {
      print('   - SUPABASE_URL is still using a placeholder value');
    }
  }

  if (supabaseAnonKey != null &&
      supabaseAnonKey.isNotEmpty &&
      supabaseAnonKey != 'demo-key' &&
      supabaseAnonKey.startsWith('ey')) {
    print('✅ Supabase Anon Key is VALID');
  } else {
    print('❌ Supabase Anon Key is INVALID');
    isValidSupabase = false;
    if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      print('   - SUPABASE_ANON_KEY is missing');
    } else if (supabaseAnonKey == 'demo-key') {
      print('   - SUPABASE_ANON_KEY is still using a placeholder value');
    } else if (!supabaseAnonKey.startsWith('ey')) {
      print('   - SUPABASE_ANON_KEY does not appear to be a valid JWT');
    }
  }

  if (googleMapsApiKey != null &&
      googleMapsApiKey.isNotEmpty &&
      googleMapsApiKey != 'your-google-maps-api-key') {
    print('✅ Google Maps API Key is VALID');
  } else {
    print('⚠️  Google Maps API Key is using placeholder value');
    if (googleMapsApiKey == null || googleMapsApiKey.isEmpty) {
      print('   - GOOGLE_MAPS_API_KEY is missing');
    } else if (googleMapsApiKey == 'your-google-maps-api-key') {
      print('   - GOOGLE_MAPS_API_KEY needs to be set for map functionality');
    }
  }

  print('\n=== Configuration Check Complete ===');
}
