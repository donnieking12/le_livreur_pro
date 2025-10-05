# Visual Studio Installation Verification Script
# This script checks if Visual Studio with C++ build tools is properly installed

Write-Host "=== Visual Studio Installation Verification ===" -ForegroundColor Green
Write-Host ""

# Check if Visual Studio is installed
Write-Host "1. Checking for Visual Studio installation..." -ForegroundColor Yellow

# Try to find Visual Studio installation
$vsInstances = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*Visual Studio*"}

if ($vsInstances.Count -gt 0) {
    Write-Host "✅ Visual Studio installation found:" -ForegroundColor Green
    foreach ($instance in $vsInstances) {
        Write-Host "  - $($instance.Name)" -ForegroundColor Cyan
    }
} else {
    Write-Host "❌ No Visual Studio installation found" -ForegroundColor Red
    Write-Host "   Please install Visual Studio Community with C++ build tools" -ForegroundColor Yellow
    Write-Host "   Download from: https://visualstudio.microsoft.com/downloads/" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "2. Checking for C++ build tools..." -ForegroundColor Yellow

# Check for common C++ build tools locations
$buildToolsFound = $false
$commonPaths = @(
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC",
    "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC",
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC",
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Tools\MSVC"
)

foreach ($path in $commonPaths) {
    if (Test-Path $path) {
        Write-Host "✅ C++ build tools found at: $path" -ForegroundColor Green
        $buildToolsFound = $true
        break
    }
}

if (-not $buildToolsFound) {
    Write-Host "❌ C++ build tools not found" -ForegroundColor Red
    Write-Host "   Please ensure you installed Visual Studio with 'Desktop development with C++' workload" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "3. Checking Windows SDK..." -ForegroundColor Yellow

# Check for Windows SDK
$sdkPaths = @(
    "C:\Program Files (x86)\Windows Kits\10\Include",
    "C:\Program Files\Windows Kits\10\Include"
)

$sdkFound = $false
foreach ($path in $sdkPaths) {
    if (Test-Path $path) {
        Write-Host "✅ Windows SDK found at: $path" -ForegroundColor Green
        $sdkFound = $true
        # Show latest SDK version
        $versions = Get-ChildItem $path -Directory | Sort-Object Name -Descending
        if ($versions.Count -gt 0) {
            Write-Host "  Latest SDK version: $($versions[0].Name)" -ForegroundColor Cyan
        }
        break
    }
}

if (-not $sdkFound) {
    Write-Host "❌ Windows SDK not found" -ForegroundColor Red
    Write-Host "   The Windows SDK should be included with Visual Studio installation" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "4. Running flutter doctor to verify integration..." -ForegroundColor Yellow
Write-Host "   (This may take a moment)" -ForegroundColor Gray

try {
    $flutterDoctorOutput = flutter doctor 2>&1
    $vsLine = $flutterDoctorOutput | Where-Object { $_ -like "*Visual Studio*" }
    
    if ($vsLine -and $vsLine -like "*√*") {
        Write-Host "✅ Flutter recognizes Visual Studio installation" -ForegroundColor Green
    } elseif ($vsLine -and $vsLine -like "*X*") {
        Write-Host "❌ Flutter does not recognize Visual Studio properly" -ForegroundColor Red
        Write-Host "   Try restarting your computer and running this script again" -ForegroundColor Yellow
    } else {
        Write-Host "⚠️  Could not determine Visual Studio status from flutter doctor" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error running flutter doctor: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Verification Complete ===" -ForegroundColor Green

if ($buildToolsFound -and $sdkFound) {
    Write-Host "🎉 Visual Studio appears to be properly installed!" -ForegroundColor Green
    Write-Host "You can now proceed with Flutter Windows development." -ForegroundColor Cyan
} else {
    Write-Host "⚠️  Some components are missing. Please review the installation." -ForegroundColor Yellow
}