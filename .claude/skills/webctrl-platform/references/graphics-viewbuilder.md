# ViewBuilder Graphics Standards

ViewBuilder is ALC's WYSIWYG graphics editor for building operator-facing dashboards, floorplans, and diagnostic screens on top of a WebCTRL/SiteBuilder database.

## Path Syntax — Deep Dive

| Type | Syntax | Resolves | Use for |
|---|---|---|---|
| **Absolute** | `#equipment/zone_temp` | One fixed, specific point — always the same point no matter where the graphic is viewed from | One-off dashboard elements, plant-level summary screens, anything not duplicated |
| **Relative** | `~equipment/lstat/present_value` | Relative to the graphic's current binding context | Reusable templates applied across many identical equipment instances (VAV boxes, FCUs, repeated AHUs) |

**Decision rule**: if you will ever copy/paste this graphic onto a second piece of equipment, it must use relative (`~`) paths. If you build it with absolute (`#`) paths and then duplicate it, every copy will silently point back at the *original* equipment's data — a common and hard-to-spot graphics bug. Audit any graphic before duplicating it: search for `#` paths and convert any that should be relative.

## Conditional Logic

Show/hide and color-changes use JS-style boolean expressions evaluated against a bound path:

```
$path$ == true
```

Example patterns:
- Show an alarm icon only when active: `$alarm_active$ == true`
- Color a zone red when above setpoint + deadband: `$zone_temp$ > ($setpoint$ + 2)`
- Hide a heating-stage indicator when the unit is in cooling mode: `$mode$ == "cooling"`

Demonstrated in [this ALC ViewBuilder walkthrough](https://www.youtube.com/watch?v=apAV3jUYsc8).

## Editable Setpoints

- Bind a setpoint field directly to the BACnet Setpoint microblock's live path (not to a static/display-only value) so an operator edit writes through to the control program.
- Always pair an editable setpoint with a visible **current value** readout nearby, so the operator can see the actual sensed value alongside the point they're adjusting — prevents confusion between "what I set" and "what it's actually doing."
- Constrain editable ranges in ViewBuilder to match the safe operating range enforced in EIKON (don't let the graphic allow input outside what the logic will actually accept).

## Live Microblock Data Paths

Both absolute and relative paths can point at **any** live microblock output — not just sensor values. Common bindings:
- AI/BI values (raw sensed inputs)
- AO/BO command values (what's being driven)
- Setpoint microblock outputs (active setpoint after resets/deadbands)
- Trend microblock history (for embedded trend graphs)
- Alarm microblock state (for status icons/coloring)

## Dashboards, Floorplans, Diagnostics — Conventions

**Dashboards** (building/plant-level summary screens):
- Lead with the highest-value KPIs: Environmental Index score, active alarm count, equipment status summary.
- Use absolute paths for plant-level, non-repeated equipment (chillers, boilers, main AHUs) since these are rarely duplicated as templates.

**Floorplans** (SVG-based, dynamically resizing since v8):
- Bind each zone polygon to that zone's temperature/status via relative paths if the floorplan is a reusable per-floor template.
- Use conditional color logic to reflect comfort/alarm state at a glance (e.g., green = in range, red = alarm, gray = offline).

**Diagnostic screens** (technician-facing, not operator-facing):
- Surface raw AI/BI values alongside calculated/derived values (e.g., show both the raw airflow sensor value and the calculated CFM) so a technician can spot sensor vs. logic issues quickly.
- Include a live logic link/shortcut where possible — pairs with EIKON's Live GFB debugging (see `eikon-programming` skill) so a technician can jump from a graphic straight into the running control program.
- Keep operator-facing **Home Screens simple**; push diagnostic depth to secondary Info/Diagnostic screens — this mirrors the ZS/RS sensor UI philosophy (simple home screen, detail on info screens) and should be applied consistently across all graphics, not just sensor displays.

## Common Symbols (recent addition)

Reusable shared graphic components were added in a recent WebCTRL Cloud release ([WebCTRL Cloud release notes, 4/13/2026](https://www.automatedlogic.com/en/media/WebCTRL%20Cloud_ReleaseNotes_04132026_tcm702-280589.pdf)). Use Common Symbols for any icon/indicator reused across many graphics (fan icons, valve icons, alarm bells) so a single edit propagates everywhere — avoid manually copy-pasting the same icon graphic across dozens of screens, since that makes future style updates a multi-hour manual task instead of a one-line edit.

## Additional Graphic Features

- **Graphic layering** (v7.0+) — stack multiple graphic elements/overlays on a single screen.
- **Embeddable WebApps** — embed external web content inside a ViewBuilder screen.
- **BACview-compatible screen layouts** — ensure graphics remain usable on BACview-class local operator displays, not just full WebCTRL client sessions.

## Common Mistakes

- Using absolute paths on a graphic intended to be duplicated across many equipment instances — breaks silently on the first copy.
- Editable setpoint fields with no visible current-value readout — operators can't tell if their change took effect.
- Overloading operator Home Screens with diagnostic-level detail — buries the information operators actually need under technician-only clutter.
- Not auditing existing graphics for `#` vs `~` path type before reusing them as a new template.
- Manually duplicating icon/indicator graphics across many screens instead of using Common Symbols — creates a maintenance burden on any future rebrand or style change.
