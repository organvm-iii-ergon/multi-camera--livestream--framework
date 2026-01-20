# Frequently Asked Questions

> Common questions about the Multi-Camera Livestream Framework.

**Last Updated:** 2025-01-20
**Version:** 1.0.0

---

## General

### What is this project?

Multi-Camera Livestream Framework is a documentation and tooling framework for building a professional multi-camera 4K live streaming setup. It provides:

- Hardware specifications and compatibility testing
- Software configuration guides
- Operational runbooks and checklists
- Automation scripts for setup and launch

### Who is this for?

- Multimedia artists
- Academic researchers documenting streaming setups
- Live performance practitioners
- Anyone building a reproducible broadcasting pipeline

### What's the total cost?

The full Bill of Materials (BOM) is approximately **$20,000 USD**. See `hardware/BOM.csv` for detailed pricing.

Key components:
- Mac Studio (~$4,000-6,000)
- DeckLink Quad HDMI + TB chassis (~$800)
- MOTU 8PRE-ES (~$1,200)
- Cameras x4 (~$4,000-8,000)
- Accessories, cables, network gear (~$2,000)

---

## Hardware

### Why Mac Studio instead of a PC?

The M1/M2 Mac Studio offers:
- Excellent thermal performance (quiet operation)
- Native Thunderbolt 3/4 support
- Reliable driver support
- Good balance of CPU, GPU, and memory
- macOS stability for long streaming sessions

A PC build can work but requires more configuration and testing.

### Can I use fewer cameras?

Yes! The pipeline supports 1-4 cameras. Adjust your DeckLink card choice:
- 1-2 cameras: DeckLink Mini Recorder (cheaper)
- 3-4 cameras: DeckLink Quad HDMI (documented setup)

### Why Dante for audio instead of USB/Thunderbolt?

Dante advantages:
- Low, consistent latency
- Long cable runs (Ethernet vs. USB limits)
- Network redundancy options
- Scalable to many channels
- Industry standard for pro audio

### Do I need the Thunderbolt chassis?

Yes, for internal PCIe cards like the DeckLink Quad HDMI. Alternatives:
- USB capture devices (lower quality, higher latency)
- Built-in capture (webcam quality)
- Mac Pro with PCIe slots (much higher cost)

### What cameras work?

Any camera with **clean HDMI output** (no overlays):
- Mirrorless cameras (Sony, Canon, Panasonic)
- Camcorders
- PTZ cameras
- Action cameras (GoPro with HDMI adapter)

Check camera manual for "HDMI output settings" - you need to disable on-screen display.

---

## Software

### Why OBS instead of vMix/Wirecast/etc?

OBS is:
- Free and open source
- Actively maintained
- Highly extensible (plugins)
- Well-documented
- Cross-platform

Commercial alternatives may offer more features but aren't necessary for most setups.

### Why Ableton for audio instead of mixing in OBS?

Ableton provides:
- Professional-grade audio processing
- Dante clock master capability
- Complex routing options
- Live performance features
- Plugin support (VST/AU)

OBS audio mixing is limited. For simple setups, you could skip Ableton.

### Can I use Logic Pro or another DAW?

Yes, but you'll need to:
- Handle clock sync differently (Logic isn't Dante-native)
- Use Dante Virtual Soundcard
- Adjust the documented workflows

Ableton + MOTU is the tested, documented path.

### How do I update software without breaking things?

1. Never update on show day
2. Test updates on a non-production day
3. Keep installers for previous versions
4. Update VERSION_LOCK after successful testing
5. Document any issues in CHANGELOG.md

---

## Streaming

### What resolution should I stream at?

For most internet connections and platforms:
- **Recommended**: 1080p60 at 6000 kbps
- **Alternative**: 1080p30 at 4500 kbps
- **4K**: Only if you have 25+ Mbps upload

### Why am I dropping frames?

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#dropped-frames). Common causes:
- Network can't sustain bitrate → Lower bitrate
- CPU overloaded → Use hardware encoder
- GPU overloaded → Simplify scenes

### Can I stream to multiple platforms?

Yes, options include:
1. OBS Multiple RTMP plugin (uses more bandwidth)
2. Restreaming service (Restream.io, Castr)
3. Self-hosted nginx RTMP relay

### What's the maximum stream length?

No technical limit from this setup. Considerations:
- Platform limits (YouTube: 12 hours continuous)
- Storage for local recording
- Thermal management over long sessions
- Human endurance 😊

---

## Networking

### Do I need a dedicated Dante network?

Strongly recommended. Dante can share a network but:
- Quality of Service (QoS) becomes critical
- Other traffic can cause dropouts
- Troubleshooting is harder

A simple gigabit switch for Dante devices is inexpensive insurance.

### Can remote guests join via NDI?

Yes! See [NDI-CALLERS.md](NDI-CALLERS.md) for setup. Requirements:
- VPN or NDI Bridge for WAN
- Good upload speed (10+ Mbps) from caller
- NDI software on caller's machine

### What upload speed do I need?

| Stream Quality | Upload Needed |
|----------------|---------------|
| 720p30 | 5+ Mbps |
| 1080p30 | 8+ Mbps |
| 1080p60 | 12+ Mbps |
| 4K30 | 25+ Mbps |

Always have 30-50% headroom above your streaming bitrate.

---

## Troubleshooting

### OBS says "No signal" for my camera

1. Check camera is on and outputting HDMI
2. Check HDMI cable connections
3. Check Desktop Video Setup for signal
4. Verify camera format matches OBS source settings
5. See [VIDEO-CAPTURE.md](VIDEO-CAPTURE.md#troubleshooting)

### I can't hear audio

1. Check MOTU is powered and detected
2. Check Dante Controller routing
3. Check Ableton input/output settings
4. Check virtual audio cable to OBS
5. See [AUDIO-DANTE.md](AUDIO-DANTE.md#troubleshooting)

### My stream keeps disconnecting

1. Use wired Ethernet (not WiFi)
2. Lower bitrate
3. Check upload speed
4. Try different RTMP server
5. See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#stream-disconnection)

### Where are the logs?

| Application | Log Location |
|-------------|--------------|
| OBS | `~/Library/Application Support/obs-studio/logs/` |
| macOS | Console.app |
| Dante | Dante Controller → Help → View Logs |

---

## Scripts

### What do the scripts do?

| Script | Purpose |
|--------|---------|
| `setup-macos.sh` | Verify system requirements and installations |
| `health-check.sh` | Pre-stream hardware/software verification |
| `launch-studio.sh` | Launch all apps in correct order |
| `shutdown-studio.sh` | Gracefully close all apps |

### Are the scripts safe to run?

Yes. The scripts:
- Only read system information
- Don't modify system settings
- Don't require sudo (except Homebrew install)
- Can be run repeatedly without side effects

### Can I customize the scripts?

Absolutely! They're designed as starting points. Common customizations:
- Add your specific camera names
- Adjust launch order
- Add custom health checks
- Integrate with your automation tools

---

## Contributing

### How can I contribute?

1. Test the setup and report issues
2. Document your hardware configurations in COMPATIBILITY.md
3. Submit improvements via pull request
4. Share your customizations

### I found a bug, where do I report it?

Open an issue on GitHub with:
- What you expected
- What happened
- Steps to reproduce
- System information (macOS version, hardware)

### Can I use this for commercial streams?

Yes! The documentation is provided as-is. You're responsible for:
- Your own licensing (OBS is GPL, Ableton/plugins have their own licenses)
- Platform terms of service compliance
- Any applicable broadcasting regulations

---

## Miscellaneous

### Why this framework?

This framework was created to provide a reproducible, well-documented approach to multi-camera live streaming. It captures the knowledge and lessons learned from building professional streaming setups.

### Is there a Discord/community?

<!-- TODO: Add community links if applicable -->

### Can I hire someone to set this up for me?

<!-- TODO: Add consultant/integrator recommendations if applicable -->

---

## Comparisons

### How is this different from ATEM Mini?

**ATEM is hardware-first. This framework is documentation-first.**

ATEM Mini is an excellent hardware switcher for simple setups under $1,000. This framework provides the knowledge layer for more complex deployments—Dante audio sync, operational runbooks, reproducible configurations.

Choose ATEM for: 2–4 cameras, simple audio, quick setup, appliance approach.
Choose this framework for: Dante infrastructure, volunteer operations, research reproducibility.

See [COMPARISON.md](COMPARISON.md#vs-atem-mini--atem-switchers) for detailed comparison.

### How is this different from vMix?

**vMix is Windows software. This framework is macOS ecosystem documentation.**

vMix is a powerful Windows-only application with built-in graphics, replay, and PTZ control. This framework is macOS-native with Dante audio networking and modular components.

Choose vMix for: Windows environment, built-in instant replay, excellent PTZ control.
Choose this framework for: macOS, Dante infrastructure, research context.

See [COMPARISON.md](COMPARISON.md#vs-vmix) for detailed comparison.

### Why would I use this instead of just OBS?

**OBS is the video mixer. This framework is everything else.**

OBS handles video composition, encoding, and streaming. This framework adds:
- Hardware selection guidance (tested BOM)
- Audio sync architecture (Dante)
- Operational runbooks (8-phase checklist)
- Pre-stream health checks (scripts)
- Troubleshooting decision trees
- Reproducibility documentation (version locking)

See [COMPARISON.md](COMPARISON.md#vs-obs-alone) for detailed comparison.

### Why is open-source documentation important?

Open documentation provides:

1. **Reproducibility** — Citeable configurations for research
2. **Knowledge transfer** — Survives personnel changes
3. **Community evolution** — Shared best practices improve everyone
4. **Volunteer operations** — Runbooks reduce training time

Commercial products update without notice and documentation disappears. This framework version-locks everything.

See [COMPARISON.md](COMPARISON.md#why-open-documentation-matters) for full discussion.

### What budget profiles are available?

| Profile | Budget | Best For |
|---------|--------|----------|
| **Budget** | ~$3K | Worship, education, simple setups |
| **Mobile** | ~$8K | Touring, portable production |
| **Studio** | ~$20K | Research, corporate, full-featured |
| **Broadcast** | $50K+ | Esports, enterprise, multi-room |

See [USE-CASES.md](USE-CASES.md) for how each profile fits different scenarios.

---

## See Also

- [README.md](../README.md) - Project overview
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Detailed troubleshooting
- [docs/](.) - All documentation

---

*Document maintained by Multi-Camera Livestream Framework team*
