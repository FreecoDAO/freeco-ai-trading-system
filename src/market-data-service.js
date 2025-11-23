/**
 * Real-time Market Data Service
 * Fetches live price data from Jupiter DEX and other sources
 */

const axios = require('axios');
const mqtt = require('mqtt');

class MarketDataService {
  constructor() {
    this.mqttClient = null;
    this.pairs = [
      { symbol: 'FREECO/CHF', coingeckoId: 'freeco-dao', baseToken: 'So11111111111111111111111111111111111111112' },
      { symbol: 'SOL/USDC', coingeckoId: 'solana', baseToken: 'So11111111111111111111111111111111111111112' }
    ];
    this.priceCache = {};
    this.updateInterval = 30000; // Update every 30 seconds
  }

  async init() {
    console.log('🔌 Initializing Market Data Service...');
    
    // Connect to MQTT
    this.mqttClient = require('mqtt').connect('mqtt://localhost:1883');
    this.mqttClient.on('connect', () => {
      console.log('✓ Market Data Service connected to MQTT');
    });

    // Start fetching market data
    await this.fetchMarketData();
    setInterval(() => this.fetchMarketData(), this.updateInterval);
  }

  async fetchMarketData() {
    try {
      // Fetch from CoinGecko for real-time prices
      const prices = await this.fetchCoinGeckoData();
      
      // Fetch from Jupiter DEX for swap rates
      const jupiterData = await this.fetchJupiterData();
      
      // Combine data
      const marketData = {
        timestamp: new Date().toISOString(),
        prices,
        jupiterData,
        pairs: this.pairs
      };

      // Cache and publish
      this.priceCache = marketData;
      this.publishMarketData(marketData);
      
      return marketData;
    } catch (error) {
      console.error('❌ Market data fetch error:', error.message);
      return null;
    }
  }

  async fetchCoinGeckoData() {
    try {
      const ids = this.pairs.map(p => p.coingeckoId).join(',');
      const response = await axios.get('https://api.coingecko.com/api/v3/simple/price', {
        params: {
          ids,
          vs_currencies: 'usd',
          include_market_cap: true,
          include_24hr_vol: true,
          include_24hr_change: true
        },
        timeout: 5000
      });

      const prices = {};
      this.pairs.forEach(pair => {
        if (response.data[pair.coingeckoId]) {
          prices[pair.symbol] = {
            usd: response.data[pair.coingeckoId].usd,
            market_cap: response.data[pair.coingeckoId].usd_market_cap,
            volume_24h: response.data[pair.coingeckoId].usd_24h_vol,
            change_24h: response.data[pair.coingeckoId].usd_24h_change
          };
        }
      });

      return prices;
    } catch (error) {
      console.error('❌ CoinGecko fetch error:', error.message);
      return {};
    }
  }

  async fetchJupiterData() {
    try {
      // Fetch Jupiter quote for FREECO/USDC swap
      const response = await axios.get('https://quote-api.jup.ag/v6/quote', {
        params: {
          inputMint: 'So11111111111111111111111111111111111111112', // SOL
          outputMint: 'EPjFWaLb3odcccccccccccccccccccccccccccccccccccccccc', // USDC
          amount: 1000000000, // 1 SOL
          slippageBps: 50 // 0.5% slippage
        },
        timeout: 5000
      });

      if (response.data) {
        return {
          solUsdcRate: response.data.outAmount / 1000000, // Normalized
          timestamp: new Date().toISOString()
        };
      }
      return {};
    } catch (error) {
      console.error('❌ Jupiter fetch error:', error.message);
      return {};
    }
  }

  publishMarketData(data) {
    if (this.mqttClient && this.mqttClient.connected) {
      this.mqttClient.publish('market/data', JSON.stringify(data), { qos: 1 });
    }
  }

  getPriceCache() {
    return this.priceCache;
  }
}

module.exports = new MarketDataService();
