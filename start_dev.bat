@echo off
echo ========================================
echo Le Livreur Pro - Development Startup
echo ========================================

echo.
echo 1. Verifying Flutter installation...
flutter --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Flutter is installed
) else (
    echo ❌ Flutter is not installed or not in PATH
    echo    Please install Flutter SDK 3.19.0+ and add to PATH
    pause
    exit /b 1
)

echo.
echo 2. Checking dependencies...
if exist pubspec.yaml (
    echo ✅ pubspec.yaml found
) else (
    echo ❌ pubspec.yaml not found
    pause
    exit /b 1
)

echo.
echo 3. Verifying environment configuration...
if exist .env (
    echo ✅ .env file found
) else (
    echo ⚠️  .env file not found
    echo    Copy .env.template to .env and configure your API keys
)

echo.
echo 4. Installing dependencies...
flutter pub get
if %errorlevel% == 0 (
    echo ✅ Dependencies installed successfully
) else (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo 5. Starting development server...
echo    The app will be available at http://localhost:8080
echo    Press Ctrl+C to stop the server
echo.
flutter run -d web-server --web-port 8080