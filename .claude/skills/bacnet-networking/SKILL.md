---
name: bacnet-networking
description: "Design and troubleshoot BAS networks: BACnet/IP, MS/TP, ARC156, ARCnet, BACnet/SC, Rnet, and Modbus integration. Use for network architecture (segment sizing, network numbering, router/BBMD placement), addressing (MAC address, device instance), broadcast/unicast traffic, comm loss and duplicate-address troubleshooting, token-passing issues, wiring/termination faults, and WebCTRL console diagnostics (commstat, tracert, count devices). Trigger phrases: BACnet, MS/TP, ARC156, device instance, MAC address, network number, BBMD, foreign device, who-is, COV, router, broadcast storm, comm loss, token passing, duplicate address, BACnet/SC certificate. Skip when the task is EIKON program logic, sequence-of-operation authoring, or ViewBuilder graphics — use eikon-programming or webctrl-platform instead."
metadata:
  author: JeffJenkinsBAS
  version: '1.0.0'
---

# BACnet Networking

## When to Use This Skill

Use this skill when:
- Designing a new BAS network — segmenting field buses, assigning network numbers, placing routers/BBMDs, sizing IP subnets
- Assigning or auditing addresses — MAC addresses, device instances, avoiding duplicates before they cause comm loss
- Troubleshooting comm loss, "device offline," token-passing errors, or broadcast storms
- Choosing between MS/TP, ARC156, BACnet/IP, or BACnet/SC for a field segment or backbone
- Integrating third-party BACnet or Modbus devices (chillers, meters, VFDs, lighting) into a WebCTRL job
- Verifying wiring, termination/biasing, or Ethernet cabling against spec before calling a comm problem "solved"

**Skip when:** the task is EIKON control logic, ViewBuilder graphics paths, WebCTRL report building, or HVAC sequence design — those live in other skills in this pack. This skill is strictly the wire-and-packet layer: how devices find each other and talk, not what they say to each other.

## Core Principle

BACnet networking problems are almost always one of four things, in this order of likelihood: **physical layer fault → addressing conflict → routing/BBMD misconfiguration → traffic overload**. Work the decision tree top-down. Don't jump to "it's a software bug" before you've checked wiring and addresses with a meter and a rotary switch.

---

## 1. Network Architecture Design Workflow

Design top-down: backbone first, then field segments, then addressing scheme. Do this on paper (or in the network riser diagram) before touching hardware.

### Step 1 — Define the backbone
- Backbone = BACnet/IP (or BACnet/SC on security-sensitive campuses) connecting building/network controllers, servers, and workstations.
- One IP subnet per building is typical; larger campuses split by wing or floor to keep broadcast domains small.
- Every IP subnet needs a **unique BACnet network number**. Never duplicate a network number across two separate physical networks — this breaks routing and causes duplicate-path errors.

### Step 2 — Segment field buses
- Field bus (MS/TP or ARC156) segments hang off building/network controllers with routing capability (OF1628, OFBBC, G5RE, G5CE, OFHI-A, OFCSR-E2).
- Size each segment by device count and by physical run length, not just device count — see wiring table in Section 5. A segment that's electrically too long will show token-passing errors even with headroom on device count.
- Give each field segment its own **BACnet network number**, distinct from the IP backbone's network number and from every other segment in the job. Track this on the network riser — it's the single most common numbering mistake on multi-building jobs (copy-pasting a riser page and forgetting to bump the network number).

### Step 3 — Place routers and default gateways
- A BACnet router bridges two different network numbers (e.g., IP backbone ↔ MS/TP segment). Place one router per field segment; do not daisy-chain routers unless the job specifically requires multi-hop segmentation.
- **G5RE** is a dedicated router only — no control programs, used purely to bridge ARC156/MS/TP to BACnet/IP. Use it when you need routing capacity without adding integration/Modbus scope to that panel (per [OptiFlex hardware reference](/home/user/workspace/research/optiflex_hardware.md)).
- **G5CE / OFHI-A** are integrators — they route *and* run control programs *and* gateway third-party BACnet/Modbus devices. Choose these when the panel also needs to host logic or a Modbus integration (OFHI-A's 1,000-point Modbus capacity vs. G5CE's 25 points makes OFHI-A the default choice for chiller/meter/VFD-heavy integrations).
- **OFCSR-E2** is a lightweight router (Eth0/Eth1 + one Port S1 only, no Port S2, no Gig-E, no Rnet) — use for a single small field segment where a full G5RE/OFHI-A is overkill.
- Set a **default gateway** on every IP-connected controller pointing at the site's actual network router (the IT router, not the BACnet router) so the device can reach the WebCTRL server across VLANs if the architecture requires it. Confirm this with the site's IT contact before go-live — a missing or wrong default gateway is a common cause of "device pings fine locally but never reports to WebCTRL."

### Step 4 — Configure BBMDs for cross-subnet broadcasts
- BACnet/IP broadcasts (Who-Is, I-Am, etc.) do not cross IP subnet/router boundaries on their own. If controllers span multiple IP subnets separated by an IT router, each subnet needs its own **BBMD (BACnet Broadcast Management Device)**.
- **Configure exactly one BBMD per subnet.** More than one BBMD on the same subnet can create circular routing loops — this is a documented failure mode, not a theoretical one.
- For remote/roaming devices that can't run a full BBMD (e.g., a laptop workstation off-site), register them as a **Foreign Device** to an existing BBMD instead of adding a second BBMD.
- G5RE supports BBMD and Foreign Device Registration natively (B-R-TR profile, Protocol Revision 14) — confirm this is enabled during commissioning, not assumed.

### Architecture design checklist
- [ ] Every physical network (IP subnet, each MS/TP or ARC156 segment) has one unique network number
- [ ] One router per field segment, correct model for the scope (router-only vs. integrator)
- [ ] Exactly one BBMD per IP subnet that needs cross-subnet broadcast reach
- [ ] Default gateway set correctly on every IP device
- [ ] Segment lengths and device counts checked against wiring limits (Section 5) *before* pulling cable

---

## 1a. Modbus Integration Notes (Field Bus Layer)

Modbus is the shop's secondary protocol, used to integrate third-party equipment (chillers, meters, VFDs, lighting panels) that doesn't speak native BACnet. Modbus rides the same physical field-bus infrastructure decisions as BACnet, so plan it during the same network design pass, not as an afterthought.

- **Port S1** on building controllers/routers/integrators (OF1628, OFBBC, OFHI-A, G5CE) is rotary-selectable between MS/TP, ARCNET, or Modbus serial — but only **one protocol at a time** per port. A port carrying Modbus cannot simultaneously carry MS/TP or ARC156 BACnet traffic.
- **Port S2** is generally MS/TP or Modbus only (never ARCNET) and is electrically isolated on most devices — a common choice for dedicating S2 to a Modbus-only integration while S1 stays on BACnet field bus.
- Modbus TCP/IP rides the same Gig-E port as BACnet/IP on most integrators — no separate physical run needed for a TCP-based Modbus device.
- **Capacity varies significantly by model** — this determines which panel to specify for a Modbus-heavy job: OFHI-A supports up to 1,000 Modbus points vs. G5CE's 25, making OFHI-A the default choice for chiller/meter/VFD-heavy integrations. OF1628 supports 200 Modbus points, OFBBC 200, G5RE and OFCSR-E2 **none** (pure routers, no Modbus support on either port).
- Because Modbus devices don't participate in BACnet's Who-Is/I-Am discovery, they must be manually mapped point-by-point into a BACnet-visible object on the integrator — budget engineering time for this; it isn't auto-discovered the way a native BACnet device is.

---

## 2. Addressing Rules

Two independent addressing layers exist in BACnet — mixing them up is the #1 cause of "duplicate address" comm loss calls.

| Address type | Scope | Range | Notes |
|---|---|---|---|
| **MAC address** | Unique per physical segment only (can repeat on a different segment) | ARCNET (ARC156): **1–255**. MS/TP: **0–127** | Set via rotary switches or router web UI depending on device |
| **Device Instance** | Unique system-wide across the entire BACnet internetwork | 0–4,194,302 | Never reuse across buildings/segments even if they'll never route to each other today — networks get merged later |

- **MAC address collisions only matter within the same segment.** Two MS/TP devices on *different* segments can both be MAC 5 with no conflict, because MAC addresses are resolved locally by the router boundary.
- **Device instance collisions are global.** Two devices anywhere in the same BACnet internetwork sharing a device instance will cause discovery failures, ambiguous Who-Is/I-Am responses, and WebCTRL binding errors — even if they're on opposite ends of the campus.
- **Rotary-switch gotcha:** On many OptiFlex controllers, the same three rotary switches (hundreds/tens/units) set both the "Default IP" address *and* the MS/TP or ARCNET MAC address. Changing the switches after the Default IP has already been set can silently change the device's network MAC — always re-verify the applied address (not just the switch position) after any rotary change, especially on a live segment.
- **Practical numbering scheme:** Reserve a block per segment (e.g., building controller device instances in the x000 range, VAV controllers in the x100–x699 range matching room numbers where practical) so a device instance tells a technician roughly where the device lives without opening WebCTRL. Document the scheme on the network riser.
- Devices without rotary switches (OFCSR-E2) are addressed entirely through their USB Service Port web UI — including MAC address — and support MS/TP Autobaud (detects and matches an already-configured segment's baud rate; requires at least one other configured device already present).

### Example — worked addressing scheme for a 3-building job

| Building | IP Network # | Field Segment | Segment Network # | Device Instance Block | MAC Range Used |
|---|---|---|---|---|---|
| Admin (A) | 1001 | MS/TP-1 (AHU/RTU controllers) | 2001 | 1000–1099 | 1–20 |
| Admin (A) | 1001 | MS/TP-2 (VAV boxes, floor 1) | 2002 | 1100–1199 | 1–60 |
| Classroom (B) | 1002 | ARC156-1 (AHU/RTU controllers) | 3001 | 2000–2099 | 1–20 |
| Classroom (B) | 1002 | ARC156-2 (VAV boxes) | 3002 | 2100–2199 | 1–100 |
| Gym/Annex (C) | 1003 | MS/TP-1 (all field devices, small building) | 4001 | 3000–3099 | 1–30 |

Note every network number (IP or field segment) in the entire job is unique, and device instance blocks never overlap across buildings even though MAC ranges intentionally repeat (1–20, 1–30, etc.) across *different* segments — that repetition is fine because MAC scope is per-segment, not system-wide. This is the exact distinction techs get wrong under time pressure: copying a working MS/TP MAC scheme to a new segment is safe; copying device instances is not.

---

## 3. Unicast vs. Broadcast — Why It Matters

- **Unicast** = one device talking directly to one other device (e.g., a confirmed COV notification, a ReadProperty response). Efficient, scales fine.
- **Broadcast** = one message sent to every device on the segment/network (Who-Is, I-Am, unconfirmed COV, some alarm traffic). Every device must process every broadcast whether it cares or not.
- On MS/TP and ARC156, broadcasts consume token-passing bandwidth that every other device is waiting on — a segment saturated with broadcast traffic shows up as sluggish response, delayed COV, or apparent comm loss even though no single device has failed.
- **Prefer confirmed COV (Change of Value) subscriptions over polling.** Polling (repeated ReadProperty requests) generates constant unicast traffic that scales with poll frequency × point count × device count; COV only generates traffic when a value actually changes and confirms delivery. This is a standing design principle for this shop — always default to COV for graphics/trend bindings unless a specific device doesn't support it.
- Minimize router-crossing broadcasts: keep BBMD configuration correct (Section 1, step 4) so broadcasts don't loop, and don't put unrelated devices on an oversized flat segment just because there's spare wire — broadcast domains should map to logical segments, not convenience.

---

## 4. Ethernet Wiring Standards (BACnet/IP Backbone)

- Terminate all RJ45 ends to **T568B**, consistently on both ends of every run. Mixed T568A/T568B on the same cable still passes straight-through Ethernet but breaks the shop standard and creates confusion during troubleshooting — don't do it.
- Max cable length: **300 ft standard run** (consistent with the 328 ft / 100 m Cat5e Ethernet ceiling — treat 300 ft as the practical field limit with margin).
- **150 ft rule for daisy-chain/ring runs** — when Ethernet ports are being repeated/passed through device-to-device (as OptiFlex Eth0/Eth1 fail-safe repeater ports do), keep each hop to 150 ft to preserve signal margin across the chain.
- OptiFlex Ethernet ports mirror/repeat traffic between Eth0 and Eth1 even when the controller loses power — this fail-safe repeater behavior preserves the physical ring, but don't rely on it as a substitute for a properly designed backbone with real redundancy.
- Use Cat5e or higher. Verify with a cable tester after every pull — don't trust a "looks fine" continuity check on a long run.

---

## 5. MS/TP vs. ARC156 Comparison

Both protocols share the same physical wiring spec but differ in speed, defaults, and where they're used.

| Characteristic | MS/TP | ARC156 (ARCNET) |
|---|---|---|
| Baud rate | Selectable 9.6–115.2 kbps (default **76.8 kbps** unless changed) | Fixed **156 kbps** |
| MAC address range | **0–127** | **1–255** |
| Wiring | 22 AWG, low-capacitance, twisted/stranded/shielded copper | Same: 22 AWG, low-capacitance, twisted/stranded/shielded copper |
| Max segment length | **2,000 ft (610 m)** | **2,000 ft (610 m)** |
| Termination | 120-ohm at each physical end only ("End of Net?" switch) | Same termination rule |
| Access method | Token-passing, deterministic | Token-passing, deterministic |
| Typical use on ALC gear | Legacy/mixed-vendor segments, Port S2 default | ALC's default field-bus protocol on most OptiFlex controllers |
| Switching between them | Physical jumper/rotary move required on the controller — real field task, not a software toggle | Same — switching a segment from ARC156 to MS/TP (or vice versa) means touching every device's Port S1 selector |

Key field notes:
- Port S1 on building controllers/routers/integrators (OF1628, OFBBC, OFHI-A, G5CE) is rotary-selectable: **0 = unused, 1 = MS/TP, 2 = ARCNET, 3 = Modbus, 4 = reserved**. Port S2 is generally MS/TP or Modbus only — **never ARCNET** — and is electrically isolated on most devices.
- G5RE's Port S1 supports ARC156 or MS/TP; Port S2 is MS/TP only — no Modbus on either port.
- OFCSR-E2's Port S1 supports ARC156 or MS/TP only (no Modbus), with no Port S2 at all.
- **Critical hardware gotcha:** G5CE units with serial prefix **RT5** (built during the semiconductor shortage) have no ARCNET hardware at all and never will, regardless of firmware update. Units with prefix **RT6** (production resumed November 2023) have full ARCNET support. Always check the serial number before scoping an ARCNET integration on a G5CE.
- Switching a controller from the ALC default (ARC156) to MS/TP for mixed-vendor jobs requires a physical jumper move on many OptiFlex controllers — confirmed recurring field task, budget time for it on integration jobs.

---

## 6. Comm Loss Troubleshooting Decision Tree

Work top to bottom. Don't skip a layer just because it seems unlikely — most "it's definitely a software problem" calls turn out to be a loose termination or a duplicate MAC.

```
1. PHYSICAL LAYER
   ├─ Check power to the device (LED status, voltage at terminals)
   ├─ Check wiring continuity Net+/Net- (meter, not just visual)
   ├─ Check termination: only segment ENDS should have End-of-Net = Yes
   │  (exception: DIAG485 tool with Bias jumper ON → controller End-of-Net = No,
   │   wire external 120-ohm resistor instead)
   ├─ Check for damaged/pinched cable, especially at panel entries
   └─ Confirm no line voltage was ever applied to comm terminals
        → If physical layer is clean, go to 2.

2. ADDRESSING
   ├─ Check for duplicate MAC address on the segment (ARC156 1–255 / MS/TP 0–127)
   ├─ Check for duplicate Device Instance anywhere on the system (system-wide, not just segment)
   ├─ If Default-IP rotary switches were touched recently, re-verify the
   │  applied MAC/IP — switch changes can silently move a device's address
   └─ Confirm baud rate matches across all devices on the segment (MS/TP default 76.8 kbps)
        → If addressing is clean, go to 3.

3. ROUTING / BBMD
   ├─ Confirm the segment's BACnet network number is unique and correctly
   │  set on the router
   ├─ Confirm exactly one BBMD per IP subnet (extra BBMDs cause routing loops)
   ├─ Confirm foreign device registration (if used) points at the right BBMD
   └─ Confirm default gateway is correct on IP-connected controllers
        → If routing is clean, go to 4.

4. TRAFFIC / LOAD
   ├─ Check for broadcast storm symptoms (segment-wide sluggishness, not
   │  one device down)
   ├─ Check for excessive polling vs. COV — audit graphics/trend bindings
   ├─ Check device/point count against segment and controller capacity limits
   └─ Consider segment split if a single MS/TP or ARC156 bus is overloaded
```

### WebCTRL console verification path
Access via **Ctrl+M → console** in WebCTRL, then:

1. `count devices` — confirms total system size and whether the missing device is even being discovered at the network level.
2. `commstat` — reports comm health per network/segment; use this first to scope whether the problem is one device or a whole segment (a whole-segment failure points you straight to physical/routing, not a single controller).
3. `tracert` — traces the BACnet route to a specific device; use this to confirm routing/BBMD configuration is actually delivering packets to the segment the device claims to be on.
4. `help -a -h` — full command reference if you need additional diagnostics beyond these three.

Run `commstat` before opening a panel. If `commstat` shows the whole segment down, don't start pulling wire nuts on one VAV box — go straight to the router/segment power and termination.

### Field verification steps (do these, don't just theorize)
1. Pull the actual device count and expected device count for the segment — compare against `count devices`.
2. Meter Net+/Net- for correct voltage/continuity at the suspect device and at both physical ends of the segment.
3. Physically confirm End-of-Net switch position at both ends — don't trust as-built documentation, verify in the field.
4. Read the MAC address rotary switches directly off the hardware and cross-check against the network riser / WebCTRL device list.
5. If ARC156/MS/TP is suspected saturated, use a bus analyzer (see [MS/TP troubleshooting reference](references/mstp-troubleshooting.md)) to confirm token rotation time before assuming a device is dead.
6. Only after physical + addressing + routing are confirmed clean should you treat it as a load/traffic issue and consider segment splitting or moving points to COV.

---

## Reference Files

- **[references/bacnet-protocol.md](references/bacnet-protocol.md)** — Read when you need the object/service model, BIBBs, device profiles (B-BC/B-AAC/B-ASC/B-OWS), PICS review, BTL listing verification, or Who-Is/I-Am and BBMD/foreign device registration mechanics in depth.
- **[references/bacnet-sc.md](references/bacnet-sc.md)** — Read when a spec calls for BACnet Secure Connect, when scoping a cybersecurity-reviewed campus/healthcare job, or when asked about TLS certificates, hub-and-spoke topology, and current BACnet/SC support status in the ALC/OptiFlex ecosystem.
- **[references/mstp-troubleshooting.md](references/mstp-troubleshooting.md)** — Read for deep MS/TP troubleshooting: token-passing mechanics, duplicate MAC symptoms, wiring/termination/biasing faults, baud mismatches, max device counts, and capturing traffic with Wireshark/MS/TP analyzer tools.

---

## Common Mistakes

- **Duplicate device instance across buildings** — assigning device instances per-building without checking the whole campus/portfolio. Fails the moment two systems get networked together, even years later.
- **Two BBMDs on one subnet** — usually from copy-pasting a config or from a previous integrator's leftover BBMD nobody removed. Causes circular routing loops, not redundancy.
- **Confusing MAC address scope with device instance scope** — troubleshooting a "duplicate address" as if it's system-wide when it's actually just a local segment collision (or vice versa).
- **Trusting rotary switch position without re-verifying applied address** — Default-IP schemes can silently remap MAC/IP when switches are touched later for an unrelated reason.
- **Skipping the physical layer because "it worked yesterday"** — loose terminations and chafed cable don't announce themselves; always meter before assuming firmware/software.
- **Leaving End-of-Net set to Yes on more than the two physical ends of a segment** — creates reflection/noise that looks like intermittent comm loss under load.
- **Polling everything instead of using confirmed COV** — inflates unicast traffic unnecessarily and is a common root cause of "system feels slow" complaints with no obvious single failure.
- **Assuming a G5CE supports ARCNET without checking the serial prefix** — RT5 units physically cannot, regardless of configuration effort.
- **Mixing T568A and T568B terminations on the same Ethernet run** — works electrically but breaks the shop wiring standard and confuses the next technician.
