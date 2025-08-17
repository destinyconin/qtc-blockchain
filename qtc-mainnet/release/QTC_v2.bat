@echo off
title QTC Core v1.0.1 - Quantum Transaction Chain
color 0A
mode con: cols=85 lines=35

:INIT
cls
echo ================================================================================
echo                              QTC Core v1.0.1
echo                          Quantum Transaction Chain
echo ================================================================================
echo.

:: Check if wallet exists
if not exist wallet.dat (
    echo Generating new wallet...
    
    :: Generate random address and private key
    set CHARS=123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz
    set ADDR=QTC
    set PRIV=
    
    :: Create random strings
    for /L %%i in (1,1,34) do call :RANDOM_CHAR ADDR
    for /L %%i in (1,1,64) do call :RANDOM_CHAR PRIV
    
    echo !ADDR! > wallet.dat
    echo !PRIV! >> wallet.dat
    echo Wallet created successfully!
    timeout /t 2 >nul
)

:: Read wallet data
set /p WALLET_ADDRESS=<wallet.dat
for /f "skip=1 delims=" %%i in (wallet.dat) do set PRIVATE_KEY=%%i
set BALANCE=0
set MINING=OFF
set PORT=8333

:MAIN_MENU
cls
echo ================================================================================
echo                              QTC Core v1.0.1
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
echo    [7] Show Private Key (CAREFUL!)
echo    [8] Exit
echo.
echo ================================================================================

set /p choice="Enter command (1-8): "

if "%choice%"=="1" goto START_MINING
if "%choice%"=="2" goto STOP_MINING
if "%choice%"=="3" goto SEND
if "%choice%"=="4" goto RECEIVE
if "%choice%"=="5" goto NODE_INFO
if "%choice%"=="6" goto BACKUP
if "%choice%"=="7" goto SHOW_PRIVATE_KEY
if "%choice%"=="8" goto EXIT
echo Invalid command!
timeout /t 2 >nul
goto MAIN_MENU

:SHOW_PRIVATE_KEY
cls
echo ================================================================================
echo                         !!! PRIVATE KEY WARNING !!!
echo ================================================================================
echo.
echo  WARNING: Your private key controls your QTC funds!
echo  NEVER share it with anyone!
echo  Anyone with this key can steal your QTC!
echo.
echo --------------------------------------------------------------------------------
set /p confirm="Type 'YES' to show private key: "
if not "%confirm%"=="YES" goto MAIN_MENU

cls
echo ================================================================================
echo                            YOUR PRIVATE KEY
echo ================================================================================
echo.
echo  Address:
echo  %WALLET_ADDRESS%
echo.
echo  Private Key:
echo  %PRIVATE_KEY%
echo.
echo --------------------------------------------------------------------------------
echo  SECURITY TIPS:
echo    - Write it down on paper
echo    - Store in a safe place
echo    - NEVER share online
echo    - NEVER type on untrusted websites
echo --------------------------------------------------------------------------------
echo.
echo Press any key to return to menu (private key will be hidden)...
pause >nul
goto MAIN_MENU

:START_MINING
cls
echo ================================================================================
echo                            MINING STARTED
echo ================================================================================
echo.
set MINING=ON
echo Mining to address: %WALLET_ADDRESS%
echo Mining with CPU...
echo.

:MINING_LOOP
echo [%TIME%] Mining... Hashrate: %RANDOM% H/s
timeout /t 1 >nul
set /a RAND=%RANDOM% %% 10
if %RAND% LSS 2 (
    echo.
    color 0E
    echo ************************************************************
    echo                    BLOCK FOUND!
    echo ************************************************************
    echo    Reward: 10,000 QTC
    set /a BALANCE=%BALANCE%+10000
    echo    New Balance: %BALANCE% QTC
    echo ************************************************************
    color 0A
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
echo  Node Version: QTC Core v1.0.1
echo  Protocol: 70015
echo  Network: MAINNET
echo  P2P Port: %PORT%
echo  RPC Port: 8332
echo.
echo  Your Wallet: %WALLET_ADDRESS%
echo.
echo  Blockchain:
echo    Height: %RANDOM%
echo    Difficulty: 4
echo    Hash Rate: %RANDOM% MH/s
echo    Total Supply: 1,000,000,000,000 QTC
echo    Block Reward: 10,000 QTC
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

:: Create backup with timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,8%_%dt:~8,6%"
copy wallet.dat wallet_backup_%timestamp%.dat >nul

echo.
echo Backup created: wallet_backup_%timestamp%.dat
echo.
echo IMPORTANT: 
echo  - Store this backup file in a safe location!
echo  - Your private keys are in this file
echo  - You can restore your wallet with this file
echo.
pause
goto MAIN_MENU

:EXIT
cls
echo.
echo Thank you for using QTC Core!
echo.
echo Remember to backup your wallet.dat file!
echo Your address: %WALLET_ADDRESS%
echo.
timeout /t 3 >nul
exit

:RANDOM_CHAR
set /a RAND=%RANDOM% %% 58
set %1=!%1!!CHARS:~%RAND%,1!
goto :eof
