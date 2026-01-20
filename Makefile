# Makefile - Build automation for Dope's Show configuration system
#
# Usage:
#   make config           Generate config from default profile (studio)
#   make config PROFILE=mobile   Generate config from mobile profile
#   make docs             Generate documentation from templates
#   make all              Generate both config and docs
#   make clean            Remove all generated files
#   make switch-profile PROFILE=mobile   Switch active profile
#   make list-profiles    List available profiles
#   make validate         Validate all scripts
#
# Version: 1.0.0

.PHONY: all config docs clean switch-profile list-profiles validate help install-deps

# Default profile
PROFILE ?= studio

# Script paths
SCRIPTS_DIR := software/scripts
CONFIG_SCRIPT := $(SCRIPTS_DIR)/generate-config.sh
DOCS_SCRIPT := $(SCRIPTS_DIR)/generate-docs.sh
SETUP_SCRIPT := $(SCRIPTS_DIR)/setup-macos.sh
HEALTH_SCRIPT := $(SCRIPTS_DIR)/health-check.sh
LAUNCH_SCRIPT := $(SCRIPTS_DIR)/launch-studio.sh
SHUTDOWN_SCRIPT := $(SCRIPTS_DIR)/shutdown-studio.sh

# Generated paths
GENERATED_DIR := software/generated
CONFIG_SH := $(GENERATED_DIR)/config.sh
CONFIG_JSON := $(GENERATED_DIR)/config.json

# Default target
all: config docs

# Generate configuration from YAML profile
config: $(CONFIG_SH)

$(CONFIG_SH): software/configs/profiles/$(PROFILE).yaml software/configs/defaults.yaml
	@echo "Generating configuration for profile: $(PROFILE)"
	@./$(CONFIG_SCRIPT) $(PROFILE)

# Generate documentation from templates
docs: config
	@echo "Generating documentation..."
	@./$(DOCS_SCRIPT)

# Switch to a different profile
switch-profile:
	@echo "Switching to profile: $(PROFILE)"
	@./$(CONFIG_SCRIPT) $(PROFILE)
	@./$(DOCS_SCRIPT)

# List available profiles
list-profiles:
	@./$(CONFIG_SCRIPT) --list

# Clean all generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf $(GENERATED_DIR)
	@rm -f software/configs/active
	@echo "Done."

# Validate all shell scripts
validate:
	@echo "Validating shell scripts..."
	@bash -n $(CONFIG_SCRIPT) && echo "✓ $(CONFIG_SCRIPT)"
	@bash -n $(DOCS_SCRIPT) && echo "✓ $(DOCS_SCRIPT)"
	@bash -n $(SETUP_SCRIPT) && echo "✓ $(SETUP_SCRIPT)"
	@bash -n $(HEALTH_SCRIPT) && echo "✓ $(HEALTH_SCRIPT)"
	@bash -n $(LAUNCH_SCRIPT) && echo "✓ $(LAUNCH_SCRIPT)"
	@bash -n $(SHUTDOWN_SCRIPT) && echo "✓ $(SHUTDOWN_SCRIPT)"
	@bash -n software/lib/config-utils.sh && echo "✓ software/lib/config-utils.sh"
	@echo "All scripts valid."

# Install dependencies
install-deps:
	@echo "Installing dependencies..."
	@which yq > /dev/null || brew install yq
	@which envsubst > /dev/null || brew install gettext
	@echo "Dependencies installed."

# Run health check
health-check: config
	@./$(HEALTH_SCRIPT)

# Run setup verification
setup: config
	@./$(SETUP_SCRIPT)

# Show help
help:
	@echo "Dope's Show - Configuration System"
	@echo ""
	@echo "Usage:"
	@echo "  make config              Generate config (default: studio profile)"
	@echo "  make config PROFILE=X    Generate config from profile X"
	@echo "  make docs                Generate documentation"
	@echo "  make all                 Generate config and docs"
	@echo "  make switch-profile PROFILE=X   Switch to profile X"
	@echo "  make list-profiles       List available profiles"
	@echo "  make clean               Remove generated files"
	@echo "  make validate            Validate all scripts"
	@echo "  make install-deps        Install required tools (yq, gettext)"
	@echo "  make health-check        Run pre-stream health check"
	@echo "  make setup               Run system setup verification"
	@echo ""
	@echo "Current profile: $(PROFILE)"
	@echo ""
	@echo "Examples:"
	@echo "  make                     # Generate config and docs for 'studio'"
	@echo "  make PROFILE=mobile      # Generate for 'mobile' profile"
	@echo "  make switch-profile PROFILE=backup"
