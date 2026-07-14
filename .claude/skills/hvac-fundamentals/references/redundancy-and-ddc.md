# Equipment Redundancy (Lead/Lag vs. Lead/Standby) and DDC Control of an Air Handler

Reference for redundant-equipment sequencing and the full DDC point list behind AHU control. Read before writing or reviewing an AHU sequence, or when commissioning a redundant pump/fan/chiller arrangement.

## 1. Lead/Lag vs. Lead/Standby — Know the Difference Before You Sequence

These two terms describe fundamentally different redundancy strategies. Design engineers frequently mislabel one as the other in specs — verify the actual intended operation against equipment sizing before programming, not just against the label in the SOO.

### 1.1 Lead/Lag
- **Operation**: sequential — the lead unit runs continuously to meet base load; lag unit(s) sit idle but ready, and engage automatically when the lead unit fails *or* when the lead unit alone can't meet setpoint/demand (i.e., lag can run **simultaneously** with lead for added capacity, not just as a failure backup).
- **Load balancing**: rotate which unit is "lead" (daily/weekly/runtime-based) to equalize wear across redundant equipment.
- **Sizing implication**: lag capacity is genuine *additional* capacity — the system is sized assuming lead+lag can run together to meet peak demand.

### 1.2 Lead/Standby
- **Operation**: standby unit is fully inactive until the lead unit fails — it is not a capacity-adder, purely a failover.
- **Advantages**: simpler control logic, energy-saving (standby draws zero power while idle).
- **Limitation**: no capacity flexibility — if the lead unit is undersized for a load spike, the standby unit switching in doesn't add capacity, it just continues serving the same (insufficient) capacity. There's also an inherent delay on switchover versus a system already running two units in parallel.

### 1.3 Two Ways This Goes Wrong in the Field

**(a) Lead/standby control logic implemented on equipment sized for lead/lag.** If the mechanical design assumed two pumps running together at peak (lead/lag sizing) but the control sequence only ever runs one at a time (lead/standby logic), the system physically cannot meet peak flow — this is usually easy to diagnose because the shortfall shows up directly as an inability to hit setpoint at high load, with an obvious "only one pump is ever running" trend signature.

**(b) The 2019 high-rise condo case — read this before touching any primary/secondary HW plant with mismatched pump rotation logic.** In winter 2019, a high-rise condominium building couldn't heat units above 55°F. The plant used a constant-speed primary loop and a variable-speed secondary loop for hot water distribution. Excess secondary flow relative to primary flow caused **reverse flow in the common pipe** (the primary-secondary decoupler), which degraded the secondary hot water supply temperature system-wide. The root cause was improper makeup air unit control — but the failure was **significantly worsened** because the secondary pumps were configured for **lead/lag** operation despite being **sized for lead/standby**. That mismatch let secondary flow creep higher than the primary loop could support, destabilizing the whole distribution loop further. Two independent problems (MAU control + pump rotation mismatch) compounded into a building-wide comfort failure that took real investigation to unwind — the pump rotation mismatch alone would not have caused total failure, but it removed the margin that would have otherwise masked the MAU problem.

**Takeaway for commissioning and SOO review**: never assume the spec's "lead/lag" or "lead/standby" language is correct — cross-check against the actual pump/fan/chiller sizing basis. If sizing assumes only one unit ever needs to run at a time, lead/lag control logic on that equipment is a latent failure waiting for a load or flow condition that exposes it.

## 2. DDC Control of an Air Handler — Full Point List

Use this as the baseline point inventory when reviewing a submittal or building a point list from scratch. Cross-reference against the project's actual sequence — not every AHU needs every point below, but every point present in the sequence should map to one of these categories.

| Point Category | Points | Notes |
|---|---|---|
| **Dampers** | OA damper, RA damper, EA (exhaust/relief) damper | 24V actuators typical; state fail position (OA fails closed is standard) |
| **Temperature sensors** | Return air (RA), mixed air (MA), supply air (SA), outdoor air (OA), space temp | MA sensor should be an averaging element across the duct cross-section, not a single point, to avoid stratification error |
| **Fan status** | Current transducer (CT) sensing actual motor current, not just a control relay auxiliary contact | A relay-based "status" shows commanded state, not proof of actual rotation — see Section 3 below on threshold setup |
| **Filter monitoring** | Differential pressure (DP) sensor across filter bank | Alarm on high DP (dirty filter) — trend for filter-change scheduling |
| **Cooling** | Chilled water control valve (2-way modulating typical) | Fails closed on loss of signal unless sequence states otherwise |
| **Life safety** | Smoke detector — commands automatic AHU shutdown | Hard-wired interlock, independent of BAS logic wherever code requires |
| **Airflow** | Airflow measuring station (AMS) — total supply/OA airflow | Required for DCV Voz math and static pressure T&R request generation |
| **High static pressure switch** | Fire-mode/safety switch, **manual reset required** | Dual output: (1) cuts power to the VFD directly (hardwired safety, not BAS-mediated), (2) sends a status signal to DDC for alarm/logging. This is a life-safety/equipment-protection point — never allow it to be bypassed or auto-reset in software. |
| **VFD control points** | Speed command/setpoint, speed feedback, motor overload status, fault status, soft-start/soft-stop configuration, duct static pressure setpoint (T&R-driven), occupancy/schedule input, energy/power monitoring | The VFD is a control node in its own right, not just a variable-speed relay — commission its fault/overload points explicitly, don't assume "runs fine" means all VFD status points are wired correctly |
| **Humidity** | RA and/or OA relative humidity sensors | Drives humidification (winter) or dehumidification (summer) control — see `references/iaq-monitoring.md` Section 1 |

### 2.1 Sequencing Notes Tied to This Point List
- The **high static pressure switch** is the one safety on this list that must cut power at the hardware level, independent of any DDC logic path — if the BAS is down or the controller has locked up, this safety still has to work. Verify this during point-to-point by physically testing the switch, not just reading its BAS status point.
- **Smoke detector shutdown** is typically a hardwired interlock to the fan starter/VFD enable circuit, with a BAS status point for annunciation — confirm which one actually stops the fan before assuming the BAS sequence's smoke-shutdown logic is the only thing standing between a smoke event and a running fan.
- **CT-based fan status** (vs. relay-based) is the difference between "the fan was commanded on" and "the fan is actually turning" — see Section 3 for how to set the alarm threshold.

## 3. Status Point Verification, Threshold Setup, and Temperature Sensor Field Notes

These are the field-technician-level checks that turn a point list into a correctly commissioned system.

### 3.1 Status Point Setup
1. Verify the current transducer (CT) is terminated and correctly assigned to the intended AI point — a CT wired to the wrong motor leg or the wrong point in the database gives a plausible-looking but wrong status.
2. Start the monitored equipment (fan, pump) via AUTO command, or lock the start/stop point on, to get a live current reading.
3. If the equipment is VFD-driven, **lock the VFD speed to minimum** during this check so the current reading reflects a known, repeatable operating point rather than a moving target.
4. Read the actual AI amperage value at the drive or starter (cross-check against a handheld meter if available).
5. Set the "True if > Constant" microblock threshold **just below the actual current reading observed** — not an arbitrary round number. Setting the threshold too far below the real running current risks a false "running" status during a failure (e.g., belt slip, coupling failure) that still draws some residual current.

### 3.2 Lead/Standby (and Lead/Lag) Rotation Test Procedure
Always test rotation-on-failure explicitly — don't assume it works because the logic "looks right" on the Logic page.
1. Put the redundant equipment's control logic in AUTO.
2. Turn the lead unit off **at the disconnect** (a true hard failure, not a BAS-commanded stop — a BAS stop won't necessarily exercise the same failure-detection path).
3. Confirm the system automatically swaps to the lag/standby unit.
4. Verify an alarm is generated for the failure event — a silent swap-over means nobody gets notified a unit actually failed.
5. Adjust start/stop timing as needed so the building is maintained (temperature, pressure, flow) through the failure/rotation transition without an unacceptable gap.

**Rotation method options**: Daily, Weekly, Monthly, Manual, or **Runtime-based** (most popular in the field — rotates lead designation based on accumulated run-hours rather than a calendar schedule, which equalizes wear more precisely). Manual rotation still allows an on-failure swap, but the system will not proactively rotate lead designation until manually told to — don't mistake "manual rotation mode" for "rotation disabled," but do confirm the operator/PM understands manual mode requires action to actually rotate wear.

**Red-flag warning**: always explicitly check that equipment rotates on lead failure during commissioning — this is one of the most commonly assumed-but-unverified sequences in the field, and a silent failure to rotate is invisible until the day the standby unit that was "supposed to" have been exercised regularly turns out to have never actually run.

### 3.3 Temperature Sensor Field Notes
- Most field temperature sensors in this control ecosystem are **10K ohm @ 77°F thermistors** and are **not polarity-sensitive** — miswiring polarity is not a valid troubleshooting theory for a thermistor reading wrong; look elsewhere (bad location, damaged element, wrong point address).
- For duct-mounted probes, if a reading looks wrong: **pull the thermistor and measure it against a second reference** (another calibrated sensor or an IR gun) rather than trusting the BAS-displayed value alone.
- Always verify the sensor's point label actually matches its physical function and location — a mislabeled SAT/MAT/RAT sensor will pass a superficial "point is reading a reasonable temperature" check while feeding the wrong loop entirely.
