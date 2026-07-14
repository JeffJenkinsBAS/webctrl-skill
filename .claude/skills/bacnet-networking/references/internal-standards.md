# Internal Standards — MS/TP Integration, COV/Refresh Timers, Modbus, Wiring Restrictions

This is the shop's internal standards reference for BACnet field-bus integration and network diagnostics. Read this when commissioning a new MS/TP or ARC156 segment, standardizing refresh-timer/COV settings on a job, integrating Modbus, or capturing network traffic for a support case. Controller-hardware-specific wiring limits (Rnet, Act Net, expander buses) live in the alc-hardware skill — this file is the network/protocol layer only.

---

## 1. BACnet MS/TP Wiring & Integration — Non-Negotiables

BACnet MS/TP is an **RS-485 serial protocol** — it is **not Ethernet** and **not plug-and-play**. One bad device or incorrect wiring can break the entire trunk.

**Topology:** Daisy-chain only — one continuous trunk. No stars. No T-taps. No individual home-runs. Start at the controller's MS/TP port, end at the last device with the highest MAC address.

**Cable:** 22 AWG, low-capacitance, twisted, stranded, shielded copper wire. Check manufacturer spec on landing/not landing the shield at each device — landing the shield at every device can cause issues. Max length 2,000 ft (610 m).

**Termination:** 120Ω End-of-Line (EOL) termination at both physical ends **only**. Never terminate mid-trunk. Never enable termination on every controller. **"Two ends. No exceptions."**

**Biasing:** The trunk must have **exactly one bias source**. Newer controllers include bias built in; older installs need a DIAG485 added for bias. No bias = unstable comm. Multiple bias points = devices fighting each other. **"One trunk. One bias."**

**Shielding/grounding:** If shielded cable is used, bond shields together continuously and land the shield at **one end only** (typically the controller). Do not land shield on controller or signal ground — ground loops are a real risk, not theoretical. See also [MS/TP troubleshooting reference](mstp-troubleshooting.md) for termination/biasing exceptions (DIAG485) and cold-weather switch cautions.

**Addressing:** Every MS/TP device needs a unique MAC address on that trunk, matching baud rate across all devices, Max Masters set ≥ highest master MAC address, and a unique Device Instance system-wide. Duplicate addresses break trunks silently.

**Segment limits:** Typical max segment length 2,000 ft (610 m). **Standardize on 38400 baud** unless the situation dictates otherwise. Excessive devices, poor cable, or bad routing shorten this fast.

**MAC numbering discipline:** MS/TP doesn't jump directly between devices — it counts through MAC numbers, 1 to 127 (127 is the highest possible MAC). Big gaps in MAC numbering waste time; sequential MACs mean faster, cleaner token passing. **MS/TP rewards discipline and punishes creativity.**

### Integration & checkout best practices
- Verify wiring and terminations **before** power-up.
- Power and commission devices **in stages**, not all at once.
- Confirm communication device-by-device.
- Use a router/controller to observe token passing, device discovery, and polling stability.
- If adding one device collapses the trunk, that device is guilty until proven innocent.
- If the trunk is unstable, stop programming and check wiring — don't debug logic on an unstable bus.
- If you can't explain how token passing works, you're not done commissioning.

### Common failure causes
Missing or extra EOL termination; no or multiple bias sources; star/tee wiring; shield grounded at multiple points; duplicate MAC addresses; mismatched baud rates; long stubs or noisy routing near VFDs. **"Most MS/TP problems are wiring problems, pretending to be software problems."**

---

## 2. BACnet Refresh Timer & COV Standard

**Effective standard: use Confirmed COV (refresh time ending in `:01`, e.g. `1:01`, `5:01`) on all new integrations and updates.** This greatly reduces BACnet broadcast traffic and ensures reliable, acknowledged data updates.

| Refresh Timer | Behavior | Result |
|---|---|---|
| ≤ 30 seconds | Straight polling | No COV; point polled directly — highest network overhead |
| > 30 sec (≤ 9:59) | Unconfirmed COV | Saves bandwidth; no ACK required; updates can be missed if a packet drops |
| ≥ 1 min + 1 sec (`X:01`, e.g. `1:01`, `5:01`) | **Confirmed COV** ✅ | Reliable; expects ACK, retries on failure |
| > 10 minutes | Becomes resubscription interval | Device re-subscribes at this interval instead of every 10 min |

**Rules of thumb:**
- `≤30s` → Polling (no COV)
- `>30s` → Unconfirmed COV (broadcasts)
- `X:01` → ✅ Confirmed COV (acknowledged, efficient) — **this is the shop standard**
- `>10m` → Used as resubscription interval

### When to use each method
- **Straight polling (≤30s):** device doesn't support COV; real-time updates critical and must never be missed; COV resources exhausted.
- **Unconfirmed COV (>30s–1min):** network traffic needs minimizing; both devices support COV; occasional missed update acceptable; both devices on the **same network segment** (ARCnet/MSTP ring — same-segment unconfirmed COV sends as unicast, not broadcast). ⚠️ Across a router, unconfirmed COV broadcasts and contributes to congestion if many points change frequently.
- **Confirmed COV (≥1:01):** reliability critical (alarming, trending, analytics); subscriber and target on **different network segments**; device supports Confirmed COV (**driver v6.00a-067 or newer**); broadcast reduction is a design goal. Set by entering a refresh time ending in `:01`.

### Confirmed vs. unconfirmed on segmented networks
| Network Type | Unconfirmed COV | Confirmed COV |
|---|---|---|
| Same MSTP/ARCnet loop | Sent as unicast | Sent as unicast with ACK |
| Across BACnet router | Sent as broadcast (may be filtered/dropped) | Sent as unicast with retry/ACK |

### COV subscription limits & resubscription logic
- ALC v6.00a-067+ drivers support up to **1,000 confirmed COV subscriptions per controller**. If exceeded, the controller falls back to polling (e.g., 5:01 interval) — review refresh times or prioritize critical points for COV.
- If refresh time ≤10 minutes, the microblock resubscribes every 10 minutes. If refresh time >10 minutes, the refresh value itself becomes the resubscription interval.

### Best-practice summary table
| Use Case | Recommended Setting |
|---|---|
| Real-time/mission-critical data | Polling (≤30s) or Confirmed COV |
| Limited bandwidth/local network | Unconfirmed COV |
| Same MSTP or ARCnet ring | Unconfirmed COV |
| Across BACnet router | Confirmed COV |
| Trending, alarming, analytics | Confirmed COV |
| Older/unknown device compatibility | Start with Polling; test COV support |

### Checking COV status in WebCTRL
View "Next Refresh / Next Subscription" on the point's status view: **Sub** = active subscription (COV working); **Ref** = fallback to polling. Newer Gen 5 drivers show Confirmed/Unconfirmed status explicitly.

**Standardization directive:** effective immediately, all new integrations and point refresh configurations default to **Confirmed COV (≥1:01)** — reduces broadcast traffic, ensures reliability across routers, and simplifies standardization across all sites.

---

## 3. Modbus Integration Guide

Modbus is the shop's secondary protocol. **Master/Client** asks for information; **Slave/Server** sends it when asked.

### Before starting, have ready
1. A points list (data to read/write — temperature, alarms, etc.)
2. Device details — addresses, baud rate, data bits, stop bits
3. Proper wiring — twisted shielded pair for serial, Ethernet for IP
4. Tools — PuTTY (diagnostics), Wireshark (troubleshooting)

**Checklist:** Device powered on? Correct Modbus driver installed? Communication settings match on both devices (baud, parity, etc.)? Wiring correct and secure?

### Steps to integrate Modbus in WebCTRL

**1. Create a control program.** Use EIKON; add Network I/O microblocks for each Modbus point.

Address formats:
- Serial: `modbus1://UINT/400001`
- Ethernet: `mtcpip://UINT/400001/3/192.168.1.10` (`UINT` = data type; `400001` = register address; `192.168.1.10` = device IP)

**2. Install and download drivers.** Automated Logic Partner Community website → download Modbus driver → add via SiteBuilder.

**3. Wiring**
- Serial (EIA-485): twisted shielded pair. Controller **S1+** → device **+**; Controller **S1-** → device **-**. If the controller is at the end of the network, set "End of Net?" to **Yes**.
- Ethernet: straight-through or crossover cable. Connect controller's Gig-E/Eth0/Eth1 to device or switch.

**4. Configure the driver.** In WebCTRL's Network Tree: select controller → Communication Status → enable the correct port (S1 or Gig-E) → match baud rate/parity/stop bits to the third-party device → for Ethernet, set mode to Client or Server as needed.

**5. Verify communication.** Modbus points updating correctly? Common errors: **"?"** = no communication; **red errors** = address/setup issue. Fix by re-checking wiring, verifying addresses, and checking controller power.

### Modbus registers
| Register Type | Access | Notes |
|---|---|---|
| Coils (Discrete Outputs) | Read/write | On/off values |
| Discrete Inputs | Read-only | On/off values |
| Input Registers (3XXXXX) | Read-only | 16-bit values |
| Holding Registers (4XXXXX) | Read/write | 16-bit values |

- **Unsigned 16-bit:** 0–65,535 (all-1s = 65,535 decimal). **Signed 16-bit:** −32,768 to 32,767.
- For numbers >65,535 or with decimals, use **32-bit** or **FLOAT** registers (FLOAT combines two consecutive 16-bit registers to store a decimal, e.g. 12.34).
- Choosing register type: check device docs for the register type per point, then match the WebCTRL microblock to it (e.g. use **ANI** for FLOAT values).

### Troubleshooting
- **PuTTY (serial):** connect to the controller's serial port. Port S1: type `modbus1 rx` to see received data. For errors: `modbus1 emsg`.
- **Wireshark (Ethernet):** install Wireshark, connect computer and controller to the same network hub, capture traffic to check data flow.

| Error Code | Meaning | Solution |
|---|---|---|
| 1 | Communication Disabled | Enable it in WebCTRL settings |
| 3 | Address Error | Check the Modbus address |
| 97 | Communications Inhibited | Check if "inhibit_comms" is active |

**Quick tips:** use a short cable for initial testing; verify all devices share baud rate and parity; always start with one device before adding more.

---

## 4. Communication Wiring Restrictions — ARC156, MS/TP, Ethernet

⚠️ **Caution:** If bare communication wire contacts the cable's foil shield, shield wire, or a metal surface other than the terminal block, communications may fail. For third-party equipment, always check manufacturer docs — some require different shield termination than ALC gear.

### ARC156
ALC's implementation of the ARCnet industry standard (based on BACnet MSTP) — more nodes, faster speed, longer pulls than typical MS/TP.

- **Nodes:** up to **99 controllers WITH repeaters (REP385)**, unique MAC each. Addressing does NOT need to match wire-pull order — check submittal drawing/SiteBuilder first. ⛔ **31 devices WITHOUT a repeater (REP485)**; best practice stay under **26 controllers**.
- **Speed:** 156 kbps — faster than standard MS/TP baud options (9600 / 38400 / 76800 / 115200 bps). **38400 = our BACnet MS/TP integration standard speed.**
- **Length of pull:** 2,000 ft max without a repeater; best practice under **1,800 ft**.

### BACnet MS/TP
Master-Slave/Token-Passing. ALC controllers work on any BACnet-compliant MS/TP network at 9600/19.2k/38.4k/76.8k bps. **OptiFlex controllers also support 57.6k and 115.2k bps.** If the network contains an **S6104, M220nx, or UNI** controller, network speed must be 9600 or 38.4k bps.

- **Nodes:** same as ARC156 — 99 with repeater (REP385, unique MAC each), 31 without (REP485), best practice under 26.
- **Length of pull:** 2,000 ft max without repeater; best practice under 1,800 ft.

**To optimize MS/TP performance** (adjust for every controller on the network): WebCTRL NET tree → controller → Driver → Device, adjust Max Masters and Max Info Frames, click OK.
- **Max Masters:** set to the highest MAC address (up to 127) actually on the network. ⛔ If a higher-address device is added later, update this field.
- **Max Info Frames:** max info messages a controller may transmit before passing the token. ⛔ Increasing allows more messages per token hold but increases total token-pass time. For a router, set high (e.g. **200**). For non-router controllers, use:

\[
\text{Max Info Frames} = \frac{2 - \left(devices \times \left(0.002 + \frac{80}{baud}\right)\right)}{\left(\frac{600}{baud}\right) \times devices}
\]

Example: 15 devices at 19200 baud → Max Info Frames = **4**. May need to increase the result for controllers communicating many values to other devices.

### Ethernet
ALC's newer-generation controllers use dual-Ethernet, enabling full IP-based building networks (vs. legacy supervisory-controller + serial ARC156/MSTP).

- **Nodes:** limited only by IP addresses available on the subnet.
- **Speed:** ALC controllers limited to 10/100; routers like **G5CE** support gigabit. CAT-5 up to 100 Mbps/100m; CAT-5e up to 1 Gbps; CAT-6 up to 1 Gbps at 100m (10 Gbps at ≤37m/121 ft), has spline separator + foil shield for crosstalk/EMI reduction.
- **Length of pull:** standardize controller-to-controller pulls at **under 150 ft**, so a downed controller (power loss, etc.) can be skipped while still reaching the next controller within the 100m (328 ft) max Ethernet length.

**CIDR quick chart:**
| Subnet Mask | # IPs Available | Prefix |
|---|---|---|
| 255.255.255.0 | 256 | /24 (most frequently used) |
| 255.255.254.0 | 512 | /23 |
| 255.255.252.0 | 1,000 | /22 |
| 255.255.248.0 | 2,000 | /21 |
| 255.255.240.0 | 4,000 | /20 |
| 255.255.224.0 | 8,000 | /19 |
| 255.255.192.0 | 16,000 | /18 |
| 255.255.128.0 | 32,000 | /17 |
| 255.255.0.0 | 64,000 | /16 |

---

## 5. Shield Wiring — ARCnet & MS/TP

The communication network is the "central nervous system" of a BAS — without a reliable link to the supervisory controller (e.g. G5CE or equivalent), the entire BAS is compromised.

In RS-485 setups, the shield wire protects against EMI. Ground it **at one end only**, typically at the supervisory control panel — this dissipates interference without disrupting signal integrity. Effectiveness depends on **continuity**: shield wires should be meticulously twisted together, wrapped around the wires, and neatly secured with electrical tape to form a compact, robust barrier. **Verify continuity through testing** after installation.

---

## 6. Ethernet Topologies and Terminations

Three options: **Daisy-Chain**, **Star**, and **Ring**.

### Daisy-Chain
Same layout historically used for ARCnet wiring — starts at the main supervisory controller, goes in/out of equipment control modules (or up an AAR backbone), ends at an EOL device. First/last controller have one cable connection; all controllers between have two (in and out).
- **No more than 50 nodes/controllers** per daisy-chain run.
- **No more than 50m (150 ft) of cable between each controller.**
- Most cost-effective: single switch port per run (5–8 port switch OK for most projects), less cabling, fewer labor hours than Ring/Star.

### Star
Most expensive/time-consuming — home-run cable to each controller from the switch; needs a single switch port per controller (likely a 16- or 24-port rack-mounted switch). Limited to **100m (300 ft)** per home run — longer will not communicate.

### Ring
Most advanced/reliable — uses **RSTP (Rapid Spanning Tree Protocol)**; maintains comm even if a wire is damaged/cut. Similar to daisy-chain but the run returns to the switch on a separate port to complete the ring. Requires a **layer-3 managed switch capable of RSTP** — more expensive/setup time, chosen for critical sites requiring 100% uptime.
- If a cable is cut, the managed switch self-heals via RSTP, redirecting through the backend port — nearly immediate, downtime may not be visible.
- Recommend integrating managed switches to pull port/RSTP status over **BACnet/IP** so a "NOT NORMAL" alarm/graphical alert notifies the customer of a damaged wire.
- Still limited to **5 nodes/controllers per ring**, and no more than 50m (150 ft) between controllers.

### Ethernet cable choice
CAT 7/8 are overkill for BAS speeds. **CAT5e and CAT6 are the industry standard for building use — CAT6 will most likely be used for our work.**

### Terminating Ethernet ends
Use **T568B** for all terminations, consistent order on both ends of every cable. **Standard runs: limit to 300 ft max** between connections. **Daisy-chain/ring installs: limit to 150 ft max** between controllers.

---

## 7. Obtaining an ARCnet/MS/TP Wireshark Capture

Use when ALC Technical Support requests a packet capture, or when self-diagnosing excessive traffic, binding conflicts, or slow-network symptoms beyond what `commstat`/`tracert` can show (see SKILL.md Section 6 console path).

### Setup
1. Download `DLCap.zip` from the ALC Portal Site; unzip to a folder.
2. Run `setup_dlcap.exe`, accept defaults.
3. Download and install the latest Wireshark (accept defaults, including WinPcap).

### Capture procedure
**You'll need:** a computer with USB, a USB Link Kit (use only the white 7¾" USB-to-485 cable), and a piece of ARC156 cable.

1. First time using the USB Link Kit: install its driver (`CP210x_VCP_*.exe`) before connecting.
2. Connect the USB-to-485 cable to the computer.
3. Connect the ARC156 cable to the USB-to-485 cable's screw terminals.
4. Connect the other end per the target network:

| To Capture… | Connect ARC156 Cable to… | Set… |
|---|---|---|
| ARCNET | Port S2 on an LGR/ME-LGR; Port S1 on an ME812u-LGR — screw terminals Net+, Net-, Signal Ground | Port jumper to EIA-485; DIP switch 1 On for Enhanced Access; on ME812u-LGR set Duplex jumper to Half |
| MS/TP | Any connection on the MS/TP network — insert into the daisy chain as if another device | N/A |

5. Cycle the controller's power.
6. Double-click `DLCapture.bat` in `c:\Program Files\Automated Logic Corporation\dlcap_installer` (may need Administrator rights).
7. Enter the computer's COM port number (Device Manager → Ports).
8. Enter the network baud rate number (for ARCNET, type **5**).
9. Enter the communication type: **1** = MS/TP, **2** = ARCnet.
10. Type `y` to run Wireshark — it opens and displays captured packets.
11. While capturing: get a modstat of a device on the network to create traffic, recreate the actual problem, or wait 30 minutes for normal traffic.
12. Capture → Stop, then File → Save As, naming the file descriptively (e.g. `systemname_excessive_traffic`, `systemname_binding_conflicts`, `systemname_slow_network`).
13. Email the capture to Engineering, or attach to an ALC Technical Support case along with: the device instance number of the problem device and a description of the problem.

---

## 8. Cimetrics B3075 BACnet IP-to-IP Router Setup

Use to route BACnet/IP traffic between the ALC controller network and the customer's IT network — ensures consistent setup, security, and interoperability.

### On-site materials
B3075 router + mounting kit + power supply; 3 Ethernet patch cables; laptop with Chrome/Edge; IP address info for both customer and private (BAS) networks; BACnet network numbers per subnet; standard login credentials.

### Standard login (ALC standard — use for any B3075 in the field)
- **Username:** `admin` / **Password:** `Alc1234$`
- ⚠️ On first login it may require a password change — re-enter the same standard password to keep consistency across jobsites unless otherwise instructed. If credentials are unknown on a previously configured router, factory reset (see below).

### Physical setup
Mount to DIN rail/wall, connect power, confirm boot. Cabling: **Port 1 (Config)** → technician laptop; **Port 2 (Customer)** → customer/IT network; **Port 3 (Private)** → ALC controller switch/BAS VLAN.

### Web interface access
1. Set laptop IP to `192.168.92.100` / mask `255.255.255.0`.
2. Browse to `http://192.168.92.1`, log in with standard credentials, re-enter `Alc1234$` if prompted to change.
3. Go to **Activate Configuration** → **Confirm** to save password and reboot.

### IP setup per port
- **Private Port (ALC side):** static IP per BAS design; subnet mask (usually `255.255.255.0`); BACnet network number (e.g. `2001+`); UDP port `47808` (default).
- **Customer Port (IT side):** static IP (DHCP only with reservation); subnet per IT; default gateway (required if using BBMD); BACnet network number (e.g. `1001`); UDP port `47808`.

### BACnet device settings
Navigate to **BACnet Device Settings**: assign a unique Device Instance Number and a unique Device Name (e.g. `B3075_ALC_Router_BldgA`); save via OK.

### BBMD setup (if needed)
1. Navigate to **BBMD Settings**; enable BBMD on **Customer Port only** — 🚫 never on the Private port.
2. Add BBMDs to the **Broadcast Distribution Table (BDT)** — format `192.168.1.100` or `192.168.1.100:47808`.
3. Optionally enable **Foreign Device Registration** only if required.

### Save and reboot
**Activate Configuration** → review warnings → **Confirm** to save/apply. ⚠️ Unsaved changes are lost on logout or power loss.

### Resetting the B3075
- **Password known:** Login → Manage Configuration → Restore Defaults → enter `admin` password, confirm.
- **Password unknown:** Connect a USB mouse, power cycle the router, wait for the webpage prompt to unplug the mouse, click "Reset Configuration," then use `Alc1234$` after reset.

### Final jobsite checklist
- [ ] Mounted securely and powered up
- [ ] All ports connected correctly
- [ ] Static IPs and network numbers documented
- [ ] BBMD entries applied (if applicable)
- [ ] Admin password set to `Alc1234$`
- [ ] Config saved and router rebooted
- [ ] Verified BACnet traffic across networks

---

## 9. Network Infrastructure Devices (Gen5 OptiFlex)

Four Gen5 OptiFlex parts serve pure network-infrastructure roles (no local I/O). Selection, port capacity, and detailed setup live in the **alc-hardware** skill (`references/port-capability-matrix.md` and `references/device-details.md`) — this is a placement/architecture-level summary only.

- **OFRTR-E2-S2** — Pure BACnet router (Gen5 platform). No control programs, no I/O. Use where you need a straightforward bridge between an MS/TP or ARC156 field segment and BACnet/IP with no Modbus/Rnet/gateway requirement. No ACI-verified capability-matrix row exists yet for this device — treat any specific point-count/port limit as unverified until confirmed. Full specs: **alc-hardware**.
- **OFISO-E2** — Network isolation router. Its defining architectural role is separating the customer's IT/IP network from ACI's own private controller network — it routes BACnet traffic between the two rather than bridging them into one flat segment. Place it at the network boundary where a customer's IT department requires logical/physical separation from the BAS controller network. Never treat its two Ethernet ports as interchangeable — the **Isolated** port carries ACI's private network, the **Primary** port faces the customer network/WebCTRL server. Full specs: **alc-hardware**.
- **OFINT-E2** — Integration router with a 5,000-point shared FlexPoint pool (BACnet + Modbus + third-party gateway protocols such as SNMP/N2/KNX/M-Bus). Use for larger third-party integration jobs that exceed a G5CE's or OFHI-A's Modbus capacity. Runs up to 999 control programs. **Its Rnet terminal is future-use-only and must never be wired as a usable Rnet connection** — do not document or field-wire it as functional. Full specs: **alc-hardware**.
- **OFCSR-E2** — Compact segment router for lightweight Ethernet-to-ARC156/MS/TP bridging. No Rnet, no Gig-E, no Port S2. Configured entirely via USB Service Port (no rotary switches); supports MS/TP Autobaud if another already-configured device is present on the segment. Use for the smallest/cheapest router need on a segment that doesn't require Modbus or Rnet. Full specs: **alc-hardware**.

**Placement rule of thumb**: if the infrastructure need is pure routing with no I/O, no control logic, and no third-party gateway protocol, start with OFRTR-E2-S2 or OFCSR-E2 (cheapest). If IT-mandated network separation is required, use OFISO-E2. If the job needs a large shared Modbus/third-party point pool beyond G5CE/OFHI-A capacity, use OFINT-E2. Full device selection logic, comparison tables, and expander/host compatibility rules: see the **alc-hardware** skill.

---

## Cross-References

- Controller-specific wiring limits (Rnet, Act Net, expander buses) and hardware-model wiring tables: **alc-hardware** skill.
- LED status tables for troubleshooting a specific controller/router model, and firmware-recovery (9-1-1 / DSC-button) procedures: **field-commissioning** skill.
- BACnet address formatting (device/network/object/property/priority syntax) for third-party integration microblocks: [bacnet-protocol.md](bacnet-protocol.md), Section 7.
- Token-passing mechanics, duplicate-MAC symptoms, and termination/biasing exceptions in depth: [mstp-troubleshooting.md](mstp-troubleshooting.md).
