# Software Installation & Configuration

> Version-pinned software installation guide for the Multi-Camera Livestream Framework.

**Last Updated:** <!-- TODO: Update date -->
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

| Category | Software | Purpose |
|----------|----------|---------|
| Video Mixing | OBS Studio | Main production switcher |
| Audio Mixing | Ableton Live | DAW, Dante clock master |
| Audio Network | Dante Controller | Dante routing |
| Video Capture | Desktop Video | DeckLink drivers |
| Audio Interface | MOTU Drivers | MOTU 8PRE-ES support |
| Graphics | Blender (optional) | Real-time graphics |

---

## System Requirements

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | Apple M1 | Apple M1 Pro/Max/Ultra |
| RAM | 32GB | 64GB+ |
| Storage | 512GB SSD | 1TB+ NVMe |
| GPU | Integrated | Dedicated (via TB) |
| Network | Gigabit Ethernet | 10GbE for heavy NDI |

### macOS Requirements

| Requirement | Version |
|-------------|---------|
| macOS | 13.0+ (Ventura) |
| Recommended | 14.x (Sonoma) |
| **Pinned Version** | **14.2.1** |

> ⚠️ Do not upgrade macOS without verifying driver compatibility.

---

## Version Pinning

### Current Pinned Versions

These versions are tested and known to work together:

| Software | Version | Release Date | Download |
|----------|---------|--------------|----------|
| macOS | 14.2.1 | Dec 2023 | System Update |
| OBS Studio | 29.1.3 | Aug 2023 | [GitHub](https://github.com/obsproject/obs-studio/releases/tag/29.1.3) |
| Ableton Live | 12.0.10 | <!-- TODO --> | Ableton Account |
| Dante Controller | 4.5.3 | <!-- TODO --> | [Audinate](https://www.audinate.com/products/software/dante-controller) |
| Desktop Video | 13.2 (arm64) | <!-- TODO --> | [Blackmagic](https://www.blackmagicdesign.com/support) |
| MOTU Drivers | 2.23.5 | <!-- TODO --> | [MOTU](https://motu.com/download) |
| NDI Tools | 5.5.x | <!-- TODO --> | [NDI](https://ndi.tv/tools/) |
| Blender | 4.0.x | <!-- TODO --> | [Blender](https://www.blender.org/download/) |

### Version Lock File

Create a version lock file for automated verification:

```bash
# software/VERSION_LOCK
MACOS_VERSION=14.2.1
OBS_VERSION=29.1.3
ABLETON_VERSION=12.0.10
DANTE_CONTROLLER_VERSION=4.5.3
DECKLINK_DRIVER_VERSION=13.2
MOTU_DRIVER_VERSION=2.23.5
```

---

## Installation Guide

### 1. macOS Preparation

```bash
# Check current macOS version
sw_vers -productVersion

# Disable automatic updates (prevent unexpected changes)
sudo softwareupdate --set-auto-update-check off
```

### 2. Install Homebrew (Recommended)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# For Apple Silicon, add to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

### 3. Install OBS Studio

**Option A: Direct Download (Recommended for version pinning)**
1. Download OBS 29.1.3 from [GitHub Releases](https://github.com/obsproject/obs-studio/releases/tag/29.1.3)
2. Choose `obs-studio-29.1.3-macos-arm64.dmg`
3. Mount DMG and drag to Applications

**Option B: Homebrew**
```bash
# Note: This installs latest, not pinned version
brew install --cask obs
```

**Post-install:**
```bash
# Verify installation
ls -la /Applications/OBS.app
```

### 4. Install Ableton Live

1. Log into [Ableton Account](https://www.ableton.com/account/)
2. Download Ableton Live 12.0.10 installer
3. Run installer
4. Authorize using your license

**Configuration:**
- Preferences → Audio → Driver: CoreAudio
- Preferences → Audio → Device: Dante Virtual Soundcard (or MOTU)

### 5. Install Dante Controller

1. Create account at [Audinate](https://www.audinate.com/)
2. Download Dante Controller 4.5.3 for macOS
3. Install the package
4. Grant necessary permissions (System Preferences → Privacy)

### 6. Install Blackmagic Desktop Video

1. Download from [Blackmagic Support](https://www.blackmagicdesign.com/support/family/capture-and-playback)
2. Select "Desktop Video" for your DeckLink card
3. Download version 13.2 (arm64)
4. Install (requires restart)

**Verify:**
```bash
system_profiler SPPCIDataType | grep -i blackmagic
```

### 7. Install MOTU Drivers

1. Download from [MOTU Downloads](https://motu.com/download)
2. Select "MOTU Pro Audio Installer" for macOS
3. Version: 2.23.5
4. Install and restart

**Verify:**
```bash
ls /Library/PreferencePanes/ | grep -i motu
```

### 8. Install NDI Tools (Optional)

1. Download from [NDI Tools](https://ndi.tv/tools/)
2. Install NDI Tools package
3. Install OBS NDI Plugin separately:
   - Download from [obs-ndi releases](https://github.com/obs-ndi/obs-ndi/releases)
   - Install the .pkg file
   - Restart OBS

### 9. Install Blender (Optional)

```bash
# Via Homebrew
brew install --cask blender

# Or direct download from blender.org
```

---

## Configuration Files

### Directory Structure

```
software/configs/
├── obs/
│   ├── basic/
│   │   ├── profiles/
│   │   │   └── Livestream/
│   │   │       └── basic.ini
│   │   └── scenes/
│   │       └── Livestream.json
│   └── plugin_config/
├── ableton/
│   └── templates/
│       └── Livestream-Template.als
├── dante/
│   └── routing-preset.xml
└── blender/
    └── overlays/
```

### OBS Configuration Location

macOS default:
```
~/Library/Application Support/obs-studio/
```

### Ableton Configuration Location

macOS default:
```
~/Library/Preferences/Ableton/
~/Music/Ableton/User Library/
```

### Backing Up Configurations

```bash
# Backup script (add to cron or run manually)
BACKUP_DIR="$HOME/Backups/streaming-configs-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# OBS
cp -r ~/Library/Application\ Support/obs-studio/ "$BACKUP_DIR/obs-studio/"

# Ableton (preferences only)
cp -r ~/Library/Preferences/Ableton/ "$BACKUP_DIR/ableton-prefs/"
```

---

## Updates & Maintenance

### Update Policy

1. **Never update software on show day**
2. Test updates in non-production environment first
3. Document any version changes in CHANGELOG.md
4. Update VERSION_LOCK file after successful testing

### Checking for Updates

```bash
# Homebrew packages
brew outdated

# Check OBS version
/Applications/OBS.app/Contents/MacOS/OBS --version

# Check macOS version
sw_vers
```

### Rollback Procedure

If an update causes issues:

1. **OBS**: Keep previous DMG, reinstall older version
2. **Ableton**: Download older version from Ableton account
3. **Drivers**: Keep installer packages, reinstall from archive
4. **macOS**: Use Time Machine or APFS snapshot

### Creating a System Snapshot

Before major updates:

```bash
# Create APFS snapshot (requires admin)
sudo tmutil localsnapshot

# List snapshots
tmutil listlocalsnapshots /
```

---

## Verification Script

Run after installation to verify setup:

```bash
# software/scripts/setup-macos.sh handles this
./software/scripts/setup-macos.sh
```

### Manual Verification

```bash
# macOS version
sw_vers -productVersion

# OBS installed
ls /Applications/OBS.app

# Ableton installed
ls /Applications/Ableton\ Live*

# Dante Controller
ls /Applications/Dante\ Controller.app

# DeckLink driver
kextstat | grep blackmagic || systemextensionsctl list | grep blackmagic

# MOTU driver
ls /Library/PreferencePanes/ | grep -i motu
```

---

## See Also

- [setup-macos.sh](../software/scripts/setup-macos.sh) - Automated setup verification
- [COMPATIBILITY.md](../hardware/COMPATIBILITY.md) - Hardware compatibility matrix
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Software troubleshooting

---

*Document maintained by Multi-Camera Livestream Framework team*
