#!/bin/bash
# Quick status check for Lofi Stream Twitch
# Run from local machine

# Configuration - update these for your server
KEY="${TWITCH_SSH_KEY:-~/api-secrets/hetzner-twitch/id_ed25519}"
HOST="${TWITCH_SERVER:-root@YOUR_SERVER_IP}"

echo "🎵 Lofi Stream Twitch Status"
echo "============================"
echo ""

# Check if we can connect to server
if [ "$HOST" = "root@YOUR_SERVER_IP" ]; then
    echo "⚠️  Server not configured. Set TWITCH_SERVER env var or edit this script."
    echo ""
else
    echo "📡 Server ($HOST):"
    ssh -i "$KEY" -o ConnectTimeout=5 "$HOST" '
        if pgrep -f "ffmpeg.*twitch" > /dev/null; then
            echo "  ✓ ffmpeg: streaming"
        else
            echo "  ✗ ffmpeg: NOT running"
        fi

        if pgrep -f "chromium.*lofi-stream-twitch" > /dev/null; then
            echo "  ✓ chromium: running"
        else
            echo "  ✗ chromium: NOT running"
        fi

        CPU=$(top -bn1 | grep "Cpu(s)" | awk "{print \$2}")
        MEM=$(free | awk "/^Mem:/ {printf \"%.0f\", \$3/\$2 * 100}")
        echo "  📊 CPU: ${CPU}% | RAM: ${MEM}%"
    ' 2>/dev/null || echo "  ✗ Cannot connect to server"
    echo ""
fi

# Check GitHub Pages
echo "🌐 GitHub Pages:"
if curl -s --max-time 5 https://ldraney.github.io/lofi-stream-twitch/ | grep -q "lofi"; then
    echo "  ✓ https://ldraney.github.io/lofi-stream-twitch/ is UP"
else
    echo "  ✗ GitHub Pages not accessible (may not be deployed yet)"
fi
echo ""

echo "📺 Twitch: Check your channel manually"
echo "   https://www.twitch.tv/YOUR_CHANNEL"
