#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WORKSPACE_DIR="/workspaces/freeco-ai-trading-system"

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🚀 FreEco AI Trading Bot - Quick Start${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"

# Step 0: Clean up old processes
echo -e "\n${YELLOW}[0/4] Cleaning up old processes...${NC}"
bash "$WORKSPACE_DIR/stop-all.sh" 2>/dev/null || true
sleep 2

# Kill any remaining process on port 8501
lsof -ti:8501 2>/dev/null | xargs kill -9 2>/dev/null || true
sleep 1

# Step 1: Check if setup is already done
echo -e "\n${YELLOW}[1/4] Checking system...${NC}"
cd "$WORKSPACE_DIR"

if [ ! -f ".env" ]; then
  echo -e "${YELLOW}Running setup (first time)...${NC}"
  if [ ! -f "setup-codespace.sh" ]; then
    echo -e "${RED}❌ setup-codespace.sh not found${NC}"
    exit 1
  fi
  bash setup-codespace.sh
  echo -e "${GREEN}✓ Setup complete${NC}"
else
  echo -e "${GREEN}✓ System already configured${NC}"
fi

# Step 2: Start services
echo -e "\n${YELLOW}[2/4] Starting services...${NC}"
bash start-all.sh
sleep 4

# Step 3: Verify services
echo -e "\n${YELLOW}[3/4] Verifying services...${NC}"

MQTT_RUNNING=$(pgrep -f "mosquitto" | wc -l)
AI_RUNNING=$(pgrep -f "ai-signal-generator" | wc -l)
DASHBOARD_RUNNING=$(pgrep -f "python3.*server.py" | wc -l)

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ FreEco AI Trading Bot is Running!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

if [ "$MQTT_RUNNING" -gt 0 ]; then
  echo -e "${GREEN}✓${NC} MQTT Broker: Running on localhost:1883"
else
  echo -e "${RED}✗${NC} MQTT Broker: Not running"
fi

if [ "$AI_RUNNING" -gt 0 ]; then
  echo -e "${GREEN}✓${NC} AI Signal Generator: Running (DeepSeek R1)"
else
  echo -e "${RED}✗${NC} AI Signal Generator: Not running"
fi

if [ "$DASHBOARD_RUNNING" -gt 0 ]; then
  echo -e "${GREEN}✓${NC} Dashboard HTTP Server: Running on http://localhost:8501"
else
  echo -e "${RED}✗${NC} Dashboard HTTP Server: Not running"
fi

echo ""
echo -e "${BLUE}📊 Dashboard Access:${NC}"
echo -e "   Browser: ${YELLOW}http://localhost:8501${NC}"
echo -e "   GitHub Codespaces: ${YELLOW}https://your-codespace-8501.app.github.dev${NC}"
echo ""

echo -e "${BLUE}📡 Monitor Live Signals:${NC}"
echo -e "   ${YELLOW}mosquitto_sub -h localhost -t 'hbot/predictions/#' -v${NC}"
echo ""

echo -e "${BLUE}📋 View Logs:${NC}"
echo -e "   AI Signals: ${YELLOW}tail -f /tmp/ai-signal-generator.log${NC}"
echo -e "   Dashboard: ${YELLOW}tail -f /tmp/hummingbot-dashboard.log${NC}"
echo ""

echo -e "${BLUE}🛑 Stop All Services:${NC}"
echo -e "   ${YELLOW}bash stop-all.sh${NC}"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}System is ready! Opening dashboard in 2 seconds...${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"

sleep 2
bash open-dashboard.sh 2>/dev/null || echo "📖 Open http://localhost:8501 in your browser"
