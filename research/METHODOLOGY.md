# Methodology & Reproducibility Statement

## Research Questions

1. **Technical**: What hardware/software architecture enables reproducible, 
   professional-grade multi-camera 4K streaming for artists without broadcast 
   engineering background?

2. **Practical**: How can we document and open-source such a system to 
   lower barriers to entry for live performance practitioners?

3. **Scalability**: How does this system scale from a single studio (4 cameras) 
   to building-scale installations (10+ rooms, 100+ simultaneous viewers)?

---

## Methodological Approach

### 1. Design Science Research (DSR)

**Framework**: Building an artifact (the streaming pipeline) to solve a 
real-world problem, then rigorously documenting its design, validation, and 
application.

**Steps**:

1. **Problem Identification**
   - Existing streaming solutions (YouTube, Twitch, OBS) insufficient for 
     synchronized multi-camera + interactive caller model
   - High barrier to entry (complexity, cost, expertise)
   - Lack of reproducible documentation for practitioners

2. **Solution Design**
   - Modular architecture: separate capture, sync, mixing, output layers
   - Hardware selection based on compatibility + cost + reliability
   - Open documentation as core research output

3. **Implementation & Artifact Development**
   - Build system on M1 Mac Studio
   - Integrate DeckLink, MOTU, OBS, Ableton, Blender
   - Document every step, failure, and workaround

4. **Evaluation**
   - Real-world validation: 3+ broadcast events, 2+ hours each
   - Performance metrics: CPU/GPU load, latency, dropped frames
   - Qualitative feedback: artist interviews, practitioner survey

5. **Communication**
   - GitHub repository (primary output)
   - Academic publication (secondary)
   - Open runbooks & troubleshooting guides

---

### 2. Iterative System Testing

**Test phases**:

| Phase | Duration | Goal | Validation |
|-------|----------|------|-----------|
| **Lab** | Weeks 1–4 | Component integration, driver compatibility | No drops in 30-min test |
| **Dry Run** | Weeks 5–8 | Full workflow, Dante sync, OBS+Ableton integration | Zero audio/video drift over 2h |
| **Broadcast 1** | Month 3 | Real event, single camera, 1 caller, <1h | Successful live stream, viewable archive |
| **Broadcast 2** | Month 4 | 4 cameras, 2 callers, longer duration (2h) | Sustained stable performance |
| **Broadcast 3** | Month 5 | Complex scene (caller + Blender + DJ set), 3h | Robustness under sustained load |

**Metrics collected**:
- Frame drops (OBS stats)
- Audio latency (Dante jitter, ms)
- CPU/GPU utilization (Activity Monitor)
- Upstream bandwidth (network utility)
- Thermal behavior (sustained temp)

---

### 3. Compatibility Matrix Testing

**Hardware combinations tested**:

```
Test Matrix Format:

Hardware Config 1: M1 Mac Studio + DeckLink Quad HDMI + MOTU 8PRE-ES + Dante Switch
- Test Date: 2025-01-15
- macOS Version: 14.2.1
- Driver Versions: DeckLink 13.2, MOTU 2.23.5, Dante Controller 4.5.3
- Test Duration: 2 hours
- Result: ✅ PASS (0 drops, 48°C avg temp, 55% CPU)
- Issues Encountered: HDMI handshake flicker on 4th camera (intermittent)
- Resolution: Swap HDMI cable type; issue resolved with Belkin 2.1 cable
```

**Outcome**: Publicly available matrix in `hardware/COMPATIBILITY.md`

---

### 4. Failure Analysis & Recovery Testing

**Protocol**: Intentionally introduce failures; document recovery procedures.

**Scenarios tested**:

| Failure Mode | Cause | Detection | Recovery | Time |
|---|---|---|---|---|
| Audio drift | Camera audio clock desync | Ableton delay increasing | Re-lock Dante clock, restart MOTU | 30 sec |
| Video drops | DeckLink driver timeout | OBS reports dropped frames | Power cycle Echo Express | 2 min |
| Caller lag | NDI network congestion | Caller video stalls | Switch to Zoom audio + NDI video | 1 min |
| Thermal throttle | Mac >80°C, CPU scaling down | CPU usage drops, frame rate stutters | Reduce bitrate; add external fan | 5 min |
| Stream interruption | Upload network failure | RTMP server unreachable | Switch backup internet (4G hotspot) | 2 min |

**Documentation**: Each scenario + fix becomes troubleshooting guide entry

---

## Reproducibility Statement

### What Can Others Reproduce?

✅ **Fully reproducible**:
- Hardware compatibility testing (given same hardware)
- Performance benchmarks (same hardware, same macOS version)
- OBS scene composition and transitions
- Dante audio routing configuration
- Startup/shutdown procedures

⚠️ **Partially reproducible**:
- Real broadcasts (content unique, but process replicable)
- Latency measurements (vary by network, ISP)
- Thermal characteristics (depends on ambient temperature, usage patterns)

❌ **Not reproducible**:
- Specific artistic outcomes (subjective)
- Viewer engagement (platform-dependent, audience-specific)
- Participant experiences (qualitative, context-dependent)

---

### Reproducibility Checklist

**For researchers/practitioners wishing to replicate:**

```markdown
## Replication Checklist

### Hardware
- [ ] Hardware BOM matches `hardware/BOM.csv` exactly
- [ ] Verify compatibility matrix entry exists in `hardware/COMPATIBILITY.md`
- [ ] Test each component individually before integration
- [ ] Record actual temperatures, CPU/GPU load in your environment

### Software
- [ ] macOS version matches (or documented as tested on your version)
- [ ] All driver versions pinned to `VERSION_PINNED` file
- [ ] OBS scene imported from `configs/obs/studio-scene.json`
- [ ] Run `bash software/scripts/health-check.sh` before broadcast

### Validation
- [ ] Complete 30-min dry run (no callers, no RTMP)
- [ ] Record to local file, verify zero drops
- [ ] Measure CPU/GPU load during dry run
- [ ] Document any differences from reference system

### Reporting
- [ ] File issue on GitHub (template: `hardware_compatibility.md`)
- [ ] Include: hardware config, driver versions, results, temperature
- [ ] Attach health-check.sh output (text file)
- [ ] Note ambient temperature, room conditions
```

---

## Data Management Plan

### Raw Data Collection

**What's collected**:
1. **System logs**
   - OBS output logs (FPS, dropped frames, render time)
   - MOTU console logs (audio levels, DSP load)
   - Dante Controller network stats
   - macOS system.log (kernel messages, driver loads)

2. **Performance metrics**
   - CPU/GPU utilization (1-minute samples)
   - Network bandwidth (upload speed, jitter)
   - Thermal data (CPU/GPU temperature)
   - Audio latency (Dante phase offset)

3. **Video archives**
   - Broadcast video files (H.264 or H.265, 20–50 GB per broadcast)
   - Optional: Raw DeckLink capture (uncompressed, 200+ GB)

4. **Configuration snapshots**
   - OBS scene export (JSON)
   - MOTU audio routing (XML)
   - Dante network configuration (JSON)
   - Ableton set file (.als)

---

### Storage & Archiving Strategy

**Local backup** (immediate):
```
~/Videos/Broadcasts/
├─ broadcast-2025-01-22/
│  ├─ video.mp4 (final RTMP output)
│  ├─ local-recording.mp4 (OBS local backup)
│  ├─ obs-logs.txt
│  ├─ system-logs.txt
│  └─ metadata.json (duration, bitrate, participants)
└─ broadcast-2025-02-XX/
   └─ [same structure]
```

**Retention policy**:
- **Local**: Keep 3 most recent broadcasts (free up disk space)
- **S3**: Retain indefinitely (cost ~$50/year per 1 TB)
- **YouTube/Twitch**: Archive live (platform-native, free)

---

### Data Privacy & Consent

**Participant consent** (before each broadcast):
```
I consent to:
[ ] Recording for archival
[ ] Archive uploaded to S3
[ ] Video used in academic publication
[ ] De-identification in publication (my name hidden)
[ ] Full anonymity (face blurred, voice anonymized)
```

---

## Quality Assurance

### Code & Documentation Review

**Before publication, verify:**

- [ ] All links in markdown files work
- [ ] Bash scripts run without errors (`shellcheck` static analysis)
- [ ] Hardware specs match actual components ordered
- [ ] Version numbers consistent across all files
- [ ] Diagrams readable at screen resolution (50% scale test)

---

## Validation Metrics (Success Criteria)

### For Conference Publication

| Metric | Target | Status |
|--------|--------|--------|
| Paper acceptance rate | ≥10% (good for competitive venues) | TBD |
| Presentation quality | ≥8/10 (audience feedback) | TBD |
| Follow-up collaborations | ≥2 inquiries | TBD |

### For GitHub Repository

| Metric | Target | Status |
|--------|--------|--------|
| Documentation completeness | >95% coverage of setup steps | ✅ |
| Hardware tested | ≥3 configurations verified | ✅ (M1 Ultra, M1 mini, MacBook) |
| Issues resolved | Respond to all issues within 2 weeks | ✅ |
| Forks/adaptations | ≥5 community forks within 1 year | Pending |

---

**Last Updated**: 2025-01-22
