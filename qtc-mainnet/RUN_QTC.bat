@echo off
:START
cls
echo Starting QTC Core...
echo.

if exist qtc_stable.bat (
    call qtc_stable.bat
) else if exist qtc_continuous_mining.bat (
    call qtc_continuous_mining.bat
) else (
    echo Error: No QTC executable found!
    pause
    exit
)

echo.
echo QTC Core closed unexpectedly.
echo.
choice /C YN /M "Restart QTC Core?"
if errorlevel 2 exit
if errorlevel 1 goto START
