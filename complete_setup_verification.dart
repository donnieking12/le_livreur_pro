import 'dart:io';
import 'package:le_livreur_pro/core/config/app_config.dart';

void main() async {
  print('=== Le Livreur Pro - Complete Setup Verification ===\n');
  
  int totalChecks = 0;
  int passedChecks = 0;

  // Check 1: Flutter environment
  totalChecks++;
  try {
    final flutterVersionResult = Process.runSync('flutter', ['--version']);
    if (flutterVersionResult.exitCode == 0) {
      print('✅ Flutter environment: OK');
      passedChecks++;
    } else {
      print('❌ Flutter environment: FAILED');
    }
  } catch (e) {
    print('❌ Flutter environment: NOT FOUND');
  }

  // Check 2: Project dependencies
  totalChecks++;
  try {
    final pubGetResult = Process.runSync('flutter', ['pub', 'get']);
    if (pubGetResult.exitCode == 0) {
      print('✅ Project dependencies: INSTALLED');
      passedChecks++;
    } else {
      print('❌ Project dependencies: INSTALLATION FAILED');
    }
  } catch (e) {
    print('❌ Project dependencies: NOT INSTALLED');
  }

  // Check 3: Environment file
  totalChecks++;
  final envFile = File('.env');
  if (envFile.existsSync()) {
    print('✅ Environment file (.env): EXISTS');
    passedChecks++;
  } else {
    print('❌ Environment file (.env): MISSING');
  }

  // Check 4: Configuration loading
  totalChecks++;
  try {
    await AppConfig.init();
    print('✅ Configuration loading: SUCCESS');
    passedChecks++;
  } catch (e) {
    print('❌ Configuration loading: FAILED - $e');
  }

  // Check 5: Supabase configuration
  totalChecks++;
  if (AppConfig.isValidSupabaseConfig) {
    print('✅ Supabase configuration: VALID');
    passedChecks++;
  } else {
    print('❌ Supabase configuration: INVALID');
  }

  // Check 6: Asset directories
  totalChecks++;
  final requiredDirs = [
    'assets',
    'assets/icons',
    'assets/images',
    'assets/images/delivery',
    'assets/images/payment',
    'assets/lottie',
    'assets/translations'
  ];
  
  bool allDirsExist = true;
  for (final dirPath in requiredDirs) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      allDirsExist = false;
      break;
    }
  }
  
  if (allDirsExist) {
    print('✅ Asset directories: ALL EXIST');
    passedChecks++;
  } else {
    print('❌ Asset directories: SOME MISSING');
  }

  // Check 7: Translation files
  totalChecks++;
  final translationFiles = [
    'assets/translations/en.json',
    'assets/translations/fr.json'
  ];
  
  bool allFilesExist = true;
  for (final filePath in translationFiles) {
    final file = File(filePath);
    if (!file.existsSync()) {
      allFilesExist = false;
      break;
    }
  }
  
  if (allFilesExist) {
    print('✅ Translation files: ALL EXIST');
    passedChecks++;
  } else {
    print('❌ Translation files: SOME MISSING');
  }

  // Check 8: Visual Studio (Windows development)
  totalChecks++;
  try {
    final flutterDoctorResult = Process.runSync('flutter', ['doctor']);
    final output = flutterDoctorResult.stdout.toString();
    if (output.contains('Visual Studio') && output.contains('√')) {
      print('✅ Visual Studio: INSTALLED');
      passedChecks++;
    } else {
      print('❌ Visual Studio: NOT INSTALLED or NOT PROPERLY CONFIGURED');
    }
  } catch (e) {
    print('❌ Visual Studio check: FAILED');
  }

  print('\n=== Verification Summary ===');
  print('Passed: $passedChecks/$totalChecks checks');
  
  final percentage = (passedChecks / totalChecks * 100).round();
  print('Completion: $percentage%');
  
  if (passedChecks == totalChecks) {
    print('🎉 All checks passed! Your development environment is ready.');
  } else if (passedChecks >= totalChecks * 0.8) {
    print('✅ Most checks passed. Your environment is mostly ready with minor issues.');
  } else {
    print('⚠️  Several checks failed. Please review the issues above.');
  }
  
  print('\n=== Complete Setup Verification Complete ===');
}