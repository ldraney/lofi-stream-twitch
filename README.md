# Lofi Stream Twitch

24/7 lofi stream to Twitch featuring a cozy coffee shop theme.

## Quick Start

### 1. Deploy the Page

The lofi page is in `docs/` and should be deployed to GitHub Pages:

1. Go to repo Settings → Pages
2. Source: Deploy from branch
3. Branch: `main`, folder: `/docs`
4. Save and wait for deployment

Preview: https://ldraney.github.io/lofi-stream-twitch/

### 2. Set Up Server

```bash
# SSH to your Hetzner VPS
ssh root@YOUR_SERVER_IP

# Clone this repo
git clone https://github.com/ldraney/lofi-stream-twitch.git
cd lofi-stream-twitch/server

# Run setup (installs deps, copies files)
chmod +x setup.sh
./setup.sh

# Edit service file to add your Twitch stream key
nano /etc/systemd/system/lofi-stream-twitch.service
# Change: Environment=TWITCH_KEY=your_actual_key_here

# Start streaming
systemctl enable lofi-stream-twitch
systemctl start lofi-stream-twitch
```

### 3. Monitor

```bash
# Check status
systemctl status lofi-stream-twitch

# Watch logs
journalctl -u lofi-stream-twitch -f

# Quick status from local machine
./status.sh
```

## Theme: Cozy Coffee Shop

- Warm amber/brown colors
- Bookshelf with books
- Rainy window with street lamp
- Desk with laptop, coffee, candle
- Sleeping cat
- Hanging plant

Audio: Jazz-style lofi with 7th chords, walking bass, cafe ambience

## Architecture

```
GitHub Pages → Hetzner VPS (Xvfb + Chromium + ffmpeg) → Twitch RTMP
```

## Related

- [lofi-stream-youtube](https://github.com/ldraney/lofi-stream-youtube) - YouTube version (night city theme)
