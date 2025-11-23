#!/bin/bash

echo "📊 FreEco AI Trading Bot - Status Check"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== PROCESS STATUS ===${NC}"
echo ""

# Check MQTT
echo -n "MQTT Broker: "
if pgrep -f mosquitto > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Running${NC}"
  MQTT_PID=$(pgrep -f mosquitto)
  echo "  PID: $MQTT_PID"
else
  echo -e "${RED}✗ NOT Running${NC}"
fi
echo ""

# Check AI Signal Generator
echo -n "AI Signal Generator: "
if pgrep -f "ai-signal-generator" > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Running${NC}"
  AI_PID=$(pgrep -f "ai-signal-generator")
  echo "  PID: $AI_PID"
else
  echo -e "${RED}✗ NOT Running${NC}"
fi
echo ""

# Check Dashboard
echo -n "Dashboard HTTP Server: "
if pgrep -f "python3.*server.py" > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Running${NC}"
  DASH_PID=$(pgrep -f "python3.*server.py")
  echo "  PID: $DASH_PID"
else
  echo -e "${RED}✗ NOT Running${NC}"
fi
echo ""

echo -e "${BLUE}=== PORT STATUS ===${NC}"
echo ""

# Check ports
echo -n "Port 1883 (MQTT): "
if netstat -tlnp 2>/dev/null | grep -q 1883 || lsof -i :1883 2>/dev/null | grep -q LISTEN; then
  echo -e "${GREEN}✓ Listening${NC}"
else
  echo -e "${RED}✗ NOT Listening${NC}"
fi
echo ""

echo -n "Port 8501 (Dashboard): "
if netstat -tlnp 2>/dev/null | grep -q 8501 || lsof -i :8501 2>/dev/null | grep -q LISTEN; then
  echo -e "${GREEN}✓ Listening${NC}"
else
  echo -e "${RED}✗ NOT Listening${NC}"
fi
echo ""

echo -e "${BLUE}=== HTTP CONNECTIVITY ===${NC}"
echo ""

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8501 2>/dev/null)
echo -n "Dashboard HTTP Status: "
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✓ HTTP 200 OK${NC}"
elif [ "$HTTP_CODE" = "000" ]; then
  echo -e "${RED}✗ Cannot connect${NC}"
else
  echo -e "${YELLOW}⚠ HTTP $HTTP_CODE${NC}"
fi
echo ""

echo -e "${BLUE}=== LOG FILES ===${NC}"
echo ""

echo "AI Signal Generator Log (last 5 lines):"
if [ -f /tmp/ai-signal-generator.log ]; then
  tail -5 /tmp/ai-signal-generator.log | sed 's/^/  /'
else
  echo "  Log file not found"
fi
echo ""

echo "Dashboard Log (last 5 lines):"
if [ -f /tmp/hummingbot-dashboard.log ]; then
  tail -5 /tmp/hummingbot-dashboard.log | sed 's/^/  /'
else
  echo "  Log file not found"
fi
echo ""

echo -e "${BLUE}=== RECOMMENDATIONS ===${NC}"
echo ""

if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✅ System appears to be working!${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Open dashboard: http://localhost:8501"
  echo "  2. Check Git status: git status"
  echo "  3. Commit changes:"
  echo "     git add ."
  echo "     git commit -m 'feat: HTTP dashboard, fix devcontainer'"
  echo "  4. Push to GitHub: git push origin main"
else
  echo -e "${RED}⚠️  System may have issues${NC}"
  echo ""
  echo "Troubleshooting:"
  echo "  1. View full logs:"
  echo "     tail -50 /tmp/ai-signal-generator.log"
  echo "     tail -50 /tmp/hummingbot-dashboard.log"
  echo "  2. Force restart:"
  echo "     bash /workspaces/freeco-ai-trading-system/force-restart.sh"
  echo "     sleep 2"
  echo "     bash /workspaces/freeco-ai-trading-system/quickstart.sh"
fi
echo ""
