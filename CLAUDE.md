# lofi-stream-twitch

Stream a cozy coffee shop lofi HTML page from GitHub Pages to Twitch Live via a Hetzner VPS.

## Project Goal

A 24/7 Twitch live stream displaying a coffee shop themed lofi page with ambient visuals and jazzy lofi music.

## Architecture

```
GitHub Pages (static HTML)
        │
        ▼
Hetzner VPS (CX22 ~€4.50/mo)
  ├── Xvfb (virtual display)
  ├── Chromium (renders page)
  └── ffmpeg (captures + RTMP stream)
        │
        ▼
Twitch Live (RTMP ingest)
```

## Definition of Done

The project is complete when:
- [ ] Twitch live stream is running 24/7
- [ ] Stream displays the coffee shop lofi page with visuals
- [ ] Audio is playing (generative jazz lofi via Web Audio API)
- [ ] Stream auto-recovers from crashes (systemd Restart=always)
- [ ] Discord alerts on failures
- [ ] Minimal maintenance required

---

## Key Files

```
lofi-stream-twitch/
├── CLAUDE.md              # This file
├── docs/                  # GitHub Pages lofi site
│   ├── index.html         # Coffee shop visuals + Web Audio API
│   └── style.css          # Warm amber styling
├── server/                # VPS scripts
│   ├── stream.sh          # Main streaming script
│   ├── setup.sh           # Server setup script
│   ├── health-check.sh    # Monitoring with Discord alerts
│   └── lofi-stream-twitch.service  # systemd unit
├── status.sh              # Local status check script
└── README.md
```

## Tech Stack

- **Frontend:** HTML, CSS, vanilla JS
- **Audio:** Web Audio API generated jazz lofi (no copyright issues)
- **Server:** Ubuntu 22.04/24.04 on Hetzner
- **Streaming:** Xvfb + Chromium + ffmpeg + PulseAudio
- **Hosting:** GitHub Pages (free)
- **Monitoring:** Discord webhooks for alerts

## Twitch Setup Notes

1. Go to Twitch Dashboard → Settings → Stream
2. Get Primary Stream Key (keep secret!)
3. RTMP URL: `rtmp://live.twitch.tv/app`
4. Recommended: 720p, 2500kbps, 30fps max

## Useful Commands

```bash
# SSH to server
ssh -i ~/api-secrets/hetzner-twitch/id_ed25519 root@YOUR_SERVER_IP

# Check stream status
systemctl status lofi-stream-twitch

# View logs
journalctl -u lofi-stream-twitch -f

# Restart stream
systemctl restart lofi-stream-twitch

# Check RTMP connection
ss -tn | grep 1935

# Monitor resources
top -bn1 | head -15 && free -h
```

## Current Status

**Phase:** Development
**GitHub Pages:** https://ldraney.github.io/lofi-stream-twitch/ (pending deployment)
**Server:** Not yet provisioned
**Twitch:** Not yet streaming

---

## Theme: Cozy Coffee Shop

Visual elements:
- Warm amber/brown color palette
- Bookshelf with colorful books
- Window with rain outside + street lamp glow
- Desk with laptop (animated code lines)
- Coffee mug with steam
- Candle with flickering flame
- Sleeping cat with animated tail
- Hanging plant with swaying vines

Audio elements (Web Audio API):
- Pink noise for rain/cafe ambience
- Jazz-style 7th chord progressions (Cmaj7 → Am7 → Dm7 → G7)
- Warm walking bass line
- Subtle cafe chatter
- Vinyl crackle

## Differences from YouTube Version

| Aspect | YouTube (lofi-stream-youtube) | Twitch (this repo) |
|--------|-------------------------------|-------------------|
| Theme | Night city / rainy window | Cozy coffee shop |
| Colors | Cool blues/purples | Warm amber/browns |
| Audio | Basic lofi pads | Jazz-style 7th chords |
| RTMP | rtmp://a.rtmp.youtube.com/live2 | rtmp://live.twitch.tv/app |
| Bitrate | 1.5 Mbps | 2.5 Mbps |

---

## Monitoring & Alerts

The health-check.sh script supports Discord webhook alerts:

```bash
# Set in /etc/environment or service file:
export DISCORD_WEBHOOK="https://discord.com/api/webhooks/xxx/yyy"
```

Alert types:
- 🔴 FFmpeg not running (auto-restart triggered)
- 🟢 Service restarted successfully
- 🔴 Service restart failed
- 🟡 GitHub Pages not accessible

---

## Lessons Learned

### PulseAudio + ffmpeg Audio Issue

**Problem:** ffmpeg not receiving audio from Chromium.

**Root Cause:** ffmpeg needs `PULSE_SERVER` environment variable set.

**Fix:**
```bash
export PULSE_SERVER=unix:/run/user/0/pulse/native

PULSE_SERVER=unix:/run/user/0/pulse/native ffmpeg \
    -f pulse -i virtual_speaker.monitor \
    ...
```

**Debugging:**
```bash
# Verify ffmpeg is actually connected to PulseAudio
pactl list source-outputs  # Should show ffmpeg as client
```
