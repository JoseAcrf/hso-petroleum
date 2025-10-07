#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import subprocess

class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        self.send_response(200)
        self.end_headers()
        subprocess.run(["git", "-C", "/opt/odoo/hso-logistics", "pull"])
        subprocess.run(["rsync", "-a", "--delete", "/opt/odoo/hso-logistics/extra-addons/", "/mnt/extra-addons/"])
        subprocess.run(["pkill", "-f", "odoo"])
        subprocess.run(["odoo"])
        self.wfile.write(b'✅ Git pull ejecutado y módulos sincronizados.')

server = HTTPServer(('0.0.0.0', 8000), WebhookHandler)
print("🔌 Webhook listener activo en puerto 8000...")
server.serve_forever()
