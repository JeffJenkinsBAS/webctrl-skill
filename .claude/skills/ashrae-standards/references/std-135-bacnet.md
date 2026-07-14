# ASHRAE Standard 135 — BACnet

Read this file when reviewing BACnet-related submittal requirements, verifying device profile/BTL claims, choosing between BACnet/IP, MS/TP, and BACnet/SC for a network design, or evaluating cybersecurity requirements on institutional/campus projects.

## 1. Scope and Purpose

ANSI/ASHRAE Standard 135, *BACnet — A Data Communication Protocol for Building Automation and Control Networks*, defines the data communication services and protocols for computer equipment used to monitor and control HVAC&R and related building systems (fire, security, lighting, access control, elevators). It also defines an abstract, object-oriented representation of information communicated between devices, independent of vendor or hardware ([ASHRAE BACnet Bookstore](https://www.ashrae.org/technical-resources/bookstore/bacnet); [ANSI Blog](https://blog.ansi.org/ansi/bacnet-building-automation-ansi-ashrae-135/)).

Critically, per the standard's own boundaries, it defines *what* must be common across vendors (data structures, service behavior, object model) but explicitly does **not** dictate product quality, UI design, system architecture, or project-specific integration practices — those remain design and specification decisions ([Actility explainer on ASHRAE 135](https://www.actility.com/bacnet-ashrae-standard-135/)).

The current edition is **Standard 135-2020**, maintained under continuous addenda, and BACnet is also published internationally as **ISO 16484-5**.

## 2. Object and Service Model

BACnet's architecture rests on two foundational concepts ([ASHRAE, *BACnet Explained*](https://www.ashrae.org/file%20library/technical%20resources/bookstore/bacnet-explained-pt1.pdf)):

- **Object Model** — Every BACnet device is represented as a collection of standardized "objects," each with a unique `Object_Identifier` and a set of "properties" (e.g., `Present_Value`, `Units`, `Reliability`). All objects require `Object_Identifier`, `Object_Name`, and `Object_Type`. BACnet-2020 defines over **60 standard object types** (up from 18 in the original 1995 release), including Analog/Binary/Multistate Input-Output-Value, Schedule, Calendar, Notification Class, Trend Log, File, and — as of newer addenda — Network Security and Authentication objects.
- **Service Model** — A client-server messaging framework where an "A" (client) device requests information or action from a "B" (server) device. There are roughly **38–45 defined services** across five Interoperability Areas (IAs): **Data Sharing, Alarm and Event Management, Scheduling, Trending, and Device and Network Management** ([BACnet Explained](https://www.ashrae.org/file%20library/technical%20resources/bookstore/bacnet-explained-pt1.pdf); [DEOS AG BACnet overview](https://www.deos-ag.com/en/blog/bacnet-simply-explained/)).

### BIBBs and PICS

**BIBBs (BACnet Interoperability Building Blocks)** package one or more services into named, testable capability sets (e.g., `DS-RP-B` = Data Sharing–ReadProperty–B side). There are roughly **67 BIBBs** organized into the same five IA categories ([Achieving BACnet Compliance, ccontrol.com](https://www.ccontrol.com/pdf/Extv8n6.pdf)).

A manufacturer's **PICS (Protocol Implementation Conformance Statement)** documents exactly which BIBBs, object types, optional properties, and data link options a device supports — **this is the document a controls engineer should always request and cross-check during submittal review.**

## 3. Network / Data-Link Options: BACnet/IP vs. MS/TP vs. BACnet/SC

| Network Type | Physical Layer | Typical Use | Key Characteristics |
|---|---|---|---|
| **BACnet/IP** | Ethernet/IP (UDP port 47808) | Backbone/riser between building controllers, supervisory devices, servers | High bandwidth, uses BACnet Broadcast Management Devices (BBMDs) for cross-subnet broadcasts; unsecured by default |
| **MS/TP** (Master-Slave/Token-Passing) | RS-485, twisted pair | Field bus for terminal-level controllers (VAV boxes, zone controllers) | Token-passing arbitration, deterministic access, limited to ~76.8–115.2 kbps, distance/node-count limits |
| **BACnet/SC** (Secure Connect) | WebSocket/TLS over IP | Modern secure IP backbone, cloud-hosted or campus-wide networks | TLS 1.3 encrypted, hub-and-spoke topology, certificate-based mutual authentication, eliminates broadcasts |
| ARCNET, LonTalk, PTP | Legacy | Largely obsolete in new design | Retained in the standard for legacy compatibility only |

### BACnet/SC Detail

**BACnet/SC** was introduced via **Addendum bj to Standard 135-2016** and is now embedded in 135-2020. It fundamentally re-architects BACnet's network layer for IT/cybersecurity compatibility:

- Uses **WebSockets over TLS 1.3** (128- or 256-bit elliptic curve cryptography), eliminating the need for static IP addresses and network broadcasts entirely ([ASHRAE BACnet/SC whitepaper](https://www.ashrae.org/file%20library/technical%20resources/bookstore/bacnet-sc-whitepaper-v15_final_20190521.pdf); [ASHRAE news release on BACnet/SC](https://www.ashrae.org/news/esociety/protecting-building-automation-systems-with-bacnet-secure-connect)).
- Operates via a **hub-and-spoke topology**: a central BACnet/SC hub function directs traffic between any number of connected nodes, and the architecture is designed to allow future extensions to standard messaging protocols like MQTT.
- All connections are **mutually authenticated** — both hub and node must complete TLS certificate validation before any traffic is exchanged, addressing the long-standing IT/OT objection to placing unencrypted BACnet/IP devices on converged networks.
- Newer addenda (2020cp series, approved through **November 2024 / May 2025**) extend BACnet/SC with **Authentication and Authorization Services** (a new Clause 17), adding fine-grained, per-client permission scopes on top of the base TLS trust model — allowing devices to be treated with different authority levels rather than all-or-nothing network trust ([BACnet Committee addenda page](https://bacnet.org/addenda/); [135-2020cp PDF](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/135_2020_cp_20241129.pdf)).

**Design implication:** For new campus, healthcare, and higher-ed projects where IT/cybersecurity review is now standard practice, specifying BACnet/SC (or at minimum a documented transition path) is increasingly a differentiator in RFPs. ALC's WebCTRL/OptiFlex/ES-based device lines should be checked against current BTL/SC listing status per project.

## 4. BTL Listing

The **BACnet Testing Laboratories (BTL)**, operated under BACnet International, is the accepted third-party conformance-testing body. A device that has passed testing appears on the [BTL Listing of Tested Products](https://www.bacnetinternational.net/btl/). Listing verifies that a device actually implements the BIBBs/object types/services it claims in its PICS, per the test procedures defined in **ASHRAE/ANSI Standard 135.1**, *Method of Test for Conformance to BACnet* ([ANSI Blog on 135.1-2019](https://blog.ansi.org/ansi/bacnet-building-automation-ansi-ashrae-135/)).

Nearly all institutional and government specs (federal UFGS, university standards) mandate **BTL listing as a submittal requirement** for all BACnet devices — this is a routine but critical checkpoint in submittal review; **a device profile claim without a current BTL certificate should be flagged.**

## 5. Device Profiles (Annex L)

Device Profiles are named, minimum sets of BIBBs a device must support to claim a given classification. The profiles most relevant to controls contractor scope:

| Profile | Description | Typical Use |
|---|---|---|
| **B-OWS** | BACnet Operator Workstation — client-side software/head-end; queries and displays data from other devices, generally does not serve data itself | Operator workstation / head-end software |
| **B-BC** | BACnet Building Controller — full-featured supervisory/network controller; must support scheduling, alarm/event management, trending, device/network management, and typically routing | ALC network/building-level controllers (e.g., OptiFlex line building controllers) |
| **B-AAC** | BACnet Advanced Application Controller — full-featured field controller with alarm/event, trending, and read/write property multiple support, but generally not scheduling or full routing | AHU/RTU-level application controllers |
| **B-ASC** | BACnet Application Specific Controller — limited-resource controller for a specific application; minimum requirement is only ReadProperty/WriteProperty and basic device/network management responses — no required alarm, scheduling, or trend capability | VAV box or unitary controller |

([Beijer Electronics BACnet profile documentation](https://www.beijerelectronics.com/docs/DIO/GN-9251/en/bacnet-interface.html); [txaee.org Guideline 36 presentation cites B-ASC minimums](https://www.scribd.com/document/578573216/BACnet-Testing-Laboratories-BTL-DDC-controller-profiles))

Additional profiles exist for smart actuators/sensors (**B-SA**, **B-SS**), routers (**B-RTR**), gateways (**B-GW**), and BBMDs (**B-BBMD**) — relevant when integrating third-party VFDs, chillers, or lighting systems via BACnet gateway.

**Design/spec implication:** Project specs should explicitly call out required device profile per controller tier (e.g., "network/building controllers shall be BTL-Listed B-BC minimum; terminal unit controllers shall be BTL-Listed B-ASC minimum") rather than generically requiring "BACnet compliant," which has no enforceable meaning on its own.

## 6. Addenda Relevant to Modern Projects

- **Addendum bj (135-2016) → BACnet/SC** — foundational secure networking addendum (2019).
- **135-2020cp series (Authentication & Authorization Services)** — approved November 2024 and May 2025, layering fine-grained access control on top of BACnet/SC's TLS trust model, including new Device Object properties, error codes, and data structures ([BACnet Committee](https://bacnet.org/addenda-category/ashrae-135-the-bacnet-standard/)).
- **135-2020cm-1 (BACnet Energy Services Interface)** — adds standardized objects/services for demand response and energy transaction signaling, relevant to utility DR programs and grid-interactive efficient building (GEB) initiatives.
- Ongoing work on **Who-Am-I/You-Are services**, extended **BACnet/WS (RESTful web services)** with JSON and expanded XML/Annex Q data models — these point toward tighter integration between BACnet devices and cloud/IT-native analytics platforms, an area directly overlapping with Standard 223P (semantic data) — see [references/comfort-and-cx.md](comfort-and-cx.md) Section 3.

## 7. Submittal / Discovery Checklist

- Confirm BTL listing certificate is current for every claimed BACnet device.
- Confirm PICS statements match spec-required BIBBs and object types line-by-line — do not accept "BACnet compliant" as sufficient language.
- Confirm device profile tier (B-BC/B-AAC/B-ASC) matches the controller's role in the network hierarchy.
- For cybersecurity-sensitive campuses, confirm BACnet/SC readiness or an explicit migration path, and check whether the spec requires network segmentation / no direct internet exposure for legacy BACnet/IP devices.
- During WebCTRL discovery (Site → Devices → Advanced → Start Discovery), cross-check each discovered device's actual reported services/objects against its PICS before building program/graphics — catching a mismatch here is far cheaper than catching it at commissioning.
