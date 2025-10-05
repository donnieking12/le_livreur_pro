# PowerShell script to check git status and push changes

Write-Host "=== Le Livreur Pro - Git Status Check ===" -ForegroundColor Green
Write-Host ""

# Check current git status
Write-Host "Checking git status..." -ForegroundColor Yellow
git status

# Add all changes
Write-Host "Adding all changes..." -ForegroundColor Yellow
git add .

# Commit changes
Write-Host "Committing changes..." -ForegroundColor Yellow
git commit -m "Setup verification and environment configuration updates"

# Push to remote repository
Write-Host "Pushing to remote repository..." -ForegroundColor Yellow
git push origin main

Write-Host ""
Write-Host "✅ Git operations completed!" -ForegroundColor Green