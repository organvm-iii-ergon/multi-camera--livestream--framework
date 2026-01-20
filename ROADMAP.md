# Roadmap

> Where this framework is going—and how to get involved.

**Last Updated:** 2025-01-20
**Version:** 1.0.0

---

## Vision Statement

**Make professional multi-camera streaming accessible with documentation so complete that a volunteer can set it up.**

The streaming industry has excellent hardware and free software. What's missing is the connective tissue: how to select hardware for your budget, how to configure audio sync, how to operate reliably, and how to document it all for reproducibility.

This framework fills that gap.

---

## Current Status: v1.0.0

### What's Complete
- ✅ Core documentation (Architecture, Runbook, Troubleshooting)
- ✅ Profile-based configuration system (YAML → shell/JSON)
- ✅ Shell scripts (setup, health-check, launch, shutdown)
- ✅ Hardware documentation (BOM, Compatibility matrix)
- ✅ Studio profile (M1 Mac Studio + DeckLink + Dante)
- ✅ Research documentation (Methodology, citations)
- ✅ GitHub templates (Issues, PRs, Hardware reports)

### What's In Progress
- 🔄 Additional hardware profiles (Budget, Mobile, Broadcast)
- 🔄 Community hardware test reports
- 🔄 Video walkthrough documentation

---

## Q1 2025 — Foundation

### Documentation
| Task | Status | Notes |
|------|--------|-------|
| README rewrite (value-first) | ✅ Done | Strategic positioning |
| USE-CASES.md | ✅ Done | 6 deployment scenarios |
| COMPARISON.md | ✅ Done | vs. ATEM, vMix, etc. |
| ROADMAP.md | ✅ Done | This document |
| Video walkthrough (YouTube) | ⏳ Planned | 15-min overview |
| Quick-start video | ⏳ Planned | 5-min first stream |

### Profiles
| Task | Status | Notes |
|------|--------|-------|
| Studio profile validation | ✅ Done | M1 Ultra verified |
| Budget profile ($3K) | ⏳ Planned | M2 Mac mini + USB capture |
| Mobile profile ($8K) | ⏳ Planned | MacBook Pro + portable gear |
| Education profile | ⏳ Planned | Classroom deployment |

### Testing
| Task | Status | Notes |
|------|--------|-------|
| M1 Mac Studio testing | ✅ Done | Primary verification |
| M2 Mac mini testing | ⏳ Planned | Budget profile |
| M3 MacBook Pro testing | ⏳ Planned | Mobile profile |
| 10+ community hardware reports | ⏳ Planned | Diverse configurations |

### Community
| Task | Status | Notes |
|------|--------|-------|
| GitHub Discussions enabled | ⏳ Planned | Q&A, Show Your Setup |
| "Show Your Setup" template | ⏳ Planned | Community gallery |
| Contributing guide | ⏳ Planned | How to add profiles |
| First external contributor | ⏳ Goal | Community validation |

---

## Q2 2025 — Expansion

### Hardware Support
| Task | Priority | Notes |
|------|----------|-------|
| 8-camera support | High | Dual DeckLink configuration |
| AJA capture card testing | Medium | Alternative to Blackmagic |
| Elgato HD60 X testing | Medium | Budget capture option |
| PTZ camera guide | Medium | NDI PTZ integration |
| ATEM as input source | Low | Hybrid configurations |

### Software
| Task | Priority | Notes |
|------|----------|-------|
| OBS 30.x compatibility | High | Version-lock update |
| macOS 15 (Sequoia) testing | High | Driver compatibility |
| vMix profile (Windows) | Medium | Community requested |
| Reaper DAW alternative | Low | Open-source audio option |

### Audio
| Task | Priority | Notes |
|------|----------|-------|
| AES67 support documentation | Medium | Alternative to Dante |
| Behringer X32 Dante guide | Medium | Popular mixer integration |
| Focusrite RedNet guide | Low | Alternative Dante interface |
| Wireless mic shootout | Low | Comparison of options |

### NDI
| Task | Priority | Notes |
|------|----------|-------|
| NDI 6 compatibility | High | Version update |
| NDI Bridge setup guide | Medium | Remote production |
| NDI|HX camera testing | Low | Consumer NDI cameras |

---

## Q3 2025 — Automation & Graphics

### Automation
| Task | Priority | Notes |
|------|----------|-------|
| Auto-switching (audio levels) | High | OBS Advanced Scene Switcher |
| Health monitoring daemon | High | Background service |
| Slack/Discord alerts | Medium | Stream status notifications |
| Calendar integration | Medium | Scheduled stream automation |
| Tally light control | Low | On-air indicators |

### Graphics
| Task | Priority | Notes |
|------|----------|-------|
| Lower thirds library | High | OBS browser sources |
| Singular.live integration | Medium | Cloud graphics |
| Score overlay (esports) | Medium | Game integration |
| Blender workflow refinement | Low | 3D graphics pipeline |

### Remote Production
| Task | Priority | Notes |
|------|----------|-------|
| WebRTC caller guide | High | Browser-based guests |
| SRT contribution guide | Medium | Long-distance feeds |
| Multi-site federation | Low | Connecting studios |

---

## Q4 2025 — Scale & Analytics

### Infrastructure
| Task | Priority | Notes |
|------|----------|-------|
| Multi-room deployment guide | High | Campus/enterprise |
| Docker containerization | Medium | Portable services |
| AWS/GCP streaming guide | Medium | Cloud transcoding |
| Kubernetes orchestration | Low | Enterprise scale |

### Analytics & Monitoring
| Task | Priority | Notes |
|------|----------|-------|
| Stream quality dashboard | High | Real-time metrics |
| Post-broadcast reports | Medium | Automated summaries |
| Viewer analytics integration | Low | Platform APIs |
| Long-term trend analysis | Low | Historical data |

### Reliability
| Task | Priority | Notes |
|------|----------|-------|
| Failover configuration | High | Backup streaming |
| Redundant encoding | Medium | Dual-encoder setup |
| UPS integration | Low | Power monitoring |

---

## 2026 and Beyond — Vision

### Long-Term Goals

| Goal | Timeline | Notes |
|------|----------|-------|
| Multi-studio federation | 2026 | Connect 10-15 rooms |
| AI camera selection | 2026+ | Automatic switching hints |
| SMPTE 2110 support | 2026+ | Broadcast standard IP |
| Linux profile | 2026+ | Ubuntu-based deployments |
| ARM Windows (Snapdragon) | TBD | When ecosystem matures |

### Research Directions
- Real-time quality assessment algorithms
- Automated troubleshooting via ML
- Viewer engagement correlation
- Latency optimization research

### Community Growth
- Regional user groups
- Annual virtual summit
- Certification program (maybe)
- Integration partnerships

---

## Community Milestones

| Milestone | Target | Status |
|-----------|--------|--------|
| First external contributor | Q1 2025 | ⏳ |
| 25 GitHub stars | Q1 2025 | ⏳ |
| 10 hardware reports submitted | Q2 2025 | ⏳ |
| 100 GitHub stars | Q2 2025 | ⏳ |
| First academic citation | Q4 2025 | ⏳ |
| 25 hardware reports submitted | Q4 2025 | ⏳ |
| First non-English translation | 2026 | ⏳ |
| 500 GitHub stars | 2026 | ⏳ |
| First conference presentation | 2026 | ⏳ |
| 1,000 GitHub stars | 2026+ | ⏳ |

---

## How to Contribute

### Immediate Needs

1. **Hardware Testing**
   - Test your setup, submit a hardware compatibility report
   - Template: `.github/ISSUE_TEMPLATE/hardware_compatibility.md`

2. **Documentation Review**
   - Find unclear sections, suggest improvements
   - Open an issue with specific feedback

3. **Profile Development**
   - Create profiles for untested configurations
   - Submit as PR with testing notes

### Medium-Term Contributions

4. **Video Content**
   - Record walkthrough of your setup
   - Create troubleshooting tutorials

5. **Alternative Hardware**
   - Test non-Blackmagic capture cards
   - Document non-MOTU Dante interfaces

6. **Platform Guides**
   - Write guides for specific streaming platforms
   - Document enterprise configurations

### Long-Term Contributions

7. **Translation**
   - Translate core documentation
   - Maintain localized versions

8. **Tool Development**
   - Build monitoring dashboards
   - Create automation scripts

9. **Research**
   - Academic papers using the framework
   - Performance benchmarking

---

## Versioning Strategy

### Semantic Versioning

```
MAJOR.MINOR.PATCH

MAJOR: Breaking changes to profiles or scripts
MINOR: New features, new profiles, new documentation
PATCH: Bug fixes, clarifications, minor updates
```

### Planned Releases

| Version | Target | Scope |
|---------|--------|-------|
| 1.1.0 | Q2 2025 | Budget + Mobile profiles |
| 1.2.0 | Q3 2025 | OBS 30.x, macOS 15 compatibility |
| 1.3.0 | Q4 2025 | Automation features |
| 2.0.0 | 2026 | Major architecture updates |

---

## Deprecation Policy

When features or configurations are deprecated:

1. **Announcement**: Noted in CHANGELOG with migration path
2. **Grace Period**: At least one minor version before removal
3. **Documentation**: Old docs moved to `archive/` directory
4. **Profiles**: Deprecated profiles marked clearly

---

## Feedback

This roadmap is a living document. To influence priorities:

1. **Vote on Issues**: 👍 issues you care about
2. **Open Feature Requests**: Use the feature request template
3. **Start Discussions**: GitHub Discussions for broader topics
4. **Submit PRs**: Code/docs contributions welcome

We prioritize based on:
- Community demand (issue votes, discussion activity)
- Strategic alignment with vision
- Contributor availability
- Technical feasibility

---

## See Also

- [README.md](README.md) - Project overview
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [CONTRIBUTING.md](.github/CONTRIBUTING.md) - Contribution guidelines
- [docs/USE-CASES.md](docs/USE-CASES.md) - Real-world deployments

---

*Roadmap reflects current planning and is subject to change based on community feedback and contributor availability.*
