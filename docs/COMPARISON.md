# How This Framework Compares

> Understanding when to use this framework vs. alternatives.

**Last Updated:** 2025-01-20
**Version:** 1.0.0

---

## The Core Difference

**This is not a product. It's documentation.**

ATEM, vMix, and Wirecast are tools you buy. OBS is software you download.

This framework is the *knowledge layer* that connects hardware, software, audio networking, and operational procedures into a reproducible system. You still use OBS. You might still own an ATEM. But you'll finally understand how everything fits together.

---

## Quick Decision Guide

| Your Situation | Best Choice |
|----------------|-------------|
| "I need to stream today with $500" | ATEM Mini |
| "I need Windows + PTZ + built-in graphics" | vMix |
| "I'm on Mac with Dante audio infrastructure" | **This Framework** |
| "I need reproducible, documented setups for research" | **This Framework** |
| "I want a turnkey appliance" | ATEM or vMix hardware |
| "I have volunteers who need runbooks" | **This Framework** |

---

## vs. ATEM Mini / ATEM Switchers

**ATEM is hardware-first. This is documentation-first.**

| Aspect | ATEM Mini Pro | This Framework |
|--------|---------------|----------------|
| **Philosophy** | Buy hardware, read manual | Document everything, choose hardware |
| **Audio Sync** | HDMI embedded only | Dante network (broadcast-grade) |
| **Audio Channels** | 2 (stereo embedded) | Unlimited (Dante routing) |
| **Max Inputs** | 4–8 (hardware limit) | Unlimited (NDI, capture cards) |
| **Scaling** | Buy bigger hardware | Add profiles, cards, NDI |
| **Documentation** | Product manual only | 95% operational coverage |
| **Cost** | $295–$6,995 | $3K–$50K+ (your choice) |
| **Reproducibility** | "Same hardware" only | Version-pinned, citeable configs |
| **Volunteers** | "Watch the tutorial" | 8-phase runbook |

### Choose ATEM When:
- Budget under $1,000
- 2–4 cameras with simple audio
- No audio sync requirements (HDMI embedded is fine)
- You want an appliance, not a system
- Setup time: 30 minutes

### Choose This Framework When:
- You have Dante infrastructure
- Audio sync is critical (multiple wireless mics, board feeds)
- You need operational documentation for others
- Research reproducibility matters
- You want to understand *why* things work

### Can I Use Both?
Yes! An ATEM can be one input source into this framework via HDMI or SDI. Common hybrid setup:
- ATEM for quick camera switching
- DeckLink captures ATEM's program output
- Dante handles all audio separately
- Framework provides operational procedures

---

## vs. vMix

**vMix is Windows software. This is macOS ecosystem documentation.**

| Aspect | vMix | This Framework |
|--------|------|----------------|
| **Platform** | Windows only | macOS-native |
| **Audio** | Windows audio / NDI | Dante network |
| **Cost** | $60–$1,200 (software) | Free documentation |
| **Graphics** | Built-in titling | Blender/external |
| **PTZ Control** | Excellent, built-in | Manual/third-party |
| **Replay** | Built-in instant replay | External solution needed |
| **Documentation** | Tutorials, forums | Comprehensive runbooks |
| **Reproducibility** | "Same vMix version" | Full version pinning |

### Choose vMix When:
- You're on Windows
- You need built-in instant replay
- PTZ camera control is primary
- You want one application for everything
- Lower thirds / graphics built-in is important

### Choose This Framework When:
- You're on macOS
- You have existing Dante infrastructure
- You use Ableton/Logic for audio
- You need citable, reproducible configurations
- You prefer modular, best-of-breed components

### vMix + Framework?
If you're on Windows and want the documentation approach, you could adapt the framework:
- Replace OBS references with vMix
- Dante workflow remains the same
- Runbooks would need modification
- Hardware BOM mostly transfers

---

## vs. Wirecast

| Aspect | Wirecast | This Framework |
|--------|----------|----------------|
| **Platform** | Mac + Windows | macOS |
| **Cost** | $599–$799 | Free |
| **Audio** | Basic mixing | Dante + Ableton |
| **Capture** | NDI, webcams, some capture cards | DeckLink + NDI |
| **Graphics** | Built-in | Blender/external |
| **Documentation** | Manual + support | 95% coverage |

### Choose Wirecast When:
- You need cross-platform
- Built-in graphics are sufficient
- Simpler audio requirements
- Budget for commercial software

### Choose This Framework When:
- macOS-only deployment
- Complex audio routing (Dante)
- You prefer OBS ecosystem
- Research/documentation requirements

---

## vs. OBS Alone

**OBS is the video mixer. This framework is everything else.**

### What OBS Provides
- Multi-source video composition
- Encoding (x264, NVENC, Apple VT)
- RTMP streaming
- Local recording
- Scene management
- Basic audio mixing

### What OBS Doesn't Provide
- Hardware selection guidance
- Audio sync architecture
- Network audio routing
- Pre-stream health checks
- Operational runbooks
- Troubleshooting decision trees
- Version compatibility testing
- Reproducibility documentation

### What This Framework Adds

```
┌─────────────────────────────────────────────────────────────────┐
│                    THIS FRAMEWORK PROVIDES                       │
├─────────────────────────────────────────────────────────────────┤
│  Hardware Layer                                                  │
│  └─ Tested BOM ($3K–$50K profiles)                              │
│  └─ Compatibility matrix                                         │
│  └─ Version-pinned drivers                                       │
│                                                                  │
│  Audio Layer                                                     │
│  └─ Dante network design                                         │
│  └─ Clock sync (Ableton master)                                  │
│  └─ Multi-source routing                                         │
│                                                                  │
│  Operations Layer                                                │
│  └─ 8-phase runbook                                              │
│  └─ Pre-stream health checks                                     │
│  └─ Troubleshooting decision trees                               │
│                                                                  │
│  Reproducibility Layer                                           │
│  └─ Profile-based configuration                                  │
│  └─ BibTeX citations                                             │
│  └─ Version lock documentation                                   │
├─────────────────────────────────────────────────────────────────┤
│                      OBS PROVIDES                                │
│  └─ Video mixing                                                 │
│  └─ Encoding                                                     │
│  └─ Streaming                                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Universal Problem We Solve

**Multi-camera streaming isn't a hardware problem. It's a documentation problem.**

You can buy excellent hardware. OBS is free. Dante works beautifully.

But nobody tells you:
- **Which** hardware to buy for your budget
- **How** to connect audio and video
- **Why** things fail and how to fix them
- **What** to check before going live
- **How** to reproduce configurations
- **How** to write runbooks for volunteers

### The "Last Mile" Problem

Most streaming guides cover 80% of the setup:
1. Buy this camera ✓
2. Install OBS ✓
3. Add your scenes ✓
4. Click "Start Streaming" ✓

Then you discover:
- Audio is 3 frames out of sync
- Dante routing makes no sense
- OBS crashes when DeckLink initializes
- Your wireless mics create feedback
- Nobody documented the actual procedure

**We solve the last mile**: from "I have the pieces" to "I can reliably stream."

---

## Why Open Documentation Matters

### 1. Reproducibility for Research

Academic work requires citable sources:

```bibtex
@misc{mcls-framework-2025,
  title = {Multi-Camera Livestream Framework},
  year = {2025},
  url = {https://github.com/...},
  note = {Version 1.0.0, Studio profile}
}
```

Commercial products change versions without notice. This framework version-locks everything.

### 2. Knowledge Transfer

Organizations lose institutional knowledge:
- Key person leaves → nobody knows the setup
- Vendor changes → documentation is obsolete
- Platform updates → previous guides break

Open documentation survives personnel changes.

### 3. Community Evolution

Shared best practices improve everyone:
- Hardware test reports from multiple users
- Troubleshooting tips from real failures
- Profile variations for different use cases
- Alternative vendor configurations

### 4. Volunteer Operations

Houses of worship, universities, and community organizations rely on volunteers:
- Detailed runbooks reduce training time
- Health checks catch issues before live
- Decision trees guide troubleshooting
- Documentation outlasts individual volunteers

---

## Feature Comparison Matrix

| Feature | ATEM Mini | vMix | Wirecast | OBS Alone | This Framework |
|---------|-----------|------|----------|-----------|----------------|
| **Multi-camera** | ✅ 4–8 | ✅ Unlimited | ✅ Varies | ✅ Varies | ✅ 4+ tested |
| **4K support** | ⚠️ Limited | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Audio sync (Dante)** | ❌ No | ⚠️ NDI only | ❌ No | ⚠️ DIY | ✅ Documented |
| **NDI support** | ❌ No | ✅ Excellent | ✅ Yes | ✅ Plugin | ✅ Documented |
| **macOS native** | ✅ Yes | ❌ No | ✅ Yes | ✅ Yes | ✅ Yes |
| **Built-in graphics** | ✅ Basic | ✅ Advanced | ✅ Advanced | ⚠️ Plugin | ⚠️ Blender |
| **Instant replay** | ✅ Yes* | ✅ Yes | ✅ Yes | ⚠️ Plugin | ❌ External |
| **PTZ control** | ⚠️ Via ATEM | ✅ Excellent | ✅ Yes | ⚠️ Plugin | ❌ External |
| **Operational docs** | ❌ Manual | ❌ Tutorials | ❌ Manual | ❌ Wiki | ✅ 95% |
| **Pre-stream checks** | ❌ No | ❌ No | ❌ No | ❌ No | ✅ Scripts |
| **Runbooks** | ❌ No | ❌ No | ❌ No | ❌ No | ✅ 8-phase |
| **Budget profiles** | ❌ Fixed | ❌ Fixed | ❌ Fixed | ❌ Unknown | ✅ 4 profiles |
| **Reproducible** | ⚠️ Hardware | ⚠️ Version | ⚠️ Version | ❌ No | ✅ Citeable |

*ATEM Mini Pro and above

---

## Cost Comparison

| Solution | Entry | Recommended | High-End |
|----------|-------|-------------|----------|
| **ATEM** | $295 (Mini) | $995 (Mini Pro ISO) | $6,995 (4 M/E) |
| **vMix** | $60 (Basic) | $700 (HD) | $1,200 (Pro) |
| **Wirecast** | $599 (Studio) | $799 (Pro) | $799 |
| **OBS** | Free | Free | Free |
| **This Framework** | Free docs + ~$3K hardware | Free docs + ~$20K hardware | Free docs + $50K+ hardware |

**Note:** Framework costs are hardware, not documentation. The value proposition is that you know *which* hardware and *how* to configure it.

---

## Migration Paths

### From ATEM to This Framework
1. Keep ATEM as one input source
2. Add Dante audio infrastructure
3. Use DeckLink for additional cameras
4. Adopt runbook for operations

### From vMix to This Framework
1. Requires switching to macOS
2. Dante workflow transfers directly
3. Replace vMix features with plugins/external tools
4. Adapt runbooks to OBS

### From OBS (Alone) to This Framework
1. Add Dante audio (MOTU + Ableton)
2. Upgrade to DeckLink capture
3. Adopt profile-based configuration
4. Implement health checks and runbooks

---

## Summary

| If You Need... | Choose... | Why |
|----------------|-----------|-----|
| Quick setup under $1K | ATEM Mini | Appliance, works immediately |
| Windows + all-in-one | vMix | Best Windows ecosystem |
| macOS + cross-platform | Wirecast | Commercial support |
| Free mixer software | OBS | Universal standard |
| **Documented, reproducible system** | **This Framework** | **Knowledge + process** |
| **Dante audio sync** | **This Framework** | **Broadcast-grade audio** |
| **Research reproducibility** | **This Framework** | **Citeable configurations** |
| **Volunteer-operated** | **This Framework** | **Runbooks + health checks** |

---

## See Also

- [README.md](../README.md) - Project overview
- [USE-CASES.md](USE-CASES.md) - Real-world deployment scenarios
- [FAQ.md](FAQ.md) - Frequently asked questions
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical system design

---

*This comparison is based on publicly available information as of January 2025. Product features and pricing may change.*
