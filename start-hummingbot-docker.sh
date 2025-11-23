#!/bin/bash

echo "🐳 Starting Hummingbot in Docker"
echo "================================="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo ""
    echo "Install Docker:"
    echo "  https://docs.docker.com/get-docker/"
    echo ""
    echo "Or try Python installation:"
    echo "  bash start-hummingbot.sh"
    exit 1
fi

# Create config directory
mkdir -p ~/.hummingbot

echo "Starting Hummingbot Docker container..."
echo ""

# Run Hummingbot in Docker
docker run -it \
  --name hummingbot \
  --rm \
  -v ~/.hummingbot:/root/hummingbot_files \
  -e PROMPT_PASS=hummingbot \
  hummingbot/hummingbot:latest

echo ""
echo "✓ Hummingbot Docker container stopped"
