@echo off
title QTC Quick Miner
color 0A
cls

echo ================================================================================
echo                         QTC QUICK MINER
echo ================================================================================
echo.

if not exist wallet.dat (
    echo Creating wallet...
    echo QTC%RANDOM%%RANDOM%%RANDOM% > wallet.dat
    echo PRIVATE_%RANDOM%%RANDOM% >> wallet.dat
)

set /p WALLET=<wallet.dat
set BALANCE=0
set BLOCKS=0

echo  Your Wallet: %WALLET%
echo.
echo  Starting mining...
echo.

:MINE
set /a HASH=%RANDOM%
echo  [%TIME%] Mining... Hash: %HASH% - Balance: %BALANCE% QTC

set /a CHECK=%RANDOM% %% 10
if %CHECK% LSS 2 (
    echo.
    echo  *** BLOCK FOUND! +10,000 QTC ***
    set /a BALANCE+=10000
    set /a BLOCKS+=1
    echo  Total: %BALANCE% QTC - Blocks: %BLOCKS%
    echo.
)

timeout /t 1 >nul
goto MINE
