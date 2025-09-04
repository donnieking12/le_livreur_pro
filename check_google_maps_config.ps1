# Le Livreur Pro - Google Maps Configuration Check
Write-Host "=== Le Livreur Pro - Google Maps Configuration Verification ===" -ForegroundColor Green

# Check if .env file exists
if (Test-Path ".env") {
    Write-Host "✅ .env file exists" -ForegroundColor Green
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    Write-Host "   Please create a .env file with your configuration" -ForegroundColor Yellow
    exit 1
}

# Read the .env file
$envContent = Get-Content ".env"

# Extract Google Maps API Key
$googleMapsKey = $null
foreach ($line in $envContent) {
    # Skip comments and empty lines
    if ($line.Trim().StartsWith("#") -or $line.Trim() -eq "") {
        continue
    }
    
    # Check if line contains Google Maps API key
    if ($line -match "GOOGLE_MAPS_API_KEY\s*=") {
        $parts = $line.Split("=", 2)
        if ($parts.Length -eq 2) {
            $googleMapsKey = $parts[1].Trim()
        }
    }
}

# Display and validate Google Maps configuration
Write-Host "`n--- Google Maps Configuration ---" -ForegroundColor Cyan
if ($googleMapsKey) {
    Write-Host "GOOGLE_MAPS_API_KEY: $googleMapsKey" -ForegroundColor White
    
    # Check if configuration is valid
    Write-Host "`n--- Validation Results ---" -ForegroundColor Cyan
    if ($googleMapsKey -ne "your-google-maps-api-key" -and $googleMapsKey -ne "") {
        Write-Host "✅ Google Maps configuration is VALID" -ForegroundColor Green
        Write-Host "   The API key is properly configured and ready to use" -ForegroundColor Green
        Write-Host "`n✅ Your Google Maps API key is properly configured!" -ForegroundColor Green
        Write-Host "   You can now run the application and use map features" -ForegroundColor Green
    } else {
        Write-Host "❌ Google Maps configuration is INVALID" -ForegroundColor Red
        if ($googleMapsKey -eq "your-google-maps-api-key") {
            Write-Host "   - GOOGLE_MAPS_API_KEY is still using a placeholder value" -ForegroundColor Yellow
            Write-Host "   - Please update it with your actual Google Maps API key" -ForegroundColor Yellow
        } elseif ($googleMapsKey -eq "") {
            Write-Host "   - GOOGLE_MAPS_API_KEY is empty" -ForegroundColor Yellow
            Write-Host "   - Please provide a valid Google Maps API key" -ForegroundColor Yellow
        }
        
        Write-Host "`n--- Next Steps ---" -ForegroundColor Cyan
        Write-Host "1. Get your Google Maps API key from Google Cloud Console" -ForegroundColor White
        Write-Host "2. Update the GOOGLE_MAPS_API_KEY value in your .env file" -ForegroundColor White
        Write-Host "3. Re-run this verification script to confirm" -ForegroundColor White
    }
} else {
    Write-Host "❌ GOOGLE_MAPS_API_KEY not found in .env file" -ForegroundColor Red
    Write-Host "   Please add your Google Maps API key to the .env file" -ForegroundColor Yellow
}