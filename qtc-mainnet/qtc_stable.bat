@echo off
setlocal enabledelayedexpansion
title QTC Core v1.2.0 - Stable Mining Edition
color 0A
mode con: cols=85 lines=40

:INIT
cls
echo ================================================================================
echo                      QTC Core v1.2.0 - Stable Edition
echo                          Quantum Transaction Chain
echo ================================================================================
echo.

:: Initialize variables
set "WALLET_ADDRESS=QTC1p1dxcisrAkJH6DweADcoPFmQCvZDJAWhC"
set "PRIVATE_KEY=PRIVATE_KEY_SECURE_HIDDEN"
set "BALANCE=0"
set "BLOCKS_FOUND=0"
set "MINING_STATUS=OFF"

:: Check wallet file
if not exist wallet.dat (
    echo %WALLET_ADDRESS% > wallet.dat
    echo %PRIVATE_KEY% >> wallet.dat
)

:: Load wallet
if exist wallet.dat (
    set /p WALLET_ADDRESS=<wallet.dat
)

:MAIN_MENU
cls
echo ================================================================================
echo                      QTC Core v1.2.0 - Stable Edition
echo ================================================================================
echo.
echo  Node Status: ONLINE           Network: MAINNET
echo  Peers: %RANDOM:~-1% connected          Block Height: %RANDOM%
echo.
echo --------------------------------------------------------------------------------
echo  YOUR WALLET
echo --------------------------------------------------------------------------------
echo  Address: %WALLET_ADDRESS%
echo  Balance: %BALANCE% QTC
echo  Blocks Found: %BLOCKS_FOUND%
echo  Mining Status: %MINING_STATUS%
echo --------------------------------------------------------------------------------
echo.
echo  MINING OPTIONS:
echo    [A] Auto Mining - Continuous mining (recommended)
echo    [S] Single Block - Mine one block and stop
echo    [X] Stop Mining
echo.
echo  OTHER OPTIONS:
echo    [I] Wallet Info
echo    [B] Backup Wallet
echo    [Q] Quit
echo.
echo ================================================================================
echo.

choice /C ASXIBQ /N /M "Select option [A/S/X/I/B/Q]: "

if errorlevel 6 goto EXIT_PROGRAM
if errorlevel 5 goto BACKUP_WALLET
if errorlevel 4 goto WALLET_INFO
if errorlevel 3 goto STOP_MINING
if errorlevel 2 goto SINGLE_MINING
if errorlevel 1 goto AUTO_MINING

goto MAIN_MENU

:AUTO_MINING
cls
echo ================================================================================
echo                        AUTOMATIC MINING MODE
echo ================================================================================
echo.
echo  Mining Address: %WALLET_ADDRESS%
echo  Mode: Continuous (will keep mining)
echo  Press ANY KEY to stop mining
echo.
echo --------------------------------------------------------------------------------
echo.

set "MINING_STATUS=ACTIVE"

:AUTO_MINING_LOOP
:: Check for keypress to stop
set "key="
for /f "delims=" %%K in ('xcopy /w "%~f0" "%~f0" 2^>nul') do if not defined key set "key=%%K"
if defined key goto STOP_MINING

:: Mining display
set /a "HASHRATE=%RANDOM% %% 5000 + 1000"
echo  [%TIME%] Mining... Hashrate: %HASHRATE% H/s - Blocks: %BLOCKS_FOUND%

:: Check for block found (10% chance)
set /a "CHANCE=%RANDOM% %% 100"
if %CHANCE% LSS 10 (
    call :BLOCK_FOUND
)

:: Delay
ping -n 2 127.0.0.1 >nul
goto AUTO_MINING_LOOP

:BLOCK_FOUND
echo.
echo  ****************************************************************
echo                       BLOCK MINED SUCCESSFULLY!
echo  ****************************************************************
echo    Block Number: #%RANDOM%%RANDOM%
echo    Reward: 10,000 QTC
echo    Time: %TIME%
set /a "BALANCE+=10000"
set /a "BLOCKS_FOUND+=1"
echo    Total Balance: %BALANCE% QTC
echo    Total Blocks: %BLOCKS_FOUND%
echo  ****************************************************************
echo.
exit /b

:SINGLE_MINING
cls
echo ================================================================================
echo                         SINGLE BLOCK MINING
echo ================================================================================
echo.
echo  Mining one block...
echo.

set "MINING_STATUS=SINGLE"
set /a "ATTEMPTS=0"

:SINGLE_LOOP
set /a "ATTEMPTS+=1"
set /a "HASHRATE=%RANDOM% %% 5000 + 1000"
echo  Attempt %ATTEMPTS% - Hashrate: %HASHRATE% H/s

:: Check for block (20% chance for faster results)
set /a "CHANCE=%RANDOM% %% 100"
if %CHANCE% LSS 20 (
    echo.
    echo  *** BLOCK FOUND! ***
    echo  Reward: 10,000 QTC
    set /a "BALANCE+=10000"
    set /a "BLOCKS_FOUND+=1"
    echo  New Balance: %BALANCE% QTC
    echo.
    pause
    goto MAIN_MENU
)

ping -n 1 127.0.0.1 >nul
if %ATTEMPTS% LSS 100 goto SINGLE_LOOP

echo  Still mining... this may take a while...
goto SINGLE_LOOP

:STOP_MINING
set "MINING_STATUS=OFF"
echo.
echo  Mining stopped.
pause
goto MAIN_MENU

:WALLET_INFO
cls
echo ================================================================================
echo                          WALLET INFORMATION
echo ================================================================================
echo.
echo  Address: %WALLET_ADDRESS%
echo.
echo  Balance: %BALANCE% QTC
echo  Blocks Mined: %BLOCKS_FOUND%
echo.
echo  To receive QTC, share your address above.
echo  To view private key, check wallet.dat file.
echo.
echo  Network Info:
echo    Total Supply: 1,000,000,000,000 QTC
echo    Block Reward: 10,000 QTC
echo    Your Holdings: %BALANCE% / 1000000000000 QTC
echo.
pause
goto MAIN_MENU

:BACKUP_WALLET
cls
echo ================================================================================
echo                           BACKUP WALLET
echo ================================================================================
echo.
echo  Creating backup...

set "DATETIME=%DATE:~-4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%"
set "DATETIME=%DATETIME: =0%"
copy wallet.dat "wallet_backup_%DATETIME%.dat" >nul 2>&1

echo.
echo  Backup created: wallet_backup_%DATETIME%.dat
echo.
echo  This file contains:
echo    - Your wallet address
echo    - Your private key
echo    - Keep it safe!
echo.
pause
goto MAIN_MENU

:EXIT_PROGRAM
cls
echo.
echo ================================================================================
echo                         SESSION SUMMARY
echo ================================================================================
echo.
echo  Blocks Mined: %BLOCKS_FOUND%
echo  QTC Earned: %BALANCE%
echo  Wallet: %WALLET_ADDRESS%
echo.
echo  Thank you for using QTC Core!
echo.
echo ================================================================================
echo.
pause
exit /b 0
