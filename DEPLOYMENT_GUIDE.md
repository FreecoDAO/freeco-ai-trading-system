# FreEco AI Trading Bot - Deployment Guide

## ⚡ Quick Start (1 Command)

```bash
cd /workspaces/freeco-ai-trading-system && bash run.sh
```

That's it! This single command will:
- ✅ Setup all dependencies (Node.js, Python, MQTT) if needed
- ✅ Start MQTT Broker
- ✅ Start AI Signal Generator (DeepSeek R1)
- ✅ Start Dashboard HTTP Server (no authentication needed!)
- ✅ Show dashboard access information

---

## 📊 What You'll See

After running the command, you'll see:
- ✓ MQTT Broker: Running on localhost:1883
- ✓ AI Signal Generator: Running (DeepSeek R1)
- ✓ Dashboard HTTP Server: Running on http://localhost:8501

**Dashboard Access:**
- Local: `http://localhost:8501`
- GitHub Codespaces: `https://your-codespace-name-8501.app.github.dev`
- Command: `bash open-dashboard.sh`

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Codespace (16GB)                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐      ┌──────────────────┐            │
│  │  AI Signal Gen   │─────▶│  MQTT Broker     │            │
│  │  (DeepSeek R1)   │      │  (Mosquitto)     │            │
│  └──────────────────┘      └────────┬─────────┘            │
│           │                          │                       │
│           │                          ▼                       │
│           │                 ┌──────────────────┐            │
│           │                 │   Dashboard      │            │
│           │                 │   HTTP Server    │            │
│           │                 │  (Python 3)      │            │
│           │                 └────────┬─────────┘            │
│           │                          │                       │
│           ▼                          ▼                       │
│  ┌─────────────────────────────────────────┐                │
│  │         Jupiter DEX (Solana)             │                │
│  │     FRE.ECO/CHF Trading Pairs            │                │
│  └─────────────────────────────────────────┘                │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Helpful Commands

### Access Dashboard

```bash
# GitHub Codespaces - Forward port 8501
# Click on the "Ports" tab in Codespaces terminal
# Your dashboard will be available at the forwarded URL

# Or open with script
bash open-dashboard.sh

# Or manually navigate to:
# http://localhost:8501 (local)
# Your-Codespace-URL:8501 (GitHub Codespaces)
```

### Monitor Services

```bash
# View AI Signal Generator logs (real-time)
tail -f /tmp/ai-signal-generator.log

# View Dashboard logs
tail -f /tmp/hummingbot-dashboard.log

# View MQTT Broker signals in real-time
mosquitto_sub -h localhost -t "hbot/predictions/#" -v
```

### Stop Services

```bash
bash stop-all.sh
```

### Check Running Services

```bash
ps aux | grep -E "mosquitto|node|streamlit"
```

---

## 🔧 Configuration

### Environment Variables (.env)

The setup script automatically creates `.env` with these values:

```bash
# AI API Keys (Novita.ai - DeepSeek R1)
NOVITA_API_KEY=sk_18Vuiio04cZmEs3ieW1xE2j9uoT9_VuGewihPFqVRe0
DEEPSEEK_API_URL=https://api.novita.ai/openai/v1
DEEPSEEK_MODEL=deepseek/deepseek-r1

# MQTT Configuration
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_TOPIC_PREFIX=hbot/predictions

# Trading Configuration (Solana Token Addresses)
FREECO_TOKEN=2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc
CHF_TOKEN=3bKaHFgY4Ja9JMgxxZhzi3NtbSd3WQRzPYadgZ7dLzFB
TRADING_PAIRS=FREECO_CHF,FREECO_HAPPYTAILS

# Master Wallet (Update with your private key when ready to trade)
MASTER_WALLET_ADDRESS=FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw
MASTER_WALLET_PRIVATE_KEY=your-private-key-here
```

To update values manually:
```bash
nano .env
# Edit and save
source .env
```

---

## 🤖 AI Models

### Primary: DeepSeek R1 (via Novita.ai)

- **Model**: `deepseek/deepseek-r1`
- **Cost**: $0.70 per 1M input tokens, $2.50 per 1M output tokens
- **Speed**: 5-10 seconds per analysis
- **Availability**: 24/7 inference
- **Use**: Real-time market analysis and trading signals

### Signal Features

- Real-time signal generation every 60 seconds
- Trend analysis (BUY/SELL/HOLD)
- Confidence scoring (0-100%)
- Price target predictions
- MQTT publish to `hbot/predictions/freeco_chf`

---

## 📈 Trading Strategies

### 1. AI-Driven Market Making

- Uses DeepSeek R1 signals
- MQTT-based communication
- Automatic order placement on Jupiter DEX

### 2. Arbitrage

- Cross-DEX arbitrage detection
- Jupiter aggregation for best prices
- Dedicated arbitrage wallet

### 3. Trend Following

- AI-powered trend detection
- Risk-managed position sizing
- Stop-loss automation

---

## 🚨 Troubleshooting

### Dashboard Returns 401 Unauthorized Error

**The 401 error means Streamlit is still running from a previous attempt.**

```bash
# Step 1: Diagnose what's running
bash diagnose.sh

# Step 2: If you see "FOUND STREAMLIT", force restart everything
bash force-restart.sh
sleep 2

# Step 3: Start fresh
bash run.sh
```

**What's happening:**
- Old Streamlit process is still listening on port 8501
- Streamlit requires authentication in some configurations
- The new HTTP server can't start because port is in use

**Solution:**
- Force kill all processes
- Clear all caches
- Start completely fresh

### Setup Failed

```bash
# Re-run setup with verbose output
bash -x setup-codespace.sh

# Check if required tools are installed
which node python3 mosquitto npm
```

### MQTT Connection Issues

```bash
# Kill existing MQTT processes
pkill mosquitto
sleep 1

# Restart MQTT explicitly
mosquitto -c /etc/mosquitto/mosquitto.conf -d -p 1883
sleep 2

# Verify MQTT is listening
netstat -tlnp | grep 1883

# Test connection
mosquitto_pub -h localhost -t "test" -m "hello" && echo "✓ MQTT working"
```

### API Key Issues

```bash
# Verify API key is set
echo "API Key: $NOVITA_API_KEY"

# Test API connectivity
curl -s "https://api.novita.ai/openai/v1/chat/completions" \
  -H "Authorization: Bearer $NOVITA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek/deepseek-r1","messages":[{"role":"user","content":"test"}],"max_tokens":50}' \
  | head -c 200
```

### AI Signal Generator Not Generating Signals

```bash
# Check logs for errors
tail -20 /tmp/ai-signal-generator.log

# Restart AI Signal Generator
pkill -f "node.*ai-signal-generator"
sleep 1
node /workspaces/freeco-ai-trading-system/src/ai-signal-generator.js &
```

---

## ✅ Verification Checklist

After running setup, verify everything is working:

```bash
# Quick diagnosis
bash diagnose.sh

# Or manual checks:
# 1. Check MQTT Broker
ps aux | grep mosquitto && echo "✓ MQTT running" || echo "✗ MQTT not running"

# 2. Check AI Signal Generator
ps aux | grep "node.*ai-signal-generator" && echo "✓ AI Signal Gen running" || echo "✗ AI Signal Gen not running"

# 3. Check Dashboard HTTP Server (NOT Streamlit!)
ps aux | grep "python3.*server.py" && echo "✓ Dashboard running" || echo "✗ Dashboard not running"
ps aux | grep streamlit && echo "✗ STREAMLIT RUNNING - RUN: bash force-restart.sh"

# 4. Check API Key
[ -n "$NOVITA_API_KEY" ] && echo "✓ API key configured" || echo "✗ API key missing"

# 5. Check MQTT connectivity
mosquitto_pub -h localhost -t "test" -m "test" 2>/dev/null && echo "✓ MQTT connectivity OK" || echo "✗ MQTT connectivity failed"

# 6. Test Dashboard HTTP Access (should NOT return 401)
curl -I http://localhost:8501 2>&1 | grep -E "200|401"
```

All checks should show ✓ for the system to be ready.

---

## 📚 Next Steps

### 1. Run the Bot

```bash
bash run.sh
# Services will start automatically
```

### 2. Access Dashboard

```bash
# GitHub Codespaces: Check Ports tab for forwarded URL
# Local: http://localhost:8501
bash open-dashboard.sh
```

### 3. Monitor Live Signals

```bash
# In a new terminal, watch AI signals in real-time
mosquitto_sub -h localhost -t "hbot/predictions/#" -v

# In dashboard, watch signal confidence scores update
```

### 4. Fund Wallets (When Ready to Trade)

- Transfer SOL for gas fees (0.1-1 SOL minimum)
- Transfer FRE.ECO tokens for trading
- Update `MASTER_WALLET_PRIVATE_KEY` in `.env`

### 5. Test Trading (Optional)

- Start with small test amounts
- Monitor execution on Solana Explorer
- Verify trades match signals
- Scale up once confident

---

## 📁 Project Structure

```
/workspaces/freeco-ai-trading-system/
├── run.sh                      # Start everything (main command)
├── setup-codespace.sh          # Automated setup (run once)
├── start-all.sh                # Start all services
├── stop-all.sh                 # Stop all services
├── open-dashboard.sh           # Open dashboard in browser
├── .env                        # Configuration (auto-created)
├── DEPLOYMENT_GUIDE.md         # This file
├── README.md                   # Project overview
├── src/
│   └── ai-signal-generator.js  # AI signal generation logic
└── hummingbot-dashboard/
    └── server.py               # HTTP Dashboard Server
```

---

## 🤖 Access Hummingbot Trading Interface

You have **2 ways** to access Hummingbot:

### Option 1: Web UI (Recommended for Codespaces)

```bash
bash start-hummingbot-web.sh
```

**Access**: http://localhost:8502

Features:
- ✅ Browser-based (no CLI needed)
- ✅ Create strategies visually
- ✅ Connect to exchanges
- ✅ Real-time AI signal monitoring
- ✅ Start/stop trading with one click
- ✅ View trade history

### Option 2: CLI (Traditional)

```bash
bash start-hummingbot.sh
```

Or install and run directly:
```bash
source /workspaces/venv/hummingbot/bin/activate
hummingbot
```

**See** `HUMMINGBOT-UI-GUIDE.md` for complete CLI setup.

### Three-Interface Trading System

```
┌─────────────────────────────────────────────┐
│  1. Hummingbot CLI (Terminal)               │
│     bash start-hummingbot.sh                │
│     - Strategy configuration                │
│     - Trading control                       │
│     - Real-time monitoring                  │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  2. FreEco Dashboard (Web)                  │
│     http://localhost:8501                   │
│     - AI signal metrics                     │
│     - System status                         │
│     - Configuration panel                   │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  3. Solana Explorer (Blockchain)            │
│     https://explorer.solana.com             │
│     - On-chain transactions                 │
│     - Wallet verification                   │
│     - Trade confirmation                    │
└─────────────────────────────────────────────┘
```

---

## 📞 Support & Resources

- **GitHub Repository**: https://github.com/FreecoDAO/freeco-ai-trading-system
- **Hummingbot Docs**: https://docs.hummingbot.org
- **Novita.ai API Docs**: https://novita.ai/docs
- **Solana Documentation**: https://docs.solana.com
- **Jupiter DEX**: https://jup.ag

---

## ⚠️ Security Notes

- ⛔ **Never commit private keys to Git**
- ⛔ **Never share API keys or `.env` files**
- ✅ Use environment variables (`.env`) for all sensitive data
- ✅ Keep API keys and wallet private keys secure
- ✅ Monitor wallet balances regularly
- ✅ Enable alerts for unusual activity
- ✅ Use a dedicated wallet for trading bots (not main wallet)

---

## 📄 License

This project is released under the **Apache 2.0 License**.

## Quick troubleshooting: Rebuild the dev container

If Codespaces reports "recovery mode" or devcontainer configuration errors:

1. Open the Command Palette in VS Code (Ctrl/Cmd+Shift+P) and run: "Dev Containers: Rebuild Container".
2. Alternatively, from the terminal run:
   ```bash
   # quick diagnostic: show processes and what's listening on port 8501
   bash /workspaces/freeco-ai-trading-system/diagnose.sh || (ps aux | head -n 20; netstat -tlnp | grep 8501 || true)
   ```

If the rebuild fails, revert custom devcontainer overrides and use the provided minimal `.devcontainer/devcontainer.json`, then run "Rebuild Container" again.

---

## ☁️ Kubernetes Cloud Deployment

Deploy to AWS EKS, Google GKE, Azure AKS, or any Kubernetes cluster:

```bash
# Quick deploy
bash deploy-k8s.sh

# Or manual deploy
kubectl apply -k k8s/
```

**See** `k8s/CLOUD-DEPLOYMENT.md` for detailed cloud provider setup.

### AWS EKS (Recommended)

```bash
# Create cluster
eksctl create cluster --name freeco-ai --region us-east-1 --nodes 3

# Deploy bot
kubectl apply -k k8s/

# Get dashboard URL
kubectl get svc dashboard -n freeco-ai
```

### Auto-Scaling

```bash
kubectl autoscale deployment ai-signal-generator --min=2 --max=10 -n freeco-ai
```

---

## 🛑 Stop Everything

### Quick Stop

```bash
bash stop-all.sh
```

### Manual Stop

```bash
# Stop all services at once
pkill -f "mosquitto|node|python3.*server|python3.*app"
```

### Stop Individual Services

```bash
# Stop MQTT Broker
pkill mosquitto

# Stop AI Signal Generator
pkill -f "node.*ai-signal-generator"

# Stop Dashboard Server (port 8501)
pkill -f "python3.*server.py"

# Stop Hummingbot Web UI (port 8502)
pkill -f "python3.*app.py"
```

### Verify Everything Stopped

```bash
# Check if services are running
ps aux | grep -E "mosquitto|node|python3" | grep -v grep

# Should return empty (no services running)
```
