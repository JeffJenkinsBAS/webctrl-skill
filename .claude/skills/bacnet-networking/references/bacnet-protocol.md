# BACnet Protocol Reference — Object/Service Model, BIBBs, Profiles, PICS, BTL

Deep-dive reference for BACnet's data model and conformance framework. Read this when reviewing submittals, scoping a device's actual capability, or explaining why a "BACnet compliant" claim on a cutsheet isn't enough on its own.

## 1. Object and Service Model

BACnet's architecture rests on two foundational concepts ([ASHRAE, *BACnet Explained*](https://www.ashrae.org/file%20library/technical%20resources/bookstore/bacnet-explained-pt1.pdf)):

- **Object Model** — Every BACnet device is represented as a collection of standardized "objects," each with a unique `Object_Identifier` and a set of "properties" (e.g., `Present_Value`, `Units`, `Reliability`). All objects require `Object_Identifier`, `Object_Name`, and `Object_Type`. BACnet-2020 defines over 60 standard object types (up from 18 in the original 1995 release), including Analog/Binary/Multistate Input-Output-Value, Schedule, Calendar, Notification Class, Trend Log, File, and — as of newer addenda — Network Security and Authentication objects.
- **Service Model** — A client-server messaging framework where an "A" (client) device requests information or action from a "B" (server) device. There are roughly 38–45 defined services across five Interoperability Areas (IAs): **Data Sharing, Alarm and Event Management, Scheduling, Trending, and Device and Network Management** ([BACnet Explained](https://www.ashrae.org/file%20library/technical%20resources/bookstore/bacnet-explained-pt1.pdf); [DEOS AG BACnet overview](https://www.deos-ag.com/en/blog/bacnet-simply-explained/)).

Practical implication: when a controller "doesn't see" a point, the first question is whether the object even exists on the target device (wrong Object_Identifier or Object_Type assumption), not whether the network is broken.

## 2. BIBBs and PICS

**BIBBs (BACnet Interoperability Building Blocks)** package one or more services into named, testable capability sets (e.g., `DS-RP-B` = Data Sharing–ReadProperty–B side). There are roughly 67 BIBBs organized into the same five IA categories ([Achieving BACnet Compliance, ccontrol.com](https://www.ccontrol.com/pdf/Extv8n6.pdf)).

A manufacturer's **PICS (Protocol Implementation Conformance Statement)** documents exactly which BIBBs, object types, optional properties, and data link options a device supports. **Always request and cross-check the PICS during submittal review** — it is the single document that turns a vague "BACnet compliant" cutsheet claim into a verifiable list of what the device actually does.

PICS review checklist:
- [ ] Confirm the data link option matches the job (BACnet/IP, MS/TP, ARC156, BACnet/SC)
- [ ] Confirm the BIBBs list actually includes what the spec requires (e.g., does it claim COV-B if the design depends on confirmed COV?)
- [ ] Confirm the object types list includes everything the point list needs (e.g., Trend Log objects if on-device trending is required)
- [ ] Cross-check the claimed Device Profile (Section 4 below) against the actual BIBBs list — a device can under-deliver relative to its profile name if the PICS wasn't updated

## 3. BTL Listing

The **BACnet Testing Laboratories (BTL)**, operated under BACnet International, is the accepted third-party conformance-testing body. A device that has passed testing appears on the [BTL Listing of Tested Products](https://www.bacnetinternational.net/btl/). Listing verifies that a device actually implements the BIBBs/object types/services it claims in its PICS, per the test procedures defined in **ASHRAE/ANSI Standard 135.1**, *Method of Test for Conformance to BACnet* ([ANSI Blog on 135.1-2019](https://blog.ansi.org/ansi/bacnet-building-automation-ansi-ashrae-135/)).

Nearly all institutional and government specs (federal UFGS, university standards) mandate **BTL listing as a submittal requirement** for all BACnet devices — this is a routine but critical checkpoint in submittal review. **A device profile claim without a current BTL certificate should be flagged** before the submittal goes out the door.

G5RE, for reference, conforms to the BACnet Router (B-R-TR) profile per ANSI/ASHRAE 135-2012 Annex L, Protocol Revision 14, and supports BBMD and Foreign Device Registration for cross-subnet BACnet/IP routing ([ALC vendor research](/home/user/workspace/research/alc_webctrl_vendors.md)).

## 4. Device Profiles (Annex L)

Device Profiles are named, minimum sets of BIBBs a device must support to claim a given classification. The profiles most relevant to controls contractor scope:

| Profile | Full Name | Typical Role | Required Capability Floor |
|---|---|---|---|
| **B-OWS** | BACnet Operator Workstation | Client-side software/head-end (e.g., WebCTRL server) | Queries and displays data from other devices; generally does not serve data itself |
| **B-BC** | BACnet Building Controller | Full-featured supervisory/network controller | Scheduling, alarm/event management, trending, device/network management, typically routing. This is the profile claimed by ALC network/building-level controllers (e.g., OptiFlex building controllers) |
| **B-AAC** | BACnet Advanced Application Controller | Full-featured field controller | Alarm/event, trending, read/write property multiple — but generally not scheduling or full routing. Typical of AHU/RTU-level application controllers |
| **B-ASC** | BACnet Application Specific Controller | Limited-resource controller for a specific application | Minimum is only ReadProperty/WriteProperty and basic device/network management responses — no required alarm, scheduling, or trend capability. Typical of a VAV box or unitary controller |
| **B-SA / B-SS** | Smart Actuator / Smart Sensor | Actuators, sensors | Minimal, application-specific |
| **B-RTR** | Router | Network bridging device | Routing between network numbers; may include BBMD |
| **B-GW** | Gateway | Third-party protocol bridge | Used when integrating non-BACnet devices (VFDs, chillers, lighting) via gateway |
| **B-BBMD** | BBMD | Broadcast Management Device | Cross-subnet broadcast forwarding |

**Design/spec implication:** Project specs should explicitly call out the required device profile per controller tier (e.g., "network/building controllers shall be BTL-Listed B-BC minimum; terminal unit controllers shall be BTL-Listed B-ASC minimum") rather than generically requiring "BACnet compliant," which has no enforceable meaning on its own ([ASHRAE Standard 135 research](/home/user/workspace/research/ashrae_standards.md)).

## 5. Who-Is / I-Am Discovery

- **Who-Is** is a broadcast (or unicast, if the target's address is already known) service used to discover devices on a network. Any device receiving a Who-Is that matches its device instance (or if the Who-Is has no instance range specified, matches any device) responds with an **I-Am**.
- I-Am responses are broadcasts by default, meaning every device on the segment sees every I-Am reply — this is a legitimate, expected broadcast, but on a large segment a mass Who-Is (e.g., triggered by a workstation's "discover all devices" action) can produce a burst of broadcast traffic. Time discovery operations for low-traffic periods on sensitive production segments.
- WebCTRL's discovery workflow (Site → Devices → Advanced → Start Discovery) issues Who-Is under the hood; drilling into a discovered IP network → MS/TP → device triggers additional targeted Who-Is/I-Am exchanges at that level. Discovery is not always required if identical devices already exist elsewhere in the job — reuse an existing point list/export instead of re-discovering to avoid unnecessary broadcast traffic.

## 6. BBMD and Foreign Device Registration

- **BBMD (BACnet Broadcast Management Device)** forwards BACnet/IP broadcasts (Who-Is, I-Am, unconfirmed COV, etc.) across IP subnet/router boundaries, since normal IP routers do not forward broadcast traffic. BACnet/IP is otherwise **unsecured by default** — a factor to flag on any project with IT/cybersecurity review ([ASHRAE Standard 135 research](/home/user/workspace/research/ashrae_standards.md)).
- **Rule: one BBMD per subnet.** Configuring more than one BBMD on the same subnet can create circular routing loops — this is a documented, real failure mode on multi-integrator jobs where a previous BBMD was never removed.
- **Foreign Device Registration (FDR)** lets a single device (not a full subnet) register with an existing BBMD to receive broadcasts — useful for a remote workstation, laptop, or single roaming device that doesn't warrant standing up its own BBMD.
- G5RE, G5CE, OFHI-A, and OF1628/OFBBC all support BBMD and/or FDR at the Gig-E port; check the specific model's manual for how many BBMD-capable IP networks it can host simultaneously (some support 2).

## Sources

- [ASHRAE BACnet Bookstore](https://www.ashrae.org/technical-resources/bookstore/bacnet)
- [ANSI Blog — BACnet Building Automation ANSI/ASHRAE 135](https://blog.ansi.org/ansi/bacnet-building-automation-ansi-ashrae-135/)
- [Actility — ASHRAE Standard 135 explainer](https://www.actility.com/bacnet-ashrae-standard-135/)
- [ASHRAE — BACnet Explained (Part 1)](https://www.ashrae.org/file%20library/technical%20resources/bookstore/bacnet-explained-pt1.pdf)
- [DEOS AG — BACnet Simply Explained](https://www.deos-ag.com/en/blog/bacnet-simply-explained/)
- [Achieving BACnet Compliance — ccontrol.com](https://www.ccontrol.com/pdf/Extv8n6.pdf)
- [BACnet Testing Laboratories — BTL Listing](https://www.bacnetinternational.net/btl/)
- [Beijer Electronics — BACnet interface/profile documentation](https://www.beijerelectronics.com/docs/DIO/GN-9251/en/bacnet-interface.html)
- [Scribd — BACnet Testing Laboratories BTL DDC controller profiles](https://www.scribd.com/document/578573216/BACnet-Testing-Laboratories-BTL-DDC-controller-profiles)
- Internal research: `/home/user/workspace/research/ashrae_standards.md`, `/home/user/workspace/research/alc_webctrl_vendors.md`
