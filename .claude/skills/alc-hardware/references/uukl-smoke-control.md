# UUKL / UL 864 Smoke Control System (SCS) Reference

Source: Automated Logic/Carrier UUKL SCS documentation (UL 864 10th Edition, Rev. 8/18/2023 unless noted) for `WebCTRL_SCS`, `OF342-E2`, `OF253A-E2`, `OF683T-E2`, `OF1628`, `OFBBC`, `OFHI`, `FIO812u`, `FIO012u`. Reference [automatedlogic.com](https://www.automatedlogic.com/) for the underlying documents.

**Read this file before specifying, wiring, or commissioning any ALC controller into a fire/life-safety smoke control system.** UUKL listing rules are more restrictive than standard field practice in several places — a normal (non-SCS) wiring pattern that's fine on a comfort-only job can be a code violation on a smoke control job.

---

## 1. Scope

- ALC/UUKL listing covers **non-dedicated** smoke control systems only — shared HVAC/smoke equipment that changes mode during a fire/smoke event.
- **Dedicated** systems (separate smoke-only equipment) are **out of scope** for ALC/UUKL listing — do not represent ALC hardware as UUKL-compliant on a dedicated-system job.
- Non-dedicated systems require **annual** testing at minimum; occupant comfort complaints between tests should trigger inspection/repair.
- **Caution — no weekly self-test is defined in ALC's UUKL documentation.** Only annual/periodic testing is specified. If a "weekly self-test" requirement is cited for a job, it comes from another source (e.g., NFPA 92 or the physical UL 864 standard text) — do not attribute a weekly self-test to Automated Logic's UUKL documents.

---

## 2. UL 864 Timing Requirements

| Requirement | Value | Citation |
|---|---|---|
| Smoke control sequence activation after fire alarm | ≤ **10 sec** | UL 864 §59.2.a |
| Fan response time to reach desired state | **60 sec** (worst-case calc example ≈ 38 sec) | UL 864 §59.2.c |
| Damper response time to reach desired position | **75 sec** (worst-case calc example ≈ 68 sec) | UL 864 §59.2.c |
| Failure signal to FSCS after proof-sensor detects failure | ≤ **10 sec** | — |
| Max total system response time | **200 sec** | — |
| Max restoration time (trouble → FSCS annunciation) | **200 sec** | — |
| Trouble-delay programmable range | 00:00–03:20 (mm:ss) | — |
| UL 864 permitted trouble-delay setting range | **02:45–03:00 (mm:ss)** | — |

**Caution — flagged discrepancy, do not silently resolve:** the system documentation's end-to-end verification section (§1.18 of source) appears to **reverse** the fan/damper time pairing shown in the primary requirements table above — stating damper=60 sec/fan=75 sec instead of fan=60 sec/damper=75 sec. Verify the correct pairing against the physical UL 864 standard text before citing an authoritative fan-vs-damper response time on a real job.

Each fan requires a **differential pressure monitor**; each smoke damper (UL 555S) requires **end-position switches** for positive open/closed proof, per NFPA 92.

---

## 3. FSCS (Firefighters' Smoke Control Station) Requirements

- **Approved models only:** H.R. Kirkland **RSC-GR** (hardwired I/O) or Automation Displays **ATL-XXXXX** (hardwired or Modbus serial I/O). No other FSCS model is UUKL-compliant with ALC controls.
- **Location rule (UL 864 §59.3):** FSCS must be in the **same room** as the interfacing controller, wiring in **conduit**, within **20 feet** of that controller. This 20 ft/same-room/conduit rule repeats throughout SCS wiring — treat it as the default distance limit for any SCS-critical interface unless a specific device doc states otherwise.
- **Control priority:** FSCS is **highest priority** — overrides HOA switches, start-stop switches, freeze protection, and duct smoke detectors. It does **NOT** override electrical overload protection, personal-safety devices, or major-equipment-damage protection. Motor-controller disconnects in authorized-personnel-only rooms are exempt from FSCS override.
- Circuit board part number: **EP-1012**.

## 4. FACP (Fire Alarm Control Panel) Requirements

- Must be **Edwards EST-4** — no other FACP model is documented as compliant.
- Same 20 ft/same-room/conduit rule as FSCS (UL 864 §59.3).
- Alarm inputs must route through the **FSB-PC4** bridge module — **never wire pull stations directly** into the ALC SCS interface.

---

## 5. Network Architecture Constraints (SCS-Specific — Stricter Than Standard Jobs)

- **BACnet routers: only OFBBC or OF1628 are permitted** for smoke control network routing. No other router/integrator part (G5RE, G5CE, OFHI-A, OFCSR-E2, OFISO-E2, OFINT-E2, OFRTR-E2-S2) is UUKL-listed for this role.
- **Expander modules: only FIO812u or FIO012u are permitted.** Must be within **20 ft** of the BACnet router via Xnet, with conduit required if not in the same enclosure as the router.
- **Control modules (UUKL listed):** OF1628, SE6166, ZN341A.
- **Master-controller-capable (can retain the "core program"):** OF1628, OFBBC, OFHI, OF342, OF253A, OF683T.
- **Environmental range for controllers:** 32–120°F (0–49°C), 93% RH non-condensing — narrower than the standard -40 to 158°F outdoor rating used elsewhere in the ALC lineup. Do not spec SCS controllers for outdoor/unconditioned enclosures expecting the wider standard range.
- **Ethernet:** CAT5/CAT6 through a **UL 864 listed switch/hub** (recommended **CTRLink EIS8-100T**), max segment length **1000 ft (305 m)** at 22 AWG.
- **S1/S2 EIA-485 to third-party UL 864 device:** max **1000 ft**, minimum **76,800 baud**, max **32 devices per segment** — use a **REP485** repeater (file S6002) to exceed 32 devices; max 4 REP485 units in series.

---

## 6. Firmware Whitelist (Mandatory)

**Only these module drivers are UUKL-certified. No other driver/firmware version is compliant on a smoke control job:**
- `drv_fwex.107.06.xxxx`
- `drv_se_6-06-041.driver`
- `drv_zna_6-06-041.driver`

End users must **not** update firmware via memory download or module replacement on a UUKL-listed system (UL 864 §54.2.1). Any firmware change on a live SCS job must go through a controlled re-verification process, not a routine field update.

---

## 7. PROT485 — Hard Restriction (Reverses Normal Practice)

**PROT485 surge protection must NOT be used on the SCS communication port of any device with EIA-485 ports** — this is explicitly stated across OF1628, OFBBC, OFHI, OF342, OF253A, and OF683T documentation.

This directly **contradicts standard (non-SCS) practice**, where PROT485 is required at every point EIA-485 wiring enters or exits a building. On a smoke control job, do not apply the normal PROT485 rule to SCS comm ports — use it only at the equipment-enclosure level per §1.11 of the source system documentation, never directly on an SCS device's communication port.

---

## 8. Heartbeat / Redundancy (Mandatory)

- Every control module needs a heartbeat generator — `hb_uukl.eiw` monitored by `cnt_uukl.eiw` (Central Command, which also watches reset conditions per `fac_uukl.eiw`).
- If the FSCS control module loses communication, a **secondary parallel-wired module must trigger the System Trouble LED** — redundancy is mandatory, not optional, on a UUKL job.

---

## 9. Per-Device SCS Deltas

Only what differs from a standard (non-SCS) install is listed. Full standard specs live in `references/device-details.md`.

| Device | Rnet SCS Status | Act Net / Xnet SCS Status | AC Power | DC Power | Fuses | Notes |
|---|---|---|---|---|---|---|
| **OF342-E2** | Not for SCS use | Act Net: restricted to same room/20 ft/conduit, **steel enclosure required** | 50 VA | 18 W | — | Touchscreen not listed for SCS (service-tool only) |
| **OF253A-E2** | Not for SCS use | Act Net: **fully excluded** from SCS (stricter than OF342's "restricted") | 55 VA | 20 W | — | Only 2 binary outputs (fewer than OF342/OF683T's 3) |
| **OF683T-E2** | Not for SCS use | Act Net: restricted, steel enclosure required | 55 VA | 20 W | — | Modbus S1: default 38.4 kbps, but **suggest ≥76.8 kbps for UUKL use**; 2 banks of 3 BO |
| **OF1628** | Not for SCS use | Act Net: restricted **and** "Not Listed for UUKL use" (addressing itself flagged, not just the wiring) | 100 VA | 48 W | 2.5A device + 4A I/O edge | S1/S2 recommend ≥76.8 kbps; supports 9 FIO expanders; ARCNET dropped on serial prefix **ICD** (from July 2022) |
| **OFBBC** | Not for SCS use | **Xnet explicitly "not for use within Smoke Control applications"** (unique delta — OF1628 doesn't call out Xnet separately) | 50 VA | 15 W | 2A device + 4A I/O edge | S1/S2 recommend ≥76.8 kbps; ARCNET dropped on serial prefix **HR3** (from July 2022) |
| **OFHI** | Not for SCS use | No FIO/Xnet ports at all — no expander support | 50 VA | 15 W | Single 2A fuse (no I/O edge connector) | S1/S2 suggest ≥76.8 kbps; ARCNET dropped on serial prefix **RT5** (from July 2022) |
| **FIO812u** | N/A | Outputs must be wired within 20 ft, in conduit (SCS-specific restriction not present in generic spec) | 50 VA | 12 W | 2A device + 4A I/O edge | Must mount in a UL-listed **"Smoke Control" equipment enclosure** specifically |
| **FIO012u** | N/A | Input-only (0 outputs) | 50 VA | 12 W | 2A device + 4A I/O edge | Generic "UL Listed enclosure" wording (not "Smoke Control"-specific like FIO812u) — inconsistency noted, verify before treating the distinction as meaningful |

**Universal rules across every SCS device:**
- Same-room installation, 20 ft, in conduit — repeats for router-to-expander, controller-to-FSCS/FACP, and multiple port restrictions.
- Regulated Class 2 UL 864 Listed DC Power Supply required for any DC-powered install.
- UL 1449 Listed AC Surge Suppressor required before the transformer primary — **except OFBBC**, whose documentation uses "Peak Discharge minimum 200A" phrasing instead of the 40 kA/20 kA discharge-current format used elsewhere (see caution below).
- Equipment enclosure NEMA1/size/VA rules are identical across all 9 documented SCS devices (min 12"H×16"W×6.62"D, max 60"H×36"W×12"D; ≤20"H×24"W×6.62"D enclosures capped at 50 VA total; larger enclosures capped at enclosure volume ft³ × 20 VA/ft³).

---

## 10. Flagged Open Items — Preserve as Explicit Cautions

These are unresolved discrepancies in the source documentation. **Do not silently resolve them — flag them when they come up in a real job:**

1. **No weekly self-test is defined anywhere in ALC's UUKL documentation.** Only annual/periodic testing is specified for non-dedicated systems. Don't attribute a weekly self-test requirement to these ALC docs if a customer or AHJ references one — it must come from another source (NFPA 92, physical UL 864 text, or a separate WebCTRL software feature).
2. **Fan/damper response-time pairing may be reversed between the system doc's §1.4 (primary requirements table: fan=60 sec, damper=75 sec) and §1.18 (end-to-end verification section, which appears to state the pairing the other way).** Verify against the physical UL 864 standard text before citing an authoritative number for a specific equipment type.
3. **OFBBC's AC surge-suppression spec uses "Peak Discharge minimum 200A" phrasing**, while every other SCS device (OF1628, OFHI, FIO812u, FIO012u, OF342, OF253A) uses a 40 kA max-discharge/20 kA nominal-discharge format. This is likely a documentation inconsistency rather than an intentional device-specific difference — verify against the original OFBBC device manual before treating either value as a firm spec.
4. **OFBBC's own documentation states its FIO expander draws 100 VA (AC)**, while FIO812u/FIO012u's own nameplate specs state 50 VA AC / 12 W DC. This likely reflects total combined power-budget language in the OFBBC doc rather than true per-unit draw — verify before using either number for capacity planning on a real enclosure/transformer sizing exercise.

---

*Compiled from Automated Logic/Carrier UUKL SCS Technical Instructions (UL 864 10th Edition, Rev. 8/18/2023 unless noted) for `WebCTRL_SCS`, `OF342-E2`, `OF253A-E2`, `OF683T-E2`, `OF1628`, `OFBBC`, `OFHI`, `FIO812u`, and `FIO012u`. Reference [automatedlogic.com](https://www.automatedlogic.com/) for source documents — always verify against the current Partner Community revision and the physical UL 864 standard before treating a flagged open item as resolved.*
