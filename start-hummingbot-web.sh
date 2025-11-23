#!/bin/bash

echo "🌐 Starting Hummingbot Web UI"
echo "============================="
echo ""

# Create web app directory
mkdir -p hummingbot-web/templates

# Create a dedicated venv for the web UI
VENV_DIR="/workspaces/venv/web-ui"

# Check if venv exists, if not create it
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating web UI virtual environment..."
    python3 -m venv "$VENV_DIR"
    echo "✓ Virtual environment created"
fi

# Activate venv
source "$VENV_DIR/bin/activate"

# Install Flask and MQTT client
echo "Installing Flask and MQTT client..."
pip install --quiet flask paho-mqtt 2>/dev/null || {
    echo "⚠️  Using --break-system-packages (one-time setup)..."
    pip install --break-system-packages --quiet flask paho-mqtt
}
echo "✓ Dependencies installed"
echo ""

# Start the web server
cd /workspaces/freeco-ai-trading-system/hummingbot-web

echo "Starting Flask server..."
echo ""
echo "═════════════════════════════════════════"
echo "🌐 Hummingbot Web UI"
echo "═════════════════════════════════════════"
echo ""
echo "📊 Access at: http://localhost:8502"
echo ""
echo "Features:"
echo "  • Create trading strategies"
echo "  • Connect to exchanges"
echo "  • Monitor AI signals (real-time)"
echo "  • Control trading (start/stop)"
echo "  • View executed trades"
echo ""
echo "Open in browser: http://localhost:8502"
echo ""

python3 app.py
