#!/usr/bin/env python3
"""
Satellite Telemetry Service
Synthetic Linux Daemon for Integration Testing Demonstration.
"""

import sys
import os
import json
import time
import signal
import argparse
from http.server import HTTPServer, BaseHTTPRequestHandler

DEFAULT_CONFIG_PATH = "/etc/satellite-telemetry/config.json"
DEFAULT_LOG_PATH = "/var/log/satellite-telemetry/service.log"
DEFAULT_PID_PATH = "/var/run/satellite-telemetry.pid"

VERSION = "1.0.0"


def log(msg, log_file=DEFAULT_LOG_PATH):
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    formatted_msg = f"[{timestamp}] [satellite-telemetry] {msg}\n"
    print(formatted_msg, end="")
    try:
        os.makedirs(os.path.dirname(log_file), exist_ok=True)
        with open(log_file, "a") as f:
            f.write(formatted_msg)
    except Exception as e:
        print(f"Warning: Failed to write to log file {log_file}: {e}")


def load_config(config_path):
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Configuration file not found: {config_path}")
    with open(config_path, "r") as f:
        return json.load(f)


class HealthRequestHandler(BaseHTTPRequestHandler):
    version_string = f"SatelliteTelemetry/{VERSION}"
    protocol_version = "HTTP/1.1"

    def do_GET(self):
        if self.path == "/health":
            # Load config dynamically if available to report current settings
            config_path = getattr(self.server, "config_path", DEFAULT_CONFIG_PATH)
            service_version = VERSION
            try:
                cfg = load_config(config_path)
                service_version = cfg.get("version", VERSION)
            except Exception:
                pass

            response_data = {
                "status": "ok",
                "service": "satellite-telemetry",
                "version": service_version
            }
            body_bytes = json.dumps(response_data, indent=4).encode("utf-8")

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body_bytes)))
            self.send_header("Connection", "close")
            self.end_headers()
            self.wfile.write(body_bytes)
            log(f"HTTP GET /health - 200 OK")
        else:
            body_bytes = b'{"error": "Not Found"}'
            self.send_response(404)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body_bytes)))
            self.send_header("Connection", "close")
            self.end_headers()
            self.wfile.write(body_bytes)
            log(f"HTTP GET {self.path} - 404 Not Found")

    def log_message(self, format, *args):
        # Override default BaseHTTPRequestHandler logging to route to our log function
        log(f"HTTP Request: {format % args}")


class ReuseAddrHTTPServer(HTTPServer):
    allow_reuse_address = True

def run_server(config_path, pid_file, log_file):
    try:
        config = load_config(config_path)
        log(f"Starting Satellite Telemetry Service v{VERSION}", log_file)
        log(f"Loaded configuration from {config_path}", log_file)
    except Exception as e:
        log(f"CRITICAL: Failed to load configuration from {config_path}: {e}", log_file)
        sys.exit(1)

    port = config.get("port", 8080)
    host = config.get("host", "0.0.0.0")

    # Write PID file
    pid = os.getpid()
    try:
        os.makedirs(os.path.dirname(pid_file), exist_ok=True)
        with open(pid_file, "w") as f:
            f.write(str(pid))
        log(f"Service running with PID {pid}, PID file written to {pid_file}", log_file)
    except Exception as e:
        log(f"WARNING: Could not write PID file {pid_file}: {e}", log_file)

    server = ReuseAddrHTTPServer((host, port), HealthRequestHandler)
    server.config_path = config_path

    def signal_handler(signum, frame):
        log(f"Received signal {signum}. Shutting down service...", log_file)
        server.server_close()
        if os.path.exists(pid_file):
            try:
                os.remove(pid_file)
            except Exception:
                pass
        log("Service stopped cleanly.", log_file)
        sys.exit(0)

    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)

    log(f"HTTP server listening on http://{host}:{port}", log_file)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        if os.path.exists(pid_file):
            try:
                os.remove(pid_file)
            except Exception:
                pass


def main():
    parser = argparse.ArgumentParser(description="Satellite Telemetry Service Daemon")
    parser.add_argument("action", choices=["start", "stop", "status", "run"], help="Service action")
    parser.add_argument("--config", default=DEFAULT_CONFIG_PATH, help="Path to JSON configuration file")
    parser.add_argument("--pid-file", default=DEFAULT_PID_PATH, help="Path to PID file")
    parser.add_argument("--log-file", default=DEFAULT_LOG_PATH, help="Path to log file")

    args = parser.parse_args()

    if args.action == "run":
        run_server(args.config, args.pid_file, args.log_file)

    elif args.action == "start":
        if os.path.exists(args.pid_file):
            with open(args.pid_file, "r") as f:
                pid = f.read().strip()
            log(f"Service already running with PID {pid}")
            sys.exit(0)
        
        # Start in foreground for container compatibility or spawn background
        run_server(args.config, args.pid_file, args.log_file)

    elif args.action == "stop":
        if os.path.exists(args.pid_file):
            with open(args.pid_file, "r") as f:
                pid = int(f.read().strip())
            try:
                os.kill(pid, signal.SIGTERM)
                log(f"Sent SIGTERM to process {pid}")
            except ProcessLookupError:
                log(f"Process {pid} not found.")
            if os.path.exists(args.pid_file):
                os.remove(args.pid_file)
        else:
            log("Service is not running (PID file not found).")

    elif args.action == "status":
        if os.path.exists(args.pid_file):
            with open(args.pid_file, "r") as f:
                pid = f.read().strip()
            print(f"satellite-telemetry service is running with PID {pid}.")
            sys.exit(0)
        else:
            print("satellite-telemetry service is stopped.")
            sys.exit(3)


if __name__ == "__main__":
    main()
