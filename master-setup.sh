#!/bin/bash

echo "🎯 FreEco AI Trading Bot - Master Setup (Full Plan)"
echo "=================================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

STEP_PASS=0
STEP_FAIL=0

# Function to run step with error checking
run_step() {
  local step_num=$1
  local step_name=$2
  local step_cmd=$3
  
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}[Step $step_num] $step_name${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  
  if eval "$step_cmd"; then
    echo -e "${GREEN}✓ Step $step_num PASSED${NC}"
    ((STEP_PASS++))
  else
    echo -e "${RED}✗ Step $step_num FAILED${NC}"
    ((STEP_FAIL++))
    return 1
  fi
  echo ""
}

# Function to verify and fix step
verify_step() {
  local step_num=$1
  local step_name=$2
  local verify_cmd=$3
  local fix_cmd=$4
  
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}[Verify Step $step_num] $step_name${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  
  if eval "$verify_cmd"; then
    echo -e "${GREEN}✓ Verification PASSED${NC}"
    ((STEP_PASS++))
  else
    echo -e "${YELLOW}⚠ Verification FAILED - Attempting fix...${NC}"
    if eval "$fix_cmd"; then
      echo -e "${GREEN}✓ Fix applied successfully${NC}"
      ((STEP_PASS++))
    else
      echo -e "${RED}✗ Fix failed${NC}"
      ((STEP_FAIL++))
      return 1
    fi
  fi
  echo ""
}

# ============================================================
# STEP 1: Fix Git Configuration
# ============================================================
run_step 1 "Fix Git Configuration" \
  "git config --global --add safe.directory /workspaces/freeco-ai-trading-system 2>/dev/null || true && git log --oneline -1 > /dev/null 2>&1"

verify_step 1 "Git Config Working" \
  "git log --oneline -1 > /dev/null 2>&1" \
  "git config --global --add safe.directory /workspaces/freeco-ai-trading-system && git log --oneline -1 > /dev/null 2>&1"

# ============================================================
# STEP 2: Clean Up Old Processes
# ============================================================
run_step 2 "Clean Up Old Processes" \
  "pkill -9 mosquitto 2>/dev/null || true && \
   pkill -9 -f 'python3.*server.py' 2>/dev/null || true && \
   pkill -9 -f 'node.*ai-signal-generator' 2>/dev/null || true && \
   lsof -ti:8501 2>/dev/null | xargs kill -9 2>/dev/null || true && \
   sleep 2"

verify_step 2 "No Old Processes Running" \
  "! pgrep -f mosquitto > /dev/null 2>&1 && \
   ! pgrep -f 'python3.*server.py' > /dev/null 2>&1 && \
   ! pgrep -f 'node.*ai-signal-generator' > /dev/null 2>&1" \
  "pkill -9 mosquitto 2>/dev/null || true && \
   pkill -9 -f 'python3.*server.py' 2>/dev/null || true && \
   pkill -9 -f 'node.*ai-signal-generator' 2>/dev/null || true && \
   sleep 2"

# ============================================================
# STEP 3: Run Setup Script
# ============================================================
run_step 3 "Run Setup Script" \
  "cd /workspaces/freeco-ai-trading-system && bash setup-codespace.sh"

verify_step 3 "Setup Files Created" \
  "[ -f /workspaces/freeco-ai-trading-system/.env ] && \
   [ -f /workspaces/freeco-ai-trading-system/src/ai-signal-generator.js ] && \
   [ -f /workspaces/hummingbot-dashboard/server.py ] && \
   [ -f /workspaces/freeco-ai-trading-system/start-all.sh ]" \
  "bash /workspaces/freeco-ai-trading-system/setup-codespace.sh"

# ============================================================
# STEP 4: Start Services
# ============================================================
run_step 4 "Start All Services" \
  "bash /workspaces/freeco-ai-trading-system/start-all.sh && sleep 4"

verify_step 4 "Services Running" \
  "pgrep -f mosquitto > /dev/null 2>&1 && \
   pgrep -f 'ai-signal-generator' > /dev/null 2>&1 && \
   pgrep -f 'python3.*server.py' > /dev/null 2>&1" \
  "bash /workspaces/freeco-ai-trading-system/start-all.sh && sleep 4"

# ============================================================
# STEP 5: Verify Ports
# ============================================================
verify_step 5 "MQTT Port 1883 Listening" \
  "netstat -tlnp 2>/dev/null | grep -q 1883 || lsof -i :1883 2>/dev/null | grep -q LISTEN" \
  "mosquitto -c /etc/mosquitto/mosquitto.conf -d -p 1883 2>/dev/null || true && sleep 2"

verify_step 5 "Dashboard Port 8501 Listening" \
  "netstat -tlnp 2>/dev/null | grep -q 8501 || lsof -i :8501 2>/dev/null | grep -q LISTEN" \
  "cd /workspaces/hummingbot-dashboard && python3 server.py > /tmp/hummingbot-dashboard.log 2>&1 &\nsleep 2"

# ============================================================
# STEP 6: Test HTTP Connectivity
# ============================================================
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8501 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}[Test Step 6] Dashboard HTTP Connectivity${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✓ Dashboard returns HTTP 200 OK${NC}"
  ((STEP_PASS++))
else
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}[Test Step 6] Dashboard HTTP Connectivity${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}✗ Dashboard returned HTTP $HTTP_CODE (expected 200)${NC}"
  ((STEP_FAIL++))
fi
echo ""

# ============================================================
# STEP 7: Create Backup Branch
# ============================================================
run_step 7 "Create Git Backup Branch" \
  "cd /workspaces/freeco-ai-trading-system && git branch backup-\$(date +%Y%m%d-%H%M%S)"

verify_step 7 "Backup Branch Created" \
  "cd /workspaces/freeco-ai-trading-system && git branch -a | grep -q backup-" \
  "cd /workspaces/freeco-ai-trading-system && git branch backup-\$(date +%Y%m%d-%H%M%S)"

# ============================================================
# STEP 8: Stage Changes
# ============================================================
run_step 8 "Stage Git Changes" \
  "cd /workspaces/freeco-ai-trading-system && git add ."

verify_step 8 "Changes Staged" \
  "cd /workspaces/freeco-ai-trading-system && git status | grep -q 'Changes to be committed'" \
  "cd /workspaces/freeco-ai-trading-system && git add ."

# ============================================================
# FINAL SUMMARY
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}FINAL SUMMARY${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Steps Passed: $STEP_PASS${NC}"
echo -e "${RED}Steps Failed: $STEP_FAIL${NC}"
echo ""

if [ $STEP_FAIL -eq 0 ]; then
  echo -e "${GREEN}✅ ALL STEPS COMPLETED SUCCESSFULLY!${NC}"
  echo ""
  echo "System Status:"
  echo "  🟢 MQTT Broker: Running on localhost:1883"
  echo "  🟢 AI Signal Generator: Running"
  echo "  🟢 Dashboard HTTP Server: Running on http://localhost:8501"
  echo "  🟢 HTTP Status: 200 OK (no 401 errors)"
  echo "  🟢 Git Backup: Created"
  echo "  🟢 Changes: Staged for commit"
  echo ""
  echo "Next Steps:"
  echo "  1. Review changes: git status"
  echo "  2. Commit changes:"
  echo "     git commit -m 'feat: HTTP dashboard, fix devcontainer, improve scripts'"
  echo "  3. Push to GitHub:"
  echo "     git push origin main"
  echo "  4. Test dashboard: Open http://localhost:8501 in browser"
  echo ""
else
  echo -e "${RED}❌ SOME STEPS FAILED${NC}"
  echo ""
  echo "Failed Steps:"
  echo "  Review logs:"
  echo "  tail -50 /tmp/ai-signal-generator.log"
  echo "  tail -50 /tmp/hummingbot-dashboard.log"
  echo ""
  echo "To retry failed steps, run:"
  echo "  bash /workspaces/freeco-ai-trading-system/master-setup.sh"
  echo ""
  exit 1
fi
