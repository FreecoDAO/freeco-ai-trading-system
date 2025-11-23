#!/bin/bash
set -e

echo "🚀 Setting up FreEco AI Trading Bot Development Environment"
echo "==========================================================="
echo ""

# Update system packages
echo "Installing system dependencies..."
apt-get update
apt-get install -y \
  curl \
  wget \
  git \
  build-essential \
  mosquitto \
  mosquitto-clients \
  nodejs \
  npm \
  2>&1 | tail -5

echo "✓ System dependencies installed"
echo ""

# Install Python packages
echo "Installing Python packages..."
pip install --upgrade pip setuptools wheel 2>&1 | tail -3
pip install \
  python-dotenv \
  requests \
  pandas \
  numpy \
  pyyaml \
  2>&1 | tail -3

echo "✓ Python packages installed"
echo ""

# Install Node.js packages
echo "Installing Node.js packages..."
cd /workspaces/freeco-ai-trading-system
npm install 2>&1 | tail -5

echo "✓ Node.js packages installed"
echo ""

# Create necessary directories
mkdir -p logs data temp
echo "✓ Directories created"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "✅ Development Environment Ready!"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Quick Start:"
echo "  bash run.sh"
echo ""
echo "Dashboard:"
echo "  http://localhost:8501"
echo ""
echo "MQTT Broker:"
echo "  localhost:1883"
echo ""
