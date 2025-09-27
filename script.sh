#!/bin/bash

LOG="/var/log/monitoring.log"
STATE_DIR="/var/log"
STATE_FILE="$STATE_DIR/temp_PID"
PROCESS_NAME="test"
URL="https://test.com/monitoring/test/api"
CURL_TIMEOUT=10

mkdir -p "$STATE_DIR"
touch "$LOG"

PID=$(pgrep -x "$PROCESS_NAME" | head -n1  true)

timestamp() {
  date -Iseconds
}

if [ -n "$PID" ]; then
  if ! curl -fsS --max-time "$CURL_TIMEOUT" "$URL" >/dev/null 2>&1; then
    echo "$(timestamp) Ошибка! Не удалось связаться с $URL" >> "$LOG"
  fi

  if [ -f "$STATE_FILE" ]; then
    PREV_PID=$(cat "$STATE_FILE" 2>/dev/null  echo "")
    if [ -n "$PREV_PID" ] && [ "$PREV_PID" != "$PID" ]; then
      echo "$(timestamp) Процесс перезапущен!" >> "$LOG"
    fi
  fi

  echo "$PID" > "$STATE_FILE"
else
  rm -f "$STATE_FILE"
fi