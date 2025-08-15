@echo off
echo ========================================
echo Building Le Livreur Pro for Physical Device
echo ========================================

echo.
echo 1. Getting Flutter packages...
flutter pub get

echo.
echo 2. Building debug APK...
flutter build apk --debug

echo.
echo 3. Build completed!
echo APK location: build\app\outputs\flutter-apk\app-debug.apk

echo.
echo 4. Installing on connected device...
flutter install

echo.
echo ========================================
echo Build and install completed!
echo ========================================
pause
