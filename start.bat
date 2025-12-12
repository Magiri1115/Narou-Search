@echo off
REM Windows用起動スクリプト for Narou Search

echo ========================================
echo    Narou Search Starting (Windows)
echo ========================================
echo.

REM 既存のプロセスを停止
echo Stopping existing servers on ports 5173 and 8000...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":5173" ^| find "LISTENING"') do taskkill /F /PID %%a 2>nul
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8000" ^| find "LISTENING"') do taskkill /F /PID %%a 2>nul
timeout /t 2 /nobreak >nul

REM Pythonコマンドを検出
where python3 >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set PYTHON_CMD=python3
) else (
    where python >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        set PYTHON_CMD=python
    ) else (
        echo Error: Python not found. Please install Python 3.6+
        echo Visit: https://www.python.org/downloads/
        pause
        exit /b 1
    )
)

REM Juliaコマンドを検出
where julia >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Julia not found. Please install Julia 1.6+
    echo Visit: https://julialang.org/downloads/
    pause
    exit /b 1
)

echo Using Julia: julia
echo Using Python: %PYTHON_CMD%
echo.

REM バックエンド起動
echo Starting backend (Julia/Genie on port 8000)...
cd backend
start /B julia --project=. server.jl
cd ..

REM 少し待機
timeout /t 3 /nobreak >nul

REM フロントエンド起動
echo Starting frontend (HTTP server on port 5173)...
cd frontend
start /B %PYTHON_CMD% -m http.server 5173
cd ..

echo.
echo ========================================
echo Servers started!
echo Frontend:    http://localhost:5173
echo Backend API: http://localhost:8000
echo ========================================
echo.
echo Press Ctrl+C to stop all servers
echo または、このウィンドウを閉じてください
echo.

pause
