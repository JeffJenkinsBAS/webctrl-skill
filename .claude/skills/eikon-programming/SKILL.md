---
name: eikon-programming
description: "Guides authoring and reviewing EIKON graphical control logic for Automated Logic (ALC) BAS controllers — microblock catalog, ZN program requirements, ZS/RS sensor programming, naming conventions, and Live GFB debugging. Use when the user mentions EIKON, microblock, GFB, control program, ZN program, sensor binder, ASVI, BSVI, Rnet sensor, ZS sensor, time clock microblock, trend/alarm microblock, PID microblock, or logic review. Covers INPUTS-LOGIC-OUTPUTS flow, reusable-logic philosophy, and a logic review checklist. Does not cover WebCTRL server/database/graphics administration — see webctrl-platform for that."
metadata:
  author: JeffJenkinsBAS
  version: '1.0.0'
---

# EIKON Graphical Logic Programming

## When to Use This Skill

Use this skill when authoring, reviewing, or debugging EIKON control-program logic on an ALC controller:

- Building a new **control program** (ZN, AHU, chiller plant, etc.) from scratch
- Adding or wiring a **microblock** (AI/BI/AO/BO, setpoint, time clock, airflow, trend, alarm, PID)
- Setting up a **ZS/RS zone sensor** (Rnet, sensor binder, ASVI/BSVI)
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
| **PID** | Proportional-Integral-Derivative control loop | Valve/damper modulation, discharge air temp control |
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

## Reference Files

- `references/microblock-patterns.md` — common logic patterns as pseudo-logic: occupancy arbitration, setpoint with deadbands, staging, resets, safety interlocks. Read this when building a new sequence and want a proven pattern rather than designing from scratch.
- `references/debugging-live-logic.md` — structured Live GFB workflow, simulate/override techniques, and a catalog of common logic bugs with diagnosis steps. Read this when troubleshooting a running program or training a technician on Live GFB.
