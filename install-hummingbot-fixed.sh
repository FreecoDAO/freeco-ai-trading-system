#!/bin/bash

echo "🚀 Installing Hummingbot (Fixed for Alpine Linux)"
echo "=================================================="
echo ""

VENV_DIR="/workspaces/venv/hummingbot"

# Step 1: Check if venv exists
if [ -d "$VENV_DIR" ]; then
    echo "[1/4] Removing old Hummingbot venv..."
    rm -rf "$VENV_DIR"
fi

# Step 2: Create fresh venv
echo "[1/4] Creating Hummingbot virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
echo "✓ Venv created and activated"
echo ""

# Step 3: Upgrade pip
echo "[2/4] Upgrading pip and installing build tools..."
pip install --upgrade pip setuptools wheel 2>&1 | tail -3
echo "✓ Pip upgraded"
echo ""

# Step 4: Install Hummingbot from pip (pre-built wheel)
echo "[3/4] Installing Hummingbot (this may take 2-3 minutes)..."
pip install hummingbot --prefer-binary 2>&1 | tail -10
echo ""

# Step 5: Verify installation
echo "[4/4] Verifying Hummingbot installation..."
HUMMINGBOT_PATH=$(which hummingbot)
if [ -n "$HUMMINGBOT_PATH" ]; then
    echo "✓ Hummingbot installed at: $HUMMINGBOT_PATH"
    echo ""
    echo "Installation verified:"
    hummingbot --version 2>/dev/null || echo "   (version info not available in CLI mode)"
else
    echo "⚠ Hummingbot CLI not found in PATH"
    echo "   Trying Python module import instead..."
    python3 -c "import hummingbot; print('✓ Hummingbot module available')" 2>/dev/null || {
        echo "✗ Hummingbot installation failed"
        echo ""
        echo "Alternative: Use Hummingbot Docker image instead"
        exit 1
    }
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "✅ Hummingbot Installation Complete!"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Quick Start:"
echo "  bash start-hummingbot.sh"
echo ""
echo "Or activate manually:"
echo "  source /workspaces/venv/hummingbot/bin/activate"
echo "  hummingbot"
echo ""
