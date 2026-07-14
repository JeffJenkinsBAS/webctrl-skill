# Commissioning Support — Functional Testing, Trend Verification, Deficiencies

Reference for turning a completed SOO into commissioning deliverables: functional test scripts, point-to-point checklists, trend-based verification, and deficiency tracking. Aligns with the ASHRAE commissioning process framework (Guideline 0 / Standard 202) of **Communication, Documentation, Verification** ([Utah.gov Principles of Building Commissioning](https://www.utah.gov/pmn/files/1040363.pdf); [ASHRAE Commissioning bookstore](https://www.ashrae.org/technical-resources/bookstore/commissioning)).

## 1. Where Commissioning Fits in the Project Sequence

OPR (pre-design) → Basis of Design → Division 23/25 specs (often citing Guideline 36 sections directly) → BAS submittals/BTL PICS review → installation → **point-to-point verification** → **Functional Performance Testing (FPT)** exercising the SOO's built-in override/test-mode hooks → Commissioning Report → Systems Manual/O&M turnover ([ASHRAE practical sequence, per Guideline 0/Standard 202](https://cxplanner.com/commissioning-101/ashrae-guideline-0)). A sequence that omits override/test-mode capability (see SOO review checklist Section 2.9) creates a commissioning gap discovered too late to fix cheaply — catch it at the SOO review stage, not at FPT.

### 1.1 The Formal Cx-Authority (CxA) Process Behind This Chain

The chain above is what the field tech and controls contractor execute against — but on any project with a dedicated Commissioning Authority (CxA), that role owns a broader, standards-defined process spanning the full project lifecycle, not just the BAS scope. Understanding the CxA's formal process matters because it tells you what documentation and hooks the CxA will expect from the controls submittal and SOO, before FPT day.

**CxA role, per [ASHRAE Standard 202-2013](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/202_2013_b_20180308.pdf)**: an independent third party responsible for planning, directing, and documenting the commissioning process across all phases — predesign through end of warranty. Minimum CxA activities per Standard 202:
- Initiate the commissioning process
- Facilitate development of the **Owner's Project Requirements (OPR)**
- Develop and maintain the Commissioning (Cx) Plan
- Perform design reviews and submittal reviews
- Develop pre-functional checklists and functional test procedures
- Direct, witness, and document testing
- Maintain an issues/resolution log
- Assemble the systems manual
- Conduct/verify training
- Produce the final Commissioning Report

**Design and submittal reviews**: the CxA reviews design documents against the OPR before construction documents are issued for any commissioned system — this happens *before* the controls submittal is even drafted. Submittal review runs concurrently with (but separately from) the design engineer's own review: the engineer checks code/design compliance, the CxA checks **OPR compliance**. A controls submittal can pass the engineer's review and still get flagged by the CxA if it doesn't demonstrably satisfy the OPR.

**Pre-functional / construction checklists**: a form verifying that materials and components are on-site, correctly installed, functional, and OPR-compliant — developed after submittal approval, executed during installation. This is static/visual/functional confirmation performed *before* dynamic FPT — think of it as the CxA's version of the point-to-point checklist in Section 3 below, verified on a sampling basis rather than 100% (contrast with Automated Controls' internal 100% standard, Section 1.2). Sources: [ASHRAE Standard 202](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/202_2013_b_20180308.pdf), [ASHRAE Guideline 0-2005 Addenda](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/g0_2005_a_b_c_d_final.pdf).

**Functional Performance Testing (FPT)**: dynamic testing exercising the full sequence of operation — normal operating modes, equipment staging, failure modes, alarms, interlocks. FPT is only scheduled once the GC has submitted complete QC documentation (checklists, startup reports, preliminary O&Ms, as-built drawings, preliminary TAB report). The CxA verifies independently and does **not** debug live during the test — a failed FPT step becomes a deficiency (Section 6), not an on-the-spot programming session. Source: [Dartmouth General Commissioning Requirements](https://www.dartmouth.edu/fom/docs/2023_construction_guidelines/01_91_13_general_commissioning_requirements.pdf), [LAWA Division 28 spec](https://www.lawa.org/sites/lawa/files/documents/2017%20Division%2028%20Non-IT.pdf).

**Seasonal, deferred, and warranty-period testing**: CxA activity continues through the end of the warranty period. Standard 202 requires seasonal, delayed, or otherwise incomplete testing to be completed within this window, timed to actual weather/load/occupant-interaction conditions the initial FPT couldn't create on demand (e.g., a heating-mode FPT step that can only be fully validated in winter). Source: [ASHRAE Standard 202](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/202_2013_b_20180308.pdf).

**Ongoing / Retro-Commissioning (RCx) / Monitoring-Based Commissioning (MBCx)**: commissioning doesn't end at warranty close-out on a well-run building. Retro-commissioning follows a planning → investigation → implementation → hand-off cycle on existing buildings. **Continuous Commissioning™** (origin: Texas A&M Energy Systems Laboratory) and **MBCx** leverage the BAS's own trend/alarm infrastructure plus fault-detection-and-diagnostics (FDD) analytics to keep sequences performing as designed long after turnover — this is exactly the kind of ongoing verification the G36 request-hours accumulator and FDD alarm tuning (Section 4/5 below) feed into. Source: [DOE FEMP O&M Best Practices Guide, Ch. 7](https://www1.eere.energy.gov/femp/pdfs/om_7.pdf).

**The governing document set**: **ASHRAE Guideline 0** (generic Cx process applicable to all systems, all phases), **Guideline 1.1** (HVAC&R-specific, evolved from the original Guideline 1-1996), and **Standard 202-2013** (the normative, "shall"-language version defining OPR, Basis of Design (BOD), Cx Plan, design review, submittal review, checklists, testing, and the final Cx Report). Standard 202 also introduces the **Current Facility Requirements (CFR)** concept — the existing-building analog to OPR, used for retro-commissioning and ongoing Cx on buildings that never had a formal OPR at initial construction. Sources: [ASHRAE Bookstore — Commissioning](https://www.ashrae.org/technical-resources/bookstore/commissioning), [Guideline 1-1996 process diagram](https://www.scribd.com/document/498680655/Guideline-1-1996-Commissioning), [ASHRAE Standard 202](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/202_2013_b_20180308.pdf), [HVAC Commissioning Guidelines](https://www.scribd.com/document/599853580/HVAC-Commissioning).

**How this ties back to the controls contractor's SOO**: the CxA's design/submittal review checks the SOO against the OPR before it's even built; the pre-functional checklist parallels (but doesn't replace) the point-to-point checklist in Section 3; FPT scripts should be written so they map directly onto the functional test scripts in Section 2. If a project has a formal CxA, expect the SOO's override/test-mode points (SOO review checklist Section 2.9) to be exercised by someone outside the controls contractor's own team — write them assuming an outside auditor, not just your own commissioning tech, will use them.

### 1.2 Automated Controls' Internal 100% Commissioning Standard

Third-party CxAs commonly sample **10%–30%** of VAV boxes or typical/repetitive equipment during pre-functional and functional checks — a statistically-driven sampling approach that's standard industry practice for a third party covering an entire building's systems (T&B, envelope, life-safety interfaces, and controls all at once).

**Automated Controls' own internal standard is 100%** — every piece of equipment must be touched, every sensor visually inspected and verified or calibrated where applicable, before that equipment is considered ready for third-party Cx. Concretely:
- Every VAV box gets a visual inspection: damper rotation direction, airflow tube connections, discharge sensor placement, valve stroke (full open/full closed observed, not assumed from a BAS graphic reading).
- **Never assume a VAV box is controlling correctly from discharge temperature alone** — a plausible-looking discharge temp can mask a damper that isn't actually modulating, an airflow sensor reading a stale value, or a reheat valve stuck partially open.
- AHU/chiller plant checkout includes verifying wire labels match function, sensor accuracy/placement, and — with top priority — safety devices: **High Static, Low Static, and Freezestat are never locked out and always left fully functional** through the entire commissioning process, even when other points are temporarily forced for testing.

**Why this matters for the third-party CxA relationship**: the 3rd-party Cx agent should **not** be the one finding wiring or calibration issues — those are expected to already be resolved by the internal 100% pass before the CxA ever arrives. Any design or sequence-of-operation *question* (as opposed to an installation defect) should be routed through the PM and PE before it reaches the 3rd-party Cx agent — don't let field-level SOO ambiguity surface for the first time during a formal FPT witnessed by the CxA.

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

## 7. SOO Verification Workflow (Commissioning Step 5) — Field Logic-Page Checks

This is the field-technician-level verification that happens after point-to-point is complete and before the sequence is considered ready for functional testing or a third-party CxA visit. It picks up right where Section 3 (point-to-point) leaves off.

### 7.1 Prerequisites Before Starting
- Panel inspection complete.
- Submittals reviewed and on hand.
- Module powered and downloaded.
- I/O assigned in the database.
- Point-to-point complete (Section 3).
- Points List Report generated and stored with the project record.
- All I/O unlocked (no forced/locked test values left over from point-to-point).

### 7.2 What "Commissioning the Programming" Means
Watch the **live Logic page** side-by-side with the SOO's stated requirements — this is not a paperwork exercise, it's watching real microblock values change in real time against what the sequence says should happen. Specific things to verify:
- Values may need to be temporarily locked during this process — **track every lock and every delay-timer change**. WebCTRL's Locked Values report captures locked points, but **there is no equivalent report for delay-timer changes** — keep your own note of any timer you adjust during commissioning so it can be reverted or intentionally left at the new value with a documented reason.
- Confirm PID loops open and close correctly through their full range, not just that they move in the right direction.
- Confirm alarm blocks and their time delays are actually wired and firing at the stated setpoint, not just present in the program.
- Confirm safeties shut down and interlock correctly — this is the highest-priority check in the whole workflow (see Section 1.2's non-negotiable High Static/Low Static/Freezestat rule).

### 7.3 Logic Page Detailed Checks

**Requests / Run Conditions**: the "Run Cmnd" BV microblock should show **ON** exactly when all stated run conditions are actually met — not most of them, not "close enough." Perform a **loop freeze test**: lock the OA temperature true-point to **30°F** to force the system into freeze-protection mode and confirm every freeze-protection action actually fires (fan stop, OA damper close, HW valve open — per whatever the SOO's Safeties section states) rather than assuming the freezestat logic works because the microblock diagram looks correct.

**Loop Monitor**: verify supply and return temperature thresholds are being evaluated against real, believable values — a loop that "looks stable" on a trend can still be comparing against a stale or mis-scaled threshold.

**VFD Pressure Control** (duct static pressure or hydronic DP loop): verify the DP sensor is feeding a PID block correctly, and check the PID's actual tuning values, not just that the loop is "running":
- **Startup/checkout PID values: P = 2, I = 1, D = 0, Interval = 20 seconds** — then tune further from this starting point once the loop is stable.
- **Warning — the untuned default is P = 20, I = 5, D = 0.** At these values, the loop essentially operates as an open/close bang-bang controller: 0% → 100% → 0%, with no real modulation in between. An untuned PID at these default values is easy to spot on a trend (sawtooth/square-wave output pattern) — if you see that pattern, the loop was never actually tuned, regardless of what the program's PID block claims its mode is.

**Lead/Standby System Test** (cross-reference `hvac-fundamentals` skill's `references/redundancy-and-ddc.md` for the lead/lag vs. lead/standby distinction — get this right before testing):
1. Put the logic in **AUTO**.
2. Turn the lead unit off **at the disconnect** — a true hard failure, not a BAS-commanded stop.
3. Confirm the system swaps to the lag/standby unit.
4. Confirm an alarm is generated for the failure event.
5. Adjust start/stop timing as needed so the building is maintained through the failure/rotation transition without an unacceptable gap in service.

**CT (Current Transducer) Status Setup**: verify the CT is terminated and correctly assigned; start the monitored equipment via AUTO or lock start/stop; if VFD-driven, lock speed to minimum for a stable reading; check the actual AI amperage at the drive/starter; set the "True if > Constant" microblock threshold **just below** the actual current reading observed in the field — not an arbitrary round number.

**Temperature Sensor Note**: most field temperature sensors are **10K ohm @ 77°F thermistors**, not polarity-sensitive. If a duct probe reading looks wrong, pull the thermistor and measure it against a second reference (another sensor or an IR gun) rather than assuming a wiring polarity problem.

### 7.4 Where This Sits Relative to Third-Party Commissioning
This workflow is the **initial commissioning performed by the field tech** — point-to-point plus SOO checks. The 3rd-party Cx agent's visit verifies this work in combination with T&B (test and balance), pump/motor, and envelope data for the whole building. As stated in Section 1.2: the 3rd-party agent should not be finding wiring or calibration issues at this stage — those should already be resolved. Any design or SOO question that surfaces during this workflow goes through the PM and PE before it reaches the 3rd-party Cx agent, not directly into a CxA-witnessed FPT.

## 8. SOO Simplification — The 7-Step Field Technique

Long, dense sequences of operation are hard to hold in your head while troubleshooting live in a mechanical room. Use this technique to convert a wall-of-text SOO into something you can actually work from in the field. This is a distinct skill from *writing* a compliant SOO (Section 1 of SKILL.md) — it's how you *consume* one, whether it's your own or an engineer's submittal.

**Step 1 — Read once, without stress.** Read the entire sequence start to finish with no goal except getting the overall shape of what the system does. Don't take notes yet, don't try to memorize setpoints — just build a mental map of the equipment and its general behavior.

**Step 2 — Break it into chunks.** Re-read and mentally (or physically) divide the sequence into its functional phases:
- Start-up / Initialization
- Occupied / Unoccupied
- Normal Operation
- Setpoint Control
- Economizer / Free Cooling
- Safety / Fault Modes
- Shutdown

Most sequences map cleanly onto this list even if the original document doesn't use these headers — this is the same functional grouping SKILL.md Section 1's mandatory structure enforces when *writing* a sequence, applied here to *decode* one.

**Step 3 — Highlight Inputs, Outputs, and Conditions.** Go chunk by chunk and mark every sensor/input, every commanded output, and every conditional ("if X then Y") statement. Example transformation: a sentence like *"The supply fan shall run continuously during occupied hours provided the freezestat is not tripped and no smoke alarm is active"* becomes:
- **Input**: schedule (occupied/unoccupied), freezestat status, smoke alarm status
- **Output**: supply fan run command
- **Condition**: fan runs IF (occupied) AND (freezestat normal) AND (smoke alarm normal)

**Step 4 — Create a flowchart or step list.** Convert the highlighted inputs/outputs/conditions from Step 3 into a simple flowchart or numbered step list per chunk. You don't need software for this — a hand-sketched flowchart in a field notebook is enough; the goal is a visual you can glance at instead of re-reading paragraphs.

**Step 5 — Cross out the fluff, reword what's left.** Strip filler language and restate each requirement in plain, numeric terms. Examples:
- *"The system shall maintain appropriate comfort conditions as required"* → cross out entirely, or replace with the actual numeric setpoint if one exists elsewhere in the document (and flag it if one doesn't — see SKILL.md Section 2.2 language rules).
- *"The economizer shall operate when conditions are favorable"* → reword to *"Economizer enabled when OAT < 65°F and OAT < RAT"* (or whatever the actual stated logic is).

**Step 6 — Match what you read against the field and the graphics.** Walk the actual mechanical room and BAS graphics against your simplified version. Flag any mismatch between the written sequence and what's actually installed/programmed to the PM or PE immediately — don't quietly reconcile a discrepancy by assuming the field is right and the paper is wrong, or vice versa; that's a decision for the PM/PE, not a field judgment call.

**Step 7 — Write a one-page "Tech Summary" in your own words.** Condense the whole sequence into a single page covering: system overview, start/stop conditions, normal operating setpoints, and the safety/fault responses. This becomes your fast-reference sheet for troubleshooting calls — you should never need to re-read the full submittal-length SOO to answer "why did this fan just shut off."

**Example — AHU-1 Tech Summary** (illustrating the level of compression Step 7 should reach):
> AHU-1 (VAV, serves 3rd floor). Starts: occupied schedule OR BAS override, AND freezestat normal, AND smoke normal. SAT setpoint 55°F, reset up to 65°F via T&R on zone valve/damper demand. Economizer enabled below 65°F OAT (dry-bulb) with RA comparison; locks out above high-limit. Freezestat trip <38°F: fan off, OA damper closed, HW valve open, manual reset at panel. Static pressure SP 1.2 in.w.g., T&R band 0.4–1.5. Unoccupied: fan off, freeze protection remains active.

**Additional field tips**:
- **Color-code by mode** on printed sequences or flowcharts (e.g., green = occupied, blue = unoccupied, red = safety/fault) — speeds up visual scanning during a live troubleshooting call.
- **Ask the PE to walk the logic with you** if a section genuinely doesn't parse, rather than guessing at design intent — this is faster and more reliable than reverse-engineering intent from ambiguous language.
- **Keep a lessons-learned binder** of simplified sequences and the mismatches/ambiguities found during Step 6 — this becomes institutional knowledge that improves how the next sequence gets written or reviewed, the same feedback loop described in Section 6's deficiency-list practical use.
