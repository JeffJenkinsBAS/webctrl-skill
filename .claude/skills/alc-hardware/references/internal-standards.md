# Internal Standards — G5CE Setup, Sensors, Actuators, VAV, Room Thermostats, Terminal Colors

Shop-internal procedures and reference data for OptiFlex/ALC hardware that go beyond the device-selection and wiring-limit tables in the main SKILL.md. LED quick-reference tables and firmware-recovery (DSC-button, rotary-911) procedures live in the **field-commissioning** skill — this file covers setup, field decoding, and mechanical/electrical standards only.

---

## 1. Setting Up a G5CE (OptiFlex BACnet Integrator)

### What the G5CE does
- Provides BACnet routing between any supported BACnet communication type.
- Runs control programs (up to 999).
- Can host two BACnet/IP networks on the Gig-E port, each able to serve as a BBMD.
- Supports Foreign Device Registration (FDR) and DHCP IP addressing.
- Built-in network diagnostic capture and network statistics (numeric or trend graph).
- Supports Rnet devices.
- Works with WebCTRL v6.5 or later (latest cumulative patch).
- Can act as a Modbus gateway: master/slave on Modbus serial, or server/client on Modbus TCP/IP.

### Specifications
| Spec | Value |
|---|---|
| Driver | `drv_fwex_<version>.driverx` |
| Max control programs* | 999 |
| Max BACnet objects* | 12,000 |
| Third-party BACnet integration points | 1,500 |
| Third-party Modbus integration points | 25 |
*Depends on available memory.

### Prerequisites before starting
- **Power:** verify 24 VAC (50 VA, operating range 20–30 VAC) or 24 VDC (15 W, operating range 23.4–30 VDC) is available and meets demand.
- **Communications:** verify an Ethernet drop is present (or will be present) in the panel for the building network connection.
- **Space:** verify proper mounting space for the router module.

### Plugging in & setting up (Service Port access)
1. Connect an Ethernet cable from a computer to the controller's Service Port.
2. Turn off the computer's Wi-Fi if it's on.
3. Change the laptop's Ethernet adapter settings: Address `169.254.1.x` (x between 2–7), Subnet Mask `255.255.255.248`, Default Gateway `169.254.1.1`.
4. Browse to `https://local.access` or `https://169.254.1.1` to reach the controller setup pages.

### Ports tab
Define the G5CE's IP addressing (IP address, subnet mask, default gateway) here so it can communicate with the WebCTRL server — this **must match** the IP addressing defined in SiteBuilder's controller Properties dialog.
1. Get IP address/subnet/gateway from the Project Engineer, SiteBuilder, or facility network admin.
2. On the Ports tab under IP Port, select **Custom Static**.
3. Enter IP Address, Subnet Mask, Default Gateway.
4. Click **Save**.

**Verify the rotary dial setting via Active Protocol status on the Ports tab** — this reflects the Port S1 Configuration rotary switch: **0** = Disabled, **1** = MS/TP, **2** = ARCNET, **3** = Modbus.

### Devices tab
- **Device Instance → Assigned:** enter a number unique on the BACnet network.
- End Of Line switch settings are also visible/checkable here.

### Downloading the G5CE
Once network config is saved internally, change the laptop's connection from the Service Port to the **Home IP Port** (top of the G5CE — where the customer network eventually connects). Change the laptop's IPv4 settings to match the WebCTRL server IP, plug into the top port, run WebCTRL Server on the laptop, verify the correct database starts, then browse to `https://localhost` and log into WebCTRL.

In WebCTRL: **CONFIG tree → Connections** → confirm the BACnet/IP Connection for the network is correct → **Configure** tab → check the BACnet/IP Connection setup (IP Address should match the laptop's IPv4) → **Start** — status should change to **Connected**. Then go to the **NET Tree**, find the G5CE, click it, and on the **Downloads** window it should be queued for a memory or All Content download. If not, click **Add**, select the G5CE and **All Content**, then **Add** and **Start**.

### Reverting to default settings (9-1-1)
⛔ **This erases all archived information and user-configured settings.** After recovery, you must connect locally to the G5CE and manually reconfigure all BACnet, IP, and firewall information. Only perform after exhausting all other troubleshooting. **Full step-by-step rotary-911 recovery procedure and LED behavior during recovery: field-commissioning skill (controller-service reference).** After recovery, in SiteBuilder: configure Device Instance, Network Number, and address; assign the new driver version; use WebCTRL Downloads → **Download all content** to recover previous parameters/programs.

### Troubleshooting
For reading LED lights during troubleshooting, see the **field-commissioning** skill's G5CE LED quick-reference. Contact the Project Engineer only after exhausting your own troubleshooting efforts.

---

## 2. ALC ZS Sensor — Rnet Tag & Path Reference

### Quick concept
- **Path** = where the value comes from.
- **Rnet Tag** = what the value means (drives icons, status indicators, display behavior, and user interaction like setpoints/fan speed/mode).

### Field cheat sheet (most-used tags)
```
001 → Zone Temp
002 → Zone Humidity
100 → Fan Status
116 → Energy Save Mode
400 → Heating Setpoint Adjust
401 → Cooling Setpoint Adjust
500 → Fan Speed Status
600 → Fan Speed Request
601 → Zone Mode Request
```

### Rnet tag categories

**Core sensor values:**
| Tag | Name | Type | Notes |
|---|---|---|---|
| 001 | Zone Temp | Analog | Primary temperature |
| 002 | Zone Humidity | Analog | %RH |
| 003 | Zone CO₂ | Analog | ppm |
| 004 | Zone VOC | Analog | Air quality |

**Fan & equipment status:**
| Tag | Name | Type | Notes |
|---|---|---|---|
| 100 | Fan Status | Binary | Displays fan icon |
| 116 | Energy Save Mode | Binary | Energy icon |
| 117 | Occupied Status | Binary | OCC indicator |
| 121 | Override Status | Binary | Override active |

**Airside/system values:**
| Tag | Name | Type |
|---|---|---|
| 300 | Outside Air Temp | Analog |
| 301 | Outside Air Humidity | Analog |
| 304 | Supply Air Temp | Analog |
| 305 | Return Air Temp | Analog |
| 320 | Supply Static Pressure | Analog |
| 322 | Building Static Pressure | Analog |
| 327 | Economizer | Binary |

**Setpoints & adjustments:**
| Tag | Name | Type | Notes |
|---|---|---|---|
| 400 | Heating SP Adjust | Analog | Offset |
| 401 | Cooling SP Adjust | Analog | Offset |
| 402 | Occupied Heat SP | Analog | |
| 403 | Occupied Cool SP | Analog | |
| 404 | Unoccupied Heat SP | Analog | |
| 405 | Unoccupied Cool SP | Analog | |
| 420 | SP Adjust Limit | Analog | |

**User interaction (critical):**
| Tag | Name | Type | Notes |
|---|---|---|---|
| 500 | Fan Speed Status | Multi-State | Display only |
| 501 | Zone Mode Status | Multi-State | |
| 600 | Fan Speed Request | Multi-State | User control |
| 601 | Zone Mode Request | Multi-State | Heat/Cool/Fan |

**Alarm tags (common):**
| Tag | Name |
|---|---|
| 1024 | Generic Alarm |
| 1025 | High Zone Temp |
| 1026 | Low Zone Temp |
| 1027 | Filter Change |
| 1046 | Smoke Alarm |

Full alarm range: **1024–1070**.

**Custom tags:**
| Range | Type |
|---|---|
| 11xx | Binary |
| 13xx | Analog |
| 15xx | Multi-State |

### Path formatting guide

Basic structure: `<device>/<microblock>/<property>` — e.g. `zone_temp/present_value`.

Full path example: `#VAV_1/zone_temp/present_value` — `#VAV_1` = device, `zone_temp` = microblock, `present_value` = property.

BACnet network path example (ANI): `bacnet://this/zone_temp_1/4173(3)` — `bacnet://` = protocol, `this` = local controller, `zone_temp_1` = object name (ASVI reference), `4173` = device instance, `(3)` = object instance.

**Rnet Tags are NOT part of the path** — they're assigned inside the microblock itself.

### EIKON workflow
1. Add **Sensor Binder**.
2. Add **ASVI / BSVI**.
3. Assign **Rnet Tag**.
4. Enable the Rnet checkbox.
5. Wire into logic.
6. Reference via path: `microblock/present_value`.

### Common mistakes
- Wrong Rnet tag → sensor shows numbers instead of icons.
- Forgot "Enable Rnet" → nothing works.
- Wrong object name in ANI → no data.
- Mixing RS and ZS logic → chaos.
- Overloading the Home Screen → unreadable sensor.

### Pro tips
- Keep Home Screen simple (Temp + maybe 1 more value); use Info/Diagnostics screens for everything else.
- Always name microblocks clearly — no "m000" nonsense.
- Use Calculated Value for multi-sensor averaging.

---

## 3. Freezestat Best Practices

### What a low limit switch (freezestat) does
Has a sensing bulb that checks air temperature. If it drops too low, it can turn off the heating/cooling system and/or send an alarm — preventing coil water from freezing, expanding, and cracking pipes.

### Mounting and installation
- Locate the sensing element on the downstream side of the preheat coil or mixing chamber of OA/RA.
- Cover the entire area, especially the bottom — cold air sinks; warmer "safe" air is at the top.
- Avoid locations subject to excessive vibration.
- Locate the freezestat case where ambient temperature is always warmer than the setpoint.
- Install with the reset button readily accessible and the element bellows pointing down.
- Avoid sharp bends or kinks in the sensing element — make wide bends in each turn.
- Install as much of the sensing element as possible in a horizontal plane, serpentine, across the inlet side of the preheat coil.
- **No preheat present:** install the freezestat element across the **inlet** of the chilled water coil.
- **No access between preheat and chilled water coil:** install across the **outlet** of the chilled water coil.

⛔ **Do not bend the first 1 inch (25.4mm) of the capillary where it exits the bellows housing** — doing so may break the capillary at the bellows housing.

### Verifying operation
- **Set the temperature:** use a screwdriver to set the trip temperature — usually around **35°F**.
- **Test it:** cool the sensor (e.g., with ice) to confirm it turns off the system or alarms. Alternative: hold canned air upside down and spray a small section of the element.
- **Double-check:** watch the system run for a while to confirm proper operation.

---

## 4. The Belimo Code — Actuator Label Decoding

Belimo is Swiss; the name derives from Swiss root words: **BE**raten (Consulting), **LI**fern (Delivering), **MO**ntieren (Mounting).

### Actuator code breakdown

**1st letter — Torque:**
| Letter | Torque | Mnemonic |
|---|---|---|
| G | 360 in-lb | Giant |
| A | 180 in-lb | Awesome |
| A | 133 in-lb | Awesome |
| N | 90 in-lb | Normal |
| L | 35–45 in-lb | Little |
| T | 18 in-lb | Tiny |

**2nd letter — Motor action:**
| Letter | Motor Action |
|---|---|
| F | Spring Return (returns to failure position on power loss) |
| M | Non-Spring Return (fails in place on power loss) |

**3rd letter (and optional 4th for non-spring-return) — Motor speed:**
| Letter | Motor Speed |
|---|---|
| Q | Quickest Running (Non-Spring Return) |
| C | Fast Running |
| A | No Position Feedback (Spring Return only) |
| (no letter) | Normal Speed |
| B | Basic |
| X | Customized |

**Numbers — Power supply:**
| Number | Voltage |
|---|---|
| 24 | 24 VAC/VDC |
| 120 | 120 VAC |
| 230 | 230 VAC |

**Control letters/numbers (after power supply):**
| Code | Control Signal |
|---|---|
| (blank) | On/Off (Spring Return) |
| 1 | On/Off (Non-Spring Return) |
| 3 | Floating Point (Spring Return) |
| 3 | On/Off, Floating Point (Non-Spring Return) |
| 3-P5 | On/Off, Floating Point with 5K ohm Feedback (Non-Spring Return) |
| 3-P10 | On/Off, Floating Point with 10K ohm Feedback (Non-Spring Return) |
| SR | 2–10 VDC Signal |
| PC | 0–20 volt (Phasecut) Signal |
| MFT | Multi-Function Technology (programmable via ZTH Tool or PC Tool) |
| MFT95 | 0–135 ohm |
| MFT-20 | 6–9 VDC, 20 VDC power supply (Spring Return) |

**Last letter — Options:**
| Letter | Options |
|---|---|
| S | Built-in Aux Switch |
| T | Terminal Block |
| (blank) | Cable Version |

---

## 5. VAV Box Setup

### VAV box inlet size → CFM @ 1" reference table
| Inlet Size | CFM @ 1" |
|---|---|
| 4 | 229 |
| 6 | 515 |
| 8 | 916 |
| 10 | 1432 |
| 12 | 2062 |
| 14 | 2806 |
| 16 | 3665 |
| 22 | 7000 |

### Damper stroke time
The Airflow microblock parameter must match the controller type on the VAV box:
- **Legacy:** ZN341V+ → **205 seconds**; ZN341A → **154 seconds**.
- **OptiFlex:** OF342-E2 → **154 seconds**; OF141-E2 → **154 seconds**.

### Global airflow configuration
Airflow settings can be set per box or globally once a floor/building is up and communicating on the network.
1. On the GEO tree, select the Area to configure.
2. Right-click the Area → **Airflow Config**.
3. A window opens with data for every airflow microblock under the selected area.
4. Set design values for all boxes: damper stroke time and CFM @ 1" w.c. for each box.
5. Recommendation: pull up the mechanical VAV schedule (box sizing, design airflow values) alongside this window while connected, so you can set all design values at once and confirm against the mechanical drawings' VAV schedule for **Cool/Heat Max, Min Occupied, and Aux Heat** (if applicable).

---

## 6. BASRT-B BACnet Room Thermostat — Setup and Operation

### Overview
BASRT-B is a BACnet multi-network router enabling communication between BACnet/IP, BACnet Ethernet, and BACnet MS/TP networks, configured via a built-in web interface. Supports up to **254 MS/TP devices** with routing across multiple network types.

### Hardware setup

**Power supply:** Input 24 VAC or 24 VDC, draw ≤ **4 VA**. Connections: **HI** = hot side of AC/DC source; **COM** = common/neutral side. If using shielded cable, tie one end to chassis ground, tape back the other. Caution: don't share power with full-wave rectified devices unless confirmed compatible.

**MS/TP port:** 3-pin terminal block — **+/-** (differential data), **SC** (Signal Common — must connect to MS/TP signal common for proper communication). Internal jumpers near the MS/TP connector: **U and D** = pull-up/down bias resistors (default installed); **T** = termination resistor (default installed). Tip: if the BASRT-B is not at the end of the MS/TP bus, remove the jumpers and use external termination instead.

**Ethernet port:** shielded RJ-45, auto-negotiation and Auto-MDIX — no special cable required. Indicators: **Green** = 100 Mbps link; **Yellow** = 10 Mbps link; **Flashing** = network activity.

### Configuration

**Initial setup:** Default IP `192.168.92.68`, subnet mask `255.255.255.0`. Connect via Ethernet using a computer set to a compatible IP (e.g. `192.168.92.69`).

**Changing the computer's IP (Windows 10 example):** Network & Sharing Center → Change Adapter Settings → right-click active adapter → Properties → Internet Protocol Version 4 (TCP/IPv4) → Properties → "Use the following IP address": IP `192.168.92.69`, Subnet `255.255.255.0`, Gateway `192.168.92.1`.

**Accessing the web interface:** browse to `http://192.168.92.68`. Default credentials: **admin / admin** — must change on first login. **Standard default admin password: `Alc1234$`.**

**Configuring network settings:** Device Instance — set a unique instance ID. IP Settings — static IP/subnet/gateway if not using DHCP. MS/TP Settings — ensure matching baud rate, MAC addresses, and network IDs across all connected devices.

### LED indicators
Power: green (on when powered). Ethernet: activity/speed per above. MS/TP: green flashing = valid MS/TP traffic.

### Testing and troubleshooting
1. Check the Status Screen on the web interface for live traffic monitoring.
2. Ensure proper MS/TP bus termination and signal common connections.
3. Use the **Reset IP switch** if locked out — press for **3 seconds** to reset credentials and IP.

### Advanced features
- **BBMD Configuration:** enable for multi-subnet communication.
- **Firmware Updates:** via the USB Mini-B port.
- Tip: keep the router at a fixed IP when using BBMD to avoid dynamic-IP issues.

### Common issues
1. **No MS/TP communication:** verify SC connections and termination; check baud rate and MAC address settings.
2. **Network errors:** ensure no duplicate device instances or network IDs; monitor the router's status for frame errors or token issues.

---

## 7. Terminal Strip — Color Code Standards

### Heat Pump
| Terminal | Function | Wire Color |
|---|---|---|
| G | Fan motor | Green |
| Y1 | Compressor stage 1 | Yellow |
| Y2 | Compressor stage 2 (if present) | Blue |
| O (or O/B) | Reversing Valve | Orange |
| R or RH | 24 volts + | Red |
| C | 24 volts − | Black |

### Furnace
| Terminal | Function | Wire Color |
|---|---|---|
| G | Fan motor | Green |
| Y1 | Cooling stage 1 | Yellow |
| Y2 | Cooling stage 2 (if present) | Blue |
| W1 | Heating stage 1 | White |
| W2 | Heating stage 2 (if present) | Brown |
| R or RH | 24 volts + | Red |
| C | 24 volts − | Black |

---

## Cross-References

- Full G5CE/G5RE/OF***-E2 firmware recovery procedures (FAT32 USB prep, DSC-button and rotary-911 methods, step-by-step LED progression during recovery) and LED quick-reference tables (OF342-E2, G5CE): **field-commissioning** skill.
- Controller selection, comparison tables, and wiring/addressing quick reference for all OptiFlex parts: main [SKILL.md](../SKILL.md) and [device-details.md](device-details.md) / [wiring-and-networks.md](wiring-and-networks.md).
- MS/TP/ARC156 network-layer standards (biasing, termination, Max Info Frames, COV/refresh timer directive, Modbus network integration): **bacnet-networking** skill.
