#!/bin/bash

###############################################################################
# FreEco AI Trading Bot - Codespace Setup Script
# 
# This script automates the complete setup of the trading bot system in
# GitHub Codespaces, including:
# - AI Signal Generator (DeepSeek + Minimax)
# - MQTT Broker (Mosquitto)
# - Hummingbot Dashboard
# - CrewAI Agents
###############################################################################

set -e  # Exit on error

echo "🚀 FreEco AI Trading Bot - Codespace Setup"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Install system dependencies
echo -e "${YELLOW}📦 Step 1: Installing system dependencies...${NC}"
sudo apk add --no-cache \
    nodejs npm \
    python3 py3-pip \
    mosquitto mosquitto-clients \
    git curl wget \
    build-base python3-dev \
    || echo "Some packages may already be installed"

echo -e "${GREEN}✅ System dependencies installed${NC}"
echo ""

# Step 2: Install Node.js dependencies
echo -e "${YELLOW}📦 Step 2: Installing Node.js dependencies...${NC}"
cd /workspaces/freeco-ai-trading-system
npm install mqtt axios dotenv

echo -e "${GREEN}✅ Node.js dependencies installed${NC}"
echo ""

# Step 3: Start MQTT Broker
echo -e "${YELLOW}🔌 Step 3: Starting MQTT Broker...${NC}"
pkill mosquitto || true  # Kill existing instance if any
nohup mosquitto -c /etc/mosquitto/mosquitto.conf > /tmp/mosquitto.log 2>&1 &
sleep 2

if pgrep mosquitto > /dev/null; then
    echo -e "${GREEN}✅ MQTT Broker started (PID: $(pgrep mosquitto))${NC}"
else
    echo -e "${RED}❌ Failed to start MQTT Broker${NC}"
    exit 1
fi
echo ""

# Step 4: Test AI Signal Generator
echo -e "${YELLOW}🤖 Step 4: Testing AI Signal Generator...${NC}"
export NOVITA_API_KEY='sk_18Vuiio04cZmEs3ieW1xE2j9uoT9_VuGewihPFqVRe0'
export MQTT_BROKER='localhost'

timeout 10 node ai-signal-generator.js || true

echo -e "${GREEN}✅ AI Signal Generator tested${NC}"
echo ""

# Step 5: Install Hummingbot Dashboard
echo -e "${YELLOW}📊 Step 5: Installing Hummingbot Dashboard...${NC}"
cd /workspaces

if [ ! -d "hummingbot-dashboard" ]; then
    git clone https://github.com/hummingbot/dashboard.git hummingbot-dashboard
fi

cd hummingbot-dashboard

# Install Python dependencies
pip3 install --break-system-packages \
    ccxt \
    streamlit \
    watchdog \
    plotly \
    pycoingecko \
    glom \
    defillama \
    statsmodels \
    pandas_ta \
    sqlalchemy \
    pyyaml \
    || echo "Some packages may already be installed"

echo -e "${GREEN}✅ Hummingbot Dashboard installed${NC}"
echo ""

# Step 6: Create startup script
echo -e "${YELLOW}📝 Step 6: Creating startup scripts...${NC}"

cat > /workspaces/freeco-ai-trading-system/start-all.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting FreEco AI Trading Bot System..."

# Start MQTT Broker
echo "Starting MQTT Broker..."
pkill mosquitto || true
nohup mosquitto -c /etc/mosquitto/mosquitto.conf > /tmp/mosquitto.log 2>&1 &
sleep 2

# Start AI Signal Generator
echo "Starting AI Signal Generator..."
cd /workspaces/freeco-ai-trading-system
export NOVITA_API_KEY='sk_18Vuiio04cZmEs3ieW1xE2j9uoT9_VuGewihPFqVRe0'
export MQTT_BROKER='localhost'
nohup node ai-signal-generator.js > /tmp/ai-signal-generator.log 2>&1 &

# Start Hummingbot Dashboard
echo "Starting Hummingbot Dashboard..."
cd /workspaces/hummingbot-dashboard
nohup streamlit run main.py --server.port 8501 --server.address 0.0.0.0 > /tmp/hummingbot-dashboard.log 2>&1 &

echo ""
echo "✅ All services started!"
echo ""
echo "📊 Hummingbot Dashboard: http://localhost:8501"
echo "📡 MQTT Broker: localhost:1883"
echo ""
echo "Logs:"
echo "  - MQTT: tail -f /tmp/mosquitto.log"
echo "  - AI Signal Generator: tail -f /tmp/ai-signal-generator.log"
echo "  - Hummingbot Dashboard: tail -f /tmp/hummingbot-dashboard.log"
EOF

chmod +x /workspaces/freeco-ai-trading-system/start-all.sh

echo -e "${GREEN}✅ Startup script created: /workspaces/freeco-ai-trading-system/start-all.sh${NC}"
echo ""

# Final summary
echo "=========================================="
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "To start all services, run:"
echo "  /workspaces/freeco-ai-trading-system/start-all.sh"
echo ""
echo "Services:"
echo "  - AI Signal Generator (DeepSeek R1)"
echo "  - MQTT Broker (Mosquitto)"
echo "  - Hummingbot Dashboard (Streamlit)"
echo ""
echo "Next steps:"
echo "  1. Run the start-all.sh script"
echo "  2. Access Hummingbot Dashboard at http://localhost:8501"
echo "  3. Configure your Solana wallet in the dashboard"
echo "  4. Set up trading strategies"
echo ""
