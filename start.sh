#!/bin/bash

# カラー出力用
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Narou Search Starting ===${NC}"

# OS検出
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo -e "${BLUE}Detected OS: ${MACHINE}${NC}"

# 既存のプロセスをkill
echo -e "${YELLOW}Stopping existing servers on ports 5173 and 8000...${NC}"
if [[ "$MACHINE" == "Mac" ]] || [[ "$MACHINE" == "Linux" ]]; then
    lsof -ti:5173,8000 | xargs kill -9 2>/dev/null || true
    pkill -9 -f "python3 -m http.server 5173" 2>/dev/null || true
    pkill -9 -f "julia.*server.jl" 2>/dev/null || true
else
    # Windows (Git Bash/MinGw/Cygwin)
    netstat -ano | grep ":5173" | awk '{print $5}' | xargs -r taskkill //PID //F 2>/dev/null || true
    netstat -ano | grep ":8000" | awk '{print $5}' | xargs -r taskkill //PID //F 2>/dev/null || true
fi
sleep 1

# Pythonコマンドを検出
if command -v python3 &> /dev/null; then
    PYTHON_CMD=python3
elif command -v python &> /dev/null; then
    PYTHON_CMD=python
else
    echo -e "${YELLOW}Warning: Python not found. Please install Python 3.6+${NC}"
    exit 1
fi

# Juliaコマンドを検出
if command -v julia &> /dev/null; then
    JULIA_CMD=julia
else
    echo -e "${YELLOW}Error: Julia not found. Please install Julia 1.6+${NC}"
    echo -e "${YELLOW}Visit: https://julialang.org/downloads/${NC}"
    exit 1
fi

echo -e "${GREEN}Using Julia: ${JULIA_CMD}${NC}"
echo -e "${GREEN}Using Python: ${PYTHON_CMD}${NC}"

# バックエンド起動（バックグラウンド）
echo -e "${GREEN}Starting backend (Julia/Genie on port 8000)...${NC}"
cd backend
$JULIA_CMD --project=. server.jl &
BACKEND_PID=$!
cd ..

# フロントエンド起動（バックグラウンド）
echo -e "${GREEN}Starting frontend (HTTP server on port 5173)...${NC}"
cd frontend
$PYTHON_CMD -m http.server 5173 &
FRONTEND_PID=$!
cd ..

echo -e "${BLUE}Servers started!${NC}"
echo -e "Frontend: ${GREEN}http://localhost:5173${NC}"
echo -e "Backend API: ${GREEN}http://localhost:8000${NC}"
echo ""
echo "Press Ctrl+C to stop all servers"

# Ctrl+Cで両方のサーバーを停止
trap "echo -e '\n${BLUE}Stopping servers...${NC}'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT

# プロセスが終了するまで待機
wait
