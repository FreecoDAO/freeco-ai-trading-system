#!/bin/bash

set -e

echo "🚀 FreEco AI Trading Bot - Auto Run & Check"
echo "==========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cd /workspaces/freeco-ai-trading-system

# ============================================================
# STEP 1: Self Check
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}STEP 1: Running Self Check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "[Check 1/5] Git Configuration..."
if git log --oneline -1 > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Git working${NC}"
else
  echo -e "${YELLOW}⚠ Fixing Git...${NC}"
  git config --global --add safe.directory /workspaces/freeco-ai-trading-system
  echo -e "${GREEN}✓ Git fixed${NC}"
fi
echo ""

echo "[Check 2/5] Key Files..."
FILES_OK=true
[ -f .env ] && echo -e "${GREEN}✓ .env exists${NC}" || (echo -e "${RED}✗ .env missing${NC}"; FILES_OK=false)
[ -f src/ai-signal-generator.js ] && echo -e "${GREEN}✓ ai-signal-generator.js exists${NC}" || (echo -e "${RED}✗ ai-signal-generator.js missing${NC}"; FILES_OK=false)
[ -f ../hummingbot-dashboard/server.py ] && echo -e "${GREEN}✓ server.py exists${NC}" || (echo -e "${RED}✗ server.py missing${NC}"; FILES_OK=false)
echo ""

echo "[Check 3/5] Tools Installed..."
which node > /dev/null 2>&1 && echo -e "${GREEN}✓ Node.js$(node --version)${NC}" || echo -e "${RED}✗ Node.js missing${NC}"
which python3 > /dev/null 2>&1 && echo -e "${GREEN}✓ Python3${NC}" || echo -e "${RED}✗ Python3 missing${NC}"
which mosquitto > /dev/null 2>&1 && echo -e "${GREEN}✓ Mosquitto${NC}" || echo -e "${RED}✗ Mosquitto missing${NC}"
echo ""

echo "[Check 4/5] Cleanup Old Processes..."
pkill -9 mosquitto 2>/dev/null || true
pkill -9 -f "python3.*server.py" 2>/dev/null || true
pkill -9 -f "node.*ai-signal-generator" 2>/dev/null || true
lsof -ti:8501 2>/dev/null | xargs kill -9 2>/dev/null || true
sleep 2
echo -e "${GREEN}✓ Old processes cleaned${NC}"
echo ""

echo "[Check 5/5] Setup Complete..."
if [ -f setup-codespace.sh ]; then
  echo -e "${GREEN}✓ Setup script ready${NC}"
else
  echo -e "${RED}✗ Setup script missing${NC}"
fi
echo ""

# ============================================================
# STEP 2: Run Services
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}STEP 2: Starting Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Starting MQTT Broker..."
mosquitto -c /etc/mosquitto/mosquitto.conf -d -p 1883 2>/dev/null || true
sleep 2
echo -e "${GREEN}✓ MQTT started${NC}"
echo ""

echo "Starting AI Signal Generator..."
node src/ai-signal-generator.js > /tmp/ai-signal-generator.log 2>&1 &
AI_PID=$!
sleep 2
if kill -0 $AI_PID 2>/dev/null; then
  echo -e "${GREEN}✓ AI Signal Generator started (PID: $AI_PID)${NC}"
else
  echo -e "${RED}✗ AI Signal Generator failed${NC}"
  tail -10 /tmp/ai-signal-generator.log
fi
echo ""

echo "Starting Dashboard HTTP Server..."
cd ../hummingbot-dashboard
python3 server.py > /tmp/hummingbot-dashboard.log 2>&1 &
DASH_PID=$!
sleep 2
cd ../freeco-ai-trading-system
if kill -0 $DASH_PID 2>/dev/null; then
  echo -e "${GREEN}✓ Dashboard started (PID: $DASH_PID)${NC}"
else
  echo -e "${RED}✗ Dashboard failed${NC}"
  tail -10 /tmp/hummingbot-dashboard.log
fi
echo ""

# ============================================================
# STEP 3: Verify Services
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}STEP 3: Verifying Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "[Verify 1/6] MQTT Process..."
if pgrep -f mosquitto > /dev/null 2>&1; then
  echo -e "${GREEN}✓ MQTT process running${NC}"
else
  echo -e "${RED}✗ MQTT process NOT running${NC}"
fi
echo ""

echo "[Verify 2/6] MQTT Port 1883..."
if netstat -tlnp 2>/dev/null | grep -q 1883 || lsof -i :1883 2>/dev/null | grep -q LISTEN; then
  echo -e "${GREEN}✓ Port 1883 listening${NC}"
else
  echo -e "${RED}✗ Port 1883 NOT listening${NC}"
fi
echo ""

echo "[Verify 3/6] AI Signal Generator Process..."
if pgrep -f "ai-signal-generator" > /dev/null 2>&1; then
  echo -e "${GREEN}✓ AI process running${NC}"
else
  echo -e "${RED}✗ AI process NOT running${NC}"
fi
echo ""

echo "[Verify 4/6] Dashboard Process..."
if pgrep -f "python3.*server.py" > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Dashboard process running${NC}"
else
  echo -e "${RED}✗ Dashboard process NOT running${NC}"
fi
echo ""

echo "[Verify 5/6] Dashboard Port 8501..."
if netstat -tlnp 2>/dev/null | grep -q 8501 || lsof -i :8501 2>/dev/null | grep -q LISTEN; then
  echo -e "${GREEN}✓ Port 8501 listening${NC}"
else
  echo -e "${RED}✗ Port 8501 NOT listening${NC}"
fi
echo ""

echo "[Verify 6/6] HTTP Connectivity..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8501 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✓ Dashboard HTTP 200 OK${NC}"
elif [ "$HTTP_CODE" = "000" ]; then
  echo -e "${YELLOW}⚠ Dashboard not responding yet${NC}"
else
  echo -e "${RED}✗ Dashboard HTTP $HTTP_CODE${NC}"
fi
echo ""

# ============================================================
# FINAL REPORT
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}FINAL REPORT${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

MQTT_OK=$(pgrep -f mosquitto > /dev/null 2>&1 && echo "yes" || echo "no")
AI_OK=$(pgrep -f "ai-signal-generator" > /dev/null 2>&1 && echo "yes" || echo "no")
DASH_OK=$(pgrep -f "python3.*server.py" > /dev/null 2>&1 && echo "yes" || echo "no")

echo "System Status:"
[ "$MQTT_OK" = "yes" ] && echo -e "  ${GREEN}✓${NC} MQTT Broker running on localhost:1883" || echo -e "  ${RED}✗${NC} MQTT Broker NOT running"
[ "$AI_OK" = "yes" ] && echo -e "  ${GREEN}✓${NC} AI Signal Generator running" || echo -e "  ${RED}✗${NC} AI Signal Generator NOT running"
[ "$DASH_OK" = "yes" ] && echo -e "  ${GREEN}✓${NC} Dashboard HTTP Server running on http://localhost:8501" || echo -e "  ${RED}✗${NC} Dashboard HTTP Server NOT running"
echo ""

if [ "$MQTT_OK" = "yes" ] && [ "$AI_OK" = "yes" ] && [ "$DASH_OK" = "yes" ]; then
  echo -e "${GREEN}✅ ALL SYSTEMS OPERATIONAL!${NC}"
  echo ""
  echo "You can now:"
  echo "  1. Open dashboard: http://localhost:8501"
  echo "  2. Monitor logs: tail -f /tmp/ai-signal-generator.log"
  echo "  3. Test MQTT: mosquitto_sub -h localhost -t 'hbot/predictions/#' -v"
  echo ""
  exit 0
else
  echo -e "${RED}❌ SOME SYSTEMS NOT OPERATIONAL${NC}"
  echo ""
  echo "Checking logs..."
  echo ""
  echo "AI Signal Generator Log:"
  tail -5 /tmp/ai-signal-generator.log 2>/dev/null || echo "No log found"
  echo ""
  echo "Dashboard Log:"
  tail -5 /tmp/hummingbot-dashboard.log 2>/dev/null || echo "No log found"
  echo ""
  exit 1
fi
