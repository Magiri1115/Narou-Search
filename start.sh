#!/bin/bash

# カラー出力用
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Narou Search Starting ===${NC}"

# バックエンド起動（バックグラウンド）
echo -e "${GREEN}Starting backend (Julia/Genie on port 8000)...${NC}"
cd backend
julia --project=. server.jl &
BACKEND_PID=$!
cd ..

# フロントエンド起動（バックグラウンド）
echo -e "${GREEN}Starting frontend (HTTP server on port 5173)...${NC}"
cd frontend
python3 -m http.server 5173 &
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
