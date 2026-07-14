# ASHRAE 62.1 — Ventilation for Acceptable Indoor Air Quality

Read this file when calculating or verifying ventilation rates, sizing VAV minimum airflow setpoints, or reviewing CO2-based DCV logic against code requirements.

## 1. The Ventilation Rate Procedure (VRP) — Full Equations

Section 6.2 prescribes the Ventilation Rate Procedure, the dominant compliance path used in practice ([Heatwise VRP walkthrough](https://www.heatwise-hvac.com/blog/ashrae_621/); [Trane ASHRAE 62.1 Engineers Newsletter Live material](https://www.trane.com/content/dam/Trane/Commercial/global/products-systems/education-training/continuing-education-gbci-aia-pdh/ASHRAE-Standard-62-1/APP-CMC047-EN_material_Std62.pdf)).

### Step 1 — Breathing Zone Outdoor Airflow (Vbz)

\[
V_{bz} = R_p \cdot P_z + R_a \cdot A_z
\]

Where:
- \(R_p\) = outdoor airflow rate per person (Table 6-1)
- \(P_z\) = zone population
- \(R_a\) = outdoor airflow rate per unit area
- \(A_z\) = zone floor area

The people- and area-based components are **additive** — a structural feature since the 2004 edition that fundamentally changed how ventilation scales with occupancy compared to the pre-2004 single-rate approach.

### Step 2 — Zone Outdoor Airflow (Voz)

\[
V_{oz} = \frac{V_{bz}}{E_z}
\]

Where \(E_z\) = **Zone Air Distribution Effectiveness** (Table 6-2), which depends on supply configuration and heating/cooling mode.

| Supply Configuration / Mode | Ez |
|---|---|
| Ceiling supply of cool air (typical VAV cooling) | 1.0 |
| Ceiling supply of warm air, certain throw/ΔT conditions | as low as 0.8 |

A lower Ez means **more outdoor air must be delivered to compensate for poor mixing** in that mode — a frequently-missed detail in heating-mode VAV minimum calculations. Always verify which Ez value applies to the actual operating mode (heating vs cooling) being programmed, not just the design/peak case.

### Step 3 — System-Level Outdoor Air Intake (Vot)

Calculation procedure differs by system configuration:

| System Type | Vot Calculation |
|---|---|
| Single-zone systems | Intake airflow = zone outdoor airflow directly |
| 100% outdoor air (DOAS) systems | Intake = sum of zone requirements, no recirculation credit needed |
| Multiple-zone recirculating systems (typical VAV AHU) | Requires calculating **System Ventilation Efficiency (Ev)** |

For multi-zone recirculating systems, all zones receive the same percentage outdoor air in the mixed supply stream, meaning non-critical zones are over-ventilated to ensure the "critical zone" gets its required minimum. Ev typically **improves at part load** relative to design/peak conditions, which is the basis for dynamic reset credit (see Section 3 below) ([csemag.com Zone and System calculations](https://www.csemag.com/zone-and-system-calculations/); [YouTube 62.1-2019 system calculations walkthrough](https://www.youtube.com/watch?v=ic_47UDUgSA)).

## 2. Multiple-Zone Recalculation / System Ventilation Efficiency (Ev)

For multi-zone recirculating systems, **62.1 Appendix A** provides the iterative/simplified procedure to calculate Ev as a function of the "critical zone" — the zone with the lowest ratio of primary airflow to zone outdoor air requirement. As that critical zone's damper position or primary airflow changes with load, Ev (and thus the required system intake) can be recalculated in real time — this is precisely the mechanism G36 and DCV logic exploit for energy savings, since Ev is generally higher at part-load conditions than at design ([Trane 62.1-2004 Dynamic Reset article](https://www.trane.com/content/dam/Trane/Commercial/global/learning-center/ashrae-articles/Standard%2062.1-2004%20System%20Operation%20Dynamic%20Reset%20Options.pdf)).

**Practical note:** the "critical zone" can change identity as loads shift throughout the day — a BAS implementing dynamic reset must continuously re-identify the critical zone, not assume it's fixed at the design-case zone.

## 3. Dynamic Reset / DCV with CO2 (Sections 6.2.7 / 6.2.6)

### Section 6.2.7 — Dynamic Reset

Explicitly permits resetting the design outdoor air intake flow and/or zone airflow as operating conditions change, provided the minimum breathing-zone requirement for **actual (not design) population** is continuously met.

### Section 6.2.6 — DCV Requirements (tightened via 62.1-2022 Addendum ab)

- Breathing zone outdoor airflow (Vbz) must be reset in response to **current population**, never falling below the building-related component (\(R_a \times A_z\)) even at zero occupancy.
- Multi-zone recirculating systems relying on space CO2 sensors must ventilate to the **room requiring the most ventilation** (the critical zone concept applied dynamically).
- **CO2 sensor accuracy requirements are explicit:** within **±75 ppm at both 600 ppm and 1,000 ppm** reference points ([Kaiterra 62.1 DCV CO2 compliance summary](https://learn.kaiterra.com/en/resources/ensuring-ashrae-62.1-compliance-for-co2-sensors-in-demand-controlled-ventilation-dcv); [62.1-2022 Addendum ab PDF](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/62_1_2022_ab_20231031.pdf)).
- **Upon sensor failure**, the system must default/reset to the **design ventilation rate for design population** — DCV cannot fail to a reduced/unsafe ventilation state.
- A defined **linear ramp**: minimum ventilation output at ambient CO2 (~400 ppm), maximum (100% of design rate) at the occupancy-category-specific CO2 max concentration from Table 6-1's derived values.
- **Time-averaging of zone population for DCV is explicitly not allowed** as a means of gaming reduced ventilation.

## 4. Impact on VAV Minimum Airflow Programming

**This is the single most consequential 62.1-driven change to legacy VAV programming conventions.** Modern VAV box minimum airflow setpoints should be driven by the **actual calculated zone ventilation requirement (Voz)** rather than an arbitrary fixed percentage of cooling maximum. Legacy "30% of cooling max" minimums frequently either under- or over-ventilate relative to actual code requirements.

This is precisely the shift Guideline 36 formalizes in its VAV terminal sequences — see [references/guideline-36.md](guideline-36.md) Section 4.

## Quick-Reference: Core Equations and Values

| Item | Value / Equation |
|---|---|
| Breathing zone outdoor airflow | \(V_{bz} = R_p \cdot P_z + R_a \cdot A_z\) |
| Zone outdoor airflow | \(V_{oz} = V_{bz}/E_z\) |
| Ez, ceiling supply cool air (typical VAV) | 1.0 |
| Ez, ceiling supply warm air (certain conditions) | as low as 0.8 |
| CO2 sensor accuracy requirement | ±75 ppm at 600 ppm and 1,000 ppm reference points |
| DCV ramp | 0% at ~400 ppm (ambient) → 100% of design rate at occupancy-category CO2 max |
| DCV sensor failure behavior | Default to design ventilation rate for design population |
| Time-averaging population for DCV | Not allowed |
