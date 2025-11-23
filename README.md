# 🚀 FreEco AI Trading Bot

**Status**: ✅ **FULLY OPERATIONAL**

A production-grade AI trading system powered by DeepSeek R1, MQTT messaging, and Jupiter DEX integration on Solana.

---

## ⚡ Quick Start

```bash
# Start everything in one command
bash start-production.sh
```

Then open in your browser:
- **Dashboard**: http://localhost:8501 (AI signals & metrics)
- **Hummingbot**: http://localhost:8502 (Trading interface)
- **MQTT**: localhost:1883 (Signal distribution)

---

## 🎯 What This Does

### Real-Time AI Market Analysis
- **DeepSeek R1** analyzes FREECO/CHF every 60 seconds
- Generates **BUY/SELL/HOLD** signals with confidence scores
- Publishes to MQTT for instant distribution

### Live Trading Dashboard
- Real-time signal monitoring
- System health checks
- Trade history tracking
- Configuration management

### Solana DEX Integration
- **Jupiter DEX** for token swaps
- Automatic wallet management
- Real-time price feeds
- Trade execution ready

---

## 📊 System Architecture

```
AI Analysis (DeepSeek R1)
    ↓
MQTT Broker (Message Queue)
    ├→ Dashboard (8501)
    ├→ Hummingbot UI (8502)
    └→ Trading Signals
        ↓
    Jupiter DEX (Solana)
        ↓
    Live Trades
```

---

## 🚀 Features

- ✅ **Real-time AI signals** - Every 60 seconds
- ✅ **Multi-interface control** - Web dashboards + CLI
- ✅ **MQTT messaging** - Instant signal distribution
- ✅ **Jupiter DEX** - Solana token swaps
- ✅ **Wallet management** - Solana integration
- ✅ **Production-ready** - Cloud-deployable
- ✅ **24/7 operation** - Fully automated

---

## 📁 Project Structure

```
freeco-ai-trading-system/
├── src/
│   ├── ai-signal-generator.js     # DeepSeek R1 analysis
│   ├── market-data-service.js     # Real-time prices
│   ├── wallet-service.js          # Solana integration
│   ├── dex-integration.js         # Jupiter DEX
│   └── production-server.js       # REST API
├── hummingbot-dashboard/
│   └── server.py                  # Main dashboard
├── hummingbot-web/
│   ├── app.py                     # Hummingbot Web UI
│   └── templates/index.html       # Dashboard UI
├── start-production.sh            # Main startup
├── run.sh                         # Quick start
├── stop-all.sh                    # Stop services
└── .env                          # Configuration
```

---

## 🎓 Usage Examples

### 1. View Live Signals

```bash
tail -f /tmp/ai-signal-generator.log
```

Output:
```
Signal: FREECO_CHF
Trend: BUY
Confidence: 94%
Price Target: $2.45
```

### 2. Monitor MQTT Messages

```bash
mosquitto_sub -h localhost -t "hbot/#" -v
```

### 3. Check System Status

```bash
ps aux | grep -E "mosquitto|node|python3"
```

### 4. Access API Endpoints

```bash
# Health check
curl http://localhost:3000/health

# Get signals
curl http://localhost:3000/api/signals

# Get wallet info
curl http://localhost:3000/api/wallet
```

---

## 🔧 Configuration

Edit `.env` to customize:

```bash
# AI Configuration
NOVITA_API_KEY=your-key
DEEPSEEK_MODEL=deepseek/deepseek-r1

# Trading Configuration
FREECO_TOKEN=2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc
CHF_TOKEN=3bKaHFgY4Ja9JMgxxZhzi3NtbSd3WQRzPYadgZ7dLzFB
TRADING_PAIRS=FREECO_CHF,FREECO_HAPPYTAILS

# Wallet Configuration
MASTER_WALLET_ADDRESS=your-wallet-address
MASTER_WALLET_PRIVATE_KEY=your-private-key
```

---

## 📊 Services

| Service | Port | Status |
|---------|------|--------|
| MQTT Broker | 1883 | ✅ Running |
| Dashboard | 8501 | ✅ Running |
| Hummingbot UI | 8502 | ✅ Running |
| REST API | 3000 | ✅ Ready |

---

## 🛑 Stop Services

```bash
# Stop everything
bash stop-all.sh

# Or manually
pkill -f "mosquitto|node|python3"
```

---

## 📚 Documentation

- **DEPLOYMENT_GUIDE.md** - Complete setup guide
- **START-HERE.md** - Quick start instructions
- **FUNDING-GUIDE.md** - Wallet & funding setup
- **HOW-TO-RUN.md** - Running & fine-tuning
- **FINAL-SUMMARY.md** - System overview

---

## 🌐 API Endpoints

```
GET  /health              - Health check
GET  /api/status          - System status
GET  /api/wallet          - Wallet info
GET  /api/balance         - Account balance
GET  /api/market          - Real-time prices
GET  /api/signals         - Trading signals
GET  /api/trades          - Trade history
GET  /api/quote           - Get swap quote
POST /api/trade/execute   - Execute trade
```

---

## 🔐 Security

- Private keys stored in `.env` (never commit)
- API keys secured in environment variables
- Dedicated trading wallet (not main wallet)
- MQTT local-only (localhost:1883)
- No hardcoded credentials

---

## 🚀 Deployment

### Local
```bash
bash start-production.sh
```

### Docker
```bash
docker build -t freeco-ai-bot .
docker run -p 8501:8501 -p 1883:1883 freeco-ai-bot
```

### Kubernetes
```bash
kubectl apply -k k8s/
```

### Cloud (AWS/GCP/Azure)
See `k8s/CLOUD-DEPLOYMENT.md` for setup

---

## 📞 Support

- **GitHub**: https://github.com/FreecoDAO/freeco-ai-trading-system
- **Hummingbot**: https://docs.hummingbot.org
- **DeepSeek**: https://novita.ai/docs
- **Solana**: https://docs.solana.com
- **Jupiter**: https://jup.ag

---

## 📄 License

Apache 2.0 - See LICENSE file

---

## 🎉 Ready to Trade?

1. **Start the system**
   ```bash
   bash start-production.sh
   ```

2. **Open dashboards**
   - http://localhost:8501 (AI Dashboard)
   - http://localhost:8502 (Hummingbot UI)

3. **Fund your wallet**
   - Get wallet address from `.env`
   - Send SOL for gas (0.5+ for testing)
   - Send FRE.ECO tokens

4. **Monitor signals**
   ```bash
   tail -f /tmp/ai-signal-generator.log
   ```

5. **Execute trades**
   - Via Hummingbot Web UI
   - Or Jupiter DEX API

---

**Status**: ✅ OPERATIONAL  
**Signals**: 🟢 GENERATING  
**Ready**: 🎯 FOR TRADING

**The FreEco AI Trading Bot is ready!** 🚀🤖💰
