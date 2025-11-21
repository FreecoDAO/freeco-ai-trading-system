#!/bin/bash
set -e

echo "🚀 Setting up FreEco AI Trading System..."

# Install uv package manager
echo "📦 Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# Install CrewAI CLI
echo "🤖 Installing CrewAI..."
uv tool install crewai

# Install Hummingbot Dashboard dependencies
echo "📊 Setting up Hummingbot Dashboard..."
cd hummingbot-dashboard
pip install -r requirements.txt
cd ..

# Pull Hummingbot Docker image
echo "🐳 Pulling Hummingbot Docker image..."
docker pull hummingbot/hummingbot:latest

# Create Hummingbot data directories
echo "📁 Creating Hummingbot directories..."
mkdir -p ~/hummingbot_files/{conf,logs,data,scripts,certs,pmm_scripts}

# Install MQTT broker
echo "📡 Installing Mosquitto MQTT broker..."
sudo apt-get update -qq
sudo apt-get install -y mosquitto mosquitto-clients
sudo systemctl enable mosquitto
sudo systemctl start mosquitto

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Configure your API keys in .env files"
echo "2. Start Hummingbot: docker run -it --name hummingbot --network host -v ~/hummingbot_files/conf:/conf hummingbot/hummingbot:latest"
echo "3. Start Dashboard: cd hummingbot-dashboard && streamlit run main.py"
echo "4. Create CrewAI strategy: cd .. && crewai create crew freeco-strategy"
echo ""
echo "📖 See COMPLETE_SETUP_GUIDE.md for detailed instructions"
