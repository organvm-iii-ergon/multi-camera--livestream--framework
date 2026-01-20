# Camera Settings Guide

> Per-camera configuration for the Dope's Show live streaming pipeline.

**Last Updated:** <!-- TODO: Update date -->
**Version:** 1.0.0

---

## Overview

This document contains the specific settings for each camera in your multi-camera setup. Consistent settings across all cameras ensure seamless switching and a professional look.

---

## Universal Settings

Apply these settings to **all cameras** for consistency:

### Video Output

| Setting | Value | Notes |
|---------|-------|-------|
| Resolution | 1920x1080 | Or match DeckLink input |
| Frame Rate | 60p | Or 30p if all cameras match |
| HDMI Output | Clean/No Info Display | Critical! |
| HDMI Resolution | Match capture format | Don't let camera scale |

### Exposure

| Setting | Value | Notes |
|---------|-------|-------|
| Mode | Manual or Aperture Priority | Consistency > auto |
| ISO | <!-- TODO --> | Match across cameras |
| Shutter Speed | 1/120 for 60fps | Double frame rate rule |
| Aperture | <!-- TODO --> | Based on DOF needs |

### White Balance

| Setting | Value | Notes |
|---------|-------|-------|
| Mode | Manual (Kelvin) | Never auto |
| Temperature | 5600K (daylight) or 3200K (tungsten) | Match your lighting |
| Tint | 0 (or match to grey card) | Fine-tune if needed |

### Color Profile

| Setting | Value | Notes |
|---------|-------|-------|
| Picture Profile | Standard/Neutral | Easier to match |
| Contrast | 0 or -1 | Slightly flat is easier to grade |
| Saturation | 0 | Neutral |
| Sharpness | -1 or 0 | Avoid over-sharpening |

---

## Per-Camera Configuration

### Camera 1: <!-- TODO: Model Name -->

**Role:** <!-- TODO: e.g., Wide shot, Host camera -->
**Position:** <!-- TODO: e.g., Front of desk, 10ft back -->
**Lens:** <!-- TODO: e.g., 24-70mm f/2.8 -->

#### Settings

```
Resolution: 1080p60
HDMI Output: Clean
White Balance: 5600K
ISO: 800
Aperture: f/4.0
Shutter: 1/120

Picture Profile: Standard
Contrast: 0
Saturation: 0
Sharpness: 0

Focus: Manual / Continuous (depending on movement)
Image Stabilization: Off (tripod mounted)

Power: AC adapter (recommended for long sessions)
```

#### Notes

<!-- TODO: Any specific notes about this camera -->
-
-

---

### Camera 2: <!-- TODO: Model Name -->

**Role:** <!-- TODO -->
**Position:** <!-- TODO -->
**Lens:** <!-- TODO -->

#### Settings

```
Resolution: 1080p60
HDMI Output: Clean
White Balance: 5600K
ISO: 800
Aperture: f/4.0
Shutter: 1/120

Picture Profile: Standard
Contrast: 0
Saturation: 0
Sharpness: 0

Focus: Manual / Continuous
Image Stabilization: Off

Power: AC adapter
```

#### Notes

-
-

---

### Camera 3: <!-- TODO: Model Name -->

**Role:** <!-- TODO -->
**Position:** <!-- TODO -->
**Lens:** <!-- TODO -->

#### Settings

```
Resolution: 1080p60
HDMI Output: Clean
White Balance: 5600K
ISO: 800
Aperture: f/4.0
Shutter: 1/120

Picture Profile: Standard
Contrast: 0
Saturation: 0
Sharpness: 0

Focus: Manual / Continuous
Image Stabilization: Off

Power: AC adapter
```

#### Notes

-
-

---

### Camera 4: <!-- TODO: Model Name -->

**Role:** <!-- TODO -->
**Position:** <!-- TODO -->
**Lens:** <!-- TODO -->

#### Settings

```
Resolution: 1080p60
HDMI Output: Clean
White Balance: 5600K
ISO: 800
Aperture: f/4.0
Shutter: 1/120

Picture Profile: Standard
Contrast: 0
Saturation: 0
Sharpness: 0

Focus: Manual / Continuous
Image Stabilization: Off

Power: AC adapter
```

#### Notes

-
-

---

## Brand-Specific Settings

### Sony Cameras

**HDMI Output Settings:**
```
Menu → Setup → HDMI Settings
├── HDMI Resolution: 1080p
├── HDMI Output: No Info Display
├── TC Output: Off
└── REC Control: Off
```

**Picture Profile (Neutral):**
```
Menu → Camera → Picture Profile
├── PP Off (or)
└── PP1 with:
    ├── Black Level: 0
    ├── Gamma: Still
    ├── Color Mode: Standard
    └── Saturation: 0
```

### Canon Cameras

**HDMI Output Settings:**
```
Menu → Wrench/Setup → Video System
├── HDMI output: 1080p
Menu → Wrench/Setup → HDMI Output
├── Info Display: Off
└── Clean HDMI: On
```

**Picture Style:**
```
Menu → Camera → Picture Style
└── Standard or Neutral
```

### Panasonic Cameras

**HDMI Output Settings:**
```
Menu → Setup → TV Connection
├── HDMI Mode: 1080p
├── Info Display: Off
└── Down Convert: Off
```

**Photo Style:**
```
Menu → Rec → Photo Style
└── Standard or Natural
```

### Blackmagic Cameras

**HDMI Output:**
```
Menu → Setup → Monitor
├── Clean Feed: On
├── Status Text: Off
└── Frame Guides: Off
```

---

## Pre-Show Camera Checklist

Run through this checklist for each camera before streaming:

- [ ] Power: AC adapter connected (not battery)
- [ ] Memory card: Removed or formatted (prevents recording prompt)
- [ ] HDMI: Clean output confirmed (no overlays)
- [ ] Resolution: Matches OBS/DeckLink setting
- [ ] White balance: Manual, matches all cameras
- [ ] Exposure: Manual or locked, levels matched
- [ ] Focus: Set and locked (or AF configured)
- [ ] Audio: Disabled or confirmed muted on camera
- [ ] Auto power-off: Disabled
- [ ] Recording: Not actively recording

---

## Color Matching Procedure

### Initial Setup (One Time)

1. Set up all cameras pointing at same grey card
2. Match white balance exactly (use Kelvin value)
3. Set identical exposure (ISO, aperture, shutter)
4. Set identical picture profile settings
5. Take screenshot of each camera's output in OBS
6. Adjust picture profile if needed to match

### Quick Match (Per Session)

1. Verify white balance matches (same lighting)
2. Check exposure levels (waveform/histogram)
3. Quick A/B switch between cameras to verify

### Post-Production (If Needed)

For recordings that need color correction:
1. Apply same base correction to all cameras
2. Fine-tune individual clips as needed
3. Use scopes (waveform, vectorscope)

---

## Troubleshooting

### Cameras Look Different When Switching

1. Check white balance (most common cause)
2. Check exposure/brightness levels
3. Compare picture profiles
4. Verify same resolution/frame rate

### HDMI Showing Overlays

1. Find "HDMI Info Display" or "Clean HDMI" setting
2. Disable all overlays, guides, histograms
3. May need to disable record indicator

### Camera Overheating

1. Use AC power (reduces heat from charging)
2. Remove memory card (reduces internal recording heat)
3. Ensure ventilation around camera
4. Consider camera cooling fan for long sessions

### Auto Power-Off During Stream

1. Find "Auto Power Off" setting, set to OFF
2. Use AC adapter (some cameras won't sleep on AC)
3. Set LCD timeout but not camera power-off

---

## See Also

- [VIDEO-CAPTURE.md](../docs/VIDEO-CAPTURE.md) - DeckLink configuration
- [COMPATIBILITY.md](COMPATIBILITY.md) - Tested camera models
- [RUNBOOK.md](../docs/RUNBOOK.md) - Pre-stream checklist

---

*Document maintained by Dope's Show Pipeline team*
