# MS/TP Troubleshooting Reference

Deep-dive field reference for MS/TP (and shared ARC156 wiring/termination behavior) issues. Read this when the SKILL.md decision tree points to a physical-layer or token-passing problem and you need mechanics, not just the checklist.

## 1. Token-Passing Mechanics

MS/TP (Master-Slave/Token-Passing) is a deterministic-access protocol — unlike Ethernet's collision-based access, only one device can transmit at a time, and the right to transmit ("the token") is passed explicitly from device to device in ascending MAC address order.

- Each master device on the segment holds the token for a bounded window, does its work (sends its own requests, polls, responds to remote requests), then passes the token to the next-highest MAC address it knows about.
- If a device with the next-highest MAC has gone offline, the token-holder must time out waiting for a response before it tries the next known address — this timeout-and-retry behavior is why **one dead device can measurably slow the whole segment**, not just make that one device unreachable.
- **Symptom pattern:** if the whole segment feels sluggish (not just one device down), suspect a token-passing problem — a dead or intermittent device still occupying an address slot, not necessarily a wiring fault affecting every device simultaneously.
- Token rotation time scales with device count and baud rate — a segment with many devices at a low baud rate will have a visibly longer token rotation cycle, which shows up as delayed point updates even with zero actual faults.

## 2. Duplicate MAC Addresses

- MS/TP MAC address range is **0–127**. Two devices with the same MAC on the same segment will intermittently both try to hold the token, producing garbled responses, dropped packets, or a device that appears to flicker on/off in WebCTRL.
- Duplicate MAC symptoms are often mistaken for a bad device because the *lower*-numbered duplicate tends to "win" more often, making the higher-numbered duplicate look like the flaky one — check both devices' actual rotary switch positions, don't just replace the one that looks worse.
- **Fix procedure:**
  1. Physically read the MAC rotary switches on every device on the suspect segment (don't trust as-built documentation).
  2. Cross-check against the network riser / WebCTRL device list for the segment.
  3. Reassign the duplicate to an unused MAC in range.
  4. Re-verify the applied address after the change — on OptiFlex controllers using "Default IP" rotary addressing, changing switches can affect both the IP and MAC scheme simultaneously (see SKILL.md Section 2 rotary-switch gotcha).

## 3. Wiring Faults

MS/TP and ARC156 share the same physical wiring spec:
- **22 AWG, low-capacitance, twisted, stranded, shielded copper wire.**
- **Max segment length: 2,000 ft (610 m).**

Common wiring faults and their symptoms:

| Fault | Typical symptom |
|---|---|
| Reversed Net+/Net- polarity at one device | That device offline; rest of segment may be fine or degraded depending on topology |
| Pinched/damaged cable at a panel entry | Intermittent comm loss, often correlates with vibration/temperature |
| Star/tee topology instead of daisy-chain | Reflection noise, intermittent errors under load, hard to diagnose without a bus analyzer |
| Missing shield ground or shield grounded at both ends | Noise susceptibility, especially near VFDs or high-voltage runs |
| Segment exceeding 2,000 ft | Signal attenuation, especially at higher baud rates — try lowering baud before condemning the run |

Always meter Net+/Net- for continuity and check for unintended shorts to shield/ground before assuming a device-level fault.

## 4. Termination and Biasing

- Most Automated Logic controllers, routers, and integrators have **built-in network termination and bias** on Port S1/S2 and the I/O Bus, activated via the **"End of Net?" switch**.
- **Only the device(s) at the physical ends of a segment should have End-of-Net set to Yes; all other devices on that segment must be No.** Setting more than two devices to Yes on a linear segment introduces reflection and noise that presents as intermittent comm loss under load — this is a very common self-inflicted fault after a segment is extended and the old "last device" is never switched back to No. Internal standard: **"Two ends. No exceptions."**
- **Exception:** if a segment end is a **DIAG485** tool with its Bias jumper in the ON position, set the controller's End-of-Net to **No** at that point and instead wire an external **120-ohm resistor** across Net+ and Net- there.
- On FIO/MEx expander chains: the **host controller has built-in I/O bus termination and must be the first device** on the expander network; only the **last expander** in the chain should have its I/O Bus End-of-Net switch set to Yes — all others stay No.
- **Cold-weather caution:** do not change the position of a power or End-of-Net switch at temperatures **below -22°F (-30°C)** — cold can compromise the switch contact and produce an unreliable setting that looks fine visually but doesn't make contact electrically.

### Biasing — the one-bias rule
- The trunk must have **exactly one bias source**, full stop. Newer controllers have bias built in; older installs required adding a DIAG485 specifically to provide bias.
- **No bias source on the trunk** = unstable communications. **Multiple bias sources** = devices fighting each other for the idle-state voltage reference, producing the same kind of intermittent/garbled symptoms as a duplicate MAC. Internal standard: **"One trunk. One bias."**
- When troubleshooting an unstable trunk, check bias in the same pass as termination — a segment can have perfect EOL termination and still be unstable from zero or duplicate bias sources.

### Shield wiring — ARCnet & MS/TP
- The comm network is the "central nervous system" of the BAS — without a reliable link to the supervisory controller (e.g., G5CE or equivalent), the whole BAS is compromised. Treat a shield-wiring fault with the same urgency as a termination fault.
- If shielded cable is used, bond shields together **continuously** across the run, and land the shield at **one end only** — typically at the supervisory control panel. Do not land the shield on controller or signal ground. Landing the shield at every device (rather than continuity-bonding through to one ground point) can itself cause problems — check manufacturer spec before assuming "more grounding is safer."
- Ground loops from shield grounded at multiple points are a **real, documented risk**, not a theoretical one — this is one of the more common self-inflicted MS/TP/ARCnet noise sources on retrofit jobs where a previous contractor grounded both ends.
- Proper termination technique: shield wires meticulously twisted together, wrapped around the conductors, and neatly secured with electrical tape to form a compact, robust barrier against interference. **Verify continuity through testing** after installation — a visually neat shield termination can still be electrically open.

## 5. Baud Rate Mismatches

- MS/TP baud is selectable **9.6–115.2 kbps**, default **76.8 kbps** unless changed. ARC156 is fixed at **156 kbps** and is not subject to this mismatch class of fault.
- Every device on an MS/TP segment must agree on baud rate. A single device left at a different baud (e.g., after a factory reset or a replacement unit shipped at default) will fail to join the token-passing ring — it won't necessarily throw an obvious error, it will simply never appear.
- **OFCSR-E2 and some newer OptiFlex devices support MS/TP Autobaud** — the device detects and matches the segment's existing baud rate on power-up. This requires **at least one other device already configured** on the segment; autobaud cannot establish a baud rate on a segment with no reference device.
- Fix procedure: confirm the segment's intended baud rate from the network riser/commissioning docs, then verify every device (especially recently replaced or reset units) matches it explicitly rather than relying on default settings matching by coincidence.

## 6. Max Devices Per Segment

- MS/TP practical device count is governed by both the protocol's addressing range (0–127 MAC) and by real-world token rotation time — a segment can be under the MAC limit and still perform poorly if device count and polling load are too high for the baud rate in use.
- Design guidance: don't max out a segment to the addressing ceiling just because the MAC range allows it. Split a segment when token rotation time starts producing noticeable point-update lag, especially on segments carrying VAV boxes with frequent setpoint/airflow changes.
- Prefer confirmed COV over polling on segment-bound devices — this is the single biggest lever for keeping a busy MS/TP segment responsive without adding hardware (see SKILL.md Section 3).

## 7. Capturing Traffic — Wireshark and MS/TP Analyzer Tools

- MS/TP runs on RS-485 and is not natively visible to a standard Ethernet-tap Wireshark capture — you need an RS-485-to-USB/Ethernet capture adapter (e.g., an MS/TP-capable bus analyzer or a purpose-built capture device) feeding into Wireshark with the BACnet MS/TP dissector enabled.
- What to look for in a capture:
  - **Token rotation time** — how long it takes the token to cycle through all active MAC addresses; compare against expected baud-rate-driven norms.
  - **Retries/timeouts** — repeated "poll for master" frames targeting the same MAC address indicate that address is unreachable or intermittent.
  - **Duplicate MAC evidence** — two different frame sourcing patterns claiming the same MAC address.
  - **Malformed/garbled frames** — often correlates with a wiring/termination fault rather than a device-level software issue.
- For a quick field check without a full analyzer, a basic RS-485 tester or the **DIAG485** tool can confirm bias/termination and basic signal presence before escalating to a full packet capture — don't reach for Wireshark as the first troubleshooting step; use it after physical/addressing checks (SKILL.md decision tree, Sections 1–2) have already been ruled out.

## Sources

- [OptiFlex hardware wiring/network rules research](/home/user/workspace/research/optiflex_hardware.md)
- [ASHRAE Standard 135 — MS/TP characteristics](/home/user/workspace/research/ashrae_standards.md)
- [ALC/WebCTRL vendor research — ARC156/MS/TP support](/home/user/workspace/research/alc_webctrl_vendors.md)
- Internal shop standards (integration/checkout best practices, wiring restrictions, Max Info Frames formula, Wireshark capture procedure): [internal-standards.md](internal-standards.md)
