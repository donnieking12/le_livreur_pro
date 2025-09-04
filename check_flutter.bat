@echo off
title Flutter Installation Check

echo ========================================
echo Le Livreur Pro - Flutter Installation Check
echo ========================================

echo.
echo Checking Flutter installation...
echo.

where flutter >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Flutter is installed
    echo.
    echo Checking Flutter version...
    flutter --version
    echo.
    echo Checking Flutter doctor...
    flutter doctor
) else (
    echo ❌ Flutter is not installed or not in PATH
    echo.
    echo Please follow the instructions in FIX_FLUTTER_INSTALLATION.md
    echo to properly install Flutter SDK.
)

echo.
echo Press any key to continue...
pause >nul