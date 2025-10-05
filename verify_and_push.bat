@echo off
echo ========================================
echo  Le Livreur Pro - Verification & Push  
echo ========================================

echo.
echo Running final verification...
powershell -ExecutionPolicy Bypass -File "final_verification.ps1"

echo.
echo.
echo Adding all files to git...
git add .

echo.
echo Committing changes...
git commit -m "Environment setup verification and helper scripts"

echo.
echo Pushing to repository...
git push origin main

echo.
echo Done! Your environment is verified and changes have been pushed.
pause