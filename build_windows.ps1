# PowerShell script to build Le Livreur Pro for Windows with the correct Visual Studio generator

Write-Host "=== Le Livreur Pro - Windows Build Script ===" -ForegroundColor Green
Write-Host ""

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error cleaning previous builds" -ForegroundColor Red
    exit 1
}

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error getting dependencies" -ForegroundColor Red
    exit 1
}

# Create build directory
Write-Host "Creating build directory..." -ForegroundColor Yellow
$buildDir = "build\windows\x64"
if (Test-Path $buildDir) {
    Remove-Item -Recurse -Force $buildDir
}
New-Item -ItemType Directory -Path $buildDir | Out-Null

# Run CMake with the correct generator
Write-Host "Running CMake configuration..." -ForegroundColor Yellow
$cmakePath = "C:\Program Files\Microsoft Visual Studio\18\Insiders\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
$sourceDir = "windows"
$buildDir = "build\windows\x64"

& $cmakePath -S $sourceDir -B $buildDir -G "Visual Studio 17 2022" -A x64 -DFLUTTER_TARGET_PLATFORM=windows-x64
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error running CMake configuration" -ForegroundColor Red
    exit 1
}

# Build the project
Write-Host "Building the project..." -ForegroundColor Yellow
& $cmakePath --build $buildDir --config Release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error building the project" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Build completed successfully!" -ForegroundColor Green
Write-Host "The executable can be found in build\windows\x64\Release" -ForegroundColor Cyan
Write-Host ""
Write-Host "To run the application, execute:" -ForegroundColor Yellow
Write-Host "  .\build\windows\x64\Release\le_livreur_pro.exe" -ForegroundColor Cyan