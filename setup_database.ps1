# Le Livreur Pro - Database Setup Helper Script
# This script guides you through setting up your production database

Write-Host "🗄️  Le Livreur Pro - Database Setup Assistant" -ForegroundColor Green
Write-Host "=" * 55 -ForegroundColor Gray

Write-Host "`n🎯 CRITICAL FIRST STEP: Database Setup" -ForegroundColor Yellow
Write-Host "This is the most important step to get your app production-ready!" -ForegroundColor White

# Step 1: Check if schema file exists
Write-Host "`n📋 Step 1: Checking database schema file..." -ForegroundColor Cyan
if (Test-Path "supabase_schema.sql") {
    Write-Host "✅ Database schema file found" -ForegroundColor Green
} else {
    Write-Host "❌ Schema file not found!" -ForegroundColor Red
    Write-Host "💡 Make sure you're in the project root directory" -ForegroundColor Yellow
    exit 1
}

# Step 2: Display schema info
Write-Host "`n📊 Step 2: Schema Overview" -ForegroundColor Cyan
$schemaContent = Get-Content "supabase_schema.sql" -Raw
$tableCount = ($schemaContent | Select-String "CREATE TABLE" -AllMatches).Matches.Count
$typeCount = ($schemaContent | Select-String "CREATE TYPE" -AllMatches).Matches.Count
$extensionCount = ($schemaContent | Select-String "CREATE EXTENSION" -AllMatches).Matches.Count

Write-Host "   📦 Tables to create: $tableCount" -ForegroundColor White
Write-Host "   🔧 Custom types: $typeCount" -ForegroundColor White  
Write-Host "   🔌 Extensions: $extensionCount" -ForegroundColor White

# Step 3: Instructions
Write-Host "`n🚀 Step 3: Execute Schema in Supabase" -ForegroundColor Cyan
Write-Host "Follow these steps:" -ForegroundColor White
Write-Host "   1. Open: https://app.supabase.com" -ForegroundColor Gray
Write-Host "   2. Select project: fnygxppfogfpwycbbhsv" -ForegroundColor Gray
Write-Host "   3. Go to: SQL Editor > New Query" -ForegroundColor Gray
Write-Host "   4. Copy the entire supabase_schema.sql file content" -ForegroundColor Gray
Write-Host "   5. Paste into SQL Editor and click RUN" -ForegroundColor Gray

Write-Host "`n⏳ Waiting for you to complete the schema execution..." -ForegroundColor Yellow
Write-Host "Press any key when you've finished executing the schema in Supabase..." -ForegroundColor White
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Step 4: Verify setup
Write-Host "`n🔍 Step 4: Verifying database setup..." -ForegroundColor Cyan
Write-Host "Running database verification..." -ForegroundColor White

try {
    dart run verify_database_setup.dart
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Database verification successful!" -ForegroundColor Green
        
        # Step 5: Next steps
        Write-Host "`n🎯 Step 5: What's Next?" -ForegroundColor Cyan
        Write-Host "Your database is ready! Here are your next priorities:" -ForegroundColor White
        Write-Host "   1. 🔐 Set up real authentication (replace mock auth)" -ForegroundColor Yellow
        Write-Host "   2. 🗺️  Configure Google Maps API" -ForegroundColor Yellow
        Write-Host "   3. 💳 Integrate payment gateways" -ForegroundColor Yellow
        Write-Host "   4. 📱 Test with real mobile devices" -ForegroundColor Yellow
        
        Write-Host "`n🏆 Congratulations! You've completed the first critical step!" -ForegroundColor Green
        Write-Host "Your Le Livreur Pro database is now production-ready!" -ForegroundColor White
    } else {
        Write-Host "`n❌ Database verification failed!" -ForegroundColor Red
        Write-Host "Please check the error messages above and try again." -ForegroundColor White
    }
} catch {
    Write-Host "`n❌ Could not run verification script" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "`n💡 Try running manually: dart run verify_database_setup.dart" -ForegroundColor Yellow
}

Write-Host "`n📚 Additional Resources:" -ForegroundColor Cyan
Write-Host "   - Database setup guide: DATABASE_SETUP_GUIDE.md" -ForegroundColor Gray
Write-Host "   - Full project guide: PRODUCTION_READINESS.md" -ForegroundColor Gray
Write-Host "   - Next steps: Check the production checklist" -ForegroundColor Gray

Write-Host "`nPress any key to exit..." -ForegroundColor White
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')