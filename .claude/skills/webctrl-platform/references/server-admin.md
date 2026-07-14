# WebCTRL Server Administration — Editions, Versions, Add-Ons, Migration Detail

## Server Platform Requirements

WebCTRL runs on Windows Server 2019/2016/2012R2, RHEL 7.4, Windows 10/8 Pro/Enterprise, or Ubuntu 18.04/20.04, with a minimum quad-core CPU and 4GB RAM. Backing database options: Apache Derby (bundled default), Oracle 12c, MySQL 5.7.2/8.0, SQL Server Express/Standard 2016–2019, or PostgreSQL 9.4–12 ([WebCTRL v8 Client-Server spec sheet](https://www.automatedlogic.com/en/media/WebCTRL_v8_CS_tcm702-183600.pdf)).

Currently supported/patched releases: **WebCTRL Cloud, v10.0, v9.0, v8.5, and v8.0** ([WebCTRL Version Comparison](https://www.automatedlogic.com/en/media/WebCTRL-Version-Compare_final_tcm702-275459.pdf)). Any server still on an earlier release is out of patch support — flag this during any site assessment.

For v10-specific feature detail (Trailguide, smarter BACnet discovery, live/hosted backups, ACxelerate 3.0, Predictive Insights) and Test & Balance v10, see `references/webctrl-10.md`. For full backup/migration/WaaS/PostgreSQL/license/patch field procedures, see `references/server-lifecycle.md`.

## Editions & Point Limits

| Edition | Point Limit | Positioning |
|---|---|---|
| WebCTRL Standard (WC-S) | 200 points | Small facilities |
| WebCTRL Advantage (WC-A) | 500 points | Mid-size facilities |
| WebCTRL Premium (WC-P) | Unlimited | Large/campus systems |
| WebCTRL Cloud (WC-C) | Unlimited (base subscription: 150 controllers / 20 users) | AWS-hosted SaaS, includes Advanced Reporting/Security/Alarming |
| WebCTRL for Life Sciences (WC-LS) | Unlimited | Adds 21 CFR Part 11 e-signatures/audit records |

Source: [WebCTRL Version Comparison PDF](https://www.automatedlogic.com/en/media/WebCTRL-Version-Compare_final_tcm702-275459.pdf).

**Field note**: the [BACnet Integration Guide](https://www.scribd.com/document/834200970/BACnet-Integration-Guide-Automated-Logic) documents a 600-point ceiling specifically on the WebCTRL 500 (Advantage) edition when third-party BACnet integration points are counted against the license — verify actual headroom before adding a large third-party BACnet integration to an Advantage-licensed job, and run `count devices` from the console to check current usage against the licensed ceiling.

**WebCTRL Cloud** is an OpEx subscription model (AWS-hosted) rather than CapEx on-prem, uses BACnet/SC (TLS 1.3) and/or a VPN tunnel for server-to-network security, and includes automatic updates/backups — this is a meaningfully different operating model from the on-prem server, which needs a third-party VPN for equivalent network-level encryption ([WebCTRL Cloud product page](https://www.automatedlogic.com/en/products/webctrl-cloud/)).

## Version History & Feature Trajectory

| Version | Key additions |
|---|---|
| **v7.0** | FDD (Fault Detection & Diagnostics) Comfort/Energy alarm categories; raised ZN control-program microblock ceiling from 400 to 700 |
| **v8** (Jan 2021) | BACnet Protocol Revision 19; **BACnet/SC support**; IPv6 readiness; Project Haystack-compatible semantic tagging; dynamically-resizing SVG floorplans; ACxelerate VAV auto-commissioning tool; expanded custom-reporting ([launch announcement](https://www.automatedlogic.com/en/news/news-articles/automated_logic_launches_webCTRL_v8_software.html)) |
| **v8.0 security** | TLS 1.3 256-bit encryption client↔server, B-AWS BTL profile, BACnet Rev 19 compliance, unlimited simultaneous users, hierarchical server configuration for enterprise scale ([v8 spec sheet](https://www.automatedlogic.com/en/media/WebCTRL_v8_CS_tcm702-183600.pdf)) |
| **v9** (May 28, 2024) | Granular multi-select user privileges; **SSO via SAML 2.0/OIDC**; schedulable Security Report (admin security settings summary); enhanced Alarm Summary View (location/count filtering); remote file upload/link support in Resource Management; up to 10 concurrent simultaneous downloads to IP networks downstream of a BACnet router; **read-only REST API for alarm data** ([v9 announcement](https://www.automatedlogic.com/en/news/news-articles/automated-logic-unveils-webctrl-v9--revolutionizing-building-automation-through-simplicity-and-efficiency.html)) |
| Trend engine (ongoing) | Marketed as "5X write / 10X delete / 15X read, 70% storage reduction" vs. legacy trend storage (ALC materials; not independently version-pinned) |

## Environmental Index

A proprietary comfort-scoring tool that blends temperature, humidity, and CO₂ readings into a single 0–100% zone-level "comfort score," rolled up to floor and building level. It is trendable and exportable to PDF/Excel, and maps directly to **LEED EB O+M EA Credit 3.3** reporting requirements ([Carrier Environmental Index tool brief](https://www.corporate.carrier.com/Images/WebCtrl-Environmental-Index-Tool-092920_tcm558-80385.pdf)).

Use this when a customer needs LEED EB O+M documentation or a simple building-wide comfort KPI for facilities leadership — it's a faster deliverable than building a custom report from scratch for the same purpose.

## Open Integrations Platform (7 paths)

ALC documents seven distinct integration paths ([WebCTRL Open Integrations Platform](https://www.automatedlogic.com/en/media/WebCTRL%20Open%20Integrations%20Platform_110325_tcm702-284058.pdf)):

1. Native serial/IP protocols: BACnet/IP, ARCnet, MS/TP, BACnet/SC, Modbus TCP/RTU, N2 Open, SNMP, KNX, M-Bus
2. Java SDK/API (case-by-case licensing)
3. Web Services (XML/SOAP/WSDL/UDDI)
4. **MQTT add-on** (v3.1.1 + Sparkplug B, certificate-based auth)
5. **Trend Export add-on** (2 years of CSV export)
6. **RESTful API** for alarm GET/POST triggers
7. Third-party BACnet device integration via Network I/O / Display microblocks, with either BACnet Discovery or COV subscription (vs. polling) — 600-point ceiling caveat on the WC-500/Advantage edition noted above

**Third-party front-end note**: a Niagara driver for WebCTRL exists ([Niagara Marketplace WebCTRL driver](https://www.niagaramarketplace.com/media/products/nm-Automated_Logic_WebCTRL_Driver/docWebCtrl.pdf)), confirming ALC systems can be subordinated into a Niagara supervisory layer as a foreign/BACnet system — but field experience shows this is rarely a clean substitute for the native WebCTRL front end. Points must be explicitly flagged "network visible" before third-party clients can see them, and BACnet write reliability into ALC controllers from Niagara has been reported as inconsistent even when reads work fine ([field report](https://www.reddit.com/r/BuildingAutomation/comments/1u45v3u/does_automated_logic_controllers_play_nice_with/)). Recommendation when a hybrid Niagara/WebCTRL scenario is unavoidable: keep the WebCTRL server on-site, since server-side logic (schedules, trend rollups, some visibility gating) is not fully replicated at the controller level.

## BACnet/SC & Security Layer

- **BACnet/SC** (Secure Connect) is supported at the WebCTRL software layer starting in v8 (BACnet Protocol Revision 19), using TLS 1.3.
- No explicit TLS/BACnet-SC implementation is documented in OptiFlex hardware-level Technical Instructions (G5RE, G5CE, OFHI-A manuals) — security/encryption is handled server-side, not as a native field-controller firmware feature, based on direct review of ALC OptiFlex manuals.
- G5RE conforms to the BACnet Router (B-R-TR) profile per ANSI/ASHRAE 135-2012 Annex L, Protocol Revision 14, and supports BBMD and Foreign Device Registration for cross-subnet BACnet/IP routing.
- SSO/SAML 2.0/OIDC arrives at v9 for user authentication into WebCTRL itself.

## Migration & Upgrade — Full Procedure

Treat every migration/upgrade as a three-phase project, never a direct in-place change on production:

### Phase 1 — Replicate
1. Full backup of the live production database, named per standard (`SITENAME_VERSION_PROD_BKUPDATE`).
2. Create a working copy for migration: `SITENAME_VERSION_MIGRATE_BKUPDATE`.
3. Confirm the replicated copy opens cleanly and matches production point-for-point (spot check a sample of trends, alarms, schedules).

### Phase 2 — Upgrade
1. Run the WebCTRL software upgrade against the **replicated copy**, never live production.
2. Note any deprecated features or breaking changes for the specific version jump (e.g., jumping multiple major versions, such as v7→v9, may require intermediate steps — check ALC release notes for the specific path).
3. Re-verify BACnet/SC certificates and SSO configuration if crossing the v8→v9 boundary.

### Phase 3 — Validate
1. Confirm graphics render correctly (ViewBuilder paths still resolve).
2. Confirm trends and alarms are firing and historical data is intact.
3. Confirm schedules run as expected.
4. Spot-check a representative sample of control programs across equipment types.
5. Communicate a controlled downtime window to the customer for cutover — do not assume the swap is hot-swappable, especially across major version boundaries.
6. Only after validation passes: promote the migrated copy to `PROD` naming and retire/archive the prior production database as `SITENAME_VERSION_ARCHIVE_BKUPDATE`.

### Legacy hardware migration
Backward compatibility is a genuine ALC strength: technicians report pulling logic off 1990s-era ALC controllers (running the decades-old ExecB firmware) and redeploying identical logic onto current hardware in roughly 15 minutes ([field report](https://www.reddit.com/r/BuildingAutomation/comments/1u45v3u/does_automated_logic_controllers_play_nice_with/)) — a meaningful advantage on long-lifecycle retrofit jobs. Still take a backup of the extracted logic before redeploying.

## Console Command Reference (extended)

Beyond the core four in the main SKILL.md, general usage notes:

- Run commands via **CTRL+M** to open the console from within the WebCTRL client.
- `help -a -h` returns the full command list with inline help — use this first on any unfamiliar server to see what diagnostic commands are actually available on that version.
- `count devices` — always run after discovery, hardware swaps, or before renewing/adjusting a license, to confirm actual device count against the licensed edition ceiling.
- `commstat` — first troubleshooting step for "points not updating" complaints; faster than manually pinging each device.
- `tracert` — use when `commstat` shows a device as unreachable, to isolate whether the break is at the router, MS/TP trunk, or device itself.

## Dealer/Platform Context

ALC was founded in 1977 in Marietta, GA, and was the first BAS company to ship a color graphical interface ([ControlTrends history](https://controltrends.org/hvac-smart-building-controls/building-automation-and-integration/08/building-automation-controls-systems-reviews-automated-logic/)). Carrier Corporation acquired ALC in 2004 ([Wikipedia: Automated Logic Corporation](https://en.wikipedia.org/wiki/Automated_Logic_Corporation)). Distribution today is a mixed model of 185+ company branches and independent dealers ([ALC dealer network page](https://www.automatedlogic.com/en/support-resources/support/dealer-network/)) — relevant context when discussing licensing, support escalation paths, or long-term platform trajectory with a customer.
