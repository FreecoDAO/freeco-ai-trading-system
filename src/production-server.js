/**
 * Production Server with API
 * Manages all trading operations and provides REST API
 */

const express = require('express');
const cors = require('cors');
const mqtt = require('mqtt');
const walletService = require('./wallet-service');
const dexIntegration = require('./dex-integration');
const marketDataService = require('./market-data-service');

class ProductionServer {
  constructor() {
    this.app = express();
    this.port = process.env.PORT || 3000;
    this.mqttClient = null;
    this.state = {
      isRunning: false,
      trades: [],
      signals: [],
      balance: 0,
      walletAddress: null
    };
  }

  async init() {
    console.log('🚀 Starting Production Server...');

    // Middleware
    this.app.use(cors());
    this.app.use(express.json());

    // Initialize services
    await walletService.init();
    await dexIntegration.init();
    await marketDataService.init();

    // Update state
    this.state.walletAddress = walletService.getWalletAddress();
    this.state.balance = await walletService.getBalance();

    // Setup routes
    this.setupRoutes();

    // Start MQTT
    this.connectMqtt();

    // Start server
    this.app.listen(this.port, () => {
      console.log(`✓ Production Server running on port ${this.port}`);
      console.log(`📊 API: http://localhost:${this.port}`);
    });
  }

  connectMqtt() {
    this.mqttClient = mqtt.connect('mqtt://localhost:1883');
    
    this.mqttClient.on('connect', () => {
      console.log('✓ Server connected to MQTT');
      this.mqttClient.subscribe('hbot/predictions/#');
      this.mqttClient.subscribe('market/data');
    });

    this.mqttClient.on('message', (topic, message) => {
      try {
        const payload = JSON.parse(message.toString());
        
        if (topic.includes('predictions')) {
          this.handleSignal(payload);
        } else if (topic === 'market/data') {
          this.state.marketData = payload;
        }
      } catch (error) {
        console.error('MQTT message error:', error.message);
      }
    });
  }

  handleSignal(signal) {
    console.log(`📊 Signal received: ${signal.signal} ${signal.pair} @ ${signal.price_target}`);
    
    this.state.signals.push({
      ...signal,
      receivedAt: new Date().toISOString()
    });

    // Keep last 100 signals
    if (this.state.signals.length > 100) {
      this.state.signals.shift();
    }
  }

  setupRoutes() {
    // Health check
    this.app.get('/health', (req, res) => {
      res.json({
        status: 'healthy',
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
      });
    });

    // Get status
    this.app.get('/api/status', (req, res) => {
      res.json({
        ...this.state,
        balance: walletService.getBalance()
      });
    });

    // Get wallet info
    this.app.get('/api/wallet', async (req, res) => {
      const balance = await walletService.getBalance();
      res.json({
        address: this.state.walletAddress,
        balance,
        rpcUrl: process.env.SOLANA_RPC_URL
      });
    });

    // Get market data
    this.app.get('/api/market', (req, res) => {
      res.json(marketDataService.getPriceCache());
    });

    // Get signals
    this.app.get('/api/signals', (req, res) => {
      res.json(this.state.signals.slice(-20)); // Last 20 signals
    });

    // Execute trade
    this.app.post('/api/trade/execute', async (req, res) => {
      const { inputMint, outputMint, amount } = req.body;
      
      try {
        const result = await dexIntegration.executeSwap(inputMint, outputMint, amount);
        
        if (result.success) {
          this.state.trades.push(result);
          res.json({ success: true, ...result });
        } else {
          res.status(400).json({ success: false, error: result.error });
        }
      } catch (error) {
        res.status(500).json({ success: false, error: error.message });
      }
    });

    // Get trades
    this.app.get('/api/trades', (req, res) => {
      res.json(this.state.trades);
    });

    // Get balance
    this.app.get('/api/balance', async (req, res) => {
      const balance = await walletService.getBalance();
      res.json({ balance, address: this.state.walletAddress });
    });

    // Get quote
    this.app.get('/api/quote', async (req, res) => {
      const { inputMint, outputMint, amount } = req.query;
      
      try {
        const quote = await dexIntegration.getQuote(inputMint, outputMint, amount);
        res.json(quote || { error: 'Failed to get quote' });
      } catch (error) {
        res.status(500).json({ error: error.message });
      }
    });
  }
}

// Start server
const server = new ProductionServer();
server.init().catch(error => {
  console.error('❌ Server startup error:', error);
  process.exit(1);
});

module.exports = server;
