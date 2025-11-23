/**
 * Wallet Management Service with Jupiter AG SDK
 * Manages Solana wallet connections and Jupiter DEX integration
 */

const { Keypair, Connection, PublicKey, LAMPORTS_PER_SOL } = require('@solana/web3.js');
const { getAssociatedTokenAddress, getMint } = require('@solana/spl-token');
const fs = require('fs');
const path = require('path');

class WalletService {
  constructor() {
    this.connection = null;
    this.wallet = null;
    this.walletPath = path.join(process.env.HOME, '.freeco', 'wallet.json');
    this.rpcUrl = process.env.SOLANA_RPC_URL || 'https://api.mainnet-beta.solana.com';
    this.jupiterUrl = 'https://api.jup.ag/swap/v1';
    this.tokenAccounts = {};
  }

  async init() {
    console.log('💰 Initializing Wallet Service with Jupiter AG SDK...');
    
    try {
      // Initialize Solana connection
      this.connection = new Connection(this.rpcUrl, 'confirmed');
      
      // Load or create wallet
      await this.loadOrCreateWallet();
      
      console.log('✓ Wallet Service initialized');
      console.log(`  📍 Address: ${this.wallet.publicKey.toString()}`);
      
      // Check balance
      const balance = await this.getBalance();
      console.log(`  💵 Balance: ${balance.toFixed(4)} SOL`);
      
      // Check token balances
      await this.loadTokenBalances();
      
      return true;
    } catch (error) {
      console.error('❌ Wallet init error:', error.message);
      return false;
    }
  }

  async loadOrCreateWallet() {
    try {
      // Create wallet directory
      const dir = path.dirname(this.walletPath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }

      // Try to load existing wallet
      if (fs.existsSync(this.walletPath)) {
        const walletData = JSON.parse(fs.readFileSync(this.walletPath, 'utf8'));
        this.wallet = Keypair.fromSecretKey(Buffer.from(walletData.secretKey));
        console.log('✓ Wallet loaded from file');
      } else {
        // Create new wallet
        this.wallet = Keypair.generate();
        const walletData = {
          publicKey: this.wallet.publicKey.toString(),
          secretKey: Array.from(this.wallet.secretKey),
          createdAt: new Date().toISOString()
        };
        fs.writeFileSync(this.walletPath, JSON.stringify(walletData, null, 2));
        console.log('✓ New wallet created');
        console.log(`⚠️  Fund wallet at: ${this.wallet.publicKey.toString()}`);
      }
    } catch (error) {
      console.error('❌ Wallet load error:', error.message);
      throw error;
    }
  }

  async loadTokenBalances() {
    try {
      const tokenAccounts = await this.connection.getParsedTokenAccountsByOwner(
        this.wallet.publicKey,
        { programId: new PublicKey('TokenkegQfeZyiNwAJsyFbPVwwQQnmLYKPrA7ieKj9u') }
      );

      for (const account of tokenAccounts.value) {
        const mint = account.account.data.parsed.info.mint;
        const amount = account.account.data.parsed.info.tokenAmount.uiAmount;
        this.tokenAccounts[mint] = {
          address: account.pubkey.toString(),
          amount,
          decimals: account.account.data.parsed.info.tokenAmount.decimals
        };
      }

      if (Object.keys(this.tokenAccounts).length > 0) {
        console.log('✓ Token accounts loaded:');
        Object.entries(this.tokenAccounts).forEach(([mint, data]) => {
          console.log(`  • ${mint}: ${data.amount} tokens`);
        });
      }
    } catch (error) {
      console.error('⚠️  Token balance load error:', error.message);
    }
  }

  async getBalance() {
    try {
      const balance = await this.connection.getBalance(this.wallet.publicKey);
      return balance / LAMPORTS_PER_SOL;
    } catch (error) {
      console.error('❌ Balance fetch error:', error.message);
      return 0;
    }
  }

  async getTokenBalance(tokenMint) {
    try {
      if (this.tokenAccounts[tokenMint]) {
        return this.tokenAccounts[tokenMint].amount;
      }

      const tokenAccounts = await this.connection.getParsedTokenAccountsByOwner(
        this.wallet.publicKey,
        { mint: new PublicKey(tokenMint) }
      );

      if (tokenAccounts.value.length > 0) {
        const amount = tokenAccounts.value[0].account.data.parsed.info.tokenAmount.uiAmount;
        this.tokenAccounts[tokenMint] = {
          address: tokenAccounts.value[0].pubkey.toString(),
          amount,
          decimals: tokenAccounts.value[0].account.data.parsed.info.tokenAmount.decimals
        };
        return amount;
      }
      return 0;
    } catch (error) {
      console.error('❌ Token balance error:', error.message);
      return 0;
    }
  }

  async getJupiterQuote(inputMint, outputMint, amount, slippageBps = 50) {
    try {
      const response = await fetch(`${this.jupiterUrl}/quote?inputMint=${inputMint}&outputMint=${outputMint}&amount=${amount}&slippageBps=${slippageBps}`);
      const data = await response.json();
      
      if (!data.data || data.data.length === 0) {
        throw new Error('No route found');
      }

      return {
        inputAmount: data.data[0].inAmount,
        outputAmount: data.data[0].outAmount,
        priceImpactPct: data.data[0].priceImpactPct,
        marketInfos: data.data[0].marketInfos,
        routePlan: data.data[0].routePlan
      };
    } catch (error) {
      console.error('❌ Jupiter quote error:', error.message);
      return null;
    }
  }

  async getJupiterSwapInstructions(quote, inputMint, outputMint) {
    try {
      const response = await fetch(`${this.jupiterUrl}/swap-instructions`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userPublicKey: this.wallet.publicKey.toString(),
          quoteResponse: quote,
          wrapAndUnwrapSol: true
        })
      });

      const data = await response.json();
      
      if (!data.swapTransaction) {
        throw new Error('No swap transaction generated');
      }

      return {
        swapTransaction: data.swapTransaction,
        setupTransaction: data.setupTransaction,
        cleanupTransaction: data.cleanupTransaction,
        addressLookupTableAddresses: data.addressLookupTableAddresses
      };
    } catch (error) {
      console.error('❌ Jupiter swap instructions error:', error.message);
      return null;
    }
  }

  async executeJupiterSwap(inputMint, outputMint, amount) {
    try {
      console.log(`🔄 Executing Jupiter swap: ${amount} of ${inputMint}`);

      // Step 1: Get quote
      const quote = await this.getJupiterQuote(inputMint, outputMint, amount);
      if (!quote) {
        throw new Error('Failed to get quote');
      }

      console.log(`  Quote: ${quote.outputAmount} output tokens`);
      console.log(`  Price Impact: ${quote.priceImpactPct}%`);

      // Step 2: Get swap instructions
      const instructions = await this.getJupiterSwapInstructions(quote, inputMint, outputMint);
      if (!instructions) {
        throw new Error('Failed to get swap instructions');
      }

      // Step 3: Sign and send transaction
      const { Transaction } = require('@solana/web3.js');
      const txBuffer = Buffer.from(instructions.swapTransaction, 'base64');
      const transaction = Transaction.from(txBuffer);

      // Sign transaction
      transaction.sign(this.wallet);

      // Send transaction
      const txId = await this.connection.sendRawTransaction(
        transaction.serialize(),
        { skipPreflight: false, preflightCommitment: 'confirmed' }
      );

      console.log(`✓ Swap executed: ${txId}`);
      
      return {
        success: true,
        txId,
        inputAmount: amount,
        outputAmount: quote.outputAmount,
        priceImpact: quote.priceImpactPct
      };
    } catch (error) {
      console.error('❌ Swap error:', error.message);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async getTokenPrice(tokenMint) {
    try {
      // SOL mint for price comparison
      const solMint = 'So11111111111111111111111111111111111111112';
      const quote = await this.getJupiterQuote(tokenMint, solMint, 1000000000); // 1 token
      
      if (quote) {
        return parseFloat(quote.outputAmount) / 1000000000;
      }
      return 0;
    } catch (error) {
      console.error('❌ Price fetch error:', error.message);
      return 0;
    }
  }

  getWalletAddress() {
    return this.wallet.publicKey.toString();
  }

  getKeyPair() {
    return this.wallet;
  }

  getConnection() {
    return this.connection;
  }

  async signTransaction(transaction) {
    try {
      transaction.sign(this.wallet);
      return transaction;
    } catch (error) {
      console.error('❌ Transaction sign error:', error.message);
      throw error;
    }
  }

  // Get wallet info for API responses
  getWalletInfo() {
    return {
      address: this.wallet.publicKey.toString(),
      rpcUrl: this.rpcUrl,
      jupiterUrl: this.jupiterUrl
    };
  }
}

module.exports = new WalletService();
