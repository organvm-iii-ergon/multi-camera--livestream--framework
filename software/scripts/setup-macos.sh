#!/usr/bin/env bash
#
# setup-macos.sh - Setup verification for Multi-Camera Livestream Framework
#
# This script checks that all required software and hardware is properly
# installed and configured for the multi-camera 4K live streaming setup.
#
# Usage: ./setup-macos.sh [--install]
#   --install    Attempt to install missing Homebrew packages
#
# Requirements:
#   - macOS 13.0+ (Ventura or later)
#   - M1 Mac Studio recommended (works on other Apple Silicon)
#
# Author: Multi-Camera Livestream Framework
# Version: 1.0.0

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration Loading
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Attempt to load configuration from generated config
CONFIG_LOADED=false
if [[ -f "$SCRIPT_DIR/../lib/config-utils.sh" ]]; then
    # shellcheck source=../lib/config-utils.sh
    source "$SCRIPT_DIR/../lib/config-utils.sh"
    if load_config 2>/dev/null; then
        CONFIG_LOADED=true
    fi
fi

# -----------------------------------------------------------------------------
# Configuration (with fallbacks for when config not generated)
# -----------------------------------------------------------------------------

# System requirements
REQUIRED_MACOS_MAJOR="${CONFIG_SYSTEM_REQUIRED_OS_MAJOR:-13}"
REQUIRED_MACOS_NAME="${CONFIG_SYSTEM_REQUIRED_OS_NAME:-Ventura}"

# Application bundle identifiers (populated from config or defaults)
declare -A REQUIRED_APPS
if [[ "$CONFIG_LOADED" == "true" ]]; then
    REQUIRED_APPS=(
        ["OBS Studio"]="${CONFIG_SOFTWARE_REQUIRED_VIDEO_MIXER_BUNDLE_ID:-com.obsproject.obs-studio}"
        ["Ableton Live"]="${CONFIG_SOFTWARE_REQUIRED_DAW_APP_BUNDLE_ID:-com.ableton.live}"
        ["Dante Controller"]="${CONFIG_SOFTWARE_REQUIRED_AUDIO_ROUTING_BUNDLE_ID:-com.audinate.dante.DanteController}"
    )
else
    REQUIRED_APPS=(
        ["OBS Studio"]="com.obsproject.obs-studio"
        ["Ableton Live"]="com.ableton.live"
        ["Dante Controller"]="com.audinate.dante.DanteController"
    )
fi

# Optional but recommended apps
declare -A OPTIONAL_APPS
if [[ "$CONFIG_LOADED" == "true" ]]; then
    OPTIONAL_APPS=(
        ["Dante Virtual Soundcard"]="${CONFIG_SOFTWARE_OPTIONAL_DANTE_VIRTUAL_SOUNDCARD_BUNDLE_ID:-com.audinate.dante.DVS}"
        ["MOTU Discovery"]="${CONFIG_SOFTWARE_OPTIONAL_DEVICE_MANAGER_BUNDLE_ID:-com.motu.MOTUDiscovery}"
        ["Blender"]="${CONFIG_SOFTWARE_OPTIONAL_GRAPHICS_BUNDLE_ID:-org.blenderfoundation.blender}"
    )
else
    OPTIONAL_APPS=(
        ["Dante Virtual Soundcard"]="com.audinate.dante.DVS"
        ["MOTU Discovery"]="com.motu.MOTUDiscovery"
        ["Blender"]="org.blenderfoundation.blender"
    )
fi

# Config directories to create (from config or defaults)
if [[ "$CONFIG_LOADED" == "true" && -n "${CONFIG_CONFIG_DIRS:-}" ]]; then
    # shellcheck disable=SC2206
    CONFIG_DIRS=($CONFIG_CONFIG_DIRS)
else
    CONFIG_DIRS=(
        "software/configs/obs"
        "software/configs/ableton"
        "software/configs/dante"
        "software/configs/blender"
        "software/configs/network"
    )
fi

# -----------------------------------------------------------------------------
# Color Output
# -----------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

print_check() {
    echo -e "${GREEN}✓${NC} $1"
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# -----------------------------------------------------------------------------
# Counters
# -----------------------------------------------------------------------------

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

increment_pass() { PASS_COUNT=$((PASS_COUNT + 1)); }
increment_fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); }
increment_warn() { WARN_COUNT=$((WARN_COUNT + 1)); }

# -----------------------------------------------------------------------------
# Check Functions
# -----------------------------------------------------------------------------

check_macos_version() {
    print_header "macOS Version Check"

    local macos_version
    macos_version=$(sw_vers -productVersion)
    local major_version
    major_version=$(echo "$macos_version" | cut -d. -f1)

    if [[ $major_version -ge $REQUIRED_MACOS_MAJOR ]]; then
        print_check "macOS $macos_version (requires $REQUIRED_MACOS_MAJOR.0+ / $REQUIRED_MACOS_NAME)"
        increment_pass
    else
        print_fail "macOS $macos_version detected - requires $REQUIRED_MACOS_MAJOR.0+ ($REQUIRED_MACOS_NAME)"
        print_info "Please upgrade macOS to continue"
        increment_fail
    fi

    # Check for Apple Silicon
    local arch
    arch=$(uname -m)
    if [[ "$arch" == "arm64" ]]; then
        print_check "Apple Silicon detected ($arch)"
        increment_pass
    else
        print_warn "Intel Mac detected ($arch) - Apple Silicon (M1+) recommended"
        increment_warn
    fi
}

check_homebrew() {
    print_header "Homebrew Check"

    if command -v brew &>/dev/null; then
        local brew_version
        brew_version=$(brew --version | head -1)
        print_check "Homebrew installed: $brew_version"
        increment_pass

        # Check if brew is in PATH correctly for Apple Silicon
        if [[ -d "/opt/homebrew" ]]; then
            if [[ ":$PATH:" == *":/opt/homebrew/bin:"* ]]; then
                print_check "Homebrew path configured correctly"
                increment_pass
            else
                print_warn "Homebrew installed but /opt/homebrew/bin not in PATH"
                print_info "Add to ~/.zshrc: export PATH=\"/opt/homebrew/bin:\$PATH\""
                increment_warn
            fi
        fi
    else
        print_fail "Homebrew not installed"
        print_info "Install with: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        increment_fail

        if [[ "${1:-}" == "--install" ]]; then
            print_info "Attempting to install Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    fi
}

check_required_apps() {
    print_header "Required Applications"

    for app_name in "${!REQUIRED_APPS[@]}"; do
        local bundle_id="${REQUIRED_APPS[$app_name]}"
        local app_path
        app_path=$(mdfind "kMDItemCFBundleIdentifier == '$bundle_id'" 2>/dev/null | head -1)

        if [[ -n "$app_path" ]]; then
            # Get version if possible
            local version=""
            if [[ -f "$app_path/Contents/Info.plist" ]]; then
                version=$(defaults read "$app_path/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "")
            fi
            if [[ -n "$version" ]]; then
                print_check "$app_name v$version"
            else
                print_check "$app_name installed"
            fi
            increment_pass
        else
            print_fail "$app_name not found"
            increment_fail
        fi
    done
}

check_optional_apps() {
    print_header "Optional Applications"

    for app_name in "${!OPTIONAL_APPS[@]}"; do
        local bundle_id="${OPTIONAL_APPS[$app_name]}"
        local app_path
        app_path=$(mdfind "kMDItemCFBundleIdentifier == '$bundle_id'" 2>/dev/null | head -1)

        if [[ -n "$app_path" ]]; then
            print_check "$app_name installed"
            increment_pass
        else
            print_warn "$app_name not found (optional)"
            increment_warn
        fi
    done
}

check_decklink_driver() {
    print_header "Blackmagic DeckLink Driver"

    # Check if DeckLink kernel extension is loaded
    if kextstat 2>/dev/null | command grep -q "com.blackmagic-design"; then
        print_check "Blackmagic kernel extension loaded"
        increment_pass
    else
        # On newer macOS, check system extensions instead
        if systemextensionsctl list 2>/dev/null | command grep -q "blackmagic"; then
            print_check "Blackmagic system extension installed"
            increment_pass
        else
            print_warn "Blackmagic driver not detected in kernel/system extensions"
            increment_warn
        fi
    fi

    # Check for DeckLink hardware via system_profiler
    print_info "Checking for DeckLink hardware..."
    local pci_info
    pci_info=$(system_profiler SPPCIDataType 2>/dev/null)

    if echo "$pci_info" | command grep -qi "decklink\|blackmagic"; then
        print_check "DeckLink hardware detected via PCIe/Thunderbolt"
        increment_pass

        # Try to get more details
        echo "$pci_info" | command grep -A5 -i "decklink\|blackmagic" | head -10 | while read -r line; do
            if [[ -n "$line" ]]; then
                print_info "  $line"
            fi
        done
    else
        print_warn "DeckLink hardware not detected (ensure Thunderbolt chassis is powered on)"
        print_info "Expected: Echo Express SE I with DeckLink Quad HDMI"
        increment_warn
    fi

    # Check for Desktop Video utility
    if [[ -d "/Applications/Blackmagic Desktop Video" ]] || [[ -d "/Applications/Blackmagic Desktop Video Setup.app" ]]; then
        print_check "Blackmagic Desktop Video utility installed"
        increment_pass
    else
        print_warn "Blackmagic Desktop Video utility not found"
        print_info "Download from: https://www.blackmagicdesign.com/support"
        increment_warn
    fi
}

check_motu_driver() {
    print_header "MOTU Audio Driver"

    # Check for MOTU audio devices
    local audio_devices
    audio_devices=$(system_profiler SPAudioDataType 2>/dev/null)

    if echo "$audio_devices" | command grep -qi "motu"; then
        print_check "MOTU audio device detected"
        increment_pass

        # Show device name
        echo "$audio_devices" | command grep -i "motu" | head -3 | while read -r line; do
            print_info "  $line"
        done
    else
        print_warn "MOTU audio device not detected"
        print_info "Ensure MOTU 8PRE-ES is connected and powered on"
        increment_warn
    fi

    # Check for MOTU driver/preference pane
    if [[ -d "/Library/PreferencePanes/MOTU Audio.prefPane" ]] || \
       [[ -d "$HOME/Library/PreferencePanes/MOTU Audio.prefPane" ]]; then
        print_check "MOTU preference pane installed"
        increment_pass
    else
        print_warn "MOTU preference pane not found"
        print_info "Download from: https://motu.com/download"
        increment_warn
    fi
}

check_dante_network() {
    print_header "Dante Network Configuration"

    # List network interfaces
    local interfaces
    interfaces=$(networksetup -listallhardwareports)

    # Check for dedicated Ethernet interface
    if echo "$interfaces" | command grep -q "Ethernet"; then
        print_check "Ethernet interface available"
        increment_pass

        # Get interface details - simplified to avoid hanging
        local primary_ip
        primary_ip=$(ipconfig getifaddr en0 2>/dev/null || echo "")
        if [[ -n "$primary_ip" ]]; then
            print_info "Primary interface (en0): $primary_ip"
        fi
    else
        print_warn "No Ethernet interface detected"
        print_info "Dante requires dedicated Ethernet for reliable performance"
        increment_warn
    fi

    # Check for Dante Virtual Soundcard (audio routing)
    local dvs_audio
    dvs_audio=$(system_profiler SPAudioDataType 2>/dev/null | command grep -i "dante" || true)
    if [[ -n "$dvs_audio" ]]; then
        print_check "Dante Virtual Soundcard active"
        increment_pass
    else
        print_info "Dante Virtual Soundcard not detected (may not be needed with hardware interface)"
    fi
}

check_disk_space() {
    print_header "Disk Space"

    local free_space
    free_space=$(df -g / | tail -1 | awk '{print $4}')

    if [[ $free_space -ge 100 ]]; then
        print_check "Disk space: ${free_space}GB free (100GB+ recommended)"
        increment_pass
    elif [[ $free_space -ge 50 ]]; then
        print_warn "Disk space: ${free_space}GB free (100GB+ recommended)"
        print_info "Consider freeing space for recording buffer"
        increment_warn
    else
        print_fail "Disk space: ${free_space}GB free (minimum 50GB required)"
        increment_fail
    fi
}

create_config_directories() {
    print_header "Config Directories"

    local script_dir
    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

    for dir in "${CONFIG_DIRS[@]}"; do
        local full_path="$script_dir/$dir"
        if [[ -d "$full_path" ]]; then
            print_check "Directory exists: $dir"
        else
            mkdir -p "$full_path"
            print_check "Created directory: $dir"
        fi
    done
    increment_pass
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

print_summary() {
    print_header "Setup Summary"

    echo ""
    echo -e "  ${GREEN}Passed:${NC}  $PASS_COUNT"
    echo -e "  ${RED}Failed:${NC}  $FAIL_COUNT"
    echo -e "  ${YELLOW}Warnings:${NC} $WARN_COUNT"
    echo ""

    if [[ $FAIL_COUNT -eq 0 ]]; then
        if [[ $WARN_COUNT -eq 0 ]]; then
            echo -e "${GREEN}${BOLD}✓ All checks passed! System is ready for streaming.${NC}"
        else
            echo -e "${YELLOW}${BOLD}⚠ Setup complete with warnings. Review items above.${NC}"
        fi
        echo ""
        echo "Next steps:"
        echo "  1. Run health-check.sh before each streaming session"
        echo "  2. Run launch-studio.sh to start all applications"
        echo ""
        return 0
    else
        echo -e "${RED}${BOLD}✗ Setup incomplete. Please resolve failed checks above.${NC}"
        echo ""
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    echo ""
    echo -e "${BOLD}Multi-Camera Livestream Framework - Setup${NC}"
    echo -e "Version 1.0.0 | $(date '+%Y-%m-%d %H:%M:%S')"

    if [[ "$CONFIG_LOADED" == "true" ]]; then
        echo -e "Profile: ${BLUE}${CONFIG_PROFILE_NAME:-unknown}${NC}"
    else
        echo -e "Profile: ${YELLOW}(using defaults - run generate-config.sh)${NC}"
    fi

    check_macos_version
    check_homebrew "$@"
    check_required_apps
    check_optional_apps
    check_decklink_driver
    check_motu_driver
    check_dante_network
    check_disk_space
    create_config_directories

    print_summary
}

main "$@"
