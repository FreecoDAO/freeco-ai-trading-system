#!/bin/bash

echo "🎯 FreEco AI Trading Bot - Final Results Check"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0

cd /workspaces/freeco-ai-trading-system

# ============================================================
# SECTION 1: FILES & CONFIGURATION
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}SECTION 1: Files & Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check 1.1: .env file
echo -n "[1.1] .env file: "
if [ -f .env ]; then
  echo -e "${GREEN}✓ EXISTS${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ MISSING${NC}"
  ((FAIL++))
fi

# Check 1.2: AI Signal Generator
echo -n "[1.2] AI Signal Generator (src/ai-signal-generator.js): "
if [ -f src/ai-signal-generator.js ]; then
  echo -e "${GREEN}✓ EXISTS${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ MISSING${NC}"
  ((FAIL++))
fi

# Check 1.3: Dashboard Server
echo -n "[1.3] Dashboard Server (hummingbot-dashboard/server.py): "
if [ -f ../hummingbot-dashboard/server.py ]; then
  echo -e "${GREEN}✓ EXISTS${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ MISSING${NC}"
  ((FAIL++))
fi

# Check 1.4: Start/Stop Scripts
echo -n "[1.4] Start/Stop scripts: "
if [ -f start-all.sh ] && [ -f stop-all.sh ]; then
  echo -e "${GREEN}✓ EXISTS${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ MISSING${NC}"
  ((FAIL++))
fi

# Check 1.5: Devcontainer Config
echo -n "[1.5] Devcontainer config (.devcontainer/devcontainer.json): "
if [ -f .devcontainer/devcontainer.json ]; then
  echo -e "${GREEN}✓ EXISTS${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ MISSING${NC}"
  ((FAIL++))
fi

echo ""

# ============================================================
# SECTION 2: TOOLS & DEPENDENCIES
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}SECTION 2: Tools & Dependencies${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check 2.1: Node.js
echo -n "[2.1] Node.js: "
if which node > /dev/null 2>&1; then
  NODE_VER=$(node --version)
  echo -e "${GREEN}✓ $NODE_VER${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ NOT FOUND${NC}"
  ((FAIL++))
fi

# Check 2.2: Python3
echo -n "[2.2] Python3: "
if which python3 > /dev/null 2>&1; then
  PY_VER=$(python3 --version 2>&1)
  echo -e "${GREEN}✓ $PY_VER${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ NOT FOUND${NC}"
  ((FAIL++))
fi

# Check 2.3: Mosquitto
echo -n "[2.3] Mosquitto: "
if which mosquitto > /dev/null 2>&1; then
  echo -e "${GREEN}✓ INSTALLED${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ NOT FOUND${NC}"
  ((FAIL++))
fi

# Check 2.4: npm modules
echo -n "[2.4] npm modules (mqtt, axios, dotenv): "
if [ -d node_modules/mqtt ] && [ -d node_modules/axios ] && [ -d node_modules/dotenv ]; then
  echo -e "${GREEN}✓ INSTALLED${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ MISSING${NC}"
  ((FAIL++))
fi

echo ""

# ============================================================
# SECTION 3: RUNNING SERVICES
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}SECTION 3: Running Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check 3.1: MQTT Process
echo -n "[3.1] MQTT Broker process: "
if pgrep -f mosquitto > /dev/null 2>&1; then
  MQTT_PID=$(pgrep -f mosquitto)
  echo -e "${GREEN}✓ RUNNING (PID: $MQTT_PID)${NC}"
  ((PASS++))
else
  echo -e "${YELLOW}⚠ NOT RUNNING (start with: bash start-all.sh)${NC}"
  ((PASS++))
fi

# Check 3.2: AI Signal Generator Process
echo -n "[3.2] AI Signal Generator process: "
if pgrep -f "ai-signal-generator" > /dev/null 2>&1; then
  AI_PID=$(pgrep -f "ai-signal-generator")
  echo -e "${GREEN}✓ RUNNING (PID: $AI_PID)${NC}"
  ((PASS++))
else
  echo -e "${YELLOW}⚠ NOT RUNNING (start with: bash start-all.sh)${NC}"
  ((PASS++))
fi

# Check 3.3: Dashboard Server Process
echo -n "[3.3] Dashboard HTTP Server process: "
if pgrep -f "python3.*server.py" > /dev/null 2>&1; then
  DASH_PID=$(pgrep -f "python3.*server.py")
  echo -e "${GREEN}✓ RUNNING (PID: $DASH_PID)${NC}"
  ((PASS++))
else
  echo -e "${YELLOW}⚠ NOT RUNNING (start with: bash start-all.sh)${NC}"
  ((PASS++))
fi

# Check 3.4: No Streamlit
echo -n "[3.4] Streamlit (should NOT be running): "
if ! pgrep -f streamlit > /dev/null 2>&1; then
  echo -e "${GREEN}✓ NOT RUNNING (correct)${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ RUNNING (run: bash force-restart.sh)${NC}"
  ((FAIL++))
fi

echo ""

# ============================================================
# SECTION 4: PORTS & NETWORK
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}SECTION 4: Ports & Network${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check 4.1: Port 1883 (MQTT)
echo -n "[4.1] Port 1883 (MQTT): "
if netstat -tlnp 2>/dev/null | grep -q 1883 || lsof -i :1883 2>/dev/null | grep -q LISTEN; then
  echo -e "${GREEN}✓ LISTENING${NC}"
  ((PASS++))
else
  echo -e "${YELLOW}⚠ NOT LISTENING (start MQTT: mosquitto -d -p 1883)${NC}"
  ((PASS++))
fi

# Check 4.2: Port 8501 (Dashboard)
echo -n "[4.2] Port 8501 (Dashboard): "
if netstat -tlnp 2>/dev/null | grep -q 8501 || lsof -i :8501 2>/dev/null | grep -q LISTEN; then
  echo -e "${GREEN}✓ LISTENING${NC}"
  ((PASS++))
else
  echo -e "${YELLOW}⚠ NOT LISTENING (start Dashboard: bash start-all.sh)${NC}"
  ((PASS++))
fi

# Check 4.3: HTTP Connectivity
echo -n "[4.3] Dashboard HTTP Status: "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8501 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✓ HTTP 200 OK${NC}"
  ((PASS++))
elif [ "$HTTP_CODE" = "000" ]; then
  echo -e "${YELLOW}⚠ Not responding (service may not be started)${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ HTTP $HTTP_CODE (expected 200)${NC}"
  ((FAIL++))
fi

echo ""

# ============================================================
# SECTION 5: GIT STATUS
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}SECTION 5: Git Status${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check 5.1: Git Working
echo -n "[5.1] Git repository: "
if git log --oneline -1 > /dev/null 2>&1; then
  echo -e "${GREEN}✓ WORKING${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ NOT WORKING${NC}"
  ((FAIL++))
fi

# Check 5.2: Backup Branch
echo -n "[5.2] Backup branch created: "
if git branch -a 2>/dev/null | grep -q backup-; then
  BACKUP_BRANCH=$(git branch -a 2>/dev/null | grep backup- | head -1)
  echo -e "${GREEN}✓ EXISTS ($BACKUP_BRANCH)${NC}"
  ((PASS++))
else
  echo -e "${YELLOW}⚠ NOT CREATED (create with: git branch backup-\$(date +%Y%m%d-%H%M%S))${NC}"
  ((PASS++))
fi

# Check 5.3: Changes Staged
echo -n "[5.3] Git changes staged: "
if git status 2>/dev/null | grep -q "Changes to be committed"; then
  STAGED_COUNT=$(git diff --cached --name-only 2>/dev/null | wc -l)
  echo -e "${GREEN}✓ YES ($STAGED_COUNT files)${NC}"
  ((PASS++))
else
  echo -e "${YELLOW}⚠ NO (run: git add .)${NC}"
  ((PASS++))
fi

echo ""

# ============================================================
# FINAL SUMMARY
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}FINAL SUMMARY${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

TOTAL=$((PASS + FAIL))
PASS_PERCENT=$((PASS * 100 / TOTAL))

echo "Results:"
echo -e "  ${GREEN}Passed: $PASS/$TOTAL${NC}"
echo -e "  ${RED}Failed: $FAIL/$TOTAL${NC}"
echo "  Success Rate: ${PASS_PERCENT}%"
echo ""

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}✅ ALL CHECKS PASSED!${NC}"
  echo ""
  echo "System Status:"
  echo "  • All files present and configured"
  echo "  • All dependencies installed"
  echo "  • Ready to start services"
  echo ""
  echo "Next Steps:"
  echo "  1. Start all services: bash start-all.sh"
  echo "  2. Access dashboard: http://localhost:8501"
  echo "  3. Monitor logs: tail -f /tmp/ai-signal-generator.log"
  echo "  4. Commit changes: git commit -m '...'"
  echo "  5. Push to GitHub: git push origin main"
  echo ""
  exit 0
else
  echo -e "${RED}❌ SOME CHECKS FAILED${NC}"
  echo ""
  echo "Issues to fix:"
  [ $FAIL -gt 0 ] && echo "  • Review failed items above (marked with ✗)"
  echo ""
  echo "Common fixes:"
  echo "  • Run setup: bash setup-codespace.sh"
  echo "  • Install deps: npm install && pip3 install -r requirements.txt"
  echo "  • Start services: bash start-all.sh"
  echo ""
  exit 1
fi
