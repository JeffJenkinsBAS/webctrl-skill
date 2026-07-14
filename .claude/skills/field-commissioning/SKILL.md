---
name: field-commissioning
description: "Guides field technicians and engineers through Automated Controls' start-up and commissioning (Cx) discipline for ALC/WebCTRL BAS jobs — pre-site prep, the 5-step commissioning workflow (pre-power inspection, power-up/download, I/O channel assignment, point-to-point checkout, SOO verification/Cx), the 100% commissioning policy, redlines, and Points List Report naming. Use when the user mentions commissioning, Cx, point-to-point checkout, point-to-point testing, field connection, RNET/OptiFlex local connection, controller replacement, controller restore/recovery, LED status, panel inspection, pre-power checks, downloading a controller, checkout notes, or SOO verification. Does not cover EIKON logic authoring (see eikon-programming) or WebCTRL server/database administration (see webctrl-platform) except where directly needed for a field checkout step."
metadata:
  author: JeffJenkinsBAS
  version: '1.0.0'
---

# Field Commissioning

## When to Use This Skill

Use this skill for the field discipline of bringing a BAS job from installed hardware to a fully commissioned, verified system:

- Prepping for a site visit ("things to have on you" before touching anything)
- Walking a panel before power-up (visual inspection, jumpers, terminations)
- Powering up controllers and downloading memory/programming
- Assigning I/O channels on the I/O Points page
- Running point-to-point checkout on BI/AI/BO/AO points
- Verifying Sequence of Operations (SOO) and performing Cx on the Logic page
- Connecting to a controller in the field (RNET, OptiFlex USB/local, Wi-Fi kit, RDP to FIELDSERVER)
- Replacing or restoring/recovering an OptiFlex controller, or reading its status LEDs
- Producing checkout notes, redlines, and the Points List Report

**Skip when**: the task is building/debugging EIKON logic itself — use `eikon-programming`. Skip for WebCTRL server/database administration, backups, or migrations not tied to a specific field checkout step — use `webctrl-platform`. Skip for BACnet/MS/TP network design standards not tied to a specific controller's field checkout — use `bacnet-networking`.

## Pre-Site Checklist ("Things to Have on You")

Before doing anything on-site, confirm/have:

- Know the **Project Manager (PM)** and **Project Engineer (PE)** for the job.
- Have the controls submittal drawings and the most complete mechanical drawing set available. If either is missing, contact the PM immediately and ask them to upload the missing set.
- Introduce yourself, at minimum, to the mechanical and electrical contractor foreman/superintendent, plus the General Contractor point of contact and safety superintendent on-site.
- Have all tools needed based on early knowledge of scope:
  - Lift or ladders arranged if VAVs are on the project.
  - Hand tools, laptop, and cables for every controller type: USB kit for RNET local connection, USB 2.0 cable for OptiFlex E2 controllers.
  - Electrical tester (voltage/continuity) and Ethernet tester (cable/termination verification).
  - On the laptop: digital drawing sets, confirmed project access, and a copy of the site database installed into the correct version's webroot/systems folder.
- Confirm local WebCTRL Server RNET/Ethernet login access in the jobsite database.

**Gotcha:** If working from the customer server over building Wi-Fi/hotspot, confirm with the PE that the database load is ready for start-up before beginning.

## 100% Commissioning (Cx) Standard

Third-party Cx often samples only 10%–30% of VAVs/typical equipment. **Automated Controls' internal standard is 100%** — every piece of equipment is touched; every sensor is visually inspected and verified/calibrated.

- Every VAV box must be visually inspected: damper rotation, airflow tube connections, discharge sensor placement, valve stroke.
- **Never assume, based on discharge temperature alone, that a VAV box is controlling correctly.**
- On AHU/Chiller Plant/large equipment: verify wire labels, verify sensors, and confirm safeties are in place and operational.
- On AHUs/RTUs, priority safety checks: **High/Low Static** and **Freezestat** devices must never be locked out and must always be functional.
- Panels/documentation cleanliness is part of the same standard: covers on and tight, debris cleared, panduit clean, wiring straightened and labeled, construction notes removed and folded into redline documentation.

## The 5-Step Commissioning Workflow (Overview)

Each job moves through five sequential steps. Full procedural detail for every step lives in `references/commissioning-workflow.md`.

1. **Pre-Power Verification & Panel Inspection** — visual panel inspection, tug test, jumper/switch/address checks, unplug all I/O before power-up.
2. **Power-Up & Download Memory** — verify voltage, observe LEDs, `paramupload` before any download, download via WebCTRL, resolve failures.
3. **I/O Channel Assignment** — enter expander/channel, sensor/actuator type, min/max, and resolution for every point on the I/O Points page.
4. **Point-to-Point Verification** — test every BI/AI/BO/AO physically at the device, document checkout notes, run the Points List Report.
5. **SOO Verification / Commissioning (Cx)** — confirm programming and equipment meet the Sequence of Operations: equipment protection, reliable operation, comfort, energy efficiency.

Do not skip ahead — each step assumes the prior step's prerequisites are complete (e.g., point-to-point verification requires I/O channel assignment to already be entered).

## Checkout Documentation Standards

Every point-to-point checkout note must specify:

- Whether a temperature sensor measured off, and the calibration offset applied (state the amount).
- Whether an existing device is **IN-OP** (Inoperable).
- The verification method used (e.g., "modulated actuator to 25%, 50%, 75%, and 100%, stopping and verifying actual control at each point").
- Any defects found on existing devices/sensors.
- Anything else worth flagging to the PM that could inhibit equipment from operating as designed.

## Redlines

- Complete redlines (markups to submittal drawings for field changes) at each piece of equipment, alongside the Points List Report.
- Always aim to match the submittal drawing; document **any** deviation — devices often get wired to different inputs than shown.
- Markup the paper jobsite submittal set or a PDF pulled from ProCore, digitally — format doesn't matter, but the markup must exist somewhere.
- All markups are compiled and reviewed with the Project Engineer at project end so Engineering can update drawings for final as-built O&M closeout.

## Points List Report Naming

Run the Points List Report once point-to-point verification is complete (all points checked out, no red text/errors). Save as PDF using this naming convention:

```
POINTLIST_<SITE>_<EQUIPMENT>_<DATE>_<YOUR FIRST INITIAL AND LASTNAME>.pdf
```

Example: `POINTLIST_CUMBERLANDTRACE_WSHP215_05022023_JJENKINS`

Save in the job folder and upload to the jobsite-specific reports folder on ProCore once connectivity allows. See `references/commissioning-workflow.md` for the full Points List Report run procedure (page size, orientation, column options).

## Reference Files

- `references/commissioning-workflow.md` — full step-by-step detail for all 5 workflow steps: voltage specs, jumper/addressing checks, download procedure with task status icons and failure recovery, I/O property table, BI/AI/BO/AO point-to-point test procedures, RIB wiring, PID field-tuning values, logic-page commissioning checks, lead/standby vs. lead/lag verification. Read this when actually performing any of the 5 steps.
- `references/field-connections.md` — how to physically/remotely connect to a controller or server: RNET local connection, OptiFlex USB/local connection, TCP/IP Manager profiles, GL-SFT1200-Opal Wi-Fi kit, RDP to FIELDSERVER. Read this before attempting any local or remote connection to a controller or database.
- `references/controller-service.md` — OptiFlex controller replacement, Gen5 controller restore/recovery, legacy 9-1-1 reset, and LED quick-reference tables for OF342-E2 and G5CE. Read this when swapping a controller, recovering a bricked/corrupted one, or diagnosing status via LEDs.

## Common Mistakes

- Skipping the pre-power panel inspection because "the installer said it's fine" — the panel/wiring inspection catches wiring mismatches, mislabeling, and stray voltage before it can damage a controller.
- Leaving I/O plugged in during initial power-up — always unplug all terminals from controllers before power-up so a field wiring mishap can't damage the controller.
- Skipping `paramupload` before downloading a controller someone else already checked out — this silently overwrites and loses prior settings/checkout notes.
- Assuming a VAV box is controlling correctly from discharge temperature alone without a full visual/point-to-point check — violates the 100% Cx standard.
- Confusing **lead/standby** (one runs, one is idle backup) with **lead/lag** (both run to meet demand) — design engineers often mislabel this, and getting it wrong during Cx breaks equipment rotation logic.
- Leaving PIDs at default (P=20, I=5, D=0) instead of tuning from the field starting point (P=2, I=1, D=0) — default values behave like open/close with no real modulation.
- Forgetting that ZN/Zone Controller inputs/outputs only support 0-5V (no mA, no 0-10V) — a common miswiring source that shows red on the I/O Points page.
- Not running/saving the Points List Report with the correct naming convention before moving off a piece of equipment.
