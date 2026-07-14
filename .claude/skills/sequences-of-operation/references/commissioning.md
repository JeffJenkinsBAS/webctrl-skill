# Commissioning Support — Functional Testing, Trend Verification, Deficiencies

Reference for turning a completed SOO into commissioning deliverables: functional test scripts, point-to-point checklists, trend-based verification, and deficiency tracking. Aligns with the ASHRAE commissioning process framework (Guideline 0 / Standard 202) of **Communication, Documentation, Verification** ([Utah.gov Principles of Building Commissioning](https://www.utah.gov/pmn/files/1040363.pdf); [ASHRAE Commissioning bookstore](https://www.ashrae.org/technical-resources/bookstore/commissioning)).

## 1. Where Commissioning Fits in the Project Sequence

OPR (pre-design) → Basis of Design → Division 23/25 specs (often citing Guideline 36 sections directly) → BAS submittals/BTL PICS review → installation → **point-to-point verification** → **Functional Performance Testing (FPT)** exercising the SOO's built-in override/test-mode hooks → Commissioning Report → Systems Manual/O&M turnover ([ASHRAE practical sequence, per Guideline 0/Standard 202](https://cxplanner.com/commissioning-101/ashrae-guideline-0)). A sequence that omits override/test-mode capability (see SOO review checklist Section 2.9) creates a commissioning gap discovered too late to fix cheaply — catch it at the SOO review stage, not at FPT.

## 2. Functional Test Script — Full Structure and Examples

Use the eight fields from SKILL.md Section 5.1 for every test. Below are worked examples by system type; adapt values to the actual project sequence.

### 2.1 Example — AHU economizer changeover (from cooling-only sequence)

1. **Test ID:** FT-AHU3-01
2. **Title:** Economizer changeover, free-cooling to mechanical cooling lockout
3. **Prerequisites:** AHU-3 running in Occupied mode ≥10 minutes; OAT between 55–70°F at test time (forcing OAT is acceptable if the BAS point supports override without disabling the physical sensor permanently).
4. **Procedure:**
   - Step 1: Confirm OA damper is modulating for economizer cooling (observe OA damper position >minimum, mechanical cooling valve at or near 0%).
   - Step 2: Force the OAT point above the economizer high-limit setpoint (e.g., 75°F if high-limit is 70°F).
   - Step 3: Observe OA damper response. *Expected:* OA damper drives to minimum position within 3 minutes of the forced value being read by the controller.
   - Step 4: Confirm mechanical cooling stages on if a cooling call is still present with OA damper at minimum. *Expected:* CHW valve modulates open within 5 minutes if SAT is above setpoint.
   - Step 5: Remove the OAT force. *Expected:* system returns to normal economizer logic within one scan cycle.
5. **Acceptance criteria:** OA damper reaches minimum position within 3 minutes of high-limit exceedance; SAT recovers to setpoint ±1°F within 10 minutes of mechanical cooling engaging.
6. **Points to trend/observe:** OAT (actual and forced), OA damper command/feedback, CHW valve command, SAT, mixed-air temperature.
7. **Pass/Fail/Deficiency:** [recorded with date, tester initials, trend export reference]
8. **Restore to normal:** Remove all forces; confirm OAT point reads live sensor value; confirm OA damper and CHW valve respond to actual conditions before closing out the test.

### 2.2 Example — VAV box functional test (reheat, per G36 or conventional cascade)

1. **Test ID:** FT-VAV301-01
2. **Title:** Cooling-to-heating cascade and minimum airflow verification
3. **Prerequisites:** AHU serving the box is running; box under normal (non-forced) automatic control at test start.
4. **Procedure:**
   - Step 1: Record current zone temp, airflow setpoint, damper position, reheat valve position.
   - Step 2: Lower the zone cooling setpoint temporarily (or raise zone temp reading via force) to drive a full cooling call. *Expected:* airflow setpoint ramps toward Vcool-max; damper position feedback tracks commanded position within [5]%.
   - Step 3: Restore zone setpoint/reading; allow to settle in deadband. *Expected:* airflow returns to Vmin; reheat valve at 0%.
   - Step 4: Force zone temp reading below heating setpoint. *Expected:* airflow setpoint holds at Vmin (or box heating minimum); reheat valve modulates open; discharge air temp rises toward calculated setpoint, capped at the stated maximum discharge temperature limit.
   - Step 5: Verify discharge air temp does not exceed the stated maximum limit even with a sustained heating call.
5. **Acceptance criteria:** airflow tracks commanded setpoint within [5]% at all three stages; discharge air temp never exceeds the stated maximum limit; box returns to automatic control cleanly after force removal.
6. **Points to trend/observe:** zone temp, airflow setpoint/feedback, damper position command/feedback, reheat valve command, discharge air temp.
7. **Pass/Fail/Deficiency:** [recorded]
8. **Restore to normal:** remove all forces; confirm zone temp reads live sensor value; confirm box resumes normal cascade control.

### 2.3 Example — Chiller plant staging test

1. **Test ID:** FT-CHWPLANT-01
2. **Title:** Chiller staging on rising load (lead/lag sequencing)
3. **Prerequisites:** Plant running with one chiller online, system load below the single-chiller staging threshold at test start.
4. **Procedure:**
   - Step 1: Record current CHWST, CHW plant reset %, active chiller PLR/lift-derived staging value.
   - Step 2: Simulate rising load (open additional AHU CHW valves, or force the plant reset signal toward 100%) to drive the staging point above SPLR.
   - Step 3: Observe: lag chiller start sequence begins (condenser/evaporator flow proving, then compressor start) within the sequence's stated staging time delay.
   - Step 4: Confirm no short-cycling — lag chiller should not stage off again within the minimum runtime.
5. **Acceptance criteria:** second chiller stages on within the stated time delay after crossing SPLR; both chillers share load per the plant's staging logic; CHWST recovers to setpoint within [X] minutes.
6. **Points to trend/observe:** CHWST, CHW plant reset %, both chillers' run status/PLR, CWRT.
7. **Pass/Fail/Deficiency:** [recorded]
8. **Restore to normal:** remove any forced load simulation; allow plant to destage naturally per its own logic (do not manually force chiller off — verify the destaging sequence works too, as a separate test).

## 3. Point-to-Point Checklist

Complete before functional testing. Every hardwired point gets its own row:

| Point name (matches point list) | Type | Device/panel | Expected range/state | Field-verified value | Pass/Fail | Tech / date |
|---|---|---|---|---|---|---|
| AHU3-SAT | AI | AHU-3 field panel | 40–90°F typical range | | | |
| AHU3-SF-STATUS | BI | AHU-3 field panel | On/Off, matches command | | | |
| AHU3-OA-DPR-CMD | AO | AHU-3 field panel | 0–100% | | | |
| VAV301-DPR-FB | AI | VAV-301 controller | 0–100%, tracks command | | | |
| CH1-CHWST | AI | Chiller panel/BAS gateway | 38–48°F typical | | | |

**Verification method for each row:**
- **AI (analog input):** compare a known reference (calibrated thermometer, manometer, multimeter) against the BAS-displayed value; confirm within sensor accuracy tolerance.
- **AO (analog output):** command a test value from the BAS graphic; physically observe the actuator/valve/damper move to the commanded position; confirm feedback (if present) matches.
- **BI (binary input):** physically toggle the field device/switch; confirm BAS status changes within one scan cycle.
- **BO (binary output):** command on/off from the BAS graphic; physically confirm the relay/starter/device responds.

A point-to-point failure caught here is a wiring/configuration issue with a clear root cause. A point-to-point failure discovered mid-functional-test is a wasted test cycle — always complete point-to-point first.

## 4. Trend-Based Verification

Some sequence behaviors can't be fully verified through a single-visit functional test (they require observing behavior over hours/days/a season). Use trend logs for:

- **SAT/duct static pressure trim-and-respond behavior:** trend the setpoint itself (not just the process value) over several days of varying occupancy/load. *Expected pattern:* setpoint should visibly trim down during low-demand periods and respond up during high-demand periods, oscillating within the SPmin/SPmax band — a setpoint that never moves indicates T&R logic is not actually running (a common finding when the point is present in the program but the reset block isn't properly wired to real zone requests).
- **Optimum start performance:** trend space temperature approach to occupied setpoint relative to scheduled occupancy time across multiple days/seasons; the lead time should adapt with OAT and observed thermal response, not run a fixed lead time year-round.
- **Chiller/boiler staging behavior:** trend run status of all lead/lag equipment over a period spanning several load-driven stage changes; check for short-cycling (a stage change reversing within the stated minimum runtime is a tuning defect).
- **Condensing boiler return water temperature:** trend return water temperature against OAT over a full week in shoulder-season weather; if return water rarely drops below ~130°F, the reset schedule or distribution ΔT design is defeating the condensing boiler's efficiency and needs revision — a documented finding, not just a note, since the referenced research indicates a majority of condensing boilers in the field never actually operate in their condensing range ([ENERGY STAR Commercial Boiler Design Guide](https://www.energystar.gov/sites/default/files/asset/document/ENERGY%20STAR%20Commercial%20Boiler%20Design%20Guide.pdf)).
- **PID loop hunting:** trend a control loop's process value and output together at a fast sample rate (seconds, not minutes); a quarter-decay ratio (each oscillation peak ~25% of the prior peak after an upset) indicates healthy tuning; sustained/growing oscillation indicates a tuning or hardware (linkage/actuator) problem — see hunting causes below.
- **G36 request-hours accumulator:** trend cumulative request-hours per zone/device over weeks; chronically high request counts flag an undersized, malfunctioning, or mis-programmed zone or device that needs investigation beyond a simple retune ([California Energy Commission G36 certification guidance](https://www.energy.ca.gov/sites/default/files/2025-07/G36_certification_guidance_ADA.docx)).
- **FDD/alarm suppression tuning:** trend alarm frequency by rule/point during the weeks after go-live; expect several weeks of tuning before nuisance alarm rates settle — budget this time explicitly in the commissioning schedule rather than treating early nuisance alarms as a final-state failure ([ASHRAE Guideline 36 implementation challenges](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20actions/samar_1_2024.pdf)).

**Common causes of loop hunting to check when trend data shows oscillation** ([David Sellers/PECI PID overview](https://www.av8rdas.com/uploads/1/0/3/2/103277290/final_-_pid_paper.pdf)): excessively narrow throttling range/high gain relative to system response speed; interacting loops (e.g., a hunting mixed-air damper disturbing the duct static pressure loop); actuator hysteresis/backlash; velocity limiting (process changing faster than the actuator can physically move); seasonal shift in the "ultimate gain" point requiring retuning between winter/summer or part-load/full-load conditions.

## 5. Common Deficiencies by System Type

Use this list when building a project deficiency list — it captures the failure patterns most frequently found in field commissioning, organized by system.

### 5.1 AHU / airside
- SAT or duct static pressure setpoint never trims — reset block present in program but not receiving real zone request inputs.
- Mixed-air low-limit override fighting the economizer loop, causing hunting (interacting-loop pattern).
- Economizer damper doesn't fully close at high-limit lockout — actuator linkage or end-switch issue.
- Freeze protection response incomplete (fan stops but OA damper doesn't close, or HW valve doesn't open) — usually a missing interlock in the program, not a sequence-writing gap, but should have been caught at SOO review.
- Fan status point wired to a control relay auxiliary contact rather than true current-sensing/differential-pressure proof — gives false "running" status when belt/coupling fails.

### 5.2 VAV terminal units
- Airflow sensor not calibrated against a traverse — box "satisfies" at a cfm reading that doesn't match actual delivered airflow.
- Minimum airflow set at a legacy "30% of cooling max" value rather than calculated Voz — flagged during SOO review, but verify actual programmed value matches the as-issued sequence.
- Reheat valve leaks past 0% command — check via the leaking-valve FDD rule (discharge temp >5°F above AHU SAT with valve at 0% for 15 minutes, fan proven on).
- Damper position feedback point wired backward (0% feedback shown at 100% actual open, or vice versa) — always verify feedback direction during point-to-point, not just presence.

### 5.3 Chiller / hot water plants
- Chiller staging based on load alone (ignoring lift), causing premature or delayed staging relative to actual efficient operating points.
- DP sensor located too close to the plant rather than at the most remote/critical coil, forcing an artificially high DP setpoint and wasting pump energy.
- Condensing boiler operating on a legacy non-condensing reset curve — return water never drops below ~130°F (see Trend-Based Verification above).
- CHWST reset and DP reset sequenced in the wrong order (DP reset acting first) — reduces achievable energy savings versus CHWST-first sequencing.
- Minimum flow bypass valve on a VPF plant not functioning, risking low-ΔT syndrome and chiller nuisance trips at low load.

### 5.4 DOAS / energy recovery
- Energy recovery wheel frost-control/defrost cycle not tuned — nuisance shutdowns or frost damage in cold climates.
- Enthalpy wheel specified/installed on a lab-exhaust-adjacent application without adequate cross-contamination mitigation (purge section) — should have been flagged at SOO review as an implied-but-unlisted risk.
- Leaving dew point control drifting because the "cold, not neutral" delivery philosophy wasn't clearly communicated to local unit controls, causing simultaneous DOAS cooling and local unit reheat.

### 5.5 Lab exhaust
- Face velocity out of the 80–120 fpm band at partial sash positions — sash sensor miscalibration or damper actuator too slow to track fast sash movement.
- Minimum exhaust floor (25 cfm/ft² sash-closed) not actually enforced in the program — damper allowed to close further than the code-required floor.
- Room pressurization offset lost when a single hood's sash is fully closed and its exhaust drops significantly — general exhaust/makeup air not compensating quickly enough.
- No functioning lag-fan failover on a manifolded exhaust system — single point of failure for life-safety exhaust, a Critical-severity deficiency.

## 6. Deficiency List — Practical Use

Use the table format from SKILL.md Section 5.3. Practical tips:

- Reference the exact sequence section/line (or spec section number) for every deficiency — "SOO Section 3, Occupied Mode" not "the sequence."
- Tie every deficiency, where possible, to a specific failed acceptance criterion from a functional test script (Section 2 above) — this creates a clean audit trail from OPR → sequence → test → deficiency → retest.
- Retest and close out Critical and Major deficiencies before occupancy/turnover; Minor deficiencies may be tracked into the warranty period but should still be assigned a responsible party and target date, not left open indefinitely.
- Feed recurring deficiency patterns (e.g., "reheat valves leaking on X% of VAV boxes") back into future SOO templates and review checklists — commissioning findings should improve the next project's sequence, not just close out the current one.
