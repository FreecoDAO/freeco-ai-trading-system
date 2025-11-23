# Hummingbot Installation & Setup Guide

## ⚡ Quick Start Options

### Option 1: Python Virtual Environment (Recommended)

```bash
# Install (first time only)
bash install-hummingbot-fixed.sh

# Start Hummingbot
bash start-hummingbot.sh
```

### Option 2: Docker Container (Most Reliable)

```bash
# Requires Docker to be installed
bash start-hummingbot-docker.sh
```

### Option 3: Manual Installation

```bash
# Activate venv
source /workspaces/venv/hummingbot/bin/activate

# Install latest
pip install --upgrade hummingbot --prefer-binary

# Run
hummingbot
```

---

## 🔧 Troubleshooting Installation

### Issue: "hummingbot: command not found"

**Solution 1: Use Python module mode**
```bash
source /workspaces/venv/hummingbot/bin/activate
python3 -m hummingbot.client.ui
```

**Solution 2: Reinstall with pre-built wheels**
```bash
bash install-hummingbot-fixed.sh
```

**Solution 3: Use Docker**
```bash
bash start-hummingbot-docker.sh
```

### Issue: Alpine Linux Build Errors

Alpine doesn't have all build tools. Use Docker instead:

```bash
docker pull hummingbot/hummingbot:latest
bash start-hummingbot-docker.sh
```

### Issue: Missing Dependencies

```bash
# Install system dependencies
apk add --no-cache \
  python3-dev \
  gcc \
  musl-dev \
  libffi-dev \
  openssl-dev

# Then reinstall
bash install-hummingbot-fixed.sh
```

---

## 🚀 Hummingbot Quick Start

### 1. Start Hummingbot

```bash
bash start-hummingbot.sh
```

### 2. Create Your First Strategy

In the Hummingbot prompt:

```
>>> create

Follow the setup wizard:
1. Strategy: pure_market_making
2. Exchange: binance (or your preferred exchange)
3. Trading pair: BTC-USDT (or FRE.ECO-CHF)
4. Bid spread: 0.1%
5. Ask spread: 0.1%
6. Order amount: 0.01 BTC
```

### 3. Configure Exchange API Keys

```
>>> config connectors

Enter your API credentials from:
- Binance: https://www.binance.com/en/my/settings/api-management
- Kraken: https://www.kraken.com/u/settings/api
- Coinbase: https://www.coinbase.com/settings/api
```

### 4. Check Wallet Balance

```
>>> balance
```

### 5. Start Trading

```
>>> start
```

### 6. Monitor Status

```
>>> status
>>> orders
>>> history
```

---

## 💰 Connect to Your Trading Bot

### Integration with FreEco AI Bot

Your AI bot generates signals → Hummingbot executes trades:

```bash
# Terminal 1: Start FreEco AI Bot
bash run.sh

# Terminal 2: Start Hummingbot
bash start-hummingbot.sh

# Terminal 3: Monitor signals
tail -f /tmp/ai-signal-generator.log
```

### MQTT Signal Integration

Create `hummingbot_mqtt_bridge.py`:

```python
import paho.mqtt.client as mqtt
import json

def on_message(client, userdata, msg):
    signal = json.loads(msg.payload.decode())
    print(f"Signal: {signal['signal']} @ {signal['price_target']}")
    # Send to Hummingbot

client = mqtt.Client()
client.on_message = on_message
client.connect("localhost", 1883)
client.subscribe("hbot/predictions/#")
client.loop_forever()
```

Run it:
```bash
python3 hummingbot_mqtt_bridge.py
```

---

## 📊 Hummingbot Commands

| Command | Purpose |
|---------|---------|
| `help` | Show all commands |
| `create` | Create new strategy |
| `config` | Configure settings |
| `balance` | Show wallet balance |
| `orders` | Show active orders |
| `status` | Show trading status |
| `start` | Start trading |
| `stop` | Stop trading |
| `history` | Show trade history |
| `pnl` | Show profit/loss |
| `exit` | Exit Hummingbot |

---

## 🐳 Docker Hummingbot (Recommended for Alpine)

### Installation

```bash
# Pull latest image
docker pull hummingbot/hummingbot:latest

# Create config directory
mkdir -p ~/.hummingbot
```

### Run Hummingbot

```bash
docker run -it \
  --rm \
  -v ~/.hummingbot:/root/hummingbot_files \
  hummingbot/hummingbot:latest
```

### Connect to Localhost Services

```bash
docker run -it \
  --rm \
  --network host \
  -v ~/.hummingbot:/root/hummingbot_files \
  hummingbot/hummingbot:latest
```

This allows Hummingbot to connect to:
- MQTT Broker (localhost:1883)
- Dashboard (localhost:8501)
- Your AI Signal Generator

---

## ✅ Verification

```bash
# Check if Hummingbot can be imported
python3 -c "import hummingbot; print('✓ Hummingbot installed')"

# Check version
hummingbot --version

# Test connection
hummingbot -v
```

---

## 🎯 Next Steps

1. **Install**: `bash install-hummingbot-fixed.sh`
2. **Start**: `bash start-hummingbot.sh`
3. **Create Strategy**: `>>> create`
4. **Add API Keys**: `>>> config connectors`
5. **Fund Wallet**: Transfer assets to trading wallet
6. **Start Trading**: `>>> start`
7. **Monitor**: `>>> status`

---

## 📚 Resources

- **Hummingbot Docs**: https://docs.hummingbot.org
- **Hummingbot GitHub**: https://github.com/hummingbot/hummingbot
- **Hummingbot Discord**: https://discord.gg/hummingbot
- **Docker Hummingbot**: https://hub.docker.com/r/hummingbot/hummingbot

---

**Happy trading!** 🚀
