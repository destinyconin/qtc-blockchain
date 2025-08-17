@echo off
echo ================================================================================
echo                     QTC Core Installation for Windows
echo ================================================================================
echo.
echo Installing QTC Core...
echo.

:: Create QTC folder in Program Files
mkdir "%LOCALAPPDATA%\QTC" 2>nul
copy qtc_windows.bat "%LOCALAPPDATA%\QTC\QTC.bat" >nul
copy wallet.dat "%LOCALAPPDATA%\QTC\" 2>nul

:: Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\QTC Wallet.lnk'); $Shortcut.TargetPath = '%LOCALAPPDATA%\QTC\QTC.bat'; $Shortcut.IconLocation = 'shell32.dll,13'; $Shortcut.Save()"

echo.
echo ================================================================================
echo Installation Complete!
echo.
echo QTC Core has been installed to: %LOCALAPPDATA%\QTC
echo Desktop shortcut created: QTC Wallet
echo.
echo You can now:
echo   1. Double-click "QTC Wallet" on your desktop
echo   2. Or run QTC.bat from this folder
echo.
pause
