# Chiller Plants Reference

Deep reference for vapor compression theory, chiller types, plant hydraulic topologies, reset math, cooling towers, waterside economizers, and thermal storage. Read alongside the Reset Strategy Guidance table in SKILL.md.

## Vapor Compression Cycle

The basic vapor-compression refrigeration cycle underlying all mechanical chillers has four processes: (1) low-pressure refrigerant evaporates in the evaporator, absorbing heat from chilled water (or air, in DX equipment); (2) the compressor raises refrigerant pressure and temperature; (3) high-pressure vapor rejects heat and condenses in the condenser (to condenser water or ambient air); (4) the expansion device drops pressure, returning refrigerant to the evaporator. Chiller types differ primarily in compressor technology:

- **Centrifugal chillers** — dynamic compression via impeller; efficient at large tonnage (300+ tons), best at high load factor and stable lift; common in central campus plants.
- **Screw (rotary screw) chillers** — positive-displacement, good turndown, common in mid-size (100–1,000+ ton) applications, air- or water-cooled.
- **Scroll chillers** — positive-displacement, small-to-mid capacity, often used in modular/multiple-compressor rack arrangements for redundancy.
- **Magnetic-bearing (frictionless) centrifugal chillers** — oil-free centrifugal compressors on magnetic bearings, enabling very high part-load efficiency and lower maintenance; increasingly common in campus retrofit/replacement plants because of superior IPLV performance.

## kW/ton, COP, and Lift

- **kW/ton** is the standard chiller efficiency metric in North American engineering practice: electrical input (kW) divided by cooling output (tons); lower is better. Full-load ratings are commonly 0.5–0.7 kW/ton for high-efficiency centrifugal/magnetic-bearing chillers, while **IPLV (Integrated Part Load Value)** captures weighted part-load efficiency, which is where magnetic-bearing and variable-speed-drive centrifugal chillers most distinguish themselves.
- **COP (Coefficient of Performance)** = cooling output / power input, in consistent energy units; \( COP = 3.517 / (kW/ton) \).
- **Lift** is the differential between condensing temperature and evaporating (suction) temperature that the compressor must work against. Lower lift (achieved via colder condenser water and/or warmer chilled water) directly reduces compressor work and kW/ton — this is the physical basis for **condenser water reset** and **chilled water temperature reset** strategies.

**Quick math**: a chiller running 0.6 kW/ton has \( COP = 3.517/0.6 \approx 5.86 \). If a reset strategy trims lift enough to move the unit to 0.55 kW/ton, COP rises to \(3.517/0.55 \approx 6.4\) — roughly an 8% efficiency gain from setpoint changes alone, no hardware.

## Condenser Water Reset

Lowering condenser water supply temperature (CWST) as ambient wet-bulb allows (and as cooling tower capacity permits) reduces chiller lift and compressor energy, but increases cooling tower fan energy — the optimization is a balance. Taylor Engineering's plant optimization guidance and Trane engineering references treat this jointly with CHWST reset as the two major energy levers in a chiller plant sequence ([Taylor Engineering, *Optimizing Design and Control of Chilled Water Plants*](https://www.scribd.com/document/179701679/Optimizing-Design-and-Control-of-Chilled-Water-Plants-pdf)).

## Chilled Water Plant Configurations

**Primary–secondary (decoupled) plants**: Constant-flow primary loop circulates water through the chillers (protecting them from flow variation and low-ΔT issues), decoupled hydraulically from a variable-flow secondary/distribution loop via a common bypass/decoupler line. This has historically been the default topology for multi-chiller central plants, including many campus systems ([Trane, *Variable-Primary-Flow Systems Revisited*](https://www.trane.com/content/dam/Trane/Commercial/global/products-systems/education-training/engineers-newsletters/waterside-design/adm_apn005_en.pdf)).

**Variable-primary-flow (VPF) plants**: Eliminate dedicated constant-speed chiller (primary) pumps; variable-speed pumps circulate water through the entire loop, chillers and distribution alike. Benefits: fewer pumps, less piping, lower first cost, smaller electrical/mechanical footprint, and pumping energy that tracks actual load rather than a fixed primary flow. Design must guard against **low-ΔT syndrome** at low loads and manage transient flow through chillers during staging — often addressed by minimum-flow bypass valves, oversizing a chilled-water pump slightly, or manifolding multiple pumps ([Trane, *Variable-Primary-Flow Systems Revisited*](https://www.trane.com/content/dam/Trane/Commercial/global/products-systems/education-training/engineers-newsletters/waterside-design/adm_apn005_en.pdf); [JMP Co, *Variable Primary Chilled Water Systems White Paper*](https://jmpco.com/Files/Files/Whitepapers/JMP%20Variable%20Primary%20Chilled%20Water%20Systems%20-%20White%20Paper.pdf)).

**Comparison for sequence-writing:**

| | Primary-secondary | Variable-primary-flow |
|---|---|---|
| Chiller pumps | Dedicated, constant-speed | None — shared variable-speed loop pumps |
| Chiller flow protection | Inherent (constant flow through chiller) | Must be actively managed (min-flow bypass) |
| Pumping energy at part load | Higher (primary always full flow) | Lower (tracks actual load) |
| Staging complexity | Lower | Higher — transient flow during chiller stage events |
| Common in | Legacy/most existing campus plants | Newer/retrofit central plants prioritizing pump energy |

## Trim-and-Respond CHWST / DP Reset (Taylor Engineering Methodology)

This is one of the most consequential control sequences for chiller plant controls engineers ([Taylor Engineering, *Optimizing Design and Control of Chilled Water Plants*](https://www.scribd.com/document/179701679/Optimizing-Design-and-Control-of-Chilled-Water-Plants-pdf)):

- CHWST reset is generally *more* effective than DP reset alone; sequencing CHWST reset first, then DP reset, is the best overall approach.
- Logic: monitor valve position at all coils served by the plant. When any valve is fully open (generating a "request"), the software point "CHW Plant Reset" (0–100%) increases; when no valves are requesting, it steadily decreases.
  - At CHW Plant Reset = 100%: CHWST setpoint = Tmin (design CHWST, e.g., 42°F) and DP setpoint = DPmax (design DP).
  - As load falls off, CHWST is raised first (toward Tmax, e.g., 2°F below the lowest AHU discharge setpoint), then DP setpoint is lowered toward DPmin (e.g., as low as ~3 psi at the most remote/critical coil).
- DP sensors should be located at the most hydraulically remote coil(s) so DPmax can be set as low as possible, minimizing pump energy.
- **Chiller staging** should be based on part-load ratio (PLR) *and* lift — not load alone — because chiller efficiency and safe staging points shift with condenser water return temperature (CWRT) and CHWST. Taylor's staging point equation:
  \[ SPLR = E(CWRT - CHWST) + F \]
  with E and F derived from chiller performance coefficients (wet-bulb, IPLV, approach, range, kW/ton). Below SPLR, run one chiller; above, run two, with a time delay to prevent short-cycling.
- Example staging points cited: **variable-speed CHW pumps at 47% of design flow**, **variable-speed CW pumps at 60% of design flow**; constant-speed CW pumps are simply staged in lockstep with their chillers.

**Sequence checklist for CHWST/DP reset programming:**
1. Poll all coil valve positions plant-wide (or a representative sample of the most demanding zones).
2. Generate a "request" whenever a valve is at/near 100% open for a sustained period (avoid nuisance triggers from brief transients).
3. Increment/decrement the 0–100% "CHW Plant Reset" software point based on outstanding request count.
4. Map that 0–100% point to CHWST between Tmin and Tmax, then to DP between DPmin and DPmax — CHWST moves first, DP second.
5. Feed CWRT and CHWST into the staging logic (SPLR) rather than gating strictly on load/tonnage.
6. Add a minimum time delay between stage-up/stage-down events to prevent short-cycling.

## Waterside Economizers

A waterside economizer allows the cooling tower (and, if piped for it, a plate-and-frame heat exchanger) to directly produce chilled water when ambient wet-bulb is low enough, bypassing the chiller compressor entirely — a major energy-saving mode for campuses in cool/dry climates, often integrated as a "free cooling" mode ahead of or in series with mechanical cooling.

## Cooling Towers: Approach and Range

- **Range** = condenser water return temperature (entering the tower) minus condenser water supply temperature (leaving the tower) — the amount of heat the tower must reject, driven by the chiller's condenser load.
- **Approach** = leaving condenser water temperature minus ambient wet-bulb temperature — the thermodynamic "closeness" of the tower's performance to the theoretical limit (ambient WB). Smaller approach = larger, more effective (or more heavily loaded) tower.
- Typical design values: range 10°F, approach 7°F (i.e., 85°F tower water leaving at a 78°F design wet-bulb), though these vary by climate and tower sizing.
- **VFD tower fan control** exploits the fan-cube-law relationship (see `psychrometrics.md` affinity laws section) — towers are close to "free discharge" devices, making fan VFDs especially effective for energy savings ([Trane Engineers Newsletter Live](https://www.youtube.com/watch?v=dvm04rtL6eA); [Yorkland Controls, *VFDs in Retrofit or New Applications*](https://kh.aquaenergyexpo.com/wp-content/uploads/2023/11/Variable-Frequency-Drives-in-Retrofit-or-New-Applications.pdf)).

**Diagnostic use**: if measured range is much higher than design at a given load, suspect fouled tubes or low CW flow. If approach is much higher than design (tower water leaving far above ambient WB), suspect fouled tower fill, poor air distribution, or undersized/failed tower fan — check before blaming the chiller.

## Thermal Energy Storage (TES)

TES shifts chiller electrical load from peak (expensive/high-demand) to off-peak (cheap/low-demand) hours by producing cooling capacity at night and discharging it during the day.

- **Chilled water TES (stratified tanks)**: Uses sensible heat storage; cold water (denser) settles at the tank bottom, warm water floats at top, separated by a **thermocline**. Typical distribution ΔT of 10–20°F. Storage density is roughly 15 ft³ per ton-hour, much larger than ice storage, but well suited to campuses with available land ([Daikin, *Thermal Energy Storage in HVAC*](https://www.daikinmea.com/en_us/knowledge-center/thermal-energy-storage-in-hvac-how-ice-and-chilled-water-systems-work.html)). Multiple university campuses use large stratified TES tanks integrated into the primary/secondary or variable-primary/variable-secondary hydraulic architecture, effectively replacing the primary-secondary decoupler bridge with the tank itself — the tank charges when primary production exceeds secondary/campus demand and discharges when the reverse is true ([NC State University, *Centennial Campus TES Package bid document*](https://facilities.ofa.ncsu.edu/files/2018/07/CC-Utility-Infrastructure-TES-Package.pdf); [University of Illinois, *Central Chilled Water System Thermal Energy Storage*](https://docs.fs.illinois.edu/wp-content/uploads/2024/02/Thermal_Energy_Storage.pdf)).
- **Ice TES**: Uses latent heat of fusion (144 Btu/lb, ~334 kJ/kg), giving 5–6× the energy density of chilled water storage and a much smaller footprint; chillers must produce glycol at roughly 20–22°F (versus ~44–45°F normal), which drops chiller COP by roughly 20–30% during ice-making, a tradeoff against the demand-charge and TOU-rate benefits ([EVAPCO, *Thermal Ice Storage Application & Design Guide*](https://www.evapco.com/sites/evapco.com/files/2022-06/Thermal%20Ice%20Storage%20Application%20&%20Design%20Guide.pdf); [CKY HVAC Engineering](https://www.cky.com.tw/en/insights/energy-storage-hvac-peak-shaving)).
- **Full storage vs. partial storage**: Full storage shuts chillers off entirely during peak (large tank, maximum demand-charge reduction); partial storage (the more common real-world choice, often 40–60% of peak load) runs chillers at reduced load during peak while the tank covers the remainder, trading tank size/cost against savings ([CKY HVAC Engineering](https://www.cky.com.tw/en/insights/energy-storage-hvac-peak-shaving)).
- **Model Predictive Control (MPC)** for campus TES: Research at UC Merced (three water-cooled chillers, 2-million-gallon stratified TES tank feeding a condenser loop → primary loop → secondary (campus) loop → tertiary building loops) demonstrated that MPC using weather forecasts to optimize the nightly charging window and loop setpoints can capture additional savings beyond simple time-of-day scheduling ([CiteSeerX, *Development and Testing of MPC for a Campus Chilled Water Plant with Thermal Storage*](https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=246bef0089441f89c1c72694915a620679688a12)).

**Campus-scale example**: James Cook University's central plant with a 12-million-liter stratified TES tank reduced electricity operating costs by roughly 30% ($3.2M → $2.26M annually) by shifting/leveling demand, while also consolidating N+1 redundancy and eliminating numerous smaller, less efficient building plants ([Ecolibrium/AIRAH, *JCU's Central Energy Chilled Water Plant*](https://airah.org.au/Common/Uploaded%20files/Archive/Ecolibrium/2009/2009-09-01.pdf)).

## Common Mistakes (Chiller Plants)

- Staging chillers on load/tonnage alone instead of PLR + lift — a chiller can hit its staging tonnage while still operating well within a safe/efficient lift envelope, or vice versa; use the SPLR relationship, not a flat tonnage threshold.
- Locating the DP sensor near the pump/plant room instead of the remote coil — this defeats the purpose of DP reset by keeping the setpoint artificially high.
- Sequencing DP reset before/independent of CHWST reset — Taylor's guidance is CHWST first, DP second, because CHWST reset captures more energy savings per unit of "headroom" available.
- Running VPF plants without adequate low-flow protection at the chiller — low-ΔT syndrome and nuisance chiller trips are common when minimum-flow bypass logic isn't tuned correctly during stage transitions.
