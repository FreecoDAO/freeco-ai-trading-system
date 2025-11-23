require('dotenv').config();
const mqtt = require('mqtt');
const axios = require('axios');

const MQTT_BROKER = process.env.MQTT_BROKER || 'localhost';
const MQTT_PORT = process.env.MQTT_PORT || 1883;
const TOPIC_PREFIX = process.env.MQTT_TOPIC_PREFIX || 'hbot/predictions';
const DEEPSEEK_API_URL = process.env.DEEPSEEK_API_URL;
const DEEPSEEK_MODEL = process.env.DEEPSEEK_MODEL;
const API_KEY = process.env.NOVITA_API_KEY;

const client = mqtt.connect(`mqtt://${MQTT_BROKER}:${MQTT_PORT}`);

client.on('connect', () => {
  console.log('✓ Connected to MQTT Broker');
  generateSignal();
  setInterval(generateSignal, 60000); // Generate signal every minute
});

async function generateSignal() {
  try {
    console.log('🤖 Generating AI signal...');
    
    const response = await axios.post(
      `${DEEPSEEK_API_URL}/chat/completions`,
      {
        model: DEEPSEEK_MODEL,
        messages: [{
          role: 'user',
          content: 'Analyze FRE.ECO/CHF market. Provide: 1) Trend (buy/sell/hold) 2) Confidence (0-100) 3) Price target. Be concise.'
        }],
        max_tokens: 300
      },
      { headers: { 'Authorization': `Bearer ${API_KEY}` } }
    );

    const signal = response.data.choices[0].message.content;
    console.log('📊 Signal:', signal);

    const payload = {
      timestamp: new Date().toISOString(),
      model: DEEPSEEK_MODEL,
      signal: signal,
      pair: 'FREECO_CHF'
    };

    client.publish(`${TOPIC_PREFIX}/freeco_chf`, JSON.stringify(payload), {qos: 1});
    console.log('✓ Signal published to MQTT');
  } catch (error) {
    console.error('❌ Error generating signal:', error.message);
  }
}

process.on('SIGINT', () => {
  console.log('\n👋 Shutting down...');
  client.end();
  process.exit(0);
});
