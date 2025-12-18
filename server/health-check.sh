#!/bin/bash
# Health check script for Lofi Stream Twitch
# Run via cron: */5 * * * * /opt/lofi-stream-twitch/health-check.sh

LOG="/var/log/lofi-twitch-health.log"
DISCORD_WEBHOOK="${DISCORD_WEBHOOK:-}"
SERVICE_NAME="lofi-stream-twitch"

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

send_discord_alert() {
    local message="$1"
    local color="${2:-16711680}"  # Default red

    if [ -n "$DISCORD_WEBHOOK" ]; then
        curl -s -H "Content-Type: application/json" \
            -d "{\"embeds\":[{\"title\":\"Lofi Stream Alert\",\"description\":\"$message\",\"color\":$color}]}" \
            "$DISCORD_WEBHOOK" > /dev/null 2>&1
    fi
}

echo "$(timestamp) --- Health Check ---" >> $LOG

# Check if ffmpeg is streaming
if pgrep -f "ffmpeg.*twitch" > /dev/null; then
    echo "$(timestamp) ✓ ffmpeg: running" >> $LOG
else
    echo "$(timestamp) ✗ ffmpeg: NOT RUNNING - restarting service" >> $LOG
    send_discord_alert "FFmpeg is not running! Restarting $SERVICE_NAME service..." 16711680
    systemctl restart $SERVICE_NAME

    # Wait and check if restart succeeded
    sleep 30
    if pgrep -f "ffmpeg.*twitch" > /dev/null; then
        echo "$(timestamp) ✓ Service restarted successfully" >> $LOG
        send_discord_alert "Service restarted successfully" 65280  # Green
    else
        echo "$(timestamp) ✗ Service restart FAILED" >> $LOG
        send_discord_alert "Service restart FAILED! Manual intervention needed." 16711680
    fi
fi

# Check if Chromium is running
if pgrep -f "chromium.*lofi-stream-twitch" > /dev/null; then
    echo "$(timestamp) ✓ chromium: running" >> $LOG
else
    echo "$(timestamp) ✗ chromium: NOT RUNNING" >> $LOG
fi

# Log resource usage
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
MEM=$(free | awk '/^Mem:/ {printf "%.1f", $3/$2 * 100}')
echo "$(timestamp)   CPU: ${CPU}% | RAM: ${MEM}%" >> $LOG

# Check if GitHub Pages is accessible
if curl -s --max-time 10 https://ldraney.github.io/lofi-stream-twitch/ | grep -q "lofi"; then
    echo "$(timestamp) ✓ GitHub Pages: accessible" >> $LOG
else
    echo "$(timestamp) ✗ GitHub Pages: NOT ACCESSIBLE" >> $LOG
    send_discord_alert "GitHub Pages is not accessible!" 16776960  # Yellow
fi

# Keep log file from growing too large (keep last 1000 lines)
tail -1000 $LOG > $LOG.tmp && mv $LOG.tmp $LOG 2>/dev/null || true

echo "" >> $LOG
