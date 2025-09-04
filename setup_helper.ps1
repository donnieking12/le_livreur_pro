# Le Livreur Pro Setup Helper Script
# This script helps with the setup process on Windows

Write-Host "========================================" -ForegroundColor Green
Write-Host "Le Livreur Pro Setup Helper" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Check if we're in the correct directory
if (-not (Test-Path ".\pubspec.yaml")) {
    Write-Host "Error: Please run this script from the root of the Le Livreur Pro project directory" -ForegroundColor Red
    exit 1
}

Write-Host "`nChecking setup progress..." -ForegroundColor Yellow

# Check .env file
if (Test-Path ".\.env") {
    Write-Host "✅ .env file found" -ForegroundColor Green
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    Write-Host "   Copy .env.template to .env and configure your API keys" -ForegroundColor Yellow
}

# Check configuration
Write-Host "`n--- Configuration Check ---" -ForegroundColor Cyan
try {
    dart verify_config.dart
    Write-Host "✅ Configuration verification script executed" -ForegroundColor Green
} catch {
    Write-Host "❌ Configuration verification failed" -ForegroundColor Red
}

# Check Flutter installation
Write-Host "`n--- Flutter Check ---" -ForegroundColor Cyan
try {
    $flutterVersion = flutter --version
    Write-Host "✅ Flutter is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "   Please install Flutter SDK 3.19.0+ and add to PATH" -ForegroundColor Yellow
}

# Check dependencies
Write-Host "`n--- Dependencies Check ---" -ForegroundColor Cyan
if (Test-Path ".\pubspec.yaml") {
    Write-Host "✅ pubspec.yaml found" -ForegroundColor Green
} else {
    Write-Host "❌ pubspec.yaml not found" -ForegroundColor Red
}

# Provide next steps
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Next Steps:" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "1. Execute database schema in Supabase:" -ForegroundColor Yellow
Write-Host "   - Follow instructions in SUPABASE_SCHEMA_EXECUTION_GUIDE.md" -ForegroundColor Yellow
Write-Host "2. After schema execution, test connection:" -ForegroundColor Yellow
Write-Host "   - dart test_supabase_connection.dart" -ForegroundColor Yellow
Write-Host "3. Install Flutter dependencies:" -ForegroundColor Yellow
Write-Host "   - flutter pub get" -ForegroundColor Yellow
Write-Host "4. Run the application:" -ForegroundColor Yellow
Write-Host "   - flutter run" -ForegroundColor Yellow

Write-Host "`nFor detailed instructions, see:" -ForegroundColor Cyan
Write-Host "- COMPLETE_SETUP_GUIDE.md" -ForegroundColor Cyan
Write-Host "- SUPABASE_SCHEMA_EXECUTION_GUIDE.md" -ForegroundColor Cyan
Write-Host "- SETUP_PROGRESS.md" -ForegroundColor Cyan