# Pre-Stream Runbook

**Purpose**: Standardized operational procedure for live broadcasts.

**Duration**: ~30–45 minutes before stream start

**Owner**: Person managing technical setup

---

## Phase 1: Network & Dante (10 min)

### Checklist

- [ ] **Ethernet cable plugged in** (Mac → Dante switch dedicated port)
- [ ] **No WiFi enabled** (System Preferences → Network → disable WiFi)
- [ ] **Dante Controller open**, all devices visible
  - MOTU 8PRE-ES: Green light, synced
  - Dante AVIO USB nodes (×2): Green, synced
  - Any other Dante devices: Green
- [ ] **Network latency test**:
  ```bash
  ping -c 5 8.8.8.8
  # Should show <10ms average
  ```
- [ ] **Dante clock status**: MOTU = Primary Clock
  ```
  Dante Controller → View → Network Status
  → Primary Clock Source should be: MOTU 8PRE-ES (Dante Connector 1)
  ```

### Troubleshooting

| Issue | Fix |
|-------|-----|
| Dante devices showing red (not synced) | Restart MOTU: Power off 10 sec, power on, wait 30 sec |
| Network latency >30ms | Check for background uploads, switch network if available |
| WiFi still enabled | Disable in System Preferences → Network (WiFi → Turn Off) |

---

## Phase 2: Audio System (10 min)

### Checklist

- [ ] **MOTU 8PRE-ES powered on** (front panel lights on)
- [ ] **MOTU display shows Dante inputs** active (green lights for channels 1–4)
- [ ] **System audio output set to MOTU**:
  ```bash
  # macOS System Settings → Sound → Output Device
  # Select: MOTU 8PRE-ES (not Built-in Speaker)
  ```
- [ ] **Test Dante audio from camera 1**:
  ```
  Dante Controller → Routing → Camera 1 audio → MOTU In 1
  MOTU front panel → Ch 1 Input: XLR (or USB)
  MOTU console → Meter 1 should show green (signal detected)
  ```
- [ ] **Ableton Live opened, project loaded**:
  - File: `configs/ableton/streaming-template.als`
  - Audio Preferences: Device = MOTU 8PRE-ES
  - Sample Rate = 48 kHz
  - I/O Buffer = 256 samples
- [ ] **Test Ableton output**:
  ```
  Ableton → Create audio track → Set input to MOTU In 1
  Ableton → Play a click track (top menu: Metronome)
  Listen in studio monitors (should hear click from Ableton)
  ```
- [ ] **Studio monitor levels**: Dial at -6 dB (not maxed out)

### Troubleshooting

| Issue | Fix |
|-------|-----|
| No audio from camera | Check Dante routing (did you assign camera audio to MOTU input?) |
| Ableton plays but OBS doesn't hear it | Set OBS audio input to MOTU channels 1–2 (next phase) |
| Feedback/noise in speakers | Mute monitor output in Ableton, use headphones instead |

---

## Phase 3: Video Capture (10 min)

### Checklist

- [ ] **DeckLink Quad HDMI powered on** (Echo Express SE I lights on)
- [ ] **Cameras powered on**, HDMI cables connected to DeckLink
  - Camera 1 → HDMI port 1
  - Camera 2 → HDMI port 2
  - Camera 3 → HDMI port 3
  - Camera 4 → HDMI port 4
- [ ] **OBS Studio opened**, main scene loaded
  - File: `configs/obs/studio-scene.json` (or re-create scene)
- [ ] **OBS sources visible in preview**:
  - Video: DeckLink Quad HDMI (4K mosaic visible)
  - Audio: MOTU 8PRE-ES channels 1–2
  - Both should show in preview pane
- [ ] **OBS resolution confirmed** (Settings → Video Output):
  - Base Canvas: 4096×2160 (4K) or 3840×2160 (UHD)
  - FPS: 30 or 60 (your choice)
  - Render at: GPU (not CPU)
- [ ] **GPU encoding enabled**:
  ```
  OBS → Settings → Output → Streaming
  → Encoder: H.264 (Apple Hardware)
  → Bitrate: 12,000 kbps (12 Mbps)
  ```

### Troubleshooting

| Issue | Fix |
|-------|-----|
| DeckLink not detected in OBS | Restart OBS, check Echo Express firmware in System Report |
| Video at 1080p (not 4K) | HDMI handshake issue—unplug camera 1, wait 10 sec, plug back in |
| GPU encoder not available | Restart OBS, verify M1 Mac (not emulated on Intel) |

---

## Phase 4: Streaming Configuration (5 min)

### Checklist

- [ ] **Streaming service credentials ready**:
  - YouTube: RTMP key copied (YouTube Studio → Go Live → Stream Settings)
  - OR Twitch: RTMP key copied (Dashboard → Settings → Stream Key)
- [ ] **OBS streaming settings configured**:
  ```
  OBS → Settings → Stream
  → Service: YouTube / Twitch (select one)
  → RTMP Server: [auto-filled based on service]
  → Stream Key: [paste your key]
  ```
- [ ] **Test stream** (without going live):
  ```
  OBS → File → Settings → Output
  → Recording Path: /tmp/test-recording.mp4
  → Hit "Start Recording"
  → Record for 10 seconds
  → "Stop Recording"
  → Verify file created: ls -lh /tmp/test-recording.mp4
  ```
- [ ] **Network connection stable**:
  ```bash
  # In terminal, monitor upload speed
  while true; do
    date
    ifstat -i en0 1 1 | tail -1
    sleep 5
  done
  # Look for stable ≥25 Mbps upload
  ```

### Troubleshooting

| Issue | Fix |
|-------|-----|
| "Invalid stream key" error | Regenerate key in YouTube/Twitch dashboard, paste fresh copy |
| OBS can't connect to RTMP | Check internet connection, try `ping google.com` |
| Upload speed <25 Mbps | Switch to wired Ethernet (not WiFi), reduce bitrate in OBS to 8 Mbps |

---

## Phase 5: Caller Setup (5 min, if applicable)

### Checklist

- [ ] **Callers notified** (email with setup instructions at least 1 hour before)
  - Template: `examples/caller-onboarding-example.md`
- [ ] **First caller's OBS NDI stream confirmed active**:
  ```bash
  # On caller's machine, OBS running
  # In your OBS, check:
  OBS → Sources → [NDI Source] → right-click → Refresh
  # Should see caller's stream in list, click to connect
  ```
- [ ] **Caller video visible in OBS preview**:
  - Scene: "Caller 1" (or whichever scene has caller PiP)
  - Caller video should appear in preview
- [ ] **Audio return path tested** (caller hears you):
  - Dante: Caller machine has Dante interface, hearing your Ableton output
  - OR Zoom: Caller joins Zoom call (separate from OBS/NDI video)
  - Test: Say "testing 1-2-3" → Caller confirms heard

### Troubleshooting

| Issue | Fix |
|-------|-----|
| Caller's NDI not appearing in OBS | Ensure caller's OBS is streaming NDI (not to Twitch/YouTube) |
| Caller audio lag >1 sec | Use Dante (preferred), not Zoom audio + NDI video combo |
| Caller can't hear you | Verify Dante return path or Zoom audio channel |

---

## Phase 6: Final Verification (5 min)

### Checklist

- [ ] **All systems green** (run health check script):
  ```bash
  bash software/scripts/health-check.sh
  # Should output: ✓ Dante synced, ✓ DeckLink detected, ✓ OBS audio input recognized
  ```
- [ ] **CPU/GPU load reasonable**:
  ```bash
  # Open Activity Monitor
  # CPU tab: <60% sustained load (should be green)
  # Restart Activity Monitor if needed: top -l 1 | grep "PhysMem"
  ```
- [ ] **Record 10-second test clip** (local storage, not streaming):
  ```
  OBS → File → Start Recording
  Wait 10 seconds
  OBS → File → Stop Recording
  Verify file in ~/Videos/OBS/ (check file size >5 MB)
  ```
- [ ] **Disk space confirmed**:
  ```bash
  df -h / | awk 'NR==2 {print $4}'  # Should show >50 GB available
  ```
- [ ] **Broadcast time**: Set a timer for stream start
- [ ] **Notify team**: "Ready to go live in 5 minutes"

### Troubleshooting

| Issue | Fix |
|-------|-----|
| Health check shows ✗ on any item | See TROUBLESHOOTING.md for detailed remediation |
| CPU load >70% before stream | Close background apps (browser, email, etc.) |
| Disk space <20 GB | Delete old recordings, restart OBS cache |

---

## Phase 7: Go Live (2 min)

### Sequence

1. **T-2 min**: All systems verified green
2. **T-1 min**: Notify callers "Streaming in 60 seconds"
3. **T-0 sec**: Click "Start Streaming" in OBS
4. **T+10 sec**: Refresh YouTube/Twitch to confirm broadcast appears
5. **T+30 sec**: Announce on social media (if applicable)

### Monitoring During Stream

**Every 10 minutes**:
- [ ] OBS stats: Dropped frames should be 0
- [ ] Activity Monitor: CPU/GPU stable (not spiking)
- [ ] MOTU console: Audio levels in range (not clipping)
- [ ] Dante Controller: All devices green (clock not drifting)

**If problem detected**:
- See TROUBLESHOOTING.md for real-time fixes
- Worst case: Stop streaming, restart from Phase 1

---

## Phase 8: Shutdown (5 min)

### Graceful Shutdown Sequence

**DO NOT power off abruptly.** Follow this order:

1. **OBS**: Click "Stop Streaming"
2. **Wait 10 seconds** (allow platform to finalize)
3. **Ableton**: File → Save, then quit
4. **OBS**: File → Exit
5. **MOTU**: Power off (let it shut down cleanly)
6. **DeckLink**: Power off (Echo Express)
7. **Dante switch**: Power off
8. **Cameras**: Power off
9. **Mac**: Shut down normally (Apple menu → Shut Down)

### Post-Broadcast

- [ ] Download broadcast archive from YouTube/Twitch (for backup)
- [ ] Save OBS logs (Help → View Log File)
- [ ] Save Dante network stats (Dante Controller → Export)
- [ ] Fill out incident report (if any issues occurred):
  ```
  templates/incident-report.md
  ```
- [ ] Commit logs to GitHub:
  ```bash
  cd live-streaming-pipeline
  git add tests/logs/broadcast-N.log
  git commit -m "broadcast: date, duration, issues & resolutions"
  ```

---

## Appendix: Quick Reference

### Emergency Stop

If system crashes or goes wrong:
```bash
# Force-quit all applications
killall OBS
killall "Ableton Live"
# Restart Dante network
sudo killall -9 Dante*
# Power-cycle MOTU
# (physically power off for 30 sec)
```

### Revert to Last Known Good Configuration

```bash
cd live-streaming-pipeline
git checkout HEAD -- software/configs/

# Restart OBS with previous config
bash software/scripts/launch-studio.sh
```

### Escalation Contacts

- **DeckLink issues**: Blackmagic support (support@blackmagicdesign.com)
- **Dante issues**: Audinate support (support@audinate.com)
- **MOTU issues**: MOTU support (support@motu.com)

---

**Last Updated**: 2025-01-22
**Author**: Your Name
**Version**: 1.0
