# 🚀 Complete FreEco AI Trading Bot Setup Guide

## ⚡ Quick Start (All-in-One)

Run this **ONE** command to start everything:

```bash
bash run.sh
```

This starts:
- ✅ MQTT Broker (localhost:1883)
- ✅ AI Signal Generator (DeepSeek R1)
- ✅ FreEco Dashboard (http://localhost:8501)

---

## 🎯 Then Access Hummingbot Web UI

In a **separate terminal**, run:

```bash
bash start-hummingbot-web.sh
```

Access at: **http://localhost:8502**

---

## 📊 Three Dashboards (Open in Browser)

| Dashboard | Port | Purpose |
|-----------|------|---------|
| **FreEco AI Dashboard** | 8501 | AI signals, system status |
| **Hummingbot Web UI** | 8502 | Trading control, strategy setup |
| **Solana Explorer** | Web | On-chain transactions |

---

## 🔄 Complete Workflow

### Terminal 1: Start Core Services

```bash
bash run.sh

# Output should show:
# ✓ MQTT Broker started
# ✓ AI Signal Generator started  
# ✓ Dashboard started
# 📊 Dashboard: http://localhost:8501
```

### Terminal 2: Start Hummingbot Web UI

```bash
bash start-hummingbot-web.sh

# Output should show:
# 📊 Hummingbot Web UI: http://localhost:8502
```

### Terminal 3: Monitor AI Signals (Optional)

```bash
tail -f /tmp/ai-signal-generator.log
```

### Browsers: Open Dashboards

**Browser Tab 1:**
```
http://localhost:8501
```
Shows real-time AI signals and system status

**Browser Tab 2:**
```
http://localhost:8502
```
Shows Hummingbot trading interface

---

## ✅ Verification Checklist

After starting everything, verify:

```bash
# 1. Check all services running
ps aux | grep -E "mosquitto|node.*ai-signal|python3.*server|python3.*app"

# 2. Test MQTT
mosquitto_pub -h localhost -t "test" -m "hello" && echo "✓ MQTT OK"

# 3. Test FreEco Dashboard
curl -I http://localhost:8501 | grep "200\|HTTP"

# 4. Test Hummingbot Web UI
curl -I http://localhost:8502 | grep "200\|HTTP"

# 5. Watch AI signals
mosquitto_sub -h localhost -t "hbot/predictions/#" -v
```

All should show ✓ for success!

---

## 🌐 Access from GitHub Codespaces

If running in GitHub Codespaces:

1. Click **"Ports"** tab in terminal
2. You should see:
   - Port 8501 (FreEco Dashboard)
   - Port 8502 (Hummingbot Web UI)
   - Port 1883 (MQTT - internal only)

3. Click the globe icon to open in browser

---

## 🛑 Stop Everything

```bash
bash stop-all.sh
```

Or manually:

```bash
pkill -f mosquitto
pkill -f "node.*ai-signal"
pkill -f "python3.*server"
pkill -f "python3.*app"
```

---

## 🔧 Quick Commands Reference

| Command | Purpose |
|---------|---------|
| `bash run.sh` | Start AI bot + MQTT + Dashboard |
| `bash start-hummingbot-web.sh` | Start Hummingbot Web UI |
| `bash stop-all.sh` | Stop everything |
| `tail -f /tmp/ai-signal-generator.log` | Watch AI signals |
| `mosquitto_sub -h localhost -t "hbot/#" -v` | Watch MQTT messages |
| `curl http://localhost:8501` | Test FreEco Dashboard |
| `curl http://localhost:8502` | Test Hummingbot Web UI |

---

## 💡 Tips

### Hummingbot Web UI Not Showing MQTT Signals?

The MQTT broker needs to be running. Make sure you started `bash run.sh` first!

### Port Already in Use?

```bash
# Find what's using a port
lsof -i :8501
lsof -i :8502
lsof -i :1883

# Kill the process
kill -9 <PID>
```

### Want to See Live Signals?

Open **three terminals**:

```bash
# Terminal 1
bash run.sh

# Terminal 2
bash start-hummingbot-web.sh

# Terminal 3
tail -f /tmp/ai-signal-generator.log
```

Then open browsers:
- http://localhost:8501 (FreEco Dashboard)
- http://localhost:8502 (Hummingbot Web UI)

---

## 📚 Full Documentation

- **DEPLOYMENT_GUIDE.md** - Complete setup & troubleshooting
- **HOW-TO-RUN.md** - Running, fine-tuning, adding funds
- **FUNDING-GUIDE.md** - Wallet setup & trading
- **HUMMINGBOT-UI-GUIDE.md** - Hummingbot CLI integration
- **HUMMINGBOT-SETUP.md** - Alternative Hummingbot setups

---

## 🎯 Summary

**You now have:**
✅ AI Signal Generator (DeepSeek R1)
✅ Real-time Dashboard (8501)
✅ Hummingbot Web UI (8502)
✅ MQTT Message Broker
✅ Full trading system ready to go

**Next Steps:**
1. Run: `bash run.sh`
2. In new terminal: `bash start-hummingbot-web.sh`
3. Open http://localhost:8501
4. Open http://localhost:8502
5. Create strategy in Hummingbot
6. Start trading! 🚀

---

**Happy Trading!** 📈🤖💰
