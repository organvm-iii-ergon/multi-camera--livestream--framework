# Live Streaming Pipeline: Multi-Camera 4K with Dante Audio Sync

**Status**: Tested and verified on M1 Mac Ultra (Jan 2025)

## Overview

A reproducible, modular system for live-streaming multi-camera productions with synchronized audio via Dante, low-latency NDI caller integration, and professional-grade OBS control. Designed for multimedia artists, academic researchers, and live performance practitioners.

### Key Features

- **4K simultaneous capture** from DSLR/mirrorless cameras via DeckLink Quad HDMI
- **Audio-sync via Dante**: All audio sources locked to Ableton Live master clock
- **Low-latency caller integration**: NDI protocol for <200ms interactivity
- **Full documentation**: Hardware specs, runbooks, troubleshooting, reproducibility notes
- **Open-source tooling**: OBS, Ableton Live, Blender, Dante Controller (free/open components where possible)

## Quick Start

### Prerequisites
- macOS 13.0+ (tested on 14.2.1)
- M1 Mac Studio or equivalent (M1 Ultra recommended)
- 128GB RAM, 1TB SSD
- Gigabit Ethernet + separate Dante-managed switch

### Installation (5 min)

```bash
git clone https://github.com/yourusername/live-streaming-pipeline.git
cd live-streaming-pipeline

# Run setup script
bash software/scripts/setup-macos.sh

# Read architecture overview
open docs/ARCHITECTURE.md
```

### First Broadcast (Within 1 week)

1. **Day 1–2**: Verify hardware compatibility ([hardware/COMPATIBILITY.md](hardware/COMPATIBILITY.md))
2. **Day 3–4**: Configure Dante network ([docs/AUDIO-DANTE.md](docs/AUDIO-DANTE.md))
3. **Day 5**: Full dry-run (Runbook in [docs/RUNBOOK.md](docs/RUNBOOK.md))
4. **Day 6–7**: Go live with recording (no external streaming)

## Documentation Index

| Document | Purpose |
|----------|---------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System design, signal flow, scaling |
| [BOM.csv](hardware/BOM.csv) | Bill of materials (~$20k system) |
| [COMPATIBILITY.md](hardware/COMPATIBILITY.md) | Hardware test matrix, vendor notes |
| [SOFTWARE.md](docs/SOFTWARE.md) | Versions, installation, dependencies |
| [AUDIO-DANTE.md](docs/AUDIO-DANTE.md) | Dante setup, clock sync, latency |
| [VIDEO-CAPTURE.md](docs/VIDEO-CAPTURE.md) | DeckLink, HDMI, camera settings |
| [NDI-CALLERS.md](docs/NDI-CALLERS.md) | Caller onboarding, network setup |
| [STREAMING.md](docs/STREAMING.md) | RTMP platform configuration |
| [RUNBOOK.md](docs/RUNBOOK.md) | Pre-stream checklist, operation |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Decision-tree troubleshooting |
| [FAQ.md](docs/FAQ.md) | Frequently asked questions |

## System Requirements

| Component | Spec |
|-----------|------|
| **Computer** | M1 Mac Studio (20-core CPU, 64-core GPU, 128GB RAM) |
| **Video Capture** | Blackmagic DeckLink Quad HDMI + Echo Express SE I |
| **Audio Interface** | MOTU 8PRE-ES (Dante-enabled) |
| **Network** | Dedicated Dante switch + gigabit Ethernet |
| **Storage** | >100GB free (for recording buffer + OS) |

## Verified Hardware Combinations

| Computer | DeckLink | Driver | Status |
|----------|----------|--------|--------|
| M1 Mac Studio (14.2.1) | Quad HDMI | 13.2 arm64 | ✅ Verified (Jan 2025) |
| M1 MacBook Air | Quad HDMI | 13.2 arm64 | ⚠️ Partial (thermal throttle likely) |
| M1 Mac mini | Quad HDMI | 13.2 arm64 | ⏳ Testing in progress |

See [hardware/COMPATIBILITY.md](hardware/COMPATIBILITY.md) for full matrix.

## Key Statistics

- **Max simultaneous cameras**: 4 (tested), expandable to 8 (with second DeckLink)
- **Latency (capture→stream)**: 2–3 sec (RTMP platform-dependent)
- **Latency (caller return)**: <200ms (Dante local), <500ms (WebRTC remote)
- **Sustained CPU load**: 40–60% (M1 Ultra under full load)
- **Upstream bandwidth required**: 25–50 Mbps (codec-dependent)

## Usage Example

```bash
# 1. Check system health
bash software/scripts/health-check.sh

# 2. Start the pipeline
bash software/scripts/launch-studio.sh

# 3. Follow the pre-stream checklist
open docs/RUNBOOK.md

# 4. Go live (OBS → RTMP → YouTube/Twitch)
# (see docs/STREAMING.md for platform-specific setup)

# 5. Shutdown gracefully
bash software/scripts/shutdown-studio.sh
```

## Contributing

This is a **living documentation project**. Contributions welcome:

- Report hardware compatibility issues (see [Issue Templates](.github/ISSUE_TEMPLATE/))
- Submit hardware test results via [Hardware Compatibility template](.github/ISSUE_TEMPLATE/hardware_compatibility.md)
- Suggest improvements via [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md)
- Share your own broadcast experiences (in `examples/`)
- Improve documentation clarity

All pull requests should follow the [PR template](.github/pull_request_template.md).

## Scholarly Citation

If you use or extend this project, cite as:

```bibtex
@misc{streaming-pipeline-2025,
  author = {Your Name},
  title = {Live Streaming Pipeline: Multi-Camera 4K with Dante Audio Sync},
  year = {2025},
  url = {https://github.com/yourusername/live-streaming-pipeline},
  note = {Open-source documentation and reproducible setup}
}
```

## License

Documentation: CC-BY-4.0 (Creative Commons Attribution)
Code/Scripts: MIT

See [LICENSE](LICENSE) for full terms.

## Contact & Support

- **Issues**: GitHub Issues (link to template)
- **Discussions**: GitHub Discussions (for non-urgent Q&A)
- **Email**: your.email@example.com

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release notes and breaking changes.

---

**Last Updated**: 2025-01-22
**Maintainer**: Your Name
**Status**: Production-ready
