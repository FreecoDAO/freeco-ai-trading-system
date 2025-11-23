#!/bin/bash

echo "🔄 Force Restarting Dashboard..."
echo ""

# Step 1: Kill all Python processes on port 8501
echo "Step 1: Killing process on port 8501..."
PIDS=$(lsof -ti:8501 2>/dev/null | grep -v "docker-init")
if [ -n "$PIDS" ]; then
  echo "$PIDS" | xargs kill -9 2>/dev/null || true
  sleep 2
  echo "✓ Killed PID(s): $PIDS"
else
  echo "✓ No process found on port 8501"
fi
echo ""

# Step 2: Kill all Python processes
echo "Step 2: Killing all Python processes..."
pkill -9 -f "python3.*server.py" 2>/dev/null || true
sleep 1
echo "✓ All Python processes killed"
echo ""

# Step 3: Verify port is free
echo "Step 3: Verifying port 8501 is free..."
if lsof -i :8501 > /dev/null 2>&1; then
  echo "⚠ Port still in use, waiting..."
  sleep 3
else
  echo "✓ Port 8501 is free"
fi
echo ""

# Step 4: Start fresh dashboard
echo "Step 4: Starting new dashboard server..."
cd /workspaces/hummingbot-dashboard
python3 server.py > /tmp/hummingbot-dashboard.log 2>&1 &
DASH_PID=$!
sleep 2

# Step 5: Verify it's running
echo "Step 5: Verifying dashboard..."
if kill -0 $DASH_PID 2>/dev/null; then
  echo "✓ Dashboard running (PID: $DASH_PID)"
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8501 2>/dev/null)
  if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Dashboard HTTP 200 OK"
  else
    echo "⚠ Dashboard returned HTTP $HTTP_CODE"
  fi
else
  echo "✗ Dashboard failed to start"
  echo "Check logs: tail /tmp/hummingbot-dashboard.log"
fi
echo ""
echo "✅ Done!"
