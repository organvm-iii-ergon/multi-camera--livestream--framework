# Audio & Dante Network Configuration

> Comprehensive guide for setting up and troubleshooting the Dante audio network in the Dope's Show live streaming pipeline.

**Last Updated:** <!-- TODO: Update date -->
**Version:** 1.0.0

---

## Table of Contents

1. [Overview](#overview)
2. [Hardware Setup](#hardware-setup)
3. [Dante Controller Configuration](#dante-controller-configuration)
4. [MOTU 8PRE-ES Setup](#motu-8pre-es-setup)
5. [Clock Synchronization](#clock-synchronization)
6. [Audio Routing](#audio-routing)
7. [Integration with Ableton Live](#integration-with-ableton-live)
8. [Troubleshooting](#troubleshooting)

---

## Overview

The Dope's Show pipeline uses **Dante audio networking** for low-latency, high-quality audio transport from the MOTU 8PRE-ES interface to the Mac Studio running Ableton Live.

### Key Components

| Component | Role | Connection |
|-----------|------|------------|
| MOTU 8PRE-ES | Dante audio interface, clock master | Ethernet → Dante switch |
| Dante Controller | Audio routing software | Mac Studio |
| Ableton Live | Audio mixing, processing | Mac Studio |
| Dante Virtual Soundcard | (Optional) Software audio routing | Mac Studio |

### Signal Flow

```
Microphones/Sources → MOTU 8PRE-ES → Dante Network → Mac Studio → Ableton Live → OBS
                          ↑
                     [Clock Master]
```

---

## Hardware Setup

### MOTU 8PRE-ES Physical Connections

<!-- TODO: Add specific port assignments for your setup -->

1. **Power**: Connect to UPS/power conditioner
2. **Ethernet**: Connect to dedicated Dante switch (NOT main network)
3. **Audio Inputs**:
   - Inputs 1-8: XLR microphone preamps
   - <!-- TODO: Document your specific input assignments -->

### Network Requirements

- **Dedicated switch**: Dante requires a dedicated gigabit switch
- **No WiFi**: Never run Dante over WiFi
- **QoS**: If sharing switch, enable QoS for Dante traffic

### Recommended Network Configuration

```
[MOTU 8PRE-ES] ─── [Dante Switch] ─── [Mac Studio Ethernet]
                        │
                   [Dante Controller]
```

<!-- TODO: Add your specific IP addressing scheme if using static IPs -->

---

## Dante Controller Configuration

### Initial Setup

1. Launch **Dante Controller** from Applications
2. Wait for device discovery (typically 5-10 seconds)
3. Verify MOTU 8PRE-ES appears in device list

### Device Naming

<!-- TODO: Add your device naming convention -->

Recommended naming format:
- `MOTU-MAIN` - Primary MOTU interface
- `MAC-STUDIO` - Mac Studio Dante receiver

### Routing Matrix

The Dante Controller routing matrix shows transmitters (rows) and receivers (columns).

#### Basic Routing Example

| Source (TX) | Destination (RX) | Channel |
|-------------|------------------|---------|
| MOTU Ch 1 | Mac Studio Ch 1 | Host Mic |
| MOTU Ch 2 | Mac Studio Ch 2 | Guest Mic |
| <!-- TODO: Add your routing --> | | |

---

## MOTU 8PRE-ES Setup

### Accessing MOTU Web Interface

1. Open browser to MOTU's IP address (check Dante Controller)
2. Or use **MOTU Discovery** application
3. Login with default credentials (check MOTU manual)

### Preamp Configuration

| Input | Gain (dB) | Phantom (+48V) | Purpose |
|-------|-----------|----------------|---------|
| 1 | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |
| 2 | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |
| 3 | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |
| 4 | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |
| 5 | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |
| 6 | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |
| 7 | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |
| 8 | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |

### Sample Rate

- **Recommended**: 48 kHz (broadcast standard)
- **Alternative**: 44.1 kHz (if mixing with music production)

> ⚠️ All Dante devices on the network must use the same sample rate.

---

## Clock Synchronization

### Clock Master Setup

The MOTU 8PRE-ES should be the **Dante clock master** for the network.

**In Dante Controller:**
1. Go to **Device Config** tab
2. Select MOTU 8PRE-ES
3. Set **Preferred Master**: ✓ Enable
4. Set **Clock Source**: Internal

### Verifying Clock Sync

In Dante Controller:
- Blue clock icon = Clock master
- Green indicator = Synced to master
- Red indicator = Clock error (troubleshoot immediately)

### Clock Priority Order

1. MOTU 8PRE-ES (Primary master)
2. Mac Studio DVS (Fallback if MOTU fails)

---

## Audio Routing

### Dante to Ableton Live

#### Option 1: Dante Virtual Soundcard (Recommended)

1. Install Dante Virtual Soundcard
2. Launch DVS and select channel count (e.g., 8x8)
3. In Ableton Live Preferences:
   - Audio Device: Dante Virtual Soundcard
   - Input Config: Enable channels matching your routing

#### Option 2: Direct MOTU Routing

<!-- TODO: Document if using MOTU's direct USB connection as backup -->

### Channel Mapping

| Dante Channel | Ableton Track | Source |
|---------------|---------------|--------|
| 1 | Audio 1 | <!-- TODO --> |
| 2 | Audio 2 | <!-- TODO --> |
| 3 | Audio 3 | <!-- TODO --> |
| 4 | Audio 4 | <!-- TODO --> |

---

## Integration with Ableton Live

### Audio Preferences

```
Preferences → Audio
├── Driver Type: CoreAudio
├── Audio Device: Dante Virtual Soundcard (or MOTU)
├── Sample Rate: 48000 Hz
├── Buffer Size: 256 samples (recommended)
└── Input/Output Config: Enable required channels
```

### Latency Settings

| Buffer Size | Latency | Use Case |
|-------------|---------|----------|
| 128 samples | ~2.7ms | Low-latency monitoring |
| 256 samples | ~5.3ms | Balanced (recommended) |
| 512 samples | ~10.7ms | High plugin load |

### Template Project Setup

<!-- TODO: Document your Ableton template structure -->

Recommended tracks:
- Host Mic (Dante 1)
- Guest Mic (Dante 2)
- Music/SFX (Dante 3-4)
- Master Bus → Virtual Audio Cable → OBS

---

## Troubleshooting

### No Devices Visible in Dante Controller

**Symptoms:** Dante Controller shows no devices

**Solutions:**
1. Check Ethernet cable connections
2. Verify devices are on same network/subnet
3. Check firewall settings (allow Dante Controller)
4. Restart Dante Controller
5. Power cycle MOTU 8PRE-ES

### Audio Dropouts

**Symptoms:** Crackling, pops, gaps in audio

**Solutions:**
1. Check clock sync status (Dante Controller)
2. Increase buffer size in Ableton
3. Check network switch for errors
4. Reduce Dante latency setting if too aggressive
5. Check CPU load on Mac Studio

### Clock Sync Errors

**Symptoms:** Red clock indicator in Dante Controller

**Solutions:**
1. Verify only one device is set as Preferred Master
2. Check all devices are same sample rate
3. Restart affected devices
4. Check for network loops (spanning tree)

### MOTU Not Detected

**Symptoms:** MOTU doesn't appear in Dante Controller

**Solutions:**
1. Power cycle MOTU (wait 30 seconds)
2. Check Ethernet connection
3. Update MOTU firmware
4. Check Dante Controller version compatibility

### High Latency

**Symptoms:** Noticeable delay in monitoring

**Solutions:**
1. Reduce Dante latency (0.25ms if network allows)
2. Reduce Ableton buffer size
3. Disable unnecessary plugins
4. Use direct monitoring on MOTU for performers

---

## Quick Reference

### Default Ports

- Dante Primary: UDP 4440-4455
- Dante Secondary: UDP 4440-4455
- mDNS: UDP 5353

### Essential Dante Controller Shortcuts

| Action | Shortcut |
|--------|----------|
| Refresh devices | F5 |
| Toggle routing | Click intersection |
| Device info | Double-click device |

---

## See Also

- [RUNBOOK.md](RUNBOOK.md) - Pre-stream checklist
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - General troubleshooting
- [VIDEO-CAPTURE.md](VIDEO-CAPTURE.md) - Video setup guide

---

*Document maintained by Dope's Show Pipeline team*
