#!/usr/bin/env bash
#
# generate-config.sh - Generate shell-sourceable config from YAML profiles
#
# This script merges defaults.yaml with a profile (e.g., studio.yaml)
# and generates:
#   - software/generated/config.sh   (shell-sourceable variables)
#   - software/generated/config.json (for other tools/documentation)
#
# Usage:
#   ./generate-config.sh [profile_name]
#   ./generate-config.sh              # Uses 'studio' profile by default
#   ./generate-config.sh mobile       # Uses 'mobile' profile
#   ./generate-config.sh --list       # List available profiles
#
# Requirements:
#   - yq (YAML processor): brew install yq
#
# Author: Dope's Show Pipeline
# Version: 1.0.0

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

CONFIG_DIR="$PROJECT_ROOT/software/configs"
PROFILES_DIR="$CONFIG_DIR/profiles"
DEFAULTS_FILE="$CONFIG_DIR/defaults.yaml"
GENERATED_DIR="$PROJECT_ROOT/software/generated"

DEFAULT_PROFILE="studio"

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
    echo -e "${RED}✗${NC} $1" >&2
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# -----------------------------------------------------------------------------
# Dependency Check
# -----------------------------------------------------------------------------

check_dependencies() {
    if ! command -v yq &>/dev/null; then
        print_error "yq is required but not installed"
        echo ""
        echo "Install with Homebrew:"
        echo "  brew install yq"
        echo ""
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Profile Management
# -----------------------------------------------------------------------------

list_profiles() {
    echo -e "${BOLD}Available profiles:${NC}"
    echo ""
    for profile_file in "$PROFILES_DIR"/*.yaml; do
        if [[ -f "$profile_file" ]]; then
            local name
            name=$(basename "$profile_file" .yaml)
            local desc
            desc=$(yq '.profile.description // "No description"' "$profile_file")
            printf "  %-12s %s\n" "$name" "$desc"
        fi
    done
    echo ""

    # Show current active profile if generated
    if [[ -f "$GENERATED_DIR/config.sh" ]]; then
        # shellcheck source=/dev/null
        source "$GENERATED_DIR/config.sh"
        echo -e "Current active: ${GREEN}${CONFIG_PROFILE_NAME:-unknown}${NC}"
    fi
}

get_profile_file() {
    local profile_name="$1"
    local profile_file="$PROFILES_DIR/${profile_name}.yaml"

    if [[ ! -f "$profile_file" ]]; then
        print_error "Profile not found: $profile_name"
        echo "Available profiles:"
        for p in "$PROFILES_DIR"/*.yaml; do
            echo "  - $(basename "$p" .yaml)"
        done
        exit 1
    fi

    echo "$profile_file"
}

# -----------------------------------------------------------------------------
# YAML to Shell Variable Conversion
# -----------------------------------------------------------------------------

# Convert a YAML path to a shell variable name
# e.g., "hardware.computer.model" -> "CONFIG_HARDWARE_COMPUTER_MODEL"
yaml_path_to_var_name() {
    local path="$1"
    # Remove leading dot if present, add CONFIG_ prefix, convert to uppercase
    echo "CONFIG_${path}" | tr '[:lower:]' '[:upper:]' | tr '.' '_' | tr '-' '_' | sed 's/^CONFIG_\./CONFIG_/'
}

# Recursively extract all leaf values from YAML and convert to shell variables
yaml_to_shell_vars() {
    local yaml_file="$1"
    local prefix="${2:-.}"

    # Get all paths that have scalar values (not arrays or objects with children)
    yq -r '
        .. | select(type == "!!str" or type == "!!int" or type == "!!float" or type == "!!bool") |
        path | join(".")
    ' "$yaml_file" 2>/dev/null | while read -r path; do
        if [[ -n "$path" ]]; then
            local value
            value=$(yq -r ".$path" "$yaml_file" 2>/dev/null)
            local var_name
            var_name=$(yaml_path_to_var_name "$path")

            # Skip multiline values (like notes) - they don't work well in shell
            if [[ "$value" == *$'\n'* ]]; then
                continue
            fi

            # Escape special characters in value
            value="${value//\\/\\\\}"
            value="${value//\"/\\\"}"
            value="${value//\$/\\\$}"
            # Escape backticks
            value="${value//\`/\\\`}"
            # Escape parentheses for safety
            value="${value//(/\\(}"
            value="${value//)/\\)}"
            echo "${var_name}=\"${value}\""
        fi
    done

    # Handle arrays specially - convert to space-separated strings
    yq -r '
        .. | select(type == "!!seq") |
        path | join(".")
    ' "$yaml_file" 2>/dev/null | while read -r path; do
        if [[ -n "$path" ]]; then
            # Check if it's an array of scalars (not objects)
            local first_type
            first_type=$(yq -r ".$path[0] | type" "$yaml_file" 2>/dev/null)
            if [[ "$first_type" == "!!str" ]] || [[ "$first_type" == "!!int" ]]; then
                local values
                values=$(yq -r ".$path[]" "$yaml_file" 2>/dev/null | tr '\n' ' ' | sed 's/ $//')
                local var_name
                var_name=$(yaml_path_to_var_name "$path")
                echo "${var_name}=\"${values}\""
            fi
        fi
    done
}

# -----------------------------------------------------------------------------
# Config Generation
# -----------------------------------------------------------------------------

generate_config() {
    local profile_name="$1"
    local profile_file
    profile_file=$(get_profile_file "$profile_name")

    print_step "Generating config for profile: $profile_name"

    # Create generated directory
    mkdir -p "$GENERATED_DIR"

    # Create temporary merged YAML (use global for trap)
    _MERGED_YAML_TMP=$(mktemp)
    local merged_yaml="$_MERGED_YAML_TMP"
    trap 'rm -f "$_MERGED_YAML_TMP" 2>/dev/null' EXIT

    # Merge defaults with profile (profile values override defaults)
    print_step "Merging defaults with profile..."
    yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
        "$DEFAULTS_FILE" "$profile_file" > "$merged_yaml"

    # Generate shell config
    print_step "Generating config.sh..."
    {
        echo "#!/usr/bin/env bash"
        echo "#"
        echo "# config.sh - Generated configuration (DO NOT EDIT)"
        echo "#"
        echo "# Generated from: $profile_name"
        echo "# Generated at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "#"
        echo "# Source this file in scripts:"
        echo "#   source \"\$SCRIPT_DIR/../generated/config.sh\""
        echo "#"
        echo ""
        echo "# Prevent multiple sourcing"
        echo "[[ -n \"\${_CONFIG_SH_LOADED:-}\" ]] && return 0"
        echo "_CONFIG_SH_LOADED=1"
        echo ""
        echo "# ==================================================================="
        echo "# GENERATED CONFIGURATION VARIABLES"
        echo "# ==================================================================="
        echo ""

        # Extract and convert all values
        yaml_to_shell_vars "$merged_yaml" | sort | uniq

        echo ""
        echo "# ==================================================================="
        echo "# EXPORT ALL CONFIG VARIABLES"
        echo "# ==================================================================="
        echo ""
        echo "# Export all CONFIG_ variables"
        echo 'for var in $(compgen -v | grep "^CONFIG_"); do'
        echo '    export "$var"'
        echo 'done'

    } > "$GENERATED_DIR/config.sh"

    chmod +x "$GENERATED_DIR/config.sh"
    print_success "Generated: $GENERATED_DIR/config.sh"

    # Generate JSON config
    print_step "Generating config.json..."
    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Use yq to merge metadata with config and output as JSON
    yq -o=json '. * {"_generated": {"profile": "'"$profile_name"'", "timestamp": "'"$timestamp"'"}}' "$merged_yaml" > "$GENERATED_DIR/config.json"

    print_success "Generated: $GENERATED_DIR/config.json"

    # Create/update symlink to active profile
    local active_link="$CONFIG_DIR/active"
    rm -f "$active_link"
    ln -sf "profiles/${profile_name}.yaml" "$active_link"
    print_success "Active profile linked: $active_link -> profiles/${profile_name}.yaml"

    # Summary
    echo ""
    echo -e "${BOLD}Configuration generated successfully!${NC}"
    echo ""
    echo "Files created:"
    echo "  $GENERATED_DIR/config.sh"
    echo "  $GENERATED_DIR/config.json"
    echo ""
    echo "To use in scripts:"
    echo "  source \"\$SCRIPT_DIR/../lib/config-utils.sh\""
    echo "  load_config"
    echo ""
}

# -----------------------------------------------------------------------------
# Validation
# -----------------------------------------------------------------------------

validate_generated_config() {
    local config_file="$GENERATED_DIR/config.sh"

    if [[ ! -f "$config_file" ]]; then
        print_error "Config file not found: $config_file"
        return 1
    fi

    # Syntax check
    if bash -n "$config_file"; then
        print_success "Config syntax valid"
    else
        print_error "Config has syntax errors"
        return 1
    fi

    # Source and check for key variables
    (
        # shellcheck source=/dev/null
        source "$config_file"
        if [[ -z "${CONFIG_PROFILE_NAME:-}" ]]; then
            echo "Missing: CONFIG_PROFILE_NAME"
            exit 1
        fi
        if [[ -z "${CONFIG_THRESHOLDS_MIN_DISK_SPACE_GB:-}" ]]; then
            echo "Missing: CONFIG_THRESHOLDS_MIN_DISK_SPACE_GB"
            exit 1
        fi
    )

    print_success "Config validation passed"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    local profile="${1:-$DEFAULT_PROFILE}"

    # Handle flags
    case "$profile" in
        --list|-l)
            list_profiles
            exit 0
            ;;
        --help|-h)
            echo "Usage: $0 [profile_name|--list|--help]"
            echo ""
            echo "Options:"
            echo "  profile_name    Name of profile to generate (default: studio)"
            echo "  --list, -l      List available profiles"
            echo "  --help, -h      Show this help"
            echo ""
            echo "Examples:"
            echo "  $0              Generate config from 'studio' profile"
            echo "  $0 mobile       Generate config from 'mobile' profile"
            echo "  $0 --list       Show available profiles"
            exit 0
            ;;
        --*)
            print_error "Unknown option: $profile"
            exit 1
            ;;
    esac

    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║     DOPE'S SHOW - CONFIG GENERATOR                            ║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_dependencies
    generate_config "$profile"
    validate_generated_config
}

main "$@"
