#!/usr/bin/env bash
#
# generate-docs.sh - Generate documentation from templates
#
# This script processes documentation templates (*.tmpl) and replaces
# {{VAR_NAME}} placeholders with values from the generated config.
#
# Usage:
#   ./generate-docs.sh           # Generate docs using current config
#   ./generate-docs.sh --clean   # Remove generated docs
#
# Requirements:
#   - Generated config (run generate-config.sh first)
#   - envsubst (from gettext): brew install gettext
#
# Author: Dope's Show Pipeline
# Version: 1.0.0

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

TEMPLATES_DIR="$PROJECT_ROOT/software/templates/docs"
GENERATED_DOCS_DIR="$PROJECT_ROOT/software/generated/docs"
CONFIG_SH="$PROJECT_ROOT/software/generated/config.sh"

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
    # Check for envsubst (from gettext)
    if ! command -v envsubst &>/dev/null; then
        # On macOS with Homebrew, envsubst might be in a non-standard location
        if [[ -f "/opt/homebrew/opt/gettext/bin/envsubst" ]]; then
            export PATH="/opt/homebrew/opt/gettext/bin:$PATH"
        elif [[ -f "/usr/local/opt/gettext/bin/envsubst" ]]; then
            export PATH="/usr/local/opt/gettext/bin:$PATH"
        else
            print_error "envsubst is required but not installed"
            echo ""
            echo "Install with Homebrew:"
            echo "  brew install gettext"
            echo ""
            exit 1
        fi
    fi
}

check_config() {
    if [[ ! -f "$CONFIG_SH" ]]; then
        print_error "Configuration not found: $CONFIG_SH"
        echo ""
        echo "Run generate-config.sh first:"
        echo "  ./software/scripts/generate-config.sh"
        echo ""
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Template Processing
# -----------------------------------------------------------------------------

# Convert {{VAR}} syntax to $VAR for envsubst
convert_template_syntax() {
    local template_file="$1"
    # Convert {{VAR_NAME}} to ${VAR_NAME}
    sed 's/{{\([^}]*\)}}/${\1}/g' "$template_file"
}

# Process a single template file
process_template() {
    local template_file="$1"
    local output_file="$2"

    print_step "Processing: $(basename "$template_file")"

    # Convert template syntax and process with envsubst
    convert_template_syntax "$template_file" | envsubst > "$output_file"

    # Check if any unsubstituted variables remain
    local unsubstituted
    unsubstituted=$(grep -oE '\$\{[A-Z_]+\}' "$output_file" 2>/dev/null | sort -u || true)

    if [[ -n "$unsubstituted" ]]; then
        print_warn "Unsubstituted variables in $(basename "$output_file"):"
        echo "$unsubstituted" | while read -r var; do
            echo "    $var"
        done
    fi

    print_success "Generated: $(basename "$output_file")"
}

# Process all templates
process_all_templates() {
    local template_count=0
    local generated_count=0

    for template in "$TEMPLATES_DIR"/*.tmpl; do
        if [[ -f "$template" ]]; then
            template_count=$((template_count + 1))

            local basename
            basename=$(basename "$template" .tmpl)
            local output_file="$GENERATED_DOCS_DIR/$basename"

            if process_template "$template" "$output_file"; then
                generated_count=$((generated_count + 1))
            fi
        fi
    done

    echo ""
    echo "Templates processed: $template_count"
    echo "Documents generated: $generated_count"
}

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------

clean_generated() {
    print_step "Cleaning generated documentation..."

    if [[ -d "$GENERATED_DOCS_DIR" ]]; then
        rm -rf "$GENERATED_DOCS_DIR"
        print_success "Removed: $GENERATED_DOCS_DIR"
    else
        print_warn "Nothing to clean"
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    # Handle flags
    case "${1:-}" in
        --clean|-c)
            clean_generated
            exit 0
            ;;
        --help|-h)
            echo "Usage: $0 [--clean|--help]"
            echo ""
            echo "Options:"
            echo "  --clean, -c    Remove generated documentation"
            echo "  --help, -h     Show this help"
            echo ""
            echo "Templates are read from:"
            echo "  $TEMPLATES_DIR"
            echo ""
            echo "Generated docs are written to:"
            echo "  $GENERATED_DOCS_DIR"
            exit 0
            ;;
    esac

    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║     DOPE'S SHOW - DOCUMENTATION GENERATOR                     ║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_dependencies
    check_config

    # Load configuration and export all variables
    print_step "Loading configuration..."
    set -a  # Auto-export all variables
    # shellcheck source=/dev/null
    source "$CONFIG_SH"

    # Add extra variables for templates
    GENERATED_DATE=$(date '+%Y-%m-%d')
    export GENERATED_DATE

    set +a
    print_success "Configuration loaded: ${CONFIG_PROFILE_NAME:-unknown}"

    # Create output directory
    mkdir -p "$GENERATED_DOCS_DIR"

    # Check for templates
    if [[ ! -d "$TEMPLATES_DIR" ]] || [[ -z "$(ls -A "$TEMPLATES_DIR"/*.tmpl 2>/dev/null)" ]]; then
        print_warn "No templates found in: $TEMPLATES_DIR"
        exit 0
    fi

    echo ""
    echo -e "${BOLD}Processing Templates${NC}"
    echo "═══════════════════════════════════════"
    echo ""

    process_all_templates

    echo ""
    echo -e "${BOLD}═══════════════════════════════════════${NC}"
    echo -e "${BOLD}  DOCUMENTATION GENERATED${NC}"
    echo -e "${BOLD}═══════════════════════════════════════${NC}"
    echo ""
    echo "Generated docs available at:"
    echo "  $GENERATED_DOCS_DIR"
    echo ""
    echo "To view generated files:"
    echo "  ls $GENERATED_DOCS_DIR"
    echo ""
}

main "$@"
