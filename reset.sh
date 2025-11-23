#!/bin/bash
echo "🔄 Resetting FreEco AI Trading Bot..."

# Stop all services
bash stop-all.sh
sleep 2

# Kill any remaining processes on port 8501
lsof -ti:8501 | xargs kill -9 2>/dev/null || true
sleep 1

# Clear Streamlit cache
rm -rf ~/.streamlit 2>/dev/null || true
rm -rf ~/.cache/streamlit 2>/dev/null || true

# Clear logs
rm -f /tmp/ai-signal-generator.log
rm -f /tmp/hummingbot-dashboard.log
rm -f /tmp/mosquitto.log

echo "✓ Reset complete"
echo ""
echo "Now run: bash run.sh"
