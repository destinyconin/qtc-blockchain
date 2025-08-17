@echo off
title QTC Private Key Exporter
color 0C

echo ================================================================================
echo                      QTC PRIVATE KEY EXPORTER
echo ================================================================================
echo.
echo                           !!! WARNING !!!
echo.
echo   This tool will display your private key.
echo   Your private key gives FULL CONTROL of your QTC funds.
echo.
echo   SECURITY RULES:
echo   1. NEVER share your private key with anyone
echo   2. NEVER enter it on websites
echo   3. NEVER send it via email or chat
echo   4. Store it offline in a secure location
echo.
echo ================================================================================
echo.

set /p confirm="Type 'I UNDERSTAND THE RISKS' to continue: "
if not "%confirm%"=="I UNDERSTAND THE RISKS" (
    echo.
    echo Cancelled for your security.
    pause
    exit
)

echo.
echo Reading wallet.dat...
echo.

if not exist wallet.dat (
    echo ERROR: wallet.dat not found!
    echo Please run QTC.bat first to generate a wallet.
    pause
    exit
)

echo --------------------------------------------------------------------------------
type wallet.dat
echo --------------------------------------------------------------------------------
echo.
echo WHAT TO DO NEXT:
echo   1. Write down your private key on paper
echo   2. Store the paper in a safe/secure location
echo   3. Delete this screen or close this window
echo   4. NEVER photograph or screenshot your private key
echo.
echo Press any key to close (for security)...
pause >nul
exit
