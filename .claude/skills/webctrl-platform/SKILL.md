---
name: webctrl-platform
description: "Guides WebCTRL server administration, SiteBuilder database work, system/source trees, BACnet discovery, custom reports, trends/alarms, console commands, backups/migrations/WebCTRL-as-a-Service/PostgreSQL setup, dealer licensing, patching, global modify (wildcard syntax), WebCTRL 10 features, Test & Balance v10, ALC tech support, customer training, and ViewBuilder graphics for Automated Logic (ALC) BAS deployments. Use when the user mentions WebCTRL, SiteBuilder, ViewBuilder, geographic tree, network tree, source tree, BACnet discovery, custom report, trend, alarm setup, database backup, server migration, WebCTRL as a Service, PostgreSQL, dealer license, patch/update, global modify, Environmental Index, add-on, ALC Portal, tech support, customer training, or graphics path. Covers database naming standards, discovery workflow, report expression syntax, console diagnostics, and server/version lifecycle management. Does not cover EIKON control-program logic authoring — see eikon-programming for that."
metadata:
  author: JeffJenkinsBAS
  version: '1.1.0'
---

# WebCTRL Platform Administration

## When to Use This Skill

Use this skill for anything touching the WebCTRL server/front-end layer of an ALC building automation system:

- Standing up or reorganizing a **SiteBuilder** database (geographic tree, network tree, source trees, naming)
- Running **BACnet discovery** to find devices/networks and pull point lists for engineering
- Building **custom reports** (trend exports, commissioning summaries, calculated fields)
- Configuring **trends and alarms** at the server/point level
- Using the **console** (CTRL+M) for diagnostics — device counts, comm health, network tracing
- **Backing up, upgrading, or migrating** a WebCTRL server or database, including **WebCTRL as a Service**, **PostgreSQL** setup, dealer **license** updates, and installing **patches/updates**
- **Globally modifying** a parameter/setpoint across many control programs at once (wildcard syntax)
- Understanding **editions, versions, add-ons**, **WebCTRL 10** features, **Test & Balance v10**, and the **Environmental Index** tool
- Building or reviewing **ViewBuilder** graphics (dashboards, floorplans, diagnostic screens)
- Escalating to **ALC Tech Support / the ALC Portal**, or delivering **customer-facing WebCTRL training**

**Skip when**: the task is about EIKON control-program logic (microblocks, ZN programs, sensor binders, PID tuning) — load `eikon-programming` instead. This skill covers the server/database/graphics layer; that skill covers the logic layer that runs inside controllers.

## Platform Stack (context)

WebCTRL (server/front end) ↔ SiteBuilder (database/config tool) ↔ EIKON (control logic, controller-resident) ↔ ViewBuilder (graphics). Protocol: BACnet primary (ARC156/MS/TP field bus, BACnet/IP backbone, BACnet/SC v8+), Modbus secondary. This tight EIKON↔WebCTRL coupling — especially live logic viewing — is ALC's core technical differentiator versus Niagara-based or proprietary-only competitors ([field confirmation, r/BuildingAutomation](https://www.reddit.com/r/BuildingAutomation/comments/1bgkyos/automated_logic_question/)).

## Database Naming Standard

Every SiteBuilder database follows:

```
SITENAME_VERSION_DBTYPE_BKUPDATE
```

| Segment | Meaning | Example |
|---|---|---|
| `SITENAME` | Facility/customer identifier, no spaces | `MEMHOSP` |
| `VERSION` | WebCTRL version the DB was built/upgraded on | `v9` |
| `DBTYPE` | `PROD`, `TEST`, `ARCHIVE`, `MIGRATE` | `PROD` |
| `BKUPDATE` | Last backup date, `YYYYMMDD` | `20260710` |

Example: `MEMHOSP_v9_PROD_20260710`

**Why it matters**: a consistent name lets any technician identify site, platform version, database role, and backup currency at a glance — critical when troubleshooting remotely or handing off a job mid-project. Never store a database with a bare or ad-hoc name; rename on every major backup/milestone.

## Geographic Tree vs. Network Tree

SiteBuilder maintains **two parallel trees** over the same physical equipment — know which one to use for which task:

| Tree | Represents | Use for |
|---|---|---|
| **Geographic Tree** | Physical/functional layout (building → floor → zone → equipment) | Operator navigation, ViewBuilder graphic assignment, end-user reporting, Environmental Index rollups |
| **Network Tree** | Physical device connectivity (IP network → MS/TP trunk → device) | Troubleshooting comms, BACnet discovery placement, controller replacement, network diagnostics |

Design rule: build the Geographic Tree around **how the building is used** (AHU-1, Floor 3 East Wing, Chiller Plant), and let the Network Tree mirror **how the wires actually run**. Do not conflate them — a device can move geographically (reassigned to a different zone) without changing its network location, and vice versa ([SiteBuilder database structure](https://www.automatedlogic.com)).

### Source Trees (parent/child equipment)

A **Source Tree** is a third, separate layer over the GEO/NET trees: it links "parent" equipment providing a resource to "children" consuming it (e.g., a Chiller Plant/AHU are parents providing temperature-controlled media; VAV boxes are children consuming it). Every system auto-generates four default Source Trees: **Cool Source, Heat Source, Demand Source, Environmental Index**.

- Right-click anywhere in the GEO tree → **"Set up Tree"** to view/edit. Red text = unassigned equipment; black text = assigned.
- To roll a child value up to a parent (e.g., average VAV damper position at the AHU): mark the child's output point **Network Visible**, add/locate a receiving microblock (e.g., Average) in the parent program, create a new Source Tree + Rule linking the two refnames, then map parent/child equipment in the tree UI. Mapped microblocks show a small **lock icon** next to the path once pathing is set via the Source Tree.
- **Gotcha**: Average/rollup blocks can report `0` when not enough children are reporting — exclude non-"Valid" blocks from the averaging/division math so only actively-reporting microblocks count.

See `references/server-lifecycle.md` for the full worked Source Tree example and rollup-logic gotcha detail.

## BACnet Discovery Workflow

1. Navigate: **Site → Devices → Advanced → Start Discovery**
2. WebCTRL returns a list of **Discovered Networks** (IP subnets and MS/TP trunks it can see from the server/router).
3. Drill down: **IP Network → MS/TP → Device** — expand each level to reach individual controllers.
4. At the device level, run **discovery at the device** to enumerate its BACnet object list (AI/AO/BI/BO/MSV points).
5. **Export** the resulting point list for engineering — this becomes the source for control-program point mapping and graphics binding.

Practical notes:
- Discovery is **not always required** — if identical controller models/programs already exist elsewhere on the job, copy the known point list/program rather than re-discovering from scratch.
- Third-party BACnet points only appear if they are marked **network visible** on the source device; an un-flagged point will not surface in discovery even if it exists ([field report, r/BuildingAutomation](https://www.reddit.com/r/BuildingAutomation/comments/1u45v3u/does_automated_logic_controllers_play_nice_with/)).
- Older ALC controllers default to **ARCnet**; switching to MS/TP requires a **physical jumper move** on the controller — not just a software setting.
- Prefer **confirmed COV subscription** over polling third-party BACnet devices when configuring the integration — it cuts unnecessary network traffic ([BACnet Integration Guide](https://www.scribd.com/document/834200970/BACnet-Integration-Guide-Automated-Logic)).

## Custom Reports

WebCTRL's custom report builder assembles Type + Columns + Variables + Expressions + output formatting into a report definition.

**Hard limits:**

| Limit | Value |
|---|---|
| Max columns | 50 |
| Max rows | 1000 |

If a report needs more than 50 columns or 1000 rows, split it into multiple reports (e.g., by floor, by equipment type, or by date range) rather than trying to force one oversized report — it will silently truncate or fail.

**Expression syntax**: reference point values by wrapping the path in `$...$`. Example — percent airflow deviation between two sensors:

```
($airflow1$ - $airflow2$) / $airflow2$ * 100
```

Other common expression patterns:
- Delta-T across a coil: `($supply_temp$ - $return_temp$)`
- Runtime hours to percent of period: `$runtime_hrs$ / $period_hrs$ * 100`
- Simple threshold flag (for conditional formatting downstream): `$zone_temp$ - $setpoint$`

Report types worth knowing:
- **Trend analysis** — historical point values over time, for FDD/commissioning
- **Commissioning data** — snapshot verification of as-built values against design
- **Equipment summaries** — rollup views (e.g., all VAV boxes on a floor)
- **Calculated fields** — any of the above plus an expression column

## Globally Modifying Parameters & Setpoints (Wildcard Syntax)

Use **Global Modify** any time the same property change needs to be applied across many identical/similar control programs instead of editing each one by hand — e.g., pushing a new default PID interval to every VAV on a job.

1. Browse to a page showing the target property.
2. Open Global Modify: **Alt+click** the property (**Ctrl+Alt+click** on Linux), or right-click → **"Global Modify."**
3. Edit the Control Program field using wildcard syntax:

| Pattern | Matches |
|---|---|
| `vav*` | `vav`, `vav1`, `vavx`, `vav12345` |
| `vav*z` | `vavz`, `vav1z`, `vavxz`, `vav12345z` |
| `vav*1*2` | `vav12`, `vavabc1xyz2` |
| `vav??` | `vav11`, `vav12`, `vavzz` (**not** `vav`, `vav1`, `vav123`) |
| `*` | Any control program in the system |

4. Select the tree item to search under → **Find All** to locate all occurrences of the microblock in other control programs.
5. Select properties to change: type a **New Value** per item, or select **Enable All** + **Set All To** (absolute new value), or **Enable All** + **Change All By** (relative/incremental change).
6. Click **Apply Changes**.

See `references/server-lifecycle.md` for the full procedure including the "Show Advanced" view.

## Trends & Alarms

- Trend collection should be **confirmed-COV driven** where the point supports it — avoid blanket interval polling on every point, which bloats the trend database and adds unnecessary network chatter.
- Trend storage in recent WebCTRL versions is markedly more efficient ("5X write / 10X delete / 15X read, 70% storage reduction" vs. legacy trend storage per ALC materials) — still, only trend what will actually be reviewed or reported on.
- Alarm categories since **v7.0** include FDD (Fault Detection & Diagnostics) **Comfort** and **Energy** categories in addition to standard hard/soft alarms — use these categories to separate "needs immediate attention" from "efficiency opportunity" in alarm routing.
- **v9** adds an enhanced Alarm Summary View with location/count filtering and a read-only REST API for alarm data — useful for pushing alarm feeds into external dashboards or ticketing ([WebCTRL v9 announcement](https://www.automatedlogic.com/en/news/news-articles/automated-logic-unveils-webctrl-v9--revolutionizing-building-automation-through-simplicity-and-efficiency.html)).

## Console Commands (CTRL+M)

Access the console with **CTRL+M**, then use:

| Command | Purpose |
|---|---|
| `help -a -h` | Full command list with help text |
| `count devices` | Report total device count (validate against license/edition point limits) |
| `commstat` | Communication health snapshot across the network |
| `tracert` | Trace network path to a device (diagnose routing/hop issues) |

Run `count devices` after any discovery pass or hardware swap to confirm the system size still matches the licensed edition (see reference file for point-limit table by edition). Run `commstat` first whenever a technician reports "points not updating" — it's faster than chasing individual device timeouts manually.

## Server Management: Backups, Migration, Licensing & Patching

**Before any change** (upgrade, database edit, hardware swap): take a full backup. No exceptions — this is the single most common cause of unrecoverable field incidents when skipped. Databases fall into two transport classes: **Derby** (default, can be copied/pasted, but not for long-term medium/large systems) vs. **MySQL/Oracle/PostgreSQL** (never copy/paste — it corrupts the database, unrecoverably). Backup replicant naming: `<SITENAME>_derby_wcXX_<TODAYSDATE>`.

Migration/upgrade sequence (replicate → upgrade → validate), expanded into ALC's full 10-phase field checklist in the reference file:

1. **Replicate** — copy/export the live production database to a working copy named per the naming standard (e.g., `SITENAME_v8_MIGRATE_20260710`). Always select **REPLICATE**, not the window's default option.
2. **Upgrade** — run the upgrade against the replicated copy, not the live production database. Install on a non-C: drive when possible; keep the Windows service on **Manual** startup until validated.
3. **Validate** — confirm graphics render, trends/alarms fire, schedules run, and spot-check a sample of control programs before cutting over. Only after validation passes should the upgraded copy replace production.
4. Communicate **controlled downtime** windows to the customer before cutover (notify at T-60/T-30/T-5 minutes) — WebCTRL upgrades are not always hot-swappable, especially across major versions. **WebCTRL 10's live/hosted backups** remove this offline-window requirement for routine backups specifically (not for a full upgrade) — see `references/webctrl-10.md`.

Other server lifecycle tasks — all detailed in `references/server-lifecycle.md`:
- **WebCTRL as a Service** — install/uninstall the Windows service via `"WebCTRL Service.exe"` / `"WebCTRL Service.exe" -remove` from an admin Command Prompt. Uninstalling one version's service removes the registration for **all** versions on that machine.
- **PostgreSQL setup** — 4-step guide: install PostgreSQL → create a `root` login role → create 4 lowercase, <18-character databases (`sitename_main/alarms/trends/audit`) → connect via SiteBuilder's Migrate Database wizard (Server/Port/Instance/Login/Password).
- **Dealer license updates** — back up `license.properties` (rename to `olddealerslicense.properties`), drop in the new file (pre-8.5: `resources\properties`; 8.5+: `programdata\licenses`, back-copyable to older version folders), then verify via SiteBuilder.
- **Patches/updates** — run SiteBuilder as admin with no database loaded → Help → Apply Update → Browse to the update file (ALC Portal, `O:\ALC\Install Files\WebCTRL`, or ProCore 4TRAIN) → queue → restart. On a fresh install, apply only the latest cumulative patch, then updates on top.

See `references/server-admin.md` for version-by-version feature changes, edition point limits, add-ons, and migration-phase detail; `references/server-lifecycle.md` for the full backup/migration/WaaS/PostgreSQL/license/patch procedures; `references/webctrl-10.md` for WebCTRL 10 feature specifics and Test & Balance v10.

## Escalation & Customer Training

- **ALC Tech Support: 770-429-3002** — save this number in every technician's phone; calling opens a tracked case with an assigned agent. ALC Portal usernames end in `.alcprod` or `.partner.prod`.
- **Customer WebCTRL training** is foundational operator training (navigation, setpoints, schedules, alarms, trends, hardware awareness, troubleshooting basics) — not a programming course. Use percentage-based time allocation scaled to the contracted session length, and anchor every topic to the customer's live system. See `references/server-lifecycle.md` for the full 10-stage flow, live-system checkpoints, and prep/post-training checklists.

## ViewBuilder Graphics — Path Syntax

Two path types bind a graphic element to a live point:

| Type | Syntax | Behavior |
|---|---|---|
| **Absolute** | `#equipment/zone_temp` | Fixed reference to one specific point, regardless of which graphic instance is viewed |
| **Relative** | `~equipment/lstat/present_value` | Resolves relative to the current graphic's binding — reusable across multiple identical equipment instances (e.g., one VAV template used on 40 VAV boxes) |

Rule of thumb: use **relative (`~`)** paths for any graphic template meant to be duplicated across similar equipment (VAV boxes, FCUs, identical AHUs) so one template serves many instances. Use **absolute (`#`)** paths for one-off dashboard elements tied to a specific, non-repeated point (e.g., a single chiller plant summary screen).

Conditional show/hide and color logic uses JS-style expressions against a path, e.g. `$path$ == true` ([ALC ViewBuilder walkthrough](https://www.youtube.com/watch?v=apAV3jUYsc8)).

See `references/graphics-viewbuilder.md` for full ViewBuilder standards, dashboard/floorplan/diagnostic-screen conventions, and editable-setpoint practices.

## Best Practices

- Always back up before touching a live database — treat this as non-negotiable, not situational.
- Name every database and backup per the standard on creation, not retroactively.
- Design the Geographic Tree for the operator; design the Network Tree for the technician; use Source Trees to model resource-provider relationships (Cool/Heat/Demand Source). Don't merge these mental models.
- Use confirmed COV over polling wherever the integration allows it — both at BACnet discovery/integration time and at trend-configuration time.
- Keep custom reports under the 50-column/1000-row ceiling by splitting reports, not by trimming useful columns.
- Validate a migration on a replicated copy before ever touching production; never start the Windows service early.
- Use Global Modify wildcard syntax (`*`, `?`) for any change spanning more than a handful of identical control programs — faster and less error-prone than editing each one by hand.
- Never copy/paste a MySQL/Oracle/PostgreSQL database folder — only Derby tolerates that; everything else corrupts irrecoverably.
- Keep customer training focused on operator tasks (navigation, setpoints, schedules, alarms, trends) — push EIKON/ViewBuilder/server-level detail to internal or advanced-owner training instead.

## Common Mistakes

- **Skipping the backup** before a database edit or upgrade — the most common cause of unrecoverable data loss in the field.
- **Naming databases inconsistently** or leaving default names — makes remote troubleshooting and handoffs slower.
- **Confusing Geographic and Network tree edits** — moving a device in one tree without checking the other, breaking graphics bindings or comms troubleshooting paths.
- **Forgetting to mark third-party BACnet points "network visible"** before running discovery — the points simply won't appear, and technicians waste time assuming discovery is broken. The same flag is required before a point can be linked into a Source Tree rule.
- **Building a report over 50 columns or 1000 rows** — it will truncate silently rather than erroring clearly; always split large reports proactively.
- **Using absolute (`#`) paths on templated graphics** meant to be reused across many equipment instances — breaks the moment the template is duplicated; should have been relative (`~`).
- **Upgrading production directly** instead of replicate → upgrade → validate — skips the safety net that catches broken graphics/trends/schedules before customers notice.
- **Assuming ARCnet-to-MS/TP is a software toggle** — it requires a physical jumper move on older controllers; scheduling field time for this is often missed.
- **Copy/pasting a MySQL/Oracle/PostgreSQL database folder** for "transport" the way Derby allows — this corrupts the database, unrecoverably.
- **Using `?` where `*` was needed (or vice versa) in a Global Modify wildcard** — `?` matches exactly one character per position and will silently miss/overmatch names of a different length than expected.
- **Uninstalling the wrong version's Windows service** — removing one version's service registration removes it for all WebCTRL versions on that machine.
- **Turning a customer training session into a programming lesson** — buries the operator-level takeaways the customer actually needs under advanced BAS theory.

## Reference Files

- `references/server-admin.md` — WebCTRL editions and point limits, version history (v7–v9/v10/Cloud), add-ons (MQTT, Trend Export, REST API), Environmental Index detail, Open Integrations Platform (7 paths), and migration-phase detail. Read this for edition licensing questions or version-specific feature questions.
- `references/server-lifecycle.md` — full backup/replication procedure, the 10-phase server upgrade/migration checklist, WebCTRL-as-a-Service install/uninstall, PostgreSQL 4-step setup, dealer license update steps, patch/update installation, Source Trees worked example, database/clippings management, Global Modify wildcard reference, ALC Tech Support/Portal info, and the full customer training delivery guide. Read this for any hands-on server lifecycle task or before delivering customer training.
- `references/webctrl-10.md` — WebCTRL 10 feature detail (Trailguide, smarter BACnet discovery, live/hosted backups, ACxelerate 3.0, Predictive Insights) and Test & Balance v10 field notes. Read this when a job is on or upgrading to v10.
- `references/graphics-viewbuilder.md` — ViewBuilder graphics standards, path syntax deep-dive, dashboard/floorplan/diagnostic-screen conventions, editable setpoints, conditional color/visibility logic, Common Symbols. Read this when building or reviewing any ViewBuilder graphic.
