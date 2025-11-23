FROM python:3.11-bullseye

LABEL maintainer="FreEco AI Trading Bot"
LABEL description="AI-Powered Trading Bot with DeepSeek R1, MQTT, and Hummingbot"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    mosquitto \
    mosquitto-clients \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspaces/freeco-ai-trading-system

# Copy project files
COPY . .

# Install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install \
    python-dotenv \
    requests \
    pandas \
    numpy \
    pyyaml

# Install Node.js dependencies
RUN npm install

# Create necessary directories
RUN mkdir -p logs data temp /var/run/mosquitto

# Expose ports
EXPOSE 8501 1883

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV NODE_ENV=production

# Make scripts executable
RUN chmod +x run.sh setup-codespace.sh start-all.sh stop-all.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8501 || exit 1

# Run startup script
CMD ["bash", "run.sh"]
