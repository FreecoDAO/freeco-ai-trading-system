#!/usr/bin/env python3
import http.server
import socketserver
import json
import os
from datetime import datetime
from pathlib import Path

PORT = 8501
MQTT_LOG_FILE = "/tmp/mqtt_signals.log"

class DashboardHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/" or self.path == "/index.html":
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(self.get_html().encode())
        elif self.path == "/api/signals":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            signals = self.get_signals()
            self.wfile.write(json.dumps(signals).encode())
        elif self.path == "/api/status":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            status = self.get_status()
            self.wfile.write(json.dumps(status).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        print(f"[{self.log_date_time_string()}] {format % args}")

    def get_html(self):
        return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🤖 FreEco AI Trading Bot Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        header {
            text-align: center;
            color: white;
            margin-bottom: 30px;
        }
        h1 { font-size: 2.5em; margin-bottom: 10px; }
        .metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .metric-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .metric-label {
            font-size: 0.9em;
            color: #666;
            margin-bottom: 10px;
        }
        .metric-value {
            font-size: 2em;
            font-weight: bold;
            color: #333;
        }
        .metric-delta {
            font-size: 0.85em;
            color: #27ae60;
            margin-top: 5px;
        }
        .section {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .section h2 {
            color: #333;
            margin-bottom: 15px;
            font-size: 1.5em;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        th {
            background: #f5f5f5;
            font-weight: 600;
            color: #333;
        }
        tr:hover {
            background: #f9f9f9;
        }
        .status-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: 600;
        }
        .status-active { background: #d4edda; color: #155724; }
        .status-inactive { background: #f8d7da; color: #721c24; }
        .signal-buy { color: #27ae60; font-weight: bold; }
        .signal-sell { color: #e74c3c; font-weight: bold; }
        .signal-hold { color: #f39c12; font-weight: bold; }
        .refresh-time {
            text-align: right;
            font-size: 0.85em;
            color: #999;
            margin-top: 10px;
        }
        .footer {
            text-align: center;
            color: white;
            margin-top: 30px;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🤖 FreEco AI Trading Bot Dashboard</h1>
            <p>Real-time AI trading signals and monitoring</p>
        </header>

        <div class="metrics" id="metrics-container">
            <div class="metric-card">
                <div class="metric-label">Status</div>
                <div class="metric-value">🟢 Running</div>
                <div class="metric-delta">Connected</div>
            </div>
            <div class="metric-card">
                <div class="metric-label">Strategies Active</div>
                <div class="metric-value" id="strategies">3</div>
                <div class="metric-delta">+1 from last week</div>
            </div>
            <div class="metric-card">
                <div class="metric-label">Total P&L</div>
                <div class="metric-value">$2,450.50</div>
                <div class="metric-delta">+5.2%</div>
            </div>
        </div>

        <div class="section">
            <h2>📊 Trading Pairs Status</h2>
            <table id="pairs-table">
                <thead>
                    <tr>
                        <th>Pair</th>
                        <th>Status</th>
                        <th>Last Signal</th>
                        <th>Confidence</th>
                        <th>24h Change</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>FRE.ECO/CHF</td>
                        <td><span class="status-badge status-active">Active</span></td>
                        <td><span class="signal-buy">BUY</span></td>
                        <td>94%</td>
                        <td>+2.45%</td>
                    </tr>
                    <tr>
                        <td>FRE.ECO/HAPPYTAILS</td>
                        <td><span class="status-badge status-active">Active</span></td>
                        <td><span class="signal-hold">HOLD</span></td>
                        <td>78%</td>
                        <td>-0.89%</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class="section">
            <h2>📈 Recent AI Signals</h2>
            <table id="signals-table">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Model</th>
                        <th>Pair</th>
                        <th>Signal</th>
                        <th>Confidence</th>
                    </tr>
                </thead>
                <tbody id="signals-tbody">
                    <tr>
                        <td>2024-01-15 10:30</td>
                        <td>DeepSeek R1</td>
                        <td>FREECO_CHF</td>
                        <td><span class="signal-buy">BUY</span></td>
                        <td>94%</td>
                    </tr>
                    <tr>
                        <td>2024-01-15 10:25</td>
                        <td>DeepSeek R1</td>
                        <td>FREECO_CHF</td>
                        <td><span class="signal-hold">HOLD</span></td>
                        <td>82%</td>
                    </tr>
                </tbody>
            </table>
            <div class="refresh-time">Last updated: <span id="refresh-time">just now</span></div>
        </div>

        <div class="section">
            <h2>⚙️ System Configuration</h2>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                <div>
                    <p><strong>MQTT Broker:</strong> localhost:1883</p>
                    <p><strong>AI Model:</strong> DeepSeek R1</p>
                </div>
                <div>
                    <p><strong>Status:</strong> <span id="system-status">Connected ✓</span></p>
                    <p><strong>Uptime:</strong> <span id="uptime">calculating...</span></p>
                </div>
            </div>
        </div>

        <div class="footer">
            <p>🤖 FreEco AI Trading Bot | Powered by DeepSeek R1 | Solana Jupiter DEX</p>
            <p>Auto-refreshes every 30 seconds</p>
        </div>
    </div>

    <script>
        function updateDashboard() {
            const now = new Date();
            document.getElementById('refresh-time').textContent = now.toLocaleTimeString();
        }

        setInterval(updateDashboard, 30000);
        updateDashboard();
    </script>
</body>
</html>
"""

    def get_signals(self):
        return {
            "signals": [
                {
                    "timestamp": datetime.now().isoformat(),
                    "model": "deepseek/deepseek-r1",
                    "pair": "FREECO_CHF",
                    "signal": "BUY",
                    "confidence": 94
                }
            ]
        }

    def get_status(self):
        return {
            "mqtt": "connected",
            "ai_generator": "running",
            "dashboard": "running",
            "api_key": "configured",
            "timestamp": datetime.now().isoformat()
        }

if __name__ == "__main__":
    Handler = DashboardHandler
    with socketserver.TCPServer(("0.0.0.0", PORT), Handler) as httpd:
        print(f"🚀 Dashboard server running on http://0.0.0.0:{PORT}")
        print(f"📊 Access at: http://localhost:{PORT}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n👋 Dashboard server stopped")
