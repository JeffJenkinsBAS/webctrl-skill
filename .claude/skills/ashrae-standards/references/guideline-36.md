# Guideline 36 — High-Performance Sequences of Operation for HVAC Systems

Read this file when reviewing or writing a G36-based sequence of operation, sizing a G36-driven point list at bid/take-off, or tuning FDD/alarm suppression during commissioning.

## 1. What It Is and Why It's Cited

Guideline 36 (first published 2018, updated 2021, current edition **2024**) provides standardized, pre-engineered, peer-reviewed sequences of operation for common air-side and (as of 2021) water-side HVAC equipment. It was developed by ASHRAE Technical Committee 1.4 from Research Project RP-1455, with the stated purpose of providing "uniform sequences of operation for HVAC systems that are intended to maximize HVAC system energy efficiency and performance, provide control stability, and allow for real-time fault detection and diagnostics" ([txaee.org G36 presentation](https://txaee.org/images/meeting/042721/aee_april_2021___ashrae_guideline_36.pdf); [ASHRAE Manitoba G36-2024 intro](https://www.ashraemanitoba.ca/wp-content/uploads/4.-ASHRAE-Guideline-36-2024.pdf)).

G36 covers sequences, hardwired point lists, control diagrams, and (per the 2024 edition roadmap) functional performance test scripts. It does **not** specify control hardware, network protocol, cybersecurity, or graphics standards — those remain the domain of Guideline 13 and project-specific specs.

Cited benefits: reduced engineering/programming/commissioning time, reduced energy consumption, improved IAQ compliance (aligned with 62.1), and built-in automated fault detection ([75f.io G36 overview](https://www.75f.io/news/ashrae-guideline-36-high-performance-hvac-sequences/)).

G36 sequences are explicitly designed to **exceed** the mandatory/prescriptive minimums of 90.1, 62.1, and 55 simultaneously, giving specifiers a single referenceable document that satisfies multiple code bases at once ([tpc.ashrae.org G36 committee background](https://tpc.ashrae.org/?cmtKey=d536fedd-5057-4fc6-be3a-808233902f4c)).

## 2. Trim-and-Respond (T&R) — The Actual Math

Trim-and-Respond is G36's signature reset methodology, used for:
- Duct static pressure reset
- Supply air temperature (SAT) reset
- Chilled water and hot water supply temperature reset (added in the 2021 water-side expansion)
- Pipe static pressure reset

([Trane Engineers Newsletter on G36](https://www.trane.com/content/dam/trane-commercial/north-america/en/document/engineers-newsletter/ADM-APN078-EN.pdf))

### Mechanics

- The setpoint continuously **trims** (moves toward the energy-saving direction — e.g., static pressure down, SAT up in cooling) at a fixed rate as long as downstream zones remain satisfied.
- Each downstream zone/AHU generates **requests** (typically 0–3) based on rule-based triggers:
  - A VAV damper at 95%+ open generates a static pressure request.
  - A zone temperature exceeding cooling setpoint by 3°C (5°F) for 2 minutes generates 3 SAT-reset requests.
  ([Guideline 36 VAV control sequences summary](https://studylib.net/doc/27122314/high-performance-sequences-of-operation-for-hvac-systems))
- Requests are multiplied by an adjustable **Importance-Multiplier** per zone, letting critical zones (labs, server rooms) dominate the reset logic.
- If the number of (weighted) requests is **≤ the configured "ignore" threshold**, the setpoint continues trimming.
- If requests **exceed** the threshold, the setpoint **responds** (moves toward the more conservative direction) at a defined rate, up to a configured maximum.
- A **Request-Hours Accumulator** and **Cumulative % Request-Hours** are tracked per zone/system for FDD purposes — persistent high request counts flag a zone that is chronically undersized or malfunctioning ([California Energy Commission G36 certification guidance](https://www.energy.ca.gov/sites/default/files/2025-07/G36_certification_guidance_ADA.docx)).

### Typical Numeric Envelope (Static Pressure Example)

| Parameter | Typical Value |
|---|---|
| Trim increment | ~0.02–0.04 in. w.g. every ~2–5 min absent requests |
| Respond increment | Similar increment, often at up to 2x the trim rate, when requests exceed the ignore count |
| Setpoint band | Commonly 0.15–1.5 in. w.g. min/max |
| "Pressure request" trigger | Damper wide open (or airflow ratio <90% of setpoint) |

([Consulting-Specifying Engineer, "Using demand-based reset strategies"](https://www.csemag.com/using-demand-based-reset-strategies/))

**Programming implication:** the trim/respond rates, ignore threshold, importance multipliers, and min/max band are all project-adjustable parameters, not fixed constants — a single reusable EIKON macro should expose all of these rather than hardcoding.

## 3. Zone Groups and Occupancy Modes

- Zones served by a common AHU and schedule are organized into **Zone Groups**; an AHU may serve multiple zone groups if scheduled differently.
- Each zone group operates in one of several **Operating Modes**: **Occupied, Warm-up, Cooldown, Setback, Setup, Freeze-Protect Setback, and Unoccupied.** The *highest-priority* zone mode within a group sets the mode for the entire group ([Yorkland G36 presentation](https://f.hubspotusercontent00.net/hubfs/8975906/ASHRAE%20Guideline%2036%20Presentation%20-%20Yorkland%20June%202021.pdf)).
- **Optimal Start** logic determines pre-occupancy warm-up/cooldown timing per zone based on space temperature deviation, outdoor temperature, and historical performance, feeding into the zone-group-level Warm-up/Cooldown mode timing.
- Every zone carries **separate occupied/unoccupied heating and cooling setpoints**, with:
  - A modest (~1°F) setback triggered by occupancy sensors.
  - A much larger "extreme setback" (e.g., 40°F heating / 120°F cooling) triggered by a window switch — protecting against nuisance conditioning while avoiding freeze/heat damage.

## 4. Ventilation Logic Integration (62.1 Alignment)

G36 explicitly harmonizes with 62.1's Ventilation Rate Procedure: zone minimum airflow is calculated from the actual zone outdoor air requirement (**Voz**) rather than an arbitrary percentage of design airflow — a substantive departure from older "30% of cooling max" VAV minimum conventions ([Steve Taylor G36 lecture](https://www.youtube.com/watch?v=g2bvUCDKGEU); [Puget Sound ASHRAE G36-2018 presentation](https://pugetsoundashrae.org/wp-content/uploads/2019/01/ASHRAE-PS-December-Chapter-Meeting-Guideline36.pdf)).

For zones with CO2 sensors, DCV logic within G36 sets **Vmin = 0%** of the ventilation requirement when CO2 is 200 ppm below setpoint and ramps linearly to 100% at setpoint — directly implementing 62.1's dynamic reset provisions in software.

## 5. VAV Terminal Unit Sequences

G36 provides sequences for the following terminal configurations ([Efficiency Vermont G36 presentation](https://www.efficiencyvermont.com/Media/Default/bbd/2017/docs/presentations/efficiency-vermont-stehmeyer-napolitan-ashrae-guideline-36.pdf)):

- VAV, cooling only
- VAV with reheat
- Parallel fan-powered terminal, constant-volume fan
- Parallel fan-powered terminal, variable-volume fan
- Series fan-powered terminal
- Dual-duct terminal with inlet sensors
- Dual-duct terminal with discharge sensors

**Not covered:** Variable Volume and Temperature (VVT) systems.

Each sequence specifies cascaded PID control (heating loop drives reheat valve, then damper on a different scale; cooling loop drives damper only), discharge air temperature limiting, and — critically for accurate G36 compliance — requires **actual damper position feedback** and **discharge air temperature sensing** at the VAV box. This has direct cost/hardware implications for new construction vs. retrofit projects, and is a frequent point of underestimation at bid time.

## 6. Fault Detection and Diagnostics (FDD)

G36 embeds **rule-based Automated Fault Detection and Diagnostics (AFDD)** directly into its sequences, derived in part from AHU Performance Assessment Rules developed at NIST ([NIST Technical Note 2024 on commissioning G36 VAV sequences](https://nvlpubs.nist.gov/nistpubs/TechnicalNotes/NIST.TN.2024.pdf)).

### FC1–FC15 (Multi-Zone VAV AHU Fault Conditions)

A widely cited example set defines 15 Fault Conditions for multi-zone VAV AHUs, covering conditions such as:
- Mixed-air temperature too low/high given OA/RA temperatures
- Excess outdoor air
- Low/high discharge temp given mixed-air conditions
- Control loop hunting
- Leaking valves/dampers

([GOVPUB NIST summary of G36 FDD rules](https://www.scribd.com/document/582133631/GOVPUB-C13-386b4a80de7b30becf35a563468898e7))

### Hierarchical Alarm Suppression

G36 mandates a **hierarchical alarm suppression** scheme: if an upstream/"source" fault exists (e.g., AHU fan failure), downstream/"load" alarms it would otherwise trigger (e.g., every VAV box reporting low airflow) are automatically suppressed to prevent alarm floods. This suppression logic must be explicitly programmed — it is not a side effect of correctly-written point logic.

### Point-Level Fault Examples (Terminal Unit)

- **Leaking valve detection:** if a heating valve commanded to 0% for 15 minutes still shows discharge air temp >3°C (5°F) above AHU SAT with the fan proven on, generate a **Level 4 alarm**.
- **Sensor drift/failure, damper/actuator stuck-open/closed, and control loop tuning faults** — each with defined test procedures suitable for functional performance testing (FPT) scripts ([CABEC FDD test procedure example](http://cabec.org/wp-content/uploads/2010/08/MECH-13A.pdf)).

### Overridability Requirement

All hardware points must be **overridable through the BAS** (G36 Section 5.1.11) for commissioning purposes, and zone-group-level force/override commands (e.g., force all VAV boxes in a group closed to test for AHU-level leakage) are a required capability. This materially shapes the point list and program structure an ALC programmer must build — it is not optional test-bench functionality, it's part of the deliverable.

## 7. Why Specs Increasingly Require G36

- **State/local energy code alignment:** California Title 24 has moved to reference and, in select applications, mandate G36-based sequences directly; other jurisdictions and utility incentive programs (e.g., Washington State Energy Code) point to it as a compliance pathway or prescriptive credit ([Envigilance BAS requirements 2025 review](https://envigilance.com/energy-monitoring/building-automation-system/)).
- **Owner/institutional standards** (university, healthcare, government) increasingly cite G36 by section number directly in Division 23/25 sequence-of-operation specs rather than writing bespoke sequences — reducing engineering liability and commissioning ambiguity.
- G36 satisfies 90.1, 62.1, and 55 simultaneously, making it attractive as a single referenceable compliance document.

## 8. Implementation Challenges for Controls Contractors

- **Point list burden.** G36 sequences require substantially more hardwired and software points than legacy sequences (damper position feedback, discharge air temp at every VAV box, zone group tables, importance multipliers, request-hours accumulators). This is a direct hardware/programming cost delta that must be captured at bid time, not discovered during submittal.
- **Non-standard variable naming/structure.** G36's discharge-air-temperature-based cascade control for VAV boxes differs fundamentally from legacy single-loop, damper-only control — technicians and programmers must be retrained; EIKON/WebCTRL logic libraries built for legacy sequences are not directly reusable.
- **Commissioning hooks.** The guideline explicitly requires override/test-mode capability and alarm-delay bypass for CxA use, adding programming scope often omitted from early bid estimates.
- **Interpretation variability.** Because G36 is a *guideline* (not adopted as code in most jurisdictions), engineers frequently customize which addenda/options are incorporated (e.g., choice of dehumidification strategy, fan-off-during-standby option per Addendum n). The controls contractor must carefully cross-reference the *specific* edition and included options cited in the spec — never assume "G36 compliance" is a single fixed target.
- **FDD false positives / suppression logic tuning.** A known field pain point; go-live commissioning typically requires several weeks of trend review to properly tune alarm thresholds and suppression hierarchies before FDD is turned over to O&M without excessive nuisance alarms.

## 9. Guideline 36-2024 — Latest Edition Changes

**ASHRAE Guideline 36-2024** incorporates **23 addenda** to the 2021 edition. Key updates ([Standard.no summary of G36-2024](https://online.standard.no/nb/ashrae-guideline-36-2024-high-performance-sequences-of-operation-for-hvac-systems-includes-supporting-files); [75f.io](https://www.75f.io/news/ashrae-guideline-36-high-performance-hvac-sequences/)):

- **Three new modular zone-humidity-limiting/dehumidification strategies** for multiple-zone VAV AHUs, where AHU SAT setpoint is reset to limit zone humidity — designers may adopt one, two, or all three strategies.
- **Outdoor air pollution mode** — a new manual/automatic mode disabling airside economizers when outdoor contaminant levels (e.g., wildfire smoke, PM2.5) exceed user-defined thresholds.
- **Fan staging addendum (Addendum a-2024)** and **Laboratory VAV addendum (Addendum b-2024)** extending sequence coverage to fan-array staging and lab-specific VAV applications with sash/face-velocity considerations.
- Corrections to multi-zone VAV AHUs with separate minimum OA dampers (fixing simultaneous OA/RA damper conflicts) and addenda enabling **fan cycling during occupied-standby mode** for fan-powered terminals and single-zone VAV AHUs ([March 2024 ASHRAE Standards Actions](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20actions/samar_1_2024.pdf)).

**Practical takeaway:** always confirm which edition (2018/2021/2024) and which specific addenda/options a spec cites before assuming a "G36-compliant" sequence submitted on a prior project satisfies a current one.
