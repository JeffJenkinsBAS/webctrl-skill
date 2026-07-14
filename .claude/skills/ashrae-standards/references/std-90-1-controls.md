# ASHRAE 90.1 — Energy Standard: Controls-Mandatory Provisions

Read this file when checking whether a DDC sequence satisfies mandatory energy-code controls provisions, or when scoping metering/submetering, economizer, DCV, reset, or hydronic controls at bid/design review.

90.1 is the baseline commercial energy code referenced by IECC and most U.S. state energy codes. **Section 6 ("Heating, Ventilating, and Air Conditioning")** contains the mandatory provisions most relevant to controls design — these apply regardless of compliance path (prescriptive, performance, or Appendix G performance rating method).

## 1. Economizer Requirements and High-Limit Controls

- Air/water economizers are required above defined system capacity thresholds by climate zone (e.g., historically ~54,000 Btu/h per fan-coil circuit trigger; exact thresholds vary by edition and climate zone) ([Trane 90.1-2010 Engineers Newsletter](https://www.trane.com/content/dam/Trane/Commercial/global/products-systems/education-training/engineers-newsletters/standards-codes/admapn038en_0910.pdf)).
- Economizers must be capable of supplying **100% of design supply air** as outdoor air for cooling and must be **integrated with mechanical cooling** — capable of partial economizer cooling concurrently with mechanical cooling, not just as an on/off first stage.
- **Damper control cannot rely on mixed-air temperature alone** for setpoint control, except for space-temperature-controlled single-zone systems — a specific, frequently-violated prohibition in legacy sequences ([fesvtech.com airflow controls summary of 90.1-2013](https://fesvtech.com/web/wp-content/uploads/2020/02/FESVTech-Airflow_Control_n_ASHRAE_Std_90_1_2013.pdf)).
- **High-limit shutoff (Table 6.5.1.1.3)** defines the control type — fixed dry bulb, differential dry bulb, fixed/differential enthalpy with dry-bulb high limit — and climate-zone-specific setpoints at which the economizer must be locked out. Electronic hybrid enthalpy and dew-point/dry-bulb combinations were eliminated in later editions to correct historically poor real-world economizer performance ([ASHRAE 90.1-2022 errata sheet](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/90.1-2022-si-erratasheet-3-25-2025-.pdf); [csemag.com "Making VAV Great Again" summary](https://www.scribd.com/document/724120931/ASHRAE-Guideline-36-2018-ASHRAE-Journal-Making-VAV-Great-Again)).
- **Mandatory fault reporting** on DDC-controlled economizer systems (added ~90.1-2016/2019):
  - Sensor failure
  - "Not economizing when should"
  - "Economizing when should not"
  - Damper not modulating
  - Excess outdoor air

  This directly overlaps with G36's FDD philosophy and now essentially requires FDD logic as a code-mandatory feature on any DDC economizer, not merely a G36 nicety ([Oregon.gov 90.1-2019 HVAC training](https://www.oregon.gov/bcd/codes-stand/Documents/90.1-2019-HVAC-training.pdf)).

## 2. Demand Control Ventilation (DCV) Thresholds

| Edition | Trigger |
|---|---|
| **90.1-2019 and earlier** | Zone **>500 ft²** with design occupancy **≥25 people/1,000 ft²**, served by a system with an airside economizer, automatic modulating OA damper control, or design OA capacity **>3,000 cfm** |
| **90.1-2022** | Replaced the single occupant-density threshold with a **table-based requirement keyed to climate zone and occupant airflow rate per 1,000 ft²**, extending DCV to some moderate-density occupancies (e.g., retail) not previously covered ([Energy Codes 90.1-2022 Final Determination TSD](https://www.energycodes.gov/sites/default/files/2024-02/Standard_90.1-2022_Final_Determination_TSD.pdf)) |

- **Addendum o to 90.1-2022** ties DCV CO2 control setpoints directly to the maximum CO2 concentrations specified in **62.1-2022 Addendum ab** — DCV controllers must now be capable of maintaining the exact ASHRAE 62.1 CO2 ceiling for the occupancy type, not an arbitrary fixed ppm setpoint ([MN DLI 90.1-2022 addendum summary](http://dli.mn.gov/sites/default/files/xls/ASHRAE-90_1-2022-Addendum.xlsx)).
- **Exceptions:** systems with qualifying energy recovery, multi-zone systems lacking zone-level DDC, and systems below the 750 cfm design OA threshold.

**Design implication:** always confirm which edition the project's adopted energy code cites — the 2019 occupant-density trigger and the 2022 table-based trigger are not interchangeable, and misapplying one for the other on a DCV take-off will produce wrong scope.

## 3. Optimum Start, Setback, and DDC Requirements

- **Optimum Start** is mandatory for individual heating/cooling systems with setback controls and DDC. The algorithm must be, at minimum, a function of:
  - The difference between space temperature and occupied setpoint
  - Outdoor temperature
  - Time available before occupancy

  ([90.1-2016 addenda text](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/90.1-2016/90_1_2016_k_o_x_ab_ac_ad_ae_ag_ah_ak_am_20210324.pdf)). Later editions extended this requirement to essentially any DDC system, removing the older ≥10,000 cfm size exemption.

- **Automatic setback/setup and morning-warmup/cooldown restart** capability are mandatory for zones with DDC:
  - Heating restart at an adjustable heating setpoint **at least 10°F below** occupied setpoint
  - Cooling restart **at least 5°F above** occupied cooling setpoint (or to prevent excess humidity)

- **Deadband requirements** govern how tightly heating/cooling setpoints may be maintained. A minimum thermostat deadband was tightened in some occupancy exceptions to **1°F** (from a historical 5°F) via later addenda — directly shaping BAS PID tuning and sequence design.

## 4. VAV Fan Control / Static Pressure Reset

- 90.1 has required **demand-based static pressure setpoint reset for DDC-controlled VAV fan systems since 1999** ([csemag.com demand-based reset strategies](https://www.csemag.com/using-demand-based-reset-strategies/)).
- Typical prescribed T&R sequence (per 90.1 Appendix/Informative guidance and widely adopted in practice): decrease setpoint every ~2 minutes by an adjustable increment (e.g., 0.04 in. w.g.) if ≤1 pressure request exists; increase by the same increment if more than 1 request exists, within a min/max envelope (e.g., 0.15–1.5 in. w.g.). "Pressure request" is generated by any VAV damper wide open (or airflow ratio <90% of setpoint).
- **Fan control:** single-zone systems ≥5 hp (chilled-water) or specific DX capacity thresholds must use two-speed or VFD fan control. **VAV fan static pressure sensor location and reset (Section 6.5.3.2.2/.3)** requirements were expanded across the 2010–2016–2019 editions, tightening exceptions and increasing coverage to smaller systems.

## 5. Supply Air Temperature (SAT) Reset

SAT reset is a **prescriptive** (not always strictly mandatory) requirement for multiple-zone VAV systems with DDC at the zone level. The setpoint must be reset based on zone demand (e.g., % of zones calling for cooling) or outdoor air temperature, within a defined range — typically implemented today via G36's trim-and-respond approach referenced directly by design engineers to satisfy this provision. See [references/guideline-36.md](guideline-36.md) for the actual T&R math.

## 6. Hydronic System Controls

- **Variable-flow pumping** is required for chilled-water and hot-water plants above defined pump horsepower thresholds.
- **Pump differential-pressure (DP) setpoint reset** is mandatory for systems with DDC:
  - DP setpoint may **not exceed** the value corresponding to **110% of design flow**.
  - DP setpoint must be **reset until at least one control valve is nearly wide open**.
  ([Trane 90.1-2010 Engineers Newsletter](https://www.trane.com/content/dam/Trane/Commercial/global/products-systems/education-training/engineers-newsletters/standards-codes/admapn038en_0910.pdf))
- VFD requirements on chilled/heating water pumps are keyed to nameplate horsepower and climate zone, expanding in scope with each edition.
- 90.1-2016 tightened requirements further, adding new detection/reporting/test-mode provisions and alternative reset methods for hydronic systems paralleling the airside VAV reset logic.

## 7. Parking Garage Ventilation

Mechanical ventilation systems in enclosed parking garages must include automatic contaminant (CO/NO2) detection-based ventilation control that varies fan speed/operation with detected contaminant levels rather than running continuously. This is a common Division 23/25 point-list item (CO sensors integrated to BAS, staged/VFD garage exhaust fan control) frequently coordinated between the controls contractor and electrical/life-safety trades.

## 8. Lighting-HVAC Coordination

90.1's lighting control provisions (occupancy sensing, daylighting, automatic shutoff) increasingly interface with the BAS for **unified occupancy signals** — G36 sequences explicitly allow lighting-control occupancy sensor status (via BACnet interface) to drive HVAC zone-group occupancy mode, avoiding duplicate sensor hardware and ensuring HVAC setback aligns with lighting setback ([4CD Early Learning Center spec excerpt referencing lighting control BACnet interface for occupancy](https://webapps.4cd.edu/apps/files/purchasing/misc/05.%20Specifications%20-%20Section%20259000%20Building%20Automation%20Sequences%20of%20Operation.pdf)).

## 9. Energy Monitoring / Submetering (2019 / 2022) — Consequential BAS Scope Item

This is one of the most consequential recent additions for BAS scope, and one of the most commonly under-bid.

- **90.1-2019** introduced baseline requirements for permanently installed metering.
- **90.1-2022** (Section 6.4.3 / Section 11 energy credits) requires **separate measurement devices** for:
  - Total electrical energy
  - HVAC systems
  - Interior lighting
  - Exterior lighting
  - Receptacle circuits
  - Refrigeration systems

  in buildings generally **≥25,000 ft²** ([Leviton submetering code requirements line card](https://leviton.com/content/dam/leviton/lighting-controls/controls/product_documents/downloads/VerifEye-Submetering-Energy-Codes-English-Line-Card.pdf)).

- Data must be recorded at **15-minute intervals**, reported at least hourly/daily/monthly/annually, retained for a **minimum of 36 months**, and made accessible to tenants.
- Buildings with a qualifying digital control system (per Section 6.4.3.10) must **transmit metering data through the BAS and display it graphically** — this explicitly pulls energy metering/dashboarding into BAS/Division 25 scope rather than leaving it purely to the electrical/metering contractor.
- Individual tenant spaces **>10,000 ft²** require dedicated submetering.
- **90.1-2022** also added site-level metering (parking lots, EV charging, on-site solar) and a new Section 11 Energy Credits framework ([Emergent Metering IECC/90.1 submetering summary](https://emergentmetering.com/resources/blog/iecc-2021-ashrae-90-1-submetering-requirements)).

**Design implication:** BAS scope-of-work and points schedules must explicitly capture metering integration (pulse/Modbus/BACnet meter points), graphic trend dashboards, and 36-month data retention/archiving — a scope item easily under-bid if only the "controls" sequences are reviewed and the energy-monitoring section of 90.1 is overlooked. In WebCTRL, plan the trend/report architecture for 15-minute interval data with a 36-month retention target and be mindful of the custom report engine's 50-column/1000-row limits when building rollup reports.

## Quick-Reference Table (from this file)

| Provision | Threshold / Requirement |
|---|---|
| DCV (90.1-2019) | Zone >500 ft², occupancy ≥25 ppl/1,000 ft², econ/auto OA damper/OA >3,000 cfm |
| DCV (90.1-2022) | Table-based by climate zone + occupant airflow rate/1,000 ft² |
| DCV CO2 setpoint (Addendum o) | Must equal 62.1-2022 Addendum ab occupancy-type ceiling |
| Optimum Start | Mandatory, function of space temp Δ, OA temp, time-to-occupancy |
| Heating restart | ≥10°F below occupied heating setpoint |
| Cooling restart | ≥5°F above occupied cooling setpoint |
| Minimum deadband (tightened editions) | 1°F (from historical 5°F) |
| Static pressure reset | Required since 1999 for DDC VAV fan systems |
| Hydronic DP ceiling | ≤110% of design flow value |
| Submetering building threshold | ≥25,000 ft² |
| Submetering interval/retention | 15-min recording, 36-month retention |
| Tenant submetering threshold | >10,000 ft² |
