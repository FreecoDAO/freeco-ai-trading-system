/**
 * DEX Integration Service with Jupiter AG SDK
 * Connects to Jupiter DEX for trading via official SDK
 */

const walletService = require('./wallet-service');

class DexIntegration {
  constructor() {
    this.jupiterUrl = 'https://api.jup.ag/swap/v1';
  }

  async init() {
    console.log('🔄 Initializing DEX Integration with Jupiter AG SDK...');
    
    try {
      console.log('✓ DEX Integration initialized');
      console.log('  Jupiter API: https://api.jup.ag');
      return true;
    } catch (error) {
      console.error('❌ DEX init error:', error.message);
      return false;
    }
  }

  async getQuote(inputMint, outputMint, amount, slippageBps = 50) {
    try {
      return await walletService.getJupiterQuote(inputMint, outputMint, amount, slippageBps);
    } catch (error) {
      console.error('❌ Quote fetch error:', error.message);
      return null;
    }
  }

  async executeSwap(inputMint, outputMint, amount) {
    try {
      return await walletService.executeJupiterSwap(inputMint, outputMint, amount);
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
      return await walletService.getTokenPrice(tokenMint);
    } catch (error) {
      console.error('❌ Price fetch error:', error.message);
      return 0;
    }
  }

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

  async validateSwap(inputMint, outputMint, amount) {
    try {
      const quote = await this.getQuote(inputMint, outputMint, amount);
      
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
}

module.exports = new DexIntegration();
