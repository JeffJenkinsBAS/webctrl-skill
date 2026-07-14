# BACnet Secure Connect (BACnet/SC) Reference

Read this when a spec calls for BACnet/SC, when scoping a cybersecurity-reviewed campus/healthcare/higher-ed job, or when asked about certificates, TLS, or current support status in the ALC/OptiFlex ecosystem.

## 1. What BACnet/SC Is and Why It Exists

**BACnet/SC (Secure Connect)** was introduced via **Addendum bj to Standard 135-2016** and is now embedded in **135-2020**. It fundamentally re-architects BACnet's network layer for IT/cybersecurity compatibility ([ASHRAE BACnet/SC whitepaper](https://www.ashrae.org/file%20library/technical%20resources/bookstore/bacnet-sc-whitepaper-v15_final_20190521.pdf); [ASHRAE news release on BACnet/SC](https://www.ashrae.org/news/esociety/protecting-building-automation-systems-with-bacnet-secure-connect)):

- Uses **WebSockets over TLS 1.3** (128- or 256-bit elliptic curve cryptography), eliminating the need for static IP addresses and network broadcasts entirely.
- Operates via a **hub-and-spoke topology**: a central BACnet/SC hub function directs traffic between any number of connected nodes. The architecture is designed to allow future extensions to standard messaging protocols like MQTT.
- All connections are **mutually authenticated** — both hub and node must complete TLS certificate validation before any traffic is exchanged, directly addressing the long-standing IT/OT objection to placing unencrypted BACnet/IP devices on converged networks.
- Because broadcasts are eliminated by design, BACnet/SC sidesteps the entire class of broadcast-storm and BBMD-misconfiguration problems that affect BACnet/IP.

## 2. Authentication and Authorization Extensions

Newer addenda (2020cp series, approved through **November 2024 / May 2025**) extend BACnet/SC with **Authentication and Authorization Services** (a new Clause 17), adding fine-grained, per-client permission scopes on top of the base TLS trust model — allowing devices to be treated with different authority levels rather than all-or-nothing network trust ([BACnet Committee addenda page](https://bacnet.org/addenda/); [135-2020cp PDF](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/135_2020_cp_20241129.pdf)).

## 3. Certificates — What to Actually Configure

BACnet/SC's trust model is certificate-based mutual TLS. In practice this means:

- Every hub and every node needs a valid certificate before it can join the SC network — plan certificate provisioning and renewal into the commissioning schedule, not as an afterthought.
- Certificate expiry is now a live operational concern for BAS networks in a way legacy BACnet/IP never had — track certificate expiration dates the same way you'd track a warranty or service contract renewal.
- Mutual authentication means a compromised or misconfigured certificate on either end (hub or node) blocks that connection entirely — this is a feature (it fails closed), but it means certificate management errors show up as hard comm loss, not degraded performance.

## 4. Deployment Status in the ALC/OptiFlex Ecosystem

- **BACnet/SC is supported at the WebCTRL software layer starting in v8** (BACnet Protocol Revision 19), using TLS 1.3 ([ALC vendor research](/home/user/workspace/research/alc_webctrl_vendors.md)).
- **Important field note:** no explicit TLS/BACnet-SC implementation was found documented in the OptiFlex hardware-level Technical Instructions (G5RE, G5CE, OFHI-A manuals) as of this research. Security/encryption for these devices appears to be handled server-side (at the WebCTRL layer) rather than being a native field-controller firmware feature, based on direct review of the uploaded OptiFlex manuals.
- **Practical implication:** don't promise a client "BACnet/SC end-to-end to the VAV box" on current OptiFlex hardware without verifying the specific firmware/product line's actual SC support at the time of the project — the backbone/server layer is ahead of the field-controller layer in this ecosystem. Always verify current BTL/SC listing status per project before committing to a spec that mandates SC at the field-controller level.
- Cybersecurity documentation maturity varies significantly by vendor. For comparison: Honeywell WEBs-N4 has published FIPS 140-2/FedRAMP-eligible documentation, and JCI Metasys 16.0 has the most detailed public BACnet/SC certificate workflow documentation of any vendor reviewed in this research; ALC's public security documentation at the hardware/firmware level is comparatively sparse ([ALC vendor research](/home/user/workspace/research/alc_webctrl_vendors.md)).

## 5. When a Spec Requires BACnet/SC

Specify or confirm BACnet/SC when:
- The project is campus, healthcare, higher-ed, or government with active IT/cybersecurity review as a standard part of the approval process.
- The spec explicitly cites Standard 135-2020 Addendum bj or references BACnet/SC by name.
- The owner's IT department has flagged unencrypted BACnet/IP as unacceptable on a converged network.

When responding to such a spec on an ALC job:
1. Confirm which layer of the stack actually needs to be SC-capable — server/backbone only, or all the way to field controllers.
2. Verify current OptiFlex firmware SC support before committing (see field note above) — don't assume based on WebCTRL server version alone.
3. Document a certificate provisioning and renewal plan as part of the commissioning package, not as a separate afterthought.
4. If full field-controller SC isn't currently available on the specified hardware, document a transition path (e.g., SC at the backbone/router level now, field segments on MS/TP/ARC156 behind a router, with a clear upgrade path) rather than overstating current capability — RFP language increasingly rewards a documented transition path even when full SC isn't yet deployed everywhere ([ASHRAE Standard 135 research](/home/user/workspace/research/ashrae_standards.md)).

## Sources

- [ASHRAE BACnet/SC whitepaper](https://www.ashrae.org/file%20library/technical%20resources/bookstore/bacnet-sc-whitepaper-v15_final_20190521.pdf)
- [ASHRAE news release — Protecting Building Automation Systems with BACnet Secure Connect](https://www.ashrae.org/news/esociety/protecting-building-automation-systems-with-bacnet-secure-connect)
- [BACnet Committee — addenda page](https://bacnet.org/addenda/)
- [BACnet Committee — 135-2020cp Authentication & Authorization Services addendum (PDF)](https://www.ashrae.org/file%20library/technical%20resources/standards%20and%20guidelines/standards%20addenda/135_2020_cp_20241129.pdf)
- [BACnet Committee — addenda category: ASHRAE 135](https://bacnet.org/addenda-category/ashrae-135-the-bacnet-standard/)
- Internal research: `/home/user/workspace/research/ashrae_standards.md`, `/home/user/workspace/research/alc_webctrl_vendors.md`
