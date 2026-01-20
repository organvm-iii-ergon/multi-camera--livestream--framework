# Troubleshooting Guide

> Decision-tree format troubleshooting for common issues in the Multi-Camera Livestream Framework.

**Last Updated:** <!-- TODO: Update date -->
**Version:** 1.0.0

---

## Quick Navigation

- [No Video Signal](#no-video-signal)
- [No Audio](#no-audio)
- [Audio Sync Issues](#audio-sync-issues)
- [Dropped Frames](#dropped-frames)
- [Stream Disconnection](#stream-disconnection)
- [Software Crashes](#software-crashes)
- [Hardware Issues](#hardware-issues)
- [Network Problems](#network-problems)
- [Emergency Recovery](#emergency-recovery)

---

## No Video Signal

```
Camera not showing in OBS?
│
├─ Is the camera powered on?
│  ├─ No → Power on camera
│  └─ Yes → Continue
│
├─ Is HDMI cable connected at both ends?
│  ├─ No → Connect cable securely
│  └─ Yes → Continue
│
├─ Does camera show signal on its LCD?
│  ├─ No → Check camera settings, ensure HDMI output enabled
│  └─ Yes → Continue
│
├─ Is Echo Express chassis powered?
│  ├─ No → Power on chassis, wait 30 seconds
│  └─ Yes → Continue
│
├─ Does Desktop Video Setup show signal?
│  ├─ No → DeckLink not detecting signal
│  │  ├─ Try different HDMI input on DeckLink
│  │  ├─ Try different HDMI cable
│  │  └─ Restart Echo Express chassis
│  └─ Yes → Continue
│
├─ Is OBS source configured correctly?
│  ├─ Check source properties match camera format
│  ├─ Try removing and re-adding source
│  └─ Verify correct DeckLink input selected
│
└─ Still not working?
   ├─ Restart OBS
   ├─ Restart Mac Studio
   └─ Check COMPATIBILITY.md for known issues
```

---

## No Audio

```
No audio in OBS/stream?
│
├─ Check: Where is audio expected from?
│  ├─ Dante/MOTU → Go to Dante Audio Path
│  └─ HDMI embedded → Go to HDMI Audio Path
│
├─ DANTE AUDIO PATH
│  ├─ Is MOTU 8PRE-ES powered on?
│  │  ├─ No → Power on, wait for boot (LEDs stabilize)
│  │  └─ Yes → Continue
│  │
│  ├─ Does Dante Controller show MOTU?
│  │  ├─ No → Check Ethernet connection to Dante switch
│  │  └─ Yes → Continue
│  │
│  ├─ Is audio routing configured in Dante Controller?
│  │  ├─ No → Configure routing matrix
│  │  └─ Yes → Continue
│  │
│  ├─ Does Ableton receive audio?
│  │  ├─ No → Check Ableton audio preferences
│  │  │  ├─ Correct audio device selected?
│  │  │  └─ Correct input channels enabled?
│  │  └─ Yes → Continue
│  │
│  └─ Does OBS receive audio from Ableton?
│     ├─ Check virtual audio cable routing
│     └─ Check OBS audio mixer levels
│
├─ HDMI AUDIO PATH (if using)
│  ├─ Is camera set to output audio via HDMI?
│  ├─ Is OBS source configured to capture audio?
│  └─ Check OBS audio mixer for HDMI source
│
└─ Still no audio?
   ├─ Restart Dante Controller
   ├─ Restart Ableton Live
   ├─ Check macOS Sound preferences
   └─ Verify no mutes active anywhere in chain
```

---

## Audio Sync Issues

```
Audio out of sync with video?
│
├─ Is audio ahead or behind video?
│  ├─ AHEAD → Add positive sync offset in OBS
│  └─ BEHIND → Add negative sync offset in OBS
│
├─ How to adjust in OBS:
│  ├─ Right-click audio source in Mixer
│  ├─ Advanced Audio Properties
│  └─ Adjust Sync Offset (ms)
│     ├─ Start with ±50ms increments
│     └─ Test with clap test
│
├─ Is sync consistent or drifting?
│  ├─ DRIFTING → Clock sync issue
│  │  ├─ Check Dante clock master (MOTU should be master)
│  │  ├─ Verify all devices same sample rate (48kHz)
│  │  └─ Check for multiple clock masters
│  └─ CONSISTENT → Static offset, adjust and done
│
├─ Sync only affects certain sources?
│  ├─ Check individual source sync offsets
│  ├─ Check processing delays in Ableton
│  └─ Verify source formats match (frame rate)
│
└─ Sync keeps changing?
   ├─ Check CPU load (processing delays vary with load)
   ├─ Simplify Ableton project
   └─ Use hardware monitoring where possible
```

---

## Dropped Frames

```
OBS showing dropped frames?
│
├─ Check OBS Stats (View → Stats)
│
├─ Which type of drops?
│  │
│  ├─ "Frames missed due to rendering lag"
│  │  ├─ GPU is overloaded
│  │  ├─ Simplify scenes (fewer sources, effects)
│  │  ├─ Lower preview resolution
│  │  └─ Close other GPU-intensive apps
│  │
│  ├─ "Skipped frames due to encoding lag"
│  │  ├─ Encoder can't keep up
│  │  ├─ Switch to hardware encoder (Apple VT)
│  │  ├─ Use faster x264 preset
│  │  ├─ Lower output resolution
│  │  └─ Lower frame rate
│  │
│  └─ "Dropped frames due to network issues"
│     ├─ Upload can't sustain bitrate
│     ├─ Lower bitrate
│     ├─ Check network connection (use wired)
│     ├─ Test upload speed
│     └─ Check for network congestion
│
├─ Drops only during specific actions?
│  ├─ Scene transitions → Simplify transitions
│  ├─ Certain scenes → Check those scene sources
│  └─ After time passes → Memory leak, restart OBS
│
└─ Consistent drops throughout?
   ├─ System resources insufficient
   ├─ Check Activity Monitor
   ├─ Close unnecessary applications
   └─ Consider hardware upgrade
```

---

## Stream Disconnection

```
Stream keeps disconnecting?
│
├─ How frequently?
│  ├─ Every few seconds → Severe network issue
│  ├─ Every few minutes → Moderate network issue
│  └─ Random/rare → Intermittent issue
│
├─ Check OBS connection status
│  ├─ View → Stats → check connection indicator
│  └─ Check log for disconnect reasons
│
├─ Network checks:
│  ├─ Using wired Ethernet?
│  │  └─ No → Switch to wired immediately
│  ├─ Run speed test during issue
│  ├─ Check for packet loss: ping -c 100 8.8.8.8
│  └─ Check router/modem status lights
│
├─ Platform-specific:
│  ├─ Try different RTMP server
│  ├─ Check platform status page
│  └─ Re-copy stream key (may have expired)
│
├─ OBS settings:
│  ├─ Enable "Automatically Reconnect"
│  ├─ Lower bitrate (reduce network stress)
│  └─ Increase retry delay
│
└─ Still disconnecting?
   ├─ Contact ISP
   ├─ Try streaming from different network
   └─ Use cellular hotspot as emergency backup
```

---

## Software Crashes

### OBS Crashes

```
OBS crashes or freezes?
│
├─ When does it crash?
│  ├─ On startup → Config corruption
│  │  ├─ Delete scene collection, rebuild
│  │  └─ Reset OBS profile
│  │
│  ├─ When adding source → Plugin issue
│  │  ├─ Disable recently added plugins
│  │  └─ Check plugin compatibility
│  │
│  ├─ During stream → Resource issue
│  │  ├─ Check memory usage
│  │  ├─ Simplify scenes
│  │  └─ Update OBS
│  │
│  └─ Random → Various causes
│     ├─ Check Console.app for crash logs
│     └─ Update macOS and OBS
│
└─ OBS frozen but not crashed?
   ├─ Wait 60 seconds (might be processing)
   ├─ Force quit: Cmd+Option+Esc
   └─ Kill via terminal: pkill -9 obs
```

### Ableton Crashes

```
Ableton crashes or freezes?
│
├─ When does it crash?
│  ├─ Opening project → Corrupt project
│  │  ├─ Try opening Auto-Backup version
│  │  └─ Create new project, import tracks
│  │
│  ├─ During audio playback → Plugin issue
│  │  ├─ Open project with plugins disabled (hold Option on load)
│  │  ├─ Enable plugins one by one to find culprit
│  │  └─ Update/replace problematic plugin
│  │
│  └─ Randomly → Resource issue
│     ├─ Increase audio buffer size
│     └─ Freeze/flatten heavy tracks
│
└─ Audio dropouts in Ableton?
   ├─ Increase buffer size (Preferences → Audio)
   ├─ Reduce sample rate (48kHz → 44.1kHz)
   └─ Close other audio apps
```

---

## Hardware Issues

### DeckLink Not Detected

```
DeckLink card not recognized?
│
├─ Check System Report → Thunderbolt
│  ├─ Is Echo Express listed?
│  │  ├─ No → Thunderbolt connection issue
│  │  │  ├─ Check cable connection
│  │  │  ├─ Try different TB port
│  │  │  └─ Power cycle chassis
│  │  └─ Yes → Continue
│  │
│  └─ Is DeckLink listed under PCI?
│     ├─ No → Card not seated properly or driver issue
│     │  ├─ Reseat card in chassis (power off first!)
│     │  └─ Reinstall Desktop Video drivers
│     └─ Yes → Card detected, check OBS sources
│
└─ After macOS update?
   ├─ Check for updated Desktop Video drivers
   ├─ Grant permissions in System Preferences → Privacy
   └─ May need to allow system extension
```

### MOTU Not Responding

```
MOTU 8PRE-ES issues?
│
├─ Front panel LEDs status?
│  ├─ No LEDs → No power
│  │  └─ Check power connection
│  ├─ Flashing LEDs → Booting or error
│  │  └─ Wait for stable state or power cycle
│  └─ Stable LEDs → Powered, continue
│
├─ Not visible in Dante Controller?
│  ├─ Check Ethernet cable
│  ├─ Verify switch connection
│  ├─ Try direct connection to Mac
│  └─ Power cycle MOTU
│
├─ Audio issues?
│  ├─ Check input gain (preamp knobs)
│  ├─ Verify phantom power if needed (+48V)
│  └─ Check web interface for detailed status
│
└─ Clock sync errors?
   ├─ Verify MOTU is set as clock master
   └─ Check sample rate consistency
```

---

## Network Problems

### Dante Network Issues

```
Dante network not working?
│
├─ Dante Controller shows no devices?
│  ├─ Firewall blocking? → Allow Dante Controller
│  ├─ Correct network interface? → Check settings
│  └─ Devices on same subnet? → Verify IP addresses
│
├─ Audio dropouts on Dante?
│  ├─ Check clock sync status (should be green)
│  ├─ Check switch for errors
│  ├─ Try different Dante latency setting
│  └─ Verify dedicated Dante network (no other traffic)
│
└─ Device shows red status?
   ├─ Clock sync error → Check clock master config
   ├─ Network error → Check physical connection
   └─ Device error → Power cycle device
```

### Internet Connectivity

```
Internet connection issues?
│
├─ Complete outage?
│  ├─ Check other devices
│  ├─ Check modem/router
│  └─ Contact ISP
│
├─ Slow/intermittent?
│  ├─ Run speed test
│  ├─ Check for local congestion
│  └─ Try different DNS (8.8.8.8, 1.1.1.1)
│
└─ Stream-specific issues?
   ├─ Platform status page shows issues?
   ├─ Try different RTMP server
   └─ Lower bitrate
```

---

## Emergency Recovery

### Mid-Stream Emergency

If something fails during a live stream:

1. **Stay calm** - Viewers will wait briefly
2. **Keep audio rolling** if possible (apologize, explain technical difficulties)
3. **Don't end stream** unless absolutely necessary

#### Quick Recovery Actions

| Issue | Quick Fix | Time |
|-------|-----------|------|
| OBS frozen | Force quit, relaunch | 30-60 sec |
| Video source gone | Remove/re-add source | 15-30 sec |
| Audio gone | Check mutes, restart source | 15-30 sec |
| Stream dropped | OBS auto-reconnects | 5-15 sec |
| Complete system hang | Restart Mac | 2-3 min |

#### Emergency Hotkeys

Configure in OBS Settings → Hotkeys:

| Hotkey | Action |
|--------|--------|
| F1 | Switch to safe scene (static image) |
| F2 | Mute all audio |
| F3 | Start/stop streaming |
| F4 | Start/stop recording |

### Post-Incident

After any significant issue:

1. Document what happened (software/templates/incident-report.md)
2. Review logs
3. Identify root cause
4. Update troubleshooting docs
5. Add preventive checks to RUNBOOK

---

## Collecting Diagnostic Information

### For Bug Reports

Gather this information:

```bash
# macOS version
sw_vers

# OBS version
/Applications/OBS.app/Contents/MacOS/OBS --version

# Check running processes
ps aux | grep -E "(obs|ableton|dante)"

# System load
top -l 1 -n 0 | head -10

# Disk space
df -h /

# Network interfaces
ifconfig | grep -E "^[a-z]|inet "
```

### OBS Logs

Location: `~/Library/Application Support/obs-studio/logs/`

### Crash Reports

Location: `~/Library/Logs/DiagnosticReports/`

---

## See Also

- [RUNBOOK.md](RUNBOOK.md) - Pre-stream checklist (prevents many issues)
- [AUDIO-DANTE.md](AUDIO-DANTE.md) - Dante-specific troubleshooting
- [VIDEO-CAPTURE.md](VIDEO-CAPTURE.md) - Video-specific troubleshooting
- [STREAMING.md](STREAMING.md) - Streaming-specific troubleshooting

---

*Document maintained by Multi-Camera Livestream Framework team*
