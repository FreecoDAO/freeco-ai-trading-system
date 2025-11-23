#!/bin/bash

echo "🚀 Installing Hummingbot and CrewAI in Virtual Environments"
echo "==========================================================="
echo ""

# Create virtual environments directory
VENV_DIR="/workspaces/venv"
mkdir -p "$VENV_DIR"

# Step 1: Create Hummingbot Virtual Environment
echo "[1/4] Creating Hummingbot virtual environment..."
python3 -m venv "$VENV_DIR/hummingbot"
source "$VENV_DIR/hummingbot/bin/activate"
echo "✓ Hummingbot venv created"
echo ""

# Step 2: Install Hummingbot
echo "[2/4] Installing Hummingbot (this may take a few minutes)..."
pip install --upgrade pip setuptools wheel 2>&1 | tail -5
pip install hummingbot 2>&1 | tail -10
echo "✓ Hummingbot installed"
echo ""

# Step 3: Create CrewAI Virtual Environment
echo "[3/4] Creating CrewAI virtual environment..."
python3 -m venv "$VENV_DIR/crewai"
source "$VENV_DIR/crewai/bin/activate"
echo "✓ CrewAI venv created"
echo ""

# Step 4: Install CrewAI
echo "[4/4] Installing CrewAI (this may take a few minutes)..."
pip install --upgrade pip setuptools wheel 2>&1 | tail -5
pip install crewai crewai-tools 2>&1 | tail -10
echo "✓ CrewAI installed"
echo ""

# Create activation scripts
cat > "$VENV_DIR/activate-hummingbot.sh" << 'EOF'
#!/bin/bash
source /workspaces/venv/hummingbot/bin/activate
echo "✓ Hummingbot environment activated"
hummingbot --version
EOF

cat > "$VENV_DIR/activate-crewai.sh" << 'EOF'
#!/bin/bash
source /workspaces/venv/crewai/bin/activate
echo "✓ CrewAI environment activated"
python3 -c "import crewai; print(f'CrewAI version: {crewai.__version__}')" 2>/dev/null || echo "CrewAI ready"
EOF

chmod +x "$VENV_DIR/activate-hummingbot.sh"
chmod +x "$VENV_DIR/activate-crewai.sh"

echo "═══════════════════════════════════════════════════════"
echo "✅ Installation Complete!"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Virtual Environments Created:"
echo "  • Hummingbot: /workspaces/venv/hummingbot"
echo "  • CrewAI: /workspaces/venv/crewai"
echo ""
echo "Activation Commands:"
echo "  • Hummingbot: source /workspaces/venv/hummingbot/bin/activate"
echo "  • CrewAI: source /workspaces/venv/crewai/bin/activate"
echo ""
echo "Or use the quick scripts:"
echo "  • bash /workspaces/venv/activate-hummingbot.sh"
echo "  • bash /workspaces/venv/activate-crewai.sh"
echo ""
echo "Next Steps:"
echo "  1. Test Hummingbot: bash /workspaces/venv/activate-hummingbot.sh && hummingbot"
echo "  2. Test CrewAI: bash /workspaces/venv/activate-crewai.sh && python3 -m crewai"
echo ""
