#!/bin/bash
echo "🔍 Diagnosing FreEco AI Trading Bot..."
echo "======================================"
echo ""

echo "1️⃣  Checking processes on port 8501:"
lsof -i :8501 2>/dev/null || netstat -tlnp 2>/dev/null | grep 8501 || echo "No process found on port 8501"
echo ""

echo "2️⃣  Checking all running processes:"
echo "MQTT Processes:"
pgrep -af mosquitto || echo "None running"
echo ""

echo "Node Processes:"
pgrep -af "node" || echo "None running"
echo ""

echo "Python Processes:"
pgrep -af "python3" || echo "None running"
echo ""

echo "3️⃣  Checking for Streamlit processes (which cause 401 error):"
pgrep -af "streamlit" && echo "⚠️  FOUND STREAMLIT - THIS IS THE PROBLEM!" || echo "✓ No Streamlit running"
echo ""

echo "4️⃣  Checking log files:"
echo "--- Dashboard Log (last 10 lines) ---"
tail -10 /tmp/hummingbot-dashboard.log 2>/dev/null || echo "Log not found"
echo ""

echo "--- AI Signal Log (last 10 lines) ---"
tail -10 /tmp/ai-signal-generator.log 2>/dev/null || echo "Log not found"
echo ""

echo "5️⃣  Testing HTTP connectivity:"
curl -I http://localhost:8501 2>&1 | head -5
echo ""

echo "=== DIAGNOSIS COMPLETE ==="
