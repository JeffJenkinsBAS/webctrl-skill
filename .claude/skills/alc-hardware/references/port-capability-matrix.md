# Port & Controller Capability Matrix (ACI-Verified)

Source of truth: the ACI BAS Network Lab Controller Verification Workbook (`capability_matrix.txt`, 128/128 rows Confirmed by TI cross-check). **Where this matrix conflicts with an Automated Logic Technical Instructions (TI) PDF, the matrix wins** — conflicts are called out explicitly below. Reference [automatedlogic.com](https://www.automatedlogic.com/) for the underlying TI documents.

Read this file when you need exact per-port protocol support, simultaneous-use rules, or licensed capacity numbers — not just the "can it do X" summary in SKILL.md.

---

## 1. Controller-Level Capability Table

| Model | Category | Min. WebCTRL | Ethernet Ports | BACnet Router | BBMD | MS/TP | ARC156 | Modbus RTU | Modbus TCP | Rnet (max) | Act Net (max) | I/O Bus (max) | Xnet (max) | 3rd-Party BACnet Pts | Modbus Pts | Combined Limit | Programs |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| G5CE | Router/Integrator | 6.5 | 1 | Yes | Yes | S1 or S2 | S1 only | S1 or S2 | Yes | 15 | 0 | 0 | 0 | 1500 | 25 | 1525 | 999 |
| G5RE | Router/Integrator | 6.5 | 1 | Yes | Yes | S1 or S2 | S1 only | No | No | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| OFISO-E2 | Router/Integrator | 9 | 2 | Yes | Yes | S1 or S2 | S1 only | No | No | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| OFCSR-E2 | Router/Integrator | 9 | 2 | Yes | Yes | S1 only | S1 only | No | No | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| OFHI-A | Router/Integrator | 6.5 | 1 | Yes | Yes | S1 or S2 | S1 only | S1 or S2 | Yes | 15 | 0 | 0 | 0 | 1500 | 1000 | 2500 | 999 |
| OFINT-E2 | Router/Integrator | 9 | 2 | Yes | Yes | S1 or S2 | S1 only | S1 or S2 | Yes | 0 (future use) | 0 | 0 | 0 | 5000 shared | 5000 shared | 5000-pt shared FlexPoint pool (100 built-in + 4,900 purchasable) | 999 |
| OFBBC-A | Building Controller | 6.5 | 1 | Yes | Yes | S1 or S2 | S1 only | S1 or S2 | Yes | 15 | 0 | 9 FIO | 6 MEx | 1500 | 200 | 1700 | 999 |
| OFBBC-NR | Building Controller | 6.5 | 1 | No | Yes | S1 only | S1 only | S1 or S2 | Yes | 15 | 0 | 9 FIO | 6 MEx | 1500 | 200 | 1700 | 999 |
| OF1628 | Building Controller | 6.5 | 1 | Yes | Yes | S1 or S2 | S1 only | S1 or S2 | Yes | 15 | 8 | 9 FIO | 0 | 1500 | 200 | 1700 | 999 |
| OF1628-NR | Building Controller | 6.5 | 1 | No | Yes | S1 or S2 | S1 only | S1 or S2 | Yes | 15 | 8 | 9 FIO | 0 | 1500 | 200 | 1700 | 999 |
| OF028-NR | Building Controller | 6.5 | 1 | No | Yes | S1 or S2 | S1 only | S1 or S2 | Yes | 15 | 8 | 9 FIO | 0 | 1500 | 200 | 1700 | 999 |
| OF141-E2 | Equipment Controller | 7 | 2 | No | No | N/A | N/A | N/A | No | 5 | 5 | 0 | 0 | 100 (BACnet/IP only) | 0 | 100 | 1 |
| OF342-E2 | Equipment Controller | 7 | 2 | No | No | N/A | N/A | N/A | No | 10 | 5 | 0 | 0 | 100 (BACnet/IP only) | 0 | 100 | 1 |
| OF253T-E2 | Equipment Controller | 7 | 2 | No | No | N/A | N/A | S1 | Yes | 5 | 5 | 0 | 0 | 300 | 50 | 350 | 1 |
| OF253A-E2 | Equipment Controller | 7 | 2 | No | No | N/A | N/A | N/A | No | 5 | 5 | 0 | 0 | 100 (BACnet/IP only) | 0 | 100 | 1 |
| OF561-E2 | Equipment Controller | 7 | 2 | No | No | N/A | N/A | N/A | No | 5 | 5 | 0 | 0 | 100 (BACnet/IP only) | 0 | 100 | 1 |
| OF561T-E2 | Equipment Controller | 7 | 2 | No | No | S1 only | No | S1 only | Yes | 5 | 5 | 0 | 0 | 300 | 50 | 350 | 1 |
| OF022-E2 | Equipment Controller | **8** | 2 | No | No | N/A | N/A | N/A | No | 5 | N/A (no Act Net) | 0 | 0 | **25** (matrix-corrected) | 0 | 25 | 1 |
| OF683-E2 | Equipment Controller | 7 | 2 | No | No | N/A | N/A | N/A | No | 5 | 5 | 0 | 0 | 100 (BACnet/IP only) | 0 | 100 | 1 |
| OF683T-E2 | Equipment Controller | 7 | 2 | Yes | No | S1 only | No | S1 or S2 | Yes | 10 | 5 | 0 | 0 | 300 | 80 | 380 | 2 |
| OF683XT-E2 | Equipment Controller | 7 | 2 | Yes | No | **S1 (matrix)** | No | S1 | Yes | 10 | 5 (no 4–5 OptiPoint) | 1 OFX48 | 0 | 300 | 50 | 350 | 2 |
| FIO812u | Expansion Module | Host-restricted | 0 | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A | Yes | No | N/A | N/A | N/A | N/A |
| FIO88u | Expansion Module | Host-restricted | 0 | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A | Yes | No | N/A | N/A | N/A | N/A |
| FIO48u | Expansion Module | Host-restricted | 0 | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A | Yes | No | N/A | N/A | N/A | N/A |
| FIO012u | Expansion Module | Host-restricted | 0 | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A | Yes | No | N/A | N/A | N/A | N/A |
| OFX48 | Expansion Module | 7.0 (OF683XT-E2 only) | 0 | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A | Yes (1 host) | No | N/A | N/A | N/A | N/A |

**Gap flag:** No matrix row exists for **OFRTR-E2-S2** — treat its capacity/limit figures (documented in `references/device-details.md`) as PDF-sourced only, not matrix-confirmed, until ACI adds a verified row.

---

## 2. Onboard I/O Summary (Controller-Level)

| Model | Universal Inputs | Analog Out | Binary Out | Universal Out |
|---|---|---|---|---|
| OF1628 | 28 | — | — | 16 UO |
| OF028-NR | 28 | — | — | 0 |
| OF141-E2 | 4 | 1 | 1 | — |
| OF342-E2 | 4 | 2 | 3 | — |
| OF253T-E2 / OF253A-E2 | 5 | 2 | 2 | 1 |
| OF561-E2 / OF561T-E2 | 6 | — | 5 (2 banks: 3+2) | 1 |
| OF022-E2 | 2 | 2 | — | — |
| OF683-E2 / OF683T-E2 / OF683XT-E2 | 8 | 2 | 6 (2 banks: 3+3) | 1 |
| FIO812u | 12 | — | — | 8 |
| FIO88u | 8 | — | — | 8 |
| FIO48u | 8 | — | — | 4 |
| FIO012u | 12 | — | — | 0 |
| OFX48 | 8 | — | — | 4 |

---

## 3. Act Net Reserved Addressing (Every Act Net-Capable Controller)

Act Net address reservations are **fixed across the entire family** except where noted:

| Address | Reserved For |
|---|---|
| **1** | Built-in actuator (zone controllers) or Automated Logic actuator (683/561T/1628 family) |
| **2–3** | ZASF-A |
| **4–5** | OptiPoint Smart Valve — **present on OF141-E2, OF342-E2, OF253T-E2, OF253A-E2, OF561-E2, OF561T-E2, OF683-E2, OF683T-E2, OF1628/OF028-NR family. NOT present on OF683XT-E2** (matrix omits the 4–5 reservation for this specific part — do not assume OptiPoint support at 4–5 on the XT variant). |

- Max Act Net devices: **5** on all zone/equipment controllers except OF342-E2 (**10**) and OF1628/OF028-NR family (**8**).
- OF022-E2, OFBBC-A/OFBBC-NR, OFHI/OFHI-A, OFRTR-E2-S2, OFISO-E2, OFINT-E2 have **no Act Net port at all** — never spec an OptiPoint Smart Valve or ZASF-A against these parts.
- Act Net wiring: 18 AWG+ copper, 300 ft max, dedicated Class 2 supply (never share the host's 24 Vac transformer).

---

## 4. Simultaneous-Use Restrictions (Physical Ports)

| Port | Restriction |
|---|---|
| S1 (all EIA-485-equipped models) | **One protocol configuration at a time** — ARCNET, MS/TP, or Modbus RTU (or third-party serial on OFINT-E2). Cannot run two protocols on S1 simultaneously. |
| S2 (all EIA-485-equipped models) | Same rule — one protocol at a time (MS/TP or Modbus RTU, never ARCNET on S2). |
| Ethernet (Gig-E/dual-Eth models) | Ethernet-based protocols (BACnet/IP, BACnet/Ethernet, Modbus TCP, third-party IP gateways) **share the same physical interface** — no separate physical run needed, but only one BACnet communication type can be the routed type on non-routing (**-NR**) models. |
| OF683T-E2 Port S2 | **Permanently terminated at the factory** — must be placed at the physical end of its Modbus segment; termination cannot be switched off. |
| OFBBC-NR / OF1628-NR / OF028-NR Ethernet | Only one port can be configured for a BACnet communication type; the Gig-E port can run Modbus simultaneously with either BACnet/IP or BACnet/Ethernet. |

---

## 5. Field-Use Notes (Verbatim Context from ACI Matrix)

- **G5RE** — *"Routing only, no control programs can be held, we don't use these."* Rarely deployed in the field — default to G5CE/OFHI-A/OFISO-E2/OFINT-E2 depending on scope.
- **OFISO-E2** — *"Used to separate customer IP network from our own IP network. Routes BACnet traffic back to server."* The **Isolated Port** carries ACI's private controller network; the **Primary Port** faces the customer/WebCTRL server network. Never expose the Isolated Port as a general LAN drop.
- **OFINT-E2** — *"The Rnet terminal is labeled for future use and should not be exposed as a usable Rnet connection in the training library."* Treat this as a hard documentation rule — **never** document or wire OFINT-E2's Rnet terminal as usable.
- **OFCSR-E2** — *"Used to segment networks, provides BACnet routing between any supported BACnet communication types."* Only has Port S1 (no S2) — the S2 row was flagged for removal from the training library during matrix verification.
- **OF683XT-E2** — OFX48 "is an I/O Bus expander, not an Xnet device," and is supported as **a single expander on OF683XT-E2 only** — never spec it against OFBBC/OF1628/OF028 (those use FIO/MEx instead).

---

## 6. 5,000-Point FlexPoint Licensing (OFINT-E2)

- Base capacity: **100 built-in FlexPoints.**
- Licensable up to **4,900 additional points**, for a **5,000-point shared FlexPoint maximum.**
- The 5,000-point ceiling is a **shared pool across every active third-party protocol integration** on the device (BACnet third-party gateway points AND Modbus gateway points draw from the same pool) — it is not 5,000 points per protocol.
- Plan licensing purchases against total third-party point count across all integrations on that OFINT-E2, not per-integration.

---

*Compiled from the ACI BAS Network Lab Controller Verification Workbook (`capability_matrix.txt`, 128/128 rows confirmed by TI cross-check) plus Automated Logic Technical Instructions cross-referenced in `references/device-details.md`. Where the matrix and a TI PDF disagree, this file documents the matrix-authoritative value — flagged inline. Reference [automatedlogic.com](https://www.automatedlogic.com/) for source TI documents.*
