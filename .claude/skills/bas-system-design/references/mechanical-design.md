# Mechanical Design Fundamentals

Load calculations, equipment selection/sizing, system-type tradeoffs, duct/pipe sizing, and ventilation design — the mechanical engineering foundation that controls design and points lists are built on top of.

## Load Calculation Methods

**Heat Balance Method (HBM) vs. Radiant Time Series Method (RTSM)**: ASHRAE's modern cooling load methodology is built on the fundamental heat balance principles of the building envelope and space. HBM solves the full simultaneous heat balance directly; RTSM is a simplified, non-iterative approximation derived from HBM and is the recommended simplified procedure in ASHRAE's *Load Calculation Applications Manual* ([ASHRAE](https://www.ashrae.org/File%20Library/Technical%20Resources/Bookstore/preview-load-calculations.pdf)). Practically, most commercial design work is performed in load calc software (Trane TRACE, Carrier HAP, IES-VE, EnergyPlus-based tools) that implement RTSM or HBM under the hood — the engineer's judgment is exercised in selecting inputs: internal loads (people, lighting, plug loads), envelope U-values and solar heat gain coefficients, infiltration assumptions, and schedules.

### Block Load vs. Peak (Zone) Load and Diversity

A **block load** is the instantaneous maximum heating and cooling load for a calculated point in time for the entire building, including all envelope and internal load components, and it typically occurs at a different time of day than any individual zone's peak because solar and occupancy loads do not peak simultaneously across all orientations and zones ([JMP Equipment Co.](https://jmpcoblog.com/hvac-blog/hydronic-balancing-part-2-making-the-most-of-system-diversity)).

The **diversity factor** is the ratio of peak block load to the sum of all individual zone peak loads (total connected load):

\[
\text{Diversity Factor} = \frac{\text{Peak Block Load}}{\text{Total Connected (Zone) Load}}
\]

Industry rule-of-thumb diversity factors ([JMP Equipment Co.](https://jmpcoblog.com/hvac-blog/hydronic-balancing-part-2-making-the-most-of-system-diversity)):

| System Size | Diversity Factor |
|---|---|
| Up to 25 tons | 0.85 |
| 25–100 tons | 0.80 |
| Larger than 100 tons | 0.75 |

**Design rule**: Central plant equipment (chillers, boilers, primary pumps) is sized to the *block* load with diversity applied. Individual zone terminal equipment (VAV boxes, FCUs) is sized to the *zone* peak load without diversity, since each zone must meet its own worst-case condition regardless of what other zones are doing at that moment.

- Undersizing the plant to the raw sum of zone peaks (ignoring diversity) → gross oversizing, inefficient part-load operation.
- Oversizing zone equipment defensively (ignoring load calc discipline) → short-cycling, poor turndown control.

This diversity/simultaneity theme recurs at every scale of the system — see `references/system-integration.md` for the same phenomenon at the ventilation and reset-logic level.

## Equipment Selection and Sizing

**Air Handling Units (AHUs)**: Sized from calculated supply airflow (derived from sensible cooling load ÷ (1.08 × ΔT) for standard air) and total/latent load for coil selection. Cooling coil face velocity is a key design decision — ASHRAE 90.1-aligned practice generally targets **2.0–2.5 m/s (~400–500 fpm)** face velocity to avoid moisture carryover past the coil while controlling static pressure and fan energy; lowering face velocity below ~2.0 m/s yields diminishing static-pressure/fan-energy returns ([Pharmaceutical HVAC](https://www.pharmaceuticalhvac.com/how-to-select-face-velocity-for-air-handling-units-in-pharmaceutical-applications/)). Airflow (CFM), static pressure, and psychrometric coil performance together drive fan and coil selection ([PDH Online — AHU Design Considerations](https://pdhonline.com/courses/m250/m250content.pdf)).

**Chillers**: Selected by tonnage (block cooling load with diversity), then by compressor type:

- **Centrifugal** — large, efficient at high load factor
- **Screw** — mid-range, good part-load performance
- **Scroll** — small tonnage, simple, modular

Also selected by condensing method (air-cooled vs. water-cooled with cooling towers). Selection considers minimum turndown, part-load efficiency (IPLV/NPLV), and redundancy/staging strategy (N+1, multiple chillers to track partial loads without a single large chiller cycling at very low load factor).

**Boilers**: Sized to block heating load with the same diversity logic. Increasingly specified as condensing boilers for higher part-load efficiency, which pushes design hot water supply temperature down — lower return water temperature improves condensing efficiency. This is a decision with major downstream controls implications (reheat energy, hot water reset curves — see `references/system-integration.md`).

**Pumps**: Sized from system flow (GPM, driven by load ÷ (500 × ΔT) for water) and total system pressure drop (coils + piping + fittings + control valves). Variable-speed pumping with two-way control valves is now standard practice for energy efficiency but drives the low-delta-T design challenges discussed in `references/system-integration.md`.

## System Type Selection Tradeoffs

| System Type | Strengths | Weaknesses | Typical Use Case |
|---|---|---|---|
| **VAV (Variable Air Volume)** | Centralized air handling, efficient at part load with fan VFDs, good for large open/core zones, easy central OA/economizer control | Reheat energy penalty at low loads and perimeter zones; ductwork-intensive; simultaneous heating/cooling risk if poorly controlled | Large office, institutional, core/perimeter buildings |
| **Fan Coil Units (FCU)** | Zone-level control, simpler ductwork, good for hydronic-served buildings (hotels, high-rise residential) | Requires 2-pipe or 4-pipe hydronic distribution; filter/coil maintenance at every zone; noise | Hotels, multifamily, perimeter zones supplementing VAV |
| **VRF (Variable Refrigerant Flow)** | High zone-level efficiency and individual zone control, simultaneous heat recovery possible (heat pump VRF), lower installation footprint than hydronic | No integral fresh air (requires separate DOAS); refrigerant piping length/elevation limits; less mature integration with BAS trending/diagnostics; per published simulation results, VRF systems can use roughly **25%–55% less HVAC site energy** than comparable RTU-VAV systems across various U.S. climates ([IBPSA](https://publications.ibpsa.org/proceedings/asim/2016/papers/asim2016_343.pdf)) | Mixed-use, renovation/retrofit, hotels, multi-tenant |
| **WSHP (Water Source Heat Pump)** | Distributed heat pumps on a shared loop enable heat recovery between zones (cooling zones reject heat to heating zones); simple zone control | Loop temperature maintenance (boiler/tower) is a central plant responsibility; efficiency benefits depend on simultaneous diversity of heating/cooling demand | Multi-story buildings with diverse simultaneous loads, schools |
| **Chilled Beams (active/passive)** | Very low fan energy (convective/induced sensible cooling); quiet; good for high ceiling, low internal-load spaces | Limited to sensible cooling — requires separate DOAS for ventilation and latent control; condensation risk requires tight dew point control; passive beams have limited cooling capacity and require extensive water piping to more connection points ([Titus HVAC — Decoupled Sensible Cooling](https://www.titus-hvac.com/file/12433/ASHRAE_Decoupled.Sensible.Cooling.pdf)) | Offices, labs (active beams), high-end commercial |
| **Radiant (panels/slabs)** | Excellent comfort (uniform radiant temperature), can use higher chilled water supply temp / lower hot water supply temp (efficiency gain), silent | Slow thermal response (poor for fast load swings); requires separate ventilation/dehumidification system; commissioning and control complexity higher | Museums, high-performance offices, spaces with stable loads |

The comparison of chilled beams, radiant panels, and VAV/reheat systems is well documented in ASHRAE-affiliated research on decoupled sensible cooling, which frames these systems as tradeoffs between "expensive but efficient" (radiant, active beams) vs. "cheaper but limited capacity" (passive beams) approaches — all of which decouple ventilation air delivery from sensible temperature control ([Titus/ASHRAE](https://www.titus-hvac.com/file/12433/ASHRAE_Decoupled.Sensible.Cooling.pdf)).

## Duct and Pipe Sizing Basics

**Duct sizing methods**:

- **Equal Friction Method** — maintains a constant pressure loss per unit duct length throughout the system (commonly 0.08–0.15 Pa/m or ~0.1 in. w.g./100 ft), simplifying balancing since all branches see comparable friction rates ([HVAC Systems Encyclopedia](https://ingener.by/ductwork-piping-distribution/ductwork-air-distribution/duct-design-methods/)).
- **Static Regain Method** — sizes ducts so the static pressure gain from velocity reduction at each branch takeoff offsets the friction loss in the next section, keeping static pressure roughly constant at each diffuser — preferred for larger, higher-velocity systems where equal friction would produce excessive velocity (and noise) near the fan.
- **Velocity Reduction Method** — simplest, using rule-of-thumb maximum velocities by duct section (main, branch, run-out) — less common in modern commercial practice but still used for quick approximations.

**Pipe sizing** follows analogous logic: chilled/hot water piping is sized by target velocity (typically 4–8 ft/s in mains to control noise and erosion, lower in smaller branch piping) and by pressure drop per 100 ft (commonly 1–4 ft of head per 100 ft of pipe as a design target), balancing pump energy against pipe material cost.

## Ventilation and Exhaust Design (ASHRAE 62.1)

ASHRAE Standard 62.1 governs minimum outdoor air ventilation via the **Ventilation Rate Procedure**. The zone-level breathing zone outdoor air requirement is:

\[
V_{bz} = R_p \times P_z + R_a \times A_z
\]

where \(R_p\) = people-based ventilation rate (cfm/person, from Table 6.2.2.1), \(P_z\) = zone population, \(R_a\) = area-based rate (cfm/ft²), and \(A_z\) = zone floor area ([Trane ASHRAE 62.1-2019 ENL](https://www.trane.com/content/dam/Trane/Commercial/global/learning-center/enl-booklets/APP-CMC077-EN_booklet.pdf)).

This is then divided by the zone air distribution effectiveness \(E_z\) to get the zone outdoor airflow:

\[
V_{oz} = V_{bz}/E_z
\]

At the system level, outdoor air intake is calculated using system ventilation efficiency \(E_v\), which accounts for occupancy diversity \(D\) across zones served by a common air handler. This diversity credit is one reason single-zone load calcs and system-level ventilation calcs diverge, and why VAV systems typically need a **multiple-spaces equation** rather than simple summation of zone minimums ([Trane CDS eLearning](https://www.trane.com/content/dam/Trane/Commercial/global/products-systems/design-analysis-tools/cds-software-news/2015_01_Jan/CDS%20ELearning-TRACE_ASHRAE62_1_handouts.pdf)).

Exhaust design (kitchen hoods, restrooms, labs, parking garages) is governed by Section 6 exhaust requirements in 62.1 and by code-mandated exhaust rates that often dominate total building exhaust air, requiring make-up air and building pressurization design to avoid negative-pressure infiltration problems.

## Field Takeaways for Controls Engineers

- When a points list or sequence references a "design load," confirm whether it's a block load (plant-side, diversified) or a zone peak load (terminal-side, non-diversified) — mixing the two up leads to nonsensical staging or reset logic.
- Face velocity and coil selection decisions upstream determine whether a "low delta-T" complaint later (see `references/system-integration.md`) is a controls problem or a mechanical selection problem.
- Ventilation diversity credit (\(E_v\), \(D\)) explains why a VAV system's total outdoor air intake, as trended in WebCTRL, will legitimately read lower than the naive sum of each zone's `Voz` — don't chase that as an alarm condition without checking the design ventilation efficiency calc first.
