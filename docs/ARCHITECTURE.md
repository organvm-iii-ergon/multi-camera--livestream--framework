# System Architecture

## High-Level Overview

This pipeline ingests 4K video from DSLR/mirrorless cameras, synchronizes audio via Dante network, enables low-latency NDI caller integration, and outputs to streaming platforms (YouTube, Twitch) via OBS.

**Design principle**: Separation of concerns — capture, sync, mixing, output are independent subsystems connected via standardized protocols (HDMI, Dante, NDI, RTMP).

## Signal Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│ INPUT LAYER                                             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Cameras (HDMI)              Cameras (Audio)            │
│  ├─ Panasonic G7             ├─ USB or XLR             │
│  ├─ GoPro Hero 9             └─ Dante converters       │
│  ├─ GoPro Max                                           │
│  └─ DJI Osmo                 Callers (Remote)          │
│       ↓                        └─ NDI OBS stream       │
│  DeckLink Quad HDMI                ↓                   │
│  (Echo Express SE I)          M1 Mac Ultra             │
│       ↓                        (OBS NDI input)         │
│                                                         │
├─────────────────────────────────────────────────────────┤
│ CAPTURE LAYER (M1 Mac Ultra)                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  OBS Studio                                             │
│  ├─ Scene 1: Camera quad (4K mosaic)                   │
│  ├─ Scene 2: Single camera + caller                    │
│  ├─ Scene 3: Screen share (Blender)                    │
│  └─ Audio Input: MOTU 8PRE-ES (Dante interface)        │
│                                                         │
│  Dante Network (audio sync)                            │
│  ├─ MOTU 8PRE-ES (Dante I/O)                           │
│  ├─ Dante AVIO nodes (camera audio converters)         │
│  └─ Sample clock: 48 kHz (broadcast standard)          │
│                                                         │
├─────────────────────────────────────────────────────────┤
│ PROCESSING LAYER                                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Ableton Live (audio mixing, clock master)             │
│  ├─ Input: Camera feeds (via Dante)                    │
│  ├─ Master clock: Drives all Dante devices             │
│  └─ Output: Master mix → MOTU → OBS                    │
│                                                         │
│  Blender (graphics, optional)                          │
│  ├─ Input: Generative parameters (MIDI from Ableton)  │
│  └─ Output: Screen share → OBS                         │
│                                                         │
├─────────────────────────────────────────────────────────┤
│ OUTPUT / ENCODING LAYER                                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  OBS Encoder (H.264 or H.265)                          │
│  ├─ Video bitrate: 8–25 Mbps (codec-dependent)         │
│  ├─ Resolution: 4K or 1080p mosaic                     │
│  └─ Framerate: 30fps or 60fps                          │
│       ↓                                                  │
│  RTMP Output (streaming protocol)                      │
│       ↓                                                  │
├─────────────────────────────────────────────────────────┤
│ DISTRIBUTION LAYER                                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Streaming Platforms:                                   │
│  ├─ YouTube Live                                        │
│  ├─ Twitch                                              │
│  └─ Custom RTMP server (Nginx, Wowza)                  │
│                                                         │
│  Archive & Analytics:                                   │
│  ├─ Local recording (OBS → H.264 file)                 │
│  └─ Optional: S3 backup of raw recordings              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Capture Subsystem (HDMI + DeckLink)

- **DeckLink Quad HDMI**: 4× HDMI input, outputs to PCIe
- **Echo Express SE I**: TB3 enclosure, PCIe slot for DeckLink
- **Protocol**: Uncompressed HDMI or HDCP-encrypted video
- **Latency**: <1ms (hardware-based capture)
- **Bandwidth**: ~1.5 Gbps per 4K30 stream

### 2. Audio Synchronization (Dante)

**Why Dante?**
- All audio sources share a **global sample clock**
- Avoids drift between video and audio
- Supports flexible routing without hardware reconfiguration
- Industry standard for broadcast

**Components**:
- **Dante Network**: Dedicated managed Ethernet switch
- **MOTU 8PRE-ES**: Primary Dante I/O, master clock source
- **Dante AVIO USB**: Bridges USB audio devices to Dante network
- **Sample Rate**: 48 kHz (locked to Ableton's clock)

**Clock Hierarchy**:
```
Ableton Live (Master Clock, 48 kHz)
    ↓ sync to
Dante Network (all devices phase-locked)
    ↓ sync to
Camera audio converters (lock to Dante clock, eliminate drift)
```

### 3. Caller Integration (NDI)

- **Protocol**: NDI (Network Device Interface)
- **Latency**: <200ms local, <500ms internet
- **Caller machine**: OBS instance streaming via NDI
- **Your OBS**: NDI input plugin (receives caller video)
- **Audio path**: Separate Dante return (or Zoom audio as fallback)

### 4. Video Mixing (OBS)

**Responsibilities**:
- Ingest 4 HDMI feeds (DeckLink)
- Ingest 1–4 NDI feeds (callers)
- Compose into scenes (mosaic, PiP, full-screen)
- Apply transitions, overlays, text
- Encode to H.264/H.265
- Output to RTMP server

**Resource allocation**:
- GPU: ~50–70% (encoding)
- CPU: ~20–30% (scene mixing, transitions)
- RAM: <10 GB (typical)

### 5. Audio Mixing (Ableton Live)

**Responsibilities**:
- Input: 4 camera feeds (via Dante interface)
- Mixing: EQ, gain, effects per camera
- Master: Acts as Dante clock master
- Output: Stereo mix → MOTU → OBS

---

## Performance Targets

| Metric | Target | Measured (Jan 2025) |
|--------|--------|-------------------|
| Video latency (capture→stream) | <5 sec | 2–3 sec (RTMP platform-dependent) |
| Audio sync drift | <100ms over 1 hour | <50ms observed |
| Caller latency (RTT) | <500ms | 150–200ms (Dante local) |
| Dropped frames | 0 | 0 (2-hour test) |
| CPU sustained load | <70% | 50–60% (M1 Ultra) |
| GPU load | <80% | 65–70% (H.265 encoding) |
| Network jitter | <10ms | <2ms (dedicated Dante switch) |

---

## Scaling: Single Room → Entire House

### Phase 1: Single Setup (Current, 4 cameras)

```
M1 Ultra (all processing)
    ├─ Video: DeckLink Quad (4 cameras)
    ├─ Audio: MOTU 8PRE-ES + Dante switch (cameras + mics)
    └─ Output: RTMP to YouTube/Twitch
```

**Limits**:
- 4 simultaneous camera inputs (DeckLink Quad limit)
- CPU: 60–70% sustained load
- Network: Single gigabit upstream (25–50 Mbps)

### Phase 2: Multi-Room Expansion (8–10 cameras)

```
Room A: Local OBS instance
    └─ Camera 1–4 + local audio
    └─ Output: NDI to master M1 Ultra

Room B: Local OBS instance
    └─ Camera 5–8 + local audio
    └─ Output: NDI to master M1 Ultra

Master (M1 Ultra):
    ├─ Input: NDI streams from rooms
    ├─ Audio: Dante network (per-room mixing)
    └─ Output: Composite RTMP to YouTube
```

**New Requirements**:
- Multiple machines (M1 mac mini per room)
- Dante redundant network (dual switches)
- Higher bandwidth (100 Mbps+ upstream)

### Phase 3: Building-Scale Reality Show

```
[Building with 10–15 rooms]
    ├─ Each room: Local capture + NDI out
    ├─ Central control: Master M1 Ultra
    ├─ Dante backbone: Redundant audio network
    ├─ Archive server: NAS or S3 backup
    └─ Analytics dashboard: Viewer engagement tracking
```

---

## Reliability & Redundancy

### Current (Single M1 Ultra)

**Single point of failure**: M1 Ultra crash → entire stream down

**Mitigation**:
- Regular thermal monitoring (avoid throttle)
- Staged restart: Dante → DeckLink → OBS → Ableton
- Local recording (continuous backup)

### Production (Multi-Room)

**Redundancy layers**:
1. **Network**: Dual Dante switches (RSTP auto-failover)
2. **Encoding**: Two M1 Ultras (active/passive or load-balanced)
3. **Archive**: Dual storage paths (local + S3)
4. **Streaming**: Multiple RTMP keys (YouTube + Twitch simultaneously)

---

## Monitoring & Observability

**Key metrics to track** (during broadcast):
- OBS frame drops (target: 0)
- Dante clock phase (should show <1µs deviation)
- MOTU CPU/DSP load (target: <80%)
- Upstream bandwidth utilization
- Caller RTT latency

**Tools**:
- macOS Activity Monitor (CPU, memory, network)
- OBS built-in stats (FPS, dropped frames, render latency)
- Dante Controller (network status, device sync)
- MOTU Console (audio levels, DSP load)

---

**Last Updated**: 2025-01-22
