# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an **active project** for a multi-camera 4K live streaming pipeline with Dante audio synchronization. The project contains:

- **Functional shell scripts** for setup, health checks, and workflow automation
- **Technical documentation** covering all aspects of the pipeline
- **Hardware specifications** and compatibility testing
- **Operational runbooks** and troubleshooting guides

**Target users**: Multimedia artists, academic researchers, live performance practitioners.

## Repository Structure

```
├── README.md                   # Project overview and quick start
├── CLAUDE.md                   # This file - AI assistant guidance
├── CHANGELOG.md                # Version history
├── VERSION                     # Semantic version (1.0.0)
├── Makefile                    # Build automation for config system
├── PROJECT_SUMMARY.md          # Package overview and completion status
├── FILE_INVENTORY.md           # Complete documentation index
│
├── docs/                       # Documentation
│   ├── ARCHITECTURE.md         # System design, signal flow diagrams
│   ├── RUNBOOK.md              # 8-phase operational checklist
│   ├── AUDIO-DANTE.md          # Dante audio network setup
│   ├── VIDEO-CAPTURE.md        # DeckLink video capture guide
│   ├── NDI-CALLERS.md          # Remote caller integration
│   ├── SOFTWARE.md             # Software installation guide
│   ├── STREAMING.md            # RTMP/platform configuration
│   ├── TROUBLESHOOTING.md      # Decision-tree troubleshooting
│   └── FAQ.md                  # Frequently asked questions
│
├── hardware/                   # Hardware documentation
│   ├── BOM.csv                 # Bill of materials (~$20k system)
│   ├── COMPATIBILITY.md        # Hardware test matrix
│   └── CAMERA-SETTINGS.md      # Per-camera configuration
│
├── research/                   # Academic materials
│   ├── METHODOLOGY.md          # Research methodology
│   ├── PUBLICATION.md          # Publication strategy
│   └── references.bib          # BibTeX citations
│
├── software/                   # Scripts and configs
│   ├── scripts/
│   │   ├── setup-macos.sh      # System setup verification
│   │   ├── health-check.sh     # Pre-stream health check
│   │   ├── launch-studio.sh    # Launch all applications
│   │   ├── shutdown-studio.sh  # Graceful shutdown
│   │   ├── generate-config.sh  # Config generator
│   │   └── generate-docs.sh    # Documentation generator
│   ├── configs/
│   │   ├── defaults.yaml       # Base configuration
│   │   ├── profiles/           # Profile-specific configs
│   │   │   ├── studio.yaml     # Primary M1 Mac Studio setup
│   │   │   └── mobile.yaml     # Portable setup
│   │   ├── active -> profiles/studio.yaml  # Symlink to active profile
│   │   ├── obs/
│   │   ├── ableton/
│   │   ├── dante/
│   │   ├── blender/
│   │   └── network/
│   ├── generated/              # Generated files (.gitignore'd)
│   │   ├── config.sh           # Shell-sourceable config
│   │   ├── config.json         # JSON config for tools
│   │   └── docs/               # Generated documentation
│   ├── lib/
│   │   └── config-utils.sh     # Shared config loading library
│   └── templates/
│       ├── incident-report.md  # Post-broadcast incident template
│       └── docs/               # Documentation templates
│           ├── SOFTWARE.md.tmpl
│           └── ARCHITECTURE.md.tmpl
│
├── .github/                    # GitHub templates
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── hardware_compatibility.md
│   ├── pull_request_template.md
│   └── workflows/              # CI/CD (to be configured)
│
├── tests/logs/                 # Test output directory
├── examples/                   # Example configurations
└── assets/icons/               # Project assets
```

## Key Technical Context

### Hardware Stack
- **Computer**: M1 Mac Studio (Apple Silicon)
- **Video capture**: Blackmagic DeckLink Quad HDMI via Echo Express SE I (TB3)
- **Audio interface**: MOTU 8PRE-ES (Dante-enabled)
- **Network**: Dedicated Dante switch + gigabit Ethernet

### Software Stack
- OBS Studio (video mixing, encoding)
- Ableton Live (audio mixing, Dante clock master)
- Dante Controller (audio network routing)
- Blender (optional graphics layer)

### Version Pinning
The project locks software versions for reproducibility:
- macOS 14.2.1
- OBS Studio 29.1.3
- Ableton Live 12.0.10
- DeckLink Driver 13.2 (arm64)
- MOTU Driver 2.23.5
- Dante Controller 4.5.3

## Configuration System

The project uses a **profile-based configuration system** that allows switching between different hardware setups without modifying scripts.

### Quick Start

```bash
# Install dependencies (yq for YAML, gettext for templating)
make install-deps

# Generate config from default 'studio' profile
make config

# Generate config and documentation
make all

# Switch to a different profile
make switch-profile PROFILE=mobile

# List available profiles
make list-profiles
```

### Configuration Architecture

```
software/configs/
├── defaults.yaml           # Base config (inherited by all profiles)
├── profiles/
│   ├── studio.yaml        # Primary M1 Mac Studio setup
│   └── mobile.yaml        # Portable MacBook Pro setup
└── active -> profiles/studio.yaml

software/generated/         # Output (.gitignore'd)
├── config.sh              # Shell-sourceable variables
├── config.json            # JSON for other tools
└── docs/                  # Generated documentation
```

### Profile Structure

Profiles use **category-based ontology** for hardware/software abstraction:

```yaml
# Example: software/configs/profiles/studio.yaml
profile:
  name: "studio"
  description: "Primary M1 Mac Studio setup"

hardware:
  computer:
    category: "workstation"
    model: "Mac Studio"
    chip: "M1 Ultra"

  video_capture:
    category: "pcie_capture"
    model: "DeckLink Quad HDMI"
    vendor: "Blackmagic Design"
    detection_patterns:
      - "decklink"
      - "blackmagic"

  audio_interface:
    category: "dante_interface"
    model: "8PRE-ES"
    vendor: "MOTU"

software:
  required:
    video_mixer:
      name: "OBS Studio"
      bundle_id: "com.obsproject.obs-studio"
      version: "29.1.3"

thresholds:
  min_disk_space_gb: 50
  max_cpu_usage_percent: 70
```

### Using Config in Scripts

Scripts automatically load config with fallbacks:

```bash
# At top of script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../lib/config-utils.sh" ]]; then
    source "$SCRIPT_DIR/../lib/config-utils.sh"
    load_config 2>/dev/null || true
fi

# Use config values with fallbacks
MIN_DISK="${CONFIG_THRESHOLDS_MIN_DISK_SPACE_GB:-50}"
AUDIO_MODEL="${CONFIG_HARDWARE_AUDIO_INTERFACE_MODEL:-8PRE-ES}"
```

### Creating New Profiles

1. Copy an existing profile: `cp software/configs/profiles/studio.yaml software/configs/profiles/mysetup.yaml`
2. Edit the new profile with your hardware/software specs
3. Generate config: `make config PROFILE=mysetup`

### Documentation Templates

Templates in `software/templates/docs/` use `{{VAR_NAME}}` placeholders:

```markdown
## Hardware Stack
- **Computer**: {{CONFIG_HARDWARE_COMPUTER_MODEL}}
- **Video Capture**: {{CONFIG_HARDWARE_VIDEO_CAPTURE_MODEL}}
```

Generate docs: `make docs`

## Working with Shell Scripts

### Running Scripts

All scripts are in `software/scripts/` and are executable:

```bash
# Verify system setup (run once after installation)
./software/scripts/setup-macos.sh

# Pre-stream health check (run before each stream)
./software/scripts/health-check.sh

# Launch all streaming applications
./software/scripts/launch-studio.sh

# Graceful shutdown after streaming
./software/scripts/shutdown-studio.sh
```

### Script Options

```bash
# Setup with optional Homebrew installation
./software/scripts/setup-macos.sh --install

# Health check with verbose output
./software/scripts/health-check.sh --verbose

# Health check with JSON output (for automation)
./software/scripts/health-check.sh --json

# Launch without health check
./software/scripts/launch-studio.sh --skip-health-check

# Shutdown with force quit
./software/scripts/shutdown-studio.sh --force

# Shutdown without confirmation prompt
./software/scripts/shutdown-studio.sh --yes
```

### Validating Scripts

```bash
# Syntax check all scripts
for script in software/scripts/*.sh; do
    bash -n "$script" && echo "✓ $script"
done

# Run health check to see current system status
./software/scripts/health-check.sh
```

## Common Development Tasks

### Modifying Shell Scripts

When editing scripts:
1. Follow existing code style (shellcheck-compatible)
2. Use color output functions (`print_pass`, `print_fail`, etc.)
3. Test on macOS before committing
4. Update help text if adding options

### Updating Documentation

- Documentation uses Markdown with ASCII diagrams
- Signal flow diagrams use text-based box drawing characters
- Hardware specs reference specific model numbers and driver versions
- Cross-reference other docs with relative paths (e.g., `[RUNBOOK](docs/RUNBOOK.md)`)

### Adding Hardware Configurations

Update `hardware/COMPATIBILITY.md` with test results:
- Machine model, macOS version, driver versions
- Test duration, CPU/GPU temps
- Issues encountered and workarounds

### Adding to BOM

Update `hardware/BOM.csv` maintaining CSV structure:
```
Item,Quantity,Part Number,Vendor,Unit Cost,Total Cost,Status,Notes
```

## Build/Test Commands

```bash
# Generate configuration (required after cloning)
make config

# Generate config and documentation
make all

# Validate all shell scripts
make validate

# Run setup verification
./software/scripts/setup-macos.sh

# Run health check
./software/scripts/health-check.sh

# Switch to a different profile
make switch-profile PROFILE=mobile

# List available profiles
make list-profiles

# Clean generated files
make clean

# Check directory structure
find . -type d | head -30

# Verify file locations
ls -la docs/ hardware/ research/ software/scripts/
```

## What's Implemented vs TBD

### ✅ Implemented
- Directory structure
- All shell scripts (setup, health-check, launch, shutdown)
- **Profile-based configuration system** (YAML profiles, shell config generation)
- **Documentation templating** (generate docs from config)
- **Makefile** for build automation
- Core documentation (ARCHITECTURE, RUNBOOK, etc.)
- Supplementary documentation templates
- GitHub issue/PR templates

### ⏳ To Be Customized (User-specific)
- Create additional profiles in `software/configs/profiles/` for your setups
- `software/configs/obs/` - OBS scene collections and profiles
- `software/configs/ableton/` - Ableton project templates
- `software/configs/dante/` - Dante routing presets
- Camera-specific settings in `hardware/CAMERA-SETTINGS.md`
- Hardware test data in `hardware/COMPATIBILITY.md`

### 🔮 Future Enhancements
- GitHub Actions workflows for documentation validation
- Automated backup scripts
- Stream monitoring/alerting integration
- Config validation schema (JSON Schema for YAML profiles)

<!-- ORGANVM:AUTO:START -->
## System Context (auto-generated — do not edit)

**Organ:** ORGAN-III (Commerce) | **Tier:** standard | **Status:** PUBLIC_PROCESS
**Org:** `organvm-iii-ergon` | **Repo:** `multi-camera--livestream--framework`

### Edges
- **Produces** → `unspecified`: product
- **Produces** → `organvm-vi-koinonia/community-hub`: community_signal
- **Produces** → `organvm-vii-kerygma/social-automation`: distribution_signal

### Siblings in Commerce
`classroom-rpg-aetheria`, `gamified-coach-interface`, `trade-perpetual-future`, `fetch-familiar-friends`, `sovereign-ecosystem--real-estate-luxury`, `public-record-data-scrapper`, `search-local--happy-hour`, `universal-mail--automation`, `mirror-mirror`, `the-invisible-ledger`, `enterprise-plugin`, `virgil-training-overlay`, `tab-bookmark-manager`, `a-i-chat--exporter`, `.github` ... and 12 more

### Governance
- Strictly unidirectional flow: I→II→III. No dependencies on Theory (I).

*Last synced: 2026-03-08T20:11:34Z*

## Session Review Protocol

At the end of each session that produces or modifies files:
1. Run `organvm session review --latest` to get a session summary
2. Check for unimplemented plans: `organvm session plans --project .`
3. Export significant sessions: `organvm session export <id> --slug <slug>`
4. Run `organvm prompts distill --dry-run` to detect uncovered operational patterns

Transcripts are on-demand (never committed):
- `organvm session transcript <id>` — conversation summary
- `organvm session transcript <id> --unabridged` — full audit trail
- `organvm session prompts <id>` — human prompts only


## Active Directives

| Scope | Phase | Name | Description |
|-------|-------|------|-------------|
| system | any | prompting-standards | Prompting Standards |
| system | any | research-standards-bibliography | APPENDIX: Research Standards Bibliography |
| system | any | research-standards | METADOC: Architectural Typology & Research Standards |
| system | any | sop-ecosystem | METADOC: SOP Ecosystem — Taxonomy, Inventory & Coverage |
| system | any | autopoietic-systems-diagnostics | SOP: Autopoietic Systems Diagnostics (The Mirror of Eternity) |
| system | any | cicd-resilience-and-recovery | SOP: CI/CD Pipeline Resilience & Recovery |
| system | any | cross-agent-handoff | SOP: Cross-Agent Session Handoff |
| system | any | document-audit-feature-extraction | SOP: Document Audit & Feature Extraction |
| system | any | essay-publishing-and-distribution | SOP: Essay Publishing & Distribution |
| system | any | market-gap-analysis | SOP: Full-Breath Market-Gap Analysis & Defensive Parrying |
| system | any | pitch-deck-rollout | SOP: Pitch Deck Generation & Rollout |
| system | any | promotion-and-state-transitions | SOP: Promotion & State Transitions |
| system | any | repo-onboarding-and-habitat-creation | SOP: Repo Onboarding & Habitat Creation |
| system | any | research-to-implementation-pipeline | SOP: Research-to-Implementation Pipeline (The Gold Path) |
| system | any | security-and-accessibility-audit | SOP: Security & Accessibility Audit |
| system | any | session-self-critique | session-self-critique |
| system | any | source-evaluation-and-bibliography | SOP: Source Evaluation & Annotated Bibliography (The Refinery) |
| system | any | stranger-test-protocol | SOP: Stranger Test Protocol |
| system | any | strategic-foresight-and-futures | SOP: Strategic Foresight & Futures (The Telescope) |
| system | any | typological-hermeneutic-analysis | SOP: Typological & Hermeneutic Analysis (The Archaeology) |
| unknown | any | gpt-to-os | SOP_GPT_TO_OS.md |
| unknown | any | index | SOP_INDEX.md |
| unknown | any | obsidian-sync | SOP_OBSIDIAN_SYNC.md |

Linked skills: evaluation-to-growth


**Prompting (Anthropic)**: context 200K tokens, format: XML tags, thinking: extended thinking (budget_tokens)

<!-- ORGANVM:AUTO:END -->


## ⚡ Conductor OS Integration
This repository is a managed component of the ORGANVM meta-workspace.
- **Orchestration:** Use `conductor patch` for system status and work queue.
- **Lifecycle:** Follow the `FRAME -> SHAPE -> BUILD -> PROVE` workflow.
- **Governance:** Promotions are managed via `conductor wip promote`.
- **Intelligence:** Conductor MCP tools are available for routing and mission synthesis.
