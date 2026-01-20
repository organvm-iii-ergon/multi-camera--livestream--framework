# Streaming Configuration

> RTMP streaming setup for YouTube Live, Twitch, and other platforms.

**Last Updated:** <!-- TODO: Update date -->
**Version:** 1.0.0

---

## Table of Contents

1. [Overview](#overview)
2. [Platform Setup](#platform-setup)
3. [OBS Output Configuration](#obs-output-configuration)
4. [Bitrate Recommendations](#bitrate-recommendations)
5. [Multi-Platform Streaming](#multi-platform-streaming)
6. [Quality Optimization](#quality-optimization)
7. [Troubleshooting](#troubleshooting)

---

## Overview

The Multi-Camera Livestream Framework outputs via RTMP to live streaming platforms. Primary platform is **YouTube Live**, with optional simulcast to **Twitch**.

### Stream Specifications

| Parameter | Value |
|-----------|-------|
| Resolution | 1920x1080 (1080p) |
| Frame Rate | 60 fps |
| Video Codec | H.264 (x264 or Apple VT) |
| Audio Codec | AAC |
| Audio Sample Rate | 48 kHz |
| Audio Bitrate | 320 kbps |

---

## Platform Setup

### YouTube Live

#### Creating Stream Key

1. Go to [YouTube Studio](https://studio.youtube.com/)
2. Click **Create** → **Go Live**
3. Choose **Stream** tab
4. Select **Streaming software**
5. Copy **Stream key** (keep secret!)

#### YouTube Recommended Settings

| Setting | Value |
|---------|-------|
| Ingest Server | Primary: rtmp://a.rtmp.youtube.com/live2 |
| Backup Server | rtmp://b.rtmp.youtube.com/live2?backup=1 |
| Video Bitrate | 4500-9000 kbps for 1080p60 |
| Keyframe Interval | 2 seconds |
| Audio Bitrate | 128-384 kbps |

#### YouTube Stream Health

Monitor at: YouTube Studio → Go Live → Stream Health

- **Excellent**: Green indicator
- **Good**: Yellow indicator (minor issues)
- **Poor**: Red indicator (investigate immediately)

### Twitch

#### Creating Stream Key

1. Go to [Twitch Dashboard](https://dashboard.twitch.tv/)
2. Settings → Stream
3. Copy **Primary Stream Key**

#### Twitch Recommended Settings

| Setting | Value |
|---------|-------|
| Ingest Server | Auto (or closest) |
| Video Bitrate | 6000 kbps max (non-partners) |
| Keyframe Interval | 2 seconds |
| Audio Bitrate | 160 kbps |

> ⚠️ Twitch Partners/Affiliates have higher bitrate limits.

### Other Platforms

<!-- TODO: Add any additional platforms you use -->

| Platform | RTMP URL | Notes |
|----------|----------|-------|
| Facebook Live | rtmps://live-api-s.facebook.com:443/rtmp/ | Use RTMPS |
| Custom RTMP | <!-- TODO --> | <!-- TODO --> |

---

## OBS Output Configuration

### Settings → Output (Simple Mode)

For quick setup:

```
Video Bitrate: 6000 kbps
Encoder: Apple VT H264 Hardware Encoder
Audio Bitrate: 320 kbps
```

### Settings → Output (Advanced Mode)

Recommended for production:

#### Streaming Tab

```
Type: Custom Output (FFmpeg)
 -- or --
Type: Standard

Encoder: Apple VT H264 Hardware Encoder
 -- or --
Encoder: x264 (software, higher quality)

Rate Control: CBR
Bitrate: 6000 kbps
Keyframe Interval: 2
Profile: high
Tune: (none)
```

#### Recording Tab (if recording locally)

```
Type: Standard
Recording Path: /Volumes/RecordingDrive/
Recording Format: mkv (convert to mp4 post-stream)
Encoder: Apple VT H264 Hardware Encoder
Rate Control: CRF
CRF: 18-20
```

### Settings → Video

```
Base Resolution: 1920x1080
Output Resolution: 1920x1080
FPS: 60
```

### Settings → Audio

```
Sample Rate: 48 kHz
Channels: Stereo
```

### Settings → Stream

```
Service: YouTube - RTMPS
 -- or --
Service: Custom...
Server: rtmp://a.rtmp.youtube.com/live2
Stream Key: [Your key - keep secret!]
```

---

## Bitrate Recommendations

### By Resolution and Frame Rate

| Resolution | Frame Rate | Bitrate Range | Recommended |
|------------|------------|---------------|-------------|
| 720p | 30 fps | 2500-4000 | 3000 kbps |
| 720p | 60 fps | 3500-5000 | 4500 kbps |
| 1080p | 30 fps | 4000-6000 | 4500 kbps |
| 1080p | 60 fps | 5000-9000 | 6000 kbps |
| 1440p | 30 fps | 8000-12000 | 9000 kbps |
| 1440p | 60 fps | 10000-15000 | 12000 kbps |
| 4K | 30 fps | 13000-20000 | 15000 kbps |
| 4K | 60 fps | 20000-35000 | 25000 kbps |

### Network Requirements

| Video Bitrate | Upload Speed Needed |
|---------------|---------------------|
| 6000 kbps | 8+ Mbps |
| 9000 kbps | 12+ Mbps |
| 15000 kbps | 20+ Mbps |

> Always have 30-50% headroom above your target bitrate.

### Testing Your Connection

```bash
# Test upload speed
speedtest-cli --simple

# Or use web-based test
open https://speedtest.net
```

---

## Multi-Platform Streaming

### Option 1: OBS Multiple Outputs (Built-in)

OBS can output to multiple RTMP endpoints simultaneously:

1. Install **Multiple RTMP Output plugin**
2. Configure additional outputs
3. Start both when going live

**Pros:** Simple, no extra cost
**Cons:** Uses more CPU/upload bandwidth

### Option 2: Restreaming Service

Use a service like Restream.io or Castr:

```
OBS → Restream.io → YouTube
                  → Twitch
                  → Facebook
```

**Pros:** Single output from OBS, lower bandwidth
**Cons:** Monthly cost, slight latency increase

### Option 3: Nginx RTMP Server (Self-hosted)

Set up local RTMP relay:

```bash
# Basic Nginx RTMP config
# /usr/local/etc/nginx/nginx.conf

rtmp {
    server {
        listen 1935;
        application live {
            live on;
            push rtmp://a.rtmp.youtube.com/live2/[key];
            push rtmp://live.twitch.tv/app/[key];
        }
    }
}
```

**Pros:** Full control, no service costs
**Cons:** Requires server setup and maintenance

---

## Quality Optimization

### Encoder Selection

| Encoder | CPU Load | Quality | Recommendation |
|---------|----------|---------|----------------|
| Apple VT H264 | Very Low | Good | Primary choice on M1 |
| x264 (medium) | High | Excellent | If CPU allows |
| x264 (fast) | Medium | Good | Balance option |

### Apple VT Hardware Encoder Settings

```
Profile: high
Allow B-Frames: Yes
```

### x264 Software Encoder Settings

```
Rate Control: CBR
Bitrate: 6000
Preset: veryfast (or faster if CPU-limited)
Profile: high
Tune: none
x264 Options: (leave empty for defaults)
```

### Color Space Settings

For best compatibility:

```
Settings → Advanced → Video
Color Format: NV12
Color Space: 709
Color Range: Partial
```

### Audio Processing

In OBS Audio settings:
- Normalize audio levels
- Use limiter to prevent clipping
- Consider noise gate for microphones

---

## Troubleshooting

### Stream Disconnects

**Symptoms:** Stream drops mid-broadcast

**Solutions:**
1. Switch to backup RTMP server
2. Lower bitrate (network congestion)
3. Check ISP stability
4. Use wired Ethernet (not WiFi)
5. Enable "Automatically reconnect" in OBS

### Dropped Frames

**Symptoms:** OBS shows dropped frames in stats

**Types:**
- **Encoding lag**: CPU/GPU can't keep up
- **Network**: Upload can't sustain bitrate
- **Rendering lag**: GPU overloaded

**Solutions:**
- Encoding: Lower preset (faster), use hardware encoder
- Network: Lower bitrate, check connection
- Rendering: Reduce scene complexity, close other apps

### Pixelation/Artifacts

**Symptoms:** Stream looks blocky, especially during motion

**Solutions:**
1. Increase video bitrate
2. Lower resolution (1080p → 720p)
3. Lower frame rate (60 → 30)
4. Use CRF instead of CBR for quality-priority encoding

### Audio Out of Sync

**Symptoms:** Audio doesn't match video

**Solutions:**
1. Check audio sync offset in Advanced Audio Properties
2. Verify consistent sample rate (48 kHz everywhere)
3. Check Dante clock sync
4. Restart audio devices

### Platform Rejects Stream

**Symptoms:** Platform shows "stream key invalid" or similar

**Solutions:**
1. Re-copy stream key (they expire sometimes)
2. Check RTMP URL is correct
3. Verify account is in good standing
4. Check stream restrictions (scheduled time, etc.)

### High Latency to Viewers

**Symptoms:** Viewers report 20+ second delay

**Solutions:**
1. Enable "Low Latency" mode on platform
2. YouTube: Ultra Low Latency mode
3. Reduce keyframe interval
4. Accept trade-off: lower latency = less buffer = more risk of stuttering

---

## Quick Reference

### OBS Stats Window

View → Stats (Dock to main window)

Key metrics:
- **Dropped Frames (Network)**: Target 0%
- **Dropped Frames (Encoder)**: Target 0%
- **Rendering Lag**: Target 0%
- **Output Bitrate**: Should match settings

### Test Stream Checklist

Before going live:

- [ ] Test stream for 5+ minutes
- [ ] Verify video quality on platform preview
- [ ] Verify audio levels and sync
- [ ] Check platform stream health indicator
- [ ] Test scene transitions
- [ ] Verify stream title/description
- [ ] Confirm scheduled start time (if applicable)

### Emergency Contacts

<!-- TODO: Add your platform support contacts -->

| Platform | Support |
|----------|---------|
| YouTube | [Creator Support](https://support.google.com/youtube/answer/3545535) |
| Twitch | [Twitch Support](https://help.twitch.tv/) |

---

## See Also

- [RUNBOOK.md](RUNBOOK.md) - Pre-stream checklist
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - General troubleshooting
- [OBS Documentation](https://obsproject.com/wiki/)

---

*Document maintained by Multi-Camera Livestream Framework team*
