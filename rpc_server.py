#!/usr/bin/env python3
import json
from http.server import HTTPServer, BaseHTTPRequestHandler

class RPCHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        try:
            request = json.loads(post_data)
            method = request.get('method', '')
            
            # Handle different RPC methods
            result = None
            if method == 'getblockcount':
                result = 1000
            elif method == 'getbalance':
                result = 10000
            elif method == 'getpeerinfo':
                result = [{"addr": "peer1.qtc.network", "connected": True}]
            else:
                result = "Method not found"
            
            response = {
                "jsonrpc": "2.0",
                "result": result,
                "id": request.get('id', 1)
            }
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode())
            
        except Exception as e:
            self.send_error(500, str(e))
    
    def log_message(self, format, *args):
        print(f"RPC: {format % args}")

print("QTC RPC Server starting on port 8332...")
server = HTTPServer(('localhost', 8332), RPCHandler)
print("RPC Server ready at http://localhost:8332")
print("Press Ctrl+C to stop")

try:
    server.serve_forever()
except KeyboardInterrupt:
    print("\nRPC Server stopped")
