# Video Capture Configuration

> Setup guide for the Blackmagic DeckLink Quad HDMI capture system in the Multi-Camera Livestream Framework.

**Last Updated:** <!-- TODO: Update date -->
**Version:** 1.0.0

---

## Table of Contents

1. [Overview](#overview)
2. [Hardware Setup](#hardware-setup)
3. [DeckLink Configuration](#decklink-configuration)
4. [Camera Settings](#camera-settings)
5. [OBS Integration](#obs-integration)
6. [Resolution & Frame Rate](#resolution--frame-rate)
7. [Troubleshooting](#troubleshooting)

---

## Overview

The video capture pipeline uses a **Blackmagic DeckLink Quad HDMI** card in a **Sonnet Echo Express SE I** Thunderbolt 3 chassis, connected to the M1 Mac Studio.

### Supported Inputs

| Input | Resolution | Frame Rate | Color Space |
|-------|------------|------------|-------------|
| HDMI 1 | Up to 4K | Up to 60fps | Various |
| HDMI 2 | Up to 4K | Up to 60fps | Various |
| HDMI 3 | Up to 4K | Up to 60fps | Various |
| HDMI 4 | Up to 4K | Up to 60fps | Various |

> **Note:** When capturing 4K on multiple inputs simultaneously, bandwidth limitations may require using 4K30 or 1080p60.

### Signal Flow

```
Cameras ──HDMI──→ DeckLink Quad HDMI ──PCIe──→ Echo Express ──TB3──→ Mac Studio ──→ OBS
```

---

## Hardware Setup

### Echo Express Chassis

1. **Position**: Place chassis with adequate ventilation (generates heat)
2. **Power**: Connect to UPS/power conditioner (powers on automatically)
3. **Thunderbolt**: Connect to Mac Studio TB3 port
   - Use **Port 1** for best bandwidth
   - Avoid daisy-chaining other devices

### DeckLink Card Installation

The DeckLink Quad HDMI should be pre-installed in the Echo Express chassis.

**Verification:**
```bash
system_profiler SPPCIDataType | grep -i decklink
```

### HDMI Connections

| Port | Cable Type | Max Length | Notes |
|------|------------|------------|-------|
| HDMI 1 | HDMI 2.0+ | 3m (10ft) for 4K | <!-- TODO: Camera assignment --> |
| HDMI 2 | HDMI 2.0+ | 3m (10ft) for 4K | <!-- TODO: Camera assignment --> |
| HDMI 3 | HDMI 2.0+ | 3m (10ft) for 4K | <!-- TODO: Camera assignment --> |
| HDMI 4 | HDMI 2.0+ | 3m (10ft) for 4K | <!-- TODO: Camera assignment --> |

> ⚠️ For runs longer than 3m at 4K, use active HDMI cables or HDMI-over-fiber extenders.

---

## DeckLink Configuration

### Installing Drivers

1. Download **Desktop Video** from [Blackmagic Support](https://www.blackmagicdesign.com/support)
2. Install the package (requires restart)
3. Verify installation:
   ```bash
   ls /Library/Application\ Support/Blackmagic\ Design/
   ```

### Desktop Video Setup Utility

Launch **Blackmagic Desktop Video Setup** from Applications:

1. Select each input
2. Configure:
   - **Video Input**: HDMI
   - **Video Format**: Match your cameras (e.g., 1080p60)
   - **Color Space**: Rec.709 (default for most cameras)

### Input Format Settings

<!-- TODO: Document your specific camera formats -->

| Input | Video Format | Color Space | Range |
|-------|--------------|-------------|-------|
| 1 | 1080p60 | Rec.709 | Full |
| 2 | 1080p60 | Rec.709 | Full |
| 3 | 1080p60 | Rec.709 | Full |
| 4 | 1080p60 | Rec.709 | Full |

---

## Camera Settings

### Recommended Camera Settings

For consistent multi-camera production:

| Setting | Value | Notes |
|---------|-------|-------|
| Resolution | 1080p or 4K | Match across all cameras |
| Frame Rate | 60fps | Or 30fps for all |
| White Balance | Manual (5600K typical) | Match all cameras |
| Exposure | Manual or priority | Consistent look |
| Color Profile | Standard/Neutral | Easier to match |
| HDMI Output | Clean (no overlays) | Critical! |
| HDMI Output Resolution | Match capture format | No scaling |

### Per-Camera Configuration

<!-- TODO: Document your specific cameras -->

#### Camera 1: <!-- TODO: Model -->

```
<!-- TODO: Add specific settings -->
```

#### Camera 2: <!-- TODO: Model -->

```
<!-- TODO: Add specific settings -->
```

#### Camera 3: <!-- TODO: Model -->

```
<!-- TODO: Add specific settings -->
```

#### Camera 4: <!-- TODO: Model -->

```
<!-- TODO: Add specific settings -->
```

---

## OBS Integration

### Adding DeckLink Sources

1. In OBS, click **+** in Sources
2. Select **Blackmagic Device**
3. Configure:
   - **Device**: DeckLink Quad HDMI (X) where X = input number
   - **Mode**: Match camera output format
   - **Pixel Format**: Auto (or match Desktop Video config)
   - **Color Space**: Rec.709
   - **Color Range**: Full (if cameras output full range)

### OBS Source Naming Convention

<!-- TODO: Adjust for your setup -->

| Source Name | DeckLink Input | Camera |
|-------------|----------------|--------|
| CAM1-Wide | Input 1 | <!-- TODO --> |
| CAM2-Host | Input 2 | <!-- TODO --> |
| CAM3-Guest | Input 3 | <!-- TODO --> |
| CAM4-Overhead | Input 4 | <!-- TODO --> |

### Scene Setup

```
Scene Collection: "Livestream-Main"
├── Scene: Full Screen
│   └── CAM1-Wide (full canvas)
├── Scene: Host Close-up
│   └── CAM2-Host (full canvas)
├── Scene: Split Screen
│   ├── CAM2-Host (left half)
│   └── CAM3-Guest (right half)
└── Scene: Picture-in-Picture
    ├── CAM1-Wide (full canvas)
    └── CAM2-Host (corner, scaled)
```

---

## Resolution & Frame Rate

### Bandwidth Considerations

The DeckLink Quad HDMI shares PCIe bandwidth across all inputs.

| Configuration | Total Bandwidth | Notes |
|---------------|-----------------|-------|
| 4x 1080p60 | ~12 Gbps | Recommended |
| 2x 4K30 + 2x 1080p60 | ~14 Gbps | Workable |
| 4x 4K30 | ~18 Gbps | May drop frames |
| 4x 4K60 | ~36 Gbps | Not supported |

### Recommended Configuration

For reliable 4-camera streaming:
- **All cameras**: 1080p60
- **OBS Canvas**: 1920x1080 @ 60fps
- **Stream Output**: 1080p60 or 1080p30

### 4K Workflows

If you need 4K:
1. Use 2 cameras at 4K30, 2 at 1080p60
2. Or use 4K capture, downscale in OBS
3. Monitor for dropped frames in OBS stats

---

## Troubleshooting

### No Signal Detected

**Symptoms:** OBS shows "No signal" for DeckLink source

**Solutions:**
1. Check HDMI cable connection (both ends)
2. Verify camera is outputting HDMI (check camera LCD)
3. Confirm HDMI output is set to match capture format
4. Check Desktop Video Setup for detected signal
5. Power cycle the Echo Express chassis
6. Try different HDMI port on DeckLink

### Signal Flickering/Unstable

**Symptoms:** Image appears and disappears, or has artifacts

**Solutions:**
1. Replace HDMI cable (cables degrade)
2. Check for HDCP issues (disable on camera if possible)
3. Ensure camera HDMI output matches DeckLink input format exactly
4. Check for loose connections
5. Try active HDMI cable for longer runs

### Color/Exposure Mismatch Between Cameras

**Symptoms:** Cameras look different when switching

**Solutions:**
1. Manual white balance on all cameras (same Kelvin value)
2. Manual exposure (or same exposure compensation)
3. Match color profiles/picture styles
4. Use color correction in OBS if needed
5. Consider video lighting for consistency

### Dropped Frames

**Symptoms:** OBS shows "Frames missed due to rendering lag"

**Solutions:**
1. Reduce capture resolution (4K → 1080p)
2. Check Thunderbolt connection (avoid hubs)
3. Close other GPU-intensive applications
4. Update DeckLink drivers
5. Monitor Mac GPU usage (Activity Monitor)

### DeckLink Not Detected

**Symptoms:** DeckLink doesn't appear in OBS or Desktop Video Setup

**Solutions:**
1. Restart Mac Studio
2. Power cycle Echo Express chassis
3. Check Thunderbolt cable connection
4. Try different Thunderbolt port
5. Reinstall Desktop Video drivers
6. Check System Report → Thunderbolt for chassis detection

### Audio Issues with HDMI Capture

**Symptoms:** Embedded HDMI audio not working or delayed

**Solutions:**
1. We use Dante for audio—disable HDMI audio in OBS source
2. If using HDMI audio, check Desktop Video audio settings
3. Sync audio using OBS advanced audio properties

---

## Quick Reference

### OBS DeckLink Source Settings

```
Device: Blackmagic DeckLink Quad HDMI (1-4)
Mode: 1080p60 (or match camera)
Pixel Format: Auto
Color Space: Rec.709
Color Range: Full
Deactivate when not showing: Off (for faster switching)
```

### Useful Commands

```bash
# Check DeckLink detection
system_profiler SPPCIDataType | grep -A10 -i "blackmagic"

# Check Thunderbolt devices
system_profiler SPThunderboltDataType

# List video input devices
system_profiler SPCameraDataType
```

---

## See Also

- [CAMERA-SETTINGS.md](../hardware/CAMERA-SETTINGS.md) - Per-camera configuration
- [RUNBOOK.md](RUNBOOK.md) - Pre-stream checklist
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - General troubleshooting

---

*Document maintained by Multi-Camera Livestream Framework team*
