# Commissioning Workflow — Full Procedure Detail (Steps 1–5)

## Step 1: Pre-Power Verification & Panel Inspection

### Before Powering Up — Prerequisites

- Have the module drawing on hand to review during checkout; add redline notes as terminations are completed.
- Ask the installer/PM/subcontractor for a detailed diagram of how communication cabling was pulled controller-to-controller.
- Speak with the on-site electrical contractor/point of contact and verify panel locations for circuits powering the controllers/panels.
- Coordinate with the mechanical contractor before powering up controllers and testing.
- Verify you have all tools required for the task.

### Steps When Opening Each Panel Prior to Power-On

**Visually inspect the panel:**

1. If a transformer (Tx) is present, verify no incoming power to the A-side; if there is, isolate power at the Tx and leave the B-side (24V output) off until other checks are complete.
2. Check for anything out of place; note possible problems.
3. Check module mounting — secure, no visual damage.
4. Perform a "tug test" on all terminated wiring to verify no loose connections.
5. Check polarity of all power wiring; verify correct voltage type is wired to correct terminals.
6. Check existing wire labeling for correctness/standard compliance.
7. Organize non-terminated wiring into Inputs and Outputs; verify none pinched or damaged.
8. Check controllers/devices for metal shavings from panel installation.
9. Verify all devices/controllers match the controls submittal drawing bill of materials for that panel. If mismatched, contact PM/PE immediately, determine if it was a late change, and redline the submittal drawing **before moving on**.

**Unplug anything currently terminated to I/O:**

- Always unplug input/output terminals from all controllers in the panel prior to power-up, so a field wiring mishap doesn't damage the controller before an issue can be found.

**Jumpers and Switches (Legacy Controllers/Non-OF):**

1. With submittals in hand/on device, run through all switches/jumpers on each controller and set accordingly.
2. If no addressing is on the drawings, open SiteBuilder to check the database for the correct address, then adjust the address dial on the module. Wobble each dial slightly to verify it hasn't stopped in a half-way position.

**Input Jumpers:**

- Jumper setting depends on device type wired to that input. On most equipment application controllers there are three settings:
  - **mA** — for 0-20mA/4-20mA devices
  - **Thermistor/Dry-Contact/RTD**
  - **Volts** — for 0-5V or 0-10V devices
  - Dry-Contact is also used for Pulse Input Types (measuring pulse count over time, e.g., water flow).
- **Gotcha:** On ZN or Zone Controllers, mA is **not** an option for inputs, and **only** 0-5V can be used (no 0-10V or 4-20mA devices work on ZN/Zone controllers).

**Output Jumpers:**

- Jumper setting depends on the device being controlled. Most equipment application controllers offer three settings:
  - **mA** — for devices controlled via 0-20mA or 4-20mA, such as some VFDs
  - **Volts** — for most analog control (0-10/2-10V or 0-5V), more common than mA for VFDs; used for damper/valve actuators
  - **External Relay** — dry contact closure; needs external 24V power to send a signal out, otherwise it's a simple dry contact.
- On ZN or Zone Controllers, mA is **not** an option for outputs — only 0-5/0-10V or Relay Output.
- **Gotcha:** The Relay Output is a dry contact closure needing external power for a 24V signal; otherwise it's a simple open/close contact.

**Auto/Off/On Switches (Legacy Controllers/Non-OF):**

- Put all output switches to **OFF** prior to power-up so nothing runs until final checkout.

**Module Address (Legacy Controllers/Non-OF):**

- Set via two rotary dial switches to the right of the module, per the communication layout drawing(s).

**Module Address (Current Generation OF-E2 Controllers):**

- Addressing is internally set up with IPv4/IPv6-type addressing.
- Relies on the installation process and QR code stickers placed per a network riser drawing so the technician can match MAC address to installed equipment.
- The database must be adjusted to match field installation. (See `field-connections.md` for OptiFlex local connection setup.)

**Terminations:**

- Verify all I/O terminations are correct — loose terminations cause issues during and after startup.
- Use an electrical tester to verify no voltage is coming from the field.
- **Gotcha:** Stray voltage can damage controllers if applied to I/O or communications terminals.

**Existing Controls:**

1. Verify existing controls to remain are wired correctly; do a quick serviceability check.
2. Check for loose wiring/electrical damage indicating prior issues.
3. Any existing device wiring now terminating on the new controller must be labeled per company standard so all I/O wiring leaving the panel is correctly labeled.
   - Standard: every panel should look better and more organized when you leave than when you arrived.

---

## Step 2: Powering Up & Downloading Memory

### Initial Power-Up Procedure

1. Locate the power switch — should still be in the **OFF** position.
2. Use an electrical tester to verify no power is being provided by the controls Tx to the (still unplugged) power terminal.
3. Once all power wiring is cleared, turn on the controls Tx circuit feeding the still-unplugged power terminal.
4. Verify with the electrical tester that correct voltage is present at the power terminal:
   - **21.6–26.4 VAC, or 24 VAC ±10%** (Legacy Controllers/Non-OF)
   - **20.6–27.6 VDC, or 24 VDC ±15%** (Current Generation OF Controllers)
5. If checks pass, plug the power terminal into the controller and enable the power ON switch.
   - **Warning:** If issues occur with the power source, turn OFF the circuit and double-check all Tx terminations, and confirm grounding is complete and the panel is bonded to ground.
6. Once powered, observe LEDs for abnormalities.
   - Use the technical instructions for each controller to interpret LED status (communications, running, errors, power, digital output statuses). See `controller-service.md` for OF342-E2 and G5CE LED quick-reference tables.
   - If a Digital Output lights up during initial power-up, the controller may be from a previous project with mismatched programming that could damage equipment.
     - Leave all outputs disconnected on this controller until it's downloaded with the correct programming.
   - If everything looks normal, the controller is ready for memory download via local or remote system access.

### Local Connection Guides

- Pre-OptiFlex E2 controllers: use the RNET Connection Setup procedure — see `field-connections.md`.
- OptiFlex E2 controllers (dual ethernet ports): use the OptiFlex Local Connection Setup procedure — see `field-connections.md`.

### Downloading Memory/Program to the Module

1. If connecting to a module already running or previously checked out by someone else, perform a **"paramupload"** manual command **FIRST** so settings/checkout notes are not overwritten and lost.
   - **Always upload** from field controllers first if there is any question about the module's checkout/parameter settings.
   - If this is the initial download, inputs/outputs remain unplugged so equipment doesn't start accidentally or damage anything.
2. Downloading the Module (WebCTRL):
   1. On the WebCTRL Network Tree, select the module.
   2. Click **Downloads**.
   3. If controller is already in the Downloads queue, skip to step (d).
      - If **not** in the list: Click **Add** → find controller in Network pop-up → select radio button **All Content** → Click **Add** → Click **Close**.
   4. Select the controller in the Downloads queue.
   5. Click **Start**.
      - If the download fails, hover over the failure for the reason, resolve, and retry.

### Downloading Notes

- **Hold** stops **pending** downloads only; active downloads cannot be stopped once started. If Start is clicked by accident on a connection-troubled controller, you must wait for it to fail.
- Downloading a controller with running equipment will **shut down** that equipment on restart — be prepared, especially with Boiler/Chiller Plants, Loop Pump Systems, Data Center CRAC Units, and AHU/RTUs serving many zones.
- ARCnet and Legacy Modules on **different networks** can be downloaded simultaneously.
- A **BBMD download** of all routers/LAN Gates is required from the front end whenever a new router is added, to update BBMD tables for BACnet traffic routing.
  - Navigate to the root/top of the NET tree → Downloads page → click **ADD**, select only the BBMDs for download (click top router, hold SHIFT, click bottom router in NET tree) → click **ADD**.
  - Check **Select All** on the Downloads page, then click **Start** to begin all BBMD downloads.
  - Expect some failures; retry until all complete/disappear. Persistent failures indicate a communication issue to troubleshoot on that router/LAN Gate.
- **Gen5 hardware-specific notes:**
  - On E2 controllers, **up to 10 controllers** can be downloaded simultaneously over the network.
  - IP Addressing is either a scheme provided by the customer's IT department, or the network sits behind a managed L3 (Layer-3) switch (provided by ACI) with a dedicated new VLAN.

### Download Task Status Icons

| Status | Meaning |
|---|---|
| **Active** | WebCTRL is downloading to the controller. |
| **Pending** | Download initiated; controller waiting its turn. |
| **Failed** | Download failed. Hover to see cause. |
| **On Hold** | Either the controller requires a download, or you clicked Hold to stop a pending download. |

To remove an item from the download list: right-click the item → **Remove selected tasks**.

### If a Controller Fails to Download

- A failed controller shows a red X icon on the Downloads page.
- Hover the failed task for the reason (hover text).
- Correct the problem.
- Select the controller on the Downloads page → click **Start** to retry.

---

## Step 3: I/O Channel Assignment

### Navigating to the I/O Points Page

Two methods to reach the I/O Points page in WebCTRL:

1. Navigate down the **NET tree** to the controller and its programming.
2. Navigate the **GEO tree**, expanding areas until reaching the equipment programming.

Once at the control program (logic icon next to equipment/room name):

1. Click **Properties**.
2. Click the **I/O Points** tab.

This is where all input/output parameters and channel assignments are adjusted for initial start-up and Cx.

**Warning (before assigning channels):** Before assigning channel assignments that could cause equipment to start unexpectedly — click the **Logic** button and disable logic from running the equipment: lock to **UNOCCUPIED**, lock all outputs to **OFF**, or adjust manual override logic to **OFF**.

### Assigning I/O Channel Assignments

1. Using the submittal drawing, enter for each point: input/output expander/channel number, I/O Type, Sensor/actuator type, Min/Max value, and resolution value.
2. A misconfigured/out-of-range point shows in **red text** (e.g., a point still defaulted at channel 0:0 shows red).

### I/O Page Property Descriptions

| Field | Description |
|---|---|
| **Name** | Click to display the microblock pop-up. A **red** name indicates a fault condition (misconfigured point) — e.g., no I/O number or a nonexistent I/O number. |
| **Type** | Type of Input or Output point. |
| **Value** | Present value of this point. |
| **Offset** | Allows fine calibration of the present value of an analog point. |
| **Polarity** | Determines the point's binary normal polarity in the control program. NOTE: Polarity is not the hardware normally-open/normally-closed position. |
| **Locked** | Checkbox to lock the present value at a specified value. |
| **Exp: Num** | Expander numbers and input/output numbers associated with where the physical point wires are physically connected to a controller. |
| **I/O Type** | Selects the bank of physical inputs/outputs on the controller. |
| **Sensor** | Selects how the physical input is mapped to engineering units. Min/Max is used with sensor type "linear" to scale the input. (Ignored for non-linear sensor types.) |
| **Actuator** | Selects how the present value (engineering units) is mapped to the physical output. Min/Max is used with actuator type "linear" to scale the output. (Ignored for non-linear actuator types.) |
| **Resolution** | Amount by which the present value will change. Example: if a physical input changes by 1 but resolution is set to 2, present value doesn't change; if input changes by 2, present value changes by 2. |
| **Checked Out / Checkout Notes** | Filled out with verification details; once checkout is complete, a Points List report is run, saved, and uploaded to the ProCore folder for that job. |

---

## Step 4: Point-to-Point Verification

### Prerequisites

- Panel/module inspection complete (wire labels, terminations in order) — see Step 1.
- Submittal drawings open/ready.
- Module powered up, downloaded with latest drivers, communicating with server or local database — see Step 2.
- All I/O channel assignments entered in the I/O Points page — see Step 3.

### Binary Inputs (BI)

1. With the I/O Points page open, confirm active values read inactive/OFF.
2. Short (touch together) both stripped wire ends of the binary input wires at the device.
3. On the I/O Points page, verify the point changed state.
4. Open the binary input at the end device.
5. Verify the point changed state again.
6. Fill out checkout notes describing the test method, check "Checked Out."
7. Repeat for all binary inputs.

**Tip:** Example — pump/fan status: remove wires from the current switch, touch stripped wires together; status should change OFF→ON at the laptop.

**Note:** Also verify by actually turning the pump on/off to confirm correct status reflects real run state (covered further in Cx phase).

### Analog Inputs (AI)

1. Verify sensor type and min/max values match device documentation/label.
2. Read the present value on the I/O Points page.
3. Verify per sensor type:
   - **Temp Sensor** — disconnect wires (leave open): present value should show **−60°F**. Short the wires: should show **259°F** (opposite end of range). Reconnect: actual reading returns.
   - **0-20mA** — use a milliamp meter at the module; convert reading to min/max scale and compare to point value. **Do not forget** most devices are **4-20mA**, not starting at 0 on the min/max scale — miswiring shows RED on the I/O page even with correct settings.
   - **0-5VDC and 0-10VDC** — use a multimeter at the module's input; convert to min/max scale and compare.
4. Fill out checkout notes, check "Checked Out."
5. Repeat for all analog inputs.

**Tip:** For temperature sensing, use a temp gun in the measured space to verify present value accuracy within **±2°F**.

**Warning:** Calibrate the analog input via the calibration offset in the I/O Points page if needed. **All devices MUST be calibrated with a meter of some type.**

### Binary Outputs (BO)

1. Verify device is terminated to the correct contact set (NO/NC).
2. If BO drives an equipment starter/VFD, set the starter HOA switch to **OFF**.
3. On the controller, set the BO's HOA switch to **ON** (if applicable) — or, if not applicable, lock the point to ON via the I/O Points page.
4. Verify the Start/Stop relay coil energized and changed state.
5. Set the BO's HOA switch to **OFF** (if applicable) — or unlock/lock to OFF via I/O Points page.
6. Set the starter HOA switch to **AUTO**.
7. Set the BO's HOA switch to **ON** (if applicable) — or lock to ON via I/O Points page.
8. Verify the controlled equipment turned on.
9. Set the BO's HOA switch to **AUTO** (if applicable) — or unlock the point and use logic to command the BO/relay.
10. Verify the device turned on.
11. Fill out checkout notes, check "Checked Out."
12. Unlock all logic regarding that BO to let programming shut everything back down.
13. Move to the next BO point.
14. If this is the final BO verification and the area/equipment isn't ready to fully run, **LOCK all outputs to OFF** to prevent unexpected equipment starts.

### RIB (Relay In a Box)

One of the most commonly used devices in controls — isolates the controls output signal from the end device, protecting both sides from damage. Functions like a light switch (makes/breaks whatever signal it's wired to).

Typical wiring (RIBU1C example):

- The 24V signal BO wires to **Wht/Blu (White/Blue)** and **Wht/Yel (White/Yellow)** on the incoming/coil side.
- The equipment's control signal/load wires through **Yel (Yellow)** out to **Org (Orange)** for common, and **N/O (Normally Open)**.

### Analog Outputs (AO)

1. Verify output/actuator type and min/max values are correctly configured in the I/O Points page.
2. AOs may include floating motor types and PWM — same test outcome, setup may vary by device.
3. Procedure via I/O Points page or Logic page:
   1. Lock the analog output to **0%** — verify end device moves to and holds desired position.
   2. Lock to **25%** — verify movement/hold.
   3. Lock to **50%** — verify movement/hold.
   4. Lock to **75%** — verify movement/hold.
   5. Lock to **100%** — verify movement/hold.
4. Unlock the analog output.
5. Fill out checkout notes, check "Checked Out."

### Point-to-Point Verification Complete — Final State Checklist

- All points assigned to correct channel assignment.
- Type and range of I/O set correctly.
- No RED text/errors on inputs or outputs.
- "Checked Out" column filled with checkmarks (login name + date/time stamp).
- Detailed checkout notes for how each device was checked out/verified.
  - Any deficiencies outside scope should be noted with the contact informed and their trade.
- Once complete, run the Points List Report.

### Points List Report — How to Run

1. In the GEO tree, click the dropdown next to **Reports**.
2. Find **Point List** in the Equipment subsection.
3. Configure Options tab once (saved thereafter in that database):
   - **Page Size:** 11x17
   - **Page Orientation:** Landscape
   - Check boxes: Type, Value, Offset/Polarity, Exp:Number, I/O Type, Checked Out, Checkout Notes, physical points
4. Click **Run**.
5. Save via the **PDF** button.
6. Naming convention: `POINTLIST_<SITE>_<EQUIPMENT>_<DATE>_<YOUR FIRST INITIAL AND LASTNAME>.pdf`
   - Example given: `POINTLIST_CUMBERLANDTRACE_WSHP215_05022023_JJENKINS`
7. Save reports in a job folder and upload to the jobsite-specific reports folder on ProCore once connectivity allows.

### Redlines

- Along with Point List reports, complete "Redlines" (markups to submittal drawings for field changes) at each piece of equipment.
- Changes happen — devices get wired to different inputs than shown. Always aim to match the submittal drawing; document **any** deviation in redlines.
- Markup jobsite submittal drawing set (paper) or digitally via an app on PDFs pulled from ProCore — no format preference, but markups must exist somewhere documenting what/how it changed.
- All markups compiled and reviewed with the Project Engineer at project end so Engineering can update drawings for the final as-built O&M closeout documentation.

---

## Step 5: Commissioning & Sequence of Operations (SOO) Verification

### Prerequisites

- Panel/module inspection complete.
- Submittal drawings open/ready.
- Module powered up, downloaded, communicating.
- I/O channel assignments entered.
- Point-to-point verification complete; Points List Report stored in job folder and on ProCore.
- All inputs/outputs unlocked and ready for testing.

### Understanding Cx and SOO Verification

The process is simply checking that the programming and equipment do what they're contractually/scope-required to do.

**Commissioning (Cx):** A systematic process ensuring equipment performs per design intent, contract documents, and owner's operational needs. Initial Cx is performed by the field technician via point-to-point verification and SOO checks. A third-party Cx agent later verifies everything combined with Test & Balance data, pump/motor data, and building envelope info for the whole building.

- The third-party Cx agent should **not** be finding wiring/calibration issues that should already have been resolved — their role is to verify, not to find our deficiencies.
- Design/SOO questions should first go through the PM **and** PE before discussion with the 3rd-party Cx agent, who may escalate to the design engineer if needed.

**Sequence of Operations (SOO)** covers four main areas:

1. **Equipment Protection** — protection against freezing coils, short-cycling motors, duct damage from over/under pressurization, etc. Not optional/tradeable.
2. **Reliable Operation** — building-specific definition of "reliable" (ranges from high tolerance for degraded conditions to near-0% downtime for top-tier data centers). Not optional.
3. **Comfort** — indoor temp, RH, air quality maintained within acceptable ranges; can be balanced against efficiency based on owner tolerance.
4. **Energy Efficiency** — balancing act with comfort; not always clear which choices improve efficiency without affecting reliability/protection.

### Performing Sequence Checks and Cx

SOOs originate from the mechanical design engineer, carried into controls submittals by ACI Engineers for reference; also found in the M sheets of project drawings. PM should have all project documents on ProCore.

### Simplifying the Sequence of Operations

Technique: break the SOO into smaller sentences per paragraph. Copy each paragraph into a Word document and write a sentence or two explaining it, as if training someone else. This aids retention during programming/commissioning.

### Commissioning the Programming

- Watch the live Logic page to confirm the program does what the SOO requires (may need to lock values to force program behavior — track any parameters/delays adjusted to speed testing).
  - **Warning:** There is a Locked Values report to check for forgotten locks, but **no report exists** to check delay timers/temporary parameter changes.
- Adjust setpoints and verify logic correctly commands heating/cooling and more/less water/airflow.
- Verify PIDs correctly open/close valves and damper actuators for flow/temp control per SOO.
- Confirm alarm blocks engage at specified alarm points after delays are reached.
- Verify safeties correctly shut down equipment and/or manipulate devices per SOO and interlocked equipment behavior during a safety shutdown.

### Logic Page — Detailed Checks

**Requests and Run Conditions:**

- Verify request/total/min-max blocks at the top of programming correctly pull values from "children" modules (building controls hierarchy — e.g., AHUs are "parents" to VAVs, but "children" to the Chiller/Boiler plant; source tree rules define information flow direction).

**Run Conditions:**

- Typically near the top of programming; houses logic for starting, engaged by requests, color, or network command from a manager-type program.
- Verify run equipment blocks work correctly — a run command should follow from sufficient requests. During unoccupied hours, a certain number of requests are required before the system can run.
- The **Run Cmnd BV microblock** should show ON when conditions are met.
- Loop freeze protection block test: with the system not running, lock the outside air temp (true point) to **30°F** to force pumps into freeze protection mode.
- Locking the OA Temp network block is a common technique for logic testing affected by varying OA temp.
- Inside the OA Temp microblock, verify correct mapping and that incoming OA Temp is valid.

**Loop Monitor:**

- Verify loop supply temp is reading correctly and threshold blocks have correct trigger values for alarming. Same check for loop return temp.

**VFD Pressure Control:**

- Typically a differential pressure (DP) sensor controls drive speed. Verify DP reading accuracy and PID function.
- **Startup/checkout PID tuning values: P=2, I=1, D=0, Interval 20 Seconds** — then tune from there.
- Tune every PID in every program to avoid problems/complaints later.
- **Warning:** Default PID values are **P=20, I=5, D=0** — with these, the output is essentially open/close (0%→100%→0%) with little/no modulation; an untuned PID is easy to spot from this behavior.

**Lead/Standby System:**

- **Lead/Standby definition:** Two redundant pieces of equipment for extended lifecycle/safety. Example: two equal pumps on a Chilled Water Loop with two Chillers — only one runs to maintain differential pressure setpoint/minimum flow; weekly rotation between pumps by time/day; if lead pump fails, standby starts and runs as lag.
- **Lead/Lag definition (different concept):** One or more units run depending on demand. Example: two equal pumps, system starts with one running, but based on DP/minimum flow demand, the speed PID engages the second pump as lag for additional flow/DP control.
- **Important distinction:** Design engineers often mislabel a lead/standby design as "lead/lag." This difference **really matters** for commissioning — you must know it and be able to explain it.
- Logic example: **STG2** is the active tag that engages the lag pump.
- Rotation method selectors — four settings: **Daily, Weekly, Monthly, Manual rotation**, plus **Runtime** (most popular rotation method).
- Manual rotation setting still allows pump swap on failure but won't rotate until told to.
- **Warning:** **ALWAYS** check that equipment rotates on failure of the lead unit.
- Test procedure for failure/rotation:
  1. Place logic in AUTO.
  2. Turn the lead unit off at the disconnect.
  3. System should swap to the lag unit.
  4. Verify an alarm is generated for the failure; adjust start/stop logic timing so the building/equipment is maintained during failure/rotation.

**Status:**

- Ensure programming shows proof of status when equipment is running at minimum (if applicable):
  - Verify the CT is correctly terminated and assigned in the program (checked during Point to Point Verification and I/O Channel Assignment).
  - Start the monitored equipment via AUTO or by manually locking the start/stop output command (ensure equipment is ready to start first).
  - If the unit is on a VFD, lock the Speed Output to minimum speed.
  - Check the analog input for amperage reading at the drive/starter; navigate to the "True if > Constant" microblock housing the status threshold and adjust it just below the current amperage reading.

**Temperature Sensors:**

- Most temp sensors are **10K ohm @ 77°F thermistor** type — not polarity sensitive, reliable if the correct sensor is on the correct input and the input type is set to thermistor.
- For duct probe sensors: pull the thermistor from the duct and measure against another measurement source in that space or via an infrared temp gun.
- Verify the sensor label matches its actual function (e.g., "Supply Temp" is actually reading supply temp).

**Final note:** Startup/commissioning processes for different devices are similar, but no single guide can cover every device type — refer to installation/online reference docs by searching the part number online. Each module has different I/O terminal rules — always reference the module's technical instructions from ALC. Sources: the ALC Portal, the office shared drive, and ProCore under **4TRAIN > Documents**.
