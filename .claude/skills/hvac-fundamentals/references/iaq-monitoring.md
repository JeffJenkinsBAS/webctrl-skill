# IAQ Monitoring — Dehumidification, CO2 DCV, CO/NO2 Detection, Sensor Calibration

Reference for indoor air quality control strategies and the sensor hardware/calibration practices behind them. Read when specifying, programming, or troubleshooting DCV, garage/parking gas detection, or humidity control.

## 1. Understanding Dehumidification

Latent load is the portion of cooling coil load spent removing moisture rather than dropping dry-bulb temperature. It comes from occupants (respiration/perspiration), outdoor-air infiltration and ventilation, and process/kitchen moisture sources. In most commercial buildings, latent load runs **roughly 20–30% of total building cooling load** — higher in high-occupancy-density or humid-climate spaces (see hvac-fundamentals SKILL.md SHR table: auditoriums/gyms 0.45–0.65 SHR vs. 0.75–0.85 for typical office/classroom).

**Sensible Heat Ratio (SHR)** is the ratio of sensible to total heat removed. A lower SHR means the space has higher latent gains relative to sensible — this is the number that tells you whether a standard coil selection is adequate or whether the space needs dedicated dehumidification.

**Traditional (cooling-coil) dehumidification process** — cool air below its dew point over a chilled-water or DX coil to force moisture to condense out, then reheat if the resulting dry-bulb is too cold for the space:

1. **Air intake** — mixed OA/RA enters the AHU.
2. **Filtering** — particulate removal upstream of the coil.
3. **Chilled water coil** — coil surface temperature driven below the entering air's dew point.
4. **Condensation** — moisture condenses on the coil surface as the air is cooled past saturation.
5. **Drainage** — condensate collects in the drain pan and leaves via trapped drain piping.
6. **Supply air** — resulting air is cool and dry; reheat (if present) brings dry-bulb back up without changing humidity ratio.
7. **Distribution** — delivered to zones via VAV boxes/diffusers.

**Alternative dehumidification approaches** (specify these when the cooling-coil-only method can't hit both a dry-bulb and dew-point target simultaneously, or when reheat energy waste is unacceptable):
- **Desiccant dehumidification** — moisture removed via a desiccant wheel/material rather than by over-cooling; decouples latent removal from sensible cooling.
- **Dual-wheel systems** — separate energy recovery and desiccant wheels in series.
- **Wrap-around heat pipes/coils** — pre-cool air ahead of the cooling coil and reheat it after, using the same refrigerant loop passively — reduces the mechanical reheat energy penalty of the traditional method.
- **Decoupled sensible/latent systems** — a DOAS handles latent load (ventilation air delivered at low dew point, "cold not neutral" — see `references/airside-systems.md`) while a separate sensible-only system (chilled beams, VRF) handles the space sensible load.

**Field tie-in**: if a space is chronically "cold and clammy" (dry-bulb at setpoint but RH high), suspect the coil isn't running cold/long enough to hit dew point, or reheat is masking a sensible-only response to what's actually a latent problem — check coil leaving-air dew point on trend, not just SAT.

## 2. CO2-Based Demand-Controlled Ventilation (DCV)

Two field-proven CO2 DCV strategies. Pick based on project type, not habit.

### 2.1 Method 1 — Static CO2 Setpoint (default recommendation)
Maintain a single fixed indoor CO2 setpoint (commonly **1,000 ppm**, consistent with `references/airside-systems.md`'s 1,000–1,100 ppm range).
- **Pros**: simple to program and commission; single sensor per zone (no OA reference sensor needed); technicians and operators understand a single number.
- **Cons**: doesn't account for varying outdoor CO2 background (rural ~400 ppm vs. urban/industrial areas running higher); can slightly over- or under-ventilate relative to true per-occupant CFM if outdoor background drifts from assumption.
- **Recommended default for most commercial and industrial projects** — the simplicity and commissioning reliability outweigh the marginal accuracy loss.

### 2.2 Method 2 — Differential CO2 (indoor minus outdoor)
Ventilate to hold indoor CO2 within a **delta above outdoor CO2** (commonly **Δ600 ppm** indoor-minus-outdoor) rather than an absolute indoor number.
- **Pros**: more accurate representation of actual occupant-generated CO2 load; adapts automatically if outdoor background CO2 changes (increasingly relevant as urban outdoor CO2 levels drift upward over time).
- **Cons**: requires a second sensor (outdoor CO2 reference), added cost/maintenance/calibration burden, added failure mode (if the OA sensor fails, the whole DCV loop is compromised, not just one zone).
- **Reserve for**: LEED/WELL-certified projects, or specialized IAQ-sensitive applications where the certification or owner's project requirements specifically call for differential measurement — not a default choice.

### 2.3 Field Considerations (both methods)
- **Sensor placement**: representative of breathing-zone air, away from doors/diffusers/windows that create local dilution, away from direct occupant breath sources.
- **Calibration**: see Section 4 below — CO2 sensors drift and require a maintained calibration program regardless of which DCV method is used.
- **Failure mode**: per ASHRAE 90.1/62.1 requirements (see `ashrae-standards` skill), CO2 sensor failure must default the zone to its design ventilation rate — never fail low/toward reduced ventilation.

## 3. Carbon Monoxide (CO) and Nitrogen Dioxide (NO2) Monitoring

Applies to parking garages, loading docks, and any enclosed space with combustion-engine exhaust exposure. These are life-safety gas detection sequences, not comfort DCV — treat alarm setpoints as non-negotiable code/safety values, not tunable comfort parameters.

### 3.1 Carbon Monoxide (CO)
| Parameter | Value |
|---|---|
| Ambient limit (working day, 8-hr exposure) | 25 ppm |
| Exhaust source limit | 20 ppm |
| Short-term limit | 35 ppm |
| Pre-warning alarm | 25 ppm |
| Critical alarm | 35 ppm — fans commanded to full speed above this threshold |
| Mounting height | 1.5–1.8 m (breathing height) |
| Density note | CO density ≈ air density — drafts and airflow patterns matter for sensor placement, no strong stratification to rely on |
| Detector density | 1 detector per 400 m² of garage area |
| Garage-specific density | 25 m² per car plus coverage of all driving surfaces |

### 3.2 Nitrogen Dioxide (NO2)
| Parameter | Value |
|---|---|
| Pre-warning (emissions-driven) | 1 ppm |
| No-exhaust condition limit | 2 ppm |
| Critical alarm | 5 ppm |
| Alarm response — 1 ppm | Fans to half speed |
| Alarm response — 5 ppm | Fans to full speed |
| Mounting height | ~20 cm above floor — NO2 is heavier than air and stratifies low |
| Detector density | 1 detector per 400 m² |

**Sequence design note**: because CO mounts at breathing height and NO2 mounts near the floor, a single garage ventilation sequence typically monitors both gases independently and drives fan speed off whichever gas's alarm tier is currently more severe — don't average the two readings into one fan-speed signal.

## 4. CO2 Sensor Testing & Calibration

### 4.1 Why Calibration Matters — the CFM/Occupant Consequence
Code compliance for typical office ventilation runs around **20 CFM/person**. At a 400 ppm ambient/outdoor baseline, a properly calibrated CO2 DCV setpoint of ~930 ppm corresponds to roughly that 20 CFM/person design ventilation rate.

Sensor drift has a direct, quantifiable ventilation consequence:
- Sensor reading **200 ppm low** → system thinks the space needs less air than it does → delivers only **~15 CFM/person**, roughly **25% ventilation-deficient**.
- Sensor reading **200 ppm high** → system over-ventilates → delivers **~32 CFM/person**, roughly **60% excess airflow** and the associated fan/heating/cooling energy waste.

A 200 ppm sensor error is not a rounding issue — it's a code-compliance and energy problem in either direction. This is why a maintained CO2 sensor calibration program is a real commissioning/O&M line item, not a "nice to have."

### 4.2 Field Verification Method
1. Use a **calibrated portable reference instrument** — one that is itself periodically calibrated against certified calibration gas.
2. Bring the reference instrument to the same breathing-zone location as the installed sensor.
3. **Allow the reading to stabilize for less than 1 minute** before comparing.
4. **Avoid breathing near the sensor** during the check — exhaled breath is >35,000 ppm CO2 and will spike the reading, giving a false comparison.
5. Compare reference vs. installed sensor reading; if outside tolerance (see Section 4.3), flag for recalibration or offset correction.

### 4.3 ALC ZS2P-C-ALC Sensor Specifics
| Parameter | Value |
|---|---|
| Accuracy, 400–1,250 ppm range | ±30 ppm or 3% of reading, whichever is greater |
| Accuracy, 1,250–2,000 ppm range | ±5% of reading + 30 ppm |
| Warranty | 24 months |
| Factory calibration | Yes — ZS sensors ship factory-calibrated |
| Field recalibration options | (1) Return the sensor to the factory for calibration, or (2) apply a control-program offset to correct a known drift without physically recalibrating |

### 4.4 Critical Installation & Calibration Warnings
- **Do NOT install ZS CO2 sensors in continuous-occupancy applications.** The sensor relies on periodic exposure to outdoor-background CO2 levels to self-calibrate — a space that is never unoccupied never gives it that reference point.
- **The zone must be unoccupied for ≥4 hours per day with air movement** so CO2 can return to background level — this is a prerequisite for the automatic calibration described below, not an optional nicety.
- **Automatic Background Calibration**: the sensor watches for the lowest 24-hour CO2 value; if that value is stable (within ±40 ppm deviation for 15+ minutes), it assigns that reading a **400 ppm baseline**. This process **may take up to 21 days** to fully calibrate a newly installed or disturbed sensor.
- **Power-up settling time**: the sensor needs **1 hour of power-up time** before its readings can be trusted as accurate — don't calibrate or commission-test immediately after energizing.
- **Physical shock**: dropping the sensor can upset its internal calibration, potentially requiring the full 21-day background recalibration cycle to recover — handle ZS sensors as carefully as any precision instrument during installation, not as a commodity thermostat.

**Commissioning implication**: schedule CO2 DCV functional testing and final trend verification at least 21 days after sensor installation/power-up, not on install day — testing before the background calibration cycle completes will show inaccurate readings that aren't a sensor defect, just an uncalibrated one.
