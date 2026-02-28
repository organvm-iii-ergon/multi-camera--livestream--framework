#!/usr/bin/env bats

# Tests for format_category function from health-check.sh
# We extract and test it in isolation

setup() {
  # Define the function under test (extracted from health-check.sh)
  format_category() {
    local cat="$1"
    cat="${cat/pcie/PCIe}"
    cat="${cat/usb/USB}"
    cat="${cat/ndi/NDI}"
    cat="${cat/sdi/SDI}"
    cat="${cat/nvme/NVMe}"
    cat="${cat/ssd/SSD}"
    cat="${cat/hdd/HDD}"
    cat="${cat/10gbe/10GbE}"
    cat="${cat//_/ }"
    echo "$cat" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1'
  }
  export -f format_category
}

@test "format_category converts pcie_capture" {
  run format_category "pcie_capture"
  [ "$output" = "PCIe Capture" ]
}

@test "format_category converts usb_capture" {
  run format_category "usb_capture"
  [ "$output" = "USB Capture" ]
}

@test "format_category converts ndi_source" {
  run format_category "ndi_source"
  [ "$output" = "NDI Source" ]
}

@test "format_category converts workstation" {
  run format_category "workstation"
  [ "$output" = "Workstation" ]
}

@test "format_category converts gigabit_ethernet" {
  run format_category "gigabit_ethernet"
  [ "$output" = "Gigabit Ethernet" ]
}

@test "format_category converts nvme_storage" {
  run format_category "nvme_storage"
  [ "$output" = "NVMe Storage" ]
}

@test "format_category converts ssd" {
  run format_category "ssd"
  [ "$output" = "SSD" ]
}

@test "format_category converts 10gbe" {
  run format_category "10gbe"
  [ "$output" = "10GbE" ]
}

@test "format_category converts interface" {
  run format_category "interface"
  [ "$output" = "Interface" ]
}

@test "format_category converts dante_interface" {
  run format_category "dante_interface"
  [ "$output" = "Dante Interface" ]
}
