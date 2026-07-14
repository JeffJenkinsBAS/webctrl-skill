# WebCTRL Server Lifecycle — Backups, Migration, WaaS, PostgreSQL, Licensing, Patches

Full field procedure detail for keeping a WebCTRL server backed up, licensed, patched, and correctly running as a Windows service. Read this before any on-site backup, upgrade, service reinstall, PostgreSQL setup, license swap, or patch install.

## Database Types — Know Which One You're Touching

| Type | Behavior | Copy/paste transport? |
|---|---|---|
| **Derby** | Default/bundled database; trends, audit logs, and alarms all live inside its own folder | **Yes** — Derby folders can be copied (Ctrl+C/Ctrl+V) for transport. Only type safe to move this way. |
| **MySQL / Oracle / PostgreSQL** | External DB engine houses trends/audit/alarms/data; WebCTRL writes to and references it | **Never.** Copy/paste on these WILL corrupt the database — unrecoverable. |

Derby cannot run a medium/large system long-term — its folder grows too large and causes comm loss/integrity issues over time. It remains useful specifically as a transport format ahead of an upgrade/migration, and as the always-available fallback/default type. Most customer production servers run MySQL (most common), though some customers require Oracle (e.g., v19) or PostgreSQL.

## Backup Database Naming Standard (backup-specific)

The general SiteBuilder naming standard (`SITENAME_VERSION_DBTYPE_BKUPDATE`, see main SKILL.md) has a specific convention when the backup itself is a Derby replicant:

```
<SITENAME>_derby_wcXX_<TODAYSDATE>
```

Example: `comfort_group_derby_wc85_5242023`

## Creating a Backup Database — Full Procedure

Backups reflect IP changes, parameter adjustments, and commissioning/T&B progress. They live on the office shared drive so Engineering can build new projects from the current site state — treat this as a live-document responsibility, not a one-time task.

**Prerequisites:** access to the customer server (VM or physical), an external drive/thumbdrive, and enough on-site time (replication can take hours on large systems).

**Preparing for the backup:**
1. Verify file egress is allowed at the site — some sites block thumbdrives for cybersecurity reasons; confirm before you need to move the file.
2. Email the PM/customer with planned offline time (roughly 20 minutes for a simple backup) and an emergency contact.
3. Open WebCTRL and run the manual command `whoson` to check for logged-in users.
4. If users are present, issue the `notify` command: *"The WebCTRL server will be going offline in X minutes for a backup procedure, the system will be offline for approximately Y minutes. If there are any issues with this planned procedure please contact [Name] at [Phone] to reschedule this procedure."*
5. Stop the service via Windows Services (search "Services" → find "WebCTRL x.x" → Stop Service).
6. Open SiteBuilder as Administrator (right-click → Run as administrator).

**Replication procedure (always select REPLICATE — it is not the default option in the Migrate/Replicate window):**
1. With the database open (GEO/NET tree items visible), click **File → Manage Database → Replicate database → Next**.
2. Name the replicant per the standard above.
3. Ensure **Database Type = Derby → Next**.
4. Leave defaults; check only **"Replicate main database"** and **"Copy system files (programs, views, etc.)" → Next**.
5. Confirm settings → Next → wait for progress bars to complete → Finish.
6. Navigate to the `\webroot` folder (v8.0 or earlier) or `\programdata\systems` folder (v8.5+) to find the new backup folder.
7. Right-click and compress it to a `.zip`.
8. Move it to an external/thumbdrive, then to the site-specific backups folder — typically `C:\WebCTRLx.x\WebCTRL Backups`.
9. **Critical:** only the main (non-dated) database folder should remain in webroot/systems — backup databases must never be left there.
10. Bring the compressed backup back to the office (or use VPN) and upload it to `O:\ALC\Webctrl System Files` (version-specific folder). This is what Project Engineers pull from for new projects — it must stay current.

**The server must NOT restart or lose power during replication** — keep a laptop plugged in for the duration.

## Server Upgrade / Migration — 10-Phase Checklist

This is the authoritative phase-by-phase sequence; it supersedes a generic "replicate → upgrade → validate" summary with the specific field checklist.

**Must-read warnings before starting:**
- Backup is **not optional** — a failed upgrade with no backup can permanently corrupt the database.
- Expect extended downtime: small sites 0.5–3+ hours; large systems may extend into the next day. Browser sessions time out after roughly 60 minutes. Equipment keeps running on existing schedules/setpoints during the outage (operators simply cannot see it).
- Install location: best practice is a non-C: drive (D:, E:); only use C: if there is no alternative.
- Do **not** start the Windows service too early — it must stay "Manual" startup type until the database is restored, the upgrade is complete, and the system is verified.
- Notifications are required at **T-60 min, T-30 min, and T-5 min** before stopping the service.

**Phase 1 — Customer Notification.** Send notify messages at T-60 (example: *"Scheduled WebCTRL Outage Notice: The WebCTRL server will be taken offline beginning at [START TIME] for a planned server backup, migration, and upgrade that may extend into [EXPECTED DURATION]…"*), T-30, and T-5.

**Phase 2 — Shut Down Existing Server.** Open Windows Services → Stop `WebCTRL x.x` → Disable the service (right-click Properties → Startup Type → Disabled) to prevent accidental restart.

**Phase 3 — Create Full Backup.** Open SiteBuilder as Admin → open the customer system DB → File → Manage System → Migrate/Replicate Database → select Full Backup (Derby) → include Trends, Alarms, Audit Logs, System Files. Wait: small systems 30–60 min, large systems 2+ hours.

**Phase 4 — Prepare New Server (in parallel with Phase 3).** Install WebCTRL preferably on `D:\WebCTRLx.x\` (not preferred: `C:\WebCTRLx.x\`). Install PostgreSQL per the setup guide below (configure DB user/port/auth). Do not start the service yet.

**Phase 5 — Transfer System.** Copy `WebCTRL\webroot\<system name>` (old) to `WebCTRL\programdata\systems\` (new).

**Phase 6 — Restore and Upgrade.** Open SiteBuilder (Admin) → Open Migrated System → File → Upgrade → WebCTRL System → (if required) File → Manage Database → Migrate.

**Phase 7 — Install WebCTRL as Service.** Open Command Prompt (Admin) → navigate to install directory (`cd C:\WebCTRLx.x\bin`, or switch drive first, e.g., `D:` then `cd \WebCTRLx.x\bin`) → run `webctrl-server install` → set Startup Type to Manual.

**Phase 8 — Validate.** Start the service manually; verify login works, graphics load, trends are intact, alarms are active, and the network is stable.

**Phase 9 — Finalize.** Set the service to Automatic; restart the service and confirm a clean startup.

**Phase 10 — Post-Upgrade Tasks.** Reconfigure/copy certkeys (TLS/certificates); reinstall add-ons or allow unsigned ones if needed; clear browser cache on client machines; remove the old WebCTRL service.

**Final notify message:** *"WebCTRL system restored: the upgrade is complete and the system is back online; if you experience issues, refresh your browser or log out and back in; for assistance, contact [TECH NAME] ([EMAIL]); thank you."*

**Common failure points:** skipping backup; installing on C: when D: exists; starting the service too early; forgetting to disable the old server; not verifying the system before go-live.

**Best practices:** run backup and new server setup in parallel; schedule upgrades early in the day; expect trend databases to slow things down; always test locally before handing back to the customer.

## WebCTRL as a Windows Service — Install/Uninstall

**Setup:** open Command Prompt as Administrator first (Start → type cmd → right-click → Run as Administrator → Yes). Without admin rights, install/uninstall will fail with permission errors.

**Navigation:** switch drive if needed (e.g., `cd C:\` or `D:`), then `cd WebCTRLX.X` (e.g., `cd WebCTRL9.0`).

**Install as service:** from within the WebCTRL folder, run `"WebCTRL Service.exe"` and press Enter — this registers WebCTRL as a Windows service to auto-start with Windows and be managed via Windows Services.

**Uninstall from service:** navigate to the folder the same way, then run `"WebCTRL Service.exe" -remove` — this removes the service registration but does **not** delete files or databases.

**Verification:** use `services.msc` (Start menu) to check whether the WebCTRL entry is present/absent as expected.

**Gotcha:** uninstalling a previous WebCTRL version's Windows Service removes the Windows Service registration for **all** versions on that machine — not just the one you targeted. Confirm which versions are actually installed before removing any service registration.

**Tips:** always double-check the version folder name; always run cmd as admin; you can restart the service anytime via `services.msc`.

## PostgreSQL Database Setup — 4-Step Guide

**Step 1 — Install PostgreSQL on Server (10–15 min).** Download the installer from the PostgreSQL website; use the second most recent version (one version behind newest) — file like `postgresql-15.x-windows.exe`. Move to the server if needed. Run the installer; click Next through the screens; when prompted for a password use `root` (type it twice); leave port `5432` unless told otherwise; uncheck Stack Builder on the last screen; click Finish.

**Step 2 — Create PostgreSQL User (5–10 min).** Start → All Programs → PostgreSQL → pgAdmin 4; enter the `root` password; expand Servers → PostgreSQL x.x; right-click Login Roles/Group Roles → Create → Login/Group Role; Name = `root` (lowercase); Definition tab: enter password (this becomes the SiteBuilder login password); Privileges tab: check **Can Login**, **Create Databases**, and ensure **Inherit rights** is ON; Save.

**Step 3 — Create 4 Databases (10–15 min).** In pgAdmin, right-click Databases → Create → Database. Name pattern: `sitename_main`, then repeat for `sitename_alarms`, `sitename_trends`, `sitename_audit`. Owner = `root`. Security tab: add `root` as Grantee, check All privileges. Save each.

> All DB names must be **lowercase** and **under 18 characters**.

**Step 4 — Connect PostgreSQL to WebCTRL in SiteBuilder (10–20 min).** If it's a live site, give a 30-minute user heads-up. Stop the WebCTRL server via Windows Services. Run SiteBuilder as Admin → File → Open (select system) → login → File → Manage Database → Migrate/Replicate → select **Migrate Database** → Database Type = PostgreSQL → rename the system to include "postgresql," e.g., `sitename_webctrl_80_postgresql` → enter connection info: Server = `localhost` or remote IP, Port = `5432` (unless changed), Instance = each database name (main/alarms/trends/audit), Login = `root`, Password = from Step 2 → Next → finish. Optional: check "Make this the default system."

The full internal timeline breaks each step into sub-steps (1.1–1.9, 2.1–2.8, 3.1–3.7, 4.1–4.10) matching the time estimates above — budget roughly 45–60 minutes total for a full PostgreSQL cutover.

## Updating the WebCTRL Dealer License

1. **Save the current dealer license:** locate the license folder — `C:\WebCTRLx.x\resources\properties` (pre-v8.5) or `C:\WebCTRLx.x\programdata\licenses` (v8.5+). Move the existing `license.properties` file to a safe location (e.g., Desktop) and rename it to `olddealerslicense.properties`.
2. **Drop in the new license:**
   - **Pre-8.5** — copy/paste or drag-drop the new dealer license file into the `resources\properties` folder where the old one was removed.
   - **8.5+** — copy the latest WebCTRL version's license file to previous versions' folders (backwards compatible), e.g., copy from `WebCTRL9.0\programdata\licenses` to `WebCTRL8.5\programdata\licenses`.
3. Open that version's SiteBuilder locally to verify the license is functional — a pop-up message appears if it was not done correctly.

## Installing Patches and Updates to WebCTRL

**Responsibility:** whoever holds the laptop used for troubleshooting/commissioning. The Engineering & Training Manager sends notice when a new ALC patch/update drops — install promptly to avoid version mismatches between the Project Engineer's build and the technician's checkout/commissioning system (mismatches can cause login/connection issues).

**Procedure:**
1. Run SiteBuilder **"As an administrator"** (right-click → Run as administrator). If you can't run as admin, escalate to IT immediately.
2. Click **"Help"** in the top toolbar — this must be done with no database loaded/running locally.
   - On a fresh WebCTRL install, only install the **most recent cumulative patch** (it includes everything from prior patches), then all updates on top — no need to apply every past cumulative patch individually.
3. Click **"Apply Update"** → a pop-up with a "Browse" button appears.
4. Click Browse; navigate to the downloaded update file. Update files come from three places: the **ALC Online Portal**; the office shared drive (`O:\ALC\Install Files\WebCTRL`); or **ProCore** (4TRAIN > WebCTRL Updates).
5. Select the correct file for the version being updated → click Select. (Check the current SiteBuilder/WebCTRL version via Help → About if unsure.)
6. After clicking Select, red text appears indicating a restart is needed to take effect — updates can be stacked and applied with a single restart.
7. Close SiteBuilder once all updates are queued.
8. Re-run SiteBuilder "As an administrator" and wait — this may take significant time on fresh installs.
   - To check progress while waiting: navigate to the WebCTRL folder for that version and hover over the temp folder named "update on restart" — folder size growth indicates progress.
   - A file named `update.lock` may appear/disappear during the process — it locks the software from opening during critical background updates.

## Source Trees — Parent/Child Equipment Relationships

Source Trees link "parent" and "children" equipment (e.g., a Chiller Plant/AHU are parents providing temperature-controlled media; VAV boxes are children consuming it). This is the mechanism the Global Modify wildcard and reset-ripple/lock testing in `eikon-programming` rely on for cross-equipment logic.

**Navigation:** right-click anywhere in the GEO tree (live WebCTRL system, customer server, or local laptop) → select **"Set up Tree"** to open the Set up Tree window. WebCTRL 7.0/8.0 had 3 tabs; WebCTRL 8.5+ has 2 tabs (treat 8.5+ as the standard going forward).

**Default Source Trees** auto-generated in every system: Cool Source, Heat Source, Demand Source, Environmental Index.

**Editing an existing tree:** navigate/click the tree (e.g., Cool Source Tree). **Red text** = unassigned equipment; **black text** = assigned equipment (child assigned, or parent has equipment assigned to it). To add equipment: select it in the left GEO tree window, then place it at the correct level in the right GEO tree window.

**Parent/child hierarchy example:**
- Cooling: Chiller Plant → parent to AHU; AHU → child of Chiller Plant AND parent to VAV box w/ Reheat; VAV box → child of AHU. (Chilled water flows Chiller Plant → AHU coil → air to VAV box.)
- Heating: Boiler Plant → parent to AHU AND VAV box w/ Reheat; AHU → child of Boiler Plant AND parent to VAV Box; VAV Box → child of both Boiler Plant AND AHU.

**Creating a new Source Tree (worked example — average VAV damper position rolled up to AHU):**
1. Open a text doc to record refnames for the parent/child microblocks to link. Use asterisk `*` wildcard if a parent needs to receive from multiple children.
2. Ensure the child output point (e.g., Damper Position) is **"Network Visible"**: open the microblock → Details tab → check "Network Visible."
3. Copy the refname of that point into the text doc.
4. In the parent program (AHU), locate/add the Average microblock(s) that will receive data from children; copy that refname too.
5. Right-click the GEO tree → "Set up Tree" → go to the 2nd tab (Source Tree Manager) → click "Add" to create a new Source Tree (e.g., name it "Average Damper Position," give it a unique refname, OK).
6. With the new tree selected, click "Add" under Rules to create a rule; fill in the previously copied parent/child refnames to connect microblocks across the network.
7. Map equipment: select the Parent equipment in the left window, click the right-arrow to associate it under the desired level in the right window (e.g., AHU-1 under Nashville area); then select AHU-1 in the right window and add children (VAV boxes) via the right-arrow.
8. Once mapped, microblocks show a small **lock icon** next to the path — this indicates pathing is set/locked via the Source Tree and not manually configured.

**Documented gotcha:** initial averaging logic didn't account for Average blocks reporting "0" when not enough children reported data. Fix: add logic to exclude non-"Valid" blocks from the averaging/division math, so only actively-reporting microblocks are included in the average.

## Database Management — Backups & Clippings Discipline

**Frequent backups:** always make a backup while SiteBuilder is open on a customer server (see the replication procedure above). Never copy/paste database folders except the Derby type.

**Working with Clippings:**
- Ensure GEO & NET tree items match up (all black text, not red) before making a clipping — red indicates something is missing; only proceed under direct Engineering Department guidance if red items exist.
- When receiving a clipping from Engineering, import it into your database immediately.
- After importing a clipping, delete it so it doesn't get re-imported.
- When sending a clipping back to Engineering, the email must fully describe its contents — which GEO tree items and NET tree items are included — so the Project Engineer knows exactly what's in the file.

**Maintaining Local Backups:** keep the latest three backups from your working database on an external/thumb drive at all times; also keep at least one archived database per past project for programming/graphics reference.

## Globally Modifying Parameters and Setpoints (Wildcard Syntax)

**Global Modify** lets you view a microblock's full path/control program name/required privileges, view or change one property across multiple control programs at once, and view errors on Graphics/Properties pages. Use it any time the same property change needs to be applied across many identical or similar control programs (e.g., every VAV box on a floor) rather than editing each program by hand.

**Prerequisites:** WebCTRL login/access, permissions for global modification of parameters/setpoints, and an understanding of the impact of global changes before applying them broadly.

**Procedure:**
1. Browse to a page showing the target property.
2. Open Global Modify: **Alt+click** the property (or **Ctrl+Alt+click** on Linux), or right-click → **"Global Modify."**
3. Edit the Control Program field if needed, using this wildcard syntax:

| Pattern | Matches |
|---|---|
| `vav*` | `vav`, `vav1`, `vavx`, `vav12345` |
| `vav*z` | `vavz`, `vav1z`, `vavxz`, `vav12345z` |
| `vav*1*2` | `vav12`, `vavabc1xyz2` |
| `vav??` | `vav11`, `vav12`, `vavzz` (**NOT** `vav`, `vav1`, `vav123`) |
| `*` | Any control program in the system |

- `*` is an open-length wildcard; `?` matches exactly one character. Use `?` when you need to constrain to a specific name length (e.g., exactly two trailing characters after `vav`), and `*` when the trailing/leading text length varies.
- Click **"Show Advanced"** to view location, value, and privileges tied to the property.
4. Select the tree item to search under for all occurrences of the microblock in other control programs → click **Find All**.
5. Select properties to change, then either:
   - Type a **New Value** per item individually, OR
   - Select **Enable All**, type new value, click **Set All To**, OR
   - Select **Enable All**, type a value, click **Change All By** (relative/incremental change).
6. Click **Apply Changes**.

## ALC Portal & Tech Support

**ALC Tech Support phone number: 770-429-3002.** Save this number in every technician's phone — it's the point of contact for all major WebCTRL issues. Calling opens a case with ALC Tech Support and assigns an agent, allowing direct tracking and communication with Automated Logic.

**ALC Portal Site login note:** usernames for the ALC Portal Site end with either `.alcprod` or `.partner.prod` — example format: `firstandlastname@automatedcontrolsinc.com.partner.prod`.

## WebCTRL Customer Training — Delivery Standard

Standardizes how technicians deliver customer-facing WebCTRL training for general facilities personnel and operators — foundational operator training, **not** controls-specialist training. Goal: a consistent, repeatable process covering core day-to-day WebCTRL functions, hardware/network infrastructure in plain language, using the customer's live system throughout, taught with confidence and consistency.

**Audience:** facility engineers, building operators, maintenance staff, and general facilities personnel. Do not teach this like a programming or engineering course — keep it practical, visual, and tied to what the customer will actually do.

**Technician mindset:** teach for operator confidence, not technical depth; show the customer their own system early and often; use the GEO Tree and graphics as the main teaching path; translate BAS language into plain language; keep a steady pace and avoid overwhelming the room.

**Percentage-based course allocation** (scale to whatever total contracted training time exists, rather than fixed time blocks):

| Topic / Block | Suggested Share of Total Course Time |
|---|---|
| Sign-in, introductions, and framing | 5% |
| Jobsite walkthrough | 10–15% |
| System overview and navigation | 15% |
| Adjusting setpoints and overrides | 10–15% |
| Scheduling and schedule groups | 10–15% |
| Alarm management | 10–15% |
| Trends and reports | 10–15% |
| Hardware and network overview | 10–15% |
| Troubleshooting basics | 10–15% |
| Final review and Q&A | 5–10% |

**Recommended training flow (10 stages, each with a live-system checkpoint):**

1. **Sign-In and Opening (~5%).** Attendance capture + session overview. Suggested opening line: *"Today's goal is to help you use your WebCTRL system confidently in normal building operation. We are not trying to make anyone a controls programmer."*
2. **Jobsite Walkthrough First (~10–15%).** Before sitting at the workstation: main control panels/controller locations, sensors/wall devices, controlled equipment, network infrastructure, local override switches. Message: recognize main parts of the system, not memorize every wire.
3. **System Overview and Navigation (~15%).** Login, user access basics, GEO Tree navigation, graphics/equipment pages. Live checkpoint: have attendees locate one actual piece of equipment, open its graphic, identify current values/statuses.
4. **Adjusting Setpoints and Overrides (~10–15%).** Identify editable points, change a setpoint, understand overrides, return to normal operation. Message: repeated overrides usually mean the schedule/strategy needs review, not a one-off comfort fix.
5. **Scheduling and Schedule Groups (~10–15%).** Weekly/holiday schedules, temporary overrides, schedule groups. Message: many comfort issues are schedule issues, not equipment failures.
6. **Alarm Management (~10–15%).** Access the Alarm Log, alarm types, acknowledge vs. resolve, alarm history. Message: acknowledging an alarm means it was seen — not that it's fixed.
7. **Trends and Reports (~10–15%).** Create/view a trend log, read trend graphs, export data, common useful reports.
8. **Hardware and Network Infrastructure (~10–15%).** Keep simple: server/workstation, network path, controllers, I/O, sensors, routers/switches. Message: *"sensors read the building, controllers make decisions, outputs command equipment, and WebCTRL lets you see and interact with all of it."*
9. **Troubleshooting Basics (~10–15%).** Repeatable sequence: (1) Check the schedule. (2) Check for overrides. (3) Check alarms. (4) Check whether sensor values make sense. (5) Determine isolated vs. system-wide comm issue. (6) Gather screenshots/time/equipment name/alarm-trend info before escalating.
10. **Final Review and Q&A (~5–10%).** Recap, open questions, escalation guidance.

**Topics to minimize** in operator training (better suited to internal/advanced/engineering sessions): deep EIKON programming discussion, ViewBuilder editing, detailed server startup/shutdown procedures, file structure/backup mechanics, module addressing theory, protocol-level BACnet detail.

**What good delivery looks like:** starts on time and organized; shows the building first, then the interface; uses the customer's actual graphics/equipment repeatedly; stays focused on operator tasks and confidence.

**What weak delivery looks like (avoid):** turning training into a programming lesson; staying in abstract BAS theory too long; using only generic screenshots when the live system is available; jumping into engineering/service-level tools too early.

**Technician preparation checklist (before session):** confirm date/time/room/attendee count; confirm working login credentials; verify customer graphics are usable; identify 3–5 strong live examples; walk the job first; confirm whether safe schedule/setpoint changes can be demonstrated; prepare sign-in; bring support materials.

**Post-training checklist (after session):** confirm attendees had time for questions; document who attended; record unresolved questions/follow-ups; identify whether advanced training is needed for any staff; send completion info internally for closeout documentation.
