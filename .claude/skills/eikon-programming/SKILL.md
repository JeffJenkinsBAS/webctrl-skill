---
name: eikon-programming
description: "Guides authoring and reviewing EIKON graphical control logic for Automated Logic (ALC) BAS controllers — microblock catalog, ZN program requirements, ZS/RS sensor programming, naming conventions, field PID tuning, offset vs. calibration, Sequence of Operations (SoO) simplification, commissioning-time logic-page checks, and Live GFB debugging. Use when the user mentions EIKON, microblock, GFB, control program, ZN program, sensor binder, ASVI, BSVI, Rnet sensor, ZS sensor, time clock microblock, trend/alarm microblock, PID microblock, PID tuning, sensor offset, calibration, sequence of operations, SoO, lead/lag, lead/standby, or logic review. Covers INPUTS-LOGIC-OUTPUTS flow, reusable-logic philosophy, field tuning standards, and a logic review checklist. Does not cover WebCTRL server/database/graphics administration — see webctrl-platform for that."
metadata:
  author: JeffJenkinsBAS
  version: '1.1.0'
---

# EIKON Graphical Logic Programming

## When to Use This Skill

Use this skill when authoring, reviewing, or debugging EIKON control-program logic on an ALC controller:

- Building a new **control program** (ZN, AHU, chiller plant, etc.) from scratch
- Adding or wiring a **microblock** (AI/BI/AO/BO, setpoint, time clock, airflow, trend, alarm, PID)
- Setting up a **ZS/RS zone sensor** (Rnet, sensor binder, ASVI/BSVI)
- **Tuning a PID loop** in the field, or deciding whether a sensor needs an **offset vs. actual calibration**
- **Simplifying a written Sequence of Operations (SoO)** before programming or commissioning against it
- Running **logic-page commissioning checks** (requests/run conditions, lead/lag vs. lead/standby, status proof, loop monitor)
- Reviewing existing logic for **missing safeties, occupancy gaps, or unclear interlocks**
- Debugging a running program using **Live GFB**
- Deciding on **naming conventions** or whether logic is getting too complex

**Skip when**: the task is about the WebCTRL server, SiteBuilder database structure, BACnet discovery, custom reports, or ViewBuilder graphics — load `webctrl-platform` instead. This skill is strictly the logic layer that runs inside the controller; that skill is the server/database/graphics layer around it.

## Core Concept: INPUTS → LOGIC → OUTPUTS

Every EIKON control program is a directed graph of microblocks wired left-to-right in three conceptual stages:

```
INPUTS  →  LOGIC  →  OUTPUTS
(AI/BI,     (setpoint,   (AO/BO
sensor      PID, math,   commands)
binder)     staging,
            interlocks)
```

- **Inputs** bring real-world data into the program: physical AI/BI points, BACnet network inputs, or sensor-binder values from an Rnet sensor.
- **Logic** is everything in between: setpoint calculation (with resets/deadbands), PID loops, staging sequences, occupancy/schedule arbitration, safety interlocks, and alarm/trend evaluation.
- **Outputs** drive real-world equipment: physical AO/BO points or BACnet network outputs.

Design every program so a technician can trace a signal left to right without jumping around the canvas. If logic must branch backward or cross itself repeatedly, it's a sign the program needs to be restructured or split into a nested/reusable custom microblock.

## Microblock Catalog

| Microblock | Purpose | Typical use |
|---|---|---|
| **Analog Input (AI)** | Reads a physical analog sensor value | Zone temp, duct static, airflow, humidity |
| **Binary Input (BI)** | Reads a physical digital/contact state | Fan status, filter switch, occupancy contact |
| **Analog Output (AO)** | Drives a physical analog actuator | Valve/damper position, VFD speed signal |
| **Binary Output (BO)** | Drives a physical relay/digital output | Fan start/stop, stage enable |
| **Setpoint** | Holds an adjustable target value, often with occupied/unoccupied and reset logic | Zone temp setpoint, duct static setpoint |
| **Time Clock** | Schedule-driven occupancy state | Occupied/Unoccupied/Standby scheduling |
| **Airflow (VAV)** | VAV-specific airflow calculation/control block | CFM calculation from velocity pressure, min/max airflow limiting |
| **Trend** | Logs a value on a schedule or COV basis | Historical data for FDD, commissioning, reporting |
| **Alarm** | Evaluates a condition and raises/clears an alarm state | High/low limit, sensor failure, comm loss |
| **PID** | Proportional-Integral-Derivative control loop | Valve/damper modulation, discharge air temp control. Field starting values **P=2, I=1, D=0** (20-sec interval) — default/untuned values are **P=20, I=5, D=0** and behave like open/close, not modulation. See Field PID Tuning below. |
| **BACnet Multi-state Value Parameter/Status** | 20-state BACnet object for mode/status representation | Equipment mode (Off/Heat/Cool/Auto), fault status |
| **Sensor Binder** | Binds an Rnet sensor's values into the program | ZS/RS zone sensor integration |
| **ASVI / BSVI** | Analog/Binary Sensed Value Input — pulls a specific value off a bound sensor | Zone temp from ZS sensor, occupancy button state |

Custom/nested microblocks are supported — build a reusable template for any logic pattern used more than once (e.g., a standard staging block, a standard occupancy arbitration block) rather than re-wiring the same pattern from scratch in every program ([EIKON product brochure](https://www.oemctrl.com/en/media/EIKON_cs_prn_tcm847-124178.pdf)).

## ZN Program Requirements

Every zone (ZN) control program must include:

1. **Schedule microblock** (Time Clock) — establishes occupied/unoccupied/standby state.
2. **Sensor binder or RS sensor** — the zone temperature source; either an Rnet-bound ZS/ZS Pro sensor via Sensor Binder, or a direct RS sensor input.
3. **Setpoint logic** — occupied/unoccupied setpoints at minimum, with deadband and any active resets (e.g., demand-controlled ventilation reset, zone-priority reset).

**Hard limit: ZN programs max ~700 microblocks.** This ceiling was raised from 400 (pre-v7.0) to 700 (v7.0+) specifically to accommodate FDD logic — but it is still a real ceiling. If a ZN program is approaching it:
- Move repeated sub-patterns into custom/nested microblocks (a nested block counts far more efficiently than re-wiring the same logic inline).
- Split genuinely separate equipment (e.g., a dual-duct box with independent hot/cold logic) into separate programs rather than one oversized program.
- Remove any dead/unused microblocks left over from earlier revisions — audit before adding new logic, not after hitting the ceiling.

## ZS/RS Sensor Programming (Rnet)

Rnet is ALC's proprietary 115.2 kbps sensor bus connecting ZS/ZS Pro zone sensors, wireless sensor adapters, and Equipment Touch/OptiPoint interfaces to a controller.

**Programming workflow** (in order):

1. **Sensor Binder** microblock — establishes the Rnet binding to the physical sensor.
2. **ASVI/BSVI** microblocks — pull specific Analog/Binary Sensed Values off the bound sensor (temp, humidity, CO₂, occupancy button, etc.).
3. **BACnet Setpoint** microblock — exposes the adjustable setpoint, tied to the sensor's local setpoint dial/buttons if present.
4. **BACnet Time Clock** microblock — schedule-driven occupancy state feeding the setpoint logic.

**Network limits** — plan sensor counts around these before finalizing a job's Rnet topology:

| Limit | Value |
|---|---|
| Max sensors per Rnet network | 15 |
| Max ZS sensors per single control program | 5 |

If a job needs more than 5 ZS sensors on one Rnet trunk, split them across **multiple control programs** — a single program cannot address more than 5 ZS sensors even though the physical Rnet bus supports up to 15 ([ZS Sensor Applications Guide](https://www.shareddocs.com/hvac/docs/1000/Public/0E/11-808-504-01.pdf)).

**Power budget**: controllers typically supply 12 Vdc at ~210–260 mA across the Rnet port (varies by model — e.g., G5CE supplies 12 Vdc/62.5 mA, OF141/OF342 supply 12 Vdc/260 mA). If total connected sensor current draw exceeds the controller's Rnet port budget, an external power source is required — check sensor draw (up to 190 mA during a CO₂ measurement cycle) against the controller's rated output before wiring a fully-loaded Rnet trunk.

**UI philosophy**: keep the sensor's **Home Screen simple** (temperature, setpoint adjust, occupancy override only) and push humidity/CO₂/VOC/diagnostic detail to secondary **Info/Diagnostic screens**. This keeps the end-user experience clean while still exposing full data for technicians who dig into the info screens.

## Naming Conventions

- Name every microblock and program element for **what it does**, not its default auto-generated label — `ZN_SETPOINT_OCC` beats `Setpoint12`.
- Keep naming consistent across similar equipment (`VAV_101_AIRFLOW`, `VAV_102_AIRFLOW` — not `VAV101Air`, `Flow_102`).
- Match program names to the Geographic Tree equipment name in SiteBuilder so a technician can correlate WebCTRL navigation directly to the EIKON program without guessing.
- Name custom/nested microblocks descriptively enough that another technician can tell what's inside without opening it (`STAGING_3STAGE_DX`, not `CustomBlock1`).

## Offset vs. Calibration

A static **offset** is not the same as a **calibration**, and treating one as the other is a common field mistake. Example: a room is actually 69.6°F but the sensor shows 72.5°F. A −2.9°F offset only fixes the reading at that single moment/temperature — thermistors are nonlinear, so a fixed offset shifts the whole curve and makes every other point on the range wrong (sometimes reversing error direction as the real temperature diverges further from the offset point).

**Diagnose before adjusting:** the most common root cause of a "bad" reading is air infiltration behind the sensor (exterior walls, unsealed sheetrock, poorly insulated boxes) — not sensor failure. Pull the sensor and compare backplate temp to room temp; if they differ significantly, seal the wall penetration, add insulation, or relocate the sensor rather than offsetting around the symptom. Only apply an offset after verifying sensor type, wiring, airflow, and installation — and only as a last-resort, minor, permanent correction.

**In the I/O Points page**, the **Offset** field allows fine calibration of an analog point's present value. Use it as a true calibration correction validated against a reference instrument (temp gun within ±2°F is the standard field check) — never as a shortcut around an installation problem. See `references/field-tuning-and-commissioning.md` for the full diagnostic procedure and the CO2-sensor-specific calibration notes.

## Field PID Tuning

**Startup/checkout starting values: P=2, I=1, D=0, 20-second interval** — then tune from there for the specific loop. **Default (untuned) values are P=20, I=5, D=0**, which produce essentially open/close (0%→100%→0%) behavior with little to no real modulation; that bang-bang-like pattern is the tell-tale sign of an untuned loop. **Tune every PID in every program** before turnover — never leave a loop at default values.

Quick procedure: disable D → raise P until the output just responds to a PV change, then cut that gain 50% → enable I at a small value and double it until oscillation appears, then cut it 50% → fine-tune P/I together → test under varying load/setpoint conditions. In BAS, P and I alone are sufficient in the large majority of loops; D is rarely needed. See `references/field-tuning-and-commissioning.md` for the full step-by-step tuning procedure and fast-vs-slow process variable guidance.

## Reusable-Logic Philosophy

**"Slow is smooth, smooth is fast."** Build logic that is:

- **Scalable** — a pattern used on one VAV box should be trivially reusable on the next 40 via nested/custom microblocks, not rebuilt by hand each time.
- **Readable** — any technician (not just the original author) should be able to trace INPUTS → LOGIC → OUTPUTS without a walkthrough.
- **Serviceable** — safeties, overrides, and alarms should be easy to locate and test in the field, not buried in a tangle of crossed wires.

Avoid:
- **Overcomplicated logic** — if a sequence needs more than a few sentences to explain, it's a candidate for simplification or splitting into named sub-blocks.
- **Excess network traffic** — prefer **confirmed COV (Change of Value) subscription over polling** for any point that doesn't need constant fixed-interval sampling. Polling every point on a fast fixed interval is a common source of unnecessary MS/TP/ARC156 bus load and can degrade comms system-wide.

This is the same engineering discipline that underlies ALC's most-cited field advantage — technicians report ALC's Live Logic tab as best-in-class for troubleshooting specifically because well-built programs are easy to read live ([r/BuildingAutomation field confirmation](https://www.reddit.com/r/BuildingAutomation/comments/1bgkyos/automated_logic_question/)). Sloppy logic erodes that advantage even on ALC's own platform.

## Live GFB Debugging Workflow

EIKON's **Live Graphic Function Block (GFB)** capability allows real-time, in-place troubleshooting:

1. Open the running control program directly (no separate debug/simulation mode needed).
2. Click the **Logic** tab on the equipment — every wire and microblock shows its **current live value** in place.
3. Click into any individual microblock to see its full live detail (inputs, output, internal state/timers where applicable).
4. Trace the signal path left to right (INPUTS → LOGIC → OUTPUTS) following live values to find exactly where an expected value diverges from actual.

This live-values-on-every-wire approach is considered best-in-class among BAS platforms and does not require a separate simulator or offline tool — competitors generally require a distinct engineering-tool session to get equivalent visibility ([field confirmation, r/BuildingAutomation](https://www.reddit.com/r/BuildingAutomation/comments/1bgkyos/automated_logic_question/)).

See `references/debugging-live-logic.md` for a structured Live GFB workflow and a catalog of common logic bugs with diagnosis steps.

## Sequence of Operations (SoO) Simplification

Convoluted written SoOs slow down both programming and commissioning. Before wiring logic against a dense SoO paragraph, run it through this 7-step simplification pass:

1. **Read it once without stressing** — just grasp the equipment, general behavior, and on/off/modulate timing.
2. **Break into logical chunks** — Start-up/Initialization; Occupied vs. Unoccupied; Normal Operation; Setpoint Control; Economizer/Free Cooling; Safety/Fault Modes; Shutdown.
3. **Highlight Inputs, Outputs, Conditions.** Example: *"The supply fan shall operate when the system schedule is occupied and the mixed air temperature is below 80°F and the fire alarm is not active"* → *"Fan ON if: Schedule = Occupied; Mixed air temp < 80°F; Fire alarm NOT active."*
4. **Create a flowchart/step list** of the decision sequence.
5. **Cross out fluff/fancy wording** — reword in plain language (e.g., "utilize integrated economizer logic based on differential enthalpy" → "use free cooling if outside air is cooler and dryer than return air").
6. **Match what you read to what you see** — walk the system, verify sensors/safeties/sequences match the graphics/field, flag mismatches to the PM and PE.
7. **Write a 1-page "Tech Summary"** in your own words for startup/troubleshooting reference and to share with other technicians or the building operator.

Always ask the Project Engineer to walk through the intended logic before programming — SoOs are open to interpretation, and the as-programmed behavior may legitimately differ from a literal reading. See `references/field-tuning-and-commissioning.md` for the full method with worked examples and a sample Tech Summary.

## Logic-Page Commissioning Checks

When verifying that a program matches its SoO during commissioning (Cx Step 5 in the `field-commissioning` skill), watch the live **Logic** tab for these specific things — this is the first-time-verification companion to Live GFB bug-hunting above:

- **Requests and Run Conditions** — confirm request/total/min-max blocks correctly pull values from "children" modules (see Source Trees in `webctrl-platform`); the **Run Cmnd BV microblock** should show ON only when conditions are actually met.
- **Freeze protection test** — with the system not running, lock the outside air temp (true point) to **30°F** to force pumps into freeze protection mode; this is a standard technique for testing any OA-temp-dependent logic on demand.
- **Loop Monitor** — verify loop supply and return temps read correctly and threshold/alarm blocks have correct trigger values.
- **VFD Pressure Control** — verify DP reading accuracy and PID function using the field tuning standard above.
- **Lead/Lag vs. Lead/Standby** — verify which one is actually implemented; design engineers frequently mislabel a lead/standby design as "lead/lag." Test failure/rotation by placing logic in AUTO, killing the lead unit at the disconnect, and confirming the standby/lag unit takes over with an alarm generated.
- **Status proof** — confirm CT wiring/assignment, lock the output to force a run condition, and verify the "True if > Constant" status threshold is set just below the actual running amperage.
- **Temperature sensors** — most are **10K ohm @ 77°F thermistor**; verify sensor labels match actual function (a point labeled "Supply Temp" should actually read supply temp).

See `references/field-tuning-and-commissioning.md` for the complete checklist with test procedures for each item.

## Logic Review Checklist

Before signing off on any control program (new build or revision), check for:

- [ ] **Missing safeties** — freeze protection, high/low limit alarms, low-limit discharge air cutout, smoke/fire interlock passthrough where applicable.
- [ ] **Occupancy gaps** — does every mode (Occupied/Unoccupied/Standby/Override) have defined setpoint and equipment behavior? Is there a defined fallback if the Time Clock or schedule source fails?
- [ ] **Alarm gaps** — sensor failure/out-of-range detection, comm-loss detection, and a defined alarm for any safety condition, not just comfort conditions.
- [ ] **Unclear interlocks** — can a technician tell, by inspection, what conditions enable/disable each output? Rename/relabel any interlock logic that isn't self-evident.
- [ ] **ZN microblock count** — confirm the program is comfortably under the ~700 ceiling, with headroom for future FDD additions.
- [ ] **ZS sensor count** — confirm no single program addresses more than 5 ZS sensors.
- [ ] **Polling vs. COV** — flag any point using fixed-interval polling that could be converted to confirmed COV.
- [ ] **Naming** — every microblock/program name should be descriptive and match the Geographic Tree equipment name.
- [ ] **PID tuning** — every PID loop moved off the P=20/I=5/D=0 default and tuned toward/from the P=2/I=1/D=0 field starting point; no loop showing open/close (0%→100%→0%) bang-bang behavior.
- [ ] **Offset misuse** — no analog point offset was applied as a substitute for diagnosing an installation/airflow problem; offsets are validated against a reference instrument (±2°F for temp).
- [ ] **Lead/Lag vs. Lead/Standby labeling** — confirm which is actually implemented and that it matches what's documented; verify failure/rotation was tested, not just configured.
- [ ] **Locked values and temporary parameter changes** — check the Locked Values report, and manually confirm every delay timer/parameter changed for testing has been reverted (no report catches these).

## Common Mistakes

- Wiring logic that jumps backward/crosses itself repeatedly instead of following a clean INPUTS → LOGIC → OUTPUTS flow — makes Live GFB tracing much harder.
- Rebuilding the same staging/occupancy pattern by hand on every piece of equipment instead of using a custom/nested microblock.
- Letting a ZN program creep toward the ~700 microblock ceiling without auditing for dead blocks or extractable custom logic first.
- Assigning more than 5 ZS sensors to a single control program (must split across programs; the 15-per-Rnet limit is a bus limit, not a per-program limit).
- Ignoring the Rnet power budget when adding sensors — assuming every controller supplies the same mA rating; always check the specific model.
- Fixed-interval polling on points that don't need it — increases bus traffic and can degrade comms for the whole trunk.
- Leaving default/auto-generated microblock names in place — makes both Live GFB debugging and future revisions slower for the next technician.
- Missing safety logic (freeze, high-limit, comm-loss alarm) because the happy-path sequence was built first and safeties were never added afterward.
- Overloading a ZS sensor's Home Screen with every available data point instead of keeping it simple and pushing detail to Info/Diagnostic screens.
- **Applying a sensor offset instead of diagnosing the root cause** (typically air infiltration behind the sensor) — masks the real problem and drifts further wrong as conditions change.
- **Leaving a PID loop at the P=20/I=5/D=0 default** — produces open/close behavior mistaken for a "working" loop; always tune from the P=2/I=1/D=0 field starting point.
- **Programming directly from a dense written SoO without simplifying it first** — leads to misread conditions; run the 7-step simplification pass and confirm intent with the PE before wiring logic.
- **Mislabeling a lead/standby design as "lead/lag"** (or vice versa) and never testing failure/rotation — the equipment may not actually swap over when the lead unit fails.
- **Forgetting to revert a locked value or temporary delay/parameter change** used during commissioning testing — there is no report that catches forgotten delay/parameter changes (only a Locked Values report for locks).

## Reference Files

- `references/microblock-patterns.md` — common logic patterns as pseudo-logic: occupancy arbitration, setpoint with deadbands, staging, resets, safety interlocks. Read this when building a new sequence and want a proven pattern rather than designing from scratch.
- `references/debugging-live-logic.md` — structured Live GFB workflow, simulate/override techniques, and a catalog of common logic bugs with diagnosis steps. Read this when troubleshooting a running program or training a technician on Live GFB.
- `references/field-tuning-and-commissioning.md` — full offset-vs-calibration diagnostic procedure, the complete PID field tuning standard and step-by-step tuning procedure, the 7-step SoO simplification method with worked examples, and the full logic-page commissioning checklist (run conditions, freeze test, loop monitor, VFD pressure control, lead/lag vs. lead/standby test procedure, status/CT check, temperature sensor check). Read this before field tuning, before simplifying an SoO, or before running commissioning-time logic checks.
