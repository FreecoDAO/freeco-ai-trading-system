#!/bin/bash
set -e

echo "🚀 Starting All Services..."
echo "============================"

# Source environment
cd /workspaces/freeco-ai-trading-system
if [ -f ".env" ]; then
  source .env
fi

# Start MQTT Broker
echo "📡 Starting MQTT Broker..."
mosquitto -c /etc/mosquitto/mosquitto.conf -d -p 1883 2>/dev/null || true
sleep 2
echo "✓ MQTT Broker running on port 1883"

# Start AI Signal Generator
echo "🤖 Starting AI Signal Generator..."
node /workspaces/freeco-ai-trading-system/src/ai-signal-generator.js > /tmp/ai-signal-generator.log 2>&1 &
echo "✓ AI Signal Generator running"

# Start Dashboard HTTP Server
echo "📊 Starting Dashboard HTTP Server..."
cd /workspaces/hummingbot-dashboard
python3 server.py > /tmp/hummingbot-dashboard.log 2>&1 &
sleep 2
echo "✓ Dashboard running on http://localhost:8501"

echo ""
echo "✅ All Services Started!"
echo "========================"
echo "📊 Dashboard: http://localhost:8501"
echo "📡 MQTT Broker: localhost:1883"
echo "🤖 AI Signal Generator: Running"
echo ""
echo "Monitor logs with:"
echo "  tail -f /tmp/ai-signal-generator.log"
echo "  tail -f /tmp/hummingbot-dashboard.log"
