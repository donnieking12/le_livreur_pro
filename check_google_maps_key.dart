import 'dart:io';

void main() {
  print('Checking Google Maps API Key...');

  // Check if .env file exists
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ .env file not found');
    return;
  }

  // Read the .env file
  final lines = envFile.readAsLinesSync();

  String? googleMapsKey;

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

      if (key == 'GOOGLE_MAPS_API_KEY') {
        googleMapsKey = value;
      }
    }
  }

  if (googleMapsKey != null) {
    print('Google Maps API Key found: $googleMapsKey');

    if (googleMapsKey.startsWith('AIza')) {
      print('✅ Google Maps API Key appears to be valid');
    } else {
      print('❌ Google Maps API Key does not appear to be valid');
    }
  } else {
    print('❌ Google Maps API Key not found in .env file');
  }
}
