# Common EIKON Logic Patterns (Pseudo-Logic)

These are field-proven patterns expressed as pseudo-logic — adapt exact microblock wiring to the specific job, but keep the structure and reasoning intact. Build each as a custom/nested microblock once proven, so it's reusable rather than re-wired from scratch on the next job.

## 1. Occupancy Arbitration

Multiple occupancy sources often need to be reconciled into one authoritative state: schedule (Time Clock), local override button (sensor), and a network/BMS override.

```
INPUTS:
  sched_state       = Time Clock microblock output (Occupied/Unoccupied/Standby)
  local_override    = BSVI from ZS sensor occupancy button
  network_override   = BACnet Multi-state Value from BMS/central override

LOGIC:
  effective_occupancy =
    IF network_override != "Auto" THEN network_override
    ELSE IF local_override == true THEN "Occupied" (timed, e.g. 2-hr bump)
    ELSE sched_state

OUTPUTS:
  Feed effective_occupancy into every downstream setpoint/staging block —
  never let staging logic read Time Clock directly if an arbitration layer exists.
```

**Why**: without a single arbitration point, different parts of a program can disagree about occupancy state (one block honoring the local override, another still reading raw schedule), producing inconsistent equipment behavior that's hard to diagnose live.

## 2. Setpoint with Deadband

```
INPUTS:
  occ_clg_sp   = 74°F (occupied cooling setpoint)
  occ_htg_sp   = 70°F (occupied heating setpoint)
  unocc_clg_sp = 85°F
  unocc_htg_sp = 60°F
  effective_occupancy (from Occupancy Arbitration pattern above)

LOGIC:
  active_clg_sp = IF effective_occupancy == "Occupied" THEN occ_clg_sp ELSE unocc_clg_sp
  active_htg_sp = IF effective_occupancy == "Occupied" THEN occ_htg_sp ELSE unocc_htg_sp
  -- enforce minimum deadband so heating/cooling setpoints never collide:
  IF (active_clg_sp - active_htg_sp) < 2°F THEN
      active_clg_sp = active_htg_sp + 2°F

OUTPUTS:
  active_clg_sp, active_htg_sp -> PID loops / staging logic
```

**Why**: a minimum deadband (commonly 2–4°F) prevents short-cycling between heating and cooling when setpoints are set too close together, whether by design error or an operator override.

## 3. Staging (e.g., 3-Stage DX Cooling)

```
INPUTS:
  cooling_demand = PID output, 0-100%
  min_stage_runtime = 3 min (anti-short-cycle)
  min_off_time      = 2 min

LOGIC:
  stage_1_enable = cooling_demand > 30%  (with min_off_time honored since last stage-1 disable)
  stage_2_enable = cooling_demand > 60%  AND stage_1_enable == true
  stage_3_enable = cooling_demand > 85%  AND stage_2_enable == true
  -- de-stage on the way down with a lower threshold than the stage-up point (hysteresis):
  stage_3_disable = cooling_demand < 75%
  stage_2_disable = cooling_demand < 45%
  stage_1_disable = cooling_demand < 15%

OUTPUTS:
  BO_stage1, BO_stage2, BO_stage3 (each respecting min_stage_runtime / min_off_time timers)
```

**Why**: staged equipment needs hysteresis (different up/down thresholds) and minimum run/off timers to prevent compressor short-cycling — a frequent omission in first-draft logic.

## 4. Reset Logic (e.g., Discharge Air Temp Reset on Zone Demand)

```
INPUTS:
  zone_clg_demands[] = cooling PID outputs from all zones served by this AHU
  dat_sp_min = 55°F
  dat_sp_max = 65°F

LOGIC:
  max_zone_demand = MAX(zone_clg_demands[])
  -- reset colder (toward min) as demand rises, warmer (toward max) as demand falls:
  dat_setpoint = dat_sp_max - (max_zone_demand / 100) * (dat_sp_max - dat_sp_min)

OUTPUTS:
  dat_setpoint -> AHU discharge air PID
```

**Why**: resets driven by the worst-case (max) zone demand keep the AHU from over-cooling every zone to satisfy the single most demanding zone, while still meeting that zone's need — a standard energy-saving pattern. Same structure applies to duct static pressure reset (reset from most-open VAV damper) and hot water/chilled water supply temp reset.

## 5. Safety Interlocks

```
INPUTS:
  freezestat_trip = BI (normally closed, opens on trip)
  smoke_detector   = BI (from fire system interlock)
  filter_dp_high   = BI or AI threshold
  fan_status       = BI (proof of fan run)

LOGIC:
  safety_shutdown = (freezestat_trip == true) OR (smoke_detector == true)
  -- freeze/smoke conditions immediately force outputs regardless of any other logic:
  IF safety_shutdown == true THEN
      force AO_heating_valve = 100% (fail-safe open on freeze)
      force AO_cooling_valve = 0%
      force BO_supply_fan = OFF
      force BO_outdoor_air_damper = CLOSED
      raise Alarm microblock: "SAFETY SHUTDOWN - [freezestat|smoke]"
  IF filter_dp_high == true THEN
      raise Alarm microblock: "FILTER HIGH DP - MAINTENANCE REQUIRED" (non-shutdown, informational)
  IF (BO_supply_fan == ON) AND (fan_status == false, after 60s delay) THEN
      raise Alarm microblock: "FAN FAILURE - NO STATUS PROOF"

OUTPUTS:
  All safety-forced outputs must override staging/setpoint logic — wire safety
  interlocks so they take priority downstream of, not upstream of, normal control
  outputs (i.e., safety logic should be the last thing that touches an output
  before it leaves the program).
```

**Why**: safety interlocks belong closest to the OUTPUTS stage so nothing downstream can override them. A common review finding is a freezestat wired into the middle of a logic tree where a later staging block can still command an output that contradicts the safety condition.

## General Notes on Applying These Patterns

- Wrap each pattern as a **custom/nested microblock** once validated on one piece of equipment, then reuse it — this is the core of the "scalable, readable, serviceable" philosophy.
- Every pattern above should feed into or be fed by a **Trend** microblock on its key value (demand, active setpoint, stage count) so post-commissioning FDD/analysis has data to work with.
- Every safety pattern must pair with an **Alarm** microblock — a safety interlock with no alarm silently protects equipment but never tells anyone it happened.
