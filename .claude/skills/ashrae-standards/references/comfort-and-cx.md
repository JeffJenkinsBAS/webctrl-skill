# Thermal Comfort, Commissioning, Emerging Standards, and Spec Flow-Through

Read this file when addressing thermal comfort design (Standard 55), the commissioning process framework (Guideline 13, Standard 202, Guideline 0/1.1), the emerging interoperability stack (223P/231P/205/207), or spec section flow-through and higher-ed master spec practices.

## 1. ASHRAE 55 — Thermal Environmental Conditions for Human Occupancy

### PMV/PPD

Standard 55 defines acceptable thermal environments using the **Predicted Mean Vote (PMV)** model — an index predicting the mean thermal sensation vote of a large occupant population on a 7-point scale from -3 (cold) to +3 (hot), with 0 = neutral ([ASHRAE 55 Wikipedia summary](https://en.wikipedia.org/wiki/ASHRAE_55)).

**Predicted Percentage of Dissatisfied (PPD)** derives from PMV and estimates the percentage of occupants likely to express dissatisfaction with the thermal environment.

**Compliance is achieved when PMV falls between -0.5 and +0.5** (broadly, ≤10% predicted dissatisfaction, per the model curve).

The PMV calculation depends on six factors:
1. Air temperature
2. Mean radiant temperature
3. Air speed
4. Relative humidity
5. Metabolic rate
6. Clothing insulation

([CBE Thermal Comfort Tool](https://comfort.cbe.berkeley.edu/); [calcengineer.com PMV/PPD calculator](https://calcengineer.com/hvac/thermal-comfort-pmvppd-calculator/))

### Operative Temperature and Comfort Zone Methods

- **Operative Temperature (top)** combines air temperature and mean radiant temperature (weighted by air speed) into a single effective temperature metric — the basis for the standard's **graphical comfort zone method**, applicable when metabolic rate is 1.0–1.3 met and humidity ratio is below 0.012 lb H2O/lb dry air.
- Outside those bounds (higher humidity or higher activity levels up to 2.0 met), the **analytical/PMV model** must be used instead of the graphical method.
- The graphic method overlays acceptable operative temperature/humidity combinations on a psychrometric chart for winter (1.0 clo) and summer (0.5 clo) clothing assumptions.
- The standard does **not** specify a minimum humidity level but does bound the humidity ratio ceiling for the simplified method's applicability.

### Setpoint/Deadband Implications for Control Design

- Because acceptable PMV bands correspond to a **range** of operative temperatures (not a single setpoint), BAS zone control should be designed around a **deadband between heating and cooling setpoints** rather than a single tight setpoint — this is the control-theory basis for the deadband requirements embedded in 90.1 (see [references/std-90-1-controls.md](std-90-1-controls.md) Section 3) and universally implemented in G36 zone sequences (separate occupied heating/cooling setpoints with a deadband, plus distinct unoccupied setback/setup values).
- Because humidity, air speed, and radiant temperature all factor into comfort (not just dry-bulb air temperature), **sensor placement and mean radiant temperature effects** (e.g., proximity to large glazing, uninsulated surfaces) are a real design consideration for zones with comfort complaints even when dry-bulb air temperature is nominally in range — a common troubleshooting scenario worth flagging when reviewing occupant comfort complaints against trend data.
- 55's **adaptive comfort model** (for naturally ventilated spaces, referenced in later editions) is generally not directly applicable to mechanically conditioned buildings under BAS control, but is relevant when designing mixed-mode or economizer-heavy sequences with wide seasonal setpoint variation.

## 2. Guideline 13 — Specifying Building Automation Systems

Guideline 13 (most recent editions 2015/2024) is the direct companion document to BAS specification writing — it provides spec-writing guidance rather than sequence content. Current scope covers ([ASHRAE Guideline 13 bookstore page](https://www.ashrae.org/technical-resources/bookstore/ashrae-guideline-13-specifying-building-automation-systems); [CIBSE Guideline 13-2015 summary](https://www.cibse.org/knowledge-research/knowledge-portal/ashrae-guideline-13-specifying-building-automation-systems-2015)):

- BAS system architecture, hardware performance, installation, and training requirements.
- Input/output structure, communication protocols, program configuration, system testing, and documentation.
- **BAS Device Network Design (Clause 12)** as a standalone section — directly relevant to MS/TP segment sizing, IP backbone design, and (per newer content) **BACnet/SC and radio-frequency media** considerations.
- **Cybersecurity considerations** for BAS and network infrastructure — a substantially expanded topic in the 2024 edition, aligning with BACnet/SC's emergence.
- **Legacy control system migration** guidance (Clause 13) — directly relevant when bidding retrofit/expansion work onto existing non-BACnet or older MS/TP infrastructure.
- Informative appendices covering **performance monitoring** (three defined levels, up to automated fault diagnosis) and **FDD**, plus a downloadable **example specification in Microsoft Word format** — many owner/university master specs are directly derived from this template.

**Guideline 13-2024** further formalizes coordination with Guideline 36 and BACnet 135, positioning the three documents as a coherent specify → sequence → communicate stack ([Envigilance BAS requirements review](https://envigilance.com/energy-monitoring/building-automation-system/)).

## 3. Commissioning Standards: Standard 202, Guideline 0, Guideline 1.1

- **ASHRAE Guideline 0, "The Commissioning Process"** — describes the overall commissioning *process* framework (not a testable pass/fail standard), built on three pillars: **Communication, Documentation, and Verification**, beginning in pre-design with development of the **Owner's Project Requirements (OPR)** and continuing through design, construction, and occupancy ([Utah.gov Principles of Building Commissioning presentation](https://www.utah.gov/pmn/files/1040363.pdf); [cxplanner.com Guideline 0 explainer](https://cxplanner.com/commissioning-101/ashrae-guideline-0)).
- **ASHRAE/IES Standard 202 ("Commissioning Process for Buildings and Systems"; current edition 202-2024)** — the more formal, codified standard version of Guideline 0's process, describing roles of principal agents/stakeholders and a framework for design documents, specifications, procedures, documentation, and reports. This is the document most frequently referenced by name in code and by AHJs requiring commissioning (e.g., referenced in IgCC/model green codes as "ASHRAE Standard 202 or another standard accepted by the AHJ") ([ASHRAE Commissioning bookstore page](https://www.ashrae.org/technical-resources/bookstore/commissioning); [Scribd summary of Standard 202-2024](https://www.scribd.com/document/858982157/ANSI-ASHRAE-IES-Standard-202-2024)).
- **ASHRAE Standard 230 ("Commissioning Process for Existing Buildings and Systems")** — the retro-commissioning/existing-building counterpart to 202, relevant for BAS upgrade/retrofit projects.
- **Guideline 1.1** — HVAC&R technical requirements for commissioning, providing the equipment-level functional test detail that complements Guideline 0/Standard 202's process-level framework ([constructandcommission.com Guideline 1.1 overview](https://constructandcommission.com/ashrae-guideline-1-1-hvacr-technical-requirements/)).

### Practical Sequence for a Controls Engineer

\[
\text{OPR (pre-design)} \rightarrow \text{Basis of Design} \rightarrow \text{Division 23/25 specs} \rightarrow \text{BAS submittals/BTL PICS review} \rightarrow \text{installation} \rightarrow \text{FPT} \rightarrow \text{Cx Report} \rightarrow \text{Systems Manual/O\&M turnover}
\]

Division 23/25 specs often cite G36 sections directly for sequences and Guideline 13 conventions for specification structure. Functional Performance Testing (FPT) should exercise G36's built-in override/test-mode hooks (see [references/guideline-36.md](guideline-36.md) Section 6) rather than relying on ad hoc manual overrides. The entire sequence is bounded by the Communication/Documentation/Verification framework of Guideline 0/Standard 202.

## 4. Emerging/Adjacent Standards: 223P, 231P, 205, 207

### Standard 205 — Representation of Performance Data for HVAC&R Equipment

Defines a **common data model and file serialization format (JSON-based)** for equipment performance data (chiller curves, fan curves, coil performance maps, etc.), enabling automated, consistent data exchange between manufacturers, simulation tools (e.g., EnergyPlus), and engineering/commissioning applications ([Purdue conference paper introducing ASHRAE 205](https://docs.lib.purdue.edu/cgi/viewcontent.cgi?article=3287&context=iracc); [ASHRAE Standard 205 resource site](https://data.ashrae.org/standard205/)). For controls engineers, its practical relevance is in **model-based commissioning and FDD** — a 205-compliant equipment performance file lets an FDD or optimization application know the *expected* performance envelope of a chiller or AHU coil without manual data entry, supporting more sophisticated automated diagnostics than rule-based G36 FDD alone.

### Standard 223P — Semantic Data Model for Building Automation

223P (in development/public review as of recent cycles) defines a **metadata schema and semantic ontology** — built on RDF/SHACL/SPARQL/Turtle Semantic Web standards — for describing building equipment, spaces, connections, and points in a machine-readable, vendor-neutral way ([docs.open223.info overview](https://docs.open223.info/overview/); [Energy.gov Control Platforms overview](https://www.energy.gov/eere/buildings/control-platforms)).

Unlike BACnet (which defines *how* devices communicate), 223P defines *what the data means* — e.g., that a given BACnet AI object represents "supply air temperature of AHU-3, downstream of the cooling coil." This directly addresses the industry's chronic **point-mapping/tagging burden**, where every project currently requires manual semantic tagging (Project Haystack, Brick Schema, and proprietary conventions) before analytics/FDD tools can be deployed. 223P was developed in coordination with Project Haystack and the Brick Schema initiative specifically to unify these competing tagging conventions ([Haystack Connect 2019 223P proposal](https://www.haystackconnect.org/wp-content/uploads/2019/05/Proposed-ASHRAE-Standard-223P-Bernhard-Isler.pdf); [Memoori semantic tagging whitepaper](https://cdn2.hubspot.net/hubfs/5083659/Memoori%20Levergaing%20Semantic%20Tagging%20whitepaper.pdf)).

A 223P semantic model can, in principle, allow analytics/FDD software to "self-configure" against a new building's point set, sharply reducing commissioning/integration labor — a capability directly relevant to ALC's own analytics and WebCTRL integration roadmap.

### Standard 231P — Control Description Language (CDL)

231P (public review draft circulated 2024) defines the **Control Description Language (CDL)**, a Modelica-based, vendor-neutral language for expressing control logic (sequences of operation) in a machine-readable, simulatable form, plus the **Controls eXchange Format (CXF)**, a JSON-LD serialization of the same logic for direct import/export into BAS products ([Building Intelligence Group 231P public review summary](https://www.building-intelligence-group.com/blog/2024/2/2/ashrae-231p-a-control-description-language-available-for-public-review); [DOE OpenBuildingControl / LBNL peer review material](https://www.energy.gov/sites/default/files/2021-09/bto-peer-2021-openbuildingcontrol.pdf)).

CDL/CXF share a common library of **~130+ "elementary function blocks"** (Add, PID, etc.) that map conceptually to EIKON-style microblock programming. The strategic significance for an ALC dealer: 231P + G36 + 223P + BACnet 135 together represent ASHRAE's roadmap toward a fully digital chain from **design intent → simulated sequence → deployed controller logic → semantically tagged points → BACnet communication**, potentially reducing (though not eliminating) the manual re-engineering of G36 sequences into proprietary EIKON/graphical programming environments for each project ([LBNL "Digital and Interoperable" whitepaper](https://eta-publications.lbl.gov/sites/default/files/2024-09/digital_and_interoperable_0.pdf)).

### Standard 207 — Laboratory Method of Test for Fault Detection and Diagnostics

Standard 207 (in development, referenced in economizer/DCV literature) provides standardized **laboratory test methods for evaluating FDD system performance** — e.g., verifying that an economizer FDD algorithm correctly detects a stuck damper under controlled test conditions ([greenfan.co ACEEE 2022 economizer FDD paper referencing 207P](https://greenfan.co/wp-content/uploads/2025/09/aceee_2022_smart_economizer.pdf); [tpc.ashrae.org 207 committee documents](https://tpc.ashrae.org/Documents?cmtKey=ac1b7184-f7fc-4b15-9faa-a28b84a8e321)). It complements G36's *in-field* FDD rule sets by providing a repeatable *lab* benchmark, relevant for equipment/controller manufacturers (including ALC) seeking to substantiate FDD performance claims independent of a specific installed building.

**Context:** G36's FDD rule sets (FC1–FC15 for multi-zone VAV AHUs, plus terminal-unit-level fault rules — see [references/guideline-36.md](guideline-36.md) Section 6) remain the most immediately actionable, field-deployable FDD content referenced in specs today. 205/223P/231P/207 represent the next-generation *infrastructure* (data models, semantic tagging, logic exchange, lab test methods) that will make FDD deployment and maintenance progressively less manual over time — monitor these but don't expect them in current project specs.

## 5. Spec Section Flow-Through: Division 23 / Division 25

Under CSI MasterFormat, BAS scope is typically split or cross-referenced between:

- **23 09 00 – Instrumentation and Controls for HVAC** (and sub-sections like **23 09 23 – Direct Digital Control System for HVAC / BACnet DDC**, **23 09 93 – Sequences of Operation for HVAC Control**) — governs field-level HVAC control hardware, DDC controllers, sensors, and sequences ([buildsync.ai Division 23 CSI overview](https://buildsync.ai/resources/division-23-hvac-csi-code); [UFGS 23 09 00 federal spec](https://www.wbdg.org/FFC/DOD/UFGS/UFGS%2023%2009%2000.pdf)).
- **25 00 00 – Integrated Automation** — used on larger/campus/institutional projects to define the **overarching BAS network, head-end/graphics, campus-wide integration, and cross-system (HVAC + lighting + metering) coordination**, often layered on top of 23 09 00's device-level requirements ([Dartmouth 25 00 00 Integrated Automation spec](https://www.dartmouth.edu/fom/docs/2023_construction_guidelines/25_00_00_integrated_automation.pdf); [UC Santa Cruz 25 00 00 BAS spec](https://www.scribd.com/document/651373014/25-00-00-BAS)).

Typical structure, as seen across university/institutional master specs (Brown, Dartmouth, UC Santa Cruz, community college district specs):

- **23 09 00 / 23 09 23** cites BTL-listing requirements, BACnet MS/TP for field controllers and BACnet/IP for supervisory network, specific device profile requirements (B-BC, B-AAC, B-ASC), and often explicitly references **Guideline 36 by section number** for sequences rather than writing custom sequences from scratch ([Brown University 23 09 00 BAS standard](https://facilities.brown.edu/sites/default/files/standards/23%2009%2000%20-%20Building%20Automation%20Systems%20Design%20&%20Construction%20Criteria%2011-6-25.pdf); [4CD Early Learning Center G36-referenced spec](https://webapps.4cd.edu/apps/files/purchasing/misc/05.%20Specifications%20-%20Section%20259000%20Building%20Automation%20Sequences%20of%20Operation.pdf)).
- **25 00 00** governs overall network architecture, protocol interoperability (BACnet/LonWorks/Modbus coexistence on legacy campuses), metering integration, cybersecurity, and BAS contractor qualification (e.g., minimum years installing networked BAS, local service office radius requirements — both seen literally in the Brown University standard).
- Federal work follows **UFGS 23 09 00 / 23 09 23.02 (BACnet DDC) / 23 09 13 / 23 09 93**, tightly coordinated with **25 10 10 (Utility Monitoring and Control System Front End)** for campus-wide DoD/GSA installations ([UFGS 23 09 00](https://www.wbdg.org/FFC/DOD/UFGS/UFGS%2023%2009%2000.pdf)).

## 6. LEED and IECC / Energy Code Adoption

- **IECC** (International Energy Conservation Code), the model code most U.S. states adopt (directly or with amendments), offers a **commercial compliance path that directly references ASHRAE 90.1** as an alternative compliance path — many jurisdictions effectively enforce 90.1's mandatory controls provisions through IECC adoption rather than IECC's own (often similar) prescriptive language.
- **LEED (v4/v4.1)** Energy and Atmosphere credits use **90.1 Appendix G Performance Rating Method** as the baseline for energy modeling credit — meaning the controls sequences modeled in the LEED energy model (economizer, SAT reset, DCV, optimum start) must actually be implemented by the BAS as specified, or the building will underperform its LEED energy model and jeopardize credit/certification.
- This creates a direct paper trail: **LEED energy model assumptions → 90.1 mandatory/prescriptive provisions → Division 23/25 sequence specs → BAS programming** — any gap between what was modeled and what was actually programmed is a common source of post-occupancy LEED/EA credit disputes.
- LEED's **Enhanced Commissioning** credit and **Monitoring-Based Commissioning** requirements explicitly require Cx Plans identifying submeters and BAS trend data sources consistent with 90.1's metering provisions ([Edmonton Commissioning Consultant Manual referencing LEED Canada monitoring-based Cx](https://www.edmonton.ca/sites/default/files/public-files/documents/PDF/Commissioning_Consultant_Manual_Vol1_2018_v2.0.pdf)).

## 7. Higher-Ed and Institutional Design Standards

University and large institutional owners (as seen directly in Brown University, Dartmouth College, and UC Santa Cruz facilities design standards) consistently:

- Mandate a **single approved BAS manufacturer/platform** campus-wide (explaining why ALC dealers frequently encounter sole-source or "or-approved-equal-with-BAS-vendor-authorization" language) and require the controls contractor to be **factory-authorized** by that manufacturer.
- Require **BACnet MS/TP at the unitary/terminal level and BACnet/IP at the supervisory/network level** as a baseline architecture, consistent with Standard 135's network-tier guidance.
- Increasingly cite **Guideline 36 by specific clause number** for sequences rather than writing sequences from scratch, explicitly requiring zone group tables, CO2/occupancy-driven ventilation setpoints per 62.1, and G36-style trend/points lists as submittal deliverables.
- Require **network security and cybersecurity provisions** consistent with Guideline 13's expanded 2024 guidance (network segmentation, no direct internet exposure of legacy BACnet/IP, and increasingly BACnet/SC evaluation for new installations).
- Reference **ASHRAE Standard 202/Guideline 0** commissioning process by name in their commissioning-specific division (often Division 01 91 00) and cross-reference it from the controls specification section.

## Quick-Reference: Compliance Chain and Roles

| Layer | Document | Role |
|---|---|---|
| Process framework | Guideline 0 / Standard 202 | Communication / Documentation / Verification across project lifecycle |
| Equipment-level test detail | Guideline 1.1 | Functional test procedures for HVAC&R commissioning |
| Spec-writing guidance | Guideline 13 | How to write the BAS spec itself (architecture, network, cybersecurity) |
| Sequences | Guideline 36 | What the sequence actually does |
| Protocol | Standard 135 (BACnet) | How devices communicate |
| Semantic meaning | 223P | What the data means |
| Logic exchange | 231P (CDL/CXF) | Machine-readable, vendor-neutral control logic |
| Equipment performance data | Standard 205 | Standardized equipment performance curves/data |
| FDD lab testing | Standard 207 | Lab benchmark for FDD algorithm performance |
