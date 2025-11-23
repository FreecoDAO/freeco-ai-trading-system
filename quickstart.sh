#!/bin/bash
set -e

echo "🚀 FreEco AI Trading Bot - Quick Start"
echo "======================================"
echo ""

# Fix Git ownership issue first
echo "Step 1: Fixing Git configuration..."
git config --global --add safe.directory /workspaces/freeco-ai-trading-system 2>/dev/null || true
echo "✓ Git configured"
echo ""

# Step 2: Clean up any old processes
echo "Step 2: Cleaning up old processes..."
pkill -9 mosquitto 2>/dev/null || true
pkill -9 -f "python3.*server.py" 2>/dev/null || true
pkill -9 -f "node.*ai-signal-generator" 2>/dev/null || true
lsof -ti:8501 2>/dev/null | xargs kill -9 2>/dev/null || true
sleep 2
echo "✓ Old processes cleaned"
echo ""

# Step 3: Run setup
echo "Step 3: Running setup..."
cd /workspaces/freeco-ai-trading-system
bash setup-codespace.sh 2>&1 | tail -20
echo "✓ Setup complete"
echo ""

# Step 4: Start services
echo "Step 4: Starting services..."
sleep 2
bash start-all.sh
sleep 4
echo ""

# Step 5: Verify system
echo "Step 5: Verifying system..."
bash verify-step2.sh
VERIFY_RESULT=$?
echo ""

if [ $VERIFY_RESULT -eq 0 ]; then
  echo "=========================================="
  echo "✅ SYSTEM IS READY!"
  echo "=========================================="
  echo ""
  echo "Dashboard: http://localhost:8501"
  echo ""
  echo "Next steps:"
  echo "  1. Test the dashboard in your browser"
  echo "  2. Run: git status"
  echo "  3. Run: git add ."
  echo "  4. Run: git commit -m 'feat: HTTP dashboard and improvements'"
  echo "  5. Run: git push origin main"
  echo ""
else
  echo "=========================================="
  echo "⚠️  VERIFICATION FAILED"
  echo "=========================================="
  echo ""
  echo "Check logs:"
  echo "  tail -20 /tmp/ai-signal-generator.log"
  echo "  tail -20 /tmp/hummingbot-dashboard.log"
  echo ""
  exit 1
fi
