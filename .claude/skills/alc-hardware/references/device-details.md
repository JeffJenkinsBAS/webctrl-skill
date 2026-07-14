# OptiFlex Device Details — Full Per-Device Reference

Technician-ready reference compiled from Automated Logic Technical Instructions PDFs (OptiFlex Controller series, BACnet Building Controllers, Routers, and Integrators), cross-checked against [automatedlogic.com](https://www.automatedlogic.com/). No specs were invented — where a document did not state a value, it is marked "not specified in source."

> Note: OFX48 I/O Expander's host is the **OF683XT-E2** Advanced Equipment Controller (not itself one of the primary target devices). It does not attach to the zone controllers (OF141/253/342/561) or building controllers (OF1628/OFBBC) covered elsewhere in this guide — those use **FIO** and **MEx** expanders instead.

---

## OF141-E2 — Advanced VAV Controller (Zone Controller)
- **I/O:** 4 universal inputs (0–5 Vdc, 0–10 Vdc, thermistor, dry contact, pulse counter, 12-bit A/D); 1 N.O. binary output bank (3.75 A max, Class 2 100 VA/4.2 A); 1 analog output 0–10 Vdc / 12 Vdc PWM. Built-in differential pressure airflow sensor (0–2 in. H2O) and Belimo brushless DC actuator (45 in-lb torque).
- **Network:** Eth0/Eth1 10/100 BaseT (BACnet/IP and/or BACnet/Ethernet, ring or daisy-chain); Rnet (up to 5 ZS/wireless sensors + 1 Equipment Touch/OptiPoint); Act Net (up to 5 addresses); 2× USB Comm/Service ports.
- **Power:** 24 Vac ±15%, 50 VA or 24 Vdc ±10%, 18 W (controller only — Act Net devices add load).
- **Addressing:** IP addressing via controller setup pages (Default IP via rotary switches on connected devices, Custom Static, or DHCP) through the Local Devices table — the OF141-E2 itself has no on-board rotary address switches; addressing is done through USB Comm/Service port connection to the WebCTRL controller setup pages.
- **Memory:** 4 GB eMMC flash + 256 MB DDR3 DRAM; max 1 control program; max 12,000 BACnet objects; 100 third-party BACnet points (BACnet/IP only).
- **Field gotchas:**
  - Rnet supplies only 12 Vdc/260 mA — verify total sensor draw before adding an Equipment Touch/OptiPoint (those are NOT powered by the Rnet port and need external 24 V power).
  - Net LED blue = MS/TP/ARCNET-related error; blue 2-blink = duplicate MAC address; blue 3-blink = no other devices detected; Sys LED magenta = firmware update in progress — **do not power off** during this.
  - Wait 30 seconds after changing a parameter before cutting power, or the change is lost (data commits to flash every 90 seconds).
  - WARNING: never apply line voltage to the controller's ports/terminals.

## OF253T-E2 — Advanced Equipment Controller (Zone Controller)
- **I/O:** 5 universal inputs (12-bit A/D); 2 N.O. binary outputs (one bank, 3.75 A/30 Vac/Vdc, Class 2 100 VA/4.2 A); 2 analog outputs 0–10 Vdc (10 mA max); 1 Universal Output — DIP switch selectable Analog (0–10 Vdc or 12 Vdc PWM @ 80 Hz) or Binary (relay, 3.75A/30 Vac/Vdc).
- **Network:** Eth0/Eth1 10/100 (BACnet/IP, BACnet/Ethernet, and/or Modbus TCP/IP simultaneously); Port S1 EIA-485 for Modbus Serial (9.6–115.2 kbps, has End-of-Net switch); Rnet (5 sensors + touch device); Act Net (5 addresses); Service + Comm USB.
- **Power:** 24 Vac ±15%, 55 VA or 24 Vdc ±10%, 20 W.
- **Addressing:** Universal Output mode set via on-board DIP switch (Analog/Binary); IP/network addressing via controller setup pages, same rotary-switch-driven Default IP scheme as other family members when applicable.
- **Memory:** 4 GB eMMC + 256 MB DDR3 (2 MB available); max 1 program; max 12,000 BACnet objects; 300 third-party BACnet points, 50 third-party Modbus points.
- **Field gotchas:**
  - Only OF253T-E2 (not OF253A-E2) supports Modbus master/slave serial and Modbus TCP/IP — this is the key differentiator between the two "253" parts.
  - Use a PROT485 surge protector everywhere EIA-485 wire enters/exits the building.
  - Do not change power or End-of-Net switch position below -22°F (-30°C) — risk of unreliable contact.
  - Environmental range is wide (-40 to 158°F) — suitable outside the building envelope but must be in a UL-listed enclosure.

## OF253A-E2 — Advanced Application Controller, IP VAV (Zone Controller)
- **I/O:** Identical I/O layout to OF253T-E2 (5 UI, 2 BO, 2 AO, 1 Universal Output), plus a **built-in airflow sensor** (0–2 in. H2O, ±3% accuracy at 2 in. H2O).
- **Network:** Eth0/Eth1 only (BACnet/IP, BACnet/Ethernet) — **no Modbus/Port S1 serial support**; Rnet; Act Net; Service + Comm USB.
- **Power:** 24 Vac 55 VA / 24 Vdc 20 W.
- **Addressing:** Universal Output DIP switch (Analog/Binary); network addressing via controller setup pages / Local Devices table.
- **Memory:** 4 GB eMMC + 256 MB DDR3 (2 MB available); max 1 program; 12,000 BACnet objects; 100 third-party BACnet points (IP only, no Modbus).
- **Field gotchas:**
  - Because it lacks Port S1, this part cannot bridge to a Modbus serial device — use OF253T-E2 instead if serial integration is needed.
  - Same PROT485 surge-protection caution applies to EIA-485-adjacent equipment even though this unit has no serial port itself (relevant when co-located with other 485 gear in a panel).
  - Listed among devices now **UUKL UL864 10th-edition compliant** (see Section 3 in the main OptiFlex research, "Common Product Announcements").

## OF342-E2 — Advanced VAV Controller (Zone Controller)
- **I/O:** 4 universal inputs (12-bit A/D); 3 N.O. binary outputs (one bank, 3.75 A/30 Vac/Vdc, Class 2 100 VA/4.2 A); 2 analog outputs 0–10 Vdc / 12 Vdc PWM. Built-in airflow sensor and Belimo actuator (45 in-lb, 154-second runtime) — same VAV-mount form factor as OF141-E2.
- **Network:** Eth0/Eth1 10/100; Rnet (5 sensors); Act Net (5 addresses); Comm/Service USB.
- **Power:** 24 Vac 50 VA / 24 Vdc 18 W (controller only).
- **Addressing:** Controller setup pages / Local Devices table; no on-board rotary switches for MAC (VAV form factor devices are addressed purely through IP setup).
- **Memory:** 4 GB eMMC + 256 MB DDR3; max 1 program; 12,000 BACnet objects; 100 third-party BACnet points.
- **Field gotchas:**
  - Listed as **UUKL UL864 compliant** per the internal product update memo.
  - Field-replaceable 3A fast-acting glass fuse (5×20mm) — same as OF141-E2.
  - Locator LED rotates with actuator direction — useful for verifying damper rotation during commissioning.
  - Net/Sys LED behavior identical to OF141-E2 — blue blink codes indicate MS/TP/address conflicts, magenta = firmware download in progress, do not power off.

## OF561-E2 — Advanced Application Controller (Zone/Equipment Controller)
- **I/O:** 6 universal inputs (12-bit A/D); 5 binary outputs across 2 banks (3 + 2, each 3.75 A/30 Vac/Vdc, Class 2 100 VA/4.2 A per bank); 1 Universal Output (DIP-selectable Analog/Binary).
- **Network:** Eth0/Eth1 10/100 (BACnet/IP, BACnet/Ethernet, or Modbus TCP/IP); Rnet; Act Net; Service + Comm USB (Comm reserved for future use).
- **Power:** 24 Vac 55 VA / 24 Vdc 20 W.
- **Addressing:** Universal Output DIP switch; network addressing via controller setup pages.
- **Memory:** 4 GB eMMC + 256 MB DDR3 (2 MB available); max 1 program; 12,000 BACnet objects; 100 third-party BACnet points.
- **Field gotchas:**
  - PROT485 surge protector caution applies (same EIA-485 wording as OF253 series, even though it's Ethernet-only for BACnet — this appears to be boilerplate carried from the shared driver documentation, but always protect any serial wiring that leaves the building).
  - Do not adjust power or End-of-Net switch below -22°F (-30°C).
  - Wide environmental range (-40 to 158°F) — outdoor-rated in a UL-listed enclosure.

## OF1628 / OF028 — BACnet Building Controller (Routing)
- **I/O:** 28 universal inputs (16-bit A/D, 0–5/0–10 Vdc, 0–20 mA, RTD, thermistor, dry contact, pulse); OF1628 = 16 universal outputs (analog 0–10 Vdc/0–20 mA or binary relay up to 1A/30 Vac/Vdc); OF028 = 0 outputs.
- **Network:** Gig-E (BACnet/IP, BACnet/Ethernet, Modbus TCP/IP, can host 2 BACnet/IP networks + BBMD each); Port S1 (ARCNET 156 kbps, MS/TP 9.6–115.2 kbps, or Modbus serial — rotary-switch selected); Port S2 (MS/TP or Modbus serial); Rnet (up to 15 ZS/wireless sensors + 1 touch device); Act Net (up to 16 OptiPoint Smart Valves/actuators); I/O Bus (up to 9 wired FIO expanders) + 6-pin edge connector for one DC-powered expander; Ethernet Service Port; USB recovery port.
- **Power:** 24 Vac ±15%, 100 VA or 24 Vdc ±10%, 48 W.
- **Addressing:** Three rotary switches (hundreds/tens/units) set the Default IP address / MS/TP or ARCNET MAC address. Port S1 Configuration rotary switch: 0=unused, 1=MS/TP, 2=ARCNET, 3=Modbus. ARCNET MAC range 1–255; MS/TP MAC range 0–127. Each FIO expander needs its own unique rotary-switch address (1–9).
- **Memory:** 16 GB eMMC + 512 MB DDR3 (22 MB available); dual 32-bit I/O microprocessors (256 kB flash/64 kB SRAM each); max 999 control programs (memory-dependent); 12,000 BACnet objects; 1500 third-party BACnet points, 200 Modbus points.
- **Field gotchas:**
  - **Routing vs. non-routing:** OF1628/OF028 route BACnet between all supported types; OF1628-NR/OF028-NR do not route and only allow one BACnet type active at a time.
  - Controller has built-in I/O bus termination and **must be the first device** on the FIO expander chain; only the last FIO expander should have its End-of-Net switch set to Yes.
  - On Port S1/S2, if the controller is at the end of a segment that includes a DIAG485 with its Bias jumper ON, set End-of-Net to **No** and add an external 120-ohm resistor across Net+/Net- instead of using the switch.
  - Act Net bus max length 300 ft, min 18 AWG copper to prevent voltage drop below 19.2 Vac/21.6 Vdc; Act Net devices need their own Class 2 power source and cannot run off the controller's 24 Vac transformer.
  - ARCNET/MS/TP wiring max length 2000 ft using 22 AWG shielded twisted-pair; listed as **UUKL UL864 10th-edition compliant**.

## OF1628-NR / OF028-NR — BACnet Building Controller (Non-Routing)
- **I/O:** Same as OF1628/OF028 — 28 UI, 16 UO (OF1628-NR) or 0 UO (OF028-NR).
- **Network:** Gig-E (BACnet/IP/Ethernet/Modbus TCP, BBMD, FDR support); Port S1 (ARCNET, MS/TP, or Modbus — only **one protocol at a time**, whichever is selected via rotary switch); Port S2 (Modbus serial only, electrically isolated); Rnet (15 sensors); Act Net (16 addresses); I/O Bus (9 FIO expanders) + edge connector; Ethernet Service Port; USB recovery.
- **Power:** 24 Vac 100 VA / 24 Vdc 48 W.
- **Addressing:** Same 3-rotary-switch scheme as OF1628; Port S1 protocol select 0/1/2/3 for unused/MS-TP/ARCNET/Modbus.
- **Memory:** 16 GB eMMC + 512 MB DDR3; max 999 programs; 12,000 BACnet objects; 1500 BACnet third-party points, 200 Modbus points.
- **Field gotchas:**
  - Key distinction from OF1628: **no BACnet routing** — "Only one port can be configured for a BACnet communication type" at a time on the non-routing unit, whereas the OF1628 can route between Gig-E, S1, and S2 simultaneously.
  - Same I/O bus termination rule: controller is first device (built-in termination); last FIO expander gets End-of-Net = Yes.
  - Two fuses: 2.5A for controller power, 4A for the I/O bus edge connector — replace with correct rating, not interchangeable.
  - PROT485 surge protection required at building entry/exit points on serial wiring.

## OFBBC — BACnet Building Controller (Expander-based I/O)
- **I/O:** **No built-in I/O.** Supports up to 9 FIO expanders and/or 6 MEx expanders, but no more than 9 expanders total combined.
- **Network:** Gig-E (routing between BACnet/IP, BACnet/Ethernet, Modbus TCP/IP; 2 BBMD-capable IP networks); Port S1 (ARCNET/MS/TP/Modbus serial); Port S2 (MS/TP or Modbus serial, isolated); Rnet (15 sensors, no OptiPoint Act Net support — **no Act Net port on OFBBC**); I/O Bus (FIO expanders); Xnet (up to 6 MEx expanders, ARC156 wiring); Ethernet Service Port; USB recovery.
- **Power:** 24 Vac ±10%, 50 VA or 26 Vdc ±10%, 15 W.
- **Addressing:** 3 rotary switches for IP/MAC addressing (same scheme as OF1628); each MEx expander address set via its own rotary switch, range 1–6; FIO expanders addressed 1–9.
- **Memory:** 16 GB eMMC + 256 MB DDR3 (22 MB available); max 999 programs; 12,000 BACnet objects; 1500 third-party BACnet, 200 Modbus points.
- **Field gotchas:**
  - This is a pure "brain" controller — all I/O comes from FIO (I/O Bus) or MEx (Xnet) expanders; plan the expander count carefully (9 max combined).
  - MEx expanders use ARC156-style wiring (22 AWG shielded twisted pair) on the Xnet port, distinct from the I/O Bus wiring used for FIO expanders.
  - Two fuses: 2A controller power, 4A I/O bus edge connector.
  - Listed as **UUKL UL864 10th-edition compliant**.

## OFX48 — I/O Expander (for OF683XT-E2 host controller)
- **I/O:** 8 universal inputs (16-bit A/D, 0–5/0–10 Vdc, 0–20 mA, RTD, thermistor, dry contact, pulse); 4 outputs (analog 0–10 Vdc/0–20 mA or binary relay, up to 1A/30 Vac/Vdc).
- **Network:** I/O Bus port only — connects to the OF683XT-E2 host's I/O bus; the port's End-of-Net switch terminates the expander network segment. No native BACnet/IP or serial network port of its own.
- **Power:** 24 Vac ±10%, 50 VA or 26 Vdc ±10%, 12 W.
- **Addressing:** Not driven by rotary MAC switch in the excerpted spec table — power/communication wiring configuration depends on AC/DC source and supply size (see host controller's instructions for applicable arrangement); End-of-Net DIP-style switch sets I/O bus termination.
- **Memory:** 32-bit microprocessor, 256 kB flash / 64 kB SRAM (I/O processor only — no application memory, as it has no control program).
- **Field gotchas:**
  - The OFX48 is powered by a **Class 2 source only** — isolate it properly if mounted in a panel with non-Class 2 circuits present.
  - Automated Logic controllers/expanders may share one power supply only if polarity is maintained and the supply is dedicated to ALC equipment.
  - WARNING: never apply line/mains voltage to the expander's ports or terminals.
  - Two fuses on the expander: 2A for expander power, 4A for the I/O bus edge connector.

## OFHI-A — OptiFlex Integrator (BACnet Router, no I/O)
- **I/O:** None — pure router/integrator.
- **Network:** Gig-E (routes BACnet/IP, BACnet/Ethernet, Modbus TCP/IP; up to 2 IP networks, each can be a BBMD; FDR support); Port S1 (ARCNET 156 kbps / MS/TP / Modbus serial, 9.6–115.2 kbps); Port S2 (MS/TP or Modbus serial, isolated); Rnet (up to 15 sensors + 1 touch device); Ethernet Service Port; USB recovery port.
- **Power:** 24 Vac ±10%, 50 VA or 26 Vdc ±10%, 15 W.
- **Addressing:** 3 rotary switches (hundreds/tens/units) for Default IP / MAC address; Port S1 Configuration rotary switch selects protocol (0=unused, 1=MS/TP, 2=ARCNET, 3=Modbus, 4=future).
- **Memory:** 16 GB eMMC + 256 MB DDR3 (22 MB available); max 999 control programs (it can run programs despite being a "router"); 12,000 BACnet objects; 1500 third-party BACnet points, 1000 Modbus points.
- **Field gotchas:**
  - Listed among devices now **UUKL UL864 10th-edition compliant**.
  - PROT485 required at building entry/exit for EIA-485 runs.
  - "If you set the Default IP address on the controller setup Ports tab and then change the rotary switches" the address changes to match the new switch position — always verify actual applied address after any rotary switch change.
  - Do not change power/End-of-Net switch position below -22°F (-30°C).
  - Local access page: `https://local.access` or `https://169.254.1.1`. Modbus capacity (1,000 points) is 40× G5CE's (25 points) — the clear choice for Modbus-heavy integrations (chillers, meters, VFDs).

## OFCSR-E2 — Compact Segment Router
- **I/O:** None — router only.
- **Network:** Eth0/Eth1 10/100 Mbps (BACnet/IP, BACnet/Ethernet, built-in fail-safe repeat between ports); Port S1 (BACnet ARCNET 156 kbps or BACnet MS/TP 9.6–115.2 kbps only — **no Modbus support**); USB Service Port.
- **Power:** 24 Vac ±10%, 50 VA or 24 Vdc ±10%, 18 W.
- **Addressing:** No rotary switches — addressed entirely through the **USB Service Port** using the router setup web pages (via USB cable direct or the Automated Logic wireless service adapter, part# USB-W, 5 GHz Wi-Fi only). Supports **MS/TP Autobaud** — the router detects and matches the network's existing baud rate on power-up (requires at least one other device already on the network with baud rate set).
- **Memory:** 16 GB eMMC (120 MB available) + 512 MB DDR3; driver `drv_fwex 107-xx-xxx` or later.
- **Field gotchas:**
  - OFCSR-E2 supports only Eth0/Eth1 + a single Port S1 — it's a lighter-weight router than G5RE/OFHI-A (no Port S2, no Gig-E, no Rnet).
  - **OFCSR-E2 only supports 5 GHz Wi-Fi** with the wireless service adapter — 2.4 GHz will not connect.
  - Cannot access the Service Port by plugging an Ethernet cable into Eth0/Eth1 — must use the dedicated USB Service Port for setup.
  - Red 2-blink on Net LED = "current default IP address does not match current settings" — cycle power after correcting on the Ports tab.

## G5RE — OptiFlex BACnet Router
- **I/O:** None.
- **Network:** Gig-E 10/100/1000 (routes BACnet/IP and/or BACnet/Ethernet); Port S1 (ARCNET 156 kbps or MS/TP 9.6–115.2 kbps); Port S2 (MS/TP only, isolated EIA-485 — **no Modbus on either port**); Ethernet Service Port (10/100, HTTP/IP); USB recovery port.
- **Power:** 24 Vac ±10%, 50 VA or 26 Vdc ±10%, 15 W.
- **Addressing:** 3 rotary switches for Default IP/MAC (same left=hundreds scheme); Port S1 has no separate protocol-select switch in the base G5RE spec table (compare drv_fwex variant, which retains the same S1/S2 mapping).
- **Memory:** 16 GB eMMC (120 MB available) + 256 MB DDR3.
- **Field gotchas:**
  - Two documented variants exist in the space files: the standard **G5RE** Technical Instructions and a **G5RE (drv_fwex)** revision — confirm which driver version is installed before troubleshooting, since port tables and LED page references differ slightly between them.
  - G5RE has no Rnet, no I/O, and no control-program capability — pure two-network router (Gig-E ↔ S1/S2).
  - Must be mounted in a metal enclosure/cabinet rated for the install location — this requirement is called out specifically for G5RE (not always repeated for other family members).
  - PROT485 required at EIA-485 building entry/exit points; single 2A/250 Vac fuse.
  - Conforms to the BACnet Router (B-R-TR) profile per ANSI/ASHRAE 135-2012 Annex L, Protocol Revision 14, and supports BBMD and Foreign Device Registration for cross-subnet BACnet/IP routing.

## G5CE — OptiFlex BACnet Integrator
- **I/O:** None — router/integrator with control-program capability (like OFHI-A) but distinct spec set.
- **Network:** Gig-E (routes BACnet/IP, BACnet/Ethernet, Modbus TCP/IP, up to 2 BBMD-capable IP networks); Port S1 (ARCNET/MS/TP/Modbus serial); Port S2 (MS/TP or Modbus serial, isolated); Rnet (15 sensors + touch device); Ethernet Service Port; USB recovery.
- **Power:** 24 Vac ±10%, 50 VA or 26 Vdc ±10%, 15 W.
- **Addressing:** 3 rotary switches, same scheme as OFHI-A/OF1628.
- **Memory:** 8 GB eMMC + 512 MB DDR3 (22 MB available); max 999 programs; 12,000 BACnet objects; 1500 third-party BACnet points, 25 Modbus points.
- **Field gotchas — CRITICAL PRODUCT ANNOUNCEMENT:**
  - During the global semiconductor shortage, ALC shipped G5CE units **without ARCNET support**. These units have serial numbers starting with **"RT5"** and their label omits the ARCNET selection option. These units will **never** gain ARCNET capability, even with firmware updates, because the enabling hardware components are physically absent.
  - Production of full-featured (ARCNET-capable) G5CE resumed in **November 2023** with serial prefix **"RT6"** and updated labeling.
  - Always check the serial number prefix (via "To get the G5CE's serial number" in the device's controller setup pages) before planning an ARCNET integration on a G5CE — the driver/setup pages will only display communication options the specific unit actually supports.
  - PROT485 surge protection required at EIA-485 entry/exit points; single 2A/250 Vac fuse.


## OFRTR-E2-S2 — OptiFlex BACnet Router (Gen5)
- **I/O:** None — pure BACnet router/BBMD, no control programs, no I/O.
- **Network:** Eth0/Eth1 10/100 (BACnet/IP, BACnet/IPv6, BACnet/Ethernet, BACnet/SC — dual switched ports with fail-safe pass-through); Port S1 (ARCNET 156 kbps or MS/TP 9.6–115.2 kbps — one protocol at a time); Port S2 (MS/TP only, 9.6–115.2 kbps); USB Service Port.
- **Power:** 24 Vac ±10%, 50 VA or 24 Vdc ±10%, 18 W.
- **Addressing:** No rotary switches — Gen5 platform, software-addressed only via the controller setup web pages. ARCNET MAC range 1–254; MS/TP MAC range 0–127.
- **Memory:** 8 GB eMMC + 512 MB DDR3 (120 MB available); ARM Cortex-A8 600 MHz; minimum WebCTRL v9.0.
- **Field gotchas:**
  - **No matching capability-matrix row exists for OFRTR-E2-S2** — treat capacity/limits as PDF-sourced only until ACI verification closes this gap. Do not cite matrix-confirmed numbers for this part.
  - Pure router — no control programs, no Rnet, no Act Net, no I/O Bus/Xnet. Don't cascade multiple OFRTR-E2-S2 units on the same ARCNET segment.
  - BACnet/SC support is **failover-hub-only** — supports up to 10 connections, requires a primary cloud hub; don't spec it as a full BACnet/SC hub replacement.
  - Fuse: 250 Vac 3A, 5x20mm. Factory reset via DSC button.
  - Only Port S1 supports ARCNET; Port S2 is MS/TP-only — mirrors the G5RE/OFISO-E2 port pattern.

## OFISO-E2 — OptiFlex Network Isolator (Gen5)
- **I/O:** None — network isolation router, no control programs.
- **Network:** **Primary Ethernet port** (10/100, faces the customer/WebCTRL server network — BACnet/IP, BACnet/Ethernet); **Isolated Ethernet port** (10/100, BACnet/IP only, faces ACI's own private controller network — **not pingable or IP-discoverable from the Primary side**); Port S1 (ARCNET or MS/TP); Port S2 (MS/TP only); USB Service Port.
- **Power:** 24 Vac ±10%, 50 VA or 24 Vdc ±10%, 18 W.
- **Addressing:** No rotary switches — Gen5 platform, software-addressed via setup web pages. ARCNET MAC 1–254; MS/TP MAC 0–127.
- **Memory:** 8 GB eMMC + 512 MB DDR3 (120 MB available); minimum WebCTRL v9.0.
- **Field gotchas:**
  - **Field-use purpose (matrix-confirmed): "used to separate customer IP network from our own IP network. Routes BACnet traffic back to server."** The **Isolated Port** is ACI's private controller network; the **Primary Port** is the customer/WebCTRL-server-facing network.
  - The Isolated Port has no IP connectivity back to the Primary Port — it only routes BACnet traffic through the device, not general IP traffic. Never treat the Isolated Port as a normal LAN drop.
  - If running a DHCP server on the Isolated Port, the device's own IP must fall **outside** its own DHCP scope.
  - Some BACnet functionality is intentionally disabled on the Isolated Port — confirm expected behavior against the current TI before troubleshooting a "missing" feature there.

## OFINT-E2 — OptiFlex Integration Router (Gen5)
- **I/O:** None — runs control programs and routes/gateways third-party protocols; no local I/O.
- **Network:** Eth0/Eth1 10/100 (BACnet/IP, BACnet/IPv6, BACnet/Ethernet, BACnet/SC, plus IP-based third-party gateway traffic — shared interface); Port S1 (ARCNET, MS/TP, or third-party serial protocol — one at a time); Port S2 (MS/TP or third-party serial protocol — one at a time); **Rnet terminal — FUTURE USE ONLY.**
- **Power:** 24 Vac ±10%, 50 VA or 24 Vdc ±10%, 18 W.
- **Addressing:** No rotary switches — Gen5 platform, software-addressed. ARCNET MAC 1–254 (S1 only); MS/TP MAC 0–127 (S1 or S2).
- **Memory:** Minimum WebCTRL v9.0; max 999 control programs; 12,000 BACnet objects; **5,000-point shared FlexPoint pool** (100 built-in + up to 4,900 purchasable) covering **BACnet third-party AND Modbus integration combined**, not per-protocol.
- **Field gotchas:**
  - **MANDATORY — never document or wire the Rnet terminal as usable.** Both the TI and the ACI capability matrix agree: "the Rnet terminal is labeled for future use and should not be exposed as a usable Rnet connection in the training library." No ZS sensor, Equipment Touch, or OptiPoint should ever be wired there.
  - Gateways Modbus, SNMP, N2 Open, KNX, and M-Bus in addition to native BACnet routing — confirm which driver is installed (Gen5 `drv_gen5` vs. legacy `drv_fwex`) before following any setup procedure, since the two driver families differ.
  - The 5,000-point FlexPoint pool is **shared** across all active third-party integrations on the device — a job running both a BACnet gateway and a Modbus gateway draws from the same combined pool, not two separate 5,000-point allowances.
  - S1 and S2 each run exactly one protocol at a time — plan segment assignment before wiring, not after.

## OFBBC-A — OptiFlex BACnet Building Controller (I/O-Expandable)
- **I/O:** None built-in — full I/O comes from expanders (distinct from plain OFBBC by driver family: OFBBC-A uses `drv_fwex`, not the Gen5 `drv_gen5` line).
- **Network:** Eth0 10/100 (BACnet/IP, BACnet/Ethernet, Modbus TCP); Port S1 (ARCNET/MS/TP/Modbus serial); Port S2 (MS/TP/Modbus serial); Rnet (up to 15 sensors + 1 touch device, 12 Vdc/62.5 mA); I/O Bus (up to 9 wired FIO expanders) + Xnet (up to 6 legacy MEx expanders) — **9 combined expander maximum**; routes, runs control programs, BBMD, FDR, DHCP.
- **Power:** 24 Vac ±15%, 50 VA or 26 Vdc ±10%, 15 W.
- **Addressing:** **3 physical rotary switches** (unlike the Gen5 router/isolator/integration-router family above, which has none). Default IP = `192.168.168.x`, where x = rotary value 1–253 (rotary 0 → .1, rotary 255 → .253). **Do not set the rotary switches to 254.**
- **Memory:** 8 GB eMMC + 512 MB DDR3 (22 MB available); minimum WebCTRL v6.5; max 999 control programs; 12,000 BACnet objects; 1,500 third-party BACnet points + 200 Modbus points = 1,700 combined (matrix-confirmed, no conflict with TI).
- **Field gotchas:**
  - Fuses: 2A at the device, 4A at the I/O Bus edge connector — not interchangeable.
  - Factory reset: set all 3 rotary switches to **911**.
  - Not the same part as plain OFBBC (already documented above) or the Gen5 OFISO-E2/OFINT-E2/OFRTR-E2-S2 family — do not mix driver-setup procedures between them.

## OFHI — OptiFlex Integrator (I/O-less sibling of OFBBC-A)
- **I/O:** None — same footprint as OFBBC-A minus the I/O Bus/Xnet expander capability.
- **Network:** Eth0 10/100 (BACnet/IP, BACnet/Ethernet; BBMD on up to 2 IP networks; FDR; DHCP); Port S1 (ARCNET/MS/TP/Modbus serial); Port S2 (MS/TP/Modbus serial); Rnet (up to 15 sensors + 1 touch device, 12 Vdc/62.5 mA); Modbus gateway (master/slave serial or server/client TCP).
- **Power:** 24 Vac ±15%, 50 VA or 26 Vdc ±10%, 15 W.
- **Addressing:** 3 physical rotary switches, same `192.168.168.x` scheme as OFBBC-A (x = rotary 1–253; never set to 254).
- **Memory:** 16 GB eMMC + 256 MB DDR3 (22 MB available); minimum WebCTRL v6.5; max 999 control programs; 12,000 BACnet objects; 1,500 third-party BACnet points + 1,000 Modbus points = 2,500 combined (matrix-confirmed).
- **Field gotchas:**
  - No I/O Bus, no Xnet — cannot host FIO or MEx expanders at all. Don't confuse with OFBBC-A, which can.
  - Single fuse: 250 Vac 2A (no I/O edge-connector fuse, since there's no I/O Bus).
  - Not the same part as **OFHI-A** (already documented above, Gen5-adjacent) — verify exact part number/driver before applying setup steps.

## OF022-E2 — Advanced Application Controller (Compact Equipment Controller)
- **I/O:** 2 universal inputs, 2 analog outputs — **no binary output, no universal output, and no Act Net port at all.**
- **Network:** Eth0/Eth1 10/100 (BACnet/IP only — no MS/TP, no Modbus at the controller level); Rnet (up to 5 sensors + 1 touch device, 12 Vdc/260 mA).
- **Power:** 24 Vac ±10%, 50 VA or 24 Vdc ±10%, 18 W.
- **Addressing:** No rotary switches — addressed via USB Comm/Service port and controller setup pages, like the rest of the zone family.
- **Memory:** Max 1 control program; **minimum WebCTRL v8** (higher than every other equipment controller in this family, which run on WebCTRL v7); driver `drv_fwex 107-xx-xxxx+`.
- **Field gotchas:**
  - **MATRIX CORRECTION:** third-party BACnet point limit is **25**, not the 1,500 figure that appears elsewhere in some PDF material — the ACI capability matrix is authoritative here; use 25.
  - No expander support (no I/O Bus, no Act Net) — this is the smallest, most stripped-down controller in the "683 family" lineage.
  - Because it needs WebCTRL v8 minimum, don't assume it will bind on a job still running WebCTRL v7 just because its siblings (OF683/OF561T) do.

## OF683-E2 — Full Equipment Controller (BACnet/IP only)
- **I/O:** 8 universal inputs; 2 analog outputs; 6 binary outputs in 2 banks of 3 (3.75 A/30 Vac-Vdc, 100 VA/4.2 A Class 2 per bank); 1 Universal Output (DIP-selectable Analog/Binary/PWM analog).
- **Network:** Eth0/Eth1 10/100 (BACnet/IP only — **the only member of the 683 family with zero serial ports**, no MS/TP, no Modbus); Rnet (5 sensors + 1 touch device, 12 Vdc/260 mA — use the main spec-table current rating, not a lower figure that appears in a caution box elsewhere in the PDF); Act Net (5 addresses: 1 = built-in ALC actuator, 2–3 = ZASF-A, 4–5 = OptiPoint Smart Valve).
- **Power:** 24 Vac ±15%, 50 VA or 24 Vdc, 20 W.
- **Addressing:** No rotary switches — USB Comm/Service port + controller setup pages.
- **Memory:** Max 1 control program; 100 third-party BACnet points (BACnet/IP only, no MS/TP points — matrix-confirmed, matches TI); minimum WebCTRL v7.
- **Field gotchas:**
  - No expander support — no I/O Bus port on this variant.
  - If Modbus or MS/TP bridging is needed on this I/O footprint, step up to **OF683T-E2**; if you also need an OFX48 I/O expander, use **OF683XT-E2** instead.
  - Rnet current draw: use **260 mA**, not 210 mA (a lower figure appears in a PDF caution box but conflicts with the main spec table — treat 260 mA as correct).

## OF683T-E2 — Full Equipment Controller with Modbus/MS/TP
- **I/O:** Same as OF683-E2 — 8 UI, 2 AO, 6 BO (2 banks of 3), 1 UO.
- **Network:** Eth0/Eth1 10/100 (BACnet/IP); Port S1 (EIA-485, Modbus RTU — settable EON switch, MS/TP also supported on S1 per matrix); Port S2 (isolated EIA-485 Modbus, **permanently terminated — must sit at the physical end of its segment**); Rnet (up to 10 sensors, still max 5 per program); Act Net (5 addresses, same 1/2-3/4-5 reservation as OF683-E2).
- **Power:** 24 Vac ±15%, 50 VA or 24 Vdc, 20 W.
- **Addressing:** No rotary switches — USB Comm/Service port + controller setup pages.
- **Memory:** Max **2** control programs (double OF683-E2); 300 third-party BACnet points + 80 Modbus points = 380 combined (matrix-confirmed); minimum WebCTRL v7.
- **Field gotchas:**
  - Port S2 is **permanently terminated at the factory** — plan segment topology so it lands at a physical segment end; you cannot disable termination on S2.
  - No expander support (no I/O Bus port — that capability is reserved for the -XT variant).
  - **UUKL UL864 10th-edition listed** — see `references/uukl-smoke-control.md` for SCS-specific deltas (Modbus S1 minimum baud, Rnet/Act Net SCS restrictions) before specifying on a smoke-control job.

## OF683XT-E2 — Full Equipment Controller with I/O Bus Expansion
- **I/O:** Same as OF683-E2/OF683T-E2 — 8 UI, 2 AO, 6 BO (2 banks of 3), 1 UO.
- **Network:** Eth0/Eth1 10/100 (BACnet/IP); Port S1 (Modbus serial; **matrix marks MS/TP = Yes on S1** even though the PDF port table shows only a "Modbus Serial" row with no separate MS/TP entry — matrix wins, but field-verify actual behavior before relying on simultaneous MS/TP+Modbus on S1); dedicated **I/O Bus port for exactly ONE OFX48 expander** (replaces the Port S2 found on OF683T-E2 — **only 683-family member with I/O expansion**); Rnet (up to 10 sensors, 5 per program max); Act Net (5 addresses: 1 = ALC actuator, 2–3 = ZASF-A — **matrix does NOT list a 4–5 OptiPoint Smart Valve reservation for this part**, unlike OF683-E2/OF683T-E2; do not assume OptiPoint support at addresses 4–5 on the XT variant).
- **Power:** 24 Vac ±15%, 50 VA or 24 Vdc, 20 W.
- **Addressing:** No rotary switches — USB Comm/Service port + controller setup pages. OFX48 expander uses its own I/O Bus addressing (single-expander only, no address selection needed).
- **Memory:** Max 2 control programs; 300 third-party BACnet points + 50 Modbus points = 350 combined (matrix-confirmed); minimum WebCTRL v7.
- **Field gotchas:**
  - **OFX48 is compatible ONLY with OF683XT-E2** — not with the FIO expander family (FIO812u/FIO88u/FIO48u/FIO012u), and not with OFBBC/OF1628/OF028. One host, one expander, no exceptions.
  - **Do not assume OptiPoint Smart Valve support at Act Net addresses 4–5** — the standard 5-address reservation text elsewhere in the PDF includes it, but the capability matrix omits it for this specific part; matrix wins.
  - Some PDF draft material suggests a BACnet profile of B-BC (vs. OF683T-E2's B-AAC) — treat as provisional until confirmed on a specific firmware/TI revision.

## OF561T-E2 — Advanced BIoT Controller (Compact Equipment Controller)
- **I/O:** 6 universal inputs; **no dedicated analog output** (only 1 Universal Output, DIP-selectable Analog/Binary/PWM); 5 binary outputs in **asymmetric** 2 banks (3 + 2 — unlike the 683 family's symmetric 3+3).
- **Network:** Eth0/Eth1 10/100 (BACnet/IP); **Port S1 only — no Port S2** (unlike OF683T-E2, which has both) — EIA-485, MS/TP or Modbus RTU, one protocol at a time; Rnet (5 sensors + 1 touch device — not 10; lower than the T/XT 683 variants); Act Net (5 addresses, same 1/2-3/4-5 reservation scheme as the 683 family).
- **Power:** 24 Vac ±15%, 55 VA or 24 Vdc, 20 W.
- **Addressing:** No rotary switches — USB Comm/Service port + controller setup pages.
- **Memory:** Max 1 control program; 300 third-party BACnet points + 50 Modbus points = 350 combined (matrix-confirmed); minimum WebCTRL v7.
- **Field gotchas:**
  - Only one serial port total — don't plan a dedicated Modbus-only segment on S2 like you would on OF683T-E2; S1 has to carry whichever single protocol the job needs.
  - No expander support.
  - Silkscreened on the board as "Advanced BIoT Controller" — don't be thrown by the label not matching the "OF561T-E2" part-number-based naming used everywhere else.

## FIO812u / FIO88u / FIO48u / FIO012u — I/O Expander Family
- **I/O:** **FIO812u** = 12 universal inputs, 8 universal outputs. **FIO88u** = 8 universal inputs, 8 universal outputs. **FIO48u** = 8 universal inputs, 4 universal outputs (matrix-corrected — an older assumption of 12 inputs/4 outputs is wrong; both the TI and the ACI matrix now agree on 8/4). **FIO012u** = 12 universal inputs, 0 outputs (input-only).
- **Network:** I/O Bus only — no Ethernet, no BACnet/IP, no independent network address. Up to **9 FIO expanders per compatible host controller.**
- **Power:** 24 Vac ±15%, 50 VA or 26 Vdc, 12 W.
- **Addressing:** Rotary-switch address 1–9, unique per expander on the host's I/O Bus chain; **EON (End-of-Net) switch = Yes only on the last expander in the chain.**
- **Memory:** N/A (I/O expansion module, no onboard control logic or BACnet objects of its own).
- **Field gotchas:**
  - **Host compatibility is strictly limited to the OFBBC/OF1628/OF028 family: OFBBC, OFBBC-NR, OF1628, OF1628-NR, OF028-NR.** The FIO family does **not** host on any of the equipment controllers in this update (OF022-E2, OF683-E2, OF683T-E2, OF683XT-E2, OF561T-E2) — those either have no expansion at all or use the incompatible OFX48/I/O-Bus-single-expander scheme instead.
  - Two wiring topologies: **direct edge-connector** (carries both power and comm — no external transformer needed) or **I/O Bus port wiring** (comm only — requires its own external Class 2 transformer).
  - Fuses: 2A at the device, 4A at the edge connector — same rating scheme as OFBBC-A, not interchangeable.
  - For UUKL/smoke-control applications, **only FIO812u and FIO012u are UUKL-listed** — see `references/uukl-smoke-control.md`.

---

## Critical Product Announcements (cross-device)
- **G5CE ARCNET gap:** Units with serial prefix **RT5** (produced during the semiconductor shortage) permanently lack ARCNET hardware and will never support it, regardless of firmware. Units with prefix **RT6** (production resumed November 2023) have full ARCNET support restored. Always check serial number before scoping an ARCNET integration on a G5CE.
- **UUKL UL864 (10th edition) compliance** has been confirmed for: **OFHI-A, OFBBC, OF1628, FIO812U, FIO012U, OF342-E2, OF253A-E2, ZN341A, OF683T-E2, SE6166, REP485** — relevant when specifying fire/life-safety-adjacent integrations that require UUKL-listed hardware.

---

*Compiled from Automated Logic Technical Instructions (space files) for OF141-E2, OF253T-E2, OF253A-E2, OF342-E2, OF561-E2, OF1628, OF1628-NR/OF028-NR, OFBBC, OFX48, OFHI-A, OFCSR-E2, G5RE, G5CE, OFRTR-E2-S2, OFISO-E2, OFINT-E2, OFBBC-A, OFHI, OF022-E2, OF683-E2, OF683T-E2, OF683XT-E2, OF561T-E2, and the FIO812u/FIO88u/FIO48u/FIO012u expander family, plus the internal "These products are now UUKL" product notice and the ACI-verified capability matrix (matrix wins on any conflict with a TI). Reference [automatedlogic.com](https://www.automatedlogic.com/) for the latest revisions — always verify against the current Partner Community document version before field use.*
