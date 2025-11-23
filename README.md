# 🤖 FreEco AI Trading Bot

An autonomous trading bot powered by DeepSeek R1 AI for Solana DEX trading.

## ⚡ Quick Start (One Command)

```bash
cd /workspaces/freeco-ai-trading-system
./run.sh
```

That's it! The bot will:
1. ✅ Setup all dependencies (if needed)
2. ✅ Start MQTT Broker
3. ✅ Start AI Signal Generator
4. ✅ Start Hummingbot Dashboard
5. ✅ Open dashboard in your browser

---

## 📊 What You Get

- **AI Signal Generator**: DeepSeek R1 real-time market analysis
- **MQTT Broker**: Fast signal distribution
- **Streamlit Dashboard**: Real-time monitoring UI
- **Solana Integration**: Trade on Jupiter DEX
- **Multiple Strategies**: Market making, arbitrage, trend following

---

## 🔧 Commands

### Start Bot
```bash
./run.sh
```

### View Dashboard
```bash
./open-dashboard.sh
```

### Monitor Signals
```bash
mosquitto_sub -h localhost -t "hbot/predictions/#" -v
```

### View Logs
```bash
tail -f /tmp/ai-signal-generator.log
tail -f /tmp/hummingbot-dashboard.log
```

### Stop All Services
```bash
./stop-all.sh
```

---

## 📁 Project Structure

```
├── run.sh                      # Start everything (main command)
├── setup-codespace.sh          # Initial setup
├── start-all.sh                # Start services
├── stop-all.sh                 # Stop services
├── open-dashboard.sh           # Open dashboard
├── .env                        # Configuration
├── DEPLOYMENT_GUIDE.md         # Detailed setup guide
├── README.md                   # This file
├── src/
│   └── ai-signal-generator.js  # AI signal logic
└── hummingbot-dashboard/
    └── main.py                 # Dashboard UI
```

---

## 🌐 Access Points

- **Dashboard**: http://localhost:8501
- **MQTT Broker**: localhost:1883
- **API**: DeepSeek R1 via Novita.ai

---

## 📚 Documentation

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for:
- Detailed setup instructions
- Configuration options
- Troubleshooting guide
- Security best practices
- Trading strategy details

---

## ⚠️ Security

- Never commit `.env` or private keys to Git
- Keep API keys secure
- Use dedicated wallet for trading bot
- Monitor balances regularly

---

## 📄 License

Apache 2.0 License
