# Complete Funding & Trading Setup Guide

## 🏦 Get Your Wallet Address

### Step 1: Find Wallet Address in Code

```bash
# View your wallet address
cat .env | grep MASTER_WALLET_ADDRESS

# Example output:
# MASTER_WALLET_ADDRESS=FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw

# Copy this address (without the variable name)
# You'll use it to receive funds
```

### Step 2: Verify on Blockchain Explorer

1. Go to https://explorer.solana.com
2. Paste your wallet address in search box
3. You'll see: Account balance, transactions, tokens

## 💸 Funding Methods

### Method 1: Phantom Wallet + Exchange (Recommended)

**Setup Phantom:**
1. Install: https://phantom.app
2. Create wallet → Save seed phrase securely
3. Get your Solana address from Phantom

**Fund from Exchange:**
1. Create account: Coinbase, Kraken, or Binance
2. Buy SOL: $50-200 (start small)
3. Withdraw to Phantom wallet address
4. Wait 5-10 minutes for confirmation

**Transfer to Trading Bot:**
1. Open Phantom → Select SOL
2. Click "Send"
3. Paste bot wallet address: `FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw`
4. Amount: Start with 0.5-1 SOL for gas
5. Confirm transaction

### Method 2: Direct Exchange Withdrawal

If your exchange supports direct Solana withdrawal:

1. Copy bot wallet address
2. Exchange → Withdraw → Solana
3. Paste wallet address
4. Confirm amount and fees
5. Done!

### Method 3: Testnet (Learning Only)

For testing without real money:

```bash
# Switch to devnet
solana config set --url devnet

# Get test SOL
solana airdrop 2 FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw

# Only for learning - these aren't real tokens
```

## 🔐 Add Private Key (IMPORTANT!)

⚠️ **WARNING**: Keep your private key secret! Never share it!

### Step 1: Export Private Key from Phantom

1. Open Phantom Wallet
2. Click wallet icon (top right)
3. Settings → Security & Privacy
4. "Show Private Key"
5. Copy the long string (starts with number or letter)

### Step 2: Update .env File

```bash
# Open editor
nano .env

# Find this line:
MASTER_WALLET_PRIVATE_KEY=your-private-key-here

# Replace with your private key from Step 1
MASTER_WALLET_PRIVATE_KEY=5Kg7...xZ   # example

# Save: Ctrl+X, then Y, then Enter
```

### Step 3: Restart Bot

```bash
# Stop running services
pkill -f mosquitto python3 node
sleep 2

# Restart
bash run.sh
```

## 🛒 Buy FRE.ECO Tokens

### Method 1: Jupiter DEX (Easiest)

1. Go to https://jup.ag
2. Click "Connect Wallet"
3. Select Phantom → Approve connection
4. **From:** Select SOL
5. **To:** Search "FREECO" → Select FRE.ECO
6. Amount: Start with 10-100 FRE.ECO
7. Review fee (usually 0.00X SOL)
8. Click "Swap"
9. Approve in Phantom
10. Wait for confirmation

### Method 2: Raydium

1. Go to https://raydium.io
2. Connect Phantom
3. Select SOL → FRE.ECO pair
4. Enter amount
5. Swap
6. Confirm in Phantom

## 💰 Configure Trading Limits

Edit `.env`:

```bash
nano .env

# Find and update these values:

# Maximum amount per single trade (in USD equivalent)
MAX_TRADE_SIZE=100

# Daily loss limit (bot stops trading if this is hit)
MAX_DAILY_LOSS=50

# Take profit target per trade (in USD equivalent)
TAKE_PROFIT_TARGET=200

# Minimum confidence for AI signals (0-100)
MIN_SIGNAL_CONFIDENCE=70

# Save and restart
```

## 🚀 Enable Trading

Edit the AI Signal Generator:

```bash
# Open the main AI file
nano src/ai-signal-generator.js

# Find this line (around line 10):
const TRADING_ENABLED = false;

# Change to:
const TRADING_ENABLED = true;

# Find wallet configuration (around line 12):
const WALLET_ADDRESS = process.env.MASTER_WALLET_ADDRESS;
const WALLET_PRIVATE_KEY = process.env.MASTER_WALLET_PRIVATE_KEY;

# Make sure they're uncommented (no // at start)

# Save and restart
# pkill -f mosquitto python3 node
# bash run.sh
```

## ✅ Verify Setup

```bash
# 1. Check wallet balance
solana balance FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw

# Expected output:
# 1.5 SOL

# 2. Check tokens on Solana Explorer
# Go to: https://explorer.solana.com
# Paste wallet address
# Should see FRE.ECO token holdings

# 3. Test bot startup
bash run.sh

# 4. Watch for first signal
tail -f /tmp/ai-signal-generator.log | grep -i "signal"

# 5. Check dashboard
# http://localhost:8501 → Settings → Wallet section
```

## 📊 Start Trading

### Conservative Approach (Recommended)

**Week 1: Testing**
- Fund: 0.5 SOL + 50 FRE.ECO
- Trade size: $10 per trade
- Monitor: 20-50 trades
- Check: P&L and execution

**Week 2: Small Scale**
- Fund: 2 SOL + 200 FRE.ECO
- Trade size: $50 per trade
- Monitor: Daily P&L
- Check: Win rate and slippage

**Week 3: Medium Scale**
- Fund: 5 SOL + 500 FRE.ECO
- Trade size: $100 per trade
- Monitor: Daily P&L
- Check: Consistency

**Week 4+: Scale Up**
- Only if consistently profitable
- Increase size by 50% per week
- Monitor risk metrics daily
- Set stop-loss alerts

### Aggressive Approach (High Risk)

- Start with more capital
- Larger trade sizes
- Higher risk of losses
- Only if you can afford it

## 🔍 Monitor Trading

```bash
# View live signals
tail -f /tmp/ai-signal-generator.log

# Watch MQTT messages
mosquitto_sub -h localhost -t "hbot/predictions/#" -v

# Check dashboard
# http://localhost:8501

# Monitor wallet
solana balance FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw

# Check recent transactions
# https://explorer.solana.com (paste wallet address)
```

## 💡 Risk Management Rules

1. **Never trade more than 2% of total capital per trade**
   - If capital = $1000, max per trade = $20

2. **Set daily loss limit**
   - If you lose 5% of capital in a day, STOP trading
   - Review what went wrong
   - Resume next day

3. **Monitor win rate**
   - Healthy win rate: 60%+
   - If below 50%, review AI parameters
   - If below 40%, stop and investigate

4. **Take profits**
   - When up 20%, withdraw some profits
   - Never risk profits, only initial capital
   - Build emergency fund first

## 🆘 Emergency Stop

If bot is losing too much:

```bash
# Immediate stop
pkill -f mosquitto python3 node

# Disable trading in .env
nano .env
# Set: ENABLE_TRADING=false

# Investigate issue
tail -100 /tmp/ai-signal-generator.log

# Fix and restart when ready
bash run.sh
```

## 📈 Success Metrics

Track these daily:

```bash
# 1. Total trades executed
grep "SIGNAL" /tmp/ai-signal-generator.log | wc -l

# 2. Winning trades
grep "EXECUTED" /tmp/ai-signal-generator.log | grep -i "profit" | wc -l

# 3. Current P&L
# Dashboard: http://localhost:8501

# 4. Wallet balance
solana balance YOUR_WALLET

# 5. Token holdings
# Explorer: https://explorer.solana.com
```

## ✨ You're Ready to Trade!

Checklist:
- [ ] Wallet created
- [ ] SOL purchased (0.5+)
- [ ] FRE.ECO tokens purchased (10+)
- [ ] Private key added to .env
- [ ] Trading enabled in code
- [ ] Bot running: `bash run.sh`
- [ ] Dashboard accessible: `http://localhost:8501`
- [ ] Signals generating
- [ ] Monitoring P&L

**Start small, grow smart!** 📈
