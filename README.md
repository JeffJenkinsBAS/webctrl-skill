# webctrl-skill

**Building Automation System (BAS) design intelligence for Claude Code — built for Automated Logic WebCTRL environments.**

A production-grade skill pack that gives AI coding assistants the working knowledge of a senior controls engineer at an Automated Logic (ALC) dealer: WebCTRL platform operations, EIKON graphical programming, BACnet network engineering, ASHRAE-compliant sequence design, commercial HVAC thermodynamics, OptiFlex hardware, and the competitive BAS vendor landscape.

Every skill follows Anthropic's [Agent Skills](https://www.anthropic.com/news/skills) specification with progressive disclosure: lightweight frontmatter for discovery, focused core instructions, and deep reference files loaded only when needed.

---

## Contents

- [Why This Exists](#why-this-exists)
- [The Skill Pack](#the-skill-pack)
- [Installation](#installation)
- [How the Skills Work](#how-the-skills-work)
- [Usage Examples](#usage-examples)
- [Repository Structure](#repository-structure)
- [Design Principles](#design-principles)
- [Versioning & Maintenance](#versioning--maintenance)
- [License](#license)

---

## Why This Exists

General-purpose AI models know HVAC exists. They do not know:

- That a ZN program hits practical limits around **~700 microblocks**, or that a ZS sensor needs a **Sensor Binder + ASVI/BSVI + BACnet Setpoint + Time Clock** to function
- The actual **trim-and-respond math** behind ASHRAE Guideline 36 static pressure and SAT resets
- That the **G5CE integrators with RT5-prefix serials permanently lack ARCNET hardware**, or the difference between an OF1628 and an OF1628-NR
- What **ASHRAE 90.1-2022** changed about DCV thresholds and energy submetering, and what that means for a controls contractor's point list
- Why writes from a Niagara supervisor into ALC controllers fail intermittently, and how to scope a Metasys takeover

This pack encodes that field knowledge — sourced from manufacturer technical documentation, ASHRAE publications, engineering references (Taylor Engineering, Trane/Carrier engineering newsletters), and real technician field reports — so Claude Code can act like a controls lead, not a generalist.

---

## The Skill Pack

Eight skills, each independently discoverable and scoped to avoid overlap:

| Skill | What It Covers | Typical Triggers |
|---|---|---|
| [`webctrl-platform`](.claude/skills/webctrl-platform/) | WebCTRL server administration, SiteBuilder databases, geographic/network trees, BACnet discovery, custom reports, trends/alarms, console diagnostics, backups/migrations, ViewBuilder graphics | "WebCTRL", "SiteBuilder", "discovery", "custom report", "server migration", "graphics path" |
| [`eikon-programming`](.claude/skills/eikon-programming/) | EIKON graphical logic authoring and review — microblock catalog, ZN program requirements, ZS/RS sensor programming, Live GFB debugging, logic review checklists | "EIKON", "microblock", "GFB", "ZN program", "sensor binder", "logic review" |
| [`bacnet-networking`](.claude/skills/bacnet-networking/) | Network architecture and troubleshooting: BACnet/IP, MS/TP, ARC156, BACnet/SC, Rnet, Modbus; addressing, routing, BBMDs, broadcast management, comm-loss diagnosis | "BACnet", "MS/TP", "device instance", "BBMD", "comm loss", "broadcast storm", "token passing" |
| [`sequences-of-operation`](.claude/skills/sequences-of-operation/) | Writing, rewriting, and reviewing SOOs; ASHRAE Guideline 36 sequences; trim-and-respond parameters; functional testing and commissioning support | "sequence of operation", "AHU sequence", "Guideline 36", "functional test", "commissioning checklist" |
| [`hvac-fundamentals`](.claude/skills/hvac-fundamentals/) | Thermodynamics and psychrometrics for controls; chiller/boiler plants; airside systems; lab exhaust; PID tuning; higher-ed campus specifics | "psychrometrics", "enthalpy", "chiller plant", "hot water reset", "economizer", "PID tuning", "hunting" |
| [`ashrae-standards`](.claude/skills/ashrae-standards/) | ASHRAE 90.1, 62.1, 55, Guideline 36, Standard 135 (BACnet), Guideline 13, Standard 202 — mapped to controls scope, compliance thresholds, and spec review | "ASHRAE 90.1", "62.1", "DCV", "economizer high limit", "energy code", "Division 23 09 00" |
| [`alc-hardware`](.claude/skills/alc-hardware/) | OptiFlex controller selection, wiring, addressing, and troubleshooting — all 13 current devices, UUKL/UL 864 listings, field gotchas | "OptiFlex", "OF342", "G5RE", "ARC156 wiring", "rotary switch", "End-of-Net", "UUKL" |
| [`bas-vendor-landscape`](.claude/skills/bas-vendor-landscape/) | ALC vs. Siemens Desigo, JCI Metasys, Honeywell WEBs/EBI, Schneider EcoStruxure, Delta, Distech, Niagara/Tridium, KMC, Alerton — takeover assessment and competitive positioning | "Metasys", "Desigo", "Niagara", "takeover project", "replace existing BAS", "vendor lock-in" |

### What's inside each skill

Every skill folder contains a `SKILL.md` (core workflows, decision tables, checklists, worked examples) plus `references/` files for depth-on-demand:

```
.claude/skills/
├── webctrl-platform/
│   ├── SKILL.md                        # DB naming, trees, discovery, reports, console, migrations
│   └── references/
│       ├── server-admin.md             # Editions, v7→v9 history, add-ons, migration procedure
│       └── graphics-viewbuilder.md     # Path syntax, conditional color, dashboard conventions
├── eikon-programming/
│   ├── SKILL.md                        # Microblock catalog, ZN requirements, review checklist
│   └── references/
│       ├── microblock-patterns.md      # Occupancy arbitration, staging, resets, interlocks
│       └── debugging-live-logic.md     # Live GFB workflow, common logic bugs
├── bacnet-networking/
│   ├── SKILL.md                        # Architecture workflow, addressing, troubleshooting tree
│   └── references/
│       ├── bacnet-protocol.md          # Objects/services, BIBBs, device profiles, BBMD
│       ├── bacnet-sc.md                # TLS 1.3, hub-and-spoke, certificates, ALC status
│       └── mstp-troubleshooting.md     # Token passing, termination/biasing, capture tools
├── sequences-of-operation/
│   ├── SKILL.md                        # 8-part SOO structure, review checklist, G36 guidance
│   └── references/
│       ├── g36-sequences.md            # G36 VAV/AHU sequences, FC1–FC15 fault rules
│       ├── soo-templates.md            # 7 skeleton templates (AHU, VAV, CHW, HW, DOAS, lab)
│       └── commissioning.md            # Functional tests, point-to-point, common deficiencies
├── hvac-fundamentals/
│   ├── SKILL.md                        # Core equations, psych decisions, PID workflow
│   └── references/
│       ├── psychrometrics.md           # Chart processes, moist-air math, affinity laws
│       ├── chiller-plants.md           # Plant configs, CW reset, towers, thermal storage
│       ├── heating-plants.md           # Condensing boilers, HW reset, campus steam/district
│       ├── airside-systems.md          # VAV resets, DOAS, energy recovery, lab exhaust
│       └── control-loops.md            # PID theory, tuning values, cascade, hunting
├── ashrae-standards/
│   ├── SKILL.md                        # Standards map, spec-check workflow, thresholds
│   └── references/
│       ├── guideline-36.md             # Trim-and-respond math, zone groups, FDD, 2024 addenda
│       ├── std-90-1-controls.md        # Economizer tables, DCV, resets, metering
│       ├── std-62-1-ventilation.md     # VRP equations (Vbz, Voz, Ev), CO2 DCV
│       ├── std-135-bacnet.md           # Object model, BIBBs/PICS, profiles, BTL
│       └── comfort-and-cx.md           # Std 55 PMV/PPD, Cx standards, spec flow-through
├── alc-hardware/
│   ├── SKILL.md                        # Selection workflow, comparison table, gotchas, UUKL
│   └── references/
│       ├── device-details.md           # Per-device specs for all 13 OptiFlex parts
│       └── wiring-and-networks.md      # ARC156/MS-TP specs, termination, Rnet/Act Net
└── bas-vendor-landscape/
    ├── SKILL.md                        # Cross-vendor table, differentiators, takeover workflow
    └── references/
        ├── vendor-profiles.md          # Per-vendor deep detail
        └── integration-pitfalls.md     # 9 real field pitfalls (Niagara writes, BBMD loops…)
```

---

## Installation

### Option 1 — Claude Code plugin (recommended)

```bash
# In Claude Code
/plugin marketplace add JeffJenkinsBAS/webctrl-skill
/plugin install webctrl-skill@webctrl-skill
```

All eight skills become available in every project.

### Option 2 — Project-level skills

Clone into your project so the skills load automatically for anyone working in that repo:

```bash
git clone https://github.com/JeffJenkinsBAS/webctrl-skill.git
cp -r webctrl-skill/.claude/skills/ your-project/.claude/skills/
```

### Option 3 — Personal (user-level) skills

Install for yourself across all projects:

```bash
git clone https://github.com/JeffJenkinsBAS/webctrl-skill.git
mkdir -p ~/.claude/skills
cp -r webctrl-skill/.claude/skills/* ~/.claude/skills/
```

Verify with `/skills` in Claude Code — you should see all eight skills listed.

---

## How the Skills Work

The pack uses the three-level **progressive disclosure** model from Anthropic's skill guide:

| Level | What Loads | When |
|---|---|---|
| 1 — Frontmatter | Name + trigger-rich description (~100 tokens/skill) | Always, so Claude knows when each skill applies |
| 2 — SKILL.md body | Core workflows, tables, checklists | When the task matches a skill's triggers |
| 3 — References | Deep technical files | Only when Claude decides it needs the detail |

This keeps context cost near zero until a BAS task actually appears. Skills are deliberately **cross-scoped with negative triggers** — e.g., `bacnet-networking` explicitly defers logic questions to `eikon-programming` — so multiple skills compose cleanly on complex tasks (a full design task may load four or five of them together).

---

## Usage Examples

Real prompts these skills are built to handle:

**Sequence design & review**
> "Write a Guideline 36 sequence of operation for a VAV AHU with a DX cooling coil and hot water reheat, including trim-and-respond static pressure reset."

> "Review this 75% controls submittal sequence and flag missing safeties, alarm gaps, and anything that will hurt us at commissioning."

**Programming**
> "Design the EIKON logic structure for a ZN341 serving a classroom with a ZS Pro sensor — occupancy arbitration, setpoint with deadbands, and DCV on the CO2 input."

**Networking**
> "I have 42 VAV controllers on one MS/TP segment dropping offline intermittently. Walk me through the diagnosis."

> "Design the BACnet network architecture for a 3-building campus: network numbering, router placement, and BBMD strategy."

**Standards & compliance**
> "The spec cites ASHRAE 90.1-2022. What controls provisions am I on the hook for in a VAV retrofit with two 40-ton RTUs?"

**Hardware**
> "I need a controller for an AHU with 14 AIs, 6 BIs, 8 BOs, and 4 AOs — which OptiFlex fits, and what expander options do I have?"

**Competitive / takeover**
> "We're bidding a takeover of a campus running Metasys NAEs on N2. What's realistic to integrate vs. rip-and-replace, and what are the gotchas?"

**Theory**
> "Mixed air is 78°F/65% RH, supply setpoint 55°F, 12,000 CFM. What's my total coil load, and how much is latent?"

---

## Repository Structure

```
webctrl-skill/
├── .claude/
│   └── skills/                 # The 8 skills (see table above)
├── .claude-plugin/
│   ├── plugin.json             # Claude Code plugin manifest
│   └── marketplace.json        # Marketplace metadata for /plugin install
├── LICENSE                     # CC0 1.0 Universal
└── README.md
```

---

## Design Principles

1. **Field usability over theory.** Every skill teaches: explanation → step-by-step actions → best practices → common mistakes. Checklists and worked examples beat prose.
2. **Real numbers, preserved.** Formulas (Q = 1.085 × CFM × ΔT), wiring specs (22 AWG / 2,000 ft MS/TP), limits (~700 microblocks per ZN program, 50 columns per WebCTRL report), and trim-and-respond parameters are kept exact — never rounded off into generalities.
3. **Sourced, not hallucinated.** Content is compiled from ALC technical instruction manuals, ASHRAE standards summaries, BACnet International material, Taylor Engineering and Trane/Carrier engineering publications, and documented technician field reports. Inline source links are preserved in the reference files.
4. **Scoped skills that compose.** Eight focused skills with explicit boundaries and cross-references instead of one monolithic prompt — better triggering, lower context cost, easier maintenance.
5. **"Slow is smooth, smooth is fast."** The pack encodes a build philosophy: scalable, readable, serviceable systems; confirmed COV over polling; clean naming conventions; minimal broadcast traffic.

---

## Versioning & Maintenance

- Current version: **1.0.0** (all skills and the plugin manifest share the version)
- Skill content is a living document set: standards addenda (e.g., Guideline 36-2024, 90.1-2022 adoption), new OptiFlex hardware, and WebCTRL releases will drive updates
- **This README is updated with every change to the skill pack** so it always reflects the exact current contents, structure, and behavior of the skills

Issues and suggestions are welcome via [GitHub Issues](https://github.com/JeffJenkinsBAS/webctrl-skill/issues).

---

## License

[CC0 1.0 Universal](LICENSE) — public domain dedication. Use it, fork it, ship it.
