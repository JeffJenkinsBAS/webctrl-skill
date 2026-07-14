---
name: hvac-fundamentals
description: "HVAC theory and thermodynamics for commercial and higher-education building controls, from a controls-engineering (BAS/DDC) perspective. Use when writing sequences of operation, sizing/checking loads, diagnosing coil or plant performance, or tuning loops involving psychrometrics, enthalpy, sensible/latent heat, dry-bulb/wet-bulb/dew point, CFM/GPM/delta-T load calcs, chiller plants (primary-secondary, variable-primary, condenser/CHW reset), cooling towers (approach/range), boilers (condensing vs non-condensing, hot water reset), campus steam/district energy, VAV AHUs and terminal boxes, static pressure or SAT trim-and-respond reset, economizers (dry-bulb/enthalpy), DOAS, energy recovery wheels/plate exchangers, fan coil units, lab exhaust/fume hood pressurization and face velocity, PID tuning, cascade control, deadbands, or hunting/oscillating loops. Skip for pure networking/BACnet wiring topics, EIKON microblock syntax, or ViewBuilder graphics authoring — use other WebCTRL skills for those."
metadata:
  author: JeffJenkinsBAS
  version: '1.0.0'
---

# HVAC Fundamentals

Theory and thermodynamics reference for controls engineers writing sequences, sizing loads, and tuning loops on commercial and higher-education BAS projects. Field-practical, formula-forward, ALC/WebCTRL-oriented.

## When to Use This Skill

Use this skill when:

- Writing or reviewing a sequence of operation that involves psychrometric processes (heating, cooling, dehumidification, mixing, economizer changeover).
- Sizing or sanity-checking a coil, AHU, chiller, boiler, pump, or fan using CFM/GPM/delta-T load math.
- Diagnosing why a chiller plant, boiler plant, or AHU isn't hitting expected efficiency (kW/ton, approach, range, IPLV).
- Designing or troubleshooting a reset strategy — CHWST, condenser water, hot water (OA reset), SAT, or duct static pressure trim-and-respond.
- Tuning a PID loop that's sluggish, offset, or hunting, or deciding whether a loop needs P-only, PI, or full PID.
- Working a higher-ed-specific application: lab exhaust/fume hood pressurization, DOAS, energy recovery wheels, library/archive humidity control, dorm/classroom/auditorium load profiles, or campus steam/district energy systems.
- Explaining *why* a sequence works, not just how to program it — this skill supplies the underlying thermodynamics; use it alongside EIKON/WebCTRL programming skills.

**Skip when**: the task is pure BACnet networking, wiring/termination standards, EIKON microblock building, ViewBuilder graphics, or WebCTRL server/database administration — those live in other skills in this pack. This skill is theory/sequence-logic, not platform mechanics.

## Core Equations Quick Reference

All rule-of-thumb constants assume standard air (0.075 lb/ft³, 0.24 Btu/lb·°F) and water (8.33 lb/gal, 1.0 Btu/lb·°F) at sea level. Re-derive if working at altitude or with glycol.

| Quantity | Formula | Units | Notes |
|---|---|---|---|
| Sensible heat, air-side | \( Q_s = 1.08 \times CFM \times \Delta T \) (some refs use 1.085) | Btu/hr | \(1.08 = 4.5 \times 0.24\); lb/hr air = \(4.5 \times CFM\) |
| Latent heat, air-side | \( Q_L = 0.68 \times CFM \times \Delta W \) (\(\Delta W\) in grains/lb) | Btu/hr | Some refs use 4,840 or 0.69 depending on \(\Delta W\) unit convention |
| Total (enthalpy) heat, air-side | \( Q_{total} = 4.5 \times CFM \times \Delta h \) (\(\Delta h\) in Btu/lb dry air) | Btu/hr | Correct formula for **total coil load** — sensible + latent combined |
| Sensible heat, water-side | \( Q = 500 \times GPM \times \Delta T \) | Btu/hr | \(500 = 8.33 \times 60 \times 1.0\); standard CHW/HW coil, chiller, boiler load calc |
| Tons from GPM/ΔT | \( GPM = \dfrac{Tons \times 24}{\Delta T} \) | — | 1 ton = 12,000 Btu/hr |
| Fan affinity — flow | \( Q_2/Q_1 = N_2/N_1 \) | — | Linear with speed |
| Fan affinity — pressure/head | \( H_2/H_1 = (N_2/N_1)^2 \) | — | Square law |
| Fan affinity — power | \( P_2/P_1 = (N_2/N_1)^3 \) | — | **Cube law** — core VFD justification |
| Fan brake horsepower | \( HP = \dfrac{CFM \times \Delta P_{in.wg}}{6{,}350 \times \eta_{fan}} \) | HP | |
| Pump brake horsepower | \( HP = \dfrac{GPM \times \Delta P_{ft\,head}}{3{,}960 \times \eta_{pump}} \) | HP | |
| COP from kW/ton | \( COP = 3.517 / (kW/ton) \) | — | Lower kW/ton = higher COP = more efficient |
| PID output | \( u(t) = K_P e + K_I\int e\,dt + K_D \dfrac{de}{dt} \) | — | See PID Tuning Workflow below |

Source for the equation set: [CED Engineering, *Air Conditioning Psychrometrics*](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf); [Trane Engineers Newsletter handout](https://www.trane.com/content/dam/Trane/Commercial/global/products-systems/education-training/continuing-education-gbci-aia-pdh/HVAC%20Myths%20and%20Realities/APP-CMC062-EN_handout.pdf); [LibreTexts HVAC formula reference](https://workforce.libretexts.org/Courses/Coalinga_College/Introduction_to_Residential_HVAC_Level_1/07:_Trade_Mathematics/7.06:_Conversions_and_Formulas_in_HVAC).

**Field example**: A VAV AHU cooling coil trending 8,000 CFM with 20°F entering-to-leaving dry-bulb drop is doing roughly \(1.08 \times 8{,}000 \times 20 = 172{,}800\) Btu/hr sensible — about 14.4 tons sensible. Compare against the coil's rated total capacity times a reasonable SHR (Section: Psychrometric Process Guidance) to sanity-check a trend before chasing a "bad" sensor.

**Affinity law energy takeaway**: cutting fan/pump speed 20% cuts power to ~51% of full-speed power; a 50% cut drops power to ~12.5% — this is *why* SP/DP trim-and-respond reset (below) is worth programming instead of running fixed setpoints ([Trane](https://www.trane.com/content/dam/Trane/Commercial/global/products-systems/education-training/continuing-education-gbci-aia-pdh/HVAC%20Myths%20and%20Realities/APP-CMC062-EN_handout.pdf)). The cube law holds exactly only for free-discharge devices (cooling tower fans); real ducted/piped systems have a fixed static-pressure component so actual savings are somewhat less than pure cube-law prediction — reset the *setpoint*, don't just add a VFD, to capture the full benefit.

## Worked Load-Calc Examples

Use these patterns when validating a trend, sizing a coil, or explaining a number to a PM/owner.

**Air-side sensible only** — VAV reheat coil, 1,200 CFM box airflow, 55°F entering / 90°F leaving (heating mode):
\[ Q_s = 1.08 \times 1{,}200 \times (90-55) = 45{,}360 \text{ Btu/hr} \]

**Air-side total (enthalpy) — cooling coil**, 10,000 CFM, entering enthalpy 28.1 Btu/lb, leaving enthalpy 22.3 Btu/lb:
\[ Q_{total} = 4.5 \times 10{,}000 \times (28.1-22.3) = 261{,}000 \text{ Btu/hr} \approx 21.75 \text{ tons} \]
Never substitute the sensible formula here — it would only capture the dry-bulb portion and understate true coil load whenever the coil is also dehumidifying.

**Water-side — chiller/boiler check**, 500 GPM at 12°F ΔT:
\[ Q = 500 \times 500 \times 12 = 3{,}000{,}000 \text{ Btu/hr} = 250 \text{ tons (if cooling)} \]
Cross-check: \( GPM = Tons \times 24/\Delta T = 250 \times 24/12 = 500 \) GPM — confirms internal consistency.

**Affinity law power savings** — 15,000 CFM supply fan at 100% design speed drawing 40 BHP; T&R reset trims speed to 80%:
\[ P_2 = 40 \times (0.8)^3 = 40 \times 0.512 = 20.5 \text{ BHP} \]
A 20% speed cut is roughly a 49% power cut in the idealized cube-law case — real ducted systems will save somewhat less due to the fixed static-pressure component, but the direction and rough magnitude hold.

## Psychrometric Process Decision Guidance

Before writing any AHU sequence, identify which psychrometric process the coil/damper/humidifier is actually performing — this drives what setpoint (dry-bulb, dew point, enthalpy) the sequence should be tracking.

| Symptom / requirement | Process | What the sequence should track |
|---|---|---|
| Coil above entering-air dew point, dry-bulb only needs to move | Sensible heating/cooling | Discharge dry-bulb setpoint only; humidity ratio unaffected |
| Coil surface below entering-air dew point | Cooling + dehumidification | Leaving dew point / leaving dry-bulb combo; expect condensate |
| Dry winter OA, need to add moisture | Humidification | Humidity ratio or RH setpoint via spray/steam injection |
| OA-RA blend at mixed-air plenum | Mixing | Resultant state point is a straight line between OA and RA points, weighted by mass-flow ratio — this is the math behind mixed-air-temperature economizer control |
| Economizer changeover decision | Mixing / comparison | **Dry-bulb economizer**: compare OA dry-bulb to setpoint/RA dry-bulb. **Enthalpy economizer**: compare OA enthalpy to RA enthalpy (ASHRAE 90.1-mandated logic in humid climates) so humid-but-cool OA doesn't add latent load |
| DOAS delivering ventilation air | Cooling + dehumidification, "cold not neutral" | Constant leaving dew point + constant (often neutral/slightly cool) dry-bulb — see `references/airside-systems.md` |

Full chart-process table (humidification, desiccant dehydration, evaporative cooling, heating+humidifying) with chart signatures: `references/psychrometrics.md`.

**Sensible heat factor (SHF/SHR)** — ratio of sensible to total heat — tells you how "latent-heavy" a space is and whether a coil selection or DOAS strategy makes sense:

| Space type | Typical SHR | Implication |
|---|---|---|
| Typical commercial office/classroom | 0.75–0.85 | Standard coil selection fine |
| Auditoriums, gymnasiums (high-density assembly) | 0.45–0.65 | Latent load dominates; consider dedicated dehumidification or displacement ventilation |

Full load-profile table by space type (classrooms, libraries, labs, gyms, auditoriums, dorms) is in `references/airside-systems.md`.

## PID Tuning Workflow

**Step 1 — decide if the loop even needs I or D.** Per [David Sellers/PECI's PID overview](https://www.av8rdas.com/uploads/1/0/3/2/103277290/final_-_pid_paper.pdf):

- **P-only**: fine where precision isn't economically warranted. Classic candidates: **zone temperature control**, mixed-air low-limit and other secondary/limit loops.
- **PI**: use where offset causes real energy waste or comfort problems. Classic candidates: **chilled water temperature control**, **building static pressure control**.
- **D**: rarely needed in HVAC. Useful only at startup or with marginally oversized final control elements (e.g., VAV static pressure transient at fan start). Excessive derivative gain "can cause more problems than it cures" — don't add D by default.
- In cascaded/interactive loop sets, it's often best to apply full PID only on the critical outer loop and leave inner/secondary loops as simple P.

**Step 2 — tune.** Two accepted methods:

*Closed-loop (Ziegler–Nichols style):*
1. Zero out I and D.
2. Raise proportional gain until the loop just sustains oscillation (**ultimate gain**, \(K_u\)).
3. Measure the oscillation period (**natural period**, \(P_u\)).
4. Set: \(K_P = 0.25\)–\(0.5 \times K_u\); integral time = \(1.2 \times P_u\) (min/repeat); derivative time = \(P_u / 8\).
5. Validate with setpoint step changes and equipment start/stop cycling.

*Open-loop (process-reaction curve):*
1. Put loop in manual, stabilize, step the output, then reverse-step at 2× magnitude, then return to start.
2. Measure apparent dead time and reaction slope (%output span/min, normalized to step size).
3. Set: \(K_P = 1/slope\) to \(1/(2 \times slope)\); integral time = \(5 \times\) dead time; derivative time = \(0.5 \times\) dead time.
4. Rule of thumb: natural period ≈ 4 × apparent dead time.

**Step 3 — validate against the quarter-decay ratio.** A well-tuned loop shows each oscillation peak at roughly 25% of the prior peak, settling within a few cycles. Settling too slowly → add gain. Staying oscillatory/never settling → reduce gain (see hunting diagnosis below and `references/control-loops.md`).

**Typical starting points for common HVAC loops** (starting points only — always validate on-site; full table with reasoning in `references/control-loops.md`):

| Loop | Typical mode | Notes |
|---|---|---|
| Zone temperature | P-only, or PI with light I | Wide deadband tolerance; P-only per Sellers |
| Discharge/supply air temperature (cascaded from zone) | PI | Fast inner loop of a cascade — see below |
| Chilled water supply temperature | PI | Offset costs real energy — don't leave P-only |
| Hot water supply temperature (OA reset) | PI | Same rationale as CHWST |
| Duct static pressure | PI | Classic trim-and-respond target; watch sensor location |
| Building static pressure | PI | Sellers' other named PI example |
| VAV box airflow (inner loop of cascade) | PI, fast | Pressure-independent cascade inner loop |
| Mixed-air low-limit | P-only | Secondary/limit-protection loop |

**Cascade control**: nest a fast inner loop inside a slower outer loop — outer loop's output becomes the inner loop's setpoint, not the final control element directly. Two textbook HVAC cascades: (1) zone temp (outer, slow) → discharge/supply air temp (inner, fast) → valve/damper; (2) zone temp (outer) → VAV box airflow setpoint (inner) → damper, decoupling zone comfort from upstream duct static pressure swings ([Texas A&M OAKTrust, *Cascaded Control for Improved Building HVAC Performance*](https://oaktrust.library.tamu.edu/server/api/core/bitstreams/04175478-867d-4f93-a6f3-5794ffea0244/content)).

**Diagnosing hunting (sustained oscillation)** — check, in order: throttling range too narrow/gain too high for the system's response speed; time lags (transport/dead time, sensor time constant, actuator stroke time, coil thermal mass, linkage hysteresis); interacting loops (e.g., hunting mixed-air dampers disturbing the static pressure loop); valve/linkage hysteresis producing small limit cycles; sampling/filter artifacts aliasing with a disturbance frequency. Fix by widening throttling range/reducing gain until oscillation stops, then re-tighten cautiously. Retune seasonally — the ultimate-gain point shifts between winter/summer and part-load/full-load operation. Full diagnostic table: `references/control-loops.md`.

## Reset Strategy Guidance

Reset logic recurs across the plant and airside because most equipment is oversized for the majority of operating hours. The pattern is always **trim-and-respond**: watch the most-demanding zone/coil/valve, and back off setpoint only as far as that single worst-case point allows — never based on average conditions.

| Reset | Trigger signal | Moves toward efficiency by... | Detail |
|---|---|---|---|
| CHWST reset | Zone/coil valve position (any valve ~100% open = "request") | Raising CHWST when no valve is starved, cutting chiller lift | `references/chiller-plants.md` |
| Condenser water reset | Ambient wet-bulb + tower capacity | Lowering CWST to cut chiller lift (balanced against tower fan energy) | `references/chiller-plants.md` |
| CHW/HW differential pressure reset | Same valve-position requests as CHWST | Lowering DP setpoint, cutting pump energy (cube law) | `references/chiller-plants.md` |
| Hot water supply temp (OA) reset | Outdoor air temperature | Lowering HWST as OA warms — keeps condensing boilers in their efficient (<130°F return) range | `references/heating-plants.md` |
| Supply air temperature (SAT) reset | Zone valve/damper demand (preferred) or OAT (simpler, less effective) | Raising SAT when zones aren't calling for max cooling, cutting reheat energy | `references/airside-systems.md` |
| Duct static pressure reset (T&R) | VAV box damper position (ASHRAE Guideline 36) | Trimming SP setpoint down when no box is starved, cutting fan energy (cube law) | `references/airside-systems.md` |

**Sequencing note**: at the chiller plant, CHWST reset is generally *more* effective than DP reset alone — sequence CHWST reset first, then DP reset ([Taylor Engineering, *Optimizing Design and Control of Chilled Water Plants*](https://www.scribd.com/document/179701679/Optimizing-Design-and-Control-of-Chilled-Water-Plants-pdf)). Sensor placement matters for every reset in this table: put the DP/SP sensor at the most hydraulically/aerodynamically remote point, not near the pump/fan, or the setpoint floor will be artificially high and energy savings will be left on the table.

## Reference Files

Read these when you need depth beyond the quick-reference tables above — each covers one domain with full math, tables, and source links.

- **`references/psychrometrics.md`** — Full psychrometric chart process table (sensible/latent heat, humidification, desiccant dehydration, evaporative cooling, mixing), moist-air property definitions (WBT, dew point, enthalpy), and the math behind mixing/economizer processes. Read when writing any AHU mixed-air, economizer, or coil sequence.
- **`references/chiller-plants.md`** — Vapor compression cycle, chiller types (centrifugal, screw, scroll, magnetic-bearing), kW/ton/COP/lift, primary-secondary vs. variable-primary plant topologies, CHWST/CW trim-and-respond math (including the Taylor SPLR staging equation), waterside economizers, cooling tower approach/range, and thermal energy storage (chilled water TES, ice TES, MPC). Read when working chiller plant sequences or diagnosing plant efficiency.
- **`references/heating-plants.md`** — Condensing vs. non-condensing boiler efficiency curves and the ~130°F return-temperature threshold, hot water OA reset, hybrid boiler plants, campus steam systems (PRV stations, steam traps), heat recovery chillers, and LTHW district energy examples (Stanford, Western University). Read when working boiler plant, steam distribution, or heat-recovery sequences.
- **`references/airside-systems.md`** — VAV AHU SAT/SP resets in full ASHRAE Guideline 36 T&R detail, VAV box pressure-independent cascade control, DOAS "cold not neutral" and constant-dew-point strategies, energy recovery wheels vs. plate exchangers (cross-contamination tradeoff), FCUs, lab exhaust/fume hood pressurization and face-velocity control (ASHRAE 110 / Z9.5), higher-ed space load-profile table, and library/archive humidity control. Read for any airside sequence or higher-ed application question.
- **`references/control-loops.md`** — Full PID theory (P/I/D roles, integral windup, anti-windup practice), both tuning methods in full step detail, cascade control theory, deadband sizing guidance, and the complete hunting-diagnosis checklist. Read before tuning or troubleshooting any loop.

## Troubleshooting by Symptom

Quick triage table for common field complaints — points to the reference file with the underlying theory.

| Symptom | Likely cause(s) to check first | Reference |
|---|---|---|
| Cooling coil "not keeping up" but valve is 100% open | Check total (enthalpy) load vs. sensible-only estimate; coil may be doing more latent work than expected, or entering conditions exceed design | `references/psychrometrics.md` |
| Economizer bringing in OA that increases the cooling load | Dry-bulb-only changeover in a humid climate — should be comparing enthalpy, not just temperature | `references/psychrometrics.md` |
| Chiller short-cycling between stages | Staging on load/tonnage alone instead of PLR + lift (SPLR); add time delay | `references/chiller-plants.md` |
| Condensing boiler plant showing no efficiency improvement over old non-condensing units | Return water temperature never drops below ~130°F — reset curve or terminal ΔT is wrong | `references/heating-plants.md` |
| Duct static pressure setpoint seems too high / fan energy high despite VFD | SP sensor located too close to the fan instead of the hydraulically remote point | `references/airside-systems.md` |
| VAV box "starves" at low loads even though duct static pressure reads fine | T&R trim-down decrement too aggressive, or box minimum airflow setpoint set below code/heating minimum | `references/airside-systems.md` |
| Fume hood face velocity reads fine but hood fails Z9.5 compliance check | Minimum exhaust volume floor (≥25 cfm/ft²) not programmed independently of face-velocity control at closed sash | `references/airside-systems.md` |
| Zone temperature loop hunting (oscillating) | Throttling range too narrow for actuator/coil response speed; check for interacting loops (e.g., mixed-air dampers disturbing static pressure) | `references/control-loops.md` |
| Loop was stable all winter, now hunting in summer | Ultimate gain/natural period shifted with load and season — retune, don't assume a hardware fault | `references/control-loops.md` |
| Reheat energy unexpectedly high on a VAV system | SAT reset not implemented or not demand-based (OAT-only reset leaves savings on the table) | `references/airside-systems.md` |


## Common Mistakes

- **Using the air-side sensible formula (1.08×CFM×ΔT) for total cooling coil load.** That formula only captures sensible heat. Cooling coils remove sensible *and* latent heat — use \(Q_{total} = 4.5 \times CFM \times \Delta h\) (enthalpy-based) for total coil/tower/chiller load, or you'll undersize load estimates and misdiagnose "underperforming" coils that are actually just doing latent work the sensible formula can't see.
- **Confusing dry-bulb (temperature) economizer with enthalpy economizer.** A dry-bulb-only economizer will happily bring in humid-but-cool OA in a humid climate, adding latent load the "free cooling" mode was supposed to avoid. ASHRAE 90.1 mandates enthalpy comparison for larger economizer-equipped units in humid climates.
- **Running a condensing boiler on a legacy non-condensing reset curve.** If return water never drops below ~130°F, the unit never condenses — one industry estimate cited is that ~90% of commercial condensing boilers never actually operate in their condensing range for exactly this reason. Check the OA reset curve and terminal ΔT design, not just the boiler nameplate.
- **Tuning duct static pressure or DP sensors located too close to the fan/pump instead of the hydraulically remote point.** This forces a higher setpoint than necessary system-wide and wastes fan/pump energy at the cube-law rate — check sensor location before touching PID gains.
- **Adding integral action without reducing proportional gain.** A loop tuned P-only and then given I without retuning P is a common path to hunting. Also: freeze/zero the integral term when associated equipment is off, or integral windup will cause sluggish, overshoot-prone recovery on restart.
- **Applying full PID everywhere "to be safe."** Per Sellers, P-only is correct for zone temperature and limit loops; adding unneeded I or D increases hunting risk without a real precision benefit. Reserve PI for loops where offset costs real energy (CHWST, HWST, static pressure).
- **Ignoring VAV fume hood minimum-flow floors.** Face-velocity control alone isn't sufficient — Z9.5 requires a minimum exhaust volume (≥25 cfm/ft² of hood work surface) even sash-closed, and this floor must be programmed as a hard minimum independent of the face-velocity loop.
- **Treating classroom/library/lab/auditorium loads as interchangeable.** SHR, OA rates, and ventilation drivers differ sharply by space type (see `references/airside-systems.md`) — labs are governed by exhaust safety code, not thermal comfort, and auditoriums run SHR as low as 0.45 at peak occupancy.
