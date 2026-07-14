# webctrl-skill

**Building Automation System (BAS) design intelligence for Claude Code — built for Automated Logic WebCTRL environments.**

A production-grade skill pack that gives AI coding assistants the working knowledge of a senior controls engineer at an Automated Logic (ALC) dealer: WebCTRL platform operations, EIKON graphical programming, BACnet network engineering, ASHRAE-compliant sequence design, commercial HVAC thermodynamics, OptiFlex hardware, field commissioning procedures, whole-building system design, and the competitive BAS vendor landscape.

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
- What a disciplined **point-to-point checkout** actually looks like in the field — voltage checks before power-up, I/O channel assignment, RIB verification, and PID startup values that don't hunt
- How a building actually **comes together**: design phases, submittals, valve authority, TAB coordination, functional testing, and why low delta-T syndrome ruins chiller plants

This pack encodes that field knowledge — sourced from manufacturer technical documentation, ASHRAE publications, engineering references (Taylor Engineering, Trane/Carrier engineering newsletters), real technician field reports, and working ALC-dealer field standards and checkout procedures — so Claude Code can act like a controls lead, not a generalist.

---

## The Skill Pack

Ten skills, each independently discoverable and scoped to avoid overlap:

| Skill | What It Covers | Typical Triggers |
|---|---|---|
| [`webctrl-platform`](.claude/skills/webctrl-platform/) | WebCTRL server administration, SiteBuilder databases, geographic/network/source trees, BACnet discovery, custom reports, trends/alarms, console diagnostics, backup/upgrade/migration lifecycle, WebCTRL-as-a-Service, PostgreSQL, dealer licensing, patches, Global Modify, WebCTRL 10 features, ViewBuilder graphics | "WebCTRL", "SiteBuilder", "discovery", "custom report", "server migration", "backup database", "global modify", "WebCTRL 10", "graphics path" |
| [`eikon-programming`](.claude/skills/eikon-programming/) | EIKON graphical logic authoring and review — microblock catalog, ZN program requirements, ZS/RS sensor programming, Live GFB debugging, logic review checklists, offset vs. calibration, field PID tuning standards, SOO simplification, logic-page commissioning checks | "EIKON", "microblock", "GFB", "ZN program", "sensor binder", "logic review", "PID tuning values", "offset or calibrate" |
| [`bacnet-networking`](.claude/skills/bacnet-networking/) | Network architecture and troubleshooting: BACnet/IP, MS/TP, ARC156, BACnet/SC, Rnet, Modbus; addressing, routing, BBMDs, broadcast management, comm-loss diagnosis; MS/TP daisy-chain and shield-wiring standards, confirmed-COV refresh timer configuration, BACnet address formatting, ARCnet Wireshark captures, IP-to-IP routing | "BACnet", "MS/TP", "device instance", "BBMD", "comm loss", "broadcast storm", "token passing", "COV", "Modbus integration" |
| [`sequences-of-operation`](.claude/skills/sequences-of-operation/) | Writing, rewriting, and reviewing SOOs; ASHRAE Guideline 36 sequences; trim-and-respond parameters; formal Cx-authority process; 100% commissioning standard; field SOO verification workflow; SOO simplification technique; functional testing | "sequence of operation", "AHU sequence", "Guideline 36", "functional test", "commissioning checklist", "verify the sequence" |
| [`hvac-fundamentals`](.claude/skills/hvac-fundamentals/) | Thermodynamics and psychrometrics for controls; chiller/boiler plants; airside systems; lab exhaust; PID theory; dehumidification; CO2 demand-controlled ventilation; CO/NO2 monitoring; lead/lag vs. lead/standby redundancy; DDC air handler point design; higher-ed campus specifics | "psychrometrics", "enthalpy", "chiller plant", "hot water reset", "economizer", "dehumidification", "DCV", "lead/lag", "PID", "hunting" |
| [`ashrae-standards`](.claude/skills/ashrae-standards/) | ASHRAE 90.1, 62.1, 55, Guideline 36, Standard 135 (BACnet), Guideline 13, Standard 202 — mapped to controls scope, compliance thresholds, and spec review | "ASHRAE 90.1", "62.1", "DCV", "economizer high limit", "energy code", "Division 23 09 00" |
| [`alc-hardware`](.claude/skills/alc-hardware/) | OptiFlex controller selection, wiring, addressing, and troubleshooting — 24 devices spanning equipment controllers (OF022/OF141/OF253/OF342/OF561/OF683 families), building controllers (OF1628/OF028/OFBBC families), routers and integrators (G5CE, G5RE, OFHI/OFHI-A, OFINT-E2, OFISO-E2, OFCSR-E2, OFRTR-E2-S2), and I/O expanders (FIO family, OFX48); dealer-verified per-port protocol capability matrix; expander compatibility rules; Act Net reserved addressing; UUKL/UL 864 smoke-control system requirements and per-device deltas; G5CE setup, ZS sensor Rnet tags and paths, freezestat best practices, Belimo actuator code decoding, VAV box setup, BASRT-B thermostats, terminal-strip color codes, field gotchas | "OptiFlex", "OF342", "OF683", "G5RE", "G5CE", "OFINT", "OFISO", "FIO expander", "ARC156 wiring", "rotary switch", "ZS sensor", "Belimo", "freezestat", "VAV setup", "UUKL", "smoke control" |
| [`field-commissioning`](.claude/skills/field-commissioning/) | The complete field checkout discipline: pre-site preparation, the 5-step commissioning workflow (pre-power inspection → power-up/download → I/O channel assignment → point-to-point verification → SOO verification), field connection methods (RNET, OptiFlex local, TCP/IP profiles, field Wi-Fi kits, RDP), controller replacement/restore procedures, LED status quick references, redlines and checkout documentation | "commissioning", "point-to-point", "checkout", "connect to the controller", "download memory", "replace a controller", "LED status", "field connection" |
| [`bas-system-design`](.claude/skills/bas-system-design/) | How buildings come together end-to-end: design phases (SD/DD/CD), delivery methods, Division 23/25 specs, OPR/BOD, mechanical load calcs and system selection, controls design engineering (points lists, valve Cv/authority, damper selection, sensor placement, panel/transformer sizing), submittal→startup→TAB workflow, formal commissioning process, whole-system integration (low delta-T, reset interactions, fire alarm/smoke control, MSI, FDD/analytics) | "system design", "design phases", "submittal", "valve sizing", "valve authority", "damper selection", "sensor placement", "TAB", "low delta-T", "MEP coordination" |
| [`bas-vendor-landscape`](.claude/skills/bas-vendor-landscape/) | ALC vs. Siemens Desigo, JCI Metasys, Honeywell WEBs/EBI, Schneider EcoStruxure, Delta, Distech, Niagara/Tridium, KMC, Alerton — takeover assessment and competitive positioning | "Metasys", "Desigo", "Niagara", "takeover project", "replace existing BAS", "vendor lock-in" |

### What's inside each skill

Every skill folder contains a `SKILL.md` (core workflows, decision tables, checklists, worked examples) plus `references/` files for depth-on-demand:

```
.claude/skills/
├── webctrl-platform/
│   ├── SKILL.md                        # DB naming, trees, discovery, reports, console, Global Modify
│   └── references/
│       ├── server-admin.md             # Editions, v7→v9 history, add-ons, migration procedure
│       ├── server-lifecycle.md         # Backups, upgrade/migration checklist, WaaS, PostgreSQL, licensing, patches, source trees, support escalation, customer training
│       ├── webctrl-10.md               # WebCTRL 10 features, ACxelerate 3.0, Predictive Insights, Test & Balance v10
│       └── graphics-viewbuilder.md     # Path syntax, conditional color, dashboard conventions
├── eikon-programming/
│   ├── SKILL.md                        # Microblock catalog, ZN requirements, review checklist
│   └── references/
│       ├── microblock-patterns.md      # Occupancy arbitration, staging, resets, interlocks
│       ├── debugging-live-logic.md     # Live GFB workflow, common logic bugs
│       └── field-tuning-and-commissioning.md  # Offset vs. calibration, field PID standard, SOO simplification, logic-page checks
├── bacnet-networking/
│   ├── SKILL.md                        # Architecture workflow, addressing, troubleshooting tree
│   └── references/
│       ├── bacnet-protocol.md          # Objects/services, BIBBs, device profiles, BBMD, address formatting
│       ├── bacnet-sc.md                # TLS 1.3, hub-and-spoke, certificates, ALC status
│       ├── mstp-troubleshooting.md     # Token passing, termination/biasing, shield wiring, capture tools
│       └── internal-standards.md       # MS/TP integration standard, COV refresh timers, Modbus guide, wiring restrictions, Ethernet/T568B, ARCnet captures, IP-to-IP routing, network infrastructure devices (routers/isolator/integration router)
├── sequences-of-operation/
│   ├── SKILL.md                        # 8-part SOO structure, review checklist, G36 guidance
│   └── references/
│       ├── g36-sequences.md            # G36 VAV/AHU sequences, FC1–FC15 fault rules
│       ├── soo-templates.md            # 7 skeleton templates (AHU, VAV, CHW, HW, DOAS, lab)
│       └── commissioning.md            # CxA process, 100% Cx standard, functional tests, field SOO verification, SOO simplification
├── hvac-fundamentals/
│   ├── SKILL.md                        # Core equations, psych decisions, PID workflow
│   └── references/
│       ├── psychrometrics.md           # Chart processes, moist-air math, affinity laws
│       ├── chiller-plants.md           # Plant configs, CW reset, towers, thermal storage
│       ├── heating-plants.md           # Condensing boilers, HW reset, campus steam/district
│       ├── airside-systems.md          # VAV resets, DOAS, energy recovery, lab exhaust
│       ├── control-loops.md            # PID theory, tuning values, cascade, hunting
│       ├── iaq-monitoring.md           # Dehumidification/SHR, CO2 DCV strategies, CO/NO2 thresholds, sensor calibration
│       └── redundancy-and-ddc.md       # Lead/lag vs. lead/standby (with failure case study), AHU DDC point design, status thresholds
├── ashrae-standards/
│   ├── SKILL.md                        # Standards map, spec-check workflow, thresholds
│   └── references/
│       ├── guideline-36.md             # Trim-and-respond math, zone groups, FDD, 2024 addenda
│       ├── std-90-1-controls.md        # Economizer tables, DCV, resets, metering
│       ├── std-62-1-ventilation.md     # VRP equations (Vbz, Voz, Ev), CO2 DCV
│       ├── std-135-bacnet.md           # Object model, BIBBs/PICS, profiles, BTL
│       └── comfort-and-cx.md           # Std 55 PMV/PPD, Cx standards, spec flow-through
├── alc-hardware/
│   ├── SKILL.md                        # Selection workflow, 24-device comparison table, expander rules, gotchas, UUKL
│   └── references/
│       ├── device-details.md           # Per-device specs for all 24 OptiFlex parts
│       ├── port-capability-matrix.md   # Dealer-verified per-controller and per-port protocol matrix, Act Net addressing, simultaneous-use restrictions, FlexPoint licensing
│       ├── uukl-smoke-control.md       # UL 864/UUKL system requirements, timing table, FSCS/FACP, firmware whitelist, per-device SCS deltas
│       ├── wiring-and-networks.md      # ARC156/MS-TP specs, termination, Rnet/Act Net
│       └── internal-standards.md       # G5CE setup, ZS Rnet tags/paths, freezestat, Belimo code, VAV box setup, BASRT-B, terminal color codes
├── field-commissioning/
│   ├── SKILL.md                        # Pre-site checklist, 100% Cx standard, 5-step workflow, redlines, documentation
│   └── references/
│       ├── commissioning-workflow.md   # Steps 1–5 in full: voltages, downloads, I/O assignment, point-to-point tests, SOO verification
│       ├── field-connections.md        # RNET local, OptiFlex local, TCP/IP Manager profiles, field Wi-Fi kit, RDP
│       └── controller-service.md       # Controller replacement, Gen5 restore, 9-1-1 reset, OF342-E2 + G5CE LED tables
├── bas-system-design/
│   ├── SKILL.md                        # Design phases, delivery methods, Div 23/25, OPR/BOD, integration mindset
│   └── references/
│       ├── mechanical-design.md        # Load calcs, diversity, equipment sizing, system-type tradeoffs, duct/pipe sizing
│       ├── controls-design.md          # Points lists, valve Cv/authority, dampers, sensor placement, panel/transformer sizing
│       ├── delivery-and-cx.md          # Submittals, startup sequencing, TAB, CxA process, Guideline 0/1.1, Std 202
│       └── system-integration.md       # Low delta-T, reset ripple effects, smoke control, MSI, FDD/analytics
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

All ten skills become available in every project.

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

Verify with `/skills` in Claude Code — you should see all ten skills listed.

---

## How the Skills Work

The pack uses the three-level **progressive disclosure** model from Anthropic's skill guide:

| Level | What Loads | When |
|---|---|---|
| 1 — Frontmatter | Name + trigger-rich description (~100 tokens/skill) | Always, so Claude knows when each skill applies |
| 2 — SKILL.md body | Core workflows, tables, checklists | When the task matches a skill's triggers |
| 3 — References | Deep technical files | Only when Claude decides it needs the detail |

This keeps context cost near zero until a BAS task actually appears. Skills are deliberately **cross-scoped with negative triggers** — e.g., `bacnet-networking` explicitly defers logic questions to `eikon-programming`, and LED tables live only in `field-commissioning` with other skills cross-referencing by name — so multiple skills compose cleanly on complex tasks (a full design task may load four or five of them together).

---

## Usage Examples

Real prompts these skills are built to handle:

**Sequence design & review**
> "Write a Guideline 36 sequence of operation for a VAV AHU with a DX cooling coil and hot water reheat, including trim-and-respond static pressure reset."

> "Review this 75% controls submittal sequence and flag missing safeties, alarm gaps, and anything that will hurt us at commissioning."

**Programming**
> "Design the EIKON logic structure for a ZN341 serving a classroom with a ZS Pro sensor — occupancy arbitration, setpoint with deadbands, and DCV on the CO2 input."

> "This zone sensor reads 2°F high. Should I offset it or calibrate it, and where?"

**Networking**
> "I have 42 VAV controllers on one MS/TP segment dropping offline intermittently. Walk me through the diagnosis."

> "Design the BACnet network architecture for a 3-building campus: network numbering, router placement, and BBMD strategy."

**Field commissioning**
> "Build me a checkout plan for a floor of 28 VAVs: point-to-point tests per point type, what to record, and what the final state of every point should be."

> "I'm standing in front of a dead OF342-E2 — walk me through LED diagnosis and the restore procedure."

**System design**
> "We're in DD on a 120,000 sq ft academic building. Draft the controls design narrative: system selection rationale, points list approach, valve/damper sizing rules, and sensor placement standards."

> "Explain valve authority to a junior engineer and size a control valve for a coil that needs Cv 25 at design flow."

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
│   └── skills/                 # The 10 skills (see table above)
├── .claude-plugin/
│   ├── plugin.json             # Claude Code plugin manifest
│   └── marketplace.json        # Marketplace metadata for /plugin install
├── LICENSE                     # CC0 1.0 Universal
└── README.md
```

---

## Design Principles

1. **Field usability over theory.** Every skill teaches: explanation → step-by-step actions → best practices → common mistakes. Checklists and worked examples beat prose.
2. **Real numbers, preserved.** Formulas (Q = 1.085 × CFM × ΔT), wiring specs (22 AWG / 2,000 ft MS/TP), limits (~700 microblocks per ZN program, 50 columns per WebCTRL report), field PID startup values (P=2, I=1, D=0 at a 20-second interval), and trim-and-respond parameters are kept exact — never rounded off into generalities.
3. **Sourced, not hallucinated.** Content is compiled from ALC technical instruction manuals, a dealer-verified controller/port capability matrix (which overrides the TI manuals where they conflict — those corrections are encoded as explicit gotchas), ASHRAE standards summaries, BACnet International material, Taylor Engineering and Trane/Carrier engineering publications, documented technician field reports, and working ALC-dealer field standards and checkout procedures. Inline source links are preserved in reference files where content came from public sources.
4. **Scoped skills that compose.** Ten focused skills with explicit boundaries and cross-references instead of one monolithic prompt — better triggering, lower context cost, easier maintenance.
5. **"Slow is smooth, smooth is fast."** The pack encodes a build philosophy: scalable, readable, serviceable systems; confirmed COV over polling; clean naming conventions; minimal broadcast traffic; 100% commissioning of every point, every sequence, every time.

---

## Versioning & Maintenance

- Current version: **1.2.0** (plugin manifest and touched skills share the version)
- **1.2.0** — Integrated the full OptiFlex technical-instruction library into `alc-hardware`: 11 new devices documented (OF022-E2, OF561T-E2, OF683-E2/T/XT, OFBBC-A, OFHI, OFINT-E2, OFISO-E2, OFRTR-E2-S2, FIO expander family), bringing coverage to 24 devices. Added two new reference files: `port-capability-matrix.md` (dealer-verified per-port protocol truth, Act Net reserved addressing, simultaneous-use restrictions, FlexPoint licensing) and `uukl-smoke-control.md` (UL 864 system requirements, timing table, FSCS/FACP requirements, firmware whitelist, per-device smoke-control deltas). Encoded matrix-vs-manual corrections as explicit gotchas (e.g., OF022-E2 verified 25-point BACnet limit, OFINT-E2 Rnet terminal is future-use only). `bacnet-networking` gained a network-infrastructure-devices section (OFRTR-E2-S2, OFISO-E2 isolation architecture, OFINT-E2, OFCSR-E2)
- **1.1.0** — Added `field-commissioning` (complete field checkout discipline: 5-step commissioning workflow, field connection methods, controller service, LED references) and `bas-system-design` (design-to-turnover lifecycle: mechanical design, controls design engineering, submittal/TAB/Cx process, whole-system integration). Expanded six existing skills with working dealer field standards: server lifecycle and WebCTRL 10 (webctrl-platform), field PID tuning and offset-vs-calibration (eikon-programming), MS/TP integration and COV refresh-timer standards (bacnet-networking), device setup procedures and terminal color codes (alc-hardware), IAQ monitoring and redundancy concepts (hvac-fundamentals), CxA process and field SOO verification (sequences-of-operation)
- **1.0.0** — Initial release: 8 skills, plugin manifests, README
- Skill content is a living document set: standards addenda (e.g., Guideline 36-2024, 90.1-2022 adoption), new OptiFlex hardware, and WebCTRL releases will drive updates
- **This README is updated with every change to the skill pack** so it always reflects the exact current contents, structure, and behavior of the skills

Issues and suggestions are welcome via [GitHub Issues](https://github.com/JeffJenkinsBAS/webctrl-skill/issues).

---

## License

[CC0 1.0 Universal](LICENSE) — public domain dedication. Use it, fork it, ship it.
