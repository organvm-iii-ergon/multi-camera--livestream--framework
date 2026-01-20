# Publication Strategy & Roadmap

## Overview

This document outlines the academic publication strategy for the **Live Streaming Pipeline** project—a reproducible, modular system for multi-camera 4K streaming with synchronized audio and low-latency interactivity.

**Publication type**: Systems/methods paper (emphasis on reproducibility, scalability, open documentation)

**Target audience**: Multimedia artists, HCI researchers, live performance technologists, digital media scholars

**Core contribution**: Reproducible infrastructure for distributed, real-time media production with documented hardware/software constraints

---

## Publication Venues & Timeline

### Tier 1: Peer-Reviewed Conference Proceedings (6–12 months)

**Best fit for systems/methods work:**

#### Option A: ACM CHI (Human Factors in Computing)
- **Track**: Interactive Art & Design
- **Deadline**: Typically September (for May conference)
- **Format**: 8-page paper + supplementary materials
- **Audience**: HCI, interaction design, creative technologists
- **Fit**: Strong (intersection of technology + creative practice)
- **Submission**: Conference-style peer review, 3+ reviewers

#### Option B: Ars Electronica / ISEA (International Symposium on Electronic Art)
- **Track**: Art & Science, Research & Development
- **Deadline**: Typically January
- **Format**: 4-page paper + 10-min presentation
- **Audience**: Digital artists, media technologists, curators
- **Fit**: Excellent (multimedia art + technical systems)
- **Submission**: Peer review by artist/technologist panel

#### Option C: Creative Computing Symposium
- **Deadline**: Typically March
- **Format**: 4-page position/systems paper
- **Audience**: Artists, programmers, researchers working at intersection
- **Fit**: Excellent
- **Submission**: Juried review

---

### Tier 2: Journal Articles (12–18 months)

**Best for deeper technical/methodological work:**

#### Option A: Leonardo (MIT Press)
- **Type**: Journal + supplementary online publication
- **Fit**: Multimedia art, technology, practice-based research
- **Format**: 6,000–10,000 words + images
- **Review**: Peer-reviewed (4–6 month turnaround)

#### Option B: Digital Humanities Quarterly (Open Access)
- **Type**: Open-access online journal
- **Fit**: Digital humanities, digital art, media studies
- **Format**: Variable (5,000–15,000 words)
- **Review**: 3–4 month peer review
- **Cost**: Free to publish

#### Option C: SoftwareX (Elsevier, open-access)
- **Focus**: Software research, reproducibility, validation
- **Format**: Software article (2,000–4,000 words) + code repository
- **Requirements**: Open-source code + documentation
- **Cost**: Free to publish
- **Fit**: Excellent for systems/methodology focus

---

## Publication Timeline (Recommended)

### Phase 1: Conference (Months 1–6)

**Month 1–2**: Write and submit to first conference
- Choose venue (ACM CHI, ISEA, or Creative Computing)
- Draft 4–8 page paper
- Prepare supplementary materials (videos, diagrams)

**Month 3–5**: Peer review & revision
- Respond to reviewer comments
- Iterate on figures/examples
- Prepare presentation materials

**Month 6**: Present at conference
- 10–20 min talk + Q&A
- Gather feedback for journal version
- Network with other researchers

### Phase 2: Journal (Months 7–14)

**Month 7–8**: Expand conference paper into journal article
- Double the length
- Add deeper technical sections
- Include more case studies / failure analysis

**Month 8–9**: Submit to journal (e.g., Leonardo, DHQ)
- Write journal-specific framing
- Prepare high-quality figures (print resolution)

**Month 10–13**: Peer review & revision cycle
- Typically 4–6 months for humanities journals
- Revise based on reviewer feedback

**Month 14**: Publication
- Proofs, final edits
- Supplementary materials uploaded

### Phase 3: Open Methods Paper (Months 12–16)

**While journal is in review**, submit software/methods article to **SoftwareX** or similar:
- Emphasize reproducibility, open documentation
- Reference GitHub repository as primary research output
- Focus on technical validation, not artistic vision

---

## Contribution & Authorship

### Who Should Be Credited?

| Contribution | Credit As |
|---|---|
| System design, hardware selection, primary documentation | First author |
| Test broadcasts, incident logging, troubleshooting docs | Co-author or acknowledgments |
| Software integration (OBS, Dante, NDI config) | Co-author |
| Peer feedback, methodology review | Acknowledgments |
| Caller participants (test streams) | Acknowledgments |

**Authorship checklist** (ICMJE criteria):
- [ ] Substantial contributions to conception/design (or data acquisition/analysis)
- [ ] Drafting/revising manuscript critically
- [ ] Final approval of version to be published
- [ ] Accountable for all aspects of work

---

## Supplementary Materials Strategy

### For Conference Submission:

**Essential**:
- High-resolution block diagram (signal flow)
- Photo of studio setup (hardware + monitors)
- Performance benchmarks table (CPU/GPU/latency)

**Optional**:
- 2–3 min video: "Day in the life of a broadcast"
- Link to GitHub repository
- Example OBS scene export (JSON)

### For Journal Submission:

**Required**:
- All figures at 300 DPI (print resolution)
- Full data appendix (hardware specs, compatibility matrix)
- Code snippets (if including shell scripts)

**Recommended**:
- Supplementary video (5–10 min): System in action
- Raw performance logs (CSV files)
- Full troubleshooting decision tree (PDF)

**Supplementary online** (hosting):
- Link to GitHub repo
- Link to example broadcasts (YouTube archives)
- Raw video files (if <1 GB; or reference S3 bucket)

---

## Ethics & Disclosure

### Hardware Sponsorship

**Disclosure statement** (if applicable):
```
Hardware was purchased with [funding source]. No commercial 
relationships with Blackmagic Design, Audinate, Sonnet Technologies, 
MOTU, or other vendors. All software is open-source or commercially 
available without modification.
```

### Participant Consent

**For broadcasts with callers**:
- Written consent from all participants (on-camera, on-stream)
- Option to be credited or anonymous
- Clear explanation of intended use (archival, publication)

### Data Privacy

- Raw video archives: Store locally or on encrypted S3
- Participant identities: De-identify in paper if requested
- Performance logs: Only share anonymized CPU/network metrics

---

## Open-Source License & Citation

### Recommended Licensing

```markdown
## License

- **Documentation** (README, runbooks, guides): CC-BY-4.0
  (Allow reuse with attribution)
  
- **Code/Scripts** (Bash, Python): MIT or GPL-3.0
  (Allow modification, redistribution)
  
- **Configuration files** (OBS JSON, MOTU XML): CC0 (Public Domain)
  (Encourage use without restriction)
```

### Citation Request

**In paper's "How to Cite" section:**

```bibtex
@article{your-name-streaming-2025,
  author = {Your Name and Collaborators},
  title = {Synchronizing Capture and Playback: 
           A Reproducible Infrastructure for Real-Time Multi-Camera Streaming},
  journal = {Leonardo},
  year = {2025},
  volume = {58},
  number = {3},
  pages = {xxx--xxx},
  url = {https://doi.org/10.xxxx/xxxx}
}

# Also cite the open-source repo:
@software{streaming-pipeline-github-2025,
  author = {Your Name},
  title = {Live Streaming Pipeline: 
           Multi-Camera 4K with Dante Audio Sync},
  year = {2025},
  url = {https://github.com/yourusername/live-streaming-pipeline},
  note = {Open-source documentation and reproducible system}
}
```

---

## Metrics & Impact

### How to Measure Success?

**Short-term** (0–6 months):
- Conference acceptance rate (target: 1/3 acceptance typical)
- Citation count (via Google Scholar)
- GitHub stars/forks (marker of community interest)

**Medium-term** (6–18 months):
- Journal acceptance
- Number of practitioners using/forking repo
- Adaptations for different hardware (reported in issues/discussions)

**Long-term** (18+ months):
- Influence on future systems (cited in other projects)
- Teaching use (adopted in courses, workshops)
- Commercial adoption (if any vendor references approach)

### Tracking

**Create**:
```
research/METRICS.md
├─ Conference submission status
├─ Reviewer feedback log
├─ GitHub repository analytics
├─ Citation count (updated quarterly)
└─ Community engagement (issues, PRs, discussions)
```

---

## Revision & Maintenance Post-Publication

**Important**: Publication is not the end. Update as technology evolves.

### Annual Review Cycle

**Each January** (or after major update):
1. **Update VERSION** in root directory
2. **Document breaking changes** (if major macOS/driver updates)
3. **Add new case studies** (broadcasts, lessons learned)
4. **Revise hardware compatibility matrix** (if new M-series Macs)
5. **Publish addendum or blog post** (lessons learned since publication)

---

**Last Updated**: 2025-01-22
**Maintainer**: Your Name
