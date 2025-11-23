# 🚀 START HERE - FreEco AI Trading Bot

## ⚡ Quick Start (2 Steps)

### Step 1: Start AI Bot + Dashboard

Open **Terminal 1** and run:

```bash
bash run.sh
```

Wait for output:
```
✅ All Services Started!
📊 Dashboard: http://localhost:8501
📡 MQTT Broker: localhost:1883
🤖 AI Signal Generator: Running
```

### Step 2: Start Hummingbot Web UI

Open **Terminal 2** and run:

```bash
bash start-hummingbot-web.sh
```

Wait for output:
```
📊 Hummingbot Web UI: http://localhost:8502
```

---

## 🌐 Open in Browser

| URL | Purpose |
|-----|---------|
| http://localhost:8501 | FreEco AI Dashboard (signals) |
| http://localhost:8502 | Hummingbot Web UI (trading) |

---

## ✅ That's It!

Your AI trading bot is now:
- ✅ Generating signals (DeepSeek R1)
- ✅ Publishing to MQTT
- ✅ Showing on dashboard
- ✅ Ready for trading commands

---

## 📚 Next Steps

See these guides for more:

- **COMPLETE-SETUP.md** - Full workflow guide
- **DEPLOYMENT_GUIDE.md** - Detailed setup & troubleshooting
- **HOW-TO-RUN.md** - Running, fine-tuning, adding funds
- **FUNDING-GUIDE.md** - Wallet setup & trading
- **HUMMINGBOT-UI-GUIDE.md** - Trading interface guide

---

## 🆘 Troubleshooting

### Dashboard shows 401 error?
```bash
bash force-restart.sh
bash run.sh
```

### Hummingbot Web UI won't load?
Make sure you started `bash run.sh` first!

### No MQTT signals in Hummingbot?
```bash
# Check if MQTT is running
mosquitto_pub -h localhost -t "test" -m "hello" && echo "✓ OK"
```

---

**You're all set!** 🎉📈🤖
