#!/usr/bin/env python3
"""
QTC DeFi API Server
Provides REST API for DeFi operations
"""

import json
from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime
import random

# DeFi State
defi_state = {
    "pools": {
        "QTC/USDT": {
            "reserve_qtc": 1000000,
            "reserve_usdt": 500000,
            "total_shares": 707106,
            "apr": 15.2
        },
        "WBTC/USDT": {
            "reserve_wbtc": 100,
            "reserve_usdt": 4000000,
            "total_shares": 20000,
            "apr": 12.8
        },
        "WETH/USDT": {
            "reserve_weth": 2000,
            "reserve_usdt": 3600000,
            "total_shares": 84852,
            "apr": 18.5
        }
    },
    "lending": {
        "QTC": {"supply_apy": 3.5, "borrow_apr": 6.8, "total_supply": 5000000, "total_borrowed": 2000000},
        "USDT": {"supply_apy": 2.8, "borrow_apr": 5.2, "total_supply": 10000000, "total_borrowed": 6000000},
        "WBTC": {"supply_apy": 1.2, "borrow_apr": 3.5, "total_supply": 50, "total_borrowed": 20}
    },
    "staking": {
        "total_staked": 25000000,
        "apy_30d": 5.0,
        "apy_90d": 10.0,
        "apy_180d": 15.0,
        "apy_365d": 20.0
    },
    "farming": {
        "QTC-USDT": {"apr": 85.2, "tvl": 2500000},
        "WBTC-USDT": {"apr": 62.8, "tvl": 1800000},
        "WETH-USDT": {"apr": 45.5, "tvl": 1200000}
    },
    "stats": {
        "tvl": 125500000,
        "volume_24h": 8200000,
        "users": 12847,
        "transactions": 284719
    }
}

class DeFiAPIHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/defi/stats':
            self.send_json(defi_state["stats"])
        elif self.path == '/defi/pools':
            self.send_json(defi_state["pools"])
        elif self.path == '/defi/lending':
            self.send_json(defi_state["lending"])
        elif self.path == '/defi/staking':
            self.send_json(defi_state["staking"])
        elif self.path == '/defi/farming':
            self.send_json(defi_state["farming"])
        else:
            self.send_error(404)
    
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        try:
            request = json.loads(post_data)
            
            if self.path == '/defi/swap':
                result = self.handle_swap(request)
            elif self.path == '/defi/addliquidity':
                result = self.handle_add_liquidity(request)
            elif self.path == '/defi/supply':
                result = self.handle_supply(request)
            elif self.path == '/defi/borrow':
                result = self.handle_borrow(request)
            elif self.path == '/defi/stake':
                result = self.handle_stake(request)
            else:
                result = {"error": "Unknown endpoint"}
            
            self.send_json(result)
            
        except Exception as e:
            self.send_error(500, str(e))
    
    def handle_swap(self, request):
        from_token = request.get('from_token')
        to_token = request.get('to_token')
        amount = request.get('amount', 0)
        
        # Calculate output (simplified)
        rate = 0.5 if from_token == 'QTC' else 2.0
        output = amount * rate * 0.997  # 0.3% fee
        
        return {
            "success": True,
            "from": f"{amount} {from_token}",
            "to": f"{output:.2f} {to_token}",
            "rate": rate,
            "fee": amount * 0.003,
            "timestamp": datetime.now().isoformat()
        }
    
    def handle_add_liquidity(self, request):
        token_a = request.get('token_a')
        token_b = request.get('token_b')
        amount_a = request.get('amount_a', 0)
        amount_b = request.get('amount_b', 0)
        
        lp_tokens = (amount_a * amount_b) ** 0.5
        
        return {
            "success": True,
            "lp_tokens": lp_tokens,
            "share": random.uniform(0.1, 30.0),
            "timestamp": datetime.now().isoformat()
        }
    
    def handle_supply(self, request):
        token = request.get('token')
        amount = request.get('amount', 0)
        
        apy = defi_state["lending"][token]["supply_apy"]
        
        return {
            "success": True,
            "supplied": f"{amount} {token}",
            "apy": apy,
            "timestamp": datetime.now().isoformat()
        }
    
    def handle_borrow(self, request):
        token = request.get('token')
        amount = request.get('amount', 0)
        
        apr = defi_state["lending"][token]["borrow_apr"]
        
        return {
            "success": True,
            "borrowed": f"{amount} {token}",
            "apr": apr,
            "health_factor": random.uniform(1.5, 3.0),
            "timestamp": datetime.now().isoformat()
        }
    
    def handle_stake(self, request):
        amount = request.get('amount', 0)
        lock_days = request.get('lock_days', 30)
        
        apy_map = {30: 5.0, 90: 10.0, 180: 15.0, 365: 20.0}
        apy = apy_map.get(lock_days, 5.0)
        
        return {
            "success": True,
            "staked": f"{amount} QTC",
            "lock_days": lock_days,
            "apy": apy,
            "unlock_date": datetime.now().isoformat(),
            "timestamp": datetime.now().isoformat()
        }
    
    def send_json(self, data):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())
    
    def log_message(self, format, *args):
        print(f"DeFi API: {format % args}")

if __name__ == "__main__":
    print("QTC DeFi API Server starting on port 8334...")
    server = HTTPServer(('localhost', 8334), DeFiAPIHandler)
    print("DeFi API ready at http://localhost:8334")
    print("Endpoints:")
    print("  GET  /defi/stats - Get overall statistics")
    print("  GET  /defi/pools - Get liquidity pools info")
    print("  GET  /defi/lending - Get lending markets")
    print("  POST /defi/swap - Perform token swap")
    print("  POST /defi/addliquidity - Add liquidity")
    print("  POST /defi/supply - Supply to lending")
    print("  POST /defi/borrow - Borrow from lending")
    print("  POST /defi/stake - Stake QTC tokens")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nDeFi API Server stopped")
