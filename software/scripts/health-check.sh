#!/usr/bin/env bash
#
# health-check.sh - Pre-stream health check for Dope's Show pipeline
#
# Run this script 30-45 minutes before going live to verify all
# hardware and software is functioning correctly.
#
# Usage: ./health-check.sh [--verbose] [--json]
#   --verbose    Show detailed information for each check
#   --json       Output results in JSON format
#
# Exit codes:
#   0 - All checks passed
#   1 - Critical failures detected
#   2 - Warnings detected but can proceed
#
# Author: Dope's Show Pipeline
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

# Thresholds from config or defaults
MIN_DISK_SPACE_GB="${CONFIG_THRESHOLDS_MIN_DISK_SPACE_GB:-50}"
MIN_MEMORY_FREE_PERCENT="${CONFIG_THRESHOLDS_MIN_MEMORY_FREE_PERCENT:-20}"
MAX_CPU_USAGE_PERCENT="${CONFIG_THRESHOLDS_MAX_CPU_USAGE_PERCENT:-70}"
MIN_MEMORY_FREE_MB="${CONFIG_THRESHOLDS_MIN_MEMORY_FREE_MB:-4000}"
RECOMMENDED_MEMORY_FREE_MB="${CONFIG_THRESHOLDS_RECOMMENDED_MEMORY_FREE_MB:-8000}"

# Hardware detection patterns from config
AUDIO_INTERFACE_PATTERNS="${CONFIG_HARDWARE_AUDIO_INTERFACE_DETECTION_PATTERNS:-motu}"
VIDEO_CAPTURE_PATTERNS="${CONFIG_HARDWARE_VIDEO_CAPTURE_DETECTION_PATTERNS:-decklink blackmagic}"
ENCLOSURE_PATTERNS="${CONFIG_HARDWARE_VIDEO_CAPTURE_ENCLOSURE_DETECTION_PATTERNS:-echo sonnet}"

# Hardware display names from config
AUDIO_INTERFACE_NAME="${CONFIG_HARDWARE_AUDIO_INTERFACE_VENDOR:-MOTU} ${CONFIG_HARDWARE_AUDIO_INTERFACE_MODEL:-8PRE-ES}"
VIDEO_CAPTURE_NAME="${CONFIG_HARDWARE_VIDEO_CAPTURE_MODEL:-DeckLink}"
ENCLOSURE_NAME="${CONFIG_HARDWARE_VIDEO_CAPTURE_ENCLOSURE_MODEL:-Echo Express}"

VERBOSE=false
JSON_OUTPUT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --json|-j)
            JSON_OUTPUT=true
            shift
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

# Disable colors for JSON output
if $JSON_OUTPUT; then
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BOLD=''
    NC=''
fi

print_header() {
    if ! $JSON_OUTPUT; then
        echo ""
        echo -e "${BOLD}${BLUE}── $1 ──${NC}"
    fi
}

print_pass() {
    if ! $JSON_OUTPUT; then
        echo -e "  ${GREEN}✓${NC} $1"
    fi
}

print_fail() {
    if ! $JSON_OUTPUT; then
        echo -e "  ${RED}✗${NC} $1"
    fi
}

print_warn() {
    if ! $JSON_OUTPUT; then
        echo -e "  ${YELLOW}⚠${NC} $1"
    fi
}

print_info() {
    if ! $JSON_OUTPUT && $VERBOSE; then
        echo -e "    ${BLUE}→${NC} $1"
    fi
}

# -----------------------------------------------------------------------------
# Result Tracking
# -----------------------------------------------------------------------------

declare -A RESULTS
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

record_result() {
    local check_name=$1
    local status=$2  # pass, fail, warn
    local message=$3

    RESULTS["$check_name"]="$status:$message"

    case $status in
        pass) PASS_COUNT=$((PASS_COUNT + 1)) ;;
        fail) FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
        warn) WARN_COUNT=$((WARN_COUNT + 1)) ;;
    esac
}

# -----------------------------------------------------------------------------
# Health Checks
# -----------------------------------------------------------------------------

check_obs_not_running() {
    print_header "Application State"

    if pgrep -x "OBS" > /dev/null 2>&1 || pgrep -x "obs" > /dev/null 2>&1; then
        print_warn "OBS Studio is already running"
        print_info "Close OBS before launching via launch-studio.sh for clean state"
        record_result "obs_not_running" "warn" "OBS already running"
    else
        print_pass "OBS Studio not running (clean state)"
        record_result "obs_not_running" "pass" "Clean state"
    fi

    if pgrep -x "Ableton Live" > /dev/null 2>&1 || pgrep -f "Ableton" > /dev/null 2>&1; then
        print_warn "Ableton Live is already running"
        record_result "ableton_not_running" "warn" "Ableton already running"
    else
        print_pass "Ableton Live not running (clean state)"
        record_result "ableton_not_running" "pass" "Clean state"
    fi
}

check_dante_devices() {
    print_header "Dante Audio Network"

    # Check for Dante/audio network devices via ioreg
    local dante_found=false
    local audio_devices
    audio_devices=$(ioreg -r -c IOAudioDevice 2>/dev/null || true)

    # Look for audio interface using detection patterns from config
    local interface_detected=false
    for pattern in $AUDIO_INTERFACE_PATTERNS; do
        if echo "$audio_devices" | command grep -qi "$pattern"; then
            interface_detected=true
            break
        fi
    done

    if $interface_detected; then
        print_pass "$AUDIO_INTERFACE_NAME detected"
        dante_found=true

        if $VERBOSE; then
            local device_info
            for pattern in $AUDIO_INTERFACE_PATTERNS; do
                device_info=$(echo "$audio_devices" | command grep -i "$pattern" -A5 | head -6)
                if [[ -n "$device_info" ]]; then
                    print_info "Device: $device_info"
                    break
                fi
            done
        fi
        record_result "audio_interface" "pass" "$AUDIO_INTERFACE_NAME detected"
    else
        print_fail "$AUDIO_INTERFACE_NAME not detected"
        print_info "Check: Is $AUDIO_INTERFACE_NAME powered on and connected?"
        record_result "audio_interface" "fail" "$AUDIO_INTERFACE_NAME not detected"
    fi

    # Check for Dante Virtual Soundcard
    if ioreg -r -c IOAudioDevice 2>/dev/null | command grep -qi "dante"; then
        print_pass "Dante Virtual Soundcard detected"
        record_result "dante_vs" "pass" "DVS detected"
    else
        print_info "Dante Virtual Soundcard not active (may not be required)"
        record_result "dante_vs" "warn" "DVS not active"
    fi

    # Check audio output devices
    local audio_output
    audio_output=$(system_profiler SPAudioDataType 2>/dev/null | command grep -A2 "Output")
    if $VERBOSE && [[ -n "$audio_output" ]]; then
        print_info "Audio outputs available"
    fi
}

check_decklink_hardware() {
    print_header "Video Capture Hardware"

    # Check for video capture via system profiler
    local pci_devices
    pci_devices=$(system_profiler SPPCIDataType 2>/dev/null || echo "")

    # Check using detection patterns from config
    local capture_detected=false
    for pattern in $VIDEO_CAPTURE_PATTERNS; do
        if echo "$pci_devices" | command grep -qi "$pattern"; then
            capture_detected=true
            break
        fi
    done

    if $capture_detected; then
        print_pass "$VIDEO_CAPTURE_NAME hardware detected"
        record_result "video_capture_hw" "pass" "$VIDEO_CAPTURE_NAME found"

        if $VERBOSE; then
            local capture_info
            for pattern in $VIDEO_CAPTURE_PATTERNS; do
                capture_info=$(echo "$pci_devices" | command grep -i "$pattern" -A3 | head -4)
                if [[ -n "$capture_info" ]]; then
                    print_info "$capture_info"
                    break
                fi
            done
        fi
    else
        # Also check Thunderbolt devices for enclosure
        local tb_devices
        tb_devices=$(system_profiler SPThunderboltDataType 2>/dev/null || echo "")

        local enclosure_detected=false
        for pattern in $ENCLOSURE_PATTERNS $VIDEO_CAPTURE_PATTERNS; do
            if echo "$tb_devices" | command grep -qi "$pattern"; then
                enclosure_detected=true
                break
            fi
        done

        if $enclosure_detected; then
            print_pass "Thunderbolt expansion chassis detected"
            print_info "Verify $VIDEO_CAPTURE_NAME card is recognized in chassis"
            record_result "video_capture_hw" "warn" "Chassis detected, verify card"
        else
            print_fail "$VIDEO_CAPTURE_NAME hardware not detected"
            print_info "Check: Is $ENCLOSURE_NAME chassis powered on?"
            print_info "Check: Is Thunderbolt cable connected?"
            record_result "video_capture_hw" "fail" "$VIDEO_CAPTURE_NAME not found"
        fi
    fi
}

check_disk_space() {
    print_header "Disk Space"

    local free_space
    free_space=$(df -g / | tail -1 | awk '{print $4}')

    if [[ $free_space -ge $MIN_DISK_SPACE_GB ]]; then
        print_pass "Disk space: ${free_space}GB free"
        record_result "disk_space" "pass" "${free_space}GB free"
    else
        print_fail "Disk space: ${free_space}GB free (minimum ${MIN_DISK_SPACE_GB}GB required)"
        print_info "Free up space before streaming to ensure recording buffer"
        record_result "disk_space" "fail" "Only ${free_space}GB free"
    fi
}

check_cpu_memory() {
    print_header "System Resources"

    # CPU usage (rough estimate via top)
    local cpu_idle
    cpu_idle=$(top -l 1 -n 0 2>/dev/null | command grep "CPU usage" | awk -F'idle' '{print $1}' | awk '{print $NF}' | tr -d '%')

    if [[ -n "$cpu_idle" ]]; then
        local cpu_used=$((100 - ${cpu_idle%.*}))

        if [[ $cpu_used -le $MAX_CPU_USAGE_PERCENT ]]; then
            print_pass "CPU usage: ${cpu_used}% (${cpu_idle}% idle)"
            record_result "cpu_usage" "pass" "${cpu_used}% used"
        else
            print_warn "CPU usage: ${cpu_used}% (high load detected)"
            print_info "Close unnecessary applications before streaming"
            record_result "cpu_usage" "warn" "${cpu_used}% used"
        fi
    else
        print_info "Could not determine CPU usage"
        record_result "cpu_usage" "warn" "Unknown"
    fi

    # Memory usage
    local mem_info
    mem_info=$(vm_stat 2>/dev/null)

    if [[ -n "$mem_info" ]]; then
        local pages_free
        pages_free=$(echo "$mem_info" | command grep "Pages free" | awk '{print $3}' | tr -d '.')
        local pages_inactive
        pages_inactive=$(echo "$mem_info" | command grep "Pages inactive" | awk '{print $3}' | tr -d '.')

        local page_size=16384  # 16KB on Apple Silicon
        local free_mb=$(( (pages_free + pages_inactive) * page_size / 1024 / 1024 ))

        if [[ $free_mb -ge 8000 ]]; then
            print_pass "Memory: ~${free_mb}MB available"
            record_result "memory" "pass" "${free_mb}MB available"
        elif [[ $free_mb -ge 4000 ]]; then
            print_warn "Memory: ~${free_mb}MB available (recommend 8GB+ free)"
            record_result "memory" "warn" "${free_mb}MB available"
        else
            print_fail "Memory: ~${free_mb}MB available (low memory)"
            print_info "Close applications to free memory before streaming"
            record_result "memory" "fail" "${free_mb}MB available"
        fi
    else
        print_info "Could not determine memory usage"
        record_result "memory" "warn" "Unknown"
    fi
}

check_network() {
    print_header "Network Connectivity"

    # Check for active network connection
    local active_interface
    active_interface=$(route get default 2>/dev/null | command grep interface | awk '{print $2}')

    if [[ -n "$active_interface" ]]; then
        print_pass "Active network interface: $active_interface"

        local ip_addr
        ip_addr=$(ifconfig "$active_interface" 2>/dev/null | command grep "inet " | awk '{print $2}')
        if [[ -n "$ip_addr" ]]; then
            print_info "IP Address: $ip_addr"
        fi

        record_result "network_interface" "pass" "$active_interface"
    else
        print_fail "No active network connection"
        record_result "network_interface" "fail" "No connection"
    fi

    # Test internet connectivity (RTMP endpoint)
    if ping -c 1 -t 5 a.]rtmp.youtube.com &>/dev/null; then
        print_pass "YouTube RTMP endpoint reachable"
        record_result "youtube_rtmp" "pass" "Reachable"
    else
        # Try general internet
        if ping -c 1 -t 5 8.8.8.8 &>/dev/null; then
            print_warn "Internet available but YouTube RTMP may be blocked"
            record_result "youtube_rtmp" "warn" "Possible block"
        else
            print_fail "No internet connectivity"
            record_result "youtube_rtmp" "fail" "No internet"
        fi
    fi
}

check_thermal() {
    print_header "Thermal Status"

    # Check for thermal throttling via powermetrics (requires sudo)
    # Fallback to checking if system is under load

    # Simple thermal check via CPU temperature if available
    if command -v osx-cpu-temp &>/dev/null; then
        local cpu_temp
        cpu_temp=$(osx-cpu-temp 2>/dev/null)
        print_info "CPU Temperature: $cpu_temp"
    fi

    # Check if thermal throttling might be occurring
    local thermal_state
    thermal_state=$(pmset -g therm 2>/dev/null | command grep -i "thermal" || echo "")

    if [[ -n "$thermal_state" ]]; then
        if echo "$thermal_state" | command grep -qi "no thermal"; then
            print_pass "No thermal throttling"
            record_result "thermal" "pass" "No throttling"
        else
            print_warn "Thermal conditions detected"
            print_info "Ensure adequate ventilation"
            record_result "thermal" "warn" "Check ventilation"
        fi
    else
        print_pass "Thermal status normal"
        record_result "thermal" "pass" "Normal"
    fi
}

# -----------------------------------------------------------------------------
# Output Summary
# -----------------------------------------------------------------------------

print_summary() {
    if $JSON_OUTPUT; then
        echo "{"
        echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
        echo "  \"pass_count\": $PASS_COUNT,"
        echo "  \"fail_count\": $FAIL_COUNT,"
        echo "  \"warn_count\": $WARN_COUNT,"
        echo "  \"status\": \"$([ $FAIL_COUNT -eq 0 ] && echo "ready" || echo "not_ready")\","
        echo "  \"checks\": {"

        local first=true
        for key in "${!RESULTS[@]}"; do
            if ! $first; then echo ","; fi
            first=false
            local value="${RESULTS[$key]}"
            local status="${value%%:*}"
            local message="${value#*:}"
            echo -n "    \"$key\": {\"status\": \"$status\", \"message\": \"$message\"}"
        done

        echo ""
        echo "  }"
        echo "}"
        return
    fi

    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  HEALTH CHECK SUMMARY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${GREEN}Passed:${NC}   $PASS_COUNT"
    echo -e "  ${RED}Failed:${NC}   $FAIL_COUNT"
    echo -e "  ${YELLOW}Warnings:${NC} $WARN_COUNT"
    echo ""

    if [[ $FAIL_COUNT -eq 0 ]]; then
        if [[ $WARN_COUNT -eq 0 ]]; then
            echo -e "${GREEN}${BOLD}✓ All systems ready for streaming!${NC}"
            echo ""
            echo "Next: Run ./launch-studio.sh to start applications"
        else
            echo -e "${YELLOW}${BOLD}⚠ Ready with warnings - review items above${NC}"
            echo ""
            echo "You can proceed but address warnings when possible."
            echo "Next: Run ./launch-studio.sh to start applications"
        fi
    else
        echo -e "${RED}${BOLD}✗ Critical issues detected - DO NOT proceed${NC}"
        echo ""
        echo "Resolve the failed checks above before streaming."
    fi
    echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    if ! $JSON_OUTPUT; then
        echo ""
        echo -e "${BOLD}Dope's Show - Pre-Stream Health Check${NC}"
        echo -e "$(date '+%Y-%m-%d %H:%M:%S')"
        if [[ "$CONFIG_LOADED" == "true" ]]; then
            echo -e "Profile: ${BLUE}${CONFIG_PROFILE_NAME:-unknown}${NC}"
        fi
    fi

    check_obs_not_running
    check_dante_devices
    check_decklink_hardware
    check_disk_space
    check_cpu_memory
    check_network
    check_thermal

    print_summary

    # Exit codes
    if [[ $FAIL_COUNT -gt 0 ]]; then
        exit 1
    elif [[ $WARN_COUNT -gt 0 ]]; then
        exit 2
    else
        exit 0
    fi
}

main
