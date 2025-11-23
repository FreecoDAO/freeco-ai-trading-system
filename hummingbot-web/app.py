#!/usr/bin/env python3
"""
Hummingbot Web UI - Browser-based trading interface
Integrates with FreEco AI Signal Generator
"""

from flask import Flask, render_template, jsonify, request
import json
import os
import subprocess
from datetime import datetime
from pathlib import Path
import paho.mqtt.client as mqtt

app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False

# Configuration
MQTT_BROKER = os.getenv("MQTT_BROKER", "localhost")
MQTT_PORT = int(os.getenv("MQTT_PORT", 1883))
CONFIG_DIR = Path.home() / ".hummingbot"
CONFIG_DIR.mkdir(exist_ok=True)

# Global state
bot_state = {
    "status": "stopped",
    "strategy": None,
    "trades": [],
    "balance": {},
    "signals": [],
    "orders": []
}

mqtt_client = None

def on_mqtt_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✓ Connected to MQTT Broker")
        client.subscribe("hbot/predictions/#")
    else:
        print(f"⚠ MQTT connection: {rc}")

def on_mqtt_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode())
        signal = {
            "timestamp": datetime.now().isoformat(),
            "topic": msg.topic,
            "signal": payload.get("signal", "UNKNOWN"),
            "confidence": payload.get("confidence", 0),
            "pair": payload.get("pair", "N/A"),
            "price_target": payload.get("price_target", 0)
        }
        bot_state["signals"].insert(0, signal)
        # Keep only last 50 signals
        bot_state["signals"] = bot_state["signals"][:50]
        print(f"Signal: {signal['signal']} {signal['pair']} @ {signal['price_target']}")
    except Exception as e:
        print(f"Error processing MQTT message: {e}")

def init_mqtt():
    global mqtt_client
    try:
        mqtt_client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION1)
        mqtt_client.on_connect = on_mqtt_connect
        mqtt_client.on_message = on_mqtt_message
        mqtt_client.connect(MQTT_BROKER, MQTT_PORT, keepalive=60)
        mqtt_client.loop_start()
    except Exception as e:
        print(f"MQTT connection error: {e}")

@app.route('/', methods=['GET', 'OPTIONS'])
def index():
    return render_template('index.html')

@app.route('/api/status', methods=['GET', 'OPTIONS'])
def get_status():
    return jsonify(bot_state)

@app.route('/api/signals', methods=['GET', 'OPTIONS'])
def get_signals():
    return jsonify(bot_state["signals"])

@app.route('/api/create-strategy', methods=['POST', 'OPTIONS'])
def create_strategy():
    if request.method == 'OPTIONS':
        return '', 204
    
    data = request.json
    strategy = {
        "name": data.get("name"),
        "exchange": data.get("exchange"),
        "pair": data.get("pair"),
        "bid_spread": data.get("bid_spread", 0.1),
        "ask_spread": data.get("ask_spread", 0.1),
        "order_amount": data.get("order_amount", 100),
        "created_at": datetime.now().isoformat()
    }
    
    # Save strategy config
    config_file = CONFIG_DIR / f"{data.get('name')}.json"
    with open(config_file, 'w') as f:
        json.dump(strategy, f, indent=2)
    
    bot_state["strategy"] = strategy
    return jsonify({"status": "success", "strategy": strategy})

@app.route('/api/start-trading', methods=['POST', 'OPTIONS'])
def start_trading():
    if request.method == 'OPTIONS':
        return '', 204
    
    if not bot_state["strategy"]:
        return jsonify({"status": "error", "message": "No strategy configured"}), 400
    
    bot_state["status"] = "running"
    return jsonify({"status": "success", "message": "Trading started"})

@app.route('/api/stop-trading', methods=['POST', 'OPTIONS'])
def stop_trading():
    if request.method == 'OPTIONS':
        return '', 204
    
    bot_state["status"] = "stopped"
    return jsonify({"status": "success", "message": "Trading stopped"})

@app.route('/api/add-exchange', methods=['POST', 'OPTIONS'])
def add_exchange():
    if request.method == 'OPTIONS':
        return '', 204
    
    data = request.json
    exchange = {
        "name": data.get("exchange"),
        "api_key": data.get("api_key"),
        "api_secret": data.get("api_secret"),
        "added_at": datetime.now().isoformat()
    }
    
    # Save exchange config (encrypted in real implementation)
    config_file = CONFIG_DIR / f"{data.get('exchange')}_keys.json"
    with open(config_file, 'w') as f:
        json.dump(exchange, f, indent=2)
    
    return jsonify({"status": "success", "exchange": exchange})

@app.route('/api/execute-trade', methods=['POST', 'OPTIONS'])
def execute_trade():
    if request.method == 'OPTIONS':
        return '', 204
    
    data = request.json
    trade = {
        "id": len(bot_state["trades"]) + 1,
        "side": data.get("side"),  # BUY or SELL
        "pair": data.get("pair"),
        "amount": data.get("amount"),
        "price": data.get("price"),
        "status": "pending",
        "executed_at": datetime.now().isoformat()
    }
    
    bot_state["trades"].insert(0, trade)
    return jsonify({"status": "success", "trade": trade})

@app.route('/api/config', methods=['GET', 'POST', 'OPTIONS'])
def config():
    if request.method == 'OPTIONS':
        return '', 204
    
    if request.method == 'POST':
        data = request.json
        config_file = CONFIG_DIR / "config.json"
        with open(config_file, 'w') as f:
            json.dump(data, f, indent=2)
        return jsonify({"status": "success"})
    
    config_file = CONFIG_DIR / "config.json"
    if config_file.exists():
        with open(config_file, 'r') as f:
            return jsonify(json.load(f))
    return jsonify({})

# Error handlers
@app.errorhandler(401)
def unauthorized(e):
    return jsonify({"error": "Unauthorized"}), 401

@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": "Not found"}), 404

@app.errorhandler(500)
def server_error(e):
    return jsonify({"error": "Server error"}), 500

if __name__ == '__main__':
    print("🚀 Starting Hummingbot Web UI")
    print("=" * 40)
    
    # Initialize MQTT connection
    init_mqtt()
    
    print("✓ MQTT Initialized")
    print("✓ Flask server starting...")
    print("")
    print("📊 Hummingbot Web UI: http://localhost:8502")
    print("")
    
    # Run Flask app
    app.run(host='0.0.0.0', port=8502, debug=False, threaded=True)
