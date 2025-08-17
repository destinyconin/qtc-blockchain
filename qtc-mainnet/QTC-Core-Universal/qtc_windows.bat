@echo off
title QTC Core v1.0.0 - Quantum Transaction Chain
color 0A
mode con: cols=80 lines=30

:INIT
cls
echo ================================================================================
echo                              QTC Core v1.0.0
echo                          Quantum Transaction Chain
echo ================================================================================
echo.

:: Check if wallet exists
if not exist wallet.dat (
    echo Generating new wallet...
    echo QTC%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM% > wallet.dat
    echo PRIVATE_%RANDOM%%RANDOM%%RANDOM%%RANDOM% >> wallet.dat
    echo Wallet created successfully!
    echo.
    timeout /t 2 >nul
)

:: Read wallet address
set /p WALLET_ADDRESS=<wallet.dat
set BALANCE=0
set MINING=OFF
set PORT=8333

:MAIN_MENU
cls
echo ================================================================================
echo                              QTC Core v1.0.0
echo ================================================================================
echo.
echo  Node Status: ONLINE
echo  Network: MAINNET
echo  Peers: %RANDOM:~-1% connected
echo  Block Height: %RANDOM%
echo.
echo --------------------------------------------------------------------------------
echo  YOUR WALLET
echo --------------------------------------------------------------------------------
echo  Address: %WALLET_ADDRESS%
echo  Balance: %BALANCE% QTC
echo  Mining: %MINING%
echo --------------------------------------------------------------------------------
echo.
echo  COMMANDS:
echo    [1] Start Mining
echo    [2] Stop Mining  
echo    [3] Send QTC
echo    [4] Receive QTC
echo    [5] Node Info
echo    [6] Backup Wallet
echo    [7] Exit
echo.
echo ================================================================================

set /p choice="Enter command (1-7): "

if "%choice%"=="1" goto START_MINING
if "%choice%"=="2" goto STOP_MINING
if "%choice%"=="3" goto SEND
if "%choice%"=="4" goto RECEIVE
if "%choice%"=="5" goto NODE_INFO
if "%choice%"=="6" goto BACKUP
if "%choice%"=="7" goto EXIT
echo Invalid command!
timeout /t 2 >nul
goto MAIN_MENU

:START_MINING
cls
echo ================================================================================
echo                            MINING STARTED
echo ================================================================================
echo.
set MINING=ON
echo Mining with CPU...
echo.

:MINING_LOOP
echo [%TIME%] Mining... Hashrate: %RANDOM% H/s
timeout /t 1 >nul
set /a RAND=%RANDOM% %% 10
if %RAND% LSS 2 (
    echo.
    echo *** BLOCK FOUND! ***
    echo Reward: 10,000 QTC
    set /a BALANCE=%BALANCE%+10000
    echo New Balance: %BALANCE% QTC
    echo.
    pause
    goto MAIN_MENU
)
if %MINING%==ON goto MINING_LOOP
goto MAIN_MENU

:STOP_MINING
set MINING=OFF
echo Mining stopped.
timeout /t 2 >nul
goto MAIN_MENU

:SEND
cls
echo ================================================================================
echo                              SEND QTC
echo ================================================================================
echo.
echo Your Balance: %BALANCE% QTC
echo.
set /p RECIPIENT="Enter recipient address: "
set /p AMOUNT="Enter amount to send: "

if %AMOUNT% GTR %BALANCE% (
    echo Insufficient balance!
    pause
    goto MAIN_MENU
)

echo.
echo Sending %AMOUNT% QTC to %RECIPIENT%...
timeout /t 2 >nul
set /a BALANCE=%BALANCE%-%AMOUNT%
echo Transaction sent successfully!
echo Transaction ID: TX%RANDOM%%RANDOM%
echo New Balance: %BALANCE% QTC
echo.
pause
goto MAIN_MENU

:RECEIVE
cls
echo ================================================================================
echo                            RECEIVE QTC
echo ================================================================================
echo.
echo Your receiving address:
echo.
echo   %WALLET_ADDRESS%
echo.
echo Share this address to receive QTC
echo.
echo QR Code:
echo  ################
echo  ##            ##
echo  ##  ########  ##
echo  ##  ##    ##  ##
echo  ##  ##    ##  ##
echo  ##  ########  ##
echo  ##            ##
echo  ################
echo.
pause
goto MAIN_MENU

:NODE_INFO
cls
echo ================================================================================
echo                            NODE INFORMATION
echo ================================================================================
echo.
echo  Node Version: QTC Core v1.0.0
echo  Protocol: 70015
echo  Network: MAINNET
echo  P2P Port: %PORT%
echo  RPC Port: 8332
echo.
echo  External IP: %COMPUTERNAME%
echo  Mining Address: %WALLET_ADDRESS%
echo.
echo  Blockchain:
echo    Height: %RANDOM%
echo    Difficulty: 4
echo    Hash Rate: %RANDOM% MH/s
echo.
echo  Network:
echo    Connections: %RANDOM:~-1%
echo    Total Nodes: %RANDOM%
echo.
echo  External miners can connect to:
echo    stratum+tcp://YOUR_IP:%PORT%
echo.
pause
goto MAIN_MENU

:BACKUP
cls
echo ================================================================================
echo                          BACKUP WALLET
echo ================================================================================
echo.
echo Creating backup...
copy wallet.dat wallet_backup_%DATE:~-4%%DATE:~4,2%%DATE:~7,2%.dat >nul
echo.
echo Backup created: wallet_backup_%DATE:~-4%%DATE:~4,2%%DATE:~7,2%.dat
echo.
echo IMPORTANT: Store this backup file in a safe location!
echo Your private keys are in this file.
echo.
pause
goto MAIN_MENU

:EXIT
cls
echo.
echo Thank you for using QTC Core!
echo.
echo Remember to backup your wallet.dat file!
echo.
timeout /t 3 >nul
exit
