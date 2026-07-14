# Psychrometrics Reference

Deep reference for moist-air properties, chart processes, and the math behind mixing/economizer and coil sequences. Read alongside the Psychrometric Process Decision Guidance table in SKILL.md.

## Sensible vs. Latent Heat

Moist air conditioning involves two distinct forms of heat transfer that must be separated when writing sequences or diagnosing coil performance:

- **Sensible heat** changes dry-bulb temperature without changing moisture content (humidity ratio). On a psychrometric chart, a pure sensible process is a horizontal line — humidity ratio, vapor pressure, and dew point stay constant while dry-bulb temperature, enthalpy, and (inversely) relative humidity change ([CED Engineering, *Air Conditioning Psychrometrics*](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf)).
- **Latent heat** changes moisture content (humidity ratio) without necessarily changing dry-bulb temperature — it is the energy of evaporation/condensation of water vapor in the airstream ([CED Engineering](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf)).
- **Total heat** (enthalpy change) is the sum of sensible and latent components; the **sensible heat factor (SHF)** — also called sensible heat ratio (SHR) — is the ratio of sensible heat to total heat. Typical commercial space SHR is 0.75–0.85; high-density assembly spaces (auditoriums, gymnasiums) run 0.45–0.65 because occupant latent load dominates ([ingener.by, *High-Density Occupancy HVAC Systems*](https://ingener.by/specialty-applications-testing/specialty-hvac-applications/high-occupancy-density-hvac/)).

## Enthalpy, Wet-Bulb, and Dew Point

- **Wet-bulb temperature (WBT)** is measured with a wetted-wick thermometer; because of evaporative cooling it is always ≤ dry-bulb temperature, converging only at saturation (100% RH). On the psychrometric chart, WBT lines run diagonally from the saturation curve down to the lower left and closely follow lines of constant enthalpy ([CED Engineering](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf)).
- **Dew point temperature** is the temperature at which water vapor begins to condense out of the air; it lies on the 100% RH curve. At dew point, dry-bulb and wet-bulb temperatures are equal ([CED Engineering](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf)).
- Enthalpy (total heat content of moist air, Btu/lb dry air) is the chart's diagonal scale and is the fundamental property tracked in **total heat (enthalpy) economizer** logic and cooling coil load calculations.

## Full Psychrometric Chart Process Table

| Process | Chart signature | Description |
|---|---|---|
| **Sensible heating** | Horizontal line, moving right | Straight horizontal line parallel to the humidity-ratio axis; humidity ratio unchanged, RH decreases as dry-bulb rises. Occurs across heating coils or electric strip heat ([CED Engineering](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf)). |
| **Sensible cooling** | Horizontal line, moving left | Humidity ratio constant; RH increases as dry-bulb falls (e.g., cooling coil operating above the air's dew point). |
| **Cooling + dehumidification** | Diagonal line down-and-left | Occurs when coil surface temperature is below the entering air dew point; both sensible and latent heat are removed simultaneously. Modeled as sensible cooling to the dew point, then condensation while air remains saturated along the curve. Dry-bulb, humidity ratio, vapor pressure, dew point, wet-bulb, and enthalpy all decrease; RH typically ends near saturation at the coil ([CED Engineering](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf)). |
| **Humidification** | Vertical/near-vertical, moving up | Moisture added via spray, wetted media, or steam injection; humidity ratio and (usually) enthalpy increase. Winter make-up-air systems and DOAS units frequently need this to counter dry outdoor air ([CED Engineering](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf)). |
| **Heating + humidifying** | Diagonal up-and-right | Modeled as two sequential steps: sensible heating first, then humidification. |
| **Chemical dehydration (desiccant)** | Diagonal up-and-left, near-isenthalpic | Adsorption releases heat of condensation into the airstream even as moisture is removed — essentially adiabatic/isenthalpic; used in industrial and some lab dehumidification. |
| **Evaporative cooling** | Diagonal, constant wet-bulb | Adiabatic — no net heat gain/loss; sensible heat used to evaporate water becomes latent heat in the airstream, so WBT stays constant while dry-bulb falls and humidity ratio rises ([CED Engineering](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf)). |
| **Mixing (economizer / OA-RA blend)** | Straight line between two state points | Mixing two airstreams (e.g., outdoor air and return air in the mixed-air plenum) produces a resultant state point that lies on the straight line connecting the two source points, located proportionally to the mass-flow ratio of the two streams. This is the underlying principle for **economizer** mixed-air-temperature control and for double-duct/multizone mixing dampers ([CED Engineering](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf)). |

## Economizer Control Implication

Dry-bulb (temperature) economizer changeover simply compares OA dry-bulb to a setpoint or to return-air dry-bulb; **enthalpy economizer** compares OA enthalpy to RA enthalpy (or a fixed enthalpy setpoint) so that humid-but-cool OA does not get admitted at the expense of added latent cooling load — this is the standard ASHRAE 90.1-mandated logic for larger economizer-equipped units in humid climates.

**Sequence-writing implication**: if the site is in a humid climate and the unit is large enough to trigger ASHRAE 90.1 economizer requirements, don't wire up a dry-bulb-only changeover — pull both OA and RA enthalpy (from temperature + humidity sensors, calculated) and compare enthalpies, not just temperatures.

## Key HVAC Equations for Controls Engineers

These "rule of thumb" constants come from standard air properties (0.075 lb/ft³ density, 0.24 Btu/lb·°F specific heat, 1,061 Btu/lb latent heat of vaporization for moist air at typical conditions) and are foundational to load calculations, trending analytics, and BAS-derived virtual sensors ([CED Engineering, *Air Conditioning Psychrometrics*](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf)):

- **Sensible heat (air-side):**
  \[ Q_s = 1.08 \times CFM \times \Delta T \]
  (Btu/hr; some references use 1.085 depending on assumed air density/altitude). Derivation: \( \text{lb/hr} = CFM \times 0.075 \times 60 = 4.5 \times CFM \); then \( Q_s = 4.5 \times CFM \times 0.24 \times \Delta T = 1.08 \times CFM \times \Delta T \).

- **Latent heat (air-side):**
  \[ Q_L = 0.68 \times CFM \times \Delta W \]
  where \(\Delta W\) is the humidity-ratio difference in grains of moisture per pound of dry air. (Some engineering references use 4,840 or 0.69 depending on unit convention for \(\Delta W\) in lb/lb vs. grains/lb — see the [LibreTexts HVAC formula reference](https://workforce.libretexts.org/Courses/Coalinga_College/Introduction_to_Residential_HVAC_Level_1/07:_Trade_Mathematics/7.06:_Conversions_and_Formulas_in_HVAC) for the grains-based form.)

- **Total (enthalpy-based) heat, air-side:**
  \[ Q_{total} = 4.5 \times CFM \times \Delta h \]
  where \(\Delta h\) is enthalpy difference in Btu/lb dry air. This is the correct formula for total cooling coil load (sensible + latent combined) and is essential for coil selection and cooling-tower/chiller load estimates ([CED Engineering](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf)).

- **Water-side sensible heat (hydronic):**
  \[ Q = 500 \times GPM \times \Delta T \]
  Derivation: \( \text{lb/hr (water)} = GPM \times 8.33 \times 60 = 500 \times GPM \); specific heat of water ≈ 1.0 Btu/lb·°F, so \( Q = 500 \times GPM \times \Delta T \) (Btu/hr). This is the standard formula for chilled-water and hot-water coil, chiller, and boiler load calcs, and for **1 ton = 12,000 Btu/hr → GPM = Tons × 24 / ΔT** ([Trane, *Engineers Newsletter Live handout*](https://www.trane.com/content/dam/Trane/Commercial/global/products-systems/education-training/continuing-education-gbci-aia-pdh/HVAC%20Myths%20and%20Realities/APP-CMC062-EN_handout.pdf)).

- **Fan brake horsepower:**
  \[ HP = \frac{CFM \times \Delta P_{(in.\, wg)}}{6{,}350 \times \eta_{fan}} \]

- **Pump brake horsepower:**
  \[ HP = \frac{GPM \times \Delta P_{(ft\,head)}}{3{,}960 \times \eta_{pump}} \]
  (both from [CED Engineering](https://www.cedengineering.com/userfiles/M05-005%20-%20Air%20Conditioning%20Psychrometrics%20-%20US.pdf))

## Applying These to Coil Sequences

- If a cooling coil's leaving air is above the entering-air dew point, it can only do sensible work — use \(Q_s = 1.08 \times CFM \times \Delta T\) to estimate load, and don't expect condensate.
- If leaving air is below entering dew point, the coil is doing combined work — use \(Q_{total} = 4.5 \times CFM \times \Delta h\), and separate sensible from latent with \(Q_L = Q_{total} - Q_s\) if you need both terms.
- For a DOAS delivering cold, dehumidified air ("cold not neutral" strategy — see `airside-systems.md`), track leaving dew point and leaving dry-bulb both; a single dry-bulb discharge setpoint alone doesn't confirm the unit is meeting its latent-removal design intent.

## Affinity Laws (Fans & Pumps) — Full Detail

For a fixed impeller/wheel diameter, centrifugal fan and pump performance scales with rotational speed (N) as follows ([Engineering Toolbox](https://www.engineeringtoolbox.com/fan-affinity-laws-d_196.html); [Trane Engineers Newsletter, *Impact of VSDs on HVAC Components*](https://www.trane.com/content/dam/Trane/Commercial/global/products-systems/education-training/engineers-newsletters/waterside-design/ADMAPN048EN_0913.pdf)):

\[ \frac{Q_2}{Q_1} = \frac{N_2}{N_1} \qquad \frac{H_2}{H_1} = \left(\frac{N_2}{N_1}\right)^2 \qquad \frac{P_2}{P_1} = \left(\frac{N_2}{N_1}\right)^3 \]

- **Flow** varies linearly with speed.
- **Head/pressure** varies with the **square** of speed.
- **Power** varies with the **cube** of speed — this is the fundamental justification for VFDs on fans and pumps: a 20% speed reduction cuts power to ~51% of full-speed power; a 50% speed reduction cuts power to ~12.5% ([Trane](https://www.trane.com/content/dam/Trane/Commercial/global/products-systems/education-training/continuing-education-gbci-aia-pdh/HVAC%20Myths%20and%20Realities/APP-CMC062-EN_handout.pdf); [Affinity Laws – Wikipedia](https://en.wikipedia.org/wiki/Affinity_laws)).

**Controls caveat — "free discharge" vs. system-curve devices:** The cubic power law holds exactly only for *free-discharge* fans (no fixed static-pressure component, e.g., cooling tower propeller fans) where the system curve passes through the origin. Real ducted/piped systems have a **fixed static-pressure component** (filters, coils, fixed orifices) plus a **variable frictional component** (∝ velocity²); as a result, actual power savings from speed reduction in a real system are *less* than the pure cube law predicts, though still substantial ([Trane Engineers Newsletter Live, *VSDs and Their Impact on HVAC Systems Components*](https://www.youtube.com/watch?v=dvm04rtL6eA)). This is why static-pressure/DP reset strategies matter — lowering the *setpoint*, not just running a VFD, is required to fully capture cube-law savings.

The affinity laws assume constant efficiency between operating points and are most accurate for speed changes within roughly ±20–30% ([Mech Codex, *Affinity Laws Calculator*](https://mechcodex.com/calculators/heat-transfer/affinity-laws)).
