# FreEco AI Trading System - Complete Setup Guide

## Overview

This is the **PROPER** integration of FreEco AI Trading Bot using:
- ✅ **Official Hummingbot Dashboard** (not custom UI)
- ✅ **Official CrewAI CLI** (not custom implementation)
- ✅ **Hummingbot API** for bot management
- ✅ **GitHub Codespaces** for persistent environment

## Architecture

```
CrewAI Agents (Market Analysis)
    ↓
Hummingbot API
    ↓
Hummingbot Dashboard (Streamlit UI)
    ↓
Hummingbot Bot Instances
    ↓
Solana/Jupiter (FRE.ECO/CHF Trading)
```

## Prerequisites

1. **GitHub Account** with access to FreecoDAO
2. **GitHub PAT**: (use your own PAT with repo access)
3. **API Keys**:
   - DeepSeek API key (for AI analysis)
   - Helius RPC key (for Solana)
   - OpenAI API key (optional, for CrewAI)

## Step 1: Fork and Clone to GitHub

```bash
# This repo is already initialized locally at:
# /home/ubuntu/freeco-ai-trading-system

# Push to GitHub
cd /home/ubuntu/freeco-ai-trading-system
git remote add origin https://github.com/FreecoDAO/freeco-ai-trading-system.git
git branch -M main
git push -u origin main
```

## Step 2: Open in GitHub Codespaces

1. Go to https://github.com/FreecoDAO/freeco-ai-trading-system
2. Click "Code" → "Codespaces" → "Create codespace on main"
3. Select **16GB** machine type
4. Wait for Codespace to initialize

## Step 3: Install Components in Codespace

### A. Install Hummingbot

```bash
# Pull Hummingbot Docker image
docker pull hummingbot/hummingbot:latest

# Create Hummingbot data directories
mkdir -p ~/hummingbot_files/{conf,logs,data,scripts,certs,pmm_scripts}

# Run Hummingbot
docker run -it \
  --name hummingbot \
  --network host \
  -v ~/hummingbot_files/conf:/conf \
  -v ~/hummingbot_files/logs:/logs \
  -v ~/hummingbot_files/data:/data \
  -v ~/hummingbot_files/scripts:/scripts \
  -v ~/hummingbot_files/certs:/certs \
  -v ~/hummingbot_files/pmm_scripts:/pmm_scripts \
  hummingbot/hummingbot:latest
```

### B. Install Hummingbot Dashboard

```bash
cd hummingbot-dashboard
pip install -r requirements.txt
streamlit run main.py --server.port 8501
```

### C. Install CrewAI

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# Install CrewAI CLI
uv tool install crewai

# Create FreEco strategy project
crewai create crew freeco-strategy
cd freeco-strategy

# Install dependencies
crewai install
```

## Step 4: Configure FreEco Trading

### A. Configure Hummingbot Wallet

1. In Hummingbot CLI, run:
```
connect solana
```

2. Import Master wallet private key:
```
# Use the private key from: /home/ubuntu/freeco-defi-bot/data/wallets/master_wallet.json
```

3. Configure FRE.ECO/CHF pair:
```
create
# Select: pure_market_making
# Exchange: solana
# Trading pair: FREECO-CHF
```

### B. Configure CrewAI Agents

Edit `freeco-strategy/src/freeco_strategy/config/agents.yaml`:

```yaml
market_analyst:
  role: >
    Market Analyst
  goal: >
    Analyze FRE.ECO/CHF market conditions and generate trading signals
  backstory: >
    Expert in crypto market analysis with deep knowledge of Solana DEX dynamics
  llm: deepseek-chat  # or minimax-m2

risk_manager:
  role: >
    Risk Manager
  goal: >
    Assess risk and validate trading decisions
  backstory: >
    Conservative risk manager focused on capital preservation

trade_executor:
  role: >
    Trade Executor
  goal: >
    Execute approved trades via Hummingbot API
  backstory: >
    Experienced trader with expertise in automated execution
```

Edit `freeco-strategy/src/freeco_strategy/config/tasks.yaml`:

```yaml
analyze_market:
  description: >
    Analyze FRE.ECO/CHF market using Jupiter API data
  expected_output: >
    Trading signal (BUY/SELL/HOLD) with confidence score
  agent: market_analyst

assess_risk:
  description: >
    Evaluate risk of proposed trade
  expected_output: >
    Risk assessment with approval/rejection
  agent: risk_manager

execute_trade:
  description: >
    Execute trade via Hummingbot API
  expected_output: >
    Trade confirmation with transaction ID
  agent: trade_executor
```

### C. Connect CrewAI to Hummingbot

Create `freeco-strategy/src/freeco_strategy/tools/hummingbot_tool.py`:

```python
from crewai_tools import tool
import requests

@tool("Execute trade on Hummingbot")
def execute_hummingbot_trade(signal: str, pair: str, amount: float):
    """Execute a trade via Hummingbot API"""
    response = requests.post(
        "http://localhost:8080/api/trade",
        json={
            "signal": signal,
            "pair": pair,
            "amount": amount
        }
    )
    return response.json()
```

## Step 5: Run the Complete System

### Terminal 1: Hummingbot
```bash
docker start -ai hummingbot
```

### Terminal 2: Hummingbot Dashboard
```bash
cd hummingbot-dashboard
streamlit run main.py
```

### Terminal 3: CrewAI Strategy
```bash
cd freeco-strategy
crewai run
```

## Step 6: Access Dashboards

- **Hummingbot Dashboard**: http://localhost:8501
- **Hummingbot API**: http://localhost:8080

## Token Addresses

- **FRE.ECO**: `2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc`
- **CHF**: `3bKaHFgY4Ja9JMgxxZhzi3NtbSd3WQRzPYadgZ7dLzFB`
- **Master Wallet**: `FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw`

## Funding the Bot

Transfer tokens to Master Wallet:
```
FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw
```

## Monitoring

1. **Hummingbot Dashboard** - View all bot activity, P&L, trades
2. **Hummingbot Logs** - `~/hummingbot_files/logs/`
3. **CrewAI Output** - Terminal output from `crewai run`

## Troubleshooting

### Hummingbot won't start
- Check Docker is running: `docker ps`
- Check logs: `docker logs hummingbot`

### Dashboard won't connect
- Ensure Hummingbot API is enabled
- Check port 8080 is accessible

### CrewAI errors
- Verify API keys in `.env`
- Run `crewai install` to reinstall dependencies

## Next Steps

1. **Test with small amounts** first
2. **Monitor for 24 hours** before increasing capital
3. **Adjust strategy parameters** based on performance
4. **Scale up** once profitable

## Improvements to Propose

### To Hummingbot:
1. Better Solana/Jupiter integration
2. Built-in AI signal support
3. Improved dashboard for DEX trading

### To CrewAI:
1. Trading-specific agent templates
2. Built-in market data tools
3. Backtesting integration

## Support

- Hummingbot Discord: https://discord.gg/hummingbot
- CrewAI Discord: https://discord.gg/crewai
- FreecoDAO: https://github.com/FreecoDAO
