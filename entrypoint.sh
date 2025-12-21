#!/bin/sh
set -eu


# Args from compose to pass to server 
HL_ARGS=""

if [ -n "${FRAME_URL:-}" ]; then
  HL_ARGS="$HL_ARGS -url $FRAME_URL"
fi

if [ -n "${VERBOSE_LOGGING:-}" ]; then
  HL_ARGS="$HL_ARGS -v $VERBOSE_LOGGING"
fi


# Start server
hl /app/P2PServer.hl $HL_ARGS &
APP_PID="$!"

# If the app dies, stop the container
monitor_app() {
  wait "$APP_PID"
  echo "App exited; shutting down."
  exit 1
}
monitor_app &

exec nginx -g "daemon off;"
