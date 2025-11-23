#!/bin/bash

cd /workspaces/freeco-ai-trading-system

echo "🎯 COMPLETE SETUP - Finishing Everything"
echo "========================================"
echo ""

# Step 1: Start MQTT
echo "[1/5] Starting MQTT Broker..."
mosquitto -c /etc/mosquitto/mosquitto.conf -d -p 1883 2>/dev/null || true
sleep 2
if pgrep -f mosquitto > /dev/null 2>&1; then
  echo "✓ MQTT running"
else
  echo "✗ MQTT failed"
fi
echo ""

# Step 2: Start AI Signal Generator
echo "[2/5] Starting AI Signal Generator..."
node src/ai-signal-generator.js > /tmp/ai-signal-generator.log 2>&1 &
sleep 2
if pgrep -f "ai-signal-generator" > /dev/null 2>&1; then
  echo "✓ AI Signal Generator running"
else
  echo "✗ AI Signal Generator failed"
fi
echo ""

# Step 3: Start Dashboard
echo "[3/5] Starting Dashboard..."
cd ../hummingbot-dashboard
python3 server.py > /tmp/hummingbot-dashboard.log 2>&1 &
cd ../freeco-ai-trading-system
sleep 2
if pgrep -f "python3.*server.py" > /dev/null 2>&1; then
  echo "✓ Dashboard running"
else
  echo "✗ Dashboard failed"
fi
echo ""

# Step 4: Verify HTTP
echo "[4/5] Testing HTTP..."
HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8501 2>/dev/null)
if [ "$HTTP" = "200" ]; then
  echo "✓ HTTP 200 OK"
else
  echo "⚠ HTTP $HTTP (may be starting)"
fi
echo ""

# Step 5: Final Report
echo "[5/5] Final Report..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
MQTT=$(pgrep -f mosquitto > /dev/null 2>&1 && echo "✓ RUNNING" || echo "✗ FAILED")
AI=$(pgrep -f "ai-signal-generator" > /dev/null 2>&1 && echo "✓ RUNNING" || echo "✗ FAILED")
DASH=$(pgrep -f "python3.*server.py" > /dev/null 2>&1 && echo "✓ RUNNING" || echo "✗ FAILED")

echo "MQTT Broker: $MQTT"
echo "AI Signal Gen: $AI"
echo "Dashboard: $DASH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [[ "$MQTT" == "✓ RUNNING" ]] && [[ "$AI" == "✓ RUNNING" ]] && [[ "$DASH" == "✓ RUNNING" ]]; then
  echo "✅ SUCCESS - All systems operational!"
  echo ""
  echo "Dashboard: http://localhost:8501"
  echo "MQTT: localhost:1883"
  echo ""
  echo "Next: git add . && git commit -m 'feat: complete setup' && git push origin main"
else
  echo "❌ Some services failed"
  echo ""
  echo "Logs:"
  echo "  tail /tmp/ai-signal-generator.log"
  echo "  tail /tmp/hummingbot-dashboard.log"
fi
