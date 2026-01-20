# Changelog

All notable changes to this project are documented here.

## [1.0.0] — 2025-01-22 (Initial Release)

### Added
- Full documentation for 4-camera live streaming with Dante audio sync
- DeckLink Quad HDMI compatibility verified on M1 Ultra
- NDI caller integration (tested with remote participants)
- Runbooks, troubleshooting guide, health-check scripts
- GitHub Actions workflow for documentation validation
- Hardware compatibility matrix (3 configurations verified)
- Performance benchmarks (CPU/GPU/latency measurements)
- Open-source repository with CC-BY-4.0 documentation license

### Fixed
- DeckLink driver stability on arm64 (confirmed with v13.2)
- Dante clock drift mitigation via Ableton master clock
- HDMI handshake issues (resolved with Cable specification)

### Known Issues
- DeckLink compatibility with M1 MacBook Air: thermal throttling observed (use external cooling)
- NDI over internet (>200ms latency): use alternative (Zoom audio + NDI video) for remote callers
- MOTU driver on older TB3 enclosures: occasional audio dropout (upgrade firmware)

### Testing
- [x] Hardware compatibility matrix (M1 Ultra, M1 Mac mini pending)
- [x] 2-hour sustained broadcast (zero drops)
- [x] 4 simultaneous NDI callers
- [x] Full Dante network sync at 48 kHz
- [x] Thermal monitoring under sustained load
- [x] Network failover (upstream loss recovery)

---

## Future Roadmap

### [1.1.0] — Q2 2025 (Planned)
- Support for 8-camera capture (dual DeckLink cards)
- Kubernetes containerization for multi-studio deployment
- Cloud backup (S3) integration
- Real-time analytics (viewer count, engagement)
- AES67 audio standard support (alternative to Dante)

### [1.2.0] — Q3 2025 (Planned)
- Blender integration (automated scene composition)
- WebRTC caller support (replace NDI for remote participants)
- Archive workflow (automated post-broadcast editing)
- Machine learning-assisted live switching (AI camera preference model)

### [2.0.0] — Future (Visionary)
- Multi-studio federation (connected buildings via Dante backbone)
- Building-scale reality show infrastructure (10-15 rooms)
- Decentralized streaming (IPFS + blockchain archiving)
- Holographic participant support (future hardware)

---

## How to Report Issues

Found a problem? Open an issue with:
1. Your hardware configuration (see VERSION output)
2. Steps to reproduce
3. Relevant logs (see troubleshooting)

See `.github/ISSUE_TEMPLATE/` for templates.

---

## Deprecation Notices

**None** as of v1.0.0. This is the initial release.

### When we deprecate features:
- We will provide 3-month notice in CHANGELOG
- Suggest migration path to alternative
- Archive deprecated code in `legacy/` folder
- Update all docs pointing to replacement
