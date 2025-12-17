#!/bin/sh
set -eu

hl /app/P2PServer.hl &
APP_PID="$!"

# If the app dies, stop the container
monitor_app() {
  wait "$APP_PID"
  echo "App exited; shutting down."
  exit 1
}
monitor_app &

exec nginx -g "daemon off;"
