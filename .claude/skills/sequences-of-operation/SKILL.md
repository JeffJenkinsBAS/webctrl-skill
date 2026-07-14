---
name: sequences-of-operation
description: "Write, rewrite, and review sequences of operation (SOO) for commercial and higher-ed HVAC systems, plus commissioning support. Use when the user says: sequence of operation, SOO, write a sequence, review this sequence, AHU sequence, VAV sequence, chiller plant sequence, boiler sequence, trim and respond, Guideline 36 sequence, commissioning checklist, functional test, point list, points list, or submittal review. Covers AHU/VAV/DOAS/lab exhaust airside, chiller/boiler plant waterside, ASHRAE Guideline 36 pre-engineered sequences, and functional performance testing for commissioning. Does not cover EIKON block-level programming syntax or WebCTRL graphics build-out — see the eikon-programming and webctrl-platform skills for that."
metadata:
  author: JeffJenkinsBAS
  version: '1.1.0'
---

# Sequences of Operation (SOO)

## When to Use This Skill

Use this skill when asked to:

- **Write** a new SOO for an AHU, VAV box, chiller plant, boiler plant, DOAS, or lab exhaust system.
- **Rewrite** or clean up a vague, contradictory, or incomplete SOO.
- **Review** a submitted SOO (engineer's spec, design-build submittal, or existing as-built sequence) for gaps, ambiguity, or commissioning risk.
- Decide whether to use **ASHRAE Guideline 36** pre-engineered sequences vs. a conventional sequence, or explain trim-and-respond logic.
- Build a **functional test script**, **point-to-point checklist**, or **deficiency list** for commissioning.
- Populate or QA a **point list / points list** against a sequence's stated inputs, outputs, and alarms.
- Run the **field SOO verification workflow** (Logic-page checks, PID startup values, lead/standby rotation test, CT status setup) after point-to-point and before functional testing.
- **Simplify** a dense, submittal-length SOO into a field-usable tech summary.
- Explain how the formal **Commissioning Authority (CxA) process** (OPR/BOD, design/submittal review, pre-functional checklists, FPT, Standard 202) relates to the controls contractor's own commissioning scope.

**Skip when:** the task is EIKON microblock logic construction (load `eikon-programming`), WebCTRL graphics/ViewBuilder paths (load `webctrl-platform`), or hardware/wiring selection (load `alc-hardware`). Those skills implement what this skill specifies.

---

## 1. The Mandatory SOO Structure

Every sequence — new, rewritten, or under review — must follow this order. If a section has nothing to say, write "None" or "N/A" explicitly. Never omit a section silently; a missing section is itself a defect (see the review checklist).

1. **System Overview** — equipment tag(s), system type, service area, design capacity (cfm/gpm/tons/MBH), major components, and how it relates to upstream/downstream equipment (e.g., "AHU-3 serves VAV boxes 3-01 through 3-14 on the Science Building third floor; chilled water from CHW Plant, hot water from HW Plant").
2. **Enable/Disable Conditions** — exactly what starts and stops the equipment: schedule, BAS command, safety interlock status, freeze/smoke conditions, lead/lag rotation. State every enable condition as an AND/OR logic statement, not a narrative. Example: "AHU-3 SF starts when: (schedule = Occupied OR Optimal Start active OR BAS override = On) AND smoke detector = Normal AND low-limit freezestat = Normal AND SF status failure alarm not active for >5 min."
3. **Occupied Mode** — every control loop active during occupied operation: setpoints, loop type (P, PI, cascade), reset logic if any, sequencing order (e.g., economizer before mechanical cooling).
4. **Unoccupied Mode** — setback/setup values, unoccupied cycling (night cycle, morning warm-up/cooldown per 90.1 optimum start), what stays enabled (freeze protection, lab exhaust) vs. disabled.
5. **Reset Logic** — every trim-and-respond or OA-reset schedule used anywhere in the sequence, stated with the full parameter set (see Section 3 table). Do not reference "reset as needed" — give the schedule.
6. **Safeties and Failure Response** — every safety (freezestat, high static, smoke, low suction pressure, low water flow, high discharge temp) with its exact setpoint, its action (what shuts down, what opens/closes, what alarms), and its manual/auto reset behavior. State reset method explicitly: auto-reset vs. manual-reset-required-at-panel.
7. **Alarm Conditions** — every alarm with trigger value, time delay, severity/priority, and required operator action. Distinguish "informational" from "critical/life-safety" alarms.
8. **Operator-Adjustable Items / Notes / Assumptions** — every setpoint or parameter intended to be field-adjustable (list with typical value and adjustable range), plus any assumptions made about equipment not yet selected (e.g., "assumes VFD-equipped supply fan; sequence must be revised if constant-volume fan is furnished").

### Language rules — no exceptions

- **Ban vague qualifiers** unless immediately defined: "as needed," "as required," "appropriate," "normal conditions," "sufficient," "periodically," "typical." If one of these phrases is unavoidable, define it in the same sentence: "cycle the OA damper periodically (once every 10 minutes for 30 seconds) to prevent linkage seizure" is acceptable; "cycle the OA damper periodically" alone is not.
- **Every setpoint gets a number and a unit.** "Maintain comfortable space temperature" is not a setpoint. "Maintain space temperature at 72°F ± 1.5°F deadband (occupied cooling SP 73.5°F / heating SP 70°F)" is.
- **Every timer gets a duration.** "After a delay" → "after a 5-minute time delay."
- **Every reset gets bounds and a rate.** Never write "reset supply air temperature based on demand" without SPmin, SPmax, trim rate, and respond rate.
- **State the failure position of every actuator.** Every damper, valve, and VFD sequence must say what it fails to on loss of power/air/signal (e.g., "OA damper fails closed; HW valve fails open; VFD fails to bypass at last-commanded speed or stops — confirm with electrical").
- **Name points consistently.** Use one name per physical point throughout the document. If the spec calls it "SAT" in one place and "DAT" in another for the same sensor, flag it — don't propagate the inconsistency.

---

## 2. SOO Review Checklist

Run every SOO — whether authored in-house, received from an engineer, or pulled from an old project — through this checklist before it goes to programming or submittal response. Mark each item Pass / Fail / N/A and attach the specific line reference for any Fail.

### 2.1 Missing points
- [ ] Every sensor/actuator named in the narrative appears on the point list (and vice versa — no orphan points with no narrative role).
- [ ] Status/feedback points exist for every commanded device (fan status separate from fan command; damper position feedback if the sequence claims pressure-independent or G36-style control).
- [ ] Discharge/mixed-air/space sensors required by the stated control loops are present (a cascade loop needs both the inner and outer sensor).

### 2.2 Contradictory language
- [ ] No setpoint stated twice with different values in different sections.
- [ ] Enable conditions in the overview match the enable conditions repeated (if at all) in occupied/unoccupied sections.
- [ ] Reset bounds (SPmin/SPmax) don't conflict with hard safety limits stated elsewhere (e.g., SAT reset max of 68°F vs. a stated high-discharge-temp alarm at 65°F).

### 2.3 Unclear safeties/interlocks
- [ ] Every safety states its setpoint, its shutdown scope (this unit only? upstream fan too? associated exhaust?), and reset method (auto vs. manual).
- [ ] Interlocks between equipment (e.g., exhaust fan interlocked to supply fan, boiler interlocked to pump proof) are stated as explicit logic, not implied by proximity in the document.
- [ ] Freeze protection response is unambiguous: does it stop the fan, close the OA damper, open the HW valve fully, or all three — and in what order?

### 2.4 Occupancy/enable gaps
- [ ] A mode exists for every hour of the year: occupied, unoccupied, and the transition modes (warm-up, cooldown, standby) — no gap where the equipment's behavior is undefined.
- [ ] Holiday/exception schedule handling is stated (defaults to unoccupied unless overridden).
- [ ] Manual override / BAS forced-occupied behavior and its timeout are defined.

### 2.5 Alarm gaps
- [ ] Every safety (Section 1.6) has a corresponding alarm (a safety trip that doesn't alarm is a commissioning and O&M defect).
- [ ] Sensor failure / out-of-range behavior is defined for every sensor driving a control loop (what does the loop do if the SAT sensor fails?).
- [ ] Alarm time delays are stated (instant trip vs. delayed) and are appropriate to the consequence (life-safety = fast, nuisance-prone = delayed).

### 2.6 Sensor/actuator ambiguity
- [ ] Sensor location is unambiguous (e.g., "duct static pressure sensor located at 75% of the distance down the longest duct run, per Guideline 36 guidance" — not just "duct static pressure sensor").
- [ ] Units and range are stated for every analog point (°F vs. °C, in.w.g. vs. Pa, % vs. position).
- [ ] Actuator action (normally open/closed, direct/reverse acting) is stated wherever ambiguity is possible.

### 2.7 Inconsistent naming
- [ ] One point = one name throughout the entire document, appendices, and point list.
- [ ] Equipment tags match the drawings/BOD (e.g., "AHU-3" vs. "AH-3" vs. "AHU3" — pick one and verify against the mechanical drawings).
- [ ] Abbreviations are defined once (glossary or first use) and used consistently thereafter.

### 2.8 "Typical of" ambiguity
- [ ] Every "typical of X" or "typ." callout states exactly which units it applies to (by tag list, not just "similar units") and flags any unit-specific exceptions (different capacity, different sensor package, different safety).
- [ ] If a VAV "typical" sequence is used for boxes with different reheat types (electric vs. hot water) or different minimum/maximum airflow, the exceptions are called out per box, not buried in a footnote.

### 2.9 Commissionability pain points
- [ ] Every point is overridable/forceable through the BAS for test purposes (G36 requirement, but good practice for any sequence).
- [ ] The sequence states expected values/ranges a commissioning agent can verify against trend data (e.g., "SAT should track setpoint within ±1°F once the AHU has been running >10 minutes").
- [ ] Zone-group or system-level test/override commands needed for functional testing (e.g., force all VAV dampers closed to leak-test the AHU) are explicitly provided for, not assumed.
- [ ] Sequence doesn't require simultaneous physical conditions that can't be created/verified in the field (e.g., a functional test that can only be performed at a specific unrepeatable outdoor condition without a documented workaround).

### 2.10 Implied-but-unlisted scope
- [ ] Anything the sequence assumes exists (e.g., "coordinate with lighting occupancy sensor" or "interlock with fire alarm relay") is called out as an explicit scope/coordination item, not left as an implication.
- [ ] Metering, trending, and submetering requirements implied by code (90.1 Section 6.4.3, LEED EA credits) are stated as points, not assumed to be "someone else's scope."
- [ ] Optimum start, DCV, economizer high-limit fault reporting — all 90.1-mandatory sequences — are present if the equipment type requires them, even if the spec didn't explicitly call them out line-by-line.

---

## 3. Guideline 36 Quick Guidance

### 3.1 When to use G36 vs. conventional sequences

| Use G36 when… | Use conventional (custom) sequence when… |
|---|---|
| Spec explicitly cites Guideline 36 by section number (common on higher-ed/institutional Division 23 09 93) | Spec has a fully custom, engineer-authored sequence that does not reference G36 |
| Owner/university standard mandates G36-based sequences campus-wide | Simple single-zone or small package unit with no zone group / reset complexity |
| Energy code compliance path (LEED, Title 24, WA state) references G36 as the pathway | Legacy retrofit where hardware (no damper feedback, no discharge sensor at VAV boxes) can't support G36's point requirements without added cost the owner won't fund |
| Project wants built-in FDD/AFDD without custom engineering | Equipment type G36 doesn't cover (e.g., VVT systems, most single-zone RTUs with simple sequences, specialty lab exhaust beyond G36's addenda scope) |

Confirm which **edition and addenda** are cited (2018, 2021, or 2024) — options like humidity-limiting strategy choice, fan-off-during-standby, and pollution mode are addenda-specific and not automatically included just because "Guideline 36" is named ([ASHRAE Guideline 36-2024 summary](https://online.standard.no/nb/ashrae-guideline-36-2024-high-performance-sequences-of-operation-for-hvac-systems-includes-supporting-files)). G36 covers sequences, point lists, and control diagrams — it does not specify hardware, protocol, or graphics standards ([ASHRAE Guideline 36 background, txaee.org](https://txaee.org/images/meeting/042721/aee_april_2021___ashrae_guideline_36.pdf)).

### 3.2 Trim-and-Respond pattern

T&R is G36's signature reset methodology for duct static pressure, SAT, CHW/HW supply temperature, and pipe DP reset. Mechanics: the setpoint **trims** (backs off, saves energy) on a timer as long as no requests are outstanding; it **responds** (moves toward design) faster when requests exceed the ignore threshold ([ASHRAE Guideline 36 T&R description](https://www.trane.com/content/dam/trane-commercial/north-america/en/document/engineers-newsletter/ADM-APN078-EN.pdf)).

Always specify every column below — a T&R block with any column missing is not a complete sequence:

| Parameter | Meaning | Example — Duct SP reset | Example — SAT reset | Example — CHWST reset |
|---|---|---|---|---|
| **Device** | What's being reset | AHU-3 supply fan VFD | AHU-3 SAT setpoint | Chiller plant CHWST setpoint |
| **SP0** | Initial setpoint at plant/AHU start | 1.2 in.w.g. | 55°F | 42°F |
| **SPmin** | Minimum allowed setpoint | 0.4 in.w.g. | 55°F | 42°F |
| **SPmax** | Maximum allowed setpoint | 1.5 in.w.g. | 65°F | 48°F (2°F below lowest AHU SAT SP) |
| **Td** | Delay timer before first trim/respond evaluation | 5 min | 10 min | 15 min |
| **T** | Time step between evaluations | 2 min | 5 min | 5 min |
| **I** | Number of ignored requests before responding | 2 | 2 | 1–2 |
| **SPtrim** | Trim amount per time step (no requests) | −0.02 in.w.g. | +1°F (raising SAT saves energy) | +1°F |
| **SPres** | Respond amount per time step (requests > I) | +0.06 in.w.g. | −2°F | −2°F |
| **SPres-max** | Maximum single respond step | +0.06 in.w.g. | −2°F | −2°F |

Numeric ranges seen in field practice: duct static pressure trims ~0.02–0.04 in.w.g. every 2–5 minutes absent requests, and responds at up to 2x that rate within a 0.15–1.5 in.w.g. band ([Consulting-Specifying Engineer on demand-based reset](https://www.csemag.com/using-demand-based-reset-strategies/)). Sequence CHWST reset before DP reset — CHWST reset is generally more effective on its own ([Taylor Engineering chilled water plant optimization](https://www.scribd.com/document/179701679/Optimizing-Design-and-Control-of-Chilled-Water-Plants-pdf)). Track a **Request-Hours Accumulator** per zone/device for FDD — chronic high request counts flag an undersized or malfunctioning zone ([California Energy Commission G36 certification guidance](https://www.energy.ca.gov/sites/default/files/2025-07/G36_certification_guidance_ADA.docx)).

**Request generation examples** (state these explicitly in any G36 sequence):
- Static pressure request: VAV damper position ≥ 95% open, or airflow < 90% of setpoint.
- SAT reset request: zone calling for cooling with a discharge/reheat valve fully closed and zone temp > cooling SP + 3°F for 2 minutes = 3 requests; smaller deviations generate 1–2 requests.
- Weight requests per zone by an adjustable **Importance-Multiplier** so critical zones (labs, server rooms) dominate the reset math.

### 3.3 Zone groups and occupancy modes

- Zones served by a common AHU/schedule form a **Zone Group**; one AHU can serve multiple groups on different schedules.
- Operating modes, in priority order: **Occupied, Warm-up, Cooldown, Setback, Setup, Freeze-Protect Setback, Unoccupied.** The highest-priority mode among any zone in the group sets the mode for the whole group ([Yorkland G36 presentation](https://f.hubspotusercontent00.net/hubfs/8975906/ASHRAE%20Guideline%2036%20Presentation%20-%20Yorkland%20June%202021.pdf)).
- **Optimal Start** sizes warm-up/cooldown lead time from space temp deviation, OAT, and historical performance — state the algorithm inputs, don't just say "optimal start enabled."
- Every zone carries separate occupied heating/cooling setpoints, unoccupied setback (~1°F nuisance-avoidance via occupancy sensor), and an extreme setback (e.g., 40°F heat / 120°F cool) on a window switch or similar override.
- Zone minimum airflow should be calculated from the actual zone outdoor-air requirement (Voz per 62.1), not an arbitrary % of cooling max ([62.1 Ventilation Rate Procedure alignment](https://txaee.org/images/meeting/042721/aee_april_2021___ashrae_guideline_36.pdf)). For CO2-equipped zones, ramp Vmin linearly from 0% at 200 ppm below setpoint to 100% at setpoint.

See `references/g36-sequences.md` for full VAV box/AHU sequence detail, FDD fault rules, and alarm suppression logic.

---

## 4. Typical Setpoint / Reset Values Table

Use these as starting points only — always state the project-specific values actually used, and verify against the current ASHRAE edition, mechanical schedule, and equipment submittal before issuing a stamped or as-built sequence.

| System | Parameter | Typical value / range | Notes |
|---|---|---|---|
| VAV AHU | SAT design (cooling) | 55°F | Reset up to ~65°F max under G36 T&R as zone demand allows ([ASHRAE Guideline 36 T&R](https://www.trane.com/content/dam/trane-commercial/north-america/en/document/engineers-newsletter/ADM-APN078-EN.pdf)) |
| VAV AHU | Duct static pressure SP | 0.4–1.5 in.w.g. band (T&R) | Sensor at ~75% down longest duct run, not near the fan |
| VAV AHU | Mixed-air low limit | 45–50°F | Prevents coil freeze; overrides economizer position |
| VAV AHU | Economizer high-limit (fixed dry bulb) | ~65–75°F by climate zone | Per 90.1 Table 6.5.1.1.3; verify climate zone-specific value |
| VAV box, cooling only | Minimum airflow | Per calculated Voz (62.1), not arbitrary % | Legacy "30% of cooling max" is non-compliant/inaccurate |
| VAV box w/ reheat | Heating max airflow | Box heating minimum, per Voz and reheat capacity | Reheat modulates only once box is at heating-min airflow |
| Zone | Occupied cooling SP | 74–75°F | Deadband 2–5°F between heat/cool SP (ASHRAE 55 comfort band) |
| Zone | Occupied heating SP | 70–71°F | — |
| Zone | Unoccupied setback (heat/cool) | 60°F / 85°F | Occupancy-sensor-triggered ~1°F nuisance setback also common |
| Zone | Deadband | 2–5°F | Prevents simultaneous heat/cool cycling |
| CHW Plant | CHWST design (SPmin) | 42°F | Reset up (SPmax) to ~2°F below lowest AHU SAT SP as load allows |
| CHW Plant | CHW DP reset band | ~3 psi (min, at remote coil) to design max | DP sensor at hydraulically most remote/critical coil |
| CHW Plant | Chiller staging | Based on part-load ratio AND lift, not load alone | \(SPLR = E(CWRT-CHWST) + F\) — Taylor Engineering method |
| CHW Plant | VSD CHW pump staging | ~47% of design flow | VSD CW pump staging ~60% of design flow |
| Condenser water | CWST reset | Track ambient wet-bulb + tower capacity | Balances chiller lift savings vs. tower fan energy |
| Cooling tower | Range / Approach (design) | 10°F range / 7°F approach | e.g., 85°F leaving CW at 78°F design wet-bulb |
| HW Plant | HWST reset (OA reset) | ~180°F design → lower with warmer OA | Condensing boilers need return water <130°F to stay in condensing range |
| HW Plant | Non-condensing boiler return water floor | >130–140°F | Prevents flue-gas condensation/corrosion in non-condensing equipment |
| HW Plant | Boiler turndown | 3:1 to 25:1 typical modern modulating condensing units | ENERGY STAR minimum 5:1 |
| DOAS | Leaving air dew point | Below space dew point setpoint, "cold not neutral" | Local unit then handles sensible only |
| Lab exhaust / fume hood | Face velocity | 80–120 fpm (100 fpm typical target) | ±20 fpm allowed deviation across face, per Z9.5 |
| Lab exhaust | Minimum VAV hood exhaust (sash closed) | ≥25 cfm/ft² of hood work surface | Z9.5 minimum flow floor, independent of face velocity control |
| Lab room | General ventilation | 4–10 ACH occupied minimum | Z9.5-2022; room held negative to corridor |
| DCV zones (classroom/assembly) | CO2 setpoint | 1,000–1,100 ppm | Sensor accuracy ±75 ppm at 600 ppm and 1,000 ppm per 62.1-2022 Addendum ab |

---

## 5. Commissioning Support

### 5.1 Functional test script structure

Every functional test script needs these fields — do not skip any when drafting a test for a CxA or self-commissioning use:

1. **Test ID / Equipment tag** — e.g., FT-AHU3-01.
2. **Test title** — plain description ("Economizer changeover, free-cooling to mechanical").
3. **Prerequisite conditions** — what must be true to run the test safely and meaningfully (e.g., "OAT between 55–65°F," "AHU running in occupied mode for ≥10 minutes").
4. **Procedure steps** — numbered, each with an action and an expected system response ("Step 3: Force OAT point above economizer high-limit setpoint (75°F). Expected: OA damper drives to minimum position within 3 minutes; mechanical cooling stages on if zone demand present.")
5. **Acceptance criteria** — the numeric tolerance that defines pass ("SAT settles to setpoint ±1°F within 10 minutes of step completion").
6. **Points to trend/observe** — the exact BAS points to watch during the test.
7. **Pass/Fail/Deficiency** — recorded result with date, tester initials, and trend data reference.
8. **Restore-to-normal step** — always end by removing any forced points and confirming normal operation resumes.

### 5.2 Point-to-point checklist structure

For physical/wiring verification before functional testing begins:

- Point name (matches point list exactly) | Point type (AI/AO/BI/BO) | Device/panel | Expected range or state | Field-verified value | Pass/Fail | Tech initials/date

Verify every hardwired point physically (toggle the input, command the output, confirm at the field device) before relying on it in a functional test — a point-to-point failure caught late is a functional test failure with an unrelated root cause, and wastes commissioning time.

### 5.3 Deficiency list format

| Deficiency # | Equipment/System | Description | Sequence/Spec reference | Severity (Critical/Major/Minor) | Responsible party | Status | Retest date |
|---|---|---|---|---|---|---|---|

- **Critical**: life-safety, code-compliance, or equipment-damage risk (e.g., freeze protection doesn't trip). Requires immediate correction before occupancy/turnover.
- **Major**: sequence doesn't perform as specified, affects comfort/energy but not safety (e.g., SAT reset never trims).
- **Minor**: cosmetic, naming, or documentation issue (e.g., point name mismatch between BAS and as-built).

See `references/commissioning.md` for the full functional-testing methodology, trend-based verification approach, common deficiencies by system type, the formal CxA process (Standard 202/Guideline 0/1.1, OPR/BOD, pre-functional checklists, FPT, seasonal/retro-Cx/MBCx), Automated Controls' internal 100% commissioning standard, the field SOO verification workflow (Section 7), and the SOO simplification technique (Section 8).

---

## 5.4 Commissioning Quick Reference

| Item | Key detail | Detail |
|---|---|---|
| Internal Cx standard | 100% of equipment touched/inspected — not the 10–30% sampling common to 3rd-party CxAs | `references/commissioning.md` §1.2 |
| Never-locked-out safeties | High Static, Low Static, Freezestat — always functional, even mid-commissioning | `references/commissioning.md` §1.2 |
| CxA governing documents | ASHRAE Guideline 0 (generic process), Guideline 1.1 (HVAC&R-specific), Standard 202 (OPR/BOD/Cx Plan/FPT/final report, normative) | `references/commissioning.md` §1.1 |
| PID startup/checkout values | P=2, I=1, D=0, Interval=20 sec — then tune further | `references/commissioning.md` §7.3 |
| Untuned PID default (red flag) | P=20, I=5, D=0 → essentially bang-bang 0%→100%→0% | `references/commissioning.md` §7.3 |
| Loop freeze test | Lock OA temp true-point to 30°F, confirm all freeze-protection actions fire | `references/commissioning.md` §7.3 |
| Lead/standby rotation test | AUTO → kill lead at disconnect → confirm swap + alarm → verify timing | `references/commissioning.md` §7.3 |
| CT status threshold | Set "True if > Constant" just below actual observed running current | `references/commissioning.md` §7.3 |
| Field temp sensors | 10K ohm @ 77°F thermistor, not polarity-sensitive | `references/commissioning.md` §7.3 |
| SOO simplification | 7-step technique: read → chunk → highlight I/O/conditions → flowchart → cut fluff → match to field → 1-page tech summary | `references/commissioning.md` §8 |

## 6. Worked Example — Applying the Structure to a Short AHU Sequence

Below is a compressed illustration of the mandatory structure (Section 1) applied to a single-zone AHU with reheat, showing the difference between vague and acceptable language.

**Vague (reject on review):**
> "The AHU runs during occupied hours and maintains comfortable space temperature. Static pressure is reset as needed. If there's a problem, the unit alarms."

**Acceptable:**
> 1. **Overview:** AHU-7 is a single-zone, VAV-capable unit serving Room 204 (classroom, 32 occupants design). Design supply airflow 1,200 cfm; cooling coil 3 tons; electric reheat, 15 kW.
> 2. **Enable/Disable:** Supply fan starts when (schedule = Occupied OR BAS override) AND freezestat = Normal AND smoke detector = Normal. Stops on loss of any condition or fan-status mismatch >5 min.
> 3. **Occupied:** Zone temp PI loop modulates supply airflow between Vmin 480 cfm (62.1 Voz for 32 occupants at 10 cfm/person + area component) and Vmax 1,200 cfm. Below heating SP 70°F, airflow holds at Vmin while discharge-air PI loop modulates the electric reheat stage to maintain a calculated discharge setpoint, capped at 95°F.
> 4. **Unoccupied:** Fan off; damper closed; freeze protection remains active (see Safeties).
> 5. **Reset:** SAT setpoint fixed at 55°F for this single-zone unit — no T&R applies (single-zone systems typically don't need SAT reset the way multi-zone VAV AHUs do; state this explicitly rather than leaving reset unaddressed).
> 6. **Safeties:** Freezestat trips <38°F: stops fan, closes OA damper, de-energizes reheat; manual reset at panel. Electric reheat requires airflow-proving switch ≥400 cfm before energizing.
> 7. **Alarms:** Zone temp deviation >3°F for 15 min = Minor. Freezestat trip = Critical, instant. Fan status failure >5 min = Major.
> 8. **Notes:** Vmin calculated assuming 32 occupants at 10 cfm/person + 0.12 cfm/ft² per classroom category (Section 4 table); revise if design occupancy changes.

This is the level of specificity every SOO section should reach — numeric, bounded, and free of "as needed"/"appropriate"/"periodically" without an inline definition.

## Reference Files

- **`references/g36-sequences.md`** — Read when writing or reviewing a Guideline 36 sequence in detail: full VAV terminal unit sequences (cooling-only, reheat, fan-powered, dual-duct), multi-zone VAV AHU sequence, FC1–FC15 fault rules, and alarm suppression hierarchy.
- **`references/soo-templates.md`** — Read when starting a new SOO from scratch: bracketed-placeholder skeleton templates for VAV AHU, VAV terminal (cooling-only + reheat), chilled water plant, hot water plant, DOAS, and exhaust/lab systems, each following the Section 1 mandatory structure.
- **`references/commissioning.md`** — Read when building functional test scripts, point-to-point checklists, or reviewing trend data for verification: detailed functional testing approach, trend-based verification techniques, common deficiencies organized by system type, the formal CxA process (§1.1: Standard 202/Guideline 0/1.1, OPR/BOD, design/submittal review, pre-functional checklists, FPT, seasonal/retro-Cx/MBCx), Automated Controls' internal 100% commissioning standard (§1.2), the field SOO verification workflow (§7: Logic-page checks, PID startup values, loop freeze test, lead/standby rotation test, CT status setup), and the 7-step SOO simplification technique (§8).

## Common Mistakes

- Writing "reset as needed" or "modulate to maintain comfort" instead of stating the actual setpoint, band, and reset schedule — always fix this before the sequence leaves your hands.
- Describing a safety without stating its reset method — operators need to know if a freezestat trip clears itself or requires a manual reset at the panel.
- Reusing a "typical" VAV sequence across boxes with different reheat types or airflow limits without calling out the per-box exceptions.
- Sizing VAV minimums off "30% of cooling max" instead of the calculated 62.1 Voz — a common legacy habit that under- or over-ventilates.
- Citing "Guideline 36 compliance" without confirming which edition/addenda the spec actually incorporates — options like dehumidification strategy and fan-off-during-standby are addenda-specific choices, not automatic.
- Omitting override/force-testing capability from the point list, then discovering during commissioning that a required functional test can't be performed.
- Letting non-condensing hot-water reset curves get applied to condensing boilers — verify return water temperature actually drops below ~130°F for the sequence to deliver the claimed efficiency.
- Skipping the "Notes/Assumptions" section — undocumented assumptions about unselected equipment become disputes at submittal review.
- Leaving a PID loop at its untuned default (P=20, I=5, D=0) and mistaking the resulting bang-bang 0%→100%→0% behavior for a working loop — always set startup/checkout values (P=2, I=1, D=0, 20-second interval) and verify modulation before calling a loop commissioned.
- Assuming a lead/standby (or lead/lag) system rotates on failure because the logic "looks right" on the Logic page — always run the disconnect-level failure test and confirm both the swap and the alarm.
- Sampling equipment at a 3rd-party-CxA-style 10–30% rate on Automated Controls' own scope — the internal standard is 100%, and wiring/calibration issues are expected to be resolved before any 3rd-party Cx agent arrives.
- Treating SOO simplification as optional busywork — skipping the chunk/highlight/flowchart steps on a dense submittal-length sequence is how field mismatches (Step 6) go undetected until a functional test fails.
