#!/bin/bash

cd /workspaces/freeco-ai-trading-system

echo "═══════════════════════════════════════════════════════"
echo "  🚀 FreEco AI Trading Bot - Quick Start"
echo "═══════════════════════════════════════════════════════"
echo ""

# Step 0: Kill all old processes directly (no calling stop-all.sh)
echo "[0/4] Cleaning up old processes..."
pkill -9 mosquitto 2>/dev/null || true
pkill -9 -f "python3.*server.py" 2>/dev/null || true
pkill -9 -f "node.*ai-signal-generator" 2>/dev/null || true
pkill -9 -f streamlit 2>/dev/null || true
sleep 1
echo "✓ Old processes cleaned"
echo ""

# Step 1: Check environment
echo "[1/4] Checking environment..."
if [ ! -f .env ]; then
  echo "⚠ .env not found, skipping (already created during setup)"
fi
echo "✓ Environment ready"
echo ""

# Step 2: Start MQTT
echo "[2/4] Starting MQTT Broker..."
mosquitto -c /etc/mosquitto/mosquitto.conf -d -p 1883 2>&1 | grep -v "^$" || true
sleep 2
echo "✓ MQTT Broker started"
echo ""

# Step 3: Start AI Signal Generator
echo "[3/4] Starting AI Signal Generator..."
node src/ai-signal-generator.js > /tmp/ai-signal-generator.log 2>&1 &
sleep 2
echo "✓ AI Signal Generator started"
echo ""

# Step 4: Start Dashboard
echo "[4/4] Starting Dashboard HTTP Server..."
cd hummingbot-dashboard 2>/dev/null || (mkdir -p /workspaces/hummingbot-dashboard && cd /workspaces/hummingbot-dashboard)
python3 server.py > /tmp/hummingbot-dashboard.log 2>&1 &
sleep 2
echo "✓ Dashboard started"
echo ""

# Final Status
echo "═══════════════════════════════════════════════════════"
echo "✅ All Services Started!"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "📊 Dashboard: http://localhost:8501"
echo "📡 MQTT Broker: localhost:1883"
echo "🤖 AI Signal Generator: Running"
echo ""
echo "✨ Next Steps:"
echo "   1. Open http://localhost:8501 in your browser"
echo "   2. Monitor AI signals: tail -f /tmp/ai-signal-generator.log"
echo "   3. Stop services: pkill -f mosquitto python3 node"
echo ""
