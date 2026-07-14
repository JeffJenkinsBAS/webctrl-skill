---
name: webctrl-platform
description: "Guides WebCTRL server administration, SiteBuilder database work, system trees, BACnet discovery, custom reports, trends/alarms, console commands, backups/migrations, and ViewBuilder graphics for Automated Logic (ALC) BAS deployments. Use when the user mentions WebCTRL, SiteBuilder, ViewBuilder, geographic tree, network tree, BACnet discovery, custom report, trend, alarm setup, database backup, server migration, Environmental Index, add-on, or graphics path. Covers database naming standards, discovery workflow, report expression syntax, console diagnostics, and server/version management. Does not cover EIKON control-program logic authoring — see eikon-programming for that."
metadata:
  author: JeffJenkinsBAS
  version: '1.0.0'
---

# WebCTRL Platform Administration

## When to Use This Skill

Use this skill for anything touching the WebCTRL server/front-end layer of an ALC building automation system:

- Standing up or reorganizing a **SiteBuilder** database (geographic tree, network tree, naming)
- Running **BACnet discovery** to find devices/networks and pull point lists for engineering
- Building **custom reports** (trend exports, commissioning summaries, calculated fields)
- Configuring **trends and alarms** at the server/point level
- Using the **console** (CTRL+M) for diagnostics — device counts, comm health, network tracing
- **Backing up, upgrading, or migrating** a WebCTRL server or database
- Understanding **editions, versions, add-ons**, and the **Environmental Index** tool
- Building or reviewing **ViewBuilder** graphics (dashboards, floorplans, diagnostic screens)

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

## Server Management: Backups & Migration

**Before any change** (upgrade, database edit, hardware swap): take a full backup. No exceptions — this is the single most common cause of unrecoverable field incidents when skipped.

Migration sequence (replicate → upgrade → validate):

1. **Replicate** — copy/export the live production database to a working copy named per the naming standard (e.g., `SITENAME_v8_MIGRATE_20260710`).
2. **Upgrade** — run the upgrade against the replicated copy, not the live production database.
3. **Validate** — confirm graphics render, trends/alarms fire, schedules run, and spot-check a sample of control programs before cutting over. Only after validation passes should the upgraded copy replace production.
4. Communicate **controlled downtime** windows to the customer before cutover — WebCTRL upgrades are not always hot-swappable, especially across major versions.

See `references/server-admin.md` for version-by-version feature changes, edition point limits, add-ons, and full migration detail.

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
- Design the Geographic Tree for the operator; design the Network Tree for the technician. Don't merge the two mental models.
- Use confirmed COV over polling wherever the integration allows it — both at BACnet discovery/integration time and at trend-configuration time.
- Keep custom reports under the 50-column/1000-row ceiling by splitting reports, not by trimming useful columns.
- Validate a migration on a replicated copy before ever touching production.

## Common Mistakes

- **Skipping the backup** before a database edit or upgrade — the most common cause of unrecoverable data loss in the field.
- **Naming databases inconsistently** or leaving default names — makes remote troubleshooting and handoffs slower.
- **Confusing Geographic and Network tree edits** — moving a device in one tree without checking the other, breaking graphics bindings or comms troubleshooting paths.
- **Forgetting to mark third-party BACnet points "network visible"** before running discovery — the points simply won't appear, and technicians waste time assuming discovery is broken.
- **Building a report over 50 columns or 1000 rows** — it will truncate silently rather than erroring clearly; always split large reports proactively.
- **Using absolute (`#`) paths on templated graphics** meant to be reused across many equipment instances — breaks the moment the template is duplicated; should have been relative (`~`).
- **Upgrading production directly** instead of replicate → upgrade → validate — skips the safety net that catches broken graphics/trends/schedules before customers notice.
- **Assuming ARCnet-to-MS/TP is a software toggle** — it requires a physical jumper move on older controllers; scheduling field time for this is often missed.

## Reference Files

- `references/server-admin.md` — WebCTRL editions and point limits, version history (v7–v9/v10/Cloud), add-ons (MQTT, Trend Export, REST API), Environmental Index detail, Open Integrations Platform (7 paths), and full migration/backup procedure detail. Read this for edition licensing questions, version-specific feature questions, or a deep migration project.
- `references/graphics-viewbuilder.md` — ViewBuilder graphics standards, path syntax deep-dive, dashboard/floorplan/diagnostic-screen conventions, editable setpoints, conditional color/visibility logic, Common Symbols. Read this when building or reviewing any ViewBuilder graphic.
