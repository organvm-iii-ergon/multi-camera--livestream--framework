#!/usr/bin/env bash
#
# launch-studio.sh - Launch all streaming applications for Multi-Camera Livestream Framework
#
# This script launches all required applications in the correct order
# with appropriate delays to avoid race conditions.
#
# Usage: ./launch-studio.sh [--skip-health-check] [--no-wait]
#   --skip-health-check    Skip the pre-launch health check
#   --no-wait              Don't wait between application launches
#
# Launch Order:
#   1. Dante Controller (audio routing)
#   2. MOTU Discovery (if installed)
#   3. Ableton Live (audio mixing, clock master)
#   4. OBS Studio (video mixing, streaming)
#   5. Optionally: Blender (graphics)
#
# Author: Multi-Camera Livestream Framework
# Version: 1.0.0

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration Loading
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

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

SKIP_HEALTH_CHECK=false
NO_WAIT=false

# Timing from config or defaults
LAUNCH_DELAY="${CONFIG_TIMING_LAUNCH_DELAY_SECONDS:-3}"

# Application paths (using bundle IDs for reliability)
declare -A APP_BUNDLE_IDS
if [[ "$CONFIG_LOADED" == "true" ]]; then
    APP_BUNDLE_IDS=(
        ["Dante Controller"]="${CONFIG_SOFTWARE_REQUIRED_AUDIO_ROUTING_BUNDLE_ID:-com.audinate.dante.DanteController}"
        ["MOTU Discovery"]="${CONFIG_SOFTWARE_OPTIONAL_DEVICE_MANAGER_BUNDLE_ID:-com.motu.MOTUDiscovery}"
        ["Ableton Live"]="${CONFIG_SOFTWARE_REQUIRED_DAW_APP_BUNDLE_ID:-com.ableton.live}"
        ["OBS Studio"]="${CONFIG_SOFTWARE_REQUIRED_VIDEO_MIXER_BUNDLE_ID:-com.obsproject.obs-studio}"
        ["Blender"]="${CONFIG_SOFTWARE_OPTIONAL_GRAPHICS_BUNDLE_ID:-org.blenderfoundation.blender}"
    )
else
    APP_BUNDLE_IDS=(
        ["Dante Controller"]="com.audinate.dante.DanteController"
        ["MOTU Discovery"]="com.motu.MOTUDiscovery"
        ["Ableton Live"]="com.ableton.live"
        ["OBS Studio"]="com.obsproject.obs-studio"
        ["Blender"]="org.blenderfoundation.blender"
    )
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-health-check)
            SKIP_HEALTH_CHECK=true
            shift
            ;;
        --no-wait)
            NO_WAIT=true
            LAUNCH_DELAY=0
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--skip-health-check] [--no-wait]"
            echo ""
            echo "Options:"
            echo "  --skip-health-check    Skip the pre-launch health check"
            echo "  --no-wait              Don't wait between application launches"
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

get_app_path() {
    local bundle_id=$1
    mdfind "kMDItemCFBundleIdentifier == '$bundle_id'" 2>/dev/null | head -1
}

is_app_running() {
    local app_name=$1
    pgrep -f "$app_name" > /dev/null 2>&1
}

wait_for_app() {
    local app_name=$1
    local max_wait=30
    local waited=0

    while [[ $waited -lt $max_wait ]]; do
        if is_app_running "$app_name"; then
            return 0
        fi
        sleep 1
        ((waited++))
    done
    return 1
}

launch_app() {
    local app_name=$1
    local bundle_id="${APP_BUNDLE_IDS[$app_name]:-}"
    local app_path=""

    print_step "Launching $app_name..."

    # Find application path
    if [[ -n "$bundle_id" ]]; then
        app_path=$(get_app_path "$bundle_id")
    fi

    if [[ -z "$app_path" ]]; then
        # Try common locations
        if [[ -d "/Applications/$app_name.app" ]]; then
            app_path="/Applications/$app_name.app"
        elif [[ -d "$HOME/Applications/$app_name.app" ]]; then
            app_path="$HOME/Applications/$app_name.app"
        fi
    fi

    if [[ -z "$app_path" ]] || [[ ! -d "$app_path" ]]; then
        print_warn "$app_name not found - skipping"
        return 1
    fi

    # Check if already running
    if is_app_running "$app_name"; then
        print_info "$app_name is already running"
        return 0
    fi

    # Launch the application
    open -a "$app_path"

    # Wait for launch (brief)
    sleep 2

    if is_app_running "$app_name"; then
        print_success "$app_name launched"
        return 0
    else
        # Give it more time
        if wait_for_app "$app_name"; then
            print_success "$app_name launched"
            return 0
        else
            print_error "$app_name may have failed to launch"
            return 1
        fi
    fi
}

# -----------------------------------------------------------------------------
# Pre-Launch Checks
# -----------------------------------------------------------------------------

run_health_check() {
    print_step "Running pre-launch health check..."
    echo ""

    local health_script="$SCRIPT_DIR/health-check.sh"

    if [[ -x "$health_script" ]]; then
        if "$health_script"; then
            echo ""
            print_success "Health check passed"
            return 0
        else
            local exit_code=$?
            echo ""
            if [[ $exit_code -eq 2 ]]; then
                print_warn "Health check passed with warnings"
                echo ""
                read -p "Continue anyway? [y/N] " -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    return 0
                else
                    print_info "Launch cancelled"
                    exit 0
                fi
            else
                print_error "Health check failed"
                print_info "Resolve issues before launching"
                exit 1
            fi
        fi
    else
        print_warn "Health check script not found at: $health_script"
        read -p "Continue without health check? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
}

# -----------------------------------------------------------------------------
# Launch Sequence
# -----------------------------------------------------------------------------

launch_sequence() {
    local launched=0
    local failed=0

    echo ""
    echo -e "${BOLD}Starting Launch Sequence${NC}"
    echo "═══════════════════════════════════════"
    echo ""

    # 1. Dante Controller (audio routing must be first)
    if launch_app "Dante Controller"; then
        ((launched++))
        if [[ $LAUNCH_DELAY -gt 0 ]]; then
            print_info "Waiting ${LAUNCH_DELAY}s for Dante to initialize..."
            sleep $LAUNCH_DELAY
        fi
    else
        ((failed++))
    fi

    # 2. MOTU Discovery (optional, for device management)
    if launch_app "MOTU Discovery" 2>/dev/null; then
        ((launched++))
    fi
    # Don't count MOTU as failure - it's optional

    if [[ $LAUNCH_DELAY -gt 0 ]]; then
        sleep $LAUNCH_DELAY
    fi

    # 3. Ableton Live (audio mixing, clock master)
    if launch_app "Ableton Live"; then
        ((launched++))
        if [[ $LAUNCH_DELAY -gt 0 ]]; then
            print_info "Waiting ${LAUNCH_DELAY}s for Ableton to initialize..."
            sleep $LAUNCH_DELAY
        fi
    else
        ((failed++))
        print_error "Ableton Live is required for audio mixing"
    fi

    # 4. OBS Studio (video mixing, streaming)
    if launch_app "OBS Studio"; then
        ((launched++))
    else
        ((failed++))
        print_error "OBS Studio is required for streaming"
    fi

    return $failed
}

# -----------------------------------------------------------------------------
# Post-Launch Status
# -----------------------------------------------------------------------------

verify_launch() {
    echo ""
    echo -e "${BOLD}Verifying Applications${NC}"
    echo "═══════════════════════════════════════"
    echo ""

    local all_good=true

    # Check critical applications
    if is_app_running "Dante"; then
        print_success "Dante Controller: Running"
    else
        print_warn "Dante Controller: Not detected"
    fi

    if is_app_running "Ableton" || is_app_running "Live"; then
        print_success "Ableton Live: Running"
    else
        print_error "Ableton Live: Not running"
        all_good=false
    fi

    if is_app_running "OBS" || is_app_running "obs"; then
        print_success "OBS Studio: Running"
    else
        print_error "OBS Studio: Not running"
        all_good=false
    fi

    echo ""
    return $([ "$all_good" = true ] && echo 0 || echo 1)
}

print_next_steps() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════${NC}"
    echo -e "${BOLD}  LAUNCH COMPLETE${NC}"
    echo -e "${BOLD}═══════════════════════════════════════${NC}"
    echo ""
    echo "Next Steps (RUNBOOK):"
    echo ""
    echo "  1. ${BOLD}Dante Controller:${NC}"
    echo "     - Verify MOTU 8PRE-ES is visible"
    echo "     - Check audio routing matrix"
    echo "     - Confirm clock sync (MOTU = master)"
    echo ""
    echo "  2. ${BOLD}Ableton Live:${NC}"
    echo "     - Open your streaming template project"
    echo "     - Verify Dante audio inputs"
    echo "     - Check levels on all channels"
    echo ""
    echo "  3. ${BOLD}OBS Studio:${NC}"
    echo "     - Verify all camera sources"
    echo "     - Check audio from Ableton (virtual cable)"
    echo "     - Configure stream settings"
    echo "     - Test record before going live"
    echo ""
    echo "Ready to stream? Follow the full RUNBOOK at:"
    echo "  $PROJECT_ROOT/docs/RUNBOOK.md"
    echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║     MULTI-CAMERA LIVESTREAM FRAMEWORK - LAUNCH STUDIO         ║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    if [[ "$CONFIG_LOADED" == "true" ]]; then
        echo -e "Profile: ${BLUE}${CONFIG_PROFILE_NAME:-unknown}${NC}"
    fi

    # Run health check unless skipped
    if ! $SKIP_HEALTH_CHECK; then
        run_health_check
    else
        print_warn "Skipping health check (--skip-health-check)"
    fi

    echo ""

    # Launch applications
    if launch_sequence; then
        verify_launch
        print_next_steps
        exit 0
    else
        echo ""
        print_error "Some applications failed to launch"
        verify_launch
        echo ""
        print_info "Try launching failed applications manually"
        exit 1
    fi
}

main
