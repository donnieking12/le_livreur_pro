@echo off
echo Getting debug keystore information...
echo.
"C:\Program Files\Java\jdk-24\bin\keytool.exe" -list -v -keystore "C:\Users\Mimi\.android\debug.keystore" -alias androiddebugkey -storepass android
pause