---
name: ashrae-standards
description: "Maps ASHRAE standards and guidelines (90.1, 62.1, 55, Guideline 36, Standard 135/BACnet, Guideline 13, Standard 202) to BAS controls design, sequences of operation, and project specs. Use when a project spec, RFP, or engineer's sequence cites ASHRAE 90.1, 62.1, 55, Guideline 36 / G36, BACnet / Standard 135, BACnet/SC, DCV or demand control ventilation, economizer high limit, ventilation rate procedure, trim and respond, energy code, IECC, LEED controls credits, Division 23 09 00 / 25 00 00 spec sections, or commissioning standards (202, Guideline 0, Guideline 1.1). Covers checking a spec for applicable-standard gaps, pulling compliance thresholds (DCV, economizer, metering, VAV minimums), and translating guideline language into EIKON/WebCTRL point lists and sequences. Not for general HVAC theory unrelated to code/spec compliance — see hvac-fundamentals for that."
metadata:
  author: JeffJenkinsBAS
  version: '1.0.0'
---

# ASHRAE Standards for BAS Controls Design

## When to Use This Skill

Use this skill whenever a project document, RFP, engineer's basis of design, or spec section references ASHRAE standards/guidelines that shape controls scope, sequences, or submittals. Concretely, reach for it when you see or need to answer questions involving:

- **ASHRAE 90.1** — energy code mandatory controls provisions (economizer, DCV, optimum start, SAT/static pressure reset, hydronic DP reset, metering)
- **ASHRAE 62.1** — ventilation rate procedure, ventilation ventilation minimums, CO2-based DCV
- **ASHRAE 55** — thermal comfort, PMV/PPD, deadband design
- **Guideline 36 / G36** — pre-engineered sequences of operation, trim-and-respond, zone groups, FDD
- **Standard 135 / BACnet**, **BACnet/SC**, BIBBs, PICS, BTL listing, device profiles (B-BC/B-AAC/B-ASC)
- **Division 23 09 00 / 25 00 00** spec sections, IECC, LEED EA credits, higher-ed master specs
- **Commissioning**: Standard 202, Guideline 0, Guideline 1.1, functional performance testing (FPT)
- Emerging stack: **223P** (semantic tagging), **231P** (CDL), **205** (equipment performance data), **207** (FDD lab test method)

**Typical triggers:** "check this spec against 90.1," "what does 62.1 require for DCV," "does this sequence meet G36," "what BTL profile do we need," "is our economizer high-limit table compliant," "what's the trim-and-respond math," "does this qualify for the LEED EA credit," "what commissioning standard does the spec cite."

**Skip when:** the question is general HVAC/mechanical theory with no code or spec angle (use `hvac-fundamentals`), or it's a pure EIKON/WebCTRL programming-syntax question with no compliance driver — cross-reference this skill's sequences but don't force a standards citation into unrelated troubleshooting.

## Standards Map

| Standard/Guideline | What It Governs | What It Means for the Controls Contractor |
|---|---|---|
| **90.1** (Energy Standard) | Mandatory HVAC controls: economizers, high-limit lockout, DCV thresholds, optimum start, setback/deadband, SAT reset, static pressure reset, hydronic DP reset, garage ventilation, energy metering/submetering | These are code-mandatory sequences, not value-engineering options. Confirm each is actually programmed, not just referenced. See [references/std-90-1-controls.md](references/std-90-1-controls.md). |
| **62.1** (Ventilation) | Ventilation Rate Procedure (Vbz, Voz, Ev), Zone Air Distribution Effectiveness, dynamic reset, CO2 DCV accuracy/failure modes | VAV minimums must be driven by calculated Voz, not an arbitrary % of cooling max. CO2 sensor DCV logic has explicit accuracy (±75 ppm) and fail-safe requirements. See [references/std-62-1-ventilation.md](references/std-62-1-ventilation.md). |
| **55** (Thermal Comfort) | PMV/PPD model, operative temperature, comfort zone method | Justifies deadband-based zone control (not single-setpoint). Radiant/humidity comfort complaints are distinct from dry-bulb deviations. See [references/comfort-and-cx.md](references/comfort-and-cx.md). |
| **Guideline 36** (Sequences) | Pre-engineered air-side/water-side sequences, trim-and-respond, zone groups, occupancy modes, VAV terminal sequences, rule-based FDD (FC1–FC15) | Larger point count than legacy sequences (damper feedback, DAT at every VAV box), non-legacy cascade control, override/test-mode hooks required for CxA. See [references/guideline-36.md](references/guideline-36.md). |
| **135** (BACnet) | Object/service model, BIBBs, PICS, BTL listing, device profiles, BACnet/IP vs MS/TP vs BACnet/SC | Verify device profile claims (B-BC/B-AAC/B-ASC) against actual BTL listing; evaluate BACnet/SC readiness for cybersecurity-sensitive campuses. See [references/std-135-bacnet.md](references/std-135-bacnet.md). |
| **Guideline 13** | BAS specification-writing guidance: architecture, network design, cybersecurity, legacy migration | The template many owner/university master specs are built from — cross-check network design and cybersecurity clauses against current scope. See [references/comfort-and-cx.md](references/comfort-and-cx.md). |
| **Standard 202 / Guideline 0 / Guideline 1.1** | Commissioning process framework (Communication/Documentation/Verification), OPR, FPT | Submittal → BTL/PICS review → install → FPT (exercising G36 override/test-mode points) → Cx report → O&M turnover. See [references/comfort-and-cx.md](references/comfort-and-cx.md). |
| **223P / 231P / 205 / 207** (emerging) | Semantic tagging (223P), Control Description Language (231P), equipment performance data model (205), FDD lab test method (207) | Not yet mandatory in most specs; monitor for future reduction in manual point-tagging and sequence re-engineering labor. See [references/comfort-and-cx.md](references/comfort-and-cx.md). |

## Workflow: Checking a Project Spec Against Applicable Standards

1. **Identify the spec sections in play.** Look for `23 09 00` / `23 09 23` (HVAC DDC, device/network requirements) and `25 00 00` (campus-wide integrated automation) — or federal `UFGS 23 09 00` / `25 10 10`. Confirm which edition year of each ASHRAE standard the spec cites (90.1-2019 vs 2022 materially changes DCV thresholds — see below).

2. **Check the BACnet requirements line-by-line against Standard 135.**
   - Does the spec require BTL listing? For which device tiers?
   - Does it specify device profiles (B-BC for network/building controllers, B-AAC for AHU-level, B-ASC for VAV/terminal)? Generic "BACnet compliant" language with no BIBB/profile specificity is a red flag — flag it back to the engineer.
   - Is BACnet/SC required or referenced for cybersecurity-sensitive projects (healthcare, higher-ed, government)? Check ALC controller line BTL/SC listing status.
   - Full detail: [references/std-135-bacnet.md](references/std-135-bacnet.md).

3. **Check sequences against Guideline 36.**
   - Does the spec cite G36 by section/clause number, or is it a bespoke sequence? If it cites G36, identify the **edition** (2018/2021/2024) and which optional addenda/strategies are called out (e.g., dehumidification strategy choice, fan-off-during-standby option).
   - Cross-check the point list: does the design include damper position feedback and discharge air temperature sensing at every VAV box? If not, G36-compliant cascade control cannot be implemented as specified — flag as a bid-scope gap.
   - Full detail: [references/guideline-36.md](references/guideline-36.md).

4. **Check mandatory 90.1 controls provisions are actually present in the sequence**, not just implied:
   - Economizer + integrated mechanical cooling + high-limit lockout type/setpoint by climate zone
   - DCV (know which edition's threshold table applies — see Quick Reference below)
   - Optimum start, setback/deadband
   - SAT reset and static pressure trim-and-respond
   - Hydronic DP reset
   - Energy monitoring/submetering scope (often missed — see below)
   - Full detail: [references/std-90-1-controls.md](references/std-90-1-controls.md).

5. **Check ventilation math against 62.1.** Confirm VAV minimum airflow setpoints are derived from calculated Voz (not a flat 30%-of-cooling-max legacy convention), confirm Ez values match the actual supply configuration/mode, and confirm CO2 DCV sensor accuracy/fail-safe behavior meets Addendum ab. Full detail: [references/std-62-1-ventilation.md](references/std-62-1-ventilation.md).

6. **Check comfort/deadband design against Standard 55**, and confirm the spec's commissioning section references Standard 202/Guideline 0 and requires FPT scripts that exercise G36's override/test-mode points. Full detail: [references/comfort-and-cx.md](references/comfort-and-cx.md).

7. **Check LEED/IECC linkage if referenced.** If the project targets LEED EA credits, the 90.1 Appendix G energy model assumptions (economizer, SAT reset, DCV, optimum start) must match what is actually programmed — any gap is a post-occupancy credit risk. IECC commercial paths often reference 90.1 directly as an alternative compliance path.

8. **Flag scope gaps immediately, not at submittal.** The most common under-bid items: G36 point-count/hardware delta, energy metering/submetering integration (90.1 Section 6.4.3/Section 11), BACnet/SC network redesign, and FPT/commissioning override programming.

## Key Compliance Thresholds — Quick Reference

| Item | Threshold / Value | Source |
|---|---|---|
| DCV trigger (90.1-2019 and earlier) | Zone >500 ft², design occupancy ≥25 people/1,000 ft², system w/ economizer, auto modulating OA damper, or OA capacity >3,000 cfm | [references/std-90-1-controls.md](references/std-90-1-controls.md) |
| DCV trigger (90.1-2022) | Table-based, keyed to climate zone + occupant airflow rate per 1,000 ft²; extends to moderate-density occupancies (e.g., retail) | [references/std-90-1-controls.md](references/std-90-1-controls.md) |
| DCV CO2 setpoint (90.1-2022 Addendum o) | Must match 62.1-2022 Addendum ab occupancy-type CO2 ceiling — not an arbitrary fixed ppm | [references/std-90-1-controls.md](references/std-90-1-controls.md) |
| CO2 sensor accuracy (62.1-2022 Addendum ab) | ±75 ppm at both 600 ppm and 1,000 ppm reference points | [references/std-62-1-ventilation.md](references/std-62-1-ventilation.md) |
| Optimum start | Mandatory for DDC systems w/ setback; function of space-temp deviation, OA temp, time-to-occupancy | [references/std-90-1-controls.md](references/std-90-1-controls.md) |
| Heating restart setpoint | ≥10°F below occupied heating setpoint | [references/std-90-1-controls.md](references/std-90-1-controls.md) |
| Cooling restart setpoint | ≥5°F above occupied cooling setpoint (or to control humidity) | [references/std-90-1-controls.md](references/std-90-1-controls.md) |
| Minimum thermostat deadband (tightened editions) | 1°F (down from historical 5°F) in some occupancy exceptions | [references/std-90-1-controls.md](references/std-90-1-controls.md) |
| Static pressure T&R increment (typical) | ±0.04 in. w.g. every ~2 min, band 0.15–1.5 in. w.g., "request" = damper wide open or airflow ratio <90% of setpoint | [references/guideline-36.md](references/guideline-36.md) |
| Hydronic DP reset ceiling | DP setpoint ≤ value corresponding to 110% of design flow; reset until ≥1 valve nearly wide open | [references/std-90-1-controls.md](references/std-90-1-controls.md) |
| Energy submetering building size threshold (90.1-2022) | ≥25,000 ft² requires separate measurement of total electrical, HVAC, interior lighting, exterior lighting, receptacle, refrigeration | [references/std-90-1-controls.md](references/std-90-1-controls.md) |
| Submetering data interval / retention | 15-min recording; hourly/daily/monthly/annual reporting; 36-month minimum retention | [references/std-90-1-controls.md](references/std-90-1-controls.md) |
| Tenant space submetering threshold | >10,000 ft² requires dedicated submetering | [references/std-90-1-controls.md](references/std-90-1-controls.md) |
| PMV comfort compliance band | -0.5 ≤ PMV ≤ +0.5 (≈≤10% PPD) | [references/comfort-and-cx.md](references/comfort-and-cx.md) |
| G36 request-based SAT reset trigger (typical) | Zone temp >3°C (5°F) above cooling setpoint for 2 min → 3 SAT-reset requests | [references/guideline-36.md](references/guideline-36.md) |
| G36 leaking valve fault | Heating valve at 0% for 15 min but discharge air temp >3°C (5°F) above AHU SAT with fan proven on → Level 4 alarm | [references/guideline-36.md](references/guideline-36.md) |
| Ez (Zone Air Distribution Effectiveness), typical VAV | 1.0 ceiling supply of cool air; can drop to 0.8 for ceiling supply of warm air under certain throw/ΔT conditions | [references/std-62-1-ventilation.md](references/std-62-1-ventilation.md) |
| VRP core equations | \(V_{bz} = R_p \cdot P_z + R_a \cdot A_z\); \(V_{oz} = V_{bz}/E_z\) | [references/std-62-1-ventilation.md](references/std-62-1-ventilation.md) |

## Reference Files

- **[references/guideline-36.md](references/guideline-36.md)** — Read when reviewing or writing a G36-based sequence: trim-and-respond math, zone groups/occupancy modes, VAV terminal sequence types, FDD fault rules (FC1–FC15), alarm suppression hierarchy, 2024 addenda, and known contractor implementation pain points.
- **[references/std-90-1-controls.md](references/std-90-1-controls.md)** — Read when checking mandatory energy-code controls provisions: economizer/high-limit tables, DCV thresholds (2019 vs 2022), optimum start, setback/deadband, SAT/static pressure reset, hydronic DP reset, garage ventilation, energy monitoring/submetering.
- **[references/std-62-1-ventilation.md](references/std-62-1-ventilation.md)** — Read when calculating or verifying ventilation rates: full VRP equations, Ez table values, CO2 DCV requirements, dynamic reset, and impact on VAV minimum airflow setpoints.
- **[references/std-135-bacnet.md](references/std-135-bacnet.md)** — Read when reviewing BACnet submittal requirements: object/service model, BIBBs/PICS, device profiles, BACnet/IP vs MS/TP vs BACnet/SC, BTL listing.
- **[references/comfort-and-cx.md](references/comfort-and-cx.md)** — Read when addressing thermal comfort design (Std 55 PMV/PPD/deadband), commissioning process flow (Guideline 13, Std 202, Guideline 0/1.1), the emerging 223P/231P/205/207 stack, and spec section flow-through (23 09 00 / 25 00 00) plus higher-ed master spec conventions.

## Worked Example: Reviewing a VAV AHU Sequence Against the Standards Map

A typical Division 23 09 93 sequence-of-operation submittal for a multi-zone VAV AHU should be checked in this order:

1. **Ventilation minimums (62.1).** Pull the zone-by-zone Voz values from the mechanical schedule. Confirm the VAV box minimum airflow setpoint in the sequence equals (or is derived from) Voz for that zone at the specified Ez, not a flat "30% of cooling max." If the AHU serves multiple zone groups with different Ez values (e.g., some zones on ceiling cool supply, others with warm-air throw considerations), confirm each zone group's Ez is applied individually — see [references/std-62-1-ventilation.md](references/std-62-1-ventilation.md).

2. **System-level OA intake (62.1 Appendix A).** For a multi-zone recirculating system, confirm the sequence documents how System Ventilation Efficiency (Ev) is calculated from the critical zone, and whether Ev is recalculated dynamically (dynamic reset) as the critical zone changes with load — this is where real energy savings show up and where G36's ventilation logic plugs in.

3. **Economizer and high-limit (90.1).** Confirm the high-limit control type (fixed dry bulb, differential dry bulb, fixed/differential enthalpy) and setpoint match the project's climate zone per Table 6.5.1.1.3, and that damper control does not rely on mixed-air temperature alone for setpoint (unless it's a single-zone, space-temperature-controlled system). Confirm fault reporting (sensor failure, "not economizing when should," "economizing when should not," damper not modulating, excess OA) is explicitly in the point list — see [references/std-90-1-controls.md](references/std-90-1-controls.md).

4. **DCV (90.1 + 62.1).** If zones qualify under the applicable edition's threshold table, confirm CO2 sensors are specified to ±75 ppm accuracy, that the DCV setpoint matches 62.1's occupancy-type CO2 ceiling (not an arbitrary fixed ppm), and that sensor failure defaults to design ventilation rate rather than failing low.

5. **Static pressure and SAT reset (90.1 + G36 trim-and-respond).** Confirm the sequence specifies actual trim/respond rates and min/max envelope (not just "reset based on demand"), and that "pressure request" and "SAT-reset request" trigger conditions are numerically defined, matching or exceeding 90.1's baseline expectations — see [references/guideline-36.md](references/guideline-36.md).

6. **Optimum start / setback (90.1).** Confirm restart setpoints (≥10°F below occupied heating, ≥5°F above occupied cooling) and that optimum start is a function of space temp, OA temp, and time-to-occupancy — not a fixed lead time.

7. **Zone groups, occupancy modes, and FDD (G36).** If the spec cites G36, confirm the submittal includes zone group tables, importance multipliers, and the FC1–FC15 fault rule set (or equivalent) with an alarm suppression hierarchy — not just the trim-and-respond math in isolation.

8. **BACnet submittal (135).** Cross-check the PICS for every controller tier against the profile the spec requires (B-BC network/building, B-AAC AHU-level, B-ASC terminal) and confirm current BTL listing — a device profile claim without a current BTL certificate should be flagged back to the submittal reviewer.

9. **Commissioning hooks (202/Guideline 0).** Confirm the sequence includes BAS-overridable points for every hardware point (G36 Section 5.1.11) and that the CxA's FPT scripts reference those override points by name — this is where early bid estimates most often miss programming scope.

## ALC / EIKON Implementation Notes

These standards translate into concrete WebCTRL/EIKON programming decisions, not just paperwork:

- **Trim-and-respond microblocks.** G36 static pressure and SAT reset logic maps to a Setpoint microblock driven by request-count logic rather than a simple PID loop — build a reusable EIKON macro for T&R (trim rate, response rate, ignore count, min/max clamps) once per project type rather than re-deriving it per AHU. Confirm the macro's request-count inputs (damper position feedback, airflow ratio) are wired from real hardware points, not simulated.
- **Zone group tables** in G36 are naturally modeled as a WebCTRL custom report or a database table keyed by AHU/zone-group ID, feeding importance multipliers into the Setpoint microblock's request math — this is a departure from legacy single-zone reset logic and should be templated early rather than repeated by hand across every AHU program.
- **DCV/Voz-based VAV minimums** require the ZN program's minimum airflow Setpoint to reference a calculated value (from the mechanical schedule's Voz, adjusted for Ez) rather than a hardcoded percentage — flag any legacy EIKON logic library block that still computes minimum airflow as `0.3 * cooling_max` for replacement.
- **BACnet device profile verification** happens at discovery: when running Site → Devices → Advanced → Start Discovery, cross-check each discovered device's reported object/service support against its PICS and the spec's required profile tier (B-BC/B-AAC/B-ASC) before building program/graphics — a mismatch here is far cheaper to catch at discovery than at commissioning.
- **FDD/override points** (G36 Section 5.1.11) mean every hardwired point in the ZN/AHU program needs an accessible override path in EIKON (and a corresponding graphic override control in ViewBuilder) — plan microblock count accordingly given the ~700 microblock ceiling per ZN program; G36 zone programs with full FDD, zone-group logic, and cascade control run measurably heavier than legacy single-loop VAV logic.
- **Metering integration** (90.1 Section 6.4.3) points (electrical, HVAC, lighting submeters) should be trended at the required 15-minute interval using WebCTRL's trend/report engine, with retention configured to meet the 36-month minimum — verify the report's row/column limits (max 50 columns / 1000 rows) don't truncate a full year of 15-minute interval data without an aggregation strategy.

## Common Mistakes

- **Treating "BACnet compliant" as a meaningful spec requirement.** It isn't, on its own — always tie down BIBBs, device profile (B-BC/B-AAC/B-ASC), and BTL listing status.
- **Sizing VAV minimums off a flat percentage of cooling max.** This is a pre-2004 convention that both 62.1 and G36 have superseded — use calculated Voz.
- **Assuming "G36 compliance" is a single fixed target.** It's a guideline with edition-specific addenda and optional strategies (dehumidification approach, fan-off-during-standby) — always confirm which edition and which options the spec actually cites.
- **Under-bidding G36 point count.** Damper position feedback and discharge air temperature sensing at every VAV box is a hardware/programming cost delta, not a free upgrade — capture it at take-off.
- **Missing the energy metering/submetering scope in 90.1-2019/2022.** This pulls meter data integration and graphic dashboards into BAS/Division 25 scope even when the RFP frames it as an "electrical" or "metering contractor" item.
- **Confusing DCV thresholds between 90.1-2019 and 90.1-2022.** The occupant-density trigger became a climate-zone/airflow-rate table in 2022 — verify which edition the project's adopted energy code cites before applying either threshold.
- **Ignoring alarm suppression hierarchy in G36 FDD.** Without it, a single AHU-level fault (e.g., fan failure) floods O&M with dozens of redundant VAV-level nuisance alarms — budget commissioning time to tune this before turnover.
- **Skipping edition verification.** ASHRAE standards are under continuous maintenance with addenda issued multiple times a year — always confirm the specific edition/addenda cited in the project's adopted code or spec before treating any threshold in this skill as final; re-verify against the governing jurisdiction's adopted edition before use in a stamped design document.
