# What's New in WebCTRL 10 — Features & Test and Balance v10

Feature-specific reference for the WebCTRL 10 release. Read this when a customer/job is on v10 or being upgraded to it, or when a technician needs to know what changed versus v9 and earlier.

## Trailguide — Improved Troubleshooting Tool

A new troubleshooting tool that visually shows parent and child equipment as it relates to different Source Trees (see `server-lifecycle.md` for Source Tree concepts), along with the current status of those devices — e.g., viewing the Cool Source tree for an RTU and the PIUs under it, with thermographic color coding and active alarm counts.

- **Privilege note:** with location-dependent privileges enabled, a user without access to specific equipment **can still see** the Trailguide for that equipment but will **not** be able to navigate to it. Keep this in mind when scoping a customer's operator permissions — Trailguide visibility and navigation permission are not the same gate.

## Smarter BACnet Discovery

The BACnet Discovery tool now allows drilling further and specifying exactly what to discover, and lets you export a network discovery file containing all third-party equipment in one file.

The new discovery window lets you choose:
- All devices, **or**
- A specific address, address range, instance, or instance range.

**Example:** if three ABB drives have instance numbers 241501, 241502, 241503, set the instance range to 241501–241503 and discover only those devices — without waiting for the system to search the entire addressing range. Use this on any job with known third-party device instances to cut discovery time dramatically versus a full-range scan.

## Live & Hosted Backups

Described internally as probably the greatest advancement in WebCTRL to date — a **live backup** of the running system, meaning a partial or full database backup can now be accomplished **without taking the server down**. This changes the backup-window conversation with customers: a v10 backup no longer requires the offline-time notification (`whoson`/`notify`) sequence in `server-lifecycle.md` for routine backups, though the same notification discipline still applies for any actual upgrade/migration/service-level work.

Two backup types:

| Type | Covers |
|---|---|
| **Partial** | The typical "light" backup pulled from customer sites — programs, database structure, and graphics |
| **Full** | Everything in Partial, plus all trends, alarms, and audit log data |

Backups can be saved to a location of choice on a schedule, maintaining a specific number of backups automatically, or run manually with the click of a button — with no site interruption either way.

## ACxelerate 3.0

The ACxelerate VAV auto-commissioning add-on has been refreshed and is now included in WebCTRL (previously a separate add-on). New licenses still get 6 months free from date of first use, or two years from install — whichever comes first.

## Predictive Insights (AI Add-On)

An AI-based add-on that actively watches equipment and flags upcoming maintenance issues based on historical data and building control degradation over time. It is a **paid service**; ALC currently runs a promotional offer for customers. Mention this to a customer during v10 upgrade/training conversations as a value-add, but confirm current pricing/promo terms before quoting — they change.

## Version Trajectory Context

For the fuller version-by-version history (v7 through v9, editions, point limits, Open Integrations Platform), see `references/server-admin.md`. v10 sits at the current head of that trajectory as of this reference's writing — always confirm against ALC's current release notes before treating any single version as "latest," since ALC ships updates on an ongoing cadence.

## Test & Balance v10.0

ALC's Test & Balance (T&B) software has a v10.0 release with its own User Guide (distributed as a PDF alongside the software install file — not reproduced here as narrative text). Field notes:

- Confirm the technician's laptop has the matching T&B version installed before a TAB-adjacent commissioning visit, the same way SiteBuilder/WebCTRL version mismatches cause login/connection issues (see patch-install guidance in `server-lifecycle.md`).
- T&B v10 pairs naturally with the live-backup and Trailguide improvements above during commissioning: capture a live backup before/after a TAB pass so the as-commissioned state is preserved without an offline window, and use Trailguide to sanity-check parent/child equipment status while TAB is verifying airflow/balance in the field.
- For the full T&B v10 procedure/UI walkthrough, pull the current User Guide PDF from the ALC Online Portal, the office shared drive, or ProCore (4TRAIN > Documents) — treat the PDF as the source of truth for step-by-step T&B software operation; this reference only captures where T&B fits into the broader WebCTRL 10 feature set.
