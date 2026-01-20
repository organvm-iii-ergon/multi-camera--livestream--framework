# NDI Remote Callers Guide

> Configuration guide for integrating remote participants via NDI into the Multi-Camera Livestream Framework.

**Last Updated:** <!-- TODO: Update date -->
**Version:** 1.0.0

---

## Table of Contents

1. [Overview](#overview)
2. [NDI Fundamentals](#ndi-fundamentals)
3. [Caller Setup](#caller-setup)
4. [OBS NDI Integration](#obs-ndi-integration)
5. [Latency Optimization](#latency-optimization)
6. [Multi-Caller Management](#multi-caller-management)
7. [Troubleshooting](#troubleshooting)

---

## Overview

NDI (Network Device Interface) allows remote participants to send high-quality video and audio over the network. This is ideal for:

- Remote guests on the show
- Off-site co-hosts
- Screen sharing from remote locations
- B-roll from remote cameras

### NDI vs. Other Solutions

| Method | Latency | Quality | Complexity |
|--------|---------|---------|------------|
| NDI | ~100-200ms | Excellent | Medium |
| Zoom/Discord | 200-500ms | Good | Low |
| SRT | 200-500ms | Excellent | High |
| WebRTC | 100-300ms | Variable | Medium |

---

## NDI Fundamentals

### How NDI Works

```
Remote Caller ──[NDI over LAN/WAN]──→ Mac Studio ──→ OBS
      │                                    │
    [NDI Source]                    [NDI Receiver]
```

### NDI Requirements

**For Remote Callers:**
- Wired Ethernet connection (strongly recommended)
- Webcam or camera
- NDI-compatible software
- Upload bandwidth: 10+ Mbps (for 1080p)

**For Your Studio:**
- Download bandwidth: 10+ Mbps per caller
- NDI Tools installed
- OBS with NDI plugin

### NDI Software Options

| Software | Platform | Cost | Best For |
|----------|----------|------|----------|
| NDI Webcam Input | Win/Mac | Free | Simple webcam |
| OBS + NDI Plugin | Win/Mac/Linux | Free | Full production |
| Skype + NDI | Windows | Free | Easy setup |
| vMix Call | Web-based | Free | Remote guests |
| NDI Screen Capture | Win/Mac | Free | Screen sharing |

---

## Caller Setup

### For Remote Callers Using OBS

1. **Install NDI Tools** from [ndi.tv](https://ndi.tv/tools/)
2. **Install OBS NDI Plugin** from [obs-ndi releases](https://github.com/obs-ndi/obs-ndi/releases)
3. **Configure OBS:**
   - Tools → NDI Output Settings
   - Enable "Main Output"
   - Set Output Name (e.g., "Guest-John")

### For Callers Using NDI Webcam Input

Simplest option for basic video calls:

1. Download **NDI Webcam Input** from NDI Tools
2. Launch application
3. Configure:
   - Select webcam
   - Set resolution (1080p recommended)
   - Name the source
4. Share your **IP address** with the studio

### Network Configuration for Remote NDI

<!-- TODO: Document your network setup for external callers -->

**Option 1: VPN (Recommended)**
```
Remote Caller ──[VPN]──→ Studio Network ──→ Mac Studio
```

**Option 2: NDI Bridge (For WAN)**
```
Remote Caller ──[NDI Bridge/HX]──→ Internet ──→ Mac Studio
```

**Option 3: Port Forwarding (Advanced)**
- Forward port 5960-5990 (TCP/UDP)
- Not recommended for security reasons

---

## OBS NDI Integration

### Installing OBS NDI Plugin

1. Download from [obs-ndi releases](https://github.com/obs-ndi/obs-ndi/releases)
2. Install the package
3. Restart OBS
4. Verify: Tools menu should show NDI options

### Adding NDI Sources

1. Sources → Add → **NDI Source**
2. Configure:
   - **Source Name**: Descriptive name (e.g., "NDI-Guest-John")
   - **Source**: Select from discovered NDI sources
   - **Bandwidth**: Highest (or adjust for network)
   - **Sync**: Network (recommended)
   - **Latency Mode**: Normal

### NDI Source Settings

```
Source Name: NDI-Guest-John
Source: [Discovered NDI Source]
Bandwidth: Highest
Sync: Network
Allow hardware acceleration: ✓
Latency mode: Normal
PTZ: (disable unless using PTZ camera)
```

### Audio Considerations

NDI sources include embedded audio. Options:

1. **Use NDI Audio**: Enable audio in NDI source properties
2. **Separate Audio**: Disable NDI audio, use dedicated audio path
3. **Mixed**: Use NDI audio as backup, prefer dedicated audio

---

## Latency Optimization

### Reducing NDI Latency

| Setting | Impact | Trade-off |
|---------|--------|-----------|
| Low bandwidth mode | Reduces latency | Lower quality |
| Disable HW acceleration | More consistent | Higher CPU |
| Sync: Network | Better sync | Slight delay |
| Dedicated VLAN | Reduces jitter | Network complexity |

### Network Optimization

**For LAN:**
- Use gigabit Ethernet (not WiFi)
- Dedicated NDI VLAN if possible
- Enable jumbo frames (9000 MTU)
- QoS for NDI traffic

**For WAN:**
- Use NDI|HX (compressed) instead of NDI (full bandwidth)
- VPN for security
- Stable upload connection for callers
- Buffer for jitter (increase latency slightly)

### Measuring Latency

In OBS:
1. View → Stats
2. Check "Average frame render time"
3. Monitor for dropped frames

Test latency:
1. Display timecode on caller end
2. Capture with OBS
3. Compare displayed vs captured time

---

## Multi-Caller Management

### Organizing Multiple Callers

Create a consistent naming scheme:

| NDI Source Name | OBS Source Name | Guest |
|-----------------|-----------------|-------|
| GUEST-01 | NDI-Guest-Alice | Alice |
| GUEST-02 | NDI-Guest-Bob | Bob |
| GUEST-03 | NDI-Guest-Carol | Carol |

### Scene Templates for Callers

```
Scene: Single Caller
└── NDI-Guest-Current (full screen)

Scene: Two Callers
├── NDI-Guest-1 (left 50%)
└── NDI-Guest-2 (right 50%)

Scene: Three Callers
├── NDI-Guest-1 (top left)
├── NDI-Guest-2 (top right)
└── NDI-Guest-3 (bottom center)

Scene: Host + Caller PIP
├── CAM-Host (full screen)
└── NDI-Guest-Current (corner PIP)
```

### Caller Onboarding Checklist

<!-- TODO: Customize for your workflow -->

Send to callers before the show:

- [ ] Install NDI Tools
- [ ] Configure webcam/camera
- [ ] Test audio levels
- [ ] Connect via VPN (if required)
- [ ] Send NDI source name to studio
- [ ] Test connection 30 min before show
- [ ] Wired Ethernet connected
- [ ] Background/lighting acceptable

### Pre-Show Caller Test

1. Have caller enable NDI output
2. Verify source appears in OBS NDI list
3. Add to test scene
4. Check video quality
5. Check audio levels
6. Test latency (clap test)
7. Confirm backup communication method (phone/Discord)

---

## Troubleshooting

### NDI Source Not Appearing

**Symptoms:** Remote NDI source not visible in OBS

**Solutions:**
1. Verify both devices on same network/subnet
2. Check firewall settings (allow NDI ports 5353, 5960-5990)
3. Restart NDI services on caller end
4. Refresh NDI sources in OBS (may take 30-60 seconds)
5. Verify NDI Tools are running on both ends

### Poor Video Quality

**Symptoms:** Pixelation, compression artifacts

**Solutions:**
1. Increase bandwidth setting in OBS NDI source
2. Check caller's upload speed
3. Switch to NDI|HX if network is constrained
4. Reduce caller's output resolution
5. Check for network congestion

### Audio Out of Sync

**Symptoms:** Lip sync issues with NDI caller

**Solutions:**
1. In OBS, right-click NDI source → Advanced Audio Properties
2. Adjust Sync Offset (typically +/- 100ms)
3. Try different Sync mode (Network vs Internal)
4. Use separate audio source with manual sync

### High Latency

**Symptoms:** Noticeable delay when talking to caller

**Solutions:**
1. Use NDI|HX instead of full NDI
2. Enable "Low bandwidth" in NDI source
3. Check for network hops between caller and studio
4. Consider alternative (WebRTC may have lower latency for some setups)

### Dropped Frames from NDI

**Symptoms:** OBS shows dropped frames from rendering

**Solutions:**
1. Reduce number of simultaneous NDI sources
2. Lower NDI source resolution
3. Check CPU usage (NDI decoding is CPU-intensive)
4. Enable hardware acceleration if available
5. Consider M1's limited NDI hardware acceleration

### Connection Drops

**Symptoms:** NDI source disconnects intermittently

**Solutions:**
1. Check caller's network stability
2. Increase network timeout settings
3. Use wired connection (not WiFi)
4. Check for VPN disconnections
5. Have backup communication channel ready

---

## Quick Reference

### NDI Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 5353 | UDP | mDNS discovery |
| 5960-5990 | TCP/UDP | Video transport |

### OBS NDI Source Cheat Sheet

```
Best Quality:    Bandwidth=Highest, Sync=Network, HW Accel=On
Lower Latency:   Bandwidth=Lowest, Sync=Internal, Latency=Low
Balanced:        Bandwidth=High, Sync=Network, Latency=Normal
```

### Caller Quick Setup Email Template

```
Subject: NDI Setup for [Show Name] - [Date]

Hi [Caller Name],

Please complete these steps before our show:

1. Install NDI Tools: https://ndi.tv/tools/
2. Open NDI Webcam Input (or your NDI app)
3. Set your source name to: GUEST-[YourName]
4. Connect to VPN: [VPN instructions if applicable]
5. Test at [time] - I'll confirm I can see your source

Technical requirements:
- Wired Ethernet connection
- Webcam at 1080p
- Upload speed: 10+ Mbps
- Quiet, well-lit environment

Backup contact: [phone/Discord]

Let me know if you have questions!
```

---

## See Also

- [AUDIO-DANTE.md](AUDIO-DANTE.md) - If using separate audio for callers
- [STREAMING.md](STREAMING.md) - Output configuration
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - General troubleshooting

---

*Document maintained by Multi-Camera Livestream Framework team*
