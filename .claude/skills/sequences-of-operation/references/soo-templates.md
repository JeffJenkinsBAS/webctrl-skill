# SOO Skeleton Templates

Bracketed-placeholder templates for the six most common system types. Each follows the mandatory structure from SKILL.md Section 1: System Overview → Enable/Disable → Occupied Mode → Unoccupied Mode → Reset Logic → Safeties → Alarms → Notes/Assumptions.

Fill every `[bracket]` with a project-specific value. Do not leave a bracket unresolved in an issued sequence — an unresolved placeholder is worse than a missing section because it can be missed on review. Typical values are suggested inline; verify against the mechanical schedule, equipment submittal, and current ASHRAE edition before issuing.

---

## Template 1 — VAV Air Handling Unit

### 1. System Overview
[AHU tag, e.g., AHU-3] serves [zone/area description] via [number] VAV terminal units. Design supply airflow: [X] cfm. Design cooling coil capacity: [X] tons / [X] MBH. Design heating coil capacity: [X] MBH. Chilled water from [plant/source]; hot water from [plant/source]. Supply fan: [VFD / two-speed / constant volume], [X] hp. [Economizer type: dry-bulb / differential dry-bulb / enthalpy], per 90.1 climate zone [X] high-limit requirements.

### 2. Enable/Disable Conditions
Supply fan starts when: (schedule = Occupied OR Optimal Start active OR BAS operator command = On) AND smoke detector(s) = Normal AND freezestat = Normal AND [any other interlock, e.g., fire/smoke damper end-switch = Normal]. Supply fan stops on loss of any enable condition, on a fan status failure alarm persisting >[5] minutes, or on any safety trip (Section 6). [State return/relief fan interlock to supply fan explicitly if present.]

### 3. Occupied Mode
- **Supply air temperature (SAT):** design cooling SAT setpoint [55°F]; reset per trim-and-respond, SPmin [55°F] / SPmax [65°F] (see Section 5).
- **Duct static pressure:** setpoint via T&R, band [0.4–1.5] in.w.g. (see Section 5). Sensor location: [X]% down the [longest/critical] duct run.
- **Economizer:** enabled when OAT (or OA enthalpy) < high-limit setpoint [X°F/Btu-lb] AND cooling is called; OA damper modulates to [mixed-air temperature setpoint / minimum ventilation flow with separate minimum-OA damper — state which].
- **Mixed-air low limit:** [45–50°F]; OA damper closes toward minimum if MAT falls below this value.
- **Mechanical cooling:** stages/modulates chilled water valve once economizer is fully open and SAT is still above setpoint.
- **Heating coil (if present):** modulates to maintain SAT setpoint when heating is called (typically only active during warm-up or extreme cold OAT, per zone group mode).

### 4. Unoccupied Mode
- Fan [cycles per night-cycle setpoint of [X°F] zone temp / remains off] unless a zone group enters Warm-up, Cooldown, or Freeze-Protect Setback mode.
- OA damper closes to [0% / minimum ventilation floor if continuous ventilation required] during unoccupied fan-off periods.
- [State morning warm-up/cooldown behavior: OA damper closed, 100% recirculation, until space temp within [X°F] of occupied setpoint.]

### 5. Reset Logic
**SAT reset (Trim & Respond):** SP0 [55°F] / SPmin [55°F] / SPmax [65°F] / Td [10 min] / T [5 min] / I [2 requests] / SPtrim [+1°F] / SPres [−2°F] / SPres-max [−2°F]. Requests generated per zone per [reference Guideline 36 or state custom logic].

**Duct static pressure reset (Trim & Respond):** SP0 [1.2 in.w.g.] / SPmin [0.4 in.w.g.] / SPmax [1.5 in.w.g.] / Td [5 min] / T [2 min] / I [2 requests] / SPtrim [−0.02 in.w.g.] / SPres [+0.06 in.w.g.] / SPres-max [+0.06 in.w.g.].

### 6. Safeties and Failure Response
- **Freezestat:** trips below [38°F] across coil face; action: stop supply fan, close OA damper fully, open HW valve to 100% [if HW coil present]; reset: [manual at panel / auto after clearing]. Alarm: Critical, no delay.
- **High duct static pressure:** trips above [X in.w.g.]; action: stop supply fan; reset: [manual/auto]. Alarm: Critical.
- **Smoke detection:** on smoke alarm, [fan shuts down / fan continues in smoke-control mode per life-safety sequence — coordinate with fire alarm system]; reset: manual at fire alarm panel.
- **Fan failure (status mismatch):** command on, status off for >[5] min → shut down fan command, alarm; auto-retry [X] times before locking out.
- **Actuator fail-safe positions:** OA damper fails closed; CHW valve fails closed; HW valve fails open; VFD fails [to bypass at last speed / stops — confirm with electrical].

### 7. Alarm Conditions
| Alarm | Trigger | Delay | Severity | Operator action |
|---|---|---|---|---|
| SAT deviation | >[X°F] from setpoint | [10] min | Major | Investigate coil/valve |
| Duct static high/low | Outside [X–Y] in.w.g. | [5] min | Major | Check fan/VFD, duct leaks |
| Freezestat trip | <[38°F] | 0 (instant) | Critical | Immediate response — verify coil/OA damper |
| Filter high DP | >[X in.w.g.] | [30] min | Minor | Schedule filter change |
| [add project-specific alarms] | | | | |

### 8. Operator-Adjustable Items / Notes / Assumptions
- SAT SPmin/SPmax, duct SP SPmin/SPmax, T&R timers — all adjustable at [BAS graphic/point].
- Mixed-air low limit, economizer high-limit setpoint — adjustable, restricted to [operator/admin] access level.
- **Assumptions:** [e.g., "Sequence assumes VFD-equipped supply fan with 0–100% speed feedback. If a two-speed or constant-volume fan is furnished, revise Sections 3 and 5 accordingly."]

---

## Template 2 — VAV Terminal Unit, Cooling Only

### 1. System Overview
[VAV tag(s), e.g., VAV 3-01 through 3-06, "typical of" list explicitly stated] serve [room/zone description]. Design cooling maximum airflow: [X] cfm. Design minimum airflow: [X] cfm (per calculated Voz — state calculation basis, not an arbitrary percentage). Served by [AHU tag].

### 2. Enable/Disable Conditions
Box is active whenever [AHU tag] supply fan is proven on. Zone temperature control is active in all AHU occupancy modes; box goes to zero-flow (or unoccupied ventilation floor if applicable) when zone group is in Unoccupied mode and not in Warm-up/Cooldown/Freeze-Protect Setback.

### 3. Occupied Mode
- Zone temp loop (PI) modulates airflow setpoint between Vmin [X cfm] and Vcool-max [X cfm] as zone temp rises above cooling setpoint [74–75°F].
- In deadband [width X°F] or below cooling setpoint, airflow setpoint holds at Vmin.
- Damper position (inner loop, PI) modulates to hold commanded airflow setpoint per flow sensor feedback.
- Damper position feedback point required; state whether pressure-independent (flow-sensor-based) or damper-position-only control is used.

### 4. Unoccupied Mode
Damper closes to [zero flow / unoccupied ventilation floor of X cfm] unless zone is in Warm-up/Cooldown/Freeze-Protect Setback mode.

### 5. Reset Logic
[If box participates in AHU-level SAT or duct static pressure T&R, state the specific request-generation trigger for this box type: e.g., "generates a static pressure request when damper ≥95% open or measured airflow <90% of setpoint."] No box-level reset otherwise.

### 6. Safeties and Failure Response
- **Damper actuator failure position:** fails [open at Vmin position / last commanded position — state which and confirm with actuator spec].
- **Airflow sensor failure:** if flow sensor reading is out of range for >[X] min, box reverts to [damper-position-only control at a fixed default position / alarm and hold last good value] — state which.
- **Loss of communication to AHU:** box [holds last commanded setpoint / defaults to a safe minimum position] for [X] minutes before alarming.

### 7. Alarm Conditions
| Alarm | Trigger | Delay | Severity | Operator action |
|---|---|---|---|---|
| Zone temp deviation | >[X°F] from setpoint | [15] min | Minor | Check damper operation, airflow sensor |
| Airflow sensor failure | Out of range | [5] min | Minor | Inspect/replace sensor |
| Damper not tracking command | Feedback vs. command mismatch >[X]% | [10] min | Major | Inspect actuator/linkage |

### 8. Operator-Adjustable Items / Notes / Assumptions
- Vmin, Vcool-max, zone cooling setpoint, deadband — all adjustable.
- **Assumptions:** [e.g., "Vmin calculated per 62.1 Voz assuming design occupancy of X people/1,000 ft². Revise if room use changes."]
- **Typical-of note:** if this template applies to multiple boxes, list every included tag explicitly and flag any box with different Vmin/Vcool-max/reheat as an exception, not folded into "typical."

---

## Template 3 — VAV Terminal Unit, Reheat

Follows Template 2's structure for the cooling stage; add the following heating-stage content to Sections 3 and elsewhere.

### 3. Occupied Mode (addition)
- **Heating stage:** below heating setpoint [70–71°F], airflow setpoint holds at Vmin [or Vheat-min if different, state value] while discharge air temperature loop modulates reheat valve/element to maintain a calculated discharge setpoint, capped at a maximum discharge air temperature limit of [X°F, e.g., SAT + 20–30°F — confirm against coil selection].
- Reheat type: [hot water valve / electric element] — state fail-safe position (HW valve fails [open/closed]; electric element fails off with airflow proving switch interlock).

### 5. Reset Logic (addition)
[State whether this box's reheat valve position feeds a leaking-valve FDD rule: "If reheat valve commanded to 0% for 15 minutes and discharge air temp remains >5°F above AHU SAT with fan proven on, generate a Level [X] alarm."]

### 6. Safeties (addition)
- **Reheat high-limit:** discharge air temp >[X°F] → close reheat valve/de-energize element regardless of loop command; alarm.
- **Electric reheat interlock:** element cannot energize unless airflow proving switch confirms flow ≥[minimum cfm] — prevents overheating a stagnant duct section.

---

## Template 4 — Chilled Water Plant

### 1. System Overview
Plant serves [building(s)/campus loop] with [number] chillers, [type: centrifugal/screw/scroll/magnetic-bearing], [X] tons each, [N+redundancy strategy]. Configuration: [primary-secondary decoupled / variable-primary-flow]. Condenser water via [cooling tower(s), number and type]. [State TES tank if present.]

### 2. Enable/Disable Conditions
Plant enabled when: (schedule = Occupied for any served building OR manual override) AND [at minimum one CHW pump proven running] AND no plant-level safety trip active. Individual chillers enabled/staged per Section 3 sequencing logic; each chiller additionally requires its own proven condenser water flow and evaporator water flow before start permit is issued.

### 3. Occupied Mode
- **CHW pump(s):** [variable-speed primary/secondary, or VPF] maintain differential pressure setpoint at [remote/critical coil sensor location] via T&R (see Section 5).
- **Chiller staging:** based on part-load ratio (PLR) AND lift, not load alone. Staging point: \(SPLR = E(CWRT-CHWST) + F\) using manufacturer performance coefficients — state E/F or reference the chiller selection software output. Time delay before staging a second chiller: [X] minutes minimum, to prevent short-cycling.
- **Condenser water pump(s):** [VSD, staged at X% of design flow / constant-speed, staged 1:1 with chillers].
- **Cooling tower fan(s):** VFD-controlled to maintain condenser water supply temperature setpoint, reset per Section 5.

### 4. Unoccupied Mode
[State whether plant runs continuously for a campus loop or cycles off; if continuous, state minimum-load/single-chiller operation strategy for unoccupied hours.]

### 5. Reset Logic
**CHWST reset (Trim & Respond), sequenced BEFORE DP reset:** SP0 [42°F] / SPmin [42°F] / SPmax [X°F, e.g., 2°F below lowest served AHU SAT setpoint] / Td [15 min] / T [5 min] / I [1–2 requests] / SPtrim [+1°F] / SPres [−2°F] / SPres-max [−2°F]. Requests generated by [any served AHU CHW valve ≥95% open].

**CHW differential pressure reset (Trim & Respond):** DPmax [design value] / DPmin [as low as ~3 psi at most remote/critical coil] / other T&R parameters [state Td/T/I/trim/respond values].

**Condenser water supply temperature reset:** track ambient wet-bulb and tower capacity; lower CWST as far as tower can sustain to reduce chiller lift, balanced against tower fan energy.

### 6. Safeties and Failure Response
- **Low evaporator water flow:** chiller trips off if flow switch opens for >[X] seconds; reset: [auto after flow restored / manual].
- **Low condenser water flow:** same structure as above.
- **High/low refrigerant pressure, motor overload, etc.:** per chiller manufacturer's onboard protections — BAS monitors and alarms but does not override.
- **Freeze protection (CHW loop):** if any CHW loop temperature sensor reads below [36°F], [initiate glycol-loop alarm / trigger low-temp shutdown] — state project-specific logic if glycol is/isn't used.
- **Actuator/pump fail-safe:** CHW/CW pump VFDs fail to [stop / bypass at fixed speed — confirm with electrical]; isolation valves fail [as specified].

### 7. Alarm Conditions
| Alarm | Trigger | Delay | Severity | Operator action |
|---|---|---|---|---|
| Chiller fault/trip | Any manufacturer fault relay | 0 (instant) | Critical | Dispatch service, verify redundant chiller staged |
| CHW supply temp deviation | >[X°F] from setpoint | [10] min | Major | Check staging, valve leakage |
| Low CHW differential pressure | Below DPmin sustained | [10] min | Major | Check pump staging, valve positions |
| Condenser water high temp | >[X°F] | [10] min | Major | Check tower fan operation |

### 8. Operator-Adjustable Items / Notes / Assumptions
- All T&R parameters (SPmin/SPmax/Td/T/I/trim/respond) adjustable.
- Chiller staging time delay, minimum runtime/off-time between stage changes — adjustable.
- **Assumptions:** [e.g., "Sequence assumes VPF plant with no dedicated primary pumps. If primary-secondary decoupled configuration is furnished, revise Section 3 pump staging accordingly."]

---

## Template 5 — Hot Water Plant

### 1. System Overview
Plant serves [building(s)/campus loop] with [number] boilers, [condensing / non-condensing / hybrid mix], [X] MBH each input, [N+redundancy strategy]. Distribution: [primary-secondary / variable-primary]. [State if steam-to-hot-water heat exchanger is part of the plant, e.g., campus steam system per Section 3.3 of hvac_theory research.]

### 2. Enable/Disable Conditions
Plant enabled when: (schedule = Occupied for any served building OR OAT below a lockout setpoint of [X°F] OR manual override) AND [pumps proven] AND no plant-level safety trip. Individual boilers enabled/staged per Section 3.

### 3. Occupied Mode
- **HW pump(s):** [variable-speed] maintain differential pressure setpoint at [remote/critical coil location] via T&R.
- **Boiler staging:** lead/lag rotation on runtime-equalization basis; stage additional boiler(s) when HWST cannot be maintained within [X°F] of setpoint at current firing rate for [X] minutes.
- **Condensing/non-condensing hybrid sequencing (if applicable):** condensing boiler(s) lead for most of the season; non-condensing unit(s) engage only when return water temperature must exceed [~130–135°F] to meet design HWST — state the exact crossover logic and confirm return-water-temperature sensor location.

### 4. Unoccupied Mode
[State setback strategy: lower HWST setpoint / cycle boilers off with pump minimum-flow bypass / continuous operation for freeze protection of remote coils.]

### 5. Reset Logic
**HWST reset (OA reset schedule) — state as a schedule table, not narrative:**

| OAT | HWST setpoint |
|---|---|
| [design OAT, e.g., 10°F] | [design HWST, e.g., 180°F] |
| [X°F] | [X°F] |
| [warm cutoff OAT, e.g., 60°F] | [minimum HWST, e.g., 120–140°F] |

**Return water temperature constraint:** if condensing boilers are present, confirm the reset schedule actually drives return water below ~[130°F] for a meaningful fraction of the heating season — a schedule that never does so defeats the purpose of specifying condensing equipment.

**HW differential pressure reset (Trim & Respond):** DPmax [design] / DPmin [as low as possible at most remote/critical coil] / [state Td/T/I/trim/respond].

### 6. Safeties and Failure Response
- **Low water flow / low water cutoff:** boiler trips per manufacturer's onboard low-water cutoff; BAS monitors/alarms, does not override.
- **High limit (HWST):** boiler trips above [manufacturer high-limit setpoint]; reset: manual per code (typical for firetube/high-limit safeties).
- **Flame failure / combustion safety:** per boiler's onboard burner management system; BAS monitors/alarms only.
- **Freeze protection:** remote coils served by this loop maintain minimum HW flow/circulation during unoccupied/setback periods per [state strategy].
- **Actuator fail-safe:** HW pump VFDs fail to [stop/bypass]; isolation valves fail [as specified].

### 7. Alarm Conditions
| Alarm | Trigger | Delay | Severity | Operator action |
|---|---|---|---|---|
| Boiler fault/lockout | Any manufacturer fault relay | 0 (instant) | Critical | Dispatch service, verify redundant boiler staged |
| HW supply temp deviation | >[X°F] from reset schedule value | [10] min | Major | Check staging, reset schedule programming |
| Low HW differential pressure | Below DPmin sustained | [10] min | Major | Check pump staging |
| Return water temp too high for condensing operation | >[135°F] for >[X]% of heating season hours (trend-based, not real-time) | N/A (trend review) | Minor/O&M | Review reset schedule, distribution ΔT design |

### 8. Operator-Adjustable Items / Notes / Assumptions
- HWST reset schedule endpoints, boiler staging delay, DP reset bounds — all adjustable.
- **Assumptions:** [e.g., "Sequence assumes all boilers are condensing type. If a hybrid plant is furnished, add non-condensing lead/lag crossover logic per Section 3."]

---

## Template 6 — DOAS (Dedicated Outdoor Air System)

### 1. System Overview
[DOAS tag] delivers 100% outdoor air, dehumidified/conditioned, to [served zones/local units — e.g., "fan coils in dormitory units 101–420"]. Design airflow: [X] cfm (sum of zone Voz requirements, no recirculation credit). Energy recovery: [enthalpy wheel / plate heat exchanger — state type and cross-contamination consideration if serving labs or similar spaces].

### 2. Enable/Disable Conditions
Unit starts when schedule = Occupied OR any served zone/local unit requires ventilation per its own occupancy signal (state coordination logic if DOAS ventilation is tied to local unit occupancy rather than a fixed schedule). Enable also requires smoke/freeze safeties normal.

### 3. Occupied Mode
- **Leaving air dew point control:** maintain leaving dew point at or below [X°F] setpoint via cooling coil modulation — delivery philosophy is "cold, not neutral" (dehumidify to a dew point below space setpoint, then deliver cold; local units handle sensible only). State explicitly if this project instead reheats to neutral, and why.
- **Leaving dry-bulb control:** maintain [neutral / slightly cool] leaving dry-bulb of [X°F], independent of zone-by-zone load variation.
- **Energy recovery:** wheel/plate HX modulates [wheel speed / bypass damper] to maintain leaving air conditions; if enthalpy wheel, state cross-contamination mitigation (purge section) if serving any space with contamination risk — plate HX preferred for labs.

### 4. Unoccupied Mode
[State whether unit runs continuously for ventilation floor maintenance or cycles off; if serving 24/7 occupancy such as dormitories, define minimum continuous ventilation rate rather than a simple on/off schedule.]

### 5. Reset Logic
[If leaving dew point or dry-bulb setpoint resets seasonally or with load, state the schedule/T&R parameters explicitly. Otherwise state "no reset — constant setpoint by design" and justify why.]

### 6. Safeties and Failure Response
- **Freeze protection:** [glycol runaround loop / face-and-bypass damper / preheat coil] engages below [X°F] OAT to protect the energy recovery device and downstream coils; failure action: [state].
- **Frost control on energy recovery wheel:** [defrost cycle / bypass] engages when differential pressure or temperature indicates frost formation risk below [X°F] OAT.
- **High-limit dew point exceedance:** alarm and [stage additional cooling / alarm only] if leaving dew point exceeds setpoint by [X°F] for [X] minutes.

### 7. Alarm Conditions
| Alarm | Trigger | Delay | Severity | Operator action |
|---|---|---|---|---|
| Leaving dew point high | >[X°F] above setpoint | [15] min | Major | Check cooling coil, CHW supply |
| Energy recovery device fault | Wheel not rotating / HX bypass stuck | [5] min | Major | Inspect device, check frost control |
| Fan/coil freeze risk | OAT below [X°F] without freeze protection engaged | 0 (instant) | Critical | Verify freeze protection sequence |

### 8. Operator-Adjustable Items / Notes / Assumptions
- Leaving dew point and dry-bulb setpoints, freeze-protection OAT threshold — adjustable.
- **Assumptions:** [e.g., "Sequence assumes plate heat exchanger energy recovery (no cross-contamination risk). If an enthalpy wheel is furnished for a lab-adjacent application, add purge-section and cross-contamination mitigation language."]

---

## Template 7 — Exhaust / Lab Systems

### 1. System Overview
[Exhaust system tag] serves [lab/room list] via [number] fume hoods and/or general exhaust points, manifolded to [number] rooftop exhaust fan(s). Governed by ANSI/ASSP Z9.5 and ASHRAE 110 for hood performance. Room(s) held at [negative] pressure relative to corridor.

### 2. Enable/Disable Conditions
Exhaust fan(s) run **continuously**, independent of any local switch or schedule — fans have no local on/off switch and do not cycle with occupancy, per life-safety design practice. [State N+1 redundancy/failover logic between manifolded fans if applicable.]

### 3. Occupied Mode
- **Face velocity control (VAV hoods):** maintain [80–120 fpm, target 100 fpm] at the hood face by modulating the exhaust valve/damper in response to sash position sensor or direct face-velocity feedback, with ±[20] fpm allowed deviation across the face.
- **Minimum exhaust volume (sash closed):** never below [25] cfm/ft² of hood work surface, regardless of face velocity control — a hard floor, not a target.
- **Room general ventilation:** maintain [4–10] ACH occupied minimum via general exhaust, separate from fume hood exhaust.
- **Supply/makeup air tracking:** supply airflow tracks total exhaust (hood + general) minus the room offset needed to maintain [negative] pressure relative to corridor; both supply and general exhaust use pressure-independent (flow-tracking) control so the offset holds even as individual hoods modulate.

### 4. Unoccupied Mode
Fans continue running continuously (see Section 2) — face velocity and minimum exhaust floor logic remain active at all times; only the general room ACH minimum may reduce per [state unoccupied setback ACH value if the project allows one — confirm against Z9.5 and the lab's hazard assessment before reducing].

### 5. Reset Logic
No trim-and-respond reset on life-safety exhaust flow. [If the project uses a sash-closure/occupancy-based airflow reduction strategy for energy savings, state its exact logic and confirm it never violates the minimum exhaust volume floor in Section 3.]

### 6. Safeties and Failure Response
- **Low face velocity alarm/interlock:** if face velocity cannot be maintained within tolerance for [X] seconds, alarm at the hood and to BAS; [state whether sash is mechanically/electrically restricted or if it's alarm-only].
- **Exhaust fan failure:** on loss of the lead fan, [lag fan starts automatically / alarm for manual intervention — state redundancy strategy]; never allow all lab exhaust to stop without an immediate critical alarm.
- **Loss of room negative pressure:** alarm if room-to-corridor pressure differential fails to meet setpoint for [X] minutes.
- **Chemical compatibility (manifolded systems):** confirm all branches combined into a shared riser are chemically compatible (below LEL, non-reactive) per Z9.5 — state this as a design/coordination note, not a control sequence item.

### 7. Alarm Conditions
| Alarm | Trigger | Delay | Severity | Operator action |
|---|---|---|---|---|
| Low face velocity | Below [X] fpm | [30] sec | Critical | Life-safety — investigate immediately |
| Exhaust fan failure | Status mismatch | [30] sec | Critical | Verify redundant fan started; dispatch immediately |
| Room pressure loss | Outside setpoint | [5] min | Major | Check dampers, door seals, supply/exhaust balance |
| Sash left open (energy/behavior) | Sash open beyond [X]% for >[X] min unoccupied | [X] min | Minor | Behavioral/energy notice, not safety |

### 8. Operator-Adjustable Items / Notes / Assumptions
- Face velocity target and tolerance band, minimum exhaust floor value, room ACH minimum — adjustable only within Z9.5-compliant ranges; flag any change request that would violate the code minimum.
- **Assumptions:** [e.g., "Sequence assumes VAV fume hoods with sash-position sensors. If constant-volume hoods are furnished instead, remove face-velocity modulation language and confirm fixed exhaust cfm meets both face-velocity and minimum-flow requirements simultaneously."]
