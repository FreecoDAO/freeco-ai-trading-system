# How to Access Hummingbot UI

## 🚀 Quick Start: Open Hummingbot UI

### Option 1: Using Virtual Environment (Recommended)

```bash
# Activate Hummingbot virtual environment
source /workspaces/venv/hummingbot/bin/activate

# Start Hummingbot with UI
hummingbot

# You'll see:
# >>>
# (hummingbot) >>>
```

### Option 2: Direct Command

```bash
# One-liner (activates venv + starts hummingbot)
source /workspaces/venv/hummingbot/bin/activate && hummingbot
```

### Option 3: Background Service (For Continuous Trading)

```bash
# Start Hummingbot in background
source /workspaces/venv/hummingbot/bin/activate
nohup hummingbot > /tmp/hummingbot.log 2>&1 &

# Check if running
ps aux | grep hummingbot

# View logs
tail -f /tmp/hummingbot.log
```

---

## 📊 Hummingbot UI Features

Once Hummingbot starts, you can:

```
Welcome to Hummingbot!

>>>help                          # Show all commands
>>>config                        # View/edit configuration
>>>status                        # Check trading status
>>>balance                       # View wallet balance
>>>history                       # View trade history
>>>start                         # Start trading
>>>stop                          # Stop trading
>>>exit                          # Exit Hummingbot
```

---

## ⚙️ Configure Hummingbot for Solana/Jupiter

### Step 1: Create Strategy

```bash
# In Hummingbot UI
>>> create

# Follow prompts:
# 1. Strategy name: "pure_market_making"
# 2. Exchange: "jupiterswap" or "raydium"
# 3. Trading pair: "SOL-USDC" or "FREECO-CHF"
# 4. Bid spread: 0.1%
# 5. Ask spread: 0.1%
# 6. Order amount: 100 (tokens)
```

### Step 2: Set Wallet

```bash
# In Hummingbot UI
>>> config connectors

# Add Solana connector:
# 1. Exchange: solana
# 2. Wallet address: [Your wallet from .env]
# 3. Private key: [Your private key from .env]
```

### Step 3: Start Trading

```bash
>>> start
# Hummingbot will begin placing orders on Jupiter DEX
```

---

## 🔗 Connect Hummingbot with Your AI Bot

### Integration Architecture

```
┌─────────────────────────────────────┐
│  FreEco AI Signal Generator         │
│  (DeepSeek R1 - every 60 seconds)   │
└──────────────┬──────────────────────┘
               │
               ▼
        ┌──────────────┐
        │  MQTT Broker │
        │  (Messages)  │
        └──────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Hummingbot UI                      │
│  (Receives signals via MQTT)        │
│  (Places orders on Jupiter)         │
└─────────────────────────────────────┘
```

### Step 1: Enable MQTT in Hummingbot

```bash
# In Hummingbot UI
>>> config strategy

# Look for MQTT settings:
# mqtt_enabled: True
# mqtt_broker: localhost
# mqtt_port: 1883
# mqtt_topic: hbot/predictions
```

### Step 2: Create MQTT Signal Listener

Create a new file: `hummingbot_integration.py`

```python
# filepath: /workspaces/freeco-ai-trading-system/hummingbot_integration.py
import paho.mqtt.client as mqtt
import json
from datetime import datetime

class HummingbotMQTTListener:
    def __init__(self, broker="localhost", port=1883):
        self.client = mqtt.Client()
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message
        self.broker = broker
        self.port = port
        self.last_signal = None
        
    def on_connect(self, client, userdata, flags, rc):
        print(f"✓ Connected to MQTT broker: {self.broker}:{self.port}")
        client.subscribe("hbot/predictions/#")
        
    def on_message(self, client, userdata, msg):
        payload = json.loads(msg.payload.decode())
        self.last_signal = {
            "timestamp": datetime.now().isoformat(),
            "topic": msg.topic,
            "signal": payload.get("signal"),
            "confidence": payload.get("confidence"),
            "pair": payload.get("pair"),
            "price_target": payload.get("price_target")
        }
        
        print(f"📊 New Signal Received:")
        print(f"   Pair: {self.last_signal['pair']}")
        print(f"   Signal: {self.last_signal['signal']}")
        print(f"   Confidence: {self.last_signal['confidence']}%")
        print(f"   Price Target: {self.last_signal['price_target']}")
        
        # Send to Hummingbot
        self.send_to_hummingbot(payload)
        
    def send_to_hummingbot(self, signal):
        """Convert AI signal to Hummingbot command"""
        if signal.get("signal") == "BUY":
            print(f"→ Hummingbot: BUY {signal.get('pair')} @ {signal.get('price_target')}")
        elif signal.get("signal") == "SELL":
            print(f"→ Hummingbot: SELL {signal.get('pair')} @ {signal.get('price_target')}")
        else:
            print(f"→ Hummingbot: HOLD {signal.get('pair')}")
        
    def connect(self):
        self.client.connect(self.broker, self.port, keepalive=60)
        
    def start(self):
        self.connect()
        self.client.loop_forever()

if __name__ == "__main__":
    listener = HummingbotMQTTListener()
    print("🚀 Hummingbot MQTT Signal Listener Started")
    print("   Waiting for AI signals...")
    try:
        listener.start()
    except KeyboardInterrupt:
        print("\n✓ Listener stopped")
        listener.client.disconnect()
```

### Step 3: Run Integration

```bash
# Terminal 1: Start your AI Signal Generator
bash run.sh

# Terminal 2: Start Hummingbot
source /workspaces/venv/hummingbot/bin/activate
hummingbot

# Terminal 3: Start MQTT Listener
source /workspaces/venv/hummingbot/bin/activate
python3 hummingbot_integration.py
```

---

## 🎮 Hummingbot Commands Reference

```bash
# Navigation
>>> help [command]               # Show help for command
>>> status                       # Show current status
>>> balance                      # Show wallet balance
>>> history                      # Show trade history

# Configuration
>>> config [strategy]            # Configure strategy
>>> config connectors            # Configure exchanges
>>> config strategy              # Configure strategy params

# Trading Control
>>> start                        # Start trading
>>> stop                         # Stop trading
>>> pause                        # Pause trading
>>> resume                       # Resume trading

# Monitoring
>>> orders                       # Show active orders
>>> trades                       # Show recent trades
>>> pnl                         # Show profit/loss
>>> assets                      # Show asset allocation

# System
>>> logs                        # View logs
>>> set log_level [level]       # Set log level
>>> exit                        # Exit Hummingbot
```

---

## 📈 Monitor Hummingbot Performance

### Real-Time Monitoring Script

Create: `monitor_hummingbot.sh`

```bash
# filepath: /workspaces/freeco-ai-trading-system/monitor_hummingbot.sh
#!/bin/bash

echo "🤖 Hummingbot Performance Monitor"
echo "=================================="
echo ""

while true; do
    clear
    echo "🤖 Hummingbot Performance Monitor"
    echo "=================================="
    echo ""
    
    # Check if running
    if pgrep -f "hummingbot" > /dev/null; then
        echo "✓ Status: RUNNING"
    else
        echo "✗ Status: STOPPED"
    fi
    
    echo ""
    echo "Recent Signals:"
    tail -5 /tmp/ai-signal-generator.log | grep -i signal
    
    echo ""
    echo "Recent Trades:"
    mosquitto_sub -h localhost -t "hbot/trades/#" -C 5 -v 2>/dev/null || echo "Waiting for trade signals..."
    
    echo ""
    echo "Press Ctrl+C to exit. Refreshing in 10 seconds..."
    sleep 10
done
```

Run it:
```bash
bash monitor_hummingbot.sh
```

---

## 🐛 Troubleshooting Hummingbot

### Hummingbot Command Not Found

```bash
# Check if venv is properly activated
source /workspaces/venv/hummingbot/bin/activate
which hummingbot

# If not found, reinstall
pip install hummingbot

# Or install from source
git clone https://github.com/hummingbot/hummingbot.git
cd hummingbot
pip install -e .
```

### Cannot Connect to Exchange

```bash
# In Hummingbot UI
>>> config connectors

# Verify:
# - Exchange name is correct
# - API keys are valid
# - Network connectivity is OK
```

### No Signals Received

```bash
# Check if AI Signal Generator is running
ps aux | grep "node.*ai-signal-generator"

# Check MQTT connectivity
mosquitto_sub -h localhost -t "hbot/predictions/#" -v

# Check AI logs
tail -20 /tmp/ai-signal-generator.log
```

### Wallet Balance Not Updating

```bash
# In Hummingbot UI
>>> balance

# Verify:
# - Wallet address is correct
# - Wallet has SOL for gas fees (0.1+ SOL)
# - Network connectivity is OK
```

---

## 💰 Set Up Trading on Jupiter DEX

### 1. Fund Wallet

```bash
# Send SOL for gas fees
solana transfer YOUR_WALLET_ADDRESS 1  # 1 SOL

# Send FRE.ECO tokens
# Use Jupiter or Raydium to swap SOL → FRE.ECO
```

### 2. Configure Hummingbot for Jupiter

```bash
# In Hummingbot UI
>>> create
# Select: pure_market_making
# Exchange: jupiterswap
# Pair: FREECO-CHF
# Bid/Ask Spread: 0.1-0.5%
# Order amount: 10-100 tokens
```

### 3. Start Trading

```bash
>>> start
# Hummingbot will:
# - Place buy orders at bid price
# - Place sell orders at ask price
# - Update based on AI signals
# - Manage risk with stop-losses
```

---

## 📊 Dashboard Integration

Your AI Trading Bot has 3 interfaces:

| Interface | Port | Purpose |
|-----------|------|---------|
| **Hummingbot CLI** | Terminal | Strategy configuration & trading control |
| **FreEco Dashboard** | 8501 | Real-time metrics & signal monitoring |
| **Solana Explorer** | Web | On-chain transaction verification |

### Access All Three

```bash
# Terminal 1: Hummingbot UI
source /workspaces/venv/hummingbot/bin/activate && hummingbot

# Terminal 2: FreEco Dashboard
# http://localhost:8501
bash open-dashboard.sh

# Terminal 3: Solana Explorer
# https://explorer.solana.com
# Paste your wallet address
```

---

## 🚀 Full Integration Workflow

```bash
# Step 1: Start AI Signal Generator
bash run.sh
# MQTT Broker starts automatically
# AI Generator starts automatically
# Dashboard starts automatically

# Step 2: In new terminal - Start Hummingbot
source /workspaces/venv/hummingbot/bin/activate
hummingbot

# Step 3: In Hummingbot UI
>>> create
# Follow prompts to create pure_market_making strategy

>>> config connectors
# Add Solana wallet and Jupiter DEX

>>> start
# Begin trading

# Step 4: Monitor in real-time
# Terminal 3: tail -f /tmp/ai-signal-generator.log
# Terminal 4: mosquitto_sub -h localhost -t "hbot/#" -v
# Browser: http://localhost:8501 (Dashboard)
# Browser: https://explorer.solana.com (On-chain)
```

---

## ✅ Quick Checklist

- [ ] Hummingbot installed: `source /workspaces/venv/hummingbot/bin/activate && hummingbot --help`
- [ ] Strategy configured: `hummingbot >>> config strategy`
- [ ] Wallet added: `hummingbot >>> config connectors`
- [ ] Wallet funded: `solana balance YOUR_WALLET`
- [ ] MQTT connected: `mosquitto_sub -h localhost -t "hbot/#" -v`
- [ ] AI signals generating: `tail -f /tmp/ai-signal-generator.log`
- [ ] Dashboard accessible: `http://localhost:8501`
- [ ] Trading enabled: `hummingbot >>> start`

---

## 📚 Resources

- **Hummingbot Docs**: https://docs.hummingbot.org
- **Jupiter DEX**: https://jup.ag
- **Solana Docs**: https://docs.solana.com
- **MQTT Documentation**: https://mqtt.org

---

**You're ready to trade with Hummingbot!** 🎯
