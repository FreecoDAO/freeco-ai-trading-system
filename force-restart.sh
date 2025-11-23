#!/bin/bash
echo "💥 Force Restarting FreEco AI Trading Bot..."
echo "=============================================="
echo ""

echo "Step 1: Killing all processes..."
pkill -9 -f streamlit 2>/dev/null || true
pkill -9 -f "python3.*server.py" 2>/dev/null || true
pkill -9 -f "python3.*main.py" 2>/dev/null || true
pkill -9 -f "node.*ai-signal-generator" 2>/dev/null || true
pkill -9 mosquitto 2>/dev/null || true
sleep 2

echo "Step 2: Killing any process on port 8501..."
lsof -ti:8501 2>/dev/null | xargs kill -9 2>/dev/null || true
sleep 1

echo "Step 3: Clearing caches..."
rm -rf ~/.streamlit 2>/dev/null || true
rm -rf ~/.cache/streamlit 2>/dev/null || true

echo "Step 4: Clearing logs..."
rm -f /tmp/ai-signal-generator.log
rm -f /tmp/hummingbot-dashboard.log
rm -f /tmp/mosquitto.log

echo "✓ Force restart complete!"
echo ""
echo "Now run: bash run.sh"
