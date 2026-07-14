# Controls Design Engineering

How the controls contractor turns mechanical schedules and sequences into a buildable points list, valve/damper selections, sensor placements, and panel design. This is the discipline layer between "the mechanical engineer's design intent" and "a programmable, commissionable BAS."

## Developing Points Lists from Mechanical Schedules

The controls contractor builds the points list directly from the mechanical equipment schedules, sequences of operation, and control drawings. A rigorous points list (per widely used institutional commissioning specifications) documents, for every point:

1. Controlled system
2. Point abbreviation
3. Point description (e.g., DB temp, airflow)
4. Display unit
5. Whether it is a **control/setpoint** point (controls equipment and is adjustable — e.g., OSA setpoint, SAT setpoint)
6. Whether it is a **monitoring** point (does not control equipment, used for O&M/performance verification only)
7. Whether it is an **intermediate** point (used in a calculation that then drives control — e.g., zone temps averaged into a virtual point for reset logic)
8. Whether it is a **calculated/virtual** point (generated purely from calculations on other points)

([Dartmouth College Design & Construction Guidelines, Section 01 91 13](https://www.dartmouth.edu/fom/docs/2023_construction_guidelines/01_91_13_general_commissioning_requirements.pdf))

The controls contractor is contractually obligated to keep the commissioning authority (CA) and architect/engineer (A/E) informed of all points list changes made during programming and setup — a critical discipline because points lists drift as field conditions and RFIs change the as-built condition from the design intent.

**Field practice**: classify every point this way *before* building EIKON logic — it determines whether a value needs a Setpoint microblock (adjustable, control), a plain AI/BI trend (monitoring), or a calculation microblock feeding a virtual point (intermediate/calculated). Getting this classification wrong early is a common source of rework during Cx.

## Control Valve Sizing: Cv, Valve Authority, Rangeability

### Flow Coefficient (Cv)

**Cv** quantifies valve flow capacity: the GPM of 60°F water that flows through a fully open valve with 1 psi pressure drop across it. For water:

\[
C_v = Q \sqrt{\frac{S}{\Delta P}}
\]

where \(Q\) = flow (GPM), \(S\) = specific gravity (≈1.0 for water), \(\Delta P\) = pressure drop across the valve at design flow, in psi ([HVACProSales](https://hvacprosales.com/hvac-controls/control-valves/)).

### Valve Authority (N)

**Valve authority** is the dimensionless ratio describing how much control the valve actually has over system flow, relative to the total circuit pressure drop:

\[
N = \frac{\Delta P_{valve, wide open}}{\Delta P_{total\ circuit}}
\]

Low authority (valve is a small fraction of total circuit resistance) causes the valve's *installed* flow characteristic to deviate sharply from its inherent (catalog) characteristic — a linear valve behaves like a quick-opening valve at low authority, producing poor control resolution over most of its stroke.

**Rule of thumb**: target valve authority of roughly **0.25–0.5** for acceptable modulating control.

### Two-Way vs. Three-Way Valves

In hydronic systems, "the goal of the control valve... is to react to a temperature control signal and reduce the flow rate through the coil" — as a two-way valve closes toward 0% flow, pressure drop across the valve increases at lower-than-design flow ([R.L. Deppmann](https://www.deppmann.com/blog/monday-morning-minutes/three-way-two-way-control-valve-basics-hydronic-systems/)).

**Two-way valves are strongly preferred** in modern variable-flow systems because they reduce system flow as load drops, enabling pump VFD energy savings and proper delta-T. Three-way valves (which bypass flow rather than reduce it) defeat variable-flow pumping strategy and are a documented root cause of low-delta-T syndrome. Taylor Engineering's seminal ASHRAE paper states plainly: "never use three-way valves in variable-flow systems, except perhaps for one or two valves to ensure pumps are never dead-headed" ([Taylor — ASHRAE Symposium, "Degrading Delta-T"](https://www.scribd.com/document/40471092/ASHRAE-Symposis-Degrading-Delta-T-Taylor)).

### Rangeability

**Rangeability** is the ratio of maximum to minimum controllable flow through the valve while maintaining its characteristic curve — typically **30:1 to 50:1** for a well-selected globe valve. This is a key criterion in avoiding the "controllable range too narrow" failure mode where a valve oversized for its actual turndown duty hunts or loses control resolution near the closed position.

**Design/field checklist for valve selection**:

- Confirm Cv at design ΔP produces a valve that isn't oversized "for safety" — oversizing is the most common root cause of poor authority.
- Verify authority ≥ 0.25 against the full circuit (coil + piping + fittings + balancing valve), not just the coil.
- Two-way, not three-way, unless there's a specific dead-head protection need.
- Check rangeability against actual expected turndown (design flow ÷ minimum controlled flow) — don't just check the nameplate ratio in isolation.

## Damper Sizing and Selection

**Parallel blade dampers (PBD)** move all blades in the same rotational direction; **opposed blade dampers (OBD)** move adjacent blades in opposite directions. Their inherent flow-vs-position characteristics differ fundamentally:

- **OBD** flow approximates \(Q/Q_{max} \approx (\theta/\theta_{max})^n\), with \(n \approx 0.7\)–\(1.0\) — nearly linear, giving consistent control-loop gain across the modulating range ([HVAC Systems Encyclopedia](https://ingener.by/controls-automation-building/control-theory-fundamentals/damper-control-characteristics/)).
- **PBD** flow approximates an exponential quick-opening curve, reaching 85–90% of max flow by 50% blade rotation — poor for modulating control, prone to hunting if used that way.

### Selection Rules

| Application | Recommended Type | Rationale |
|---|---|---|
| Modulating/throttling duty (VAV terminal boxes, economizer mixing dampers, bypass control) | **Opposed blade** | Near-linear control, better turndown — though OBDs cost more, require roughly twice the size of an equivalent PBD for the same pressure drop, and need longer duct length (3–6 diameters vs. up to 10 for PBD) to achieve full static regain downstream ([ScienceDirect — Opposed Blade Damper overview](https://www.sciencedirect.com/topics/engineering/opposed-blade-damper)) |
| Mixing applications (recirculation/return air damper) | **Parallel blade** | Pressure drop across the damper is the dominant loss, and PBD directs airflow toward the outside air stream for better mixing and lower total pressure drop |
| Two-position/isolation duty | **Parallel blade** | Typically adequate and cheaper since intermediate positions aren't used |
| Economizer OA/RA dampers specifically | Sized by pressure drop, not authority | Per Steven Taylor's ASHRAE Journal guidance (adapting ASHRAE Guideline 16), *damper authority does not apply* to economizer mixing dampers because they mix two airstreams rather than throttle overall flow — sizing is instead driven by acceptable pressure drop at design airflow (typical target velocities 400–1,500 fpm depending on damper type and application) ([Taylor — ASHRAE Journal](https://www.scribd.com/document/272478509/ASHRAE-Journal-Select-Control-Economizer-Dampers-in-VAV-Systems-Taylor)) |

**Actuator sizing**: Match actuator torque to damper size (commonly **35–180 in-lb** range for typical HVAC dampers). Use spring-return, fail-safe actuators for smoke/life-safety dampers. Use an even number of actuators on large opposed-blade dampers for balanced operation.

## Sensor Selection and Placement Rules

**Outdoor air temperature (OAT)**: Mount on the north face of the building (avoiding direct solar exposure) or, where an economizer is present, immediately upstream of the OA damper so the sensor reads the actual entering OA temperature used for the economizer decision ([Carrier Sensors Installation Guide](https://www.shareddocs.com/hvac/docs/1000/Public/03/11-808-423-01.pdf)).

**Duct averaging temperature sensors**: Used where stratification is expected (immediately downstream of AHU mixing sections, coils). Best practice: mount the sensing element horizontally across the duct in a serpentine pattern, with roughly one foot of sensor element per square foot of duct cross-sectional area, spaced about 1 ft apart (minimum 6 in. if space-constrained). The entire sensing length must remain inside the duct or readings will be skewed ([BAPI mounting guidance](https://www.bapihvac.com/application_note/mounting-methods-and-best-practices-for-duct-averaging-sensors/); [manufacturer field guidance](https://www.youtube.com/watch?v=oDpDkzkhC-s)).

**Duct static pressure sensor/probe location (VAV fan control)**: Classic rule of thumb places the probe roughly **two-thirds of the way** down the longest/most critical duct run, or at minimum ~10 ft downstream of the AHU and ~5 ft downstream of the first branch takeoff, to represent the "worst case" pressure point the fan must maintain ([Johnson Controls / Verasys design guidance](https://docs.johnsoncontrols.com/bas/r/Verasys/en-US/Verasys-System-Changeover-Bypass-Zoning-System-Design-Application-Note/4.0/Detailed-Procedures/Locating-the-Static-Pressure-Sensor-and-Probe); [rooftop unit example](https://docs.johnsoncontrols.com/ductedsystems/r/Johnson-Controls/en-US/Johnson-Controls-Premier-25-Ton-to-80-Ton-Rooftop-Units-Installation-and-Maintenance-Guide/2024-05-15/Installation/Field-tubing/Discharge-air-static-pressure-transducer)).

Note that modern trim-and-respond static pressure reset strategies (per ASHRAE Guideline 36) reduce the criticality of exact 2/3 placement, because the setpoint itself is dynamically reset based on VAV damper positions rather than held at a fixed static target — some practitioners now argue for placing the sensor closer to the AHU for control stability under reset logic ([LinkedIn field discussion](https://www.linkedin.com/posts/ck-at-work_where-is-the-best-place-to-put-a-static-pressure-activity-7314934884504850432-xhj_)).

**CO2 sensors**: Placed in the return air duct (system-level demand control ventilation) or in the occupied space at breathing-zone height, away from doors, windows, and direct supply diffuser throw, to accurately represent the space's actual occupant-driven CO2 buildup.

**Zone/space sensors**: Placed on interior walls away from direct sun, supply diffusers, exterior doors, and heat-generating equipment, at roughly **4–5 ft above floor** (breathing zone height) — same underlying rationale as CO2 placement, avoiding localized effects that don't represent the zone's true condition.

## Control Panel Design, Transformer Sizing, and Power Coordination

### Panel Design

Panel design follows **UL 508A** guidance for industrial control panels: line-voltage and low-voltage (Class 2, 24VAC) wiring must be physically separated within the enclosure. Many owner standards explicitly prohibit exposed line-voltage circuitry inside control cabinets and require line voltage isolated in separate enclosures or wireways from Class 2 control wiring ([University of Virginia BAS Standards](https://www.fm.virginia.edu/docs/bascontrols/BASStandards-Rev6.1.pdf)).

Safety/interlock circuits (freezestats, high limits, smoke shutdown) are commonly required to be **hardwired, normally-closed, 24VAC series circuits** independent of software logic, so a controller failure cannot defeat a safety interlock.

### Transformer Sizing

Control power transformers (CPTs) are sized in two steps:

1. Sum the steady-state (sealed) VA of every device that will be simultaneously energized.
2. Calculate inrush VA by adding the single largest inrush VA value to the sealed VA of everything else running at that moment.

Take the **larger** of the two totals and select the next standard transformer size, typically adding a **20–25% margin** for future expansion ([Elecbase — CPT sizing](https://elecbase.net/how-to-size-a-control-power-transformer/)).

**Field rule of thumb**: don't load a transformer beyond ~80% of its rated VA (e.g., a 75 VA transformer should be loaded to no more than ~60 VA) to leave margin and avoid nuisance thermal issues ([field tutorial](https://www.youtube.com/watch?v=Kx-tpDb2ZIU)).

### Power Coordination with Electrical

Who furnishes vs. who installs, and who provides line power vs. low voltage, is a recurring and consequential design/spec decision:

- Typically the **electrical contractor (Division 26)** provides and terminates all line-voltage wiring, motor connections, disconnects, and starters; the **controls/mechanical contractor** provides and terminates low-voltage (Class 2, <100V) control wiring ([City of Madison electrical spec example](https://www.cityofmadison.com/business/pw/contracts/documents/7911%207911%20exhibit%20c%20electrical%20plans%20and%20specifications.pdf)).
- On integrated systems like unified lighting control, the split is more nuanced: the BAS controls contractor *furnishes* the low-voltage lighting control devices (occupancy sensors, light-level sensors, stations) while the electrical contractor *installs* them and makes all terminations, line and low voltage — with the controls contractor providing approved submittals, riser diagrams, and termination schematics to the electrical contractor to execute ([Blue Ridge Lighting Controls spec example](https://www.smartbuildingdesign.com/wp-content/uploads/2025/02/Blue-Ridge-Lighting-Controls-Part2.pdf)).
- **Best practice** per institutional BAS standards: each control panel/terminal unit should receive dedicated line-voltage power from the electrical contractor, with a disconnect for isolation, and the controls contractor then steps that line voltage down locally to 24V with its own transformer at each panel. **Central/distributed low-voltage power runs across panels are explicitly prohibited** in some owner standards because a single transformer fault would cascade across multiple panels ([UVA BAS Standards](https://www.fm.virginia.edu/docs/bascontrols/BASStandards-Rev6.1.pdf)).

## Common Mistakes

- **Sizing a valve to the pipe size instead of to Cv/authority.** A valve matched to line size is almost always oversized for its actual control duty — check authority against the full circuit before finalizing.
- **Using three-way valves on a new variable-flow design "to be safe."** This defeats the pumping strategy from day one and is a documented root cause of low-delta-T syndrome (see `references/system-integration.md`).
- **Specifying opposed-blade dampers for two-position isolation duty.** Wastes cost/space; parallel blade is adequate when intermediate positions aren't used.
- **Applying damper authority logic to economizer OA/RA dampers.** These are sized by acceptable pressure drop at design airflow, not by authority — authority doesn't apply to mixing dampers.
- **Locating the OAT sensor on a sun-exposed wall or downstream of the OA damper instead of upstream.** Produces a biased economizer decision input.
- **Running Class 2 low-voltage power centrally across multiple panels instead of a dedicated transformer per panel.** Creates a single point of failure that can take down multiple panels simultaneously.
