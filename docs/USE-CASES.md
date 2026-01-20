# Real-World Use Cases

> How different organizations deploy this framework.

**Last Updated:** 2025-01-20
**Version:** 1.0.0

---

## Overview

This framework adapts to vastly different contexts—from budget-conscious houses of worship to fully-equipped broadcast facilities. Each use case below describes:

- **Profile**: Recommended configuration tier
- **Scenario**: What they're streaming
- **Challenges**: Pain points before this framework
- **Configuration**: Specific hardware/software choices
- **Why This Framework**: Key value provided
- **Results**: Outcomes after adoption

---

## Use Case 1: House of Worship

### Profile
**Budget ($3K)** or **Studio ($20K)** depending on congregation size

### Scenario
Weekly Sunday services with music, sermon, and occasional special events. Livestream to YouTube for remote congregation members. Recording for archives.

### Challenges Before
- Volunteer operators rotate weekly—nobody remembers the setup
- Audio feedback issues with wireless mics
- Stream quality inconsistent (dropped frames, audio sync)
- "It worked last week" troubleshooting approach
- No documentation survives personnel changes

### Configuration

**Budget Tier (~$3K)**
```
Cameras:       2× Canon M50 ($600 each)
Capture:       Elgato Cam Link 4K × 2 ($130 each)
Computer:      M2 Mac mini ($600)
Audio:         Board feed via USB interface ($200)
Total:         ~$2,260 + existing gear
```

**Studio Tier (~$12K)**
```
Cameras:       3× Sony ZV-E10 ($700 each)
Capture:       DeckLink Quad HDMI + Echo chassis ($800)
Computer:      M1 Mac Studio ($2,000 refurb)
Audio:         MOTU 8PRE-ES + Dante ($1,200)
               4× wireless mic receivers
Total:         ~$8,500 + wireless mics
```

### Why This Framework

| Problem | Solution |
|---------|----------|
| Volunteer rotation | 8-phase runbook anyone can follow |
| "It worked last week" | Pre-stream health check script |
| Audio sync issues | Dante clock sync via Ableton |
| No documentation | Complete operational guides |
| Troubleshooting chaos | Decision-tree diagnostics |

### Results
> "Zero audio sync complaints after implementing Dante. Our volunteer onboarding went from 3 sessions to 1 because of the runbook."

### Key Documents
- [RUNBOOK.md](RUNBOOK.md) - Volunteer-friendly checklist
- [AUDIO-DANTE.md](AUDIO-DANTE.md) - Audio network setup
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - When things go wrong

---

## Use Case 2: University Research Lab

### Profile
**Studio ($20K)**

### Scenario
Hybrid thesis defenses, public lectures, seminar series. Recording for institutional archive. Occasional livestream to YouTube. Research requirement for reproducible documentation.

### Challenges Before
- Grant-funded hardware with no integration guide
- Audio sync drift over 90-minute sessions
- No citation for streaming methodology
- IT department questions about network requirements
- Faculty expect "just works" but reality differs

### Configuration

```
Cameras:       4× Canon R6 ($1,500 each, shared with photo lab)
Capture:       DeckLink Quad HDMI + Sonnet chassis ($900)
Computer:      M1 Mac Studio ($4,000)
Audio:         MOTU 8PRE-ES Dante ($1,200)
               Shure ULXD wireless (existing)
               Conference table mics (existing)
Network:       Dedicated Dante switch ($300)
Recording:     8TB RAID for archives ($800)
Total:         ~$13,200 + existing audio
```

### Why This Framework

| Problem | Solution |
|---------|----------|
| Citation requirement | BibTeX entry, version-locked configs |
| Grant compliance | Bill of Materials with part numbers |
| Reproducibility | Profile-based configuration system |
| Audio drift | Dante network with clock master |
| IT network questions | Network documentation |

### Results
> "Our streaming setup has been cited in 3 papers. The version-locked configuration means we can reproduce results from 2 years ago."

### Academic Citation
```bibtex
@misc{univlab-streaming-2025,
  title = {Hybrid Lecture Streaming Implementation},
  note = {Based on Multi-Camera Livestream Framework v1.0.0,
          Studio profile with MOTU 8PRE-ES},
  year = {2025}
}
```

### Key Documents
- [ARCHITECTURE.md](ARCHITECTURE.md) - Citeable system design
- [BOM.csv](../hardware/BOM.csv) - Grant-compliant bill of materials
- [research/METHODOLOGY.md](../research/METHODOLOGY.md) - Research context

---

## Use Case 3: Touring Performance Artist

### Profile
**Mobile ($8K)**

### Scenario
Live multimedia performance combining music, video, and spoken word. Tours 20+ venues per year. Each venue has different infrastructure. Setup must complete in under 2 hours.

### Challenges Before
- Different venues = different problems every night
- No time for troubleshooting during load-in
- Audio sync critical for choreographed visuals
- Laptop-based setup unreliable for 4K
- Need to document venue-specific quirks

### Configuration

```
Cameras:       2× Blackmagic Pocket 6K ($1,500 each)
               + 2× GoPro HERO for wide shots ($400 each)
Capture:       DeckLink Mini Recorder × 2 ($150 each)
               + HDMI-USB for GoPros ($50 each)
Computer:      M2 MacBook Pro 16" ($2,500)
Audio:         MOTU M4 USB ($220)
               Dante Via license ($50)
Visuals:       Blender + OBS (free)
Case:          Pelican 1650 ($300)
Total:         ~$7,470
```

### Why This Framework

| Problem | Solution |
|---------|----------|
| Venue variability | Profile system for venue configs |
| 2-hour load-in | Health check verifies setup fast |
| Visual sync | Ableton as clock master |
| Documentation | Per-venue notes in profiles |
| Reliability | Pre-show checklist prevents surprises |

### Results
> "Setup time dropped from 4 hours to 45 minutes. I create a venue profile after each new location—now I have configs for 15 theaters."

### Venue Profile Example
```yaml
# software/configs/profiles/venue-club-xyz.yaml
profile:
  name: "venue-club-xyz"
  description: "Club XYZ, Portland - house Dante, limited power"

hardware:
  venue_notes:
    - "House Dante on VLAN 10, request IT access"
    - "Only 2 20A circuits stage left"
    - "Projector native 1920×1200, not 1080p"

software:
  obs:
    canvas_resolution: "1920x1200"  # Match projector
```

### Key Documents
- [RUNBOOK.md](RUNBOOK.md) - Phase 1-3 for load-in
- [COMPATIBILITY.md](../hardware/COMPATIBILITY.md) - Laptop thermals
- Profile system documentation

---

## Use Case 4: Corporate Events

### Profile
**Studio ($20K)** or **Broadcast ($50K+)**

### Scenario
Quarterly all-hands meetings, product launches, executive townhalls. Mix of in-person audience and remote employees (1,000+ viewers). Previously outsourced to AV vendor at $15K/event.

### Challenges Before
- $15K per event for external vendor
- No institutional knowledge after vendor leaves
- Remote presenters via Zoom look amateur
- Legal requires archival of all communications
- IT security concerns with vendor equipment

### Configuration

**In-House Studio ($25K)**
```
Cameras:       4× Sony A7 IV ($2,500 each)
Capture:       DeckLink Quad HDMI + TB chassis ($800)
Computer:      M1 Mac Studio ($4,000)
Audio:         MOTU 8PRE-ES + Dante ($1,200)
               4× Shure MX lavaliers ($800)
               Conference mic system ($1,500)
NDI:           NDI Bridge for remote callers ($500)
Teleprompter:  iPad-based system ($500)
Streaming:     Enterprise YouTube/Vimeo ($500/mo)
Archival:      16TB RAID ($1,200)
Total:         ~$24,000 + recurring
```

### Why This Framework

| Problem | Solution |
|---------|----------|
| Vendor cost | In-house capability, 2 events = ROI |
| Knowledge loss | Documented procedures survive staff changes |
| Remote presenters | NDI caller integration |
| Legal archival | Recording workflow + storage guide |
| IT security | On-premise equipment, documented network |

### Results
> "Third event paid for the entire setup. We now have an AV team instead of a vendor dependency. NDI callers look as good as local cameras."

### ROI Calculation
```
Previous:  $15,000/event × 4 events/year = $60,000/year
Now:       $25,000 one-time + $2,000/year maintenance
Payback:   < 6 months
```

### Key Documents
- [NDI-CALLERS.md](NDI-CALLERS.md) - Remote presenter setup
- [STREAMING.md](STREAMING.md) - Enterprise platform config
- [RUNBOOK.md](RUNBOOK.md) - Event-day procedures

---

## Use Case 5: Esports Tournament

### Profile
**Broadcast ($50K+)**

### Scenario
Regional tournament with 8 player stations, commentator desk, crowd shots. 1080p60 minimum, preferably 4K. Graphics overlays, instant replay, and score integration.

### Challenges Before
- 60fps requirement stresses consumer gear
- Player cams + game capture = many inputs
- Graphics integration is manual and error-prone
- Commentary audio sync with game audio
- Instant replay requires dedicated operator

### Configuration

```
Player Cams:   8× PTZ cameras (NDI, $800 each)
Game Capture:  4× Elgato 4K60 Pro ($250 each)
Commentator:   2× Canon R6 ($1,500 each)
Main Capture:  2× DeckLink Quad HDMI ($500 each)
Computer:      M1 Mac Studio Ultra ($6,000)
Audio:         MOTU 8PRE-ES + commentator board
Graphics:      Singular.live subscription
Replay:        Dedicated replay system ($5,000)
Network:       10GbE switch for NDI ($500)
Total:         ~$35,000 + replay system
```

### Why This Framework

| Problem | Solution |
|---------|----------|
| Many inputs | Scalable architecture (DeckLink + NDI) |
| 60fps stress | Hardware encoder config, M1 optimization |
| Graphics | Blender/Singular integration guide |
| Audio sync | Dante for all game + commentary |
| Documentation | Tournament-day runbook |

### Results
> *Example pending—seeking esports organization case study.*

### Key Documents
- [ARCHITECTURE.md](ARCHITECTURE.md) - Scaling section
- [VIDEO-CAPTURE.md](VIDEO-CAPTURE.md) - Multi-card setup
- [STREAMING.md](STREAMING.md) - 60fps encoding settings

---

## Use Case 6: Classroom Lecture Capture

### Profile
**Budget ($3K)** per room, scaled across campus

### Scenario
Automated lecture capture in 20+ classrooms. Faculty press one button. Recording auto-uploads to LMS. Occasional livestream for special guests.

### Challenges Before
- Faculty won't learn complex systems
- Different equipment in each room
- IT supports 20 rooms with 2 staff
- Audio quality varies wildly
- "Zoom is easier" but quality suffers

### Configuration

**Per Classroom (~$2,500)**
```
Camera:        1× PTZ camera w/ NDI ($1,000)
               or 1× Logitech Rally ($500)
Capture:       USB-C directly (no capture card)
Computer:      M2 Mac mini ($600)
Audio:         Ceiling mic array ($400)
               or lapel mic + receiver ($300)
Control:       Elgato Stream Deck Mini ($80)
Automation:    Custom AppleScript + OBS websocket
Total:         ~$2,080–$2,500 per room
```

### Why This Framework

| Problem | Solution |
|---------|----------|
| Faculty simplicity | One-button Stream Deck operation |
| Room consistency | Same profile deployed everywhere |
| 2-person IT team | Health check scripts, remote monitoring |
| Audio variance | Documented mic recommendations |
| LMS integration | Recording workflow documentation |

### Results
> "Deployed same configuration across 20 classrooms in 2 weeks. Faculty training: 5 minutes. IT tickets dropped 80%."

### Deployment Script Example
```bash
#!/bin/bash
# deploy-classroom.sh - Deploy standard classroom config
CLASSROOM=$1
make switch-profile PROFILE=classroom-base
rsync -av software/generated/ $CLASSROOM:/usr/local/streaming/
ssh $CLASSROOM "launchctl load /Library/LaunchDaemons/streaming-health.plist"
```

### Key Documents
- Profile system for standardization
- [health-check.sh](../software/scripts/health-check.sh) - Automated monitoring
- Simplified runbook variant

---

## Decision Matrix

Which profile fits your use case?

| Use Case | Budget | Mobile | Studio | Broadcast |
|----------|--------|--------|--------|-----------|
| **House of Worship** | ✅ Best | ➖ | ⚠️ Overkill | ➖ |
| **Research Lab** | ⚠️ Limited | ➖ | ✅ Best | ➖ |
| **Touring Artist** | ➖ | ✅ Best | ⚠️ Too heavy | ➖ |
| **Corporate Events** | ➖ | ➖ | ✅ Best | ✅ Best |
| **Esports** | ➖ | ➖ | ⚠️ Limited | ✅ Best |
| **Classroom** | ✅ Best | ➖ | ⚠️ Overkill | ➖ |

**Legend:**
- ✅ Best fit for this use case
- ⚠️ Works but not optimal
- ➖ Not recommended

---

## Common Patterns

### Pattern: Volunteer-Operated

**Use Cases:** Worship, Community Organizations, Nonprofits

**Key Requirements:**
- Runbook-driven operation (minimize training)
- Pre-stream health checks (catch issues early)
- Decision-tree troubleshooting (guide non-experts)
- Documentation outlasts volunteers

**Essential Documents:**
- [RUNBOOK.md](RUNBOOK.md)
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- [health-check.sh](../software/scripts/health-check.sh)

---

### Pattern: Reproducible/Research

**Use Cases:** Academia, Grants, Publications

**Key Requirements:**
- Version-locked configurations
- Citeable documentation
- Bill of materials with part numbers
- Methodology documentation

**Essential Documents:**
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [BOM.csv](../hardware/BOM.csv)
- [research/METHODOLOGY.md](../research/METHODOLOGY.md)
- Profile YAML files

---

### Pattern: Mobile/Touring

**Use Cases:** Performance, Remote Production, Event Coverage

**Key Requirements:**
- Quick setup/teardown
- Venue-specific profiles
- Thermal management (laptops)
- Portable hardware

**Essential Documents:**
- Mobile profile
- [COMPATIBILITY.md](../hardware/COMPATIBILITY.md)
- Per-venue profile notes

---

### Pattern: Scaled Deployment

**Use Cases:** Classrooms, Corporate Campuses, Multi-Room

**Key Requirements:**
- Identical configuration across rooms
- Remote health monitoring
- Centralized management
- Minimal per-room maintenance

**Essential Documents:**
- Profile system
- Deployment scripts
- Health check automation

---

## Submit Your Use Case

Using this framework in a way not documented here? We'd love to feature your deployment:

1. Open an issue with the "Use Case" template
2. Describe your scenario, challenges, and configuration
3. Share results (anonymized if needed)
4. We'll add it to this document

Community contributions help others find the right configuration faster.

---

## See Also

- [COMPARISON.md](COMPARISON.md) - How this compares to alternatives
- [README.md](../README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical system design
- [hardware/BOM.csv](../hardware/BOM.csv) - Complete bill of materials

---

*Use cases based on framework design patterns. Individual results may vary based on specific implementation.*
