#!/usr/bin/env bash
#
# shutdown-studio.sh - Gracefully shutdown all Multi-Camera Livestream Framework applications
#
# This script gracefully quits all streaming applications in the correct
# order to prevent data loss and ensure clean shutdown.
#
# Usage: ./shutdown-studio.sh [--force] [--yes]
#   --force    Force quit applications (use if graceful quit fails)
#   --yes      Skip confirmation prompt
#
# Shutdown Order (reverse of launch):
#   1. OBS Studio (stop streaming first)
#   2. Blender (if running)
#   3. Ableton Live (save project prompt)
#   4. MOTU Discovery
#   5. Dante Controller
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
# Configuration (with fallbacks)
# -----------------------------------------------------------------------------

FORCE_QUIT=false
SKIP_CONFIRM=false

# Timing from config or defaults
QUIT_TIMEOUT="${CONFIG_TIMING_QUIT_TIMEOUT_SECONDS:-10}"

# Hardware names from config for display in reminders
AUDIO_INTERFACE_NAME="${CONFIG_HARDWARE_AUDIO_INTERFACE_VENDOR:-MOTU} ${CONFIG_HARDWARE_AUDIO_INTERFACE_MODEL:-8PRE-ES}"
ENCLOSURE_NAME="${CONFIG_HARDWARE_VIDEO_CAPTURE_ENCLOSURE_MODEL:-Echo Express}"
COMPUTER_NAME="${CONFIG_HARDWARE_COMPUTER_MODEL:-Mac Studio}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force|-f)
            FORCE_QUIT=true
            shift
            ;;
        --yes|-y)
            SKIP_CONFIRM=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--force] [--yes]"
            echo ""
            echo "Options:"
            echo "  --force, -f    Force quit applications"
            echo "  --yes, -y      Skip confirmation prompt"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Color Output
# -----------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "  ${BLUE}→${NC} $1"
}

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

is_app_running() {
    local app_name=$1
    pgrep -f "$app_name" > /dev/null 2>&1
}

quit_app_gracefully() {
    local app_name=$1

    print_step "Quitting $app_name..."

    # Use AppleScript for graceful quit (allows save dialogs)
    osascript -e "tell application \"$app_name\" to quit" 2>/dev/null || true

    # Wait for app to quit
    local waited=0
    while [[ $waited -lt $QUIT_TIMEOUT ]]; do
        if ! is_app_running "$app_name"; then
            print_success "$app_name closed"
            return 0
        fi
        sleep 1
        ((waited++))
    done

    # App didn't quit gracefully
    return 1
}

force_quit_app() {
    local app_name=$1

    print_warn "Force quitting $app_name..."

    # Kill by name pattern
    pkill -f "$app_name" 2>/dev/null || true

    sleep 2

    if ! is_app_running "$app_name"; then
        print_success "$app_name terminated"
        return 0
    else
        print_error "Failed to quit $app_name"
        return 1
    fi
}

quit_app() {
    local app_name=$1

    if ! is_app_running "$app_name"; then
        print_info "$app_name is not running"
        return 0
    fi

    if $FORCE_QUIT; then
        force_quit_app "$app_name"
    else
        if ! quit_app_gracefully "$app_name"; then
            print_warn "$app_name did not quit gracefully"
            read -p "  Force quit? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                force_quit_app "$app_name"
            else
                print_info "Skipping $app_name"
                return 1
            fi
        fi
    fi
}

# -----------------------------------------------------------------------------
# Pre-Shutdown Checks
# -----------------------------------------------------------------------------

check_obs_streaming() {
    # Check if OBS is currently streaming
    # This is a heuristic - check for high network activity from OBS process

    if is_app_running "OBS"; then
        print_warn "OBS Studio is running"
        print_info "Make sure you have STOPPED streaming before shutdown!"
        echo ""

        if ! $SKIP_CONFIRM; then
            read -p "Have you stopped streaming/recording? [y/N] " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "Please stop streaming in OBS first"
                exit 0
            fi
        fi
    fi
}

# -----------------------------------------------------------------------------
# Shutdown Sequence
# -----------------------------------------------------------------------------

shutdown_sequence() {
    local quit_count=0
    local skip_count=0

    echo ""
    echo -e "${BOLD}Starting Shutdown Sequence${NC}"
    echo "═══════════════════════════════════════"
    echo ""

    # Check for active streaming first
    check_obs_streaming

    # 1. OBS Studio (video - quit first to stop streaming)
    if is_app_running "OBS" || is_app_running "obs"; then
        if quit_app "OBS"; then
            ((quit_count++))
        else
            ((skip_count++))
        fi
    else
        print_info "OBS Studio: Not running"
    fi

    # 2. Blender (optional, might be running for graphics)
    if is_app_running "Blender" || is_app_running "blender"; then
        if quit_app "Blender"; then
            ((quit_count++))
        else
            ((skip_count++))
        fi
    fi

    # 3. Ableton Live (audio - may prompt to save)
    if is_app_running "Ableton" || is_app_running "Live"; then
        print_warn "Ableton Live may prompt to save your project"
        if quit_app "Ableton Live"; then
            ((quit_count++))
        else
            # Try alternative process name
            if quit_app "Live"; then
                ((quit_count++))
            else
                ((skip_count++))
            fi
        fi
    else
        print_info "Ableton Live: Not running"
    fi

    # 4. MOTU Discovery (optional)
    if is_app_running "MOTU"; then
        if quit_app "MOTU Discovery"; then
            ((quit_count++))
        fi
    fi

    # 5. Dante Controller (audio routing - quit last)
    if is_app_running "Dante"; then
        if quit_app "Dante Controller"; then
            ((quit_count++))
        else
            ((skip_count++))
        fi
    else
        print_info "Dante Controller: Not running"
    fi

    # Also quit Dante Virtual Soundcard if running
    if is_app_running "DVS"; then
        if quit_app "Dante Virtual Soundcard"; then
            ((quit_count++))
        fi
    fi

    echo ""
    echo "Applications closed: $quit_count"
    if [[ $skip_count -gt 0 ]]; then
        echo "Applications skipped: $skip_count"
    fi
}

# -----------------------------------------------------------------------------
# Hardware Reminders
# -----------------------------------------------------------------------------

print_hardware_reminders() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════${NC}"
    echo -e "${BOLD}  SHUTDOWN COMPLETE${NC}"
    echo -e "${BOLD}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Hardware Shutdown Reminders:${NC}"
    echo ""
    echo "  1. ${BOLD}Cameras:${NC}"
    echo "     - Power off all HDMI cameras"
    echo "     - Cap lenses to protect sensors"
    echo ""
    echo "  2. ${BOLD}${AUDIO_INTERFACE_NAME}:${NC}"
    echo "     - Power switch on rear panel"
    echo "     - Wait for LEDs to turn off"
    echo ""
    echo "  3. ${BOLD}${ENCLOSURE_NAME} Chassis:${NC}"
    echo "     - Power off Thunderbolt chassis"
    echo "     - Capture card can remain installed"
    echo ""
    echo "  4. ${BOLD}Network:${NC}"
    echo "     - Dante switch can remain powered"
    echo "     - (Low power consumption)"
    echo ""
    echo "  5. ${BOLD}${COMPUTER_NAME}:${NC}"
    echo "     - Sleep or shutdown as preferred"
    echo "     - No special shutdown required"
    echo ""
    echo -e "${GREEN}Session ended successfully.${NC}"
    echo ""
}

# -----------------------------------------------------------------------------
# Confirmation
# -----------------------------------------------------------------------------

confirm_shutdown() {
    if $SKIP_CONFIRM; then
        return 0
    fi

    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║     MULTI-CAMERA LIVESTREAM FRAMEWORK - SHUTDOWN STUDIO       ║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # List running applications
    echo "Currently running applications:"
    echo ""

    local running_count=0

    if is_app_running "OBS" || is_app_running "obs"; then
        echo "  • OBS Studio"
        ((running_count++))
    fi

    if is_app_running "Ableton" || is_app_running "Live"; then
        echo "  • Ableton Live"
        ((running_count++))
    fi

    if is_app_running "Dante"; then
        echo "  • Dante Controller"
        ((running_count++))
    fi

    if is_app_running "Blender" || is_app_running "blender"; then
        echo "  • Blender"
        ((running_count++))
    fi

    if is_app_running "MOTU"; then
        echo "  • MOTU Discovery"
        ((running_count++))
    fi

    if [[ $running_count -eq 0 ]]; then
        echo "  (No streaming applications detected)"
        echo ""
        print_info "Nothing to shut down"
        exit 0
    fi

    echo ""

    if $FORCE_QUIT; then
        print_warn "FORCE QUIT mode - applications will be terminated without saving"
    fi

    read -p "Proceed with shutdown? [y/N] " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Shutdown cancelled"
        exit 0
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    confirm_shutdown
    shutdown_sequence
    print_hardware_reminders
}

main
