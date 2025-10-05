import 'dart:io';
import 'package:le_livreur_pro/core/config/app_config.dart';

void main() async {
  print('''
  _     _ _______ _______ _______ _     _  ______ _    _  _____   ______  _____  _______
  |_____| |_____| |  |  | |       |_____| |_____/  \\  /  |_____] |_____/ |_____]    |   
  |     | |     | |  |  | |_____  |     | |    \\_   \\/   |       |    \\_ |       ___|___
  ''');
  print('=== Le Livreur Pro - Final Setup Check ===\n');

  final checker = SetupChecker();
  await checker.runAllChecks();
  
  checker.printSummary();
}

class SetupChecker {
  int totalChecks = 0;
  int passedChecks = 0;
  final List<CheckResult> results = [];

  Future<void> runAllChecks() async {
    print('Running comprehensive setup verification...\n');
    
    // Check 1: Project structure
    checkProjectStructure();
    
    // Check 2: Flutter environment
    checkFlutterEnvironment();
    
    // Check 3: Dependencies
    checkDependencies();
    
    // Check 4: Environment file
    checkEnvironmentFile();
    
    // Check 5: Configuration loading
    await checkConfigurationLoading();
    
    // Check 6: Supabase configuration
    checkSupabaseConfig();
    
    // Check 7: Asset structure
    checkAssetStructure();
    
    // Check 8: Translation files
    checkTranslationFiles();
    
    // Check 9: Visual Studio (Windows)
    checkVisualStudio();
  }

  void checkProjectStructure() {
    totalChecks++;
    final requiredFiles = ['pubspec.yaml', 'lib/main.dart', 'README.md'];
    bool allExist = true;
    
    for (final file in requiredFiles) {
      if (!File(file).existsSync()) {
        allExist = false;
        break;
      }
    }
    
    if (allExist) {
      results.add(CheckResult('Project Structure', true, 'All required files present'));
      passedChecks++;
    } else {
      results.add(CheckResult('Project Structure', false, 'Some required files missing'));
    }
  }

  void checkFlutterEnvironment() {
    totalChecks++;
    try {
      final result = Process.runSync('flutter', ['--version']);
      if (result.exitCode == 0) {
        results.add(CheckResult('Flutter Environment', true, 'Flutter is installed and accessible'));
        passedChecks++;
      } else {
        results.add(CheckResult('Flutter Environment', false, 'Flutter command failed'));
      }
    } catch (e) {
      results.add(CheckResult('Flutter Environment', false, 'Flutter not found in PATH'));
    }
  }

  void checkDependencies() {
    totalChecks++;
    final pubspecLock = File('pubspec.lock');
    if (pubspecLock.existsSync()) {
      results.add(CheckResult('Dependencies', true, 'pubspec.lock exists (dependencies installed)'));
      passedChecks++;
    } else {
      results.add(CheckResult('Dependencies', false, 'pubspec.lock missing (run flutter pub get)'));
    }
  }

  void checkEnvironmentFile() {
    totalChecks++;
    final envFile = File('.env');
    if (envFile.existsSync()) {
      results.add(CheckResult('Environment File', true, '.env file exists'));
      passedChecks++;
    } else {
      results.add(CheckResult('Environment File', false, '.env file missing'));
    }
  }

  Future<void> checkConfigurationLoading() async {
    totalChecks++;
    try {
      await AppConfig.init();
      results.add(CheckResult('Configuration Loading', true, 'Configuration loaded successfully'));
      passedChecks++;
    } catch (e) {
      results.add(CheckResult('Configuration Loading', false, 'Failed to load configuration: $e'));
    }
  }

  void checkSupabaseConfig() {
    totalChecks++;
    try {
      if (AppConfig.isValidSupabaseConfig) {
        results.add(CheckResult('Supabase Configuration', true, 'Valid Supabase credentials'));
        passedChecks++;
      } else {
        results.add(CheckResult('Supabase Configuration', false, 'Invalid Supabase credentials'));
      }
    } catch (e) {
      results.add(CheckResult('Supabase Configuration', false, 'Error checking Supabase config: $e'));
    }
  }

  void checkAssetStructure() {
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
    
    bool allExist = true;
    for (final dir in requiredDirs) {
      if (!Directory(dir).existsSync()) {
        allExist = false;
        break;
      }
    }
    
    if (allExist) {
      results.add(CheckResult('Asset Structure', true, 'All asset directories exist'));
      passedChecks++;
    } else {
      results.add(CheckResult('Asset Structure', false, 'Some asset directories missing'));
    }
  }

  void checkTranslationFiles() {
    totalChecks++;
    final requiredFiles = [
      'assets/translations/en.json',
      'assets/translations/fr.json'
    ];
    
    bool allExist = true;
    for (final file in requiredFiles) {
      if (!File(file).existsSync()) {
        allExist = false;
        break;
      }
    }
    
    if (allExist) {
      results.add(CheckResult('Translation Files', true, 'All translation files exist'));
      passedChecks++;
    } else {
      results.add(CheckResult('Translation Files', false, 'Some translation files missing'));
    }
  }

  void checkVisualStudio() {
    totalChecks++;
    try {
      final result = Process.runSync('flutter', ['doctor']);
      final output = result.stdout.toString();
      if (output.contains('Visual Studio') && output.contains('√')) {
        results.add(CheckResult('Visual Studio', true, 'Installed and configured for Windows development'));
        passedChecks++;
      } else {
        results.add(CheckResult('Visual Studio', false, 'Not installed or not configured for Windows development'));
      }
    } catch (e) {
      results.add(CheckResult('Visual Studio', false, 'Error checking Visual Studio: $e'));
    }
  }

  void printSummary() {
    print('\n' + '='*60);
    print('FINAL SETUP CHECK SUMMARY');
    print('='*60);
    
    for (final result in results) {
      final status = result.passed ? '✅' : '❌';
      print('$status ${result.name}: ${result.message}');
    }
    
    print('\n' + '='*60);
    final percentage = totalChecks > 0 ? (passedChecks / totalChecks * 100).round() : 0;
    print('PASSED: $passedChecks/$totalChecks ($percentage%)');
    
    if (passedChecks == totalChecks) {
      print('\n🎉 CONGRATULATIONS! Your development environment is fully ready!');
      print('You can now start developing the Le Livreur Pro application.');
      print('\nTo run the application:');
      print('  flutter run -d windows');
      print('\nTo build for Windows:');
      print('  flutter build windows');
    } else if (passedChecks >= totalChecks * 0.8) {
      print('\n✅ Your environment is mostly ready with minor issues.');
      print('Please review the failed checks above.');
    } else {
      print('\n⚠️  Several checks failed. Please review the issues and fix them.');
    }
    
    print('='*60);
  }
}

class CheckResult {
  final String name;
  final bool passed;
  final String message;
  
  CheckResult(this.name, this.passed, this.message);
}