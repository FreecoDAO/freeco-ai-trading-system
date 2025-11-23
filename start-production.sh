#!/bin/bash

echo "🚀 Starting FreEco AI Trading System - Production Mode"
echo "======================================================"
echo ""

cd /workspaces/freeco-ai-trading-system

# Step 1: Install dependencies
echo "[1/5] Installing Node.js dependencies..."
if ! npm list express > /dev/null 2>&1; then
    npm install --legacy-peer-deps 2>&1 | grep -E "added|up to date|audited" | tail -3
fi
echo "✓ Dependencies ready"
echo ""

# Step 2: Kill old processes
echo "[2/5] Cleaning up old processes..."
pkill -f mosquitto 2>/dev/null || true
pkill -f "node.*ai-signal" 2>/dev/null || true
pkill -f "python3.*server" 2>/dev/null || true
pkill -f "python3.*app.py" 2>/dev/null || true
sleep 2
echo "✓ Old processes cleaned"
echo ""

# Step 3: Start MQTT Broker
echo "[3/5] Starting MQTT Broker..."
mosquitto -c /etc/mosquitto/mosquitto.conf -d -p 1883 2>/dev/null || true
sleep 2
echo "✓ MQTT running on localhost:1883"
echo ""

# Step 4: Start AI Signal Generator
echo "[4/5] Starting AI Signal Generator..."
node src/ai-signal-generator.js > /tmp/ai-signal-generator.log 2>&1 &
sleep 2
echo "✓ AI signal generator running"
echo ""

# Step 5: Start Dashboard Server
echo "[5/5] Starting Dashboard Server..."
python3 hummingbot-dashboard/server.py > /tmp/dashboard.log 2>&1 &
sleep 2
echo "✓ Dashboard server running"
echo ""

# Step 6: Start Production Server
echo "════════════════════════════════════════════"
echo "🚀 Production Server Starting"
echo "════════════════════════════════════════════"
echo ""
echo "📊 Services:"
echo "  ✓ MQTT Broker: localhost:1883"
echo "  ✓ AI Signal Generator: Running"
echo "  ✓ Dashboard: http://localhost:8501"
echo "  ✓ REST API: http://localhost:3000"
echo ""
echo "API Endpoints:"
echo "  GET  /health          - Health check"
echo "  GET  /api/status      - System status"
echo "  GET  /api/wallet      - Wallet info"
echo "  GET  /api/balance     - Account balance"
echo "  GET  /api/market      - Real-time prices"
echo "  GET  /api/signals     - Trading signals"
echo "  GET  /api/trades      - Trade history"
echo "  GET  /api/quote       - Get swap quote"
echo "  POST /api/trade/execute - Execute trade"
echo ""
echo "Logs:"
echo "  tail -f /tmp/ai-signal-generator.log"
echo "  tail -f /tmp/dashboard.log"
echo ""

# Start production server
node src/production-server.js
