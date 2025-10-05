# Le Livreur Pro - Scripts Usage Guide

## Overview
This guide explains how to use the helper scripts created during the development environment setup.

## Available Scripts

### 1. `build_windows.ps1`
Builds the Le Livreur Pro Windows application.

**Usage:**
```powershell
powershell -ExecutionPolicy Bypass -File build_windows.ps1
```

**What it does:**
- Cleans previous builds
- Gets dependencies
- Runs CMake with the correct Visual Studio generator
- Builds the Release version of the application

### 2. `run_app.ps1`
Runs the built Le Livreur Pro Windows application.

**Usage:**
```powershell
powershell -ExecutionPolicy Bypass -File run_app.ps1
```

**Requirements:**
- The application must be built first using `build_windows.ps1`

### 3. `dev_setup_assistant.ps1`
Interactive setup assistant for the development environment.

**Usage:**
```powershell
powershell -ExecutionPolicy Bypass -File dev_setup_assistant.ps1
```

**Features:**
- Check current setup status
- Verify Visual Studio installation
- Test Windows build
- Run the application
- Run complete verification

### 4. `verify_vs_installation.ps1`
Verifies that Visual Studio is properly installed and configured.

**Usage:**
```powershell
powershell -ExecutionPolicy Bypass -File verify_vs_installation.ps1
```

### 5. `git_status_check.ps1`
Checks git status and pushes changes to the remote repository.

**Usage:**
```powershell
powershell -ExecutionPolicy Bypass -File git_status_check.ps1
```

### 6. `final_verification.ps1`
Runs a comprehensive verification of the development environment.

**Usage:**
```powershell
powershell -ExecutionPolicy Bypass -File final_verification.ps1
```

### 7. `verify_and_push.bat`
Windows batch file that runs verification and pushes changes to git.

**Usage:**
```cmd
verify_and_push.bat
```

## Quick Start

1. **Verify your environment:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File final_verification.ps1
   ```

2. **Build the application:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File build_windows.ps1
   ```

3. **Run the application:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File run_app.ps1
   ```

4. **Commit and push changes:**
   ```cmd
   verify_and_push.bat
   ```

## Troubleshooting

### If PowerShell scripts are blocked:
Run this command as Administrator:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
```

### If Visual Studio is not detected:
1. Make sure Visual Studio Community 2022 or later is installed
2. Ensure the "Desktop development with C++" workload is selected
3. Restart your computer after installation

### If build fails:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Try building again

## Next Steps

1. Run the verification script to confirm everything is working
2. Build the Windows application
3. Run the application to test it
4. Start developing!

## Support

If you encounter any issues:
1. Check the Flutter documentation
2. Review the DEVELOPER_ONBOARDING.md file
3. Contact the development team for assistance