Write-Host "========================================" -ForegroundColor Green
Write-Host "Building Le Livreur Pro for Physical Device" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host ""
Write-Host "1. Getting Flutter packages..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "2. Building debug APK..." -ForegroundColor Yellow
flutter build apk --debug

Write-Host ""
Write-Host "3. Build completed!" -ForegroundColor Green
Write-Host "APK location: build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor Cyan

Write-Host ""
Write-Host "4. Installing on connected device..." -ForegroundColor Yellow
flutter install

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Build and install completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Read-Host "Press Enter to continue"
