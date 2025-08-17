@echo off
title QTC Miner v2.0 - Final Edition
color 0A
cls

:: Initialize
if not exist wallet.dat (
    echo Creating new wallet...
    echo QTC%RANDOM%%RANDOM%%RANDOM%%RANDOM% > wallet.dat
    echo PRIVATE_%RANDOM%%RANDOM%%RANDOM% >> wallet.dat
)

set /p WALLET=<wallet.dat
set BALANCE=0
set BLOCKS=0

:MENU
cls
echo ================================================================================
echo                           QTC MINER v2.0 FINAL
echo ================================================================================
echo.
echo  Wallet: %WALLET%
echo  Balance: %BALANCE% QTC
echo  Blocks Found: %BLOCKS%
echo.
echo  [1] Start Mining
echo  [2] Exit
echo.
set /p choice="Select (1-2): "
if "%choice%"=="1" goto MINING
if "%choice%"=="2" exit
goto MENU

:MINING
cls
echo ================================================================================
echo                            MINING ACTIVE
echo ================================================================================
echo.
echo  Mining to: %WALLET%
echo  Balance: %BALANCE% QTC
echo  Blocks: %BLOCKS%
echo.
echo  Press Ctrl+C to stop
echo.
echo --------------------------------------------------------------------------------

:MINING_LOOP
:: Generate random values
set /a NONCE=%RANDOM%%RANDOM%
set /a HASH=%RANDOM%+1000

:: Display mining progress with timestamp
echo  [%TIME:~0,8%] Mining... Nonce: %NONCE% Hash: %HASH% H/s

:: Check if block found (15% chance for better visibility)
set /a FOUND=%RANDOM% %% 100
if %FOUND% LSS 15 (
    echo.
    color 0E
    echo  ##############################################################
    echo  #                    BLOCK FOUND!                           #
    echo  ##############################################################
    echo  # Block: #%RANDOM%%RANDOM%                                 
    echo  # Reward: 10,000 QTC                                        
    echo  # Time: %TIME:~0,8%                                         
    set /a BALANCE=BALANCE+10000
    set /a BLOCKS=BLOCKS+1
    echo  # Total Balance: %BALANCE% QTC                              
    echo  # Total Blocks: %BLOCKS%                                    
    echo  ##############################################################
    echo.
    color 0A
    echo  Continuing mining...
    echo.
)

:: Small delay for readability
ping localhost -n 2 >nul

goto MINING_LOOP
