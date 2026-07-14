# Delivery, Submittals, Installation, and Commissioning

The full workflow from controls submittal through startup, TAB, functional performance testing, and the ongoing commissioning process — the sequencing discipline that determines whether a project's trades can actually be verified against each other.

## Controls Submittal Contents

A rigorous controls submittal (per institutional commissioning requirements) must include, for **every piece of controlled equipment**, complete detailed sequences of operation — regardless of how complete the spec sequences already are — covering ([Dartmouth College Design & Construction Guidelines](https://www.dartmouth.edu/fom/docs/2023_construction_guidelines/01_91_13_general_commissioning_requirements.pdf)):

1. Overview narrative (system purpose, components, function)
2. All interactions/interlocks with other systems
3. Delineation of control between packaged unit controls and the BAS (which points are BAS-monitored-only vs. BAS-controlled-and-adjustable)
4. Written sequences for packaged equipment (manufacturer stock sequences plus added narrative)
5. Start-up, warm-up, normal operating, unoccupied, and shutdown sequences
6. Capacity control/staging sequences
7. Temperature/pressure control: setbacks, setups, resets
8. Detailed control strategy sequences (economizer, optimum start/stop, demand limiting, staging)
9. Power/equipment failure effects and standby behavior
10. Alarm and emergency shutdown sequences
11. Seasonal operational differences
12. Initial and recommended values for all adjustable setpoints/parameters
13. Schedules (if known)
14. Sequentially numbered statements for unambiguous test-procedure referencing

Control drawings must include a key to abbreviations, graphic schematics of every system and component, and layout of any equipment the BAS monitors, enables, or controls — even equipment with its own packaged controls.

## Coordination Drawings

Coordination drawings (increasingly produced in BIM with formal clash detection) resolve physical routing conflicts between ductwork, piping, conduit, cable tray, and structure before fabrication. For controls specifically, coordination drawings establish:

- Sensor and device mounting locations relative to duct geometry
- Panel locations relative to accessible service clearance
- Conduit/cable routing between field devices and panels

This reduces field rework and RFIs, a large part of the value proposition of BIM-based MEP coordination generally ([Advenser Engineering](https://www.advenser.com/mep-coordination/)).

## Equipment Startup Sequence and Trade Sequencing

Startup is a carefully sequenced, multi-trade process, not a single event:

1. **Mechanical contractor** flushes, cleans, chemically treats, and pressure-tests piping; starts AHUs/pumps and verifies correct rotation; installs P/T plugs at each water sensor input point; provides duct test holes for TAB.
2. **Electrical contractor** completes and verifies line- and low-voltage terminations, confirms no shorts/ground faults, before controls checkout begins.
3. **Controls contractor** performs point-to-point checkout — verifying hardware/wiring installation, downloading and address-verifying local controller programs, performing operational checks of each controlled component, and calibrating every valve/damper actuator and sensor — following a written, step-by-step test plan submitted in advance to the commissioning authority ([Dartmouth guidelines](https://www.dartmouth.edu/fom/docs/2023_construction_guidelines/01_91_13_general_commissioning_requirements.pdf)).
4. Only after the controls contractor certifies (signed and dated) that programming is complete and the system is in a state suitable for balancing does **TAB** begin.
5. **Functional Performance Testing (FPT)** by the commissioning authority occurs only after construction checklists, startup reports, preliminary O&Ms, as-builts, and preliminary TAB reports have all been submitted and reviewed — FPT verifies a system that has *already* passed the contractor's own internal QC, not a system still being debugged live in front of the CxA ([Dartmouth guidelines](https://www.dartmouth.edu/fom/docs/2023_construction_guidelines/01_91_13_general_commissioning_requirements.pdf)).

## TAB Coordination with Controls

Per widely used TAB construction standards: TAB shall be performed after the air and hydronic systems are mechanically complete, flushed, cleaned, and started up, **after the controls contractor has completed point-to-point checkout and placed the building automation system in a state suitable for balancing**, and after the building envelope is substantially closed ([SynC TAB Standard](https://synergyinconstruction.com/wiki/sync/testing-adjusting-and-balancing)).

Readiness conditions verified jointly by the TAB contractor, mechanical contractor, and general contractor before field measurements begin: pressure-tested/complete ductwork, clean coils and filters, aligned/tensioned belt drives, powered terminal units, complete/flushed/treated piping, correct pump rotation, and open coil valves.

**Coordination responsibilities specific to controls** (per Dartmouth's institutional standard):

- The controls contractor meets with TAB before balancing begins to review the TAB plan and confirm the control system's readiness to support it, providing any special handheld interfaces TAB will need.
- For any given area, all prefunctional checklists, calibrations, startup, and selected functional tests must be CA-approved *before* TAB starts in that area.
- The controls contractor provides a qualified technician to operate the BAS during TAB (or trains TAB staff to operate it directly).
- The TAB contractor submits a detailed TAB plan six weeks before starting, covering measurement methodology (terminal calibration, pitot traverse, flow stations), ventilation verification methodology, static pressure/exhaust fan checks, sound testing, deferred/seasonal work, and reporting cadence — reviewed jointly with the controls contractor for feasibility.
- Set point and parameter changes made by TAB during balancing must be communicated in writing back to the controls contractor, since these changes affect the control system's setup and operation ([Dartmouth guidelines](https://www.dartmouth.edu/fom/docs/2023_construction_guidelines/01_91_13_general_commissioning_requirements.pdf)).

**This sequence — mechanical startup → electrical verification → controls point-to-point checkout → TAB → functional performance testing — is the standard trade sequence on virtually every commissioned commercial project** and is the backbone against which schedule delays are diagnosed (a late controls checkout, for example, cascades directly into delayed TAB and delayed FPT).

## Commissioning in Depth

### The Commissioning Authority (CxA) Role

The Commissioning Provider/Authority (CxA/CxP) is the independent (ideally third-party) party responsible for planning, directing, and documenting the entire commissioning process across all project phases — predesign through the end of the warranty period. Per **ASHRAE Standard 202**, the CxA's minimum activities include: initiating the Cx process, facilitating OPR development, developing and updating the Cx Plan, performing design reviews, performing/coordinating submittal reviews, developing checklists and test procedures, directing/witnessing/documenting all testing, maintaining the issues and resolution log, assembling the systems manual, conducting/verifying training, and producing the final Cx Report ([ASHRAE Standard 202-2013](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/202_2013_b_20180308.pdf)).

### Design and Submittal Reviews

**Design review**: The CxA reviews design documents for commissioned systems against the OPR — including coordination between systems, features and access needed for testing/commissioning/maintenance — and this review must be completed with issues resolved *before construction documents are issued* for the systems being commissioned. The design team responds with answers/revisions; the CxA back-checks the revised documents; unresolved issues escalate to the owner ([ASHRAE Standard 202](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/202_2013_b_20180308.pdf)).

**Submittal review**: Performed *concurrently* with the designer's own submittal review (not as a replacement for it) — the CxA evaluates submittals for compliance with the OPR specifically, documenting the submittals reviewed, review dates, and any properties that appear not to meet the OPR. This dual-track review (designer checks code/design compliance; CxA checks OPR compliance) is a deliberate structural redundancy meant to catch OPR drift that a purely technical design review might miss.

### Pre-Functional Checklists (Construction Checklists)

A **construction/pre-functional checklist** is a form used by the Commissioning Project Team to verify that appropriate materials and components are on-site, ready for installation, correctly installed, functional, and in compliance with the OPR ([ASHRAE Standard 202](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/202_2013_b_20180308.pdf)). These are developed *after* submittal approval and executed during installation — a static/visual/functional confirmation step (device present, wired, labeled, calibrated) that must be complete before any dynamic Functional Performance Test is scheduled. The CxA typically verifies checklists on a sampling basis rather than reviewing 100% of them, with sample rates scaled to project size and the pace of construction ([ASHRAE Guideline 0-2005 Addenda](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/g0_2005_a_b_c_d_final.pdf)).

### Functional Performance Testing (FPT)

FPT is dynamic testing that actually exercises the system through its full sequence of operation — normal operation, staging, failure modes, alarms, interlocks — to verify it performs per the OPR and BOD, not merely that it was installed correctly. FPT can only be scheduled after the general contractor has submitted complete QC documentation (construction checklists, startup reports, preliminary O&Ms, as-builts, preliminary TAB) proving the system is *already* believed functional — the CxA's role in FPT is independent verification, not initial debugging ([Dartmouth guidelines](https://www.dartmouth.edu/fom/docs/2023_construction_guidelines/01_91_13_general_commissioning_requirements.pdf)). Once test procedures and checklists are established, "responsible entities shall execute relevant test protocols and repeat testing as necessary until equipment, systems, or assemblies pass all tests" — failures that cannot be resolved promptly are logged in the formal issues and resolution log rather than being informally waved through ([ASHRAE Standard 202](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/202_2013_b_20180308.pdf)).

A concrete cross-system FPT example is the **fire alarm/HVAC interface test**: the fire alarm contractor pre-tests the fire alarm system (including HVAC shutdown relays and smoke damper actuation), then the full Functional Performance Test — with the CxA and Authority Having Jurisdiction (AHJ) present — verifies and documents actuation at the fire alarm control panel and demonstrates HVAC equipment shutdown upon field device activation; no FPT proceeds until pre-testing and pre-functional checklists are signed off ([LAWA Division 28 guide specification](https://www.lawa.org/sites/lawa/files/documents/2017%20Division%2028%20Non-IT.pdf)).

### Seasonal, Deferred Testing, and the Warranty Period

Cx Process activities explicitly continue through the end of the contractual warranty period — not just to substantial completion. ASHRAE Standard 202 requires that "seasonal, delayed, and incomplete testing" be completed during this window, with the CxA determining timing "based on weather conditions, load conditions, or occupant interactions" ([ASHRAE Standard 202](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/202_2013_b_20180308.pdf)). This matters enormously for HVAC: a system commissioned during a mild shoulder season cannot have its heating-mode sequences, economizer changeover, or peak cooling-mode staging fully verified until the appropriate season occurs — hence "seasonal" and "deferred" testing being formal, tracked deliverables in the final Cx Report rather than optional afterthoughts.

### Ongoing/Monitoring-Based Commissioning (MBCx), Retro-Commissioning, and Continuous Commissioning

- **Retro-commissioning (RCx)** applies the commissioning process to *existing* buildings that were never formally commissioned, following a structured cycle: planning → investigation (developing functional test plans, executing them, compiling a master deficiency list with energy/cost savings estimates) → implementation (repairs, retesting, fine-tuning) → hand-off, with a plan for future ongoing commissioning as the final deliverable ([DOE FEMP O&M Best Practices Guide, Ch. 7](https://www1.eere.energy.gov/femp/pdfs/om_7.pdf)).
- **Continuous Commissioning™** (a formalized methodology originated by the Energy Systems Laboratory at Texas A&M) is defined as "an ongoing process to resolve operating problems, improve comfort, optimize energy use and to identify retrofits" — the most resource-intensive existing-building Cx approach, since it requires sustained staff/equipment allocation, but it catches inefficiencies as they occur rather than waiting for a periodic audit cycle ([DOE FEMP, citing Texas A&M 2002](https://www1.eere.energy.gov/femp/pdfs/om_7.pdf)).
- **Monitoring-Based Commissioning (MBCx)** is described as "ideal for facilities with building automation system (BAS), advanced metering systems, and well-run O&M organizations" ([DOE FEMP](https://www1.eere.energy.gov/femp/pdfs/om_7.pdf)) — it leverages the BAS's own trend/alarm infrastructure plus dedicated FDD analytics layered on top (see `references/system-integration.md`) to detect performance drift continuously rather than through periodic manual functional testing. MBCx is effectively the operational, technology-enabled evolution of Continuous Commissioning.

### ASHRAE Guideline 0, Guideline 1.1, and Standard 202

- **ASHRAE Guideline 0-2019, "The Commissioning Process"** — describes the generic commissioning process applicable to *all* building systems (not just HVAC), covering every phase from pre-design through occupancy and operation ([ASHRAE Bookstore](https://www.ashrae.org/technical-resources/bookstore/commissioning)).
- **ASHRAE Guideline 1.1** — the HVAC&R-specific application of the Guideline 0 process, historically evolved from the original **Guideline 1-1996 "Commissioning,"** whose classic process diagram maps the commissioning roles across program/design/construction/acceptance/operations phases and explicitly names the mechanical, electrical, controls, and TAB contractors alongside the CM and O&M staff as commissioning team participants at each phase ([Guideline 1-1996 process diagram](https://www.scribd.com/document/498680655/Guideline-1-1996-Commissioning)). It has since been updated (ASHRAE Guideline 1.1-2025, "Application of the Commissioning Process to HVAC&R Systems") to align with the generic Guideline 0/Standard 202 framework.
- **ANSI/ASHRAE/IES Standard 202-2013, "Commissioning Process for Buildings and Systems"** — the normative (standard-format, "shall") version of the commissioning process, defining OPR, BOD, Cx Plan, design review, submittal review, checklists, testing, and the final Cx Report with enforceable process language, versus Guideline 0's more explanatory/informative format ([ASHRAE Standard 202](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/202_2013_b_20180308.pdf)). Standard 202 also introduces the **Current Facility Requirements (CFR)** concept as the existing-building analog to OPR, used specifically for retro-/ongoing commissioning of buildings already in operation.

Industry guidance is consistent that commissioning scope and CxA selection should be initiated **early in the program phase** — ASHRAE Guideline 1/0 explicitly recommend this, and design-build teams are typically expected to identify their commissioning authority within their proposal rather than after design starts ([HVAC Commissioning Guidelines](https://www.scribd.com/document/599853580/HVAC-Commissioning)).

## Common Mistakes

- **Letting TAB start before controls point-to-point checkout is certified complete.** TAB readings taken against an uncommissioned control system will be invalidated the moment the controls contractor finishes calibration and setpoints change.
- **Treating the spec's sequence of operation as final.** The controls contractor's submitted sequence — with all 14 required elements above — supersedes the spec sequence in detail; skipping any of the 14 elements (especially failure/standby behavior and initial setpoint values) creates ambiguity that shows up as RFIs during FPT.
- **Scheduling FPT as a debugging session.** FPT is meant to verify a system the contractor's own QC has already validated — showing up to FPT with unresolved punch-list items burns CxA time and credibility.
- **Skipping seasonal/deferred testing after substantial completion.** Heating-mode sequences and peak cooling staging commissioned only in a shoulder season are unverified — track deferred tests formally through the warranty period, don't let them quietly disappear.
