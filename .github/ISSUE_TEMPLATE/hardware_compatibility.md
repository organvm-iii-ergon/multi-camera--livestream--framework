---
name: Hardware Compatibility Report
about: Report test results for hardware configurations
title: '[HARDWARE] '
labels: hardware, compatibility
assignees: ''
---

## Hardware Configuration

### Computer

| Spec | Value |
|------|-------|
| Model | <!-- e.g., Mac Studio M1 Max --> |
| CPU | <!-- e.g., M1 Max 10-core --> |
| GPU | <!-- e.g., M1 Max 32-core --> |
| RAM | <!-- e.g., 64GB --> |
| Storage | <!-- e.g., 1TB SSD --> |
| macOS Version | <!-- e.g., 14.2.1 --> |

### Video Capture

| Spec | Value |
|------|-------|
| Capture Device | <!-- e.g., DeckLink Quad HDMI --> |
| Connection | <!-- e.g., TB3 via Echo Express SE I --> |
| Driver Version | <!-- e.g., Desktop Video 13.2 --> |

### Audio Interface

| Spec | Value |
|------|-------|
| Audio Device | <!-- e.g., MOTU 8PRE-ES --> |
| Connection | <!-- e.g., Dante via Ethernet --> |
| Driver Version | <!-- e.g., 2.23.5 --> |

### Cameras

| Camera | Model | Connection | Resolution |
|--------|-------|------------|------------|
| Camera 1 | <!-- model --> | HDMI | <!-- e.g., 1080p60 --> |
| Camera 2 | <!-- model --> | HDMI | <!-- e.g., 1080p60 --> |
| Camera 3 | <!-- model --> | HDMI | <!-- e.g., 1080p60 --> |
| Camera 4 | <!-- model --> | HDMI | <!-- e.g., 1080p60 --> |

## Test Results

### Test Duration

<!-- How long did you run the test? e.g., 4 hours -->

### Metrics

| Metric | Result |
|--------|--------|
| CPU Temperature (avg) | <!-- e.g., 65°C --> |
| GPU Temperature (avg) | <!-- e.g., 55°C --> |
| CPU Usage (avg) | <!-- e.g., 45% --> |
| Memory Usage (avg) | <!-- e.g., 32GB --> |
| Dropped Frames | <!-- e.g., 0 --> |

### Configuration Tested

- [x] 4-camera capture
- [ ] 3-camera capture
- [ ] 2-camera capture
- [ ] 1-camera capture

- [x] 1080p60
- [ ] 1080p30
- [ ] 4K30
- [ ] 4K60

- [x] Dante audio
- [ ] USB audio
- [ ] HDMI embedded audio

### Streaming Test

| Parameter | Value |
|-----------|-------|
| Platform | <!-- e.g., YouTube --> |
| Resolution | <!-- e.g., 1080p60 --> |
| Bitrate | <!-- e.g., 6000 kbps --> |
| Duration | <!-- e.g., 2 hours --> |
| Dropped Frames | <!-- e.g., 0 --> |

## Issues Encountered

<!-- Describe any issues, even minor ones -->

### Critical Issues

<!-- Issues that prevented streaming -->

### Minor Issues

<!-- Issues that were workarounds or didn't affect streaming -->

### Workarounds Applied

<!-- Any non-standard configuration needed -->

## Overall Assessment

- [ ] ✅ Fully compatible - no issues
- [ ] ⚠️ Compatible with minor issues
- [ ] ❌ Not recommended - significant issues

## Notes

<!-- Any additional observations or recommendations -->

## Checklist

- [ ] Ran `setup-macos.sh` and all checks passed
- [ ] Ran `health-check.sh` before testing
- [ ] Tested for at least 1 hour continuously
- [ ] Documented all issues encountered
