# Final verification script for Le Livreur Pro development environment

Write-Host "=========================================" -ForegroundColor Green
Write-Host "  Le Livreur Pro - Final Verification    " -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "1. Checking Flutter installation..." -ForegroundColor Yellow
flutter --version
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Flutter is installed" -ForegroundColor Green
} else {
    Write-Host "   ❌ Flutter is not installed" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Checking Visual Studio installation..." -ForegroundColor Yellow
$vsInstallation = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*Visual Studio*"}
if ($vsInstallation) {
    Write-Host "   ✅ Visual Studio is installed" -ForegroundColor Green
    foreach ($install in $vsInstallation) {
        Write-Host "      - $($install.Name)" -ForegroundColor Cyan
    }
} else {
    Write-Host "   ❌ Visual Studio is not installed" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Checking project dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Project dependencies are installed" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to install project dependencies" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Checking environment file..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "   ✅ .env file exists" -ForegroundColor Green
} else {
    Write-Host "   ❌ .env file is missing" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Checking asset directories..." -ForegroundColor Yellow
$assetDirs = @("assets", "assets/icons", "assets/images", "assets/images/delivery", "assets/images/payment", "assets/lottie", "assets/translations")
$allExist = $true
foreach ($dir in $assetDirs) {
    if (Test-Path $dir) {
        Write-Host "   ✅ $dir exists" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $dir is missing" -ForegroundColor Red
        $allExist = $false
    }
}

Write-Host ""
Write-Host "6. Checking git status..." -ForegroundColor Yellow
git status

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  VERIFICATION COMPLETE                  " -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run 'build_windows.ps1' to build the Windows application" -ForegroundColor Cyan
Write-Host "2. Run 'run_app.ps1' to launch the application" -ForegroundColor Cyan
Write-Host "3. Run 'git_status_check.ps1' to commit and push changes" -ForegroundColor Cyan