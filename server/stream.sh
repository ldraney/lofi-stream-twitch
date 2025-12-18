#!/bin/bash
# Lofi Stream to Twitch
# Captures a headless browser playing our lofi page and streams to Twitch

set -e

# Configuration
DISPLAY_NUM=99
RESOLUTION="1280x720"
FPS=24
TWITCH_URL="rtmp://live.twitch.tv/app"
PAGE_URL="https://ldraney.github.io/lofi-stream-twitch/"

# Stream key from environment
if [ -z "$TWITCH_KEY" ]; then
    echo "Error: TWITCH_KEY environment variable not set"
    exit 1
fi

echo "Starting Lofi Stream to Twitch..."
echo "Resolution: $RESOLUTION @ ${FPS}fps"

# Cleanup any existing processes
cleanup() {
    echo "Cleaning up..."
    pkill -f "Xvfb :$DISPLAY_NUM" 2>/dev/null || true
    pkill -f "chromium.*lofi-stream-twitch" 2>/dev/null || true
    pkill -f "ffmpeg.*twitch" 2>/dev/null || true
    pulseaudio --kill 2>/dev/null || true
}

trap cleanup EXIT
cleanup
sleep 2

# Start virtual display
echo "Starting virtual display :$DISPLAY_NUM..."
Xvfb :$DISPLAY_NUM -screen 0 ${RESOLUTION}x24 &
XVFB_PID=$!
sleep 2
export DISPLAY=:$DISPLAY_NUM

# Start PulseAudio
echo "Starting PulseAudio..."
export XDG_RUNTIME_DIR=/run/user/$(id -u)
mkdir -p $XDG_RUNTIME_DIR
pulseaudio --start --exit-idle-time=-1

# Create virtual audio sink
pactl load-module module-null-sink sink_name=virtual_speaker sink_properties=device.description=VirtualSpeaker
pactl set-default-sink virtual_speaker

# Export PULSE_SERVER for ffmpeg (critical for audio capture!)
export PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native

# Start Chromium
echo "Starting Chromium..."
chromium-browser \
    --no-sandbox \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-dev-shm-usage \
    --kiosk \
    --autoplay-policy=no-user-gesture-required \
    --window-size=1280,720 \
    --window-position=0,0 \
    "$PAGE_URL" &
CHROME_PID=$!

# Wait for page to load
echo "Waiting for page to load..."
sleep 8

# Trigger audio with xdotool (belt and suspenders)
echo "Triggering audio..."
xdotool mousemove 640 360 click 1
sleep 1
xdotool key space
sleep 1
xdotool mousemove 640 360 click 1
sleep 2

# Move Chromium audio to virtual speaker
pactl list short sink-inputs | awk '{print $1}' | xargs -I {} pactl move-sink-input {} virtual_speaker 2>/dev/null || true

# Start FFmpeg streaming to Twitch
echo "Starting FFmpeg stream to Twitch..."
PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native ffmpeg \
    -thread_queue_size 1024 \
    -f x11grab \
    -video_size $RESOLUTION \
    -framerate $FPS \
    -draw_mouse 0 \
    -i :$DISPLAY_NUM \
    -thread_queue_size 1024 \
    -f pulse \
    -i virtual_speaker.monitor \
    -c:v libx264 \
    -preset ultrafast \
    -tune zerolatency \
    -b:v 2500k \
    -maxrate 2500k \
    -bufsize 5000k \
    -pix_fmt yuv420p \
    -g 48 \
    -c:a aac \
    -b:a 160k \
    -ar 44100 \
    -flvflags no_duration_filesize \
    -f flv "${TWITCH_URL}/${TWITCH_KEY}"
