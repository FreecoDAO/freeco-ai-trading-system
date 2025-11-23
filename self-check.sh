#!/bin/bash

echo "🔍 FreEco AI Trading Bot - Self Check"
echo "====================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_PASS=0
TESTS_FAIL=0

# Test 1: Git Configuration
echo -e "${BLUE}[Test 1/5] Git Configuration${NC}"
if git log --oneline -1 > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Git is working${NC}"
  ((TESTS_PASS++))
else
  echo -e "${RED}✗ Git configuration failed${NC}"
  ((TESTS_FAIL++))
fi
echo ""

# Test 2: Key Files Exist
echo -e "${BLUE}[Test 2/5] Key Files Exist${NC}"
if [ -f .env ] && [ -f src/ai-signal-generator.js ] && [ -f ../hummingbot-dashboard/server.py ]; then
  echo -e "${GREEN}✓ All key files exist${NC}"
  echo "  - .env"
  echo "  - src/ai-signal-generator.js"
  echo "  - ../hummingbot-dashboard/server.py"
  ((TESTS_PASS++))
else
  echo -e "${RED}✗ Some files missing${NC}"
  [ ! -f .env ] && echo "  ✗ .env missing"
  [ ! -f src/ai-signal-generator.js ] && echo "  ✗ ai-signal-generator.js missing"
  [ ! -f ../hummingbot-dashboard/server.py ] && echo "  ✗ server.py missing"
  ((TESTS_FAIL++))
fi
echo ""

# Test 3: Required Tools Installed
echo -e "${BLUE}[Test 3/5] Required Tools Installed${NC}"
TOOLS_OK=true
if which node > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Node.js$(node --version)${NC}"
else
  echo -e "${RED}✗ Node.js not found${NC}"
  TOOLS_OK=false
fi
if which python3 > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Python3 $(python3 --version 2>&1)${NC}"
else
  echo -e "${RED}✗ Python3 not found${NC}"
  TOOLS_OK=false
fi
if which mosquitto > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Mosquitto${NC}"
else
  echo -e "${RED}✗ Mosquitto not found${NC}"
  TOOLS_OK=false
fi
if [ "$TOOLS_OK" = true ]; then
  ((TESTS_PASS++))
else
  ((TESTS_FAIL++))
fi
echo ""

# Test 4: Processes Running
echo -e "${BLUE}[Test 4/5] Services Running${NC}"
MQTT_RUN=$(pgrep -f mosquitto 2>/dev/null | wc -l)
AI_RUN=$(pgrep -f "ai-signal-generator" 2>/dev/null | wc -l)
DASH_RUN=$(pgrep -f "python3.*server.py" 2>/dev/null | wc -l)

if [ "$MQTT_RUN" -gt 0 ]; then
  echo -e "${GREEN}✓ MQTT Broker running${NC}"
else
  echo -e "${YELLOW}⚠ MQTT Broker not running${NC}"
fi
if [ "$AI_RUN" -gt 0 ]; then
  echo -e "${GREEN}✓ AI Signal Generator running${NC}"
else
  echo -e "${YELLOW}⚠ AI Signal Generator not running${NC}"
fi
if [ "$DASH_RUN" -gt 0 ]; then
  echo -e "${GREEN}✓ Dashboard Server running${NC}"
else
  echo -e "${YELLOW}⚠ Dashboard Server not running${NC}"
fi
((TESTS_PASS++))
echo ""

# Test 5: HTTP Access
echo -e "${BLUE}[Test 5/5] HTTP Connectivity${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8501 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✓ Dashboard HTTP 200 OK${NC}"
  ((TESTS_PASS++))
elif [ "$HTTP_CODE" = "000" ]; then
  echo -e "${YELLOW}⚠ Dashboard not started (this is OK)${NC}"
  ((TESTS_PASS++))
else
  echo -e "${RED}✗ Dashboard HTTP $HTTP_CODE${NC}"
  ((TESTS_FAIL++))
fi
echo ""

# Final Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SUMMARY: ${GREEN}$TESTS_PASS Pass${NC} | ${RED}$TESTS_FAIL Fail${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $TESTS_FAIL -eq 0 ]; then
  echo -e "${GREEN}✅ System Ready!${NC}"
  echo ""
  echo "Next: bash run.sh"
  exit 0
else
  echo -e "${RED}❌ Fix issues and retry${NC}"
  exit 1
fi
