# FreEco AI Trading Bot - Complete How-To Guide

## 🚀 How to Run

### Quick Start (1 Command)

```bash
bash run.sh
```

That's it! The script will:
- ✅ Clean up old processes
- ✅ Start MQTT Broker
- ✅ Start AI Signal Generator
- ✅ Start Dashboard HTTP Server
- ✅ Show access information

### Expected Output

```
═══════════════════════════════════════════════════════
✅ All Services Started!
═══════════════════════════════════════════════════════

📊 Dashboard: http://localhost:8501
📡 MQTT Broker: localhost:1883
🤖 AI Signal Generator: Running

✨ Next Steps:
   1. Open http://localhost:8501 in your browser
   2. Monitor AI signals: tail -f /tmp/ai-signal-generator.log
   3. Stop services: pkill -f mosquitto python3 node
```

### Manual Start (Step by Step)

If you need to start services individually:

```bash
# Terminal 1: Start MQTT Broker
mosquitto -c /etc/mosquitto/mosquitto.conf -d -p 1883
sleep 2

# Terminal 2: Start AI Signal Generator
node src/ai-signal-generator.js

# Terminal 3: Start Dashboard
cd hummingbot-dashboard
python3 server.py
```

### Verify Everything is Running

```bash
# Check all processes
ps aux | grep -E "mosquitto|node|python3.*server"

# Test MQTT connectivity
mosquitto_pub -h localhost -t "test" -m "hello" && echo "✓ MQTT OK"

# Test Dashboard HTTP
curl -I http://localhost:8501 | head -1
# Should show: HTTP/1.0 200 OK
```

### Access Dashboard

**Local Machine:**
```
http://localhost:8501
```

**GitHub Codespaces:**
1. Click "Ports" tab in terminal
2. Look for port 8501
3. Click the forwarded URL

**Command:**
```bash
bash open-dashboard.sh
```

---

## 🎯 How to Fine-Tune

### 1. AI Signal Parameters

Edit `.env` to change AI behavior:

```bash
# Open configuration
nano .env
```

Key settings:

```bash
# Change AI model (if using different provider)
DEEPSEEK_MODEL=deepseek/deepseek-r1

# Change signal frequency (in seconds)
# Currently: 60 seconds
# Edit src/ai-signal-generator.js, line 25:
setInterval(generateSignal, 60000);  # Change 60000 to desired milliseconds
```

### 2. Trading Pair Configuration

Edit `.env` to change which pairs to trade:

```bash
# Current pairs
FREECO_TOKEN=2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc
CHF_TOKEN=3bKaHFgY4Ja9JMgxxZhzi3NtbSd3WQRzPYadgZ7dLzFB
TRADING_PAIRS=FREECO_CHF,FREECO_HAPPYTAILS
```

Add new pair:
```bash
# Get token addresses from Solana blockchain
# Update tokens and TRADING_PAIRS in .env
TRADING_PAIRS=FREECO_CHF,FREECO_HAPPYTAILS,NEW_PAIR
```

### 3. Signal Threshold Tuning

Edit `src/ai-signal-generator.js` to change signal sensitivity:

```javascript
// Find this section (around line 30):
const signal = response.data.choices[0].message.content;

// Add confidence threshold check:
if (confidence < 70) {
  console.log("⚠ Low confidence signal, skipping");
  return;
}

// Change 70 to higher (80, 90) for fewer signals
// or lower (50, 60) for more signals
```

### 4. Risk Management Parameters

Edit `src/ai-signal-generator.js` to add risk controls:

```javascript
// Add position sizing limits:
const maxTradeSize = 1000;  // USD
const maxDailyLoss = 500;   // USD stop-loss
const takeProfitTarget = 2000;  // USD target

// Add to signal payload:
payload.maxSize = maxTradeSize;
payload.stopLoss = maxDailyLoss;
payload.target = takeProfitTarget;
```

### 5. Dashboard Customization

Edit `hummingbot-dashboard/server.py` to customize display:

```python
# Around line 150, modify metric cards:
def get_hummingbot_stats(self):
    return {
        "status": "running",
        "strategies": 3,
        "total_trades": 1247,
        # Add custom metrics:
        "daily_pnl": 450.25,
        "monthly_pnl": 5230.50,
        "win_rate": 67.3
    }
```

### 6. MQTT Topic Configuration

Change MQTT signal destinations:

```bash
# Edit .env
MQTT_TOPIC_PREFIX=hbot/predictions

# Change to:
MQTT_TOPIC_PREFIX=trading/signals
# or
MQTT_TOPIC_PREFIX=freeco/ai/signals
```

Then update `src/ai-signal-generator.js` line 45:
```javascript
client.publish(`${TOPIC_PREFIX}/freeco_chf`, JSON.stringify(payload));
```

### 7. AI Prompt Fine-Tuning

Customize the AI analysis prompt:

Edit `src/ai-signal-generator.js`, around line 30:

```javascript
// Current prompt:
"content": "Analyze FRE.ECO/CHF market. Provide: 1) Trend (buy/sell/hold) 2) Confidence (0-100) 3) Price target"

// Change to more detailed prompt:
"content": `Analyze FRE.ECO/CHF market with:
  1. Technical analysis (RSI, MACD, Moving Averages)
  2. Sentiment analysis
  3. Volume analysis
  4. Price target (short-term: 1h, medium-term: 4h)
  5. Risk assessment
  6. Confidence score (0-100)
  7. Recommended position size
  Return as JSON.`
```

### Test Fine-Tuning Changes

```bash
# Stop current services
pkill -f mosquitto python3 node

sleep 2

# Start fresh with new config
bash run.sh

# Monitor signals
tail -f /tmp/ai-signal-generator.log

# Watch dashboard update
# http://localhost:8501
```

---

## 💰 How to Add Funds

### Step 1: Get Your Wallet Address

```bash
# From .env file
grep "MASTER_WALLET_ADDRESS" .env

# Output:
# MASTER_WALLET_ADDRESS=FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw
```

Copy this address.

### Step 2: Get SOL for Gas Fees

**Option A: Buy SOL**
1. Create account on Coinbase, Kraken, or Phantom wallet
2. Buy 0.5-2 SOL
3. Send to your wallet address
4. Wait for confirmation (2-5 minutes)

**Option B: Use Solana Faucet (Devnet)**
```bash
# For testnet only (not real money):
solana config set --url devnet
solana airdrop 2  # 2 SOL

# Then use devnet tokens only
```

### Step 3: Get FRE.ECO Tokens

**Option A: Swap on Jupiter DEX**
1. Go to https://jup.ag
2. Connect Phantom wallet
3. Swap SOL → FRE.ECO
4. Amount: Start with 10-100 FRE.ECO for testing

**Option B: Direct Transfer**
If you have FRE.ECO already:
```bash
# Send to wallet address from Step 1
```

### Step 4: Add Your Private Key

⚠️ **SECURITY WARNING**: Only do this after testing with small amounts!

```bash
# 1. Get your private key from Phantom wallet
#    Phantom → Settings → Security & Privacy → Show Private Key
#
# 2. Update .env file
nano .env

# Find this line:
MASTER_WALLET_PRIVATE_KEY=your-private-key-here

# Replace with your actual private key (from Phantom)
MASTER_WALLET_PRIVATE_KEY=5Kg...1xZ

# 3. Save and exit (Ctrl+X, Y, Enter)

# 4. Restart bot
bash stop-all.sh
sleep 2
bash run.sh
```

### Step 5: Monitor Wallet

```bash
# Check wallet balance via Solana blockchain explorer
# https://explorer.solana.com/?cluster=mainnet-beta
# Paste your wallet address

# Or via CLI:
solana balance FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw

# Or via Dashboard
# http://localhost:8501 → Settings tab → Wallet info
```

### Step 6: Configure Trade Parameters

Update trade sizes in `.env`:

```bash
# Maximum per trade
MAX_TRADE_SIZE=100

# Daily stop loss
MAX_DAILY_LOSS=50

# Take profit target
TAKE_PROFIT_TARGET=200
```

### Step 7: Enable Trading

Edit `src/ai-signal-generator.js`:

```javascript
// Find this section (around line 60):
const TRADING_ENABLED = false;  // ← Change to true

// Change to:
const TRADING_ENABLED = true;

// Also set wallet info:
const WALLET_ADDRESS = process.env.MASTER_WALLET_ADDRESS;
const WALLET_PRIVATE_KEY = process.env.MASTER_WALLET_PRIVATE_KEY;
```

### Step 8: Test with Small Amount

```bash
# 1. Fund wallet with only $10-50 worth of SOL/tokens
# 2. Start bot: bash run.sh
# 3. Watch logs: tail -f /tmp/ai-signal-generator.log
# 4. Monitor trades: Monitor dashboard at http://localhost:8501
# 5. After 10-20 trades, check results
# 6. If profitable, increase funding gradually
```

### Step 9: Monitor & Scale

**Daily Monitoring:**
```bash
# Check wallet balance
solana balance YOUR_WALLET_ADDRESS

# Check P&L
# Dashboard: http://localhost:8501 → FreEco AI tab

# Review signals
tail -50 /tmp/ai-signal-generator.log | grep -i "signal"
```

**Scaling:**
1. Profitable? → Increase MAX_TRADE_SIZE by 50%
2. Still profitable after 100 trades? → Increase by another 50%
3. Draw-down? → Decrease by 25%
4. Stop loss hit? → Review AI parameters, restart

---

## ⚙️ Configuration File Reference

### .env File

```bash
# AI Configuration
NOVITA_API_KEY=sk_18Vuiio04cZmEs3ieW1xE2j9uoT9_VuGewihPFqVRe0
DEEPSEEK_API_URL=https://api.novita.ai/openai/v1
DEEPSEEK_MODEL=deepseek/deepseek-r1

# MQTT Configuration
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_TOPIC_PREFIX=hbot/predictions

# Trading Configuration
FREECO_TOKEN=2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc
CHF_TOKEN=3bKaHFgY4Ja9JMgxxZhzi3NtbSd3WQRzPYadgZ7dLzFB
TRADING_PAIRS=FREECO_CHF,FREECO_HAPPYTAILS

# Wallet Configuration
MASTER_WALLET_ADDRESS=FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw
MASTER_WALLET_PRIVATE_KEY=your-private-key-here

# Trading Limits
MAX_TRADE_SIZE=1000
MAX_DAILY_LOSS=500
TAKE_PROFIT_TARGET=2000
MIN_SIGNAL_CONFIDENCE=70

# Signal Generation
SIGNAL_INTERVAL_SECONDS=60
ENABLE_TRADING=false
```

---

## 🐛 Troubleshooting Fine-Tuning

### No Signals Generated

```bash
# Check API key
echo $NOVITA_API_KEY

# Test API manually
curl -s https://api.novita.ai/openai/v1/chat/completions \
  -H "Authorization: Bearer $NOVITA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek/deepseek-r1","messages":[{"role":"user","content":"test"}],"max_tokens":50}' \
  | head -c 200

# Check logs for errors
tail -20 /tmp/ai-signal-generator.log
```

### Signals But No Trading

```bash
# Verify wallet configured
grep WALLET .env

# Verify trading enabled
grep TRADING_ENABLED src/ai-signal-generator.js

# Check wallet has funds
solana balance YOUR_WALLET_ADDRESS
```

### Performance Degrading

```bash
# Check memory usage
ps aux | grep node
ps aux | grep python3

# Clear old logs
> /tmp/ai-signal-generator.log
> /tmp/hummingbot-dashboard.log

# Restart services
bash run.sh
```

---

## 📚 Quick Reference

| Task | Command |
|------|---------|
| **Start Bot** | `bash run.sh` |
| **Stop Bot** | `pkill -f mosquitto python3 node` |
| **View Logs** | `tail -f /tmp/ai-signal-generator.log` |
| **Dashboard** | `http://localhost:8501` |
| **Watch Signals** | `mosquitto_sub -h localhost -t "hbot/#" -v` |
| **Edit Config** | `nano .env` |
| **Edit AI Prompt** | `nano src/ai-signal-generator.js` |
| **Get Wallet** | `grep MASTER_WALLET .env` |
| **Check Balance** | `solana balance YOUR_WALLET` |
| **Restart** | `bash stop-all.sh && bash run.sh` |

---

## 🎯 Success Checklist

- [ ] Services running: `bash run.sh`
- [ ] Dashboard accessible: `http://localhost:8501`
- [ ] Signals generating: `tail -f /tmp/ai-signal-generator.log`
- [ ] .env configured with API key
- [ ] Wallet address obtained
- [ ] Funded with test SOL/tokens
- [ ] Private key added to .env
- [ ] Trading enabled in code
- [ ] Running with small amounts
- [ ] Monitoring profits daily

---

**You're ready to run and fine-tune your AI trading bot!** 🚀
