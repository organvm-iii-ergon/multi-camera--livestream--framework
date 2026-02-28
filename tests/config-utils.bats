#!/usr/bin/env bats

# Tests for software/lib/config-utils.sh

setup() {
  # Create a temp dir for test fixtures
  export TEST_DIR="$(mktemp -d)"
  export PROJECT_ROOT="$TEST_DIR/project"
  mkdir -p "$PROJECT_ROOT/software/generated"
  mkdir -p "$PROJECT_ROOT/software/configs/profiles"
  mkdir -p "$PROJECT_ROOT/software/lib"

  # Copy config-utils.sh to the expected location
  cp "$BATS_TEST_DIRNAME/../software/lib/config-utils.sh" "$PROJECT_ROOT/software/lib/"

  # Unset any loaded state from previous tests
  unset _CONFIG_UTILS_LOADED
  unset CONFIG_LOADED
  unset CONFIG_PROFILE_ACTIVE
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "load_config returns 1 when config.sh does not exist" {
  # Source from the test project root
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  # Override the generated path
  CONFIG_GENERATED_SH="$PROJECT_ROOT/software/generated/config.sh"
  run load_config
  [ "$status" -eq 1 ]
}

@test "load_config returns 0 and sets CONFIG_LOADED when config exists" {
  # Create a minimal generated config
  cat > "$PROJECT_ROOT/software/generated/config.sh" <<'CONF'
CONFIG_PROFILE_NAME="test-profile"
CONFIG_THRESHOLDS_MIN_DISK_SPACE_GB="50"
CONF

  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  CONFIG_GENERATED_SH="$PROJECT_ROOT/software/generated/config.sh"
  load_config
  [ "$CONFIG_LOADED" = "true" ]
  [ "$CONFIG_PROFILE_ACTIVE" = "test-profile" ]
}

@test "is_config_loaded returns false when not loaded" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  CONFIG_LOADED=false
  run is_config_loaded
  [ "$status" -ne 0 ]
}

@test "is_config_loaded returns true when loaded" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  CONFIG_LOADED=true
  run is_config_loaded
  [ "$status" -eq 0 ]
}

@test "get_active_profile returns 'none' when no profile" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  CONFIG_PROFILE_ACTIVE=""
  run get_active_profile
  [ "$output" = "none" ]
}

@test "get_active_profile returns profile name" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  CONFIG_PROFILE_ACTIVE="studio"
  run get_active_profile
  [ "$output" = "studio" ]
}

@test "config_get returns value when variable exists" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  export CONFIG_THRESHOLDS_MIN_DISK_SPACE_GB="100"
  run config_get "THRESHOLDS_MIN_DISK_SPACE_GB"
  [ "$output" = "100" ]
}

@test "config_get returns default when variable missing" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  unset CONFIG_SOME_MISSING_KEY 2>/dev/null || true
  run config_get "SOME_MISSING_KEY" "fallback"
  [ "$output" = "fallback" ]
}

@test "config_get returns empty when no variable and no default" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  unset CONFIG_NONEXISTENT 2>/dev/null || true
  run config_get "NONEXISTENT"
  [ "$output" = "" ]
}

@test "hw_get delegates to config_get with HARDWARE_ prefix" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  export CONFIG_HARDWARE_COMPUTER_MODEL="Mac Studio"
  run hw_get "COMPUTER_MODEL"
  [ "$output" = "Mac Studio" ]
}

@test "hw_get returns default when missing" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  unset CONFIG_HARDWARE_NONEXISTENT 2>/dev/null || true
  run hw_get "NONEXISTENT" "Unknown"
  [ "$output" = "Unknown" ]
}

@test "sw_get delegates to config_get with SOFTWARE_ prefix" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  export CONFIG_SOFTWARE_REQUIRED_DAW_APP_NAME="Ableton Live"
  run sw_get "REQUIRED_DAW_APP_NAME"
  [ "$output" = "Ableton Live" ]
}

@test "threshold_get delegates to config_get with THRESHOLDS_ prefix" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  export CONFIG_THRESHOLDS_MAX_CPU_USAGE_PERCENT="70"
  run threshold_get "MAX_CPU_USAGE_PERCENT"
  [ "$output" = "70" ]
}

@test "timing_get delegates to config_get with TIMING_ prefix" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  export CONFIG_TIMING_LAUNCH_DELAY_SECONDS="3"
  run timing_get "LAUNCH_DELAY_SECONDS"
  [ "$output" = "3" ]
}

@test "list_profiles lists yaml files in profiles dir" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  CONFIG_PROFILES_DIR="$PROJECT_ROOT/software/configs/profiles"
  touch "$CONFIG_PROFILES_DIR/studio.yaml"
  touch "$CONFIG_PROFILES_DIR/mobile.yaml"
  run list_profiles
  [[ "$output" == *"studio"* ]]
  [[ "$output" == *"mobile"* ]]
}

@test "profile_exists returns 0 for existing profile" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  CONFIG_PROFILES_DIR="$PROJECT_ROOT/software/configs/profiles"
  touch "$CONFIG_PROFILES_DIR/studio.yaml"
  run profile_exists "studio"
  [ "$status" -eq 0 ]
}

@test "profile_exists returns 1 for missing profile" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  CONFIG_PROFILES_DIR="$PROJECT_ROOT/software/configs/profiles"
  run profile_exists "nonexistent"
  [ "$status" -ne 0 ]
}

@test "get_profile_path returns correct path" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  CONFIG_PROFILES_DIR="$PROJECT_ROOT/software/configs/profiles"
  run get_profile_path "studio"
  [[ "$output" == *"/profiles/studio.yaml" ]]
}

@test "validate_config fails when PROFILE_NAME is missing" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  unset CONFIG_PROFILE_NAME 2>/dev/null || true
  export CONFIG_THRESHOLDS_MIN_DISK_SPACE_GB="50"
  run validate_config
  [ "$status" -ne 0 ]
}

@test "validate_config passes when all required values present" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  export CONFIG_PROFILE_NAME="test"
  export CONFIG_THRESHOLDS_MIN_DISK_SPACE_GB="50"
  run validate_config
  [ "$status" -eq 0 ]
}

@test "matches_detection_pattern matches case-insensitively" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  export CONFIG_HARDWARE_VIDEO_CAPTURE_DETECTION_PATTERNS="decklink blackmagic"
  run matches_detection_pattern "VIDEO_CAPTURE" "Found DeckLink Quad HDMI"
  [ "$status" -eq 0 ]
}

@test "matches_detection_pattern returns 1 when no match" {
  source "$PROJECT_ROOT/software/lib/config-utils.sh"
  export CONFIG_HARDWARE_VIDEO_CAPTURE_DETECTION_PATTERNS="decklink blackmagic"
  run matches_detection_pattern "VIDEO_CAPTURE" "Elgato HD60"
  [ "$status" -ne 0 ]
}
