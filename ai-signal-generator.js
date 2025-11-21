#!/usr/bin/env node

/**
 * FreEco AI Signal Generator
 * 
 * Analyzes market data using DeepSeek (via Novita) and Minimax M2
 * Publishes trading signals to MQTT for Hummingbot consumption
 */

const mqtt = require('mqtt');
const axios = require('axios');
require('dotenv').config();

// Configuration
const CONFIG = {
  mqtt: {
    broker: `mqtt://${process.env.MQTT_BROKER || 'localhost'}:${process.env.MQTT_PORT || 1883}`,
    topic: `${process.env.MQTT_TOPIC_PREFIX || 'hbot/predictions'}/freeco_chf/ML_SIGNALS`
  },
  ai: {
    // Primary: DeepSeek via Novita
    deepseek: {
      apiKey: process.env.NOVITA_API_KEY,
      baseURL: process.env.DEEPSEEK_API_URL || 'https://api.novita.ai/openai/v1',
      model: process.env.DEEPSEEK_MODEL || 'deepseek/deepseek-r1'
    },
    // Secondary: Minimax M2
    minimax: {
      apiKey: process.env.MINIMAX_API_KEY,
      baseURL: process.env.MINIMAX_API_URL || 'https://api.minimax.io/v1',
      model: process.env.MINIMAX_MODEL || 'MiniMax-M2'
    }
  },
  trading: {
    pair: 'FREECO/CHF',
    interval: 60000, // 1 minute
    minProfitThreshold: parseFloat(process.env.MIN_PROFIT_THRESHOLD || '0.5')
  }
};

// Validate API keys
if (!CONFIG.ai.deepseek.apiKey && !CONFIG.ai.minimax.apiKey) {
  console.error('❌ ERROR: No AI API keys found!');
  console.error('Set NOVITA_API_KEY or MINIMAX_API_KEY environment variable');
  process.exit(1);
}

// MQTT Client
let mqttClient;

/**
 * Call AI model (OpenAI-compatible format)
 */
async function callAI(provider, messages) {
  const config = provider === 'deepseek' ? CONFIG.ai.deepseek : CONFIG.ai.minimax;
  
  if (!config.apiKey) {
    throw new Error(`${provider} API key not configured`);
  }

  try {
    const response = await axios.post(
      `${config.baseURL}/chat/completions`,
      {
        model: config.model,
        messages: messages,
        temperature: 0.7,
        max_tokens: 1000
      },
      {
        headers: {
          'Authorization': `Bearer ${config.apiKey}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000
      }
    );

    return response.data.choices[0].message.content;
  } catch (error) {
    console.error(`❌ ${provider} API error:`, error.response?.data || error.message);
    throw error;
  }
}

/**
 * Fetch market data from Jupiter
 */
async function fetchMarketData() {
  // Mock data for now (replace with real Jupiter API call)
  const price = 1.0 + (Math.random() - 0.5) * 0.1;
  const volume24h = 10000 + Math.random() * 5000;
  const change24h = (Math.random() - 0.5) * 10;
  
  return {
    pair: CONFIG.trading.pair,
    price: price.toFixed(6),
    volume24h: volume24h.toFixed(2),
    change24h: change24h.toFixed(2),
    timestamp: Date.now()
  };
}

/**
 * Analyze market with AI
 */
async function analyzeMarket(marketData) {
  const prompt = `You are a professional crypto trading analyst. Analyze the following market data for ${marketData.pair}:

Price: $${marketData.price}
24h Volume: $${marketData.volume24h}
24h Change: ${marketData.change24h}%

Based on this data, provide your trading recommendation in the following JSON format:
{
  "action": "BUY" | "SELL" | "HOLD",
  "confidence": 0.0-1.0,
  "reasoning": "brief explanation",
  "probabilities": {
    "short": 0.0-1.0,
    "neutral": 0.0-1.0,
    "long": 0.0-1.0
  }
}

The probabilities must sum to 1.0. Respond ONLY with valid JSON, no additional text.`;

  const messages = [
    { role: 'system', content: 'You are a professional crypto trading analyst. Always respond with valid JSON only.' },
    { role: 'user', content: prompt }
  ];

  try {
    // Try DeepSeek first (faster and cheaper)
    console.log('🤖 Analyzing with DeepSeek...');
    const response = await callAI('deepseek', messages);
    
    // Parse JSON response
    const jsonMatch = response.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      throw new Error('No JSON found in response');
    }
    
    return JSON.parse(jsonMatch[0]);
  } catch (error) {
    console.warn('⚠️  DeepSeek failed, trying Minimax M2...');
    
    try {
      const response = await callAI('minimax', messages);
      const jsonMatch = response.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('No JSON found in response');
      }
      return JSON.parse(jsonMatch[0]);
    } catch (minimaxError) {
      console.error('❌ Both AI providers failed');
      // Return neutral signal as fallback
      return {
        action: 'HOLD',
        confidence: 0.5,
        reasoning: 'AI analysis failed, defaulting to HOLD',
        probabilities: { short: 0.33, neutral: 0.34, long: 0.33 }
      };
    }
  }
}

/**
 * Publish signal to MQTT
 */
function publishSignal(marketData, analysis) {
  const signal = {
    timestamp: Date.now(),
    probabilities: [
      analysis.probabilities.short,
      analysis.probabilities.neutral,
      analysis.probabilities.long
    ],
    target_pct: CONFIG.trading.minProfitThreshold / 100,
    features: {
      price: parseFloat(marketData.price),
      volume: parseFloat(marketData.volume24h),
      change: parseFloat(marketData.change24h),
      action: analysis.action,
      confidence: analysis.confidence,
      reasoning: analysis.reasoning
    }
  };

  mqttClient.publish(CONFIG.mqtt.topic, JSON.stringify(signal), { qos: 1 }, (err) => {
    if (err) {
      console.error('❌ MQTT publish error:', err);
    } else {
      console.log(`✅ Published signal: ${analysis.action} (confidence: ${(analysis.confidence * 100).toFixed(1)}%)`);
      console.log(`   Probabilities: SHORT=${(analysis.probabilities.short * 100).toFixed(1)}% NEUTRAL=${(analysis.probabilities.neutral * 100).toFixed(1)}% LONG=${(analysis.probabilities.long * 100).toFixed(1)}%`);
    }
  });
}

/**
 * Main analysis loop
 */
async function runAnalysis() {
  try {
    console.log(`\n📈 Analyzing ${CONFIG.trading.pair}...`);
    
    // Fetch market data
    const marketData = await fetchMarketData();
    console.log(`📊 Price: $${marketData.price}, Change: ${marketData.change24h}%`);
    
    // Analyze with AI
    const analysis = await analyzeMarket(marketData);
    
    // Publish signal
    publishSignal(marketData, analysis);
    
  } catch (error) {
    console.error('❌ Analysis error:', error.message);
  }
}

/**
 * Initialize and start
 */
async function main() {
  console.log('🚀 FreEco AI Signal Generator Starting...');
  console.log(`📡 MQTT Broker: ${CONFIG.mqtt.broker}`);
  console.log(`📊 Trading Pair: ${CONFIG.trading.pair}`);
  console.log(`🤖 AI Providers: DeepSeek${CONFIG.ai.minimax.apiKey ? ' + Minimax M2' : ''}`);
  
  // Connect to MQTT
  mqttClient = mqtt.connect(CONFIG.mqtt.broker);
  
  mqttClient.on('connect', () => {
    console.log('✅ Connected to MQTT broker');
    console.log(`📤 Publishing to: ${CONFIG.mqtt.topic}\n`);
    
    // Run first analysis immediately
    runAnalysis();
    
    // Then run periodically
    setInterval(runAnalysis, CONFIG.trading.interval);
  });
  
  mqttClient.on('error', (error) => {
    console.error('❌ MQTT error:', error);
  });
}

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('\n👋 Shutting down...');
  if (mqttClient) {
    mqttClient.end();
  }
  process.exit(0);
});

// Start
main().catch(console.error);
