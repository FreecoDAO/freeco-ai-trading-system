# FreEco AI Trading Bot - Deployment Guide

## Quick Start (GitHub Codespaces)

### 1. Access Your Codespace

Open your GitHub Codespace at: https://freeco-trading-bot-x5w6g6jj4qx5c5rq.github.dev

### 2. Run the Automated Setup

```bash
cd /workspaces/freeco-ai-trading-system
./setup-codespace.sh
```

This script will:
- ✅ Install all system dependencies (Node.js, Python, MQTT)
- ✅ Install Node.js packages (mqtt, axios, dotenv)
- ✅ Start MQTT Broker (Mosquitto)
- ✅ Test AI Signal Generator (DeepSeek R1)
- ✅ Install Hummingbot Dashboard
- ✅ Create startup scripts

### 3. Start All Services

```bash
/workspaces/freeco-ai-trading-system/start-all.sh
```

### 4. Access the Dashboard

Open in your browser:
- **Hummingbot Dashboard**: `http://localhost:8501`
- **MQTT Broker**: `localhost:1883`

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
│           │                 │   Hummingbot     │            │
│           │                 │   Dashboard      │            │
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

## Configuration

### Environment Variables

The system uses the following environment variables (already configured):

```bash
# AI API Keys
NOVITA_API_KEY=sk_18Vuiio04cZmEs3ieW1xE2j9uoT9_VuGewihPFqVRe0
DEEPSEEK_API_URL=https://api.novita.ai/openai/v1
DEEPSEEK_MODEL=deepseek/deepseek-r1

# Minimax M2 (Optional)
MINIMAX_API_KEY=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
MINIMAX_API_URL=https://api.minimax.io/v1
MINIMAX_MODEL=MiniMax-M2

# MQTT Configuration
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_TOPIC_PREFIX=hbot/predictions

# Trading Configuration
FREECO_TOKEN=2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc
CHF_TOKEN=3bKaHFgY4Ja9JMgxxZhzi3NtbSd3WQRzPYadgZ7dLzFB
TRADING_PAIRS=FREECO_CHF,FREECO_HAPPYTAILS

# Master Wallet (Add your private key here)
MASTER_WALLET_PRIVATE_KEY=your-private-key-here
```

### Wallet Setup

You have 5 Solana wallets created:

1. **Master Wallet**: `FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw`
   - Funded with 10 FRE.ECO tokens
   - Used for main trading operations

2. **Arbitrage Wallet**: For arbitrage strategies
3. **Market Maker Wallet**: For market making
4. **Trend Follower Wallet**: For trend-following strategies
5. **Treasury Wallet**: For fund management

---

## AI Models

### Primary: DeepSeek R1 (via Novita.ai)

- **Model**: `deepseek/deepseek-r1`
- **Cost**: $0.7/Mt Input, $2.5/Mt Output
- **Speed**: Fast (5-10 seconds per analysis)
- **Use Case**: Real-time market analysis and trading signals

### Secondary: Minimax M2 (Optional)

- **Model**: `MiniMax-M2`
- **Cost**: $0.3/Mt Input, $1.2/Mt Output
- **Speed**: Medium (10-15 seconds per analysis)
- **Use Case**: Fallback for complex strategy decisions

---

## Trading Strategies

### 1. AI-Driven Market Making

- Uses AI signals from DeepSeek R1
- MQTT-based communication
- Hummingbot's `ai_livestream` controller

### 2. Arbitrage

- Cross-DEX arbitrage opportunities
- Jupiter aggregation for best prices
- Dedicated arbitrage wallet

### 3. Trend Following

- AI-powered trend detection
- Risk-managed position sizing
- Stop-loss automation

---

## Monitoring & Logs

### View Logs

```bash
# MQTT Broker
tail -f /tmp/mosquitto.log

# AI Signal Generator
tail -f /tmp/ai-signal-generator.log

# Hummingbot Dashboard
tail -f /tmp/hummingbot-dashboard.log
```

### Check Running Services

```bash
# Check if services are running
ps aux | grep mosquitto
ps aux | grep node
ps aux | grep streamlit
```

### Test MQTT Connection

```bash
# Subscribe to signals
mosquitto_sub -h localhost -t "hbot/predictions/#" -v

# Publish test signal
mosquitto_pub -h localhost -t "hbot/predictions/test" -m "test message"
```

---

## Troubleshooting

### MQTT Broker Not Starting

```bash
# Kill existing process
pkill mosquitto

# Restart
mosquitto -c /etc/mosquitto/mosquitto.conf &
```

### AI Signal Generator Errors

```bash
# Check API key
echo $NOVITA_API_KEY

# Test API directly
curl -s "https://api.novita.ai/openai/v1/chat/completions" \
  -H "Authorization: Bearer $NOVITA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek/deepseek-r1","messages":[{"role":"user","content":"Hello"}],"max_tokens":50}'
```

### Hummingbot Dashboard Not Loading

```bash
# Check if Streamlit is running
ps aux | grep streamlit

# Restart dashboard
cd /workspaces/hummingbot-dashboard
streamlit run main.py --server.port 8501 --server.address 0.0.0.0
```

---

## Next Steps

1. **Fund Your Wallets**
   - Transfer SOL for gas fees
   - Transfer FRE.ECO tokens for trading

2. **Configure Hummingbot**
   - Import wallet private keys
   - Set up trading pairs (FRE.ECO/CHF)
   - Configure risk parameters

3. **Test Trading**
   - Start with small amounts
   - Monitor AI signals
   - Verify trades on Solana Explorer

4. **Scale Up**
   - Increase position sizes
   - Add more trading pairs
   - Deploy multiple strategies

---

## Security Notes

⚠️ **IMPORTANT:**

- Never commit private keys to Git
- Use environment variables for sensitive data
- Keep API keys secure
- Monitor wallet balances regularly
- Set up alerts for unusual activity

---

## Support

- **GitHub Repository**: https://github.com/FreecoDAO/freeco-ai-trading-system
- **Hummingbot Docs**: https://docs.hummingbot.org
- **Novita.ai Docs**: https://novita.ai/docs
- **Solana Docs**: https://docs.solana.com

---

## License

This project is open source under the Apache 2.0 License.
