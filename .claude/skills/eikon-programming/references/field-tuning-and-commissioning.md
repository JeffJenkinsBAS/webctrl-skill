# Field PID Tuning, Offset vs. Calibration, and Commissioning-Time Logic Checks

Read this when tuning a PID loop in the field, deciding whether to apply a sensor offset, simplifying a written Sequence of Operations before programming/commissioning against it, or running the Logic-page checks that accompany Cx Step 5 (Sequence of Operations verification — see `field-commissioning` skill for the full 5-step workflow this feeds into).

## Offset vs. Calibration — They Are Not the Same Thing

A **static offset** is not a calibration. It is a one-point correction that makes everything else worse.

**Example:** a room is actually 69.6°F but the sensor shows 72.5°F. Inputting a −2.9°F offset only fixes the reading at that single moment/temperature. Thermistors are nonlinear, so a fixed offset just shifts the whole curve — every other point on the range is now wrong, and the error can even reverse direction as the real temperature diverges from the point where the offset was set.

**Root cause to check first:** air infiltration behind the sensor. Sensors on exterior walls, unsealed sheetrock, or poorly insulated boxes get biased by warm air (winter, from vertical chases) or cold air (summer, from super-cooled return air) leaking behind the plate. This is a different micro-environment at the sensor, not sensor failure — applying an offset masks the actual airflow problem, and drift continues as weather/static pressure change.

**Correct approach — diagnose before adjusting:**
1. Temporarily remove the sensor and check the backplate temperature vs. the room temperature.
2. If it differs significantly, seal the wall penetration, add foam gasket pads/insulation, or relocate the sensor — flag this to the mechanical contractor/commissioning agent if it's outside your scope to fix.
3. Only after verifying sensor type, wiring, airflow, and installation should an offset even be considered — and only as an absolute last resort for a minor, permanent, unavoidable bias.

**In EIKON:** the I/O Points page **Offset** field allows fine calibration of an analog point's present value — but treat it as a true calibration correction (validated against a reference instrument across the sensor's actual operating range), never as a quick fix for a bad reading at one point in time. During point-to-point checkout, **all devices must be calibrated with a meter of some type** before any offset is applied — a temp gun in the space is the standard field check, verifying present value accuracy within **±2°F**.

This same discipline applies to CO2 sensors: the ZS2P-C-ALC is factory calibrated, and the only correction options are returning the sensor for calibration or using the control-program offset to better match a calibrated reference instrument — never treat an offset as a substitute for actually diagnosing a placement or installation problem.

## Field PID Tuning Standard

**Startup/checkout starting values: P = 2, I = 1, D = 0, Interval 20 seconds** — then tune from there for the specific loop.

**Default (untuned) PID values: P = 20, I = 5, D = 0.** At these defaults, the output is essentially open/close (0% → 100% → 0%) with little to no real modulation — an untuned PID is easy to spot from this bang-bang-like behavior alone. **Tune every PID in every program** before turnover to avoid problems and comfort complaints later; never leave a loop at default values.

| Parameter | Field starting point | Untuned default | Effect |
|---|---|---|---|
| P (Proportional) | 2 | 20 | Strength of response to present error — lower P is gentler, higher P is more aggressive/prone to overshoot |
| I (Integral) | 1 | 5 | How quickly accumulated past error is corrected — eliminates steady-state error from friction/small leaks |
| D (Derivative) | 0 | 0 | Anticipates rate-of-change; in BAS typically left at 0 — only P and I are tuned in the large majority of loops |
| Interval | 20 sec | — | Refresh/sample time for the loop |

### PID Concepts (brief)

- **Proportional (P):** responds to the present error (setpoint − measured value), multiplied by a gain constant. Higher gain = stronger response.
- **Integral (I):** accounts for accumulated past error over time, eliminating steady-state error. Higher I gives more aggressive correction of lingering error.
- **Derivative (D):** anticipates future error from the rate of change of error. Rarely needed in BAS loops — P and I alone cover the large majority of situations; escalate to the Engineering Department for the rare case that genuinely needs D.

### Tuning Procedure (target: stable control, no overshoot)

1. **Disable Derivative** — set D to zero to isolate P and I tuning.
2. **Increase Proportional gain** gradually while watching the process variable (PV), until you see a slight response in the output due to a PV change, then **reduce that gain value by 50%**.
3. **Enable Integral control** — set a reasonable initial I (e.g., 0.5) to eliminate steady-state error. Double the value incrementally until oscillation occurs, then **cut the integral by 50%**.
4. **Fine-tune** — make small adjustments to P and I until you achieve smooth control without overshooting setpoint.
5. **Test under different conditions** — varying loads, setpoint changes, and disturbances, to verify stability and reliability across the loop's real operating range.

**Tuning is iterative** — change one parameter at a time and observe the response before making another change.

### Quick vs. Slow Process Variables

- **Fast-changing PV** (e.g., discharge air temp, duct static): start with a **low gain**, possibly as low as 0.1, and adjust Reset between **1 and 10 repeats per minute**.
- **Slow-changing PV** (e.g., zone temp, loop water temp): start with **higher gain** (2–8) and **lower reset** (0.05–0.5). Adjust one parameter at a time and observe until stable.

**Bottom line:** in most cases P and I alone are sufficient — fine-tuning those two covers nearly every BAS loop. Always know the measurement type of the process variable, and tune P and I incrementally rather than guessing at final values.

## Sequence of Operations (SoO) Simplification

Convoluted written SoOs slow down both programming and commissioning. Use this 7-step method to turn a dense paragraph-style SoO into something you can actually program and verify against:

1. **Read it once without stressing** — first pass just to grasp the equipment involved, general intended behavior, and on/off/modulate timing.
2. **Break into logical chunks:** Start-up/Initialization; Occupied vs. Unoccupied; Normal Operation; Setpoint Control; Economizer/Free Cooling (if applicable); Safety and Fault Modes; Shutdown.
3. **Highlight Inputs, Outputs, Conditions.** Example transformation:
   - Original: *"The supply fan shall operate when the system schedule is occupied and the mixed air temperature is below 80°F and the fire alarm is not active."*
   - Simplified: *"Fan ON if: Schedule = Occupied; Mixed air temp < 80°F; Fire alarm NOT active."*
4. **Create a flowchart/step list**, e.g.: (1) Is system in occupied mode? (2) Is there a call for cooling? (3) Is outside air suitable for economizing? (4) Modulate dampers or turn on chiller. (5) Maintain space temp at setpoint. (6) Shut down if alarm/fault.
5. **Cross out fluff/fancy wording** — reword in your own language:
   - *"Utilize integrated economizer logic based on differential enthalpy"* → *"Use free cooling if outside air is cooler and dryer than return air."*
   - *"Terminate operation of associated components during unoccupied periods unless overridden by schedule exception"* → *"Turn it off after hours unless someone manually overrides it."*
6. **Match what you read to what you see** — walk the system, verify sensors/safeties/sequences match the graphics/field, and flag mismatches to the PM and PE.
7. **Write a 1-page "Tech Summary"** in your own words for use during startup/troubleshooting; share with other technicians or the building operator. Example: *"AHU-1 Summary: Starts when building is occupied and no faults exist. Uses free cooling if outdoor air < 65°F. Otherwise, uses chilled water valve to hit 55°F supply air setpoint. Fan runs at 60% minimum, modulates based on VAV demand. Shuts down if fire alarm or high static pressure occurs."*

**Extra tips:**
- Use highlighters/color-coding per mode (green = normal, red = faults).
- Ask the Project Engineer to walk through the logic — programming may differ from the written SoO, since SoOs are open to interpretation; always ask rather than assume.
- Keep a "lessons learned" binder of simplified summaries for reuse on similar equipment.
- SoOs originate from the mechanical design engineer and are carried into controls submittals by ACI Engineers for reference; they're also in the M sheets of project drawings.
- Design/SoO questions should go through the PM and PE **before** discussion with a third-party Cx agent, who may escalate to the design engineer if needed.

## Logic-Page Commissioning Checks

These are the specific things to watch on the live **Logic** tab while verifying that a program matches its SoO (Cx Step 5) — treat this as the EIKON-side companion to Live GFB debugging (see `references/debugging-live-logic.md`) but oriented at first-time verification rather than bug-hunting.

**General approach:** watch the live Logic page to confirm the program does what the SoO requires. You may need to lock values to force program behavior for testing — **track every parameter/delay you change** to speed up testing, and revert them afterward. There is a **Locked Values report** to catch forgotten locks, but **no report exists** for forgotten delay-timer/temporary-parameter changes — this has to be tracked manually.

**Requests and Run Conditions:**
- Verify request/total/min-max blocks at the top of programming correctly pull values from "children" modules (see Source Trees in `webctrl-platform` — e.g., AHUs are "parents" to VAVs but "children" to the Chiller/Boiler plant).
- Verify run-equipment blocks: a run command should follow from sufficient requests; during unoccupied hours, a minimum number of requests should be required before the system runs.
- The **Run Cmnd BV microblock** should show ON when conditions are met.
- **Loop freeze protection test:** with the system not running, lock the outside air temp (true point) to **30°F** to force pumps into freeze protection mode. Locking the OA Temp network block is a standard technique for testing any logic affected by varying OA temp.
- Inside the OA Temp microblock, verify correct mapping and that incoming OA Temp is valid.

**Loop Monitor:** verify loop supply temp reads correctly and threshold blocks have correct trigger values for alarming; repeat the same check for loop return temp.

**VFD Pressure Control:** typically a differential pressure (DP) sensor controls drive speed. Verify DP reading accuracy and PID function using the field tuning standard above (start P=2/I=1/D=0, 20-second interval).

**Lead/Standby vs. Lead/Lag — verify which one is actually implemented:**
- **Lead/Standby:** two redundant units for extended lifecycle/safety — only one runs to maintain setpoint/minimum flow; rotates on a schedule; if the lead fails, standby starts and runs as lag.
- **Lead/Lag:** one or more units run depending on demand — the system starts with one unit running, but engages a second unit as lag when demand/DP/flow requires additional capacity.
- **Design engineers frequently mislabel a lead/standby design as "lead/lag."** This distinction matters for commissioning — know it and be able to explain it to the PM/PE/Cx agent.
- Rotation method selectors typically offer **Daily, Weekly, Monthly, Manual**, plus **Runtime** (most popular). Manual rotation still allows a swap on failure but won't rotate until told to.
- **Always check that equipment actually rotates on failure of the lead unit.** Test procedure: (1) place logic in AUTO; (2) turn the lead unit off at the disconnect; (3) confirm the system swaps to the lag/standby unit; (4) verify an alarm is generated for the failure; (5) adjust start/stop logic timing so the building/equipment is maintained during the failure/rotation window.

**Status verification:** confirm programming shows proof of status when equipment is running at minimum (if applicable):
1. Verify the CT (current transducer) is correctly terminated and assigned in the program.
2. Start the monitored equipment via AUTO or by manually locking the start/stop output command (confirm the equipment is ready to start first).
3. If the unit is on a VFD, lock the Speed Output to minimum speed.
4. Check the analog input for amperage reading at the drive/starter; navigate to the "True if > Constant" microblock housing the status threshold and adjust it just below the current amperage reading.

**Temperature sensors:** most temp sensors are **10K ohm @ 77°F thermistor** type — not polarity sensitive, reliable if the correct sensor is on the correct input and the input type is set to thermistor. For duct probe sensors, pull the thermistor from the duct and measure against another measurement source in that space or an infrared temp gun. Verify the sensor label matches its actual function (e.g., confirm a point labeled "Supply Temp" is actually reading supply temp).

**Scope reminder:** startup/commissioning steps are broadly similar across device types, but no single guide covers every device — always reference that specific module's technical instructions from ALC (ALC Portal, office shared drive, or ProCore 4TRAIN > Documents) for terminal-level rules.
