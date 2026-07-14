---
name: bas-system-design
description: "Explains how commercial HVAC/BAS projects are designed and delivered end to end — from mechanical load calcs through controls submittals to turnover and analytics. Use for system design, mechanical design (load calcs, equipment sizing, system-type selection), valve sizing (Cv, valve authority, rangeability), damper selection (opposed vs. parallel blade), sensor placement, panel/transformer design, design phases (SD/DD/CD), delivery methods (plan-and-spec, design-build, design-assist), Division 23/25 structure, OPR/BOD, submittals, MEP coordination, commissioning process (CxA role, pre-functional checklists, functional performance testing, seasonal/retro/MBCx), TAB coordination, and whole-system integration (low delta-T, reset ripple effects, reheat energy, fire alarm/smoke control, MSI, FDD). Skip for EIKON programming, WebCTRL server/DB admin, BACnet/MSTP wiring, or field point-to-point procedures — use other WebCTRL skills for those."
metadata:
  author: JeffJenkinsBAS
  version: '1.0.0'
---

# BAS System Design

How commercial HVAC/BAS projects come together as an integrated whole — from the mechanical engineer's first load calc through the controls contractor's submittal, installation, commissioning, and turnover into ongoing analytics. This is the "why does the project look like this" layer that sits above EIKON programming and WebCTRL platform mechanics: it explains where the controls contractor fits into the design and construction process, and why design decisions upstream (system type, delivery method, valve/damper selection) show up as constraints or opportunities in the field.

## When to Use This Skill

Use this skill when:

- Explaining or reviewing the **project design phases** — Schematic Design (SD), Design Development (DD), Construction Documents (CD) — and what resolution of information exists at each stage.
- Discussing **delivery methods** (plan-and-spec/design-bid-build, design-build, design-assist) and how each determines when and how the controls contractor gets involved.
- Interpreting **Division 23 (HVAC) vs. Division 25 (Integrated Automation)** specification structure, or the role of an **OPR** (Owner's Project Requirements) and **BOD** (Basis of Design).
- **Mechanical design** questions: load calc methods, block load vs. zone load diversity, equipment selection/sizing (AHUs, chillers, boilers, pumps), system-type tradeoffs (VAV, FCU, VRF, WSHP, chilled beams, radiant), duct/pipe sizing, ASHRAE 62.1 ventilation.
- **Controls design** questions: building a points list from mechanical schedules, **valve sizing (Cv, valve authority, rangeability, two-way vs. three-way)**, **damper selection (opposed vs. parallel blade, economizer dampers)**, sensor selection/placement, control panel design, transformer sizing, electrical/controls power coordination.
- **Submittals, installation, and commissioning process**: controls submittal contents, coordination drawings, startup/trade sequencing, TAB coordination, the Commissioning Authority (CxA) role, pre-functional checklists, functional performance testing (FPT), seasonal/retro-/monitoring-based commissioning (MBCx), ASHRAE Guideline 0/1.1 and Standard 202.
- **Whole-system integration**: plant + distribution + airside + zone coupling, low delta-T syndrome, reset ripple effects, reheat energy calculations, fire alarm/smoke control integration, lighting/electrical/metering/generator/elevator/security integration, Master Systems Integrator (MSI) scope, FDD/analytics.
- **MEP coordination** questions — how mechanical, electrical, and controls trades hand off responsibility and where clash/coordination issues typically arise.

**Skip when**: the task is EIKON microblock logic, ZN program structure, WebCTRL server/database administration, BACnet/MSTP network wiring standards, or field checkout/point-to-point procedures — those live in other skills in this pack (`eikon-programming`, `webctrl-platform`, `bacnet-networking`, `field-commissioning`). This skill is design-lifecycle and engineering-decision context, not platform mechanics or field procedure.

## The Design-to-Turnover Sequence

Design intent flows downhill through documents, not memory: **OPR → BOD → spec sequences → controls submittal sequences → as-built systems manual.** Every stage should be traceable back to the OPR; commissioning exists specifically to catch drift at each handoff.

| Phase | What happens | Controls contractor's role |
|---|---|---|
| **Schematic Design (SD)** | System type selected (VAV, VRF, hydronic, etc.); preliminary block loads; mechanical room/shaft locations confirmed | None on plan-and-spec; may co-develop sequences/points list on design-build |
| **Design Development (DD)** | Equipment types/capacities refined; duct/pipe mains laid out; BOD begins taking shape | Design-assist trade contractor may be engaged partway through DD to advise on constructability/cost |
| **Construction Documents (CD)** | Final coordinated drawings, full specs (Div 23/25), equipment schedules issued for permit/bid; spec sequences of operation included | Enters at competitive bid on plan-and-spec (no design input) |
| **Submittals** | Controls contractor submits detailed sequences (superseding spec sequences), control drawings, points list | Primary controls design deliverable — see `references/delivery-and-cx.md` |
| **Installation/startup** | Mechanical → electrical → controls point-to-point checkout, in that order | Point-to-point checkout, calibration, certifies system ready for TAB |
| **TAB** | Testing, adjusting, balancing — only after controls checkout is certified complete | Provides technician support, receives setpoint changes in writing |
| **Commissioning (FPT)** | CxA verifies system against OPR/BOD through dynamic functional testing | Supports FPT; resolves issues in the formal log |
| **Turnover / warranty** | Seasonal/deferred testing continues through warranty period; systems manual finalized | Completes deferred tests; MBCx/FDD picks up ongoing verification |

**Delivery method determines your leverage**:

| Delivery Method | Controls Contractor Entry Point | Characteristics |
|---|---|---|
| **Plan-and-Spec (Design-Bid-Build)** | After CDs are complete, at competitive bid | No design input; bids strictly against spec'd sequences/points list; higher risk of RFIs, spec ambiguity, late-discovered field conflicts |
| **Design-Build** | Often at or before SD, as part of the design-build team | May co-develop sequences and points list with the engineer of record from early on |
| **Design-Assist** | During DD, sometimes as early as late SD | Engaged under a preconstruction agreement to advise on constructability, cost, and layout *before* CDs are finalized, without displacing the engineer of record's design responsibility |

**Design-assist** is now the dominant model for complex mechanical/controls scopes — it's contractually feasible only within design-build or CM-at-risk frameworks (no direct contract between the design-assist subcontractor and the design team) ([AIA Best Practices](https://www.aia.org/sites/default/files/2025-12/AIA_BestPractices_Blurredboundaries-Designassist.pdf)). Benefits: fewer RFIs/change orders, early long-lead equipment release, milestone-based pricing, prefabrication opportunities, and design milestones aligned directly with commissioning/turnover requirements ([Cogence Alliance](https://cogence.org/wp-content/uploads/2018/06/Cogence-Alliance-Design-Assist-Paper-2018.pdf); [Symtech](https://www.symtech.com/capabilities/design-assist/); [EAS Companies](https://www.easinc.net/companies/mechanical-construction/design-assist-design-build)).

## Division 23 and Division 25

- **Division 23 (HVAC)** contains equipment capacity, duct/pipe material and insulation, outdoor air requirements, and — historically — the narrative sequences of operation for HVAC control ([Helonic](https://helonic.com/knowledge-base/csi-specification-divisions)). Common subdivisions: 23 05 00 (common requirements), 23 09 00 (instrumentation/control), 23 21 00/23 64 00 (hydronic/chillers), 23 72 00/23 73 00 (AHUs), 23 34 00 (fans).
- **Division 25 (Integrated Automation)** is reserved for building automation/integration scope spanning multiple systems (HVAC, lighting, electrical metering, life safety interfaces). On MSI-led projects, the MSI typically helps build a deep-level Division 25 that "eliminates scope gaps and overlap" across vendors ([Buildings.com](https://www.buildings.com/smart-buildings/article/33018438/master-systems-integrator-matt-white-of-buildings-iot-on-smart-buildings)). Many projects still keep all BAS scope inside Division 23 (Section 23 09 00) — the choice usually reflects whether cross-system integration ambitions justify a dedicated division.

## OPR and BOD

- **Owner's Project Requirements (OPR)** — a written document detailing project requirements, expectations for use/operation, goals, measurable performance criteria, cost considerations, benchmarks, success criteria, training and documentation requirements ([ASHRAE Standard 202](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/202_2013_b_20180308.pdf)). Developed during predesign by the owner with the commissioning team; a "living document" re-accepted by the owner as the project proceeds.
- **Basis of Design (BOD)** — records the concepts, calculations, decisions, and product selections used to meet the OPR and satisfy applicable codes/standards ([ASHRAE Standard 202](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/202_2013_b_20180308.pdf)). Developed by the design team, submitted at each milestone for evaluation against the OPR.

**Relationship**: OPR defines *what the owner needs*; BOD documents *how the engineer proposes to deliver it*; commissioning verifies, at each phase, that the BOD still satisfies the OPR and installed systems ultimately satisfy both.

## Recurring Theme: Diversity and Simultaneity

The same underlying phenomenon shows up at every scale of a BAS project — the whole is never simply the sum of the parts' individual peaks:

- **Block load diversity** at the central plant (0.85 up to 25 tons, 0.80 for 25–100 tons, 0.75 above 100 tons — see `references/mechanical-design.md`)
- **Occupancy diversity** in ASHRAE 62.1 ventilation calcs (system ventilation efficiency \(E_v\) — see `references/mechanical-design.md`)
- **Worst-zone tracking** in AHU/plant reset logic (trim-and-respond — see `references/system-integration.md`)
- **Low delta-T** at the coil/circuit level (see `references/system-integration.md`)

Recognizing this pattern helps explain *why* a trended value (e.g., total OA intake, plant load) legitimately reads lower than a naive sum of its parts — it's design intent, not necessarily a fault.

## Reference Files

Read these for full depth — each covers one domain with complete math, tables, and source links.

- **`references/mechanical-design.md`** — Load calc methods (HBM/RTSM), block load vs. zone load diversity table, AHU/chiller/boiler/pump sizing, full system-type tradeoff table (VAV/FCU/VRF/WSHP/chilled beams/radiant), duct/pipe sizing methods, ASHRAE 62.1 ventilation formula. Read for any mechanical sizing or system-selection question.
- **`references/controls-design.md`** — Points list classification (control/monitoring/intermediate/calculated), **valve sizing (Cv formula, valve authority formula, two-way vs. three-way, rangeability)**, **damper selection table (OBD/PBD, economizer dampers, actuator torque)**, sensor placement rules (OAT, duct averaging, static pressure, CO2, zone), panel design (UL 508A), transformer sizing math, electrical/controls power coordination. Read for any valve, damper, sensor, or panel design decision.
- **`references/delivery-and-cx.md`** — Full controls submittal contents (14 required elements), coordination drawings, startup/trade sequencing (mechanical → electrical → controls → TAB → FPT), TAB coordination responsibilities, CxA role and activities, design/submittal review process, pre-functional checklists, FPT process, seasonal/deferred testing, RCx/Continuous Cx/MBCx, ASHRAE Guideline 0/1.1/Standard 202. Read for any submittal, startup, TAB, or commissioning-process question.
- **`references/system-integration.md`** — Plant+distribution+airside+zone coupling, low delta-T syndrome root-cause table, reset ripple effects, **reheat energy formula with worked example**, fire alarm/smoke control integration (NFPA 90A/IBC), lighting/electrical/metering/generator/elevator/security integration, Master Systems Integrator (MSI) scope, FDD/analytics (rule-based vs. data-driven), smart building platforms. Read for any cross-subsystem diagnostic or integration-scope question.

## Common Mistakes

- **Treating the spec's sequence of operation as the final word.** The controls contractor's submitted sequence — with all 14 required elements (see `references/delivery-and-cx.md`) — supersedes the spec sequence in detail. Spec sequences establish design intent; submittal sequences are what actually gets programmed and tested.
- **Confusing block load with zone peak load.** Central plant equipment sizes to the diversified block load; terminal equipment sizes to the non-diversified zone peak. Mixing these up produces nonsensical staging or reset logic (see `references/mechanical-design.md`).
- **Sizing a valve or damper to the pipe/duct size instead of to authority.** "Sizing" a control element is really about control authority, not just flow capacity — an undersized-for-authority valve or damper will never be tunable, no matter how good the PID loop is (see `references/controls-design.md`).
- **Letting TAB start before controls point-to-point checkout is certified.** The sequencing discipline (mechanical → electrical → controls checkout → TAB → FPT) is not bureaucracy — it's the only order in which each trade's work is actually verifiable (see `references/delivery-and-cx.md`).
- **Assuming commissioning ends at substantial completion.** Seasonal/deferred testing through the warranty period is where heating-mode and peak-cooling sequences actually get proven; MBCx/FDD is the mechanism that keeps proving performance for the life of the building (see `references/system-integration.md`).
- **Diagnosing a low-delta-T or high-reheat complaint as a single-point sensor issue.** These are whole-system coupling symptoms — check terminal, hydronic, and control-level causes together (see `references/system-integration.md`).
