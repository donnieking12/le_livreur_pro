# PowerShell script to run the Le Livreur Pro Windows application

Write-Host "=== Le Livreur Pro - Run Application ===" -ForegroundColor Green
Write-Host ""

# Check if the executable exists
$exePath = "build\windows\x64\Release\le_livreur_pro.exe"
if (Test-Path $exePath) {
    Write-Host "Found executable: $exePath" -ForegroundColor Green
    Write-Host "Starting Le Livreur Pro application..." -ForegroundColor Yellow
    Write-Host ""
    
    # Run the application
    & $exePath
} else {
    Write-Host "Executable not found: $exePath" -ForegroundColor Red
    Write-Host "Please build the application first using build_windows.ps1" -ForegroundColor Yellow
    exit 1
}