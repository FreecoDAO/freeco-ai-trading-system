#!/bin/bash

echo "🤖 Starting Hummingbot Trading Interface"
echo "========================================"
echo ""

VENV_DIR="/workspaces/venv/hummingbot"

# Check if venv exists
if [ ! -d "$VENV_DIR" ]; then
    echo "❌ Hummingbot virtual environment not found!"
    echo ""
    echo "Install it first:"
    echo "  bash install-hummingbot-fixed.sh"
    exit 1
fi

# Activate venv
echo "Activating Hummingbot environment..."
source "$VENV_DIR/bin/activate"
echo "✓ Environment activated"
echo ""

# Check if hummingbot command exists
if ! command -v hummingbot &> /dev/null; then
    echo "⚠️  Hummingbot CLI not found in PATH"
    echo ""
    echo "Trying Python module instead..."
    echo ""
    
    # Try to run Hummingbot as Python module
    python3 -c "from hummingbot.client.command.start_command import StartCommand; print('✓ Hummingbot module available')" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "Starting Hummingbot (Python module mode)..."
        python3 -m hummingbot.client.ui
    else
        echo "❌ Hummingbot installation appears incomplete"
        echo ""
        echo "Solutions:"
        echo "1. Reinstall: bash install-hummingbot-fixed.sh"
        echo "2. Use Hummingbot Docker: docker run -it hummingbot/hummingbot"
        echo "3. Check logs: pip show hummingbot"
        exit 1
    fi
else
    echo "Starting Hummingbot UI..."
    echo ""
    echo "========================================"
    echo "💡 Quick Commands:"
    echo "   >>> help               - Show all commands"
    echo "   >>> create             - Create new strategy"
    echo "   >>> config             - Configure settings"
    echo "   >>> balance            - Check wallet balance"
    echo "   >>> start              - Start trading"
    echo "   >>> status             - Show current status"
    echo "   >>> exit               - Exit Hummingbot"
    echo "========================================"
    echo ""
    
    # Start Hummingbot
    hummingbot
fi
