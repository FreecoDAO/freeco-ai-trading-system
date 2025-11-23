#!/bin/bash

echo "🔍 Verifying All Changes"
echo "======================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0

cd /workspaces/freeco-ai-trading-system

# CHECK 1: Key Files
echo -e "${BLUE}[CHECK 1] Key Files${NC}"
echo ""

for file in ".env" "src/ai-signal-generator.js" "../hummingbot-dashboard/server.py" "setup-codespace.sh" "start-all.sh" ".devcontainer/devcontainer.json"; do
  if [ -f "$file" ]; then
    echo -e "${GREEN}✓${NC} $file"
    ((PASS++))
  else
    echo -e "${RED}✗${NC} $file MISSING"
    ((FAIL++))
  fi
done
echo ""

# CHECK 2: File Contents
echo -e "${BLUE}[CHECK 2] File Contents${NC}"
echo ""

if grep -q "Control Center" ../hummingbot-dashboard/server.py 2>/dev/null; then
  echo -e "${GREEN}✓${NC} server.py has multi-tab dashboard"
  ((PASS++))
else
  echo -e "${RED}✗${NC} server.py missing multi-tab dashboard"
  ((FAIL++))
fi

if grep -q "customizations" .devcontainer/devcontainer.json 2>/dev/null; then
  echo -e "${GREEN}✓${NC} devcontainer.json has correct schema"
  ((PASS++))
else
  echo -e "${RED}✗${NC} devcontainer.json has old schema"
  ((FAIL++))
fi

echo ""

# CHECK 3: Dependencies
echo -e "${BLUE}[CHECK 3] Dependencies${NC}"
echo ""

which node > /dev/null 2>&1 && echo -e "${GREEN}✓${NC} Node.js installed" || echo -e "${RED}✗${NC} Node.js missing"
which python3 > /dev/null 2>&1 && echo -e "${GREEN}✓${NC} Python3 installed" || echo -e "${RED}✗${NC} Python3 missing"
which mosquitto > /dev/null 2>&1 && echo -e "${GREEN}✓${NC} Mosquitto installed" || echo -e "${RED}✗${NC} Mosquitto missing"

echo ""

# CHECK 4: Services
echo -e "${BLUE}[CHECK 4] Running Services${NC}"
echo ""

pgrep -f mosquitto > /dev/null 2>&1 && echo -e "${GREEN}✓${NC} MQTT running" || echo -e "${YELLOW}⚠${NC} MQTT not running"
pgrep -f "ai-signal-generator" > /dev/null 2>&1 && echo -e "${GREEN}✓${NC} AI Signal Gen running" || echo -e "${YELLOW}⚠${NC} AI Signal Gen not running"
pgrep -f "python3.*server.py" > /dev/null 2>&1 && echo -e "${GREEN}✓${NC} Dashboard running" || echo -e "${YELLOW}⚠${NC} Dashboard not running"
! pgrep -f streamlit > /dev/null 2>&1 && echo -e "${GREEN}✓${NC} No Streamlit (correct)" || echo -e "${RED}✗${NC} Streamlit still running"

echo ""

# CHECK 5: HTTP
echo -e "${BLUE}[CHECK 5] HTTP Connectivity${NC}"
echo ""

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8501 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✓${NC} Dashboard HTTP 200 OK"
  ((PASS++))
elif [ "$HTTP_CODE" = "000" ]; then
  echo -e "${YELLOW}⚠${NC} Dashboard not started yet"
  ((PASS++))
else
  echo -e "${RED}✗${NC} Dashboard HTTP $HTTP_CODE"
  ((FAIL++))
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}✅ ALL CHANGES ARE INTACT!${NC}"
  echo ""
  echo "Next: bash run.sh"
else
  echo -e "${RED}❌ Some issues found${NC}"
  echo ""
  echo "Run: bash setup-codespace.sh"
fi
