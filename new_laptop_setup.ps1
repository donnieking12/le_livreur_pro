# Le Livreur Pro - New Laptop Setup Script
# This script helps verify and set up the development environment

Write-Host "=== Le Livreur Pro - New Laptop Setup ===" -ForegroundColor Green
Write-Host ""

# Check if we're in the correct directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "Error: Please run this script from the project root directory" -ForegroundColor Red
    exit 1
}

Write-Host "1. Checking Flutter installation..." -ForegroundColor Yellow
flutter --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Flutter is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Checking project dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to get project dependencies" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "3. Checking environment file..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "✅ .env file found" -ForegroundColor Green
    $envContent = Get-Content ".env" -First 10
    Write-Host "Sample content:"
    $envContent | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    Write-Host "Please create .env file from .env.template" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "4. Checking asset directories..." -ForegroundColor Yellow
$assetDirs = @("assets/images", "assets/images/delivery", "assets/images/payment", "assets/icons", "assets/lottie", "assets/translations")
$allExist = $true
foreach ($dir in $assetDirs) {
    if (Test-Path $dir) {
        Write-Host "✅ $dir exists" -ForegroundColor Green
    } else {
        Write-Host "❌ $dir not found" -ForegroundColor Red
        $allExist = $false
    }
}

if (-not $allExist) {
    Write-Host "Creating missing asset directories..." -ForegroundColor Yellow
    mkdir "assets/images" -Force | Out-Null
    mkdir "assets/images/delivery" -Force | Out-Null
    mkdir "assets/images/payment" -Force | Out-Null
    mkdir "assets/icons" -Force | Out-Null
    mkdir "assets/lottie" -Force | Out-Null
    Write-Host "✅ All asset directories created" -ForegroundColor Green
}

Write-Host ""
Write-Host "5. Running flutter doctor..." -ForegroundColor Yellow
flutter doctor

Write-Host ""
Write-Host "=== Setup Check Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Install Visual Studio with C++ build tools if not already installed" -ForegroundColor Cyan
Write-Host "2. Run 'flutter doctor' to verify all components" -ForegroundColor Cyan
Write-Host "3. Try building with 'flutter build windows'" -ForegroundColor Cyan
Write-Host "4. Run the app with 'flutter run -d windows'" -ForegroundColor Cyan