# Jupiter Wallet SDK Integration Guide

## 🚀 What is Jupiter Wallet SDK?

The **Jupiter Wallet SDK** is the official integration for:
- ✅ Direct wallet connections
- ✅ Real-time swap execution
- ✅ Quote aggregation
- ✅ Multi-route optimization
- ✅ Best price routing

---

## 📍 Wallet Location

Your bot wallet is stored at:

```bash
~/.freeco/wallet.json
```

Contents:
```json
{
  "publicKey": "FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw",
  "secretKey": [123, 45, 67, ...],
  "createdAt": "2025-01-23T22:00:00.000Z"
}
```

---

## 💰 Fund Your Wallet

### Get Your Wallet Address

```bash
# Method 1: From environment
echo $MASTER_WALLET_ADDRESS

# Method 2: From wallet file
cat ~/.freeco/wallet.json | grep publicKey

# Method 3: From .env
grep MASTER_WALLET_ADDRESS .env
```

**Your address**: `FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw`

### Fund with SOL (Gas Fees)

**Via Phantom Wallet:**
1. Install: https://phantom.app
2. Buy SOL (0.5-2 SOL)
3. Send to your wallet address
4. Wait for confirmation

**Via Exchange (Coinbase/Kraken/Binance):**
1. Buy SOL
2. Withdraw to: `FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw`
3. Wait 30 seconds for confirmation

### Get FRE.ECO Tokens

**Via Jupiter DEX:**
1. Go to https://jup.ag
2. Connect Phantom wallet
3. Swap: SOL → FRE.ECO
4. Amount: 10-100 tokens minimum
5. Confirm swap

---

## 🔄 Jupiter SDK Functions

### Get Quote

```javascript
const quote = await walletService.getJupiterQuote(
  inputMint,      // Token to sell (e.g., SOL)
  outputMint,     // Token to buy (e.g., FRE.ECO)
  amount,         // Amount in smallest unit
  slippageBps     // Slippage (50 = 0.5%, default)
);
```

**Example:**
```javascript
const quote = await walletService.getJupiterQuote(
  'So11111111111111111111111111111111111111112', // SOL
  '2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc', // FRE.ECO
  1000000000, // 1 SOL
  50 // 0.5% slippage
);

console.log(`Best rate: ${quote.outputAmount} FRE.ECO`);
console.log(`Price impact: ${quote.priceImpactPct}%`);
```

### Execute Swap

```javascript
const result = await walletService.executeJupiterSwap(
  inputMint,  // Token to sell
  outputMint, // Token to buy
  amount      // Amount to swap
);
```

**Example:**
```javascript
const result = await walletService.executeJupiterSwap(
  'So11111111111111111111111111111111111111112', // SOL
  '2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc', // FRE.ECO
  500000000 // 0.5 SOL
);

if (result.success) {
  console.log(`✓ Swap successful!`);
  console.log(`  TX: ${result.txId}`);
  console.log(`  Got: ${result.outputAmount} FRE.ECO`);
} else {
  console.error(`✗ Swap failed: ${result.error}`);
}
```

### Get Available Routes

```javascript
const routes = await walletService.getAvailableRoutes(
  inputMint,
  outputMint
);

console.log(`Available routes: ${routes.routes}`);
console.log(`Best route output: ${routes.bestRoute.outAmount}`);
```

### Validate Before Swap

```javascript
const validation = await walletService.validateSwap(
  inputMint,
  outputMint,
  amount
);

if (validation.valid) {
  console.log(`✓ Valid swap`);
  console.log(`  Output: ${validation.outputAmount}`);
  console.log(`  Min received: ${validation.minimumReceived}`);
} else {
  console.log(`✗ Invalid: ${validation.error}`);
}
```

### Get Token Price

```javascript
const priceInSol = await walletService.getTokenPrice(
  '2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc' // FRE.ECO
);

console.log(`FRE.ECO price: ${priceInSol} SOL`);
```

---

## 📊 Check Balances

### Check SOL Balance

```bash
# Command line
solana balance FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw

# Or via API
curl http://localhost:3000/api/wallet
```

### Check Token Balance

```javascript
const balance = await walletService.getTokenBalance(
  '2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc' // FRE.ECO
);

console.log(`FRE.ECO balance: ${balance}`);
```

### View on Solana Explorer

```
https://explorer.solana.com/address/FYsXJAt52drwDiytaodNjBNunG37uDA5T5Zkm1XgvzVw
```

---

## 🔐 Private Key Management

**Your private key is stored in:**
```bash
~/.freeco/wallet.json → secretKey field
```

**Never share or expose your private key!**

### Update Private Key in .env

Only if using external wallet:

```bash
nano .env

# Find:
MASTER_WALLET_PRIVATE_KEY=your-private-key-here

# Replace with your actual private key from Phantom:
# Settings → Security & Privacy → Show Private Key
```

---

## 📈 Integration Example

Full trading flow:

```javascript
// 1. Initialize wallet
const wallet = require('./src/wallet-service.js');
await wallet.init();

// 2. Get wallet info
console.log(`Wallet: ${wallet.getWalletAddress()}`);
const balance = await wallet.getBalance();
console.log(`SOL Balance: ${balance}`);

// 3. Get quote for swap
const quote = await wallet.getJupiterQuote(
  'So11111111111111111111111111111111111111112', // SOL
  '2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc', // FRE.ECO
  500000000 // 0.5 SOL
);

console.log(`Can get ${quote.outputAmount} FRE.ECO`);

// 4. Validate swap
const validation = await wallet.validateSwap(
  'So11111111111111111111111111111111111111112',
  '2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc',
  500000000
);

if (validation.valid) {
  // 5. Execute swap
  const result = await wallet.executeJupiterSwap(
    'So11111111111111111111111111111111111111112',
    '2qEb9Ai7uErRxsjWnT6MaoYXajXf8KjGGhQEsG24jPxc',
    500000000
  );
  
  if (result.success) {
    console.log(`✓ Traded! TX: ${result.txId}`);
  }
}
```

---

## 🛠️ Troubleshooting

### No Routes Found

```javascript
// Error: No route found
// Solution: Check if tokens exist and have liquidity
const routes = await wallet.getAvailableRoutes(inputMint, outputMint);
if (!routes) {
  console.log('No liquidity for this pair');
}
```

### Insufficient Balance

```javascript
// Error: Not enough SOL for gas
// Solution: Add more SOL to wallet
const balance = await wallet.getBalance();
if (balance < 0.1) {
  console.log('Need at least 0.1 SOL for gas');
}
```

### Transaction Failed

```javascript
// Error: Transaction failed
// Solution: Check on Solana Explorer
// https://explorer.solana.com/tx/YOUR_TX_ID
```

### Wrong Wallet Address

```bash
# Verify correct address
cat ~/.freeco/wallet.json
# Copy publicKey value
# Fund that address, not a different one
```

---

## ✅ Complete Checklist

- [ ] Wallet created at `~/.freeco/wallet.json`
- [ ] Wallet address obtained
- [ ] 0.5+ SOL funded to wallet
- [ ] 10+ FRE.ECO tokens obtained
- [ ] Balance verified on Explorer
- [ ] Private key secured
- [ ] .env configured correctly
- [ ] Jupiter SDK working
- [ ] Ready to execute trades!

---

## 📚 Resources

- **Jupiter Documentation**: https://docs.jup.ag
- **Jupiter API**: https://api.jup.ag
- **Solana Documentation**: https://docs.solana.com
- **Phantom Wallet**: https://phantom.app
- **Solana Explorer**: https://explorer.solana.com

---

**You're ready to trade with Jupiter SDK!** 🚀💰
