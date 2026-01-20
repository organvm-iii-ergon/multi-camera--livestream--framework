#!/usr/bin/env bash
#
# config-utils.sh - Shared configuration loading utilities
#
# This library provides functions for loading and accessing
# configuration values from generated config files.
#
# Usage in scripts:
#   source "$SCRIPT_DIR/../lib/config-utils.sh"
#   load_config || true  # Graceful fallback if config not generated
#
# The generated config.sh exports variables like:
#   CONFIG_PROFILE_NAME="studio"
#   CONFIG_HARDWARE_COMPUTER_MODEL="Mac Studio"
#   CONFIG_THRESHOLDS_MIN_DISK_SPACE_GB="50"
#
# Author: Dope's Show Pipeline
# Version: 1.0.0

# Prevent multiple sourcing
[[ -n "${_CONFIG_UTILS_LOADED:-}" ]] && return 0
_CONFIG_UTILS_LOADED=1

# -----------------------------------------------------------------------------
# Path Resolution
# -----------------------------------------------------------------------------

# Get the directory containing this library
_CONFIG_UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_CONFIG_PROJECT_ROOT="$(cd "$_CONFIG_UTILS_DIR/../.." && pwd)"

# Config file locations
CONFIG_GENERATED_DIR="${_CONFIG_PROJECT_ROOT}/software/generated"
CONFIG_GENERATED_SH="${CONFIG_GENERATED_DIR}/config.sh"
CONFIG_GENERATED_JSON="${CONFIG_GENERATED_DIR}/config.json"
CONFIG_PROFILES_DIR="${_CONFIG_PROJECT_ROOT}/software/configs/profiles"
CONFIG_DEFAULTS_FILE="${_CONFIG_PROJECT_ROOT}/software/configs/defaults.yaml"

# Track if config was loaded
CONFIG_LOADED=false
CONFIG_PROFILE_ACTIVE=""

# -----------------------------------------------------------------------------
# Core Loading Functions
# -----------------------------------------------------------------------------

# Load the generated shell configuration
# Returns 0 if successful, 1 if config not found
load_config() {
    if [[ -f "$CONFIG_GENERATED_SH" ]]; then
        # shellcheck source=/dev/null
        source "$CONFIG_GENERATED_SH"
        CONFIG_LOADED=true
        CONFIG_PROFILE_ACTIVE="${CONFIG_PROFILE_NAME:-unknown}"
        return 0
    else
        CONFIG_LOADED=false
        return 1
    fi
}

# Check if config is loaded
is_config_loaded() {
    [[ "$CONFIG_LOADED" == "true" ]]
}

# Get the active profile name
get_active_profile() {
    echo "${CONFIG_PROFILE_ACTIVE:-none}"
}

# -----------------------------------------------------------------------------
# Config Access Helpers
# -----------------------------------------------------------------------------

# Get a config value with optional default
# Usage: config_get "THRESHOLDS_MIN_DISK_SPACE_GB" "50"
config_get() {
    local key="$1"
    local default="${2:-}"
    local var_name="CONFIG_${key}"

    # Use indirect reference to get variable value
    local value="${!var_name:-$default}"
    echo "$value"
}

# Get hardware config value
# Usage: hw_get "COMPUTER_MODEL" "Mac"
hw_get() {
    config_get "HARDWARE_$1" "${2:-}"
}

# Get software config value
# Usage: sw_get "REQUIRED_DAW_APP_NAME" "Ableton Live"
sw_get() {
    config_get "SOFTWARE_$1" "${2:-}"
}

# Get threshold value
# Usage: threshold_get "MIN_DISK_SPACE_GB" "50"
threshold_get() {
    config_get "THRESHOLDS_$1" "${2:-}"
}

# Get timing value
# Usage: timing_get "LAUNCH_DELAY_SECONDS" "3"
timing_get() {
    config_get "TIMING_$1" "${2:-}"
}

# -----------------------------------------------------------------------------
# Hardware Detection Patterns
# -----------------------------------------------------------------------------

# Get detection patterns as array for a hardware component
# Usage: patterns=($(get_detection_patterns "VIDEO_CAPTURE"))
get_detection_patterns() {
    local component="$1"
    local var_name="CONFIG_HARDWARE_${component}_DETECTION_PATTERNS"
    local patterns="${!var_name:-}"

    # Patterns are stored space-separated in the shell config
    echo "$patterns"
}

# Check if hardware matches any detection pattern
# Usage: if matches_detection_pattern "VIDEO_CAPTURE" "$device_info"; then
matches_detection_pattern() {
    local component="$1"
    local text="$2"
    local patterns
    patterns=$(get_detection_patterns "$component")

    local text_lower
    text_lower=$(echo "$text" | tr '[:upper:]' '[:lower:]')

    for pattern in $patterns; do
        if [[ "$text_lower" == *"$pattern"* ]]; then
            return 0
        fi
    done
    return 1
}

# -----------------------------------------------------------------------------
# Application Bundle IDs
# -----------------------------------------------------------------------------

# Get bundle ID for an application by its config key
# Usage: bundle_id=$(get_bundle_id "REQUIRED_DAW_APP")
get_bundle_id() {
    local app_key="$1"
    config_get "SOFTWARE_${app_key}_BUNDLE_ID" ""
}

# Get all required app bundle IDs as associative array output
# Outputs: name:bundle_id pairs, one per line
get_required_apps() {
    # These are populated from config
    echo "OBS Studio:${CONFIG_SOFTWARE_REQUIRED_VIDEO_MIXER_BUNDLE_ID:-com.obsproject.obs-studio}"
    echo "Ableton Live:${CONFIG_SOFTWARE_REQUIRED_DAW_APP_BUNDLE_ID:-com.ableton.live}"
    echo "Dante Controller:${CONFIG_SOFTWARE_REQUIRED_AUDIO_ROUTING_BUNDLE_ID:-com.audinate.dante.DanteController}"
}

# Get all optional app bundle IDs
get_optional_apps() {
    echo "Dante Virtual Soundcard:${CONFIG_SOFTWARE_OPTIONAL_DANTE_VIRTUAL_SOUNDCARD_BUNDLE_ID:-com.audinate.dante.DVS}"
    echo "MOTU Discovery:${CONFIG_SOFTWARE_OPTIONAL_DEVICE_MANAGER_BUNDLE_ID:-com.motu.MOTUDiscovery}"
    echo "Blender:${CONFIG_SOFTWARE_OPTIONAL_GRAPHICS_BUNDLE_ID:-org.blenderfoundation.blender}"
}

# Get process names for an application
# Usage: get_process_names "REQUIRED_VIDEO_MIXER"
get_process_names() {
    local app_key="$1"
    config_get "SOFTWARE_${app_key}_PROCESS_NAMES" ""
}

# -----------------------------------------------------------------------------
# Validation Helpers
# -----------------------------------------------------------------------------

# Validate that required config is present
validate_config() {
    local missing=()

    # Check essential values
    [[ -z "${CONFIG_PROFILE_NAME:-}" ]] && missing+=("PROFILE_NAME")
    [[ -z "${CONFIG_THRESHOLDS_MIN_DISK_SPACE_GB:-}" ]] && missing+=("THRESHOLDS_MIN_DISK_SPACE_GB")

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Missing config values: ${missing[*]}" >&2
        return 1
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Profile Management
# -----------------------------------------------------------------------------

# List available profiles
list_profiles() {
    if [[ -d "$CONFIG_PROFILES_DIR" ]]; then
        for profile in "$CONFIG_PROFILES_DIR"/*.yaml; do
            if [[ -f "$profile" ]]; then
                basename "$profile" .yaml
            fi
        done
    fi
}

# Check if a profile exists
profile_exists() {
    local profile_name="$1"
    [[ -f "$CONFIG_PROFILES_DIR/${profile_name}.yaml" ]]
}

# Get profile file path
get_profile_path() {
    local profile_name="$1"
    echo "$CONFIG_PROFILES_DIR/${profile_name}.yaml"
}

# -----------------------------------------------------------------------------
# Display Helpers
# -----------------------------------------------------------------------------

# Print current config summary
print_config_summary() {
    if is_config_loaded; then
        echo "Profile: $(get_active_profile)"
        echo "Hardware:"
        echo "  Computer: $(hw_get 'COMPUTER_MODEL' 'Unknown')"
        echo "  Video: $(hw_get 'VIDEO_CAPTURE_MODEL' 'Unknown')"
        echo "  Audio: $(hw_get 'AUDIO_INTERFACE_VENDOR' '') $(hw_get 'AUDIO_INTERFACE_MODEL' 'Unknown')"
        echo "Thresholds:"
        echo "  Min Disk: $(threshold_get 'MIN_DISK_SPACE_GB' '?')GB"
        echo "  Max CPU: $(threshold_get 'MAX_CPU_USAGE_PERCENT' '?')%"
    else
        echo "Config not loaded"
    fi
}
