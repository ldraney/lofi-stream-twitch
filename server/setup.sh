#!/bin/bash
# Setup script for Lofi Stream to Twitch
# Run this on a fresh Ubuntu 22.04/24.04 VPS

set -e

echo "=== Lofi Stream Twitch Setup ==="

# Update system
echo "Updating system..."
apt-get update
apt-get upgrade -y

# Install dependencies
echo "Installing dependencies..."
apt-get install -y \
    xvfb \
    chromium-browser \
    ffmpeg \
    pulseaudio \
    xdotool \
    curl \
    jq

# Create application directory
echo "Setting up application..."
mkdir -p /opt/lofi-stream-twitch

# Copy scripts
cp stream.sh /opt/lofi-stream-twitch/
cp health-check.sh /opt/lofi-stream-twitch/
chmod +x /opt/lofi-stream-twitch/*.sh

# Install systemd service
cp lofi-stream-twitch.service /etc/systemd/system/
systemctl daemon-reload

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Edit /etc/systemd/system/lofi-stream-twitch.service"
echo "   Set your TWITCH_KEY in the Environment= line"
echo ""
echo "2. Enable and start the service:"
echo "   systemctl enable lofi-stream-twitch"
echo "   systemctl start lofi-stream-twitch"
echo ""
echo "3. Check status:"
echo "   systemctl status lofi-stream-twitch"
echo "   journalctl -u lofi-stream-twitch -f"
echo ""
echo "4. (Optional) Set up health check cron:"
echo "   crontab -e"
echo "   Add: */5 * * * * /opt/lofi-stream-twitch/health-check.sh"
