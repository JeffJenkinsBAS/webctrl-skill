# Live GFB Debugging — Workflow & Common Bugs

## What Live GFB Gives You

EIKON's Live Graphic Function Block view shows **real-time values on every wire and inside every microblock** of a running control program, in place, with no separate debug/simulation mode required. This is consistently cited by field technicians as ALC's strongest troubleshooting advantage over competing platforms — click the **Logic** tab on any equipment and click any microblock to see live detail ([r/BuildingAutomation field confirmation](https://www.reddit.com/r/BuildingAutomation/comments/1bgkyos/automated_logic_question/)).

This file covers **bug-hunting** on an already-running program. For **first-time verification** that a new/revised program matches its Sequence of Operations (requests/run conditions, freeze test, loop monitor, VFD pressure control, lead/lag vs. lead/standby, status/CT check, temp sensor check), see the Logic-Page Commissioning Checks section in the main SKILL.md and the full checklist in `references/field-tuning-and-commissioning.md`.

## Structured Debugging Workflow

1. **Start at the symptom, not the program start.** If a valve isn't modulating, open the Logic tab and go straight to the AO microblock driving that valve — read its current commanded value first.
2. **Walk backward from the output.** Trace the wire feeding the AO back to its PID (or staging) block. Is the PID output what you'd expect given its inputs? If not, the problem is upstream of the PID — keep walking back.
3. **Check the setpoint and process variable feeding the PID.** A PID producing a "wrong" output is almost always being fed a wrong setpoint, a wrong process variable, or is mis-tuned (gain too aggressive/sluggish) — verify all three live before assuming a tuning issue.
4. **Check occupancy/schedule state if the issue is time-dependent.** ("Works fine during the day, wrong at night" almost always traces to Time Clock or occupancy arbitration logic, not the equipment-level control loop.)
5. **Check for a stuck or forced/overridden point.** EIKON shows override state on a point — a manually forced value from a prior commissioning session left in place is one of the most common "phantom bug" causes.
6. **Confirm the input is real before blaming logic.** If an AI shows a suspicious value (e.g., a temp sensor pegged at a min/max rail, or a value that never changes), suspect a wiring/sensor hardware fault before assuming the program logic is wrong.
7. **Cross-check against the graphic.** If ViewBuilder shows a different value than the Logic tab for the same point, suspect a stale/incorrect graphic path binding (see `webctrl-platform` skill's ViewBuilder path guidance) rather than a program bug.

## Simulate / Override for Testing

- Use manual override on an input (AI/BI) to test downstream logic response without waiting for real-world conditions (e.g., force a freezestat BI to simulate a trip and confirm the safety interlock actually forces the expected outputs).
- Always **document and remove** any manual override after testing — a forgotten override is itself one of the most common bugs technicians later have to debug (see below).
- When testing staging/timer logic, be aware that minimum run/off timers will delay the visible effect of a forced input — don't mistake a timer delay for "the logic isn't working."

## Common Logic Bugs & Diagnosis

| Symptom | Likely cause | Diagnosis step |
|---|---|---|
| Equipment behaves correctly during the day, wrong at night/weekends | Occupancy arbitration or Time Clock misconfigured | Trace `effective_occupancy` live; check schedule definition and any override sources feeding arbitration |
| Valve/damper hunts or oscillates | PID gain too aggressive, or no deadband between heating/cooling setpoints | Watch PID output live over a few cycles; check active heating vs. cooling setpoint gap |
| Equipment short-cycles on/off | Missing or too-short minimum run/off timers on staging logic | Check staging block for min_stage_runtime / min_off_time wiring |
| Point reads a static, never-changing value | Manual override/force left active from prior commissioning, or dead sensor | Check override/force flag on the point first, then hardware if not forced |
| Alarm never clears despite condition resolving | Alarm microblock latching logic with no reset condition wired, or reset requires manual ack that's not documented | Check the alarm block's clear/reset condition wiring |
| Graphic shows different value than live logic | Stale or incorrectly-typed ViewBuilder path (absolute where relative was needed, or vice versa) | Compare Logic tab value against the ViewBuilder path binding |
| Program hits or approaches ~700 microblock ceiling with unpredictable behavior | Program bloat, often from copy-pasted (not nested) repeated logic | Audit for dead/duplicate blocks; convert repeated patterns to custom/nested microblocks |
| ZS sensor not reporting on a 6th+ device on same program | Program-level 5-ZS-sensor limit exceeded | Split sensors across multiple control programs (Rnet bus itself supports up to 15) |
| Sensor value never updates / sensor "offline" | Rnet power budget exceeded (too many sensors drawing more mA than controller's Rnet port supplies) | Check total connected sensor current draw against controller's rated Rnet output; add external power if needed |
| Excess network/bus traffic, slow trend response, laggy graphics | Fixed-interval polling used where confirmed COV would suffice | Audit input microblocks for polling configuration; convert to COV subscription where supported |

## Live GFB + Graphics Cross-Check

When a customer reports "the graphic looks wrong" but the equipment seems to be running fine:

1. Open Live GFB on the actual control program and confirm the true live value.
2. Open the ViewBuilder graphic in edit mode and inspect the path bound to that same element.
3. If the Logic tab value is correct but the graphic is wrong, the bug is in the graphic's path binding (see `webctrl-platform` reference for absolute vs. relative path rules), not the control logic — don't spend time re-debugging logic that's already correct.

## Training Note

When training a new technician on Live GFB, have them practice tracing backward from a known-good output through 2–3 upstream blocks on a live, running (non-critical) program before they ever touch a production safety interlock — building the "walk backward from the symptom" habit is the single highest-leverage skill for fast field diagnosis on this platform.
