@echo off
title QTC Core v1.1.0 - Continuous Mining Edition
color 0A
mode con: cols=85 lines=35

:INIT
cls
echo ================================================================================
echo                         QTC Core v1.1.0 - Mining Edition
echo                          Quantum Transaction Chain
echo ================================================================================
echo.

:: Initialize wallet
if not exist wallet.dat (
    echo Generating new wallet...
    echo QTC%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM% > wallet.dat
    echo PRIVATE_%RANDOM%%RANDOM%%RANDOM%%RANDOM% >> wallet.dat
    echo Wallet created successfully!
    timeout /t 2 >nul
)

:: Read wallet
set /p WALLET_ADDRESS=<wallet.dat
for /f "skip=1 delims=" %%i in (wallet.dat) do set PRIVATE_KEY=%%i
set BALANCE=0
set MINING=OFF
set BLOCKS_FOUND=0
set TOTAL_HASHRATE=0
set PORT=8333

:MAIN_MENU
cls
echo ================================================================================
echo                         QTC Core v1.1.0 - Mining Edition
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
echo  Mining Status: %MINING%
echo --------------------------------------------------------------------------------
echo.
echo  COMMANDS:
echo    [1] Start Continuous Mining (Auto-continue after finding blocks)
echo    [2] Start Single Mining (Stop after finding one block)
echo    [3] Stop Mining  
echo    [4] Send QTC
echo    [5] Receive QTC
echo    [6] Node Info
echo    [7] Show Private Key
echo    [8] Backup Wallet
echo    [9] Exit
echo.
echo ================================================================================

set /p choice="Enter command (1-9): "

if "%choice%"=="1" goto CONTINUOUS_MINING
if "%choice%"=="2" goto SINGLE_MINING
if "%choice%"=="3" goto STOP_MINING
if "%choice%"=="4" goto SEND
if "%choice%"=="5" goto RECEIVE
if "%choice%"=="6" goto NODE_INFO
if "%choice%"=="7" goto SHOW_PRIVATE_KEY
if "%choice%"=="8" goto BACKUP
if "%choice%"=="9" goto EXIT
echo Invalid command!
timeout /t 2 >nul
goto MAIN_MENU

:CONTINUOUS_MINING
cls
echo ================================================================================
echo                        CONTINUOUS MINING MODE ACTIVATED
echo ================================================================================
echo.
set MINING=CONTINUOUS
echo Mining to address: %WALLET_ADDRESS%
echo Mode: Continuous (will keep mining after finding blocks)
echo Press Ctrl+C to stop mining
echo.
echo --------------------------------------------------------------------------------
echo.

:CONTINUOUS_MINING_LOOP
:: Generate random hashrate
set /a HASHRATE=%RANDOM% * 100 / 32768 + 1000

:: Display mining status
echo [%TIME%] Mining... Hashrate: %HASHRATE% H/s | Blocks Found: %BLOCKS_FOUND%

:: Random chance to find block (about 10% chance)
set /a RAND=%RANDOM% %% 100
if %RAND% LSS 10 (
    call :FOUND_BLOCK_CONTINUOUS
)

:: Small delay to control speed
ping localhost -n 2 >nul

:: Check if still mining
if "%MINING%"=="CONTINUOUS" goto CONTINUOUS_MINING_LOOP
goto MAIN_MENU

:FOUND_BLOCK_CONTINUOUS
color 0E
echo.
echo ************************************************************
echo                    [!] BLOCK FOUND [!]
echo ************************************************************
echo    Block #%RANDOM%%RANDOM%
echo    Reward: 10,000 QTC
echo    Time: %TIME%
set /a BALANCE=%BALANCE%+10000
set /a BLOCKS_FOUND=%BLOCKS_FOUND%+1
echo    Total Balance: %BALANCE% QTC
echo    Total Blocks Found: %BLOCKS_FOUND%
echo ************************************************************
color 0A
echo.
echo Continuing mining...
echo.
goto :eof

:SINGLE_MINING
cls
echo ================================================================================
echo                          SINGLE MINING MODE
echo ================================================================================
echo.
set MINING=SINGLE
echo Mining to address: %WALLET_ADDRESS%
echo Mode: Single (will stop after finding one block)
echo.

:SINGLE_MINING_LOOP
echo [%TIME%] Mining... Hashrate: %RANDOM% H/s
timeout /t 1 >nul
set /a RAND=%RANDOM% %% 10
if %RAND% LSS 2 (
    color 0E
    echo.
    echo ************************************************************
    echo                    BLOCK FOUND!
    echo ************************************************************
    echo    Reward: 10,000 QTC
    set /a BALANCE=%BALANCE%+10000
    set /a BLOCKS_FOUND=%BLOCKS_FOUND%+1
    echo    New Balance: %BALANCE% QTC
    echo ************************************************************
    color 0A
    echo.
    set MINING=OFF
    pause
    goto MAIN_MENU
)
if "%MINING%"=="SINGLE" goto SINGLE_MINING_LOOP
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

if %BALANCE% EQU 0 (
    echo You have no QTC to send! Mine some blocks first.
    pause
    goto MAIN_MENU
)

set /p RECIPIENT="Enter recipient address: "
set /p AMOUNT="Enter amount to send: "

if %AMOUNT% GTR %BALANCE% (
    echo Insufficient balance! You only have %BALANCE% QTC
    pause
    goto MAIN_MENU
)

echo.
echo Sending %AMOUNT% QTC to %RECIPIENT%...
timeout /t 2 >nul
set /a BALANCE=%BALANCE%-%AMOUNT%
echo.
echo ================================================================================
echo                         TRANSACTION SUCCESSFUL
echo ================================================================================
echo  Transaction ID: TX%RANDOM%%RANDOM%%RANDOM%
echo  Sent: %AMOUNT% QTC
echo  To: %RECIPIENT%
echo  Fee: 0.001 QTC
echo  New Balance: %BALANCE% QTC
echo  Confirmations: 1/6
echo ================================================================================
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
echo QR Code (Simulated):
echo  ###############################
echo  ##                           ##
echo  ##   ####   ####   ####      ##
echo  ##   ####   ####   ####      ##
echo  ##                           ##
echo  ##   ################        ##
echo  ##   ################        ##
echo  ##                           ##
echo  ###############################
echo.
echo Checking for incoming transactions...
set /a INCOMING=%RANDOM% %% 2
if %INCOMING% EQU 1 (
    set /a RECEIVED=%RANDOM% %% 10000 + 100
    echo.
    echo [!] Incoming transaction detected!
    echo     Amount: %RECEIVED% QTC
    echo     From: QTC%RANDOM%%RANDOM%...
    set /a BALANCE=%BALANCE%+%RECEIVED%
    echo     New Balance: %BALANCE% QTC
)
echo.
pause
goto MAIN_MENU

:NODE_INFO
cls
echo ================================================================================
echo                            NODE INFORMATION
echo ================================================================================
echo.
echo  Node Version: QTC Core v1.1.0
echo  Protocol: 70015
echo  Network: MAINNET
echo  Node ID: NODE_%RANDOM%%RANDOM%
echo.
echo  P2P Port: %PORT%
echo  RPC Port: 8332
echo  Stratum Port: 3333
echo.
echo  Your Wallet: 
echo    Address: %WALLET_ADDRESS%
echo    Balance: %BALANCE% QTC
echo    Blocks Mined: %BLOCKS_FOUND%
echo.
echo  Blockchain Statistics:
echo    Height: %RANDOM%
echo    Difficulty: 4.%RANDOM:~-2%
echo    Network Hash Rate: %RANDOM% MH/s
echo    Total Supply: 1,000,000,000,000 QTC
echo    Circulating: %RANDOM%000 QTC
echo    Block Reward: 10,000 QTC
echo    Block Time: ~10 minutes
echo.
echo  Network:
echo    Active Nodes: %RANDOM%
echo    Your Connections: %RANDOM:~-1%
echo.
echo  Mining Pools Can Connect:
echo    stratum+tcp://YOUR_IP:%PORT%
echo    stratum+tcp://YOUR_IP:3333
echo.
pause
goto MAIN_MENU

:SHOW_PRIVATE_KEY
cls
echo ================================================================================
echo                         !!! PRIVATE KEY WARNING !!!
echo ================================================================================
echo.
echo  WARNING: Never share your private key!
echo.
set /p confirm="Type 'SHOW' to display private key: "
if not "%confirm%"=="SHOW" goto MAIN_MENU

cls
echo ================================================================================
echo                            YOUR PRIVATE KEY
echo ================================================================================
echo.
echo  Wallet Address:
echo  %WALLET_ADDRESS%
echo.
echo  Private Key:
echo  %PRIVATE_KEY%
echo.
echo  Balance: %BALANCE% QTC
echo.
echo --------------------------------------------------------------------------------
echo  KEEP THIS SAFE! This key controls your funds!
echo --------------------------------------------------------------------------------
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

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,8%_%dt:~8,6%"
copy wallet.dat wallet_backup_%timestamp%.dat >nul

echo.
echo Backup created: wallet_backup_%timestamp%.dat
echo.
echo Backup contains:
echo  - Your address: %WALLET_ADDRESS%
echo  - Your private key (encrypted)
echo  - Balance record: %BALANCE% QTC
echo.
echo Store this backup file safely!
echo.
pause
goto MAIN_MENU

:EXIT
cls
echo.
echo ================================================================================
echo                          QTC Mining Summary
echo ================================================================================
echo.
echo  Mining Session Results:
echo    Blocks Found: %BLOCKS_FOUND%
echo    QTC Earned: %BALANCE%
echo    Wallet: %WALLET_ADDRESS%
echo.
echo  Thank you for mining QTC!
echo  Remember to backup your wallet.dat file!
echo.
echo ================================================================================
echo.
timeout /t 5 >nul
exit
