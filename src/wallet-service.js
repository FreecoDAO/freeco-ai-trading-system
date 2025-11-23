/**
 * Wallet Management Service with Jupiter Wallet SDK
 * Complete Solana wallet integration with Jupiter DEX
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
    console.log('💰 Initializing Wallet Service with Jupiter SDK...');
    
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
      
      // Load token balances
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
        console.log('✓ Token accounts loaded');
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
        return amount;
      }
      return 0;
    } catch (error) {
      console.error('❌ Token balance error:', error.message);
      return 0;
    }
  }

  /**
   * Get quote from Jupiter API
   * @param {string} inputMint - Input token mint
   * @param {string} outputMint - Output token mint
   * @param {number} amount - Amount in smallest unit
   * @param {number} slippageBps - Slippage in basis points (50 = 0.5%)
   */
  async getJupiterQuote(inputMint, outputMint, amount, slippageBps = 50) {
    try {
      const response = await fetch(
        `${this.jupiterUrl}/quote?inputMint=${inputMint}&outputMint=${outputMint}&amount=${amount}&slippageBps=${slippageBps}`
      );
      const data = await response.json();
      
      if (!data.data || data.data.length === 0) {
        throw new Error('No route found');
      }

      const route = data.data[0];
      return {
        inputAmount: route.inAmount,
        outputAmount: route.outAmount,
        priceImpactPct: route.priceImpactPct,
        marketInfos: route.marketInfos,
        routePlan: route.routePlan
      };
    } catch (error) {
      console.error('❌ Jupiter quote error:', error.message);
      return null;
    }
  }

  /**
   * Execute swap on Jupiter DEX
   * @param {string} inputMint - Input token mint
   * @param {string} outputMint - Output token mint
   * @param {number} amount - Amount to swap
   */
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

      // Step 2: Get swap instructions from Jupiter
      const swapResponse = await fetch(`${this.jupiterUrl}/swap`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userPublicKey: this.wallet.publicKey.toString(),
          quoteResponse: quote,
          wrapAndUnwrapSol: true
        })
      });

      const swapData = await swapResponse.json();
      
      if (!swapData.swapTransaction) {
        throw new Error('No swap transaction generated');
      }

      // Step 3: Sign and send transaction
      const { Transaction } = require('@solana/web3.js');
      const txBuffer = Buffer.from(swapData.swapTransaction, 'base64');
      const transaction = Transaction.from(txBuffer);

      // Sign with wallet
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

  /**
   * Get available routes from Jupiter
   */
  async getAvailableRoutes(inputMint, outputMint) {
    try {
      const response = await fetch(
        `${this.jupiterUrl}/quote?inputMint=${inputMint}&outputMint=${outputMint}&amount=1000000000`
      );
      const data = await response.json();
      
      if (data.data && data.data.length > 0) {
        return {
          routes: data.data.length,
          bestRoute: data.data[0],
          allRoutes: data.data
        };
      }
      return null;
    } catch (error) {
      console.error('❌ Routes fetch error:', error.message);
      return null;
    }
  }

  /**
   * Validate swap before execution
   */
  async validateSwap(inputMint, outputMint, amount) {
    try {
      const quote = await this.getJupiterQuote(inputMint, outputMint, amount);
      
      if (!quote) {
        return {
          valid: false,
          error: 'No route found'
        };
      }

      return {
        valid: true,
        inputAmount: amount,
        outputAmount: quote.outputAmount,
        priceImpact: quote.priceImpactPct,
        minimumReceived: quote.outputAmount * (1 - quote.priceImpactPct / 100)
      };
    } catch (error) {
      console.error('❌ Swap validation error:', error.message);
      return {
        valid: false,
        error: error.message
      };
    }
  }

  /**
   * Get token price in SOL
   */
  async getTokenPrice(tokenMint) {
    try {
      const solMint = 'So11111111111111111111111111111111111111112';
      const quote = await this.getJupiterQuote(tokenMint, solMint, 1000000000); // 1 token
      
      if
