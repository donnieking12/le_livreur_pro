# Le Livreur Pro - Development Setup Assistant
# This script guides you through the complete setup process

Write-Host "=== Le Livreur Pro - Development Setup Assistant ===" -ForegroundColor Green
Write-Host ""

function Show-Menu {
    Write-Host "Development Setup Menu:" -ForegroundColor Yellow
    Write-Host "1. Check current setup status" -ForegroundColor Cyan
    Write-Host "2. Install Visual Studio (requires manual steps)" -ForegroundColor Cyan
    Write-Host "3. Verify Visual Studio installation" -ForegroundColor Cyan
    Write-Host "4. Test Windows build" -ForegroundColor Cyan
    Write-Host "5. Run the application" -ForegroundColor Cyan
    Write-Host "6. Run complete verification" -ForegroundColor Cyan
    Write-Host "7. Exit" -ForegroundColor Cyan
    Write-Host ""
}

function Check-Setup-Status {
    Write-Host "=== Current Setup Status ===" -ForegroundColor Yellow
    
    # Check Flutter
    Write-Host "Checking Flutter installation..." -ForegroundColor Gray
    $flutterResult = flutter --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Flutter: Installed" -ForegroundColor Green
    } else {
        Write-Host "❌ Flutter: Not found" -ForegroundColor Red
    }
    
    # Check dependencies
    Write-Host "Checking project dependencies..." -ForegroundColor Gray
    $pubGetResult = flutter pub get 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Dependencies: Installed" -ForegroundColor Green
    } else {
        Write-Host "❌ Dependencies: Not installed" -ForegroundColor Red
    }
    
    # Check .env file
    Write-Host "Checking environment file..." -ForegroundColor Gray
    if (Test-Path ".env") {
        Write-Host "✅ .env file: Exists" -ForegroundColor Green
    } else {
        Write-Host "❌ .env file: Missing" -ForegroundColor Red
    }
    
    # Check asset directories
    Write-Host "Checking asset directories..." -ForegroundColor Gray
    $assetDirs = @("assets", "assets/icons", "assets/images", "assets/images/delivery", "assets/images/payment", "assets/lottie", "assets/translations")
    $allExist = $true
    foreach ($dir in $assetDirs) {
        if (-not (Test-Path $dir)) {
            $allExist = $false
            break
        }
    }
    
    if ($allExist) {
        Write-Host "✅ Asset directories: All exist" -ForegroundColor Green
    } else {
        Write-Host "❌ Asset directories: Some missing" -ForegroundColor Red
    }
    
    # Check Visual Studio
    Write-Host "Checking Visual Studio..." -ForegroundColor Gray
    $doctorResult = flutter doctor 2>$null
    if ($doctorResult -like "*Visual Studio*" -and $doctorResult -like "*√*") {
        Write-Host "✅ Visual Studio: Installed and configured" -ForegroundColor Green
    } else {
        Write-Host "❌ Visual Studio: Not installed or not configured" -ForegroundColor Red
    }
    
    Write-Host ""
}

function Install-Visual-Studio {
    Write-Host "=== Visual Studio Installation ===" -ForegroundColor Yellow
    Write-Host "Please follow these steps manually:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Go to https://visualstudio.microsoft.com/downloads/" -ForegroundColor Gray
    Write-Host "2. Download Visual Studio Community (free)" -ForegroundColor Gray
    Write-Host "3. Run the installer" -ForegroundColor Gray
    Write-Host "4. Select 'Desktop development with C++' workload" -ForegroundColor Gray
    Write-Host "5. Make sure all default components are selected" -ForegroundColor Gray
    Write-Host "6. Complete the installation (30-60 minutes)" -ForegroundColor Gray
    Write-Host "7. Restart your computer" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press any key to continue after installation..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Verify-VS-Installation {
    Write-Host "=== Verifying Visual Studio Installation ===" -ForegroundColor Yellow
    Write-Host "Running flutter doctor..." -ForegroundColor Gray
    
    $doctorOutput = flutter doctor
    Write-Host $doctorOutput
    
    if ($doctorOutput -like "*Visual Studio*√*") {
        Write-Host "✅ Visual Studio is properly installed and configured!" -ForegroundColor Green
    } else {
        Write-Host "❌ Visual Studio is not properly installed or configured." -ForegroundColor Red
        Write-Host "Please make sure you:" -ForegroundColor Yellow
        Write-Host "1. Installed Visual Studio Community" -ForegroundColor Gray
        Write-Host "2. Selected 'Desktop development with C++' workload" -ForegroundColor Gray
        Write-Host "3. Restarted your computer" -ForegroundColor Gray
        Write-Host "4. Are running this script from a new terminal window" -ForegroundColor Gray
    }
    
    Write-Host ""
}

function Test-Windows-Build {
    Write-Host "=== Testing Windows Build ===" -ForegroundColor Yellow
    
    Write-Host "Cleaning previous build artifacts..." -ForegroundColor Gray
    flutter clean 2>$null
    
    Write-Host "Getting dependencies..." -ForegroundColor Gray
    flutter pub get
    
    Write-Host "Building Windows application..." -ForegroundColor Gray
    Write-Host "This may take a few minutes..." -ForegroundColor Gray
    
    $buildResult = flutter build windows --no-pub 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Windows build successful!" -ForegroundColor Green
        Write-Host "You can now run the application with 'flutter run -d windows'" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Windows build failed:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
        Write-Host ""
        Write-Host "Please make sure Visual Studio is properly installed with C++ build tools." -ForegroundColor Yellow
    }
    
    Write-Host ""
}

function Run-Application {
    Write-Host "=== Running Application ===" -ForegroundColor Yellow
    Write-Host "Starting Le Livreur Pro application..." -ForegroundColor Gray
    Write-Host "Close the application window to return to this menu." -ForegroundColor Gray
    Write-Host ""
    
    flutter run -d windows
}

function Run-Complete-Verification {
    Write-Host "=== Running Complete Verification ===" -ForegroundColor Yellow
    Write-Host "This will check all aspects of your setup..." -ForegroundColor Gray
    Write-Host ""
    
    dart run complete_setup_verification.dart
}

do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-7)"
    Write-Host ""
    
    switch ($choice) {
        1 { 
            Check-Setup-Status
        }
        2 { 
            Install-Visual-Studio
        }
        3 { 
            Verify-VS-Installation
        }
        4 { 
            Test-Windows-Build
        }
        5 { 
            Run-Application
        }
        6 { 
            Run-Complete-Verification
        }
        7 { 
            Write-Host "Thank you for using Le Livreur Pro Setup Assistant!" -ForegroundColor Green
            exit
        }
        default { 
            Write-Host "Invalid choice. Please enter a number between 1 and 7." -ForegroundColor Red
        }
    }
    
    if ($choice -ne 7) {
        Write-Host "Press any key to continue..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Write-Host ""
    }
} while ($choice -ne 7)