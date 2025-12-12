@echo off
setlocal enabledelayedexpansion
REM Windows用起動スクリプト for Narou Search

echo ========================================
echo    Narou Search Starting (Windows)
echo ========================================
echo.

REM 既存のプロセスを停止
echo Stopping existing servers on ports 5173 and 8000...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":5173.*LISTENING"') do (
    taskkill /F /PID %%a 2>nul
)
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8000.*LISTENING"') do (
    taskkill /F /PID %%a 2>nul
)
timeout /t 2 /nobreak >nul

echo.
echo Checking for required software...
echo.

REM Pythonコマンドを検出
set PYTHON_CMD=
where python3 >nul 2>nul
if !ERRORLEVEL! EQU 0 (
    set PYTHON_CMD=python3
    echo [OK] Python3 found
) else (
    where python >nul 2>nul
    if !ERRORLEVEL! EQU 0 (
        set PYTHON_CMD=python
        echo [OK] Python found
    ) else (
        echo [X] Error: Python not found. Please install Python 3.6+
        echo     Visit: https://www.python.org/downloads/
        echo.
        pause
        exit /b 1
    )
)

REM Juliaコマンドを検出
where julia >nul 2>nul
if !ERRORLEVEL! NEQ 0 (
    echo [X] Error: Julia not found. Please install Julia 1.6+
    echo     Visit: https://julialang.org/downloads/
    echo.
    pause
    exit /b 1
) else (
    echo [OK] Julia found
)

echo.
echo Using Julia: julia
echo Using Python: !PYTHON_CMD!
echo.

REM バックエンド起動
echo Starting backend (Julia/Genie on port 8000)...
cd backend
if not exist "server.jl" (
    echo [X] Error: server.jl not found in backend directory
    cd ..
    pause
    exit /b 1
)
start /B julia --project=. server.jl
cd ..
echo [OK] Backend started

REM 少し待機
timeout /t 3 /nobreak >nul

REM フロントエンド起動
echo Starting frontend (HTTP server on port 5173)...
cd frontend
if not exist "index.html" (
    echo [X] Error: index.html not found in frontend directory
    cd ..
    pause
    exit /b 1
)
start /B !PYTHON_CMD! -m http.server 5173
cd ..
echo [OK] Frontend started

echo.
echo ========================================
echo Servers started successfully!
echo Frontend:    http://localhost:5173
echo Backend API: http://localhost:8000
echo ========================================
echo.
echo Press any key to stop all servers...
echo (or close this window)
echo.

pause >nul

REM サーバーを停止
echo.
echo Stopping servers...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":5173.*LISTENING"') do taskkill /F /PID %%a 2>nul
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8000.*LISTENING"') do taskkill /F /PID %%a 2>nul
echo Servers stopped.
timeout /t 2 >nul
