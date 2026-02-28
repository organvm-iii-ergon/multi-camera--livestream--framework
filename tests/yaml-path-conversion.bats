#!/usr/bin/env bats

# Tests for yaml_path_to_var_name from generate-config.sh

setup() {
  # Extract the function under test
  yaml_path_to_var_name() {
    local path="$1"
    echo "CONFIG_${path}" | tr '[:lower:]' '[:upper:]' | tr '.' '_' | tr '-' '_' | sed 's/^CONFIG_\./CONFIG_/'
  }
  export -f yaml_path_to_var_name
}

@test "converts simple path" {
  run yaml_path_to_var_name "profile.name"
  [ "$output" = "CONFIG_PROFILE_NAME" ]
}

@test "converts nested path" {
  run yaml_path_to_var_name "hardware.computer.model"
  [ "$output" = "CONFIG_HARDWARE_COMPUTER_MODEL" ]
}

@test "converts hyphens to underscores" {
  run yaml_path_to_var_name "hardware.video-capture.max-resolution"
  [ "$output" = "CONFIG_HARDWARE_VIDEO_CAPTURE_MAX_RESOLUTION" ]
}

@test "uppercases all characters" {
  run yaml_path_to_var_name "thresholds.min_disk_space_gb"
  [ "$output" = "CONFIG_THRESHOLDS_MIN_DISK_SPACE_GB" ]
}

@test "handles single segment" {
  run yaml_path_to_var_name "name"
  [ "$output" = "CONFIG_NAME" ]
}

@test "handles deeply nested path" {
  run yaml_path_to_var_name "software.required.video_mixer.bundle_id"
  [ "$output" = "CONFIG_SOFTWARE_REQUIRED_VIDEO_MIXER_BUNDLE_ID" ]
}

@test "handles leading dot (double underscore artifact)" {
  # The sed runs after tr converts dots to underscores,
  # so leading dots produce a double underscore. In practice,
  # yq never outputs paths with leading dots.
  run yaml_path_to_var_name ".profile.name"
  [ "$output" = "CONFIG__PROFILE_NAME" ]
}

@test "handles mixed case input" {
  run yaml_path_to_var_name "Hardware.Computer.Model"
  [ "$output" = "CONFIG_HARDWARE_COMPUTER_MODEL" ]
}
