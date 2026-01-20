# Software Installation & Configuration

> Version-pinned software installation guide for the Multi-Camera Livestream Framework.

**Generated from profile:** studio
**Last Updated:** 2026-01-20
**Version:** 1.0.0

---

## Table of Contents

1. [Overview](#overview)
2. [System Requirements](#system-requirements)
3. [Version Pinning](#version-pinning)
4. [Installation Guide](#installation-guide)
5. [Configuration Files](#configuration-files)
6. [Updates & Maintenance](#updates--maintenance)

---

## Overview

This document provides the definitive software installation guide for the Multi-Camera Livestream Framework. All software versions are **pinned** for reproducibility—do not upgrade without testing in a non-production environment.

### Software Stack

| Category | Software | Version | Purpose |
|----------|----------|---------|---------|
| Video Mixing | OBS Studio | 29.1.3 | Main production switcher |
| Audio Mixing | Ableton Live | 12.0.10 | DAW, Dante clock master |
| Audio Network | Dante Controller | 4.5.3 | Dante routing |
| Video Capture | Desktop Video | 13.2 | DeckLink drivers |
| Audio Interface | MOTU Drivers | 2.23.5 | 8PRE-ES support |
| Graphics | Blender (optional) | - | Real-time graphics |

---

## System Requirements

### Hardware Requirements

| Component | Current Setup |
|-----------|---------------|
| Computer | Mac Studio |
| Chip | M1 Ultra |
| RAM | 128GB |
| Video Capture | Blackmagic Design DeckLink Quad HDMI |
| Audio Interface | MOTU 8PRE-ES |
| Thunderbolt Chassis | Echo Express SE I |

### macOS Requirements

| Requirement | Version |
|-------------|---------|
| macOS | 13.0+ (Ventura) |
| Current OS | 14.2.1 (Sonoma) |

> ⚠️ Do not upgrade macOS without verifying driver compatibility.

---

## Version Pinning

### Current Pinned Versions

These versions are tested and known to work together:

| Software | Version | Bundle ID |
|----------|---------|-----------|
| macOS | 14.2.1 | - |
| OBS Studio | 29.1.3 | `com.obsproject.obs-studio` |
| Ableton Live | 12.0.10 | `com.ableton.live` |
| Dante Controller | 4.5.3 | `com.audinate.dante.DanteController` |
| Desktop Video (DeckLink) | 13.2 | - |
| MOTU Drivers | 2.23.5 | - |

---

## Installation Guide

### 1. macOS Preparation

```bash
# Check current macOS version
sw_vers -productVersion
# Expected: 14.2.1 or compatible

# Verify Apple Silicon
uname -m
# Expected: arm64
```

### 2. Install Required Applications

1. **OBS Studio** v29.1.3
   - Role: Video mixing, encoding, streaming
   - Download from official source

2. **Ableton Live** v12.0.10
   - Role: Audio mixing, Dante clock master
   - Download from official source

3. **Dante Controller** v4.5.3
   - Role: Audio network routing and monitoring
   - Download from Audinate

### 3. Install Hardware Drivers

1. **Blackmagic Design Desktop Video** v13.2
   - For DeckLink Quad HDMI
   - Architecture: arm64

2. **MOTU Drivers** v2.23.5
   - For 8PRE-ES

---

## Configuration Files

Configuration is managed via the profile system. Current profile: **studio**

```bash
# View current configuration
cat software/generated/config.sh

# Switch profiles
./software/scripts/generate-config.sh [profile_name]
```

---

## Updates & Maintenance

Before updating any software:

1. Test in non-production environment
2. Verify all drivers are compatible
3. Update the profile YAML if versions change
4. Regenerate config: `./software/scripts/generate-config.sh`
5. Regenerate docs: `make docs`
