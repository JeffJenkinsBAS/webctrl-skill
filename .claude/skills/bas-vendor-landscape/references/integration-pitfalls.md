# Integration Pitfalls — Real Field Experience

Concrete, field-reported pitfalls encountered when integrating ALC/WebCTRL with other BAS front ends or when other vendors' tools attempt to talk to ALC controllers. Read this before scoping or executing any takeover/integration job — these are the items that turn a clean-sounding bid into a change order.

---

## 1. ARCnet-to-MS/TP Requires a Physical Jumper Move
ALC controllers use native BACnet, but older units communicate over **ARCnet by default** and require a **physical jumper move on the controller board** to switch to MS/TP — a real field task requiring panel access, not a software-only setting ([r/BuildingAutomation field thread](https://www.reddit.com/r/BuildingAutomation/comments/1u45v3u/does_automated_logic_controllers_play_nice_with/)).

**Implication for scoping**: If a takeover/integration job requires ALC field controllers to speak MS/TP instead of their default ARCnet (common when integrating into a Niagara JACE or another vendor's MS/TP trunk), budget site-visit time per controller for the jumper change — this cannot be done remotely.

## 2. BACnet Point Visibility Is Opt-In, Not Automatic
Points must be explicitly marked **"network visible"** in the ALC engineering software before third-party BACnet clients (Niagara, Metasys, or any other BACnet Advanced Workstation) can discover them. This is a common oversight that silently breaks integrations — the third-party system will report "device found, zero points" or simply fail discovery, and the cause is rarely obvious to a technician unfamiliar with ALC's visibility model ([r/BuildingAutomation field thread](https://www.reddit.com/r/BuildingAutomation/comments/1u45v3u/does_automated_logic_controllers_play_nice_with/)).

**Implication for scoping**: Add an explicit line item in any integration scope for "flag required points network-visible in ALC" — don't assume this is a byproduct of normal BACnet/IP configuration.

## 3. Writes From Niagara Into ALC Are Unreliable
Two independent commenters on the same field thread reported **failed BACnet write attempts from Niagara N4 into ALC controllers**, even when monitoring/read access worked fine. This is a specific, high-value warning for any dealer considering a Niagara-front-end migration or a hybrid Niagara-supervisory project involving ALC field controllers.

**Implication for scoping**: Never assume write capability from a successful read/discovery test. During commissioning of any Niagara-to-ALC integration, explicitly test writes (setpoint changes, schedule overrides, etc.) from the Niagara side and document actual reliability before sign-off. If writes prove unreliable, plan to keep setpoint/schedule authority on the WebCTRL side and use Niagara for monitoring/reporting only.

## 4. Don't Let the WebCTRL Server Disappear in a Hybrid Scenario
Multiple field commenters warn that separating the ALC back end from the WebCTRL front end **defeats the reason for choosing ALC** in the first place: *"ALC dedicated a significant amount of time developing an exceptional integrated product... incorporating ALC controllers into Niagara undermines the very reason for choosing ALC in the first place."* Server-side logic (schedules, trend rollups, some visibility gating) is **not fully replicated at the controller level** ([r/BuildingAutomation field thread](https://www.reddit.com/r/BuildingAutomation/comments/1u45v3u/does_automated_logic_controllers_play_nice_with/)).

**Implication for scoping**: Practical recommendation from the field — **keep the WebCTRL server on-site** even in a hybrid Niagara scenario. Position the JACE as reading ALC as a foreign BACnet system, not as a full replacement front end.

## 5. ALC Has Zero Structural Niagara Participation
"ALC has no involvement with Niagara to my knowledge" is the consistent field/industry read ([r/BuildingAutomation thread](https://www.reddit.com/r/BuildingAutomation/comments/1c5yzmv/is_it_accurate_that_alc_has_zero_participation/)). This is a deliberate strategic choice — ALC runs a closed, vertically-integrated stack rather than a dual-track approach like JCI (Metasys + Facility Explorer) or Honeywell (EBI + WEBs-N4).

**Implication for scoping**: A third-party Niagara driver for WebCTRL does exist ([Niagara Marketplace WebCTRL driver](https://www.niagaramarketplace.com/media/products/nm-Automated_Logic_WebCTRL_Driver/docWebCtrl.pdf)), confirming ALC systems *can* be subordinated into a Niagara supervisory layer as a foreign/BACnet system — but treat this as a workaround with the limitations in items 2–4 above, not a native integration path. Set this expectation with the customer before quoting.

## 6. BBMD Subnet Loops
If controllers span multiple IP subnets separated by a router, configure **one BBMD per subnet** — configuring more than one BBMD per subnet can create circular routing loops that degrade or break BACnet/IP traffic across the whole site. This applies whether the BBMD is on ALC hardware (G5RE, OFHI-A, G5CE, OF1628 family) or a third-party device sharing the same IP network.

**Implication for scoping**: When integrating with an existing BAS that already has BBMDs configured on its own routers, audit the existing BBMD topology before adding ALC BBMD-capable devices to the same subnets — duplicate/conflicting BBMD configuration across vendors on one subnet is a common source of hard-to-diagnose intermittent BACnet/IP issues.

## 7. Module/Driver Licensing Gates "Openness" on Niagara Jobs
Niagara specs commonly mandate that "all controllers must be able to be programmed within the Niagara Workbench," which sounds like guaranteed vendor-neutral access — but a JACE only recognizes a protocol/device if the correct Tridium driver module is installed and **licensed**. The Workbench UI is standardized; protocol coverage is still gated by which modules are actually purchased ([Smart Buildings Academy explainer](https://guides.smartbuildingsacademy.com/blog/tridium-part-2)).

**Implication for scoping**: On any job where "the JACE will read our ALC controllers as BACnet" is assumed to be simple, confirm the JACE actually has BACnet driver modules installed/licensed — don't assume it's automatic just because Niagara is "open by spec."

## 8. Cross-Vendor Point/Object Ceiling Awareness
When bridging ALC to a third-party BACnet Advanced Workstation, remember ALC's own third-party BACnet point ceilings vary sharply by device (e.g., zone controllers: 100 points; OF1628/OFBBC/OFHI-A: 1,500 points; G5CE: 1,500 BACnet + only 25 Modbus vs. OFHI-A's 1,000 Modbus). A takeover/integration scope that assumes uniform capacity across ALC hardware will under- or over-spec the wrong controller.

**Implication for scoping**: Cross-reference actual third-party point counts against the `alc-hardware` skill's device comparison table before committing to a device selection for a heavy third-party-integration job (e.g., a chiller plant with dozens of Modbus points needs OFHI-A, not G5CE).

## 9. Legacy Hardware Migration Is a Different Animal Than a True Takeover
Extracting logic from a 1990s-era ALC controller (ExecB firmware) and redeploying it onto current hardware is reported to take roughly **15 minutes** per program — this is a same-vendor migration, not a competitive takeover, and should be scoped and quoted very differently (much smaller labor line item) than a genuine rip-and-replace of a competitor's system.

**Implication for scoping**: Don't accidentally price a legacy-ALC hardware refresh as if it were a full competitive takeover — check whether the "old system" being discussed is actually ALC before assuming a full takeover scope is needed.

---

*Compiled primarily from field/technician discussion on [r/BuildingAutomation](https://www.reddit.com/r/BuildingAutomation/comments/1u45v3u/does_automated_logic_controllers_play_nice_with/) and [r/BuildingAutomation: Is it accurate that ALC has zero participation with Tridium/Niagara?](https://www.reddit.com/r/BuildingAutomation/comments/1c5yzmv/is_it_accurate_that_alc_has_zero_participation/), cross-referenced with ALC's own [Open Integrations Platform documentation](https://www.automatedlogic.com/en/media/WebCTRL%20Open%20Integrations%20Platform_110325_tcm702-284058.pdf) and [BACnet Integration Guide](https://www.scribd.com/document/834200970/BACnet-Integration-Guide-Automated-Logic). Field reports are anecdotal but consistent across independent sources — always validate write reliability and point visibility during actual commissioning, not just during scoping.*
