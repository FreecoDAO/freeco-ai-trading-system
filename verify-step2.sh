#!/bin/bash

echo "🔍 Step 2 Verification - Testing the System"
echo "==========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

# Test 1: Check MQTT Broker
echo "${YELLOW}[Test 1/6] Checking MQTT Broker...${NC}"
if pgrep -f mosquitto > /dev/null; then
  echo -e "${GREEN}✓ MQTT Broker is running${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ MQTT Broker is NOT running${NC}"
  ((FAIL++))
fi
echo ""

# Test 2: Check MQTT Port
echo "${YELLOW}[Test 2/6] Checking MQTT Port 1883...${NC}"
if netstat -tlnp 2>/dev/null | grep 1883 > /dev/null || lsof -i :1883 2>/dev/null > /dev/null; then
  echo -e "${GREEN}✓ Port 1883 is open and listening${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ Port 1883 is NOT listening${NC}"
  ((FAIL++))
fi
echo ""

# Test 3: Check AI Signal Generator
echo "${YELLOW}[Test 3/6] Checking AI Signal Generator...${NC}"
if pgrep -f "ai-signal-generator" > /dev/null; then
  echo -e "${GREEN}✓ AI Signal Generator is running${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ AI Signal Generator is NOT running${NC}"
  ((FAIL++))
fi
echo ""

# Test 4: Check Dashboard HTTP Server
echo "${YELLOW}[Test 4/6] Checking Dashboard HTTP Server...${NC}"
if pgrep -f "python3.*server.py" > /dev/null; then
  echo -e "${GREEN}✓ Dashboard HTTP Server is running${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ Dashboard HTTP Server is NOT running${NC}"
  ((FAIL++))
fi
echo ""

# Test 5: Check Dashboard Port 8501
echo "${YELLOW}[Test 5/6] Checking Dashboard Port 8501...${NC}"
if netstat -tlnp 2>/dev/null | grep 8501 > /dev/null || lsof -i :8501 2>/dev/null > /dev/null; then
  echo -e "${GREEN}✓ Port 8501 is open and listening${NC}"
  ((PASS++))
else
  echo -e "${RED}✗ Port 8501 is NOT listening${NC}"
  ((FAIL++))
fi
echo ""

# Test 6: Test HTTP Access (no 401 error)
echo "${YELLOW}[Test 6/6] Testing Dashboard HTTP Access...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8501 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✓ Dashboard returns HTTP 200 (not 401)${NC}"
  ((PASS++))
elif [ "$HTTP_CODE" = "000" ]; then
  echo -e "${RED}✗ Cannot connect to http://localhost:8501${NC}"
  ((FAIL++))
else
  echo -e "${RED}✗ Dashboard returned HTTP $HTTP_CODE (expected 200)${NC}"
  ((FAIL++))
fi
echo ""

# Summary
echo "==========================================="
echo "Test Summary:"
echo -e "  ${GREEN}Passed: $PASS${NC}"
echo -e "  ${RED}Failed: $FAIL${NC}"
echo "==========================================="
echo ""

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}✅ ALL TESTS PASSED!${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Review log files (if needed):"
  echo "     tail -f /tmp/ai-signal-generator.log"
  echo "     tail -f /tmp/hummingbot-dashboard.log"
  echo ""
  echo "  2. If all tests passed, proceed to commit:"
  echo "     git add ."
  echo "     git commit -m 'feat: Replace Streamlit with HTTP dashboard...'"
  echo "     git push origin main"
  echo ""
  exit 0
else
  echo -e "${RED}❌ SOME TESTS FAILED${NC}"
  echo ""
  echo "Troubleshooting:"
  echo "  1. Check logs:"
  echo "     tail -20 /tmp/ai-signal-generator.log"
  echo "     tail -20 /tmp/hummingbot-dashboard.log"
  echo ""
  echo "  2. Run diagnostics:"
  echo "     bash diagnose.sh"
  echo ""
  echo "  3. Force restart:"
  echo "     bash force-restart.sh"
  echo "     sleep 2"
  echo "     bash run.sh"
  echo ""
  exit 1
fi
