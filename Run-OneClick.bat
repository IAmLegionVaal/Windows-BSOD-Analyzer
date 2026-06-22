@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Analyze-WindowsBSOD.ps1"
set "RC=%ERRORLEVEL%"
echo.
echo Windows BSOD Analyzer finished with exit code %RC%.
pause
exit /b %RC%
