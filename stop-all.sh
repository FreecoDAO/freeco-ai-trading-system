#!/bin/bash
echo "🛑 Stopping All Services..."

# Kill all node processes related to AI signal generator
pkill -9 -f "node.*ai-signal-generator" 2>/dev/null || true
pkill -9 -f "node /workspaces" 2>/dev/null || true

# Kill all Python processes (Streamlit and HTTP server)
pkill -9 -f "streamlit" 2>/dev/null || true
pkill -9 -f "python3.*server.py" 2>/dev/null || true
pkill -9 -f "python3.*main.py" 2>/dev/null || true

# Kill MQTT
pkill -9 mosquitto 2>/dev/null || true

sleep 2
echo "✓ All services stopped"
