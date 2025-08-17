@echo off
title QTC Blockchain Node v3.0
color 0A
mode con: cols=100 lines=40

:: Initialize blockchain directory
if not exist blockchain mkdir blockchain
if not exist blockchain\blocks mkdir blockchain\blocks
if not exist blockchain\index.dat echo 0 > blockchain\index.dat

:: Initialize wallet
if not exist wallet.dat (
    echo Generating wallet...
    echo QTC%RANDOM%%RANDOM%%RANDOM%%RANDOM% > wallet.dat
    echo PRIVATE_%RANDOM%%RANDOM%%RANDOM% >> wallet.dat
)

:: Load blockchain state
set /p BLOCK_HEIGHT=<blockchain\index.dat
if "%BLOCK_HEIGHT%"=="" set BLOCK_HEIGHT=0
set /p WALLET=<wallet.dat

:: Load balance from blockchain
set BALANCE=0
if exist blockchain\balance.dat (
    set /p BALANCE=<blockchain\balance.dat
)

:: Mining difficulty (higher = harder)
set DIFFICULTY=4
set TARGET=10000

:MAIN_MENU
cls
echo ================================================================================
echo                         QTC BLOCKCHAIN NODE v3.0
echo ================================================================================
echo.
echo  BLOCKCHAIN INFO:
echo    Network: MAINNET
echo    Block Height: %BLOCK_HEIGHT%
echo    Difficulty: %DIFFICULTY%
echo    Target Time: 10 minutes/block
echo.
echo  YOUR WALLET:
echo    Address: %WALLET%
echo    Balance: %BALANCE% QTC
echo.
echo  NODE STATUS:
echo    P2P Port: 8333
echo    RPC Port: 8332
echo    Peers: Searching...
echo.
echo --------------------------------------------------------------------------------
echo  OPTIONS:
echo    [M] Start Mining
echo    [W] Wallet Info
echo    [B] Blockchain Explorer
echo    [S] Sync Blockchain
echo    [Q] Quit
echo --------------------------------------------------------------------------------
echo.

choice /C MWBSQ /N /M "Select option: "

if errorlevel 5 goto SHUTDOWN
if errorlevel 4 goto SYNC
if errorlevel 3 goto EXPLORER
if errorlevel 2 goto WALLET_INFO
if errorlevel 1 goto START_MINING

goto MAIN_MENU

:START_MINING
cls
echo ================================================================================
echo                              MINING ACTIVE
echo ================================================================================
echo.
echo  Mining Parameters:
echo    Address: %WALLET%
echo    Difficulty: %DIFFICULTY%
echo    Block Reward: 10,000 QTC
echo    Target Time: 600 seconds
echo.
echo  Current Blockchain:
echo    Height: %BLOCK_HEIGHT%
echo    Your Balance: %BALANCE% QTC
echo.
echo --------------------------------------------------------------------------------
echo.

:: Initialize mining variables
set START_TIME=%TIME%
set /a NONCE=0
set /a ATTEMPTS=0
set MINING_START=%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%

:MINING_LOOP
set /a NONCE+=1
set /a ATTEMPTS+=1

:: Calculate hash (simplified)
set /a HASH=%NONCE% %% %TARGET%

:: Display mining progress every 100 attempts
set /a DISPLAY=%ATTEMPTS% %% 100
if %DISPLAY%==0 (
    set /a HASHRATE=%ATTEMPTS%/10
    echo  [%TIME:~0,8%] Block: %BLOCK_HEIGHT% ^| Nonce: %NONCE% ^| Hashrate: %HASHRATE% H/s ^| Attempts: %ATTEMPTS%
)

:: Check if block found (based on difficulty)
if %HASH%==0 (
    goto BLOCK_FOUND
)

:: Check if 10 minutes passed (simulated with attempts)
if %ATTEMPTS% GTR 6000 (
    echo.
    echo  Adjusting difficulty...
    set /a DIFFICULTY-=1
    if %DIFFICULTY% LSS 1 set DIFFICULTY=1
    set /a TARGET=10000/%DIFFICULTY%
    echo  New difficulty: %DIFFICULTY%
    echo.
)

:: Continue mining
ping localhost -n 1 >nul
goto MINING_LOOP

:BLOCK_FOUND
cls
echo ================================================================================
echo                           BLOCK MINED SUCCESSFULLY
echo ================================================================================
echo.

:: Calculate mining time
set END_TIME=%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
set /a MINING_TIME=%END_TIME%-%MINING_START%

:: Generate block data
set /a BLOCK_HEIGHT+=1
set BLOCK_HASH=%RANDOM%%RANDOM%%RANDOM%%RANDOM%
set BLOCK_TIME=%DATE% %TIME%

echo  Block #%BLOCK_HEIGHT%
echo  ----------------------------------------
echo  Hash: 0000%BLOCK_HASH%
echo  Previous: 0000%RANDOM%%RANDOM%
echo  Nonce: %NONCE%
echo  Attempts: %ATTEMPTS%
echo  Time: %BLOCK_TIME%
echo  Difficulty: %DIFFICULTY%
echo  Miner: %WALLET%
echo  Reward: 10,000 QTC
echo.

:: Save block to blockchain
echo Block: %BLOCK_HEIGHT% > blockchain\blocks\block_%BLOCK_HEIGHT%.dat
echo Hash: 0000%BLOCK_HASH% >> blockchain\blocks\block_%BLOCK_HEIGHT%.dat
echo Nonce: %NONCE% >> blockchain\blocks\block_%BLOCK_HEIGHT%.dat
echo Time: %BLOCK_TIME% >> blockchain\blocks\block_%BLOCK_HEIGHT%.dat
echo Miner: %WALLET% >> blockchain\blocks\block_%BLOCK_HEIGHT%.dat
echo Reward: 10000 >> blockchain\blocks\block_%BLOCK_HEIGHT%.dat

:: Update balance
set /a BALANCE+=10000
echo %BALANCE% > blockchain\balance.dat

:: Update blockchain index
echo %BLOCK_HEIGHT% > blockchain\index.dat

echo  NEW BALANCE: %BALANCE% QTC
echo  TOTAL BLOCKS MINED: %BLOCK_HEIGHT%
echo.
echo ================================================================================
echo.

:: Adjust difficulty for next block
if %ATTEMPTS% LSS 3000 (
    set /a DIFFICULTY+=1
    echo  Difficulty increased to %DIFFICULTY% for next block
)
if %ATTEMPTS% GTR 9000 (
    set /a DIFFICULTY-=1
    if %DIFFICULTY% LSS 1 set DIFFICULTY=1
    echo  Difficulty decreased to %DIFFICULTY% for next block
)

echo.
pause
goto MAIN_MENU

:WALLET_INFO
cls
echo ================================================================================
echo                            WALLET INFORMATION
echo ================================================================================
echo.
echo  Address: %WALLET%
echo  Balance: %BALANCE% QTC
echo.
echo  Transaction History:
echo  ----------------------------------------

:: Show recent blocks mined
for /L %%i in (%BLOCK_HEIGHT%,-1,1) do (
    if exist blockchain\blocks\block_%%i.dat (
        echo  Block #%%i - Reward: 10,000 QTC
        set /a COUNT+=1
        if !COUNT! GEQ 5 goto WALLET_DONE
    )
)

:WALLET_DONE
echo.
pause
goto MAIN_MENU

:EXPLORER
cls
echo ================================================================================
echo                          BLOCKCHAIN EXPLORER
echo ================================================================================
echo.
echo  Total Blocks: %BLOCK_HEIGHT%
echo  Total QTC Mined: %BALANCE%
echo.
echo  Recent Blocks:
echo  ----------------------------------------

dir blockchain\blocks\*.dat /B /O-D 2>nul | findstr /N "^" | findstr "^[1-5]:"

echo.
echo  Blockchain Data Location: %CD%\blockchain\
echo.
pause
goto MAIN_MENU

:SYNC
cls
echo ================================================================================
echo                         SYNCING BLOCKCHAIN
echo ================================================================================
echo.
echo  Connecting to network...
echo.
echo  Seed nodes:
echo    - seed1.qtc.network:8333
echo    - seed2.qtc.network:8333
echo    - seed3.qtc.network:8333
echo.
echo  Local blockchain height: %BLOCK_HEIGHT%
echo  Network blockchain height: Checking...
echo.
echo  [Simulated - Full P2P not implemented]
echo.
timeout /t 5
echo  Sync complete.
echo.
pause
goto MAIN_MENU

:SHUTDOWN
cls
echo.
echo  Saving blockchain state...
echo %BLOCK_HEIGHT% > blockchain\index.dat
echo %BALANCE% > blockchain\balance.dat
echo.
echo  Blockchain saved.
echo  Blocks mined: %BLOCK_HEIGHT%
echo  Total earned: %BALANCE% QTC
echo.
echo  Thank you for running QTC Node!
echo.
timeout /t 3
exit
