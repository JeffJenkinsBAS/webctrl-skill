---
name: alc-hardware
description: "Selecting, wiring, addressing, and troubleshooting Automated Logic (ALC) OptiFlex controller hardware for WebCTRL/EIKON systems. Use when the user mentions OptiFlex, OF141, OF253, OF342, OF561, OF1628, OF028, OFBBC, OFX48, OFHI-A, OFCSR-E2, G5RE, G5CE, BASRT-B, controller/point-count selection, I/O count, ARC156 or MS/TP wiring, Rnet, Act Net, FIO/MEx expanders, rotary switch addressing, End-of-Net termination, UUKL/UL864 smoke-control listing, ZS sensor Rnet tags, freezestat/low-limit-switch installation, Belimo actuator model decoding, VAV box setup/airflow config, or terminal-strip wire-color standards. Covers picking the right controller for a point count, wiring field buses correctly, setting rotary-switch addresses, G5CE setup, and diagnosing comm faults. Does not cover EIKON program logic authoring, WebCTRL server administration, ViewBuilder graphics, or controller LED-code tables/firmware recovery (see field-commissioning) — those are separate concerns."
metadata:
  author: JeffJenkinsBAS
  version: '1.1.0'
---

# ALC OptiFlex Hardware Selection & Wiring

## When to Use This Skill

Use this skill when:
- Picking a controller for a VAV box, AHU, or building-level application based on point count
- Wiring or troubleshooting ARC156/MS/TP field buses, Rnet sensor buses, Act Net actuator buses, or FIO/MEx expander buses
- Setting rotary-switch MAC/IP addresses on OptiFlex hardware
- Diagnosing LED codes, comm faults, or "device not detected" issues in the field
- Confirming UUKL/UL864 smoke-control listing status for a part number
- Answering "which controller do I need for X points" or "how do I wire/terminate this bus" questions

**Skip this skill when**: the question is about EIKON logic/microblock programming, WebCTRL server setup, ViewBuilder graphics, or BACnet network design at the IP/BBMD level — those live in other parts of the WebCTRL platform, not OptiFlex hardware itself.

---

## 1. Device Selection Workflow (Point Count → Controller Pick)

**Step 1 — Count your physical I/O.** Tally universal inputs (UI) and outputs (BO/AO/UO) required by the mechanical schedule for the piece of equipment. Don't count Rnet sensors or Act Net actuators here — those ride on separate buses, not the I/O count.

**Step 2 — Match against the zone/equipment controller table.** These are self-contained zone controllers with built-in I/O — no expanders:

| Need | Pick | Why |
|---|---|---|
| Simple VAV box, 4 UI / 1 BO / 1 AO, built-in actuator | **OF141-E2** | Smallest VAV controller, built-in Belimo actuator + airflow sensor |
| VAV box needing 3 binary outputs (e.g., reheat stages) | **OF342-E2** | Same footprint as OF141 but 3 BO instead of 1 |
| Fan coil / small AHU, needs Modbus serial bridge | **OF253T-E2** | Only "253" with Port S1 (Modbus serial + Modbus TCP) |
| IP-only VAV/equipment app, no Modbus needed, wants built-in airflow sensor | **OF253A-E2** | Same I/O as OF253T but Ethernet-only, no Port S1 |
| Larger equipment (RTU, MAU), needs 6 UI / 5 BO across 2 banks | **OF561-E2** | Largest single-box equipment controller in the zone family |

**Step 3 — If point count exceeds ~28 UI or needs building-level routing, go up to a building controller:**

| Need | Pick | Why |
|---|---|---|
| Central AHU/plant, up to 28 UI + 16 UO, needs to route BACnet between IP/ARC156/MS/TP/Modbus | **OF1628** | Full I/O + routing; supports 9 FIO expanders for growth |
| Same as above, no built-in UO needed | **OF028** | Input-only variant of OF1628 |
| Same I/O need, but router function not required (single BACnet type on Port S1 at a time) | **OF1628-NR / OF028-NR** | Cheaper when you don't need cross-protocol routing |
| Large plant needing >28 points, all I/O via expanders, needs both FIO and MEx (ARC156) expansion | **OFBBC** | Zero built-in I/O — pure "brain" for 9 FIO and/or 6 MEx (9 max combined) |

**Step 4 — If no I/O at all is needed (pure network bridge or third-party integration):**

| Need | Pick | Why |
|---|---|---|
| Bridge ARC156/MS/TP field bus to BACnet/IP, no control programs, no Modbus | **G5RE** | Pure router, cheapest no-I/O option, no Rnet |
| Same bridging need, plus control programs and/or Modbus/Rnet | **G5CE** | Integrator — runs 999 programs, has Rnet, but only 25 Modbus points |
| Same as G5CE but heavy Modbus integration (chillers, meters, VFDs) | **OFHI-A** | 1,000 Modbus points vs. G5CE's 25 — 40x capacity |
| Lightweight Ethernet-to-ARC156/MS/TP segment router, no Rnet/Gig-E/Port S2 needed | **OFCSR-E2** | Smallest/cheapest router; USB-only setup, no rotary switches |
| Need more I/O on an existing OF683XT-E2 equipment controller | **OFX48** | 8 UI / 4 UO expander — I/O Bus only, host must be OF683XT-E2 (not OF1628/OFBBC/zone family) |

**Rule of thumb**: If it needs its own control program and local I/O, it's a controller (OF1xx/OF2xx/OF3xx/OF5xx or OF1628/OFBBC family). If it just needs to bridge networks with no local I/O, it's a router (G5RE, OFCSR-E2) or integrator (G5CE, OFHI-A) depending on whether you need Modbus/Rnet/control programs.

---

## 2. Summary Comparison Table

| Part No. | Role | I/O (built-in) | Comm Ports | Power |
|---|---|---|---|---|
| **OF141-E2** | Zone controller (Advanced VAV) | 4 UI, 1 BO, 1 AO + built-in actuator/airflow sensor | Eth0/Eth1, Rnet, Act Net, 2× USB | 24 Vac 50 VA / 24 Vdc 18 W |
| **OF253T-E2** | Zone/equipment controller | 5 UI, 2 BO, 2 AO, 1 Universal Output (DIP) | Eth0/Eth1, S1 (Modbus serial), Rnet, Act Net, USB | 24 Vac 55 VA / 24 Vdc 20 W |
| **OF253A-E2** | Zone controller (IP VAV) | 5 UI, 2 BO, 2 AO, 1 Universal Output; built-in airflow sensor | Eth0/Eth1, Rnet, Act Net, USB (no Modbus) | 24 Vac 55 VA / 24 Vdc 20 W |
| **OF342-E2** | Zone controller (Advanced VAV) | 4 UI, 3 BO, 2 AO + built-in actuator/airflow sensor | Eth0/Eth1, Rnet, Act Net, USB | 24 Vac 50 VA / 24 Vdc 18 W |
| **OF561-E2** | Zone/equipment controller | 6 UI, 5 BO (2 banks), 1 Universal Output | Eth0/Eth1, Rnet, Act Net, USB | 24 Vac 55 VA / 24 Vdc 20 W |
| **OF1628 / OF028** | Building controller (routing) | 28 UI, 16 UO (OF1628); 0 UO (OF028) | Gig-E, S1 (ARC156/MSTP/Modbus), S2 (MSTP/Modbus), Rnet, Act Net, I/O Bus, USB | 24 Vac 100 VA / 24 Vdc 48 W |
| **OF1628-NR / OF028-NR** | Building controller (non-routing) | Same I/O as above | Gig-E, S1 (one protocol at a time), S2 (Modbus only), Rnet, Act Net, I/O Bus, USB | 24 Vac 100 VA / 24 Vdc 48 W |
| **OFBBC** | Building controller (expander-based) | 0 built-in — up to 9 FIO and/or 6 MEx (9 max combined) | Gig-E, S1, S2, Rnet, I/O Bus, Xnet (MEx), USB | 24 Vac 50 VA / 26 Vdc 15 W |
| **OFX48** | I/O Expander (OF683XT-E2 host only) | 8 UI, 4 UO | I/O Bus only | 24 Vac 50 VA / 26 Vdc 12 W |
| **OFHI-A** | Integrator (router, no I/O) | None | Gig-E, S1, S2, Rnet, USB | 24 Vac 50 VA / 26 Vdc 15 W |
| **OFCSR-E2** | Compact Segment Router | None | Eth0/Eth1, S1 (ARC156/MSTP only), USB | 24 Vac 50 VA / 24 Vdc 18 W |
| **G5RE** | BACnet Router | None | Gig-E, S1 (ARC156/MSTP), S2 (MSTP only), USB | 24 Vac 50 VA / 26 Vdc 15 W |
| **G5CE** | BACnet Integrator | None | Gig-E, S1, S2, Rnet, USB | 24 Vac 50 VA / 26 Vdc 15 W |

Sources: [OF141-E2](https://www.automatedlogic.com), [OF253T/A-E2](https://www.automatedlogic.com), [OF342-E2](https://www.automatedlogic.com), [OF561-E2](https://www.automatedlogic.com), [OF1628/OF028 family](https://www.automatedlogic.com), [OFBBC](https://www.automatedlogic.com), [OFX48](https://www.automatedlogic.com), [OFHI-A](https://www.automatedlogic.com), [OFCSR-E2](https://www.automatedlogic.com), [G5RE](https://www.automatedlogic.com), [G5CE](https://www.automatedlogic.com) — Automated Logic Technical Instructions.

Full per-device specs (memory, exact accuracy, third-party point limits, LED codes): see `references/device-details.md`.

---

## 3. Addressing Rules — Quick Reference

- **Rotary-switch devices** (OF1628/OF028, OF1628-NR/OF028-NR, OFBBC, OFHI-A, G5CE, G5RE): 3 rotary switches (hundreds/tens/units) set the Default IP address AND double as the MS/TP/ARCNET MAC address. **Changing the switches after setting a Default IP silently changes the network address** — always re-verify the applied address after any switch change.
- **Port S1 protocol-select rotary switch** (on devices that have it — OF1628, OFBBC, OFHI-A, G5CE): 0 = unused, 1 = MS/TP, 2 = ARCNET, 3 = Modbus, 4 = reserved for future use.
- **No rotary switches at all**: OF141-E2, OF253T/A-E2, OF342-E2, OF561-E2 (zone family — addressed entirely via USB Comm/Service port + controller setup pages / Local Devices table) and **OFCSR-E2** (addressed purely via USB Service Port web UI; supports MS/TP Autobaud if another configured device is already on the segment).
- **MAC address ranges**: ARCNET 1–255; MS/TP 0–127.
- **Universal Output mode** (OF253T/A-E2, OF561-E2): set via on-board DIP switch — Analog (0–10 Vdc or 12 Vdc PWM) or Binary (relay) — not a network address, but commonly confused with one in the field.
- **Expander addressing**: each FIO expander gets a unique rotary-switch address **1–9**; each MEx expander gets a unique rotary-switch address **1–6**. Total FIO + MEx on one OFBBC/OF1628/OF028 cannot exceed **9**.

---

## 4. Wiring Rules — Quick Reference

| Bus | Wire Spec | Max Length | Speed | Notes |
|---|---|---|---|---|
| Ethernet/BACnet-IP | Cat5e+ | 328 ft (100 m) | 10/100/1000 | Ports repeat traffic even if device loses power (fail-safe passthrough) |
| ARC156 (ARCNET) | 22 AWG shielded twisted pair | 2000 ft (610 m) | Fixed 156 kbps | Shares physical spec with MS/TP |
| MS/TP | 22 AWG shielded twisted pair | 2000 ft (610 m) | 9.6–115.2 kbps (default 76.8k) | Selectable baud; must match across segment |
| Rnet | (sensor cable, per device) | — | 115.2 kbps | Max 5 sensors (zone controllers) / 15 sensors (building controllers) + 1 touch device |
| Act Net | 18 AWG+ copper | 300 ft (91.44 m) | — | Needs its own Class 2 supply; never off host 24 Vac transformer |
| I/O Bus (FIO) | — | — | — | Host controller has built-in termination, must be first device; last FIO gets End-of-Net = Yes |
| Xnet (MEx) | 22 AWG shielded twisted pair (ARC156-style) | — | — | OFBBC only |

**Termination (End-of-Net)**: Only the device(s) at the physical ends of a segment get End-of-Net = **Yes**; everyone else = **No**. Exception: if the segment end is a DIAG485 tool with Bias jumper ON, set the controller's End-of-Net to **No** and add an external 120-ohm resistor across Net+/Net- instead.

**Cold-weather caution**: never change a power or End-of-Net switch position below **-22°F (-30°C)** — cold can produce an unreliable contact.

**Power sharing**: ALC controllers/expanders may share one transformer only if (1) polarity is consistent across all devices and (2) the supply is dedicated solely to ALC equipment — no third-party loads on the same Class 2 transformer. **Never apply line voltage to any port/terminal.**

Full wiring/network deep-dive (ARC156 vs MS/TP details, Rnet/Act Net capacity math, expander bus rules, BBMD subnet guidance): see `references/wiring-and-networks.md`.

---

## 5. UUKL-Listed (UL864 10th Edition) Product List

Confirmed UUKL-compliant for fire/life-safety-adjacent smoke control integrations: **OFHI-A, OFBBC, OF1628, FIO812U, FIO012U, OF342-E2, OF253A-E2, ZN341A, OF683T-E2, SE6166, REP485.**

Notable: **OF253T-E2 is NOT on this list** — if a smoke control job requires UUKL listing and also needs Modbus serial, escalate the conflict; OF253A-E2 (IP-only) is the listed part, OF253T-E2 (with Modbus) is not.

Source: internal "These products are now UUKL" product notice, cross-referenced in [optiflex_hardware.md research](https://www.automatedlogic.com/).

---

## 6. Common Field Gotchas

- **G5CE RT5 ARCNET gap**: Units shipped during the global chip shortage with serial prefix **RT5** physically lack ARCNET hardware — no firmware update will ever add it. Units with prefix **RT6** (production resumed November 2023) have full ARCNET support. **Always check the serial number prefix before scoping an ARCNET integration on a G5CE.**
- **OF1628 vs. OF1628-NR**: The plain OF1628 can route BACnet between Gig-E, Port S1, and Port S2 simultaneously (e.g., ARCNET field bus to BACnet/IP while also running Modbus on S2). The **-NR (non-routing)** variant can only have **one BACnet protocol active on Port S1 at a time** and does not route between ports — cheaper, but don't spec it where cross-protocol routing is required.
- **OF253T-E2 vs. OF253A-E2**: Only the **-T** variant has Port S1 (Modbus serial + Modbus TCP/IP simultaneously with BACnet). The **-A** variant is Ethernet-only (BACnet/IP, BACnet/Ethernet) with a built-in airflow sensor and is the UUKL-listed part. If you need Modbus bridging, you must use -T; if you need UUKL listing, you must use -A. They cannot cover both requirements in one part.
- **Rnet touch devices are never bus-powered**: Equipment Touch and OptiPoint interfaces are NOT powered by the Rnet port on any controller — they always need their own external 24 V supply. Total up ZS/wireless sensor current draw against the specific controller's rated Rnet output (e.g., OF141-E2/OF342-E2 = 12 Vdc/260 mA; OFBBC/OFHI-A/G5CE = 12 Vdc/62.5 mA) before wiring more sensors.
- **Act Net address reservations on zone controllers**: Address 1 is reserved for the built-in/ALC actuator, 2–3 for ZASF-A, 4–5 for OptiPoint Smart Valves. Don't assign these out of order.
- **Act Net has no ground-loop tolerance**: if the Act Net power source needs an earth ground, it must share the same panel/ground reference as the host controller. A remote Act Net supply should float with no local earth ground.
- **OFCSR-E2 setup access**: You cannot configure it by plugging into Eth0/Eth1 — setup is only via the dedicated USB Service Port. Also, its wireless service adapter (USB-W) is **5 GHz only** — 2.4 GHz will not connect.
- **LED codes** (zone family, e.g. OF141/OF342): Net LED blue = MS/TP/ARCNET error; blue 2-blink = duplicate MAC address; blue 3-blink = no other devices detected; Sys LED magenta = firmware update in progress — **do not power off** during this. OFCSR-E2's own code: red 2-blink on Net LED = current default IP doesn't match current settings — cycle power after fixing on the Ports tab. **Full LED quick-reference tables (OF342-E2, G5CE) and firmware-recovery/9-1-1 procedures live in the field-commissioning skill** — cross-reference by skill name only.
- **Wait before power-cycling after a parameter change**: changes commit to flash every 90 seconds; wait at least 30 seconds after a change before cutting power or the change is lost.
- **PROT485 surge protectors**: required at every point EIA-485 (Port S1/S2) wiring enters or exits a building.
- **OFBBC has no Act Net port** — don't spec OptiPoint Smart Valves on an OFBBC-only job; use a zone controller or OF1628/OF028 instead.

---

## 7. Troubleshooting Decision Guide

Work through these in order before opening a panel:

1. **Device not showing up in WebCTRL/Local Devices table?**
   - Confirm rotary-switch address is unique on the segment (duplicate MAC = blue 2-blink on Net LED).
   - Confirm Port S1 protocol-select switch matches what the rest of the segment is running (e.g., don't leave it at "2=ARCNET" if the rest of the job is MS/TP).
   - Confirm End-of-Net is set correctly at both physical ends of the segment, and nowhere else.
   - For BACnet/IP visibility from a third-party front end, confirm the point/device is flagged "network visible" — this is opt-in, not automatic.

2. **Comm errors / dropouts on ARC156 or MS/TP?**
   - Verify wire spec: 22 AWG shielded twisted pair, under 2000 ft for the segment.
   - Verify baud rate matches across every device on an MS/TP segment (no auto-negotiation except OFCSR-E2's Autobaud, which still needs one already-configured device present).
   - Check for a missing or extra termination resistor — un-terminated segments show intermittent errors under load; double-terminated segments show constant CRC errors.
   - Check for a DIAG485 left inline with its Bias jumper ON — this requires the adjacent controller's End-of-Net to be No plus an external 120-ohm resistor, not the switch.

3. **Rnet sensor not responding / showing stale values?**
   - Confirm total connected sensor current draw against the controller's rated Rnet output (12 Vdc at 62.5–260 mA depending on device — see comparison table).
   - Confirm you haven't exceeded 5 ZS sensors on a zone controller or 15 on a building controller/router/integrator, and that no single control program is asking for more than 5 ZS sensors.
   - Confirm Equipment Touch/OptiPoint has its own external 24 V supply — it will never come up on Rnet power alone.

4. **Act Net actuator/valve not responding?**
   - Confirm voltage at the far end is not sagging below 19.2 Vac/21.6 Vdc — re-check wire gauge (18 AWG minimum) and run length (300 ft max).
   - Confirm the Act Net supply is dedicated Class 2 and not sharing the host controller's transformer.
   - Confirm address isn't colliding with a reserved slot (1 = built-in actuator, 2–3 = ZASF-A, 4–5 = OptiPoint on zone controllers).

5. **FIO/MEx expander not detected?**
   - Confirm the host controller is physically first in the chain (it has the only built-in termination) and only the last expander has End-of-Net = Yes.
   - Confirm the expander's rotary address is unique (FIO: 1–9, MEx: 1–6) and that total expanders on one host don't exceed 9 combined.
   - Check fuses — expander power and I/O bus edge-connector fuses are different ratings and not interchangeable (e.g., OF1628-NR: 2.5A controller / 4A edge connector).

6. **Suspected firmware/flash issue?**
   - Never power off during a Sys LED magenta (firmware update in progress) state.
   - Wait at least 30 seconds after any parameter change before cutting power (flash commits every 90 seconds).
   - Use the USB recovery port procedure per the device's Technical Instructions if it's unresponsive after a failed update.

## Reference Files

- **references/device-details.md** — Full per-device specs (I/O detail, memory, third-party point limits, addressing detail, complete field-gotcha lists) for all 13 OptiFlex parts covered here. Read when you need exact numbers beyond the summary table (e.g., exact accuracy specs, fuse ratings, exact BACnet object ceilings).
- **references/wiring-and-networks.md** — Deep-dive on ARC156 vs. MS/TP electrical specs, End-of-Net/termination rules with exceptions, Rnet and Act Net capacity/power math, FIO/MEx expander bus rules, and BBMD/subnet guidance. Read when doing actual field wiring, bus troubleshooting, or capacity planning.
- **references/internal-standards.md** — Shop-internal setup procedures and field reference data: full G5CE setup walkthrough (Service Port access, Ports/Devices tab config, download procedure, 9-1-1 reset overview), ZS sensor Rnet tag and path-formatting cheat sheet, freezestat/low-limit-switch mounting and verification best practices, the Belimo actuator model-code decoder, VAV box setup and airflow-config procedure (incl. damper stroke times and inlet-size CFM table), BASRT-B BACnet room-router setup, and terminal-strip wire-color standards (heat pump/furnace). Read when setting up a G5CE, decoding a Belimo actuator label, wiring a freezestat, configuring VAV airflow, or setting up a BASRT-B. LED quick-reference tables and firmware-recovery procedures are intentionally excluded here — see field-commissioning.
