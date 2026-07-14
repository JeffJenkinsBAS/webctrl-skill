# OptiFlex Wiring & Network Reference

Deep-dive on the field-bus wiring rules referenced from the main SKILL.md. Compiled from Automated Logic Technical Instructions manuals — cross-checked against [automatedlogic.com](https://www.automatedlogic.com/).

---

## Ethernet / BACnet-IP
- Max cable length: **328 ft (100 m)** using Cat5e or higher, consistent with standard Ethernet limits.
- Eth0/Eth1 (or Gig-E) ports mirror/repeat traffic to the other port under normal operation; when a controller loses power, its Ethernet ports still pass through traffic to the other port (built-in fail-safe repeater behavior), preserving the physical ring/daisy-chain.
- If controllers span multiple IP subnets separated by a router, configure **one BBMD per subnet** — configuring more than one BBMD per subnet can create circular routing loops.

## ARC156 vs. MS/TP Wiring (Port S1 / Port S2)
- Both protocols share the same physical wiring spec: **22 AWG, low-capacitance, twisted, stranded, shielded copper wire**, max length **2000 ft (610 m)** per segment.
- ARCNET (ARC156) operates at a fixed **156 kbps**; MS/TP operates at a selectable **9.6–115.2 kbps** (default 76.8 kbps unless changed).
- Port S1 is typically the flexible port (protocol selectable via rotary switch: 0 = unused, 1 = MS/TP, 2 = ARCNET, 3 = Modbus, 4 = reserved for future use) on building controllers/routers/integrators (OF1628, OFBBC, OFHI-A, G5CE). Port S2 is generally MS/TP or Modbus only (never ARCNET), and is electrically isolated on most devices.
- MAC address ranges: **ARCNET 1–255**; **MS/TP 0–127**. When using "Default IP" addressing mode, the same three rotary switches double as the network MAC address, so changing the rotary switches after setting a Default IP can silently change your device's network address — always re-verify the applied address after any switch change.
- OFCSR-E2 differs: no rotary switches at all — addressed purely through its USB Service Port web UI, with optional MS/TP Autobaud (device detects and matches the network's existing baud rate; requires another already-configured device on the segment).
- **Legacy jumper note**: on older ALC controller generations, switching between ARCNET (the default field-bus) and MS/TP requires physically repositioning a jumper on the controller board — this is a real field task, not a software-only setting, and is a common source of confusion when integrating older ALC hardware into a mixed-protocol job. Always visually confirm jumper position when troubleshooting comm on legacy segments.

## Termination Rules (End-of-Net)
- Most Automated Logic controllers, routers, and integrators have **built-in network termination and bias** on Port S1/S2 and the I/O Bus, activated via the **"End of Net?" switch**.
- Only the device(s) at the physical **ends of a segment** should have End-of-Net set to **Yes**; all other devices on that segment must be **No**.
- Exception: if a segment end is a **DIAG485** tool with its Bias jumper in the ON position, set the controller's End-of-Net to **No** and instead wire an external **120-ohm resistor** across Net+ and Net- at that end.
- On FIO/MEx expander chains: the **host controller has built-in I/O bus termination and must be the first device** on the expander network; only the **last expander** in the chain should have its I/O Bus End-of-Net switch set to Yes — all others stay No.
- Do not change the position of a power or End-of-Net switch at temperatures **below -22°F (-30°C)** — cold can compromise the switch contact and produce unreliable settings.

## Rnet Rules
- Rnet is a daisy-chain bus for ZS sensors, Wireless Adapters, Equipment Touch, and OptiPoint interfaces; it communicates at **115.2 kbps**.
- Zone controllers (OF141/253/342/561-E2) support up to **5** ZS/wireless sensors plus 1 touch device on Rnet; one control program can use no more than 5 ZS sensors.
- Building controllers/routers/integrators with Rnet (OF1628/OF028, OF1628-NR/OF028-NR, OFBBC, OFHI-A, G5CE) support up to **15** ZS/wireless sensors plus 1 touch device.
- Rnet port power varies by device: e.g., OF141-E2/OF342-E2 supply 12 Vdc/260 mA; OF1628 supplies up to 162.5 mA (AC-powered) or 262.5 mA (DC-powered); OFBBC/OFHI-A/G5CE supply 12 Vdc/62.5 mA. **Touch devices (Equipment Touch, OptiPoint) are never powered by the Rnet port** — they always require their own external 24 V supply. Always total the connected sensors' current draw against the specific device's rated Rnet output before wiring.
- Programming workflow that consumes Rnet sensor data: Sensor Binder microblock → Analog/Binary Sensed Value Input (ASVI/BSVI) microblocks → BACnet Setpoint microblock → BACnet Time Clock microblock ([ZS Sensor Applications Guide](https://www.shareddocs.com/hvac/docs/1000/Public/0E/11-808-504-01.pdf)).
- **ZS sensor family capability reference** (from [ZS2 Pro datasheet](https://www.automatedlogic.com/en/products/webctrl-building-automation-system/sensors/zs-pro/) and [OEMCtrl ZS cutsheet](https://www.oemctrl.com/en/media/ZS2-Sensors-cutsheet-v1.0_tcm847-124218.pdf)):

| Model | Temp | Humidity | CO₂ | VOC | Motion | Display/UI |
|---|---|---|---|---|---|---|
| ZS Standard | ✓ | optional | optional | optional | — | none |
| ZS Plus | ✓ | optional | optional | optional | — | occupancy status LED, override button, setpoint adjust |
| ZS Pro | ✓ | optional | optional | optional | optional | large LCD, alarm indicator, all Plus features |
| ZS Pro-F | ✓ | optional | optional | optional | optional | adds manual fan speed + heat/cool/fan-only mode control |

- Sensing accuracy: temperature ±0.35°F (non-humidity models) or ±0.5°F (humidity models); CO₂ ±30 ppm or ±3% of reading (whichever greater) up to 1250 ppm, ±5%+30ppm above that; VOC ±100 ppm. Power draw ranges from 12Vdc@8mA (temp-only) up to 190mA during a CO₂ measurement cycle — factor this into your Rnet current budget when specifying CO₂-capable sensors.

## Act Net Rules
Applies to: zone/equipment controllers (OF141/253/342/561-E2) and OF1628/OF028 family only. **Not present** on OFBBC, OFHI-A, OFCSR-E2, G5RE, or G5CE.

- Zone controllers (OF141/253/342/561-E2): up to **5** Act Net addresses — Address 1 reserved for the built-in/Automated Logic actuator, 2–3 reserved for ZASF-A, 4–5 for OptiPoint Smart Valves. Max power: 25 VA (1A) AC supply or 15 W (0.625A) DC supply — use an external transformer if devices exceed this.
- OF1628/OF028 family: up to **16** Act Net addresses (OptiPoint Smart Valves and ALC actuators only, no ZASF-A slot reservation at this scale).
- Act Net bus max length **300 ft (91.44 m)**, wired with **18 AWG or larger** copper to avoid voltage drop below 19.2 Vac / 21.6 Vdc.
- Act Net devices require their own **Class 2 power source** and cannot be powered from the host controller's 24 Vac transformer. If that Act Net power source needs an earth ground connection, it must share the same control panel (and ground reference) as the host controller to avoid ground loops; a remote Act Net supply should float with no local earth ground connection.

## Expander Buses (FIO / MEx / OFX48 I/O Bus)
- I/O Bus supports up to **9 wired FIO expanders** on OF1628/OF028/OFBBC family controllers (plus one additional DC-powered expander via the 6-pin edge connector).
- OFBBC additionally supports the **Xnet port** for up to **6 MEx expanders** (ARC156-style wiring), but total expanders (FIO + MEx) cannot exceed **9**.
- Each FIO expander needs a unique rotary-switch address **1–9**; each MEx expander needs a unique rotary-switch address **1–6**.
- OFX48 expanders attach to the **OF683XT-E2** host controller's I/O Bus specifically (not to OF1628/OFBBC/OF561/OF253 family controllers) — do not attempt to wire an OFX48 to any other host.

## Power-Sharing Rule (applies across the OptiFlex line)
- Automated Logic controllers/expanders can share a single power transformer only if: (1) the same polarity is maintained across all devices, and (2) the supply is dedicated solely to Automated Logic controllers (no third-party loads on the same Class 2 transformer).
- Never apply line voltage (mains) to any controller, router, integrator, or expander's ports or terminals — this warning appears verbatim across every device's Technical Instructions.

## Bus-Type Quick Cross-Reference

| Bus | Purpose | Devices/Segment | Speed | Power Source |
|---|---|---|---|---|
| ARC156/MS/TP (Port S1/S2) | Field-level BACnet trunk | Per MAC range (ARCNET 1–255, MS/TP 0–127) | 156 kbps fixed (ARC156) / 9.6–115.2 kbps (MS/TP) | Not bus-powered — each device has its own supply |
| Rnet | Zone sensor bus | 5 (zone controllers) / 15 (building controllers) + 1 touch device | 115.2 kbps | Powered by host controller's Rnet port (except touch devices) |
| Act Net | Actuator/valve bus | 5 (zone controllers) / 16 (OF1628/OF028) | — | Dedicated external Class 2 supply, never host's 24 Vac |
| I/O Bus (FIO) | I/O expansion | Up to 9 FIO expanders | — | Per expander, shareable transformer allowed (same polarity, ALC-only) |
| Xnet (MEx) | I/O expansion (OFBBC only) | Up to 6 MEx expanders (9 total w/ FIO) | ARC156-style | Per expander |

---

*Compiled from Automated Logic Technical Instructions (space files) and the [ZS Sensor Applications Guide](https://www.shareddocs.com/hvac/docs/1000/Public/0E/11-808-504-01.pdf). Always verify against the current Partner Community document version before field use, particularly for wire-length derating in high-EMI environments.*
