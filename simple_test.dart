import 'dart:io';

void main() {
  print('🧪 Simple Dart Test');
  print('✅ Dart is working correctly');
  print('📁 Current directory: ${Directory.current.path}');
  
  // Check if key files exist
  final schemaFile = File('supabase_schema.sql');
  final pubspecFile = File('pubspec.yaml');
  
  print('📋 File check:');
  print('   supabase_schema.sql: ${schemaFile.existsSync() ? "✅" : "❌"}');
  print('   pubspec.yaml: ${pubspecFile.existsSync() ? "✅" : "❌"}');
}