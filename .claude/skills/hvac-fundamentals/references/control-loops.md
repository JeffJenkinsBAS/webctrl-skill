# Control Loops Reference

Deep reference for PID theory, tuning methods, cascade control, deadbands, and hunting diagnosis. Read alongside the PID Tuning Workflow section in SKILL.md.

## PID Loop Roles

Source for this section: [David Sellers/PECI, *An Overview of Proportional plus Integral plus Derivative Control*](https://www.av8rdas.com/uploads/1/0/3/2/103277290/final_-_pid_paper.pdf).

**Proportional (P):**
\[ \text{Output} = K_P \times \text{Error} \]
Produces an output proportional to the current error (deviation from setpoint) but — except at one specific load condition — always leaves a residual **proportional offset/error**, because a nonzero output (needed to hold any load other than the one calibration point) requires a nonzero error under pure P control. Gain is often expressed as **throttling range** (the input span that drives the output through its full range) or **proportional band**. Example: a 10°F throttling range pneumatic loop needs a full 10°F deviation to stroke a valve from closed to open; at mid-stroke calibration, the discharge temperature must drift ±5°F from setpoint to reach either end of stroke.

**Integral (I):**
\[ \text{Output} = K_P \times e + K_I \times \int e\, dt \]
Integral action eliminates the proportional offset over time by accumulating error and increasing/decreasing output until error is driven toward zero. Gain is expressed in **repeats per minute** or **minutes per repeat**. Caution: adding integral action to a system previously tuned as P-only usually requires *reducing* proportional gain to maintain stability. **Integral windup** occurs when the controlled equipment cannot physically satisfy demand (e.g., an undersized/overloaded coil) — the integral term keeps accumulating, driving output (and eventually the final control element) to its limit and staying there, producing sluggish, overshoot-prone recovery once load conditions change; most DDC controllers implement some anti-windup logic, and best practice on scheduled equipment is to zero/freeze the integral term whenever the associated equipment is off.

**Derivative (D):**
\[ \text{Output} = K_P e + K_I \int e\, dt + K_D \frac{de}{dt} \]
Responds to the *rate of change* of error, damping sudden swings — most useful at startup or with marginally oversized final control elements (e.g., large VAV system static pressure transients at fan start). Derivative action is **not commonly needed** in HVAC and is easy to misapply: insufficient derivative provides no real benefit, while excessive derivative gain "can cause many more problems than it cures."

## Tuning Approaches

**Closed-loop (Ziegler–Nichols-style) tuning:**
1. Zero out I and D.
2. Increase proportional gain until the loop just begins to sustain oscillation — this is the **ultimate gain**.
3. Measure the oscillation period — the **natural period**.
4. Set: proportional gain = ¼ to ½ of ultimate gain; integral time = 1.2 × natural period (minutes/repeat); derivative time = ⅛ of natural period (minutes).
5. Validate with setpoint changes and start/stop cycling.

**Open-loop (process-reaction curve) tuning:**
1. Place in manual, stabilize, introduce a step change; then a reverse step of twice the magnitude; then return to starting output.
2. Measure apparent dead time and the reaction slope (%output span change per minute, normalized to the step size).
3. Set: proportional gain = 1/slope to 1/(2×slope); integral time = 5 × dead time; derivative time = 0.5 × dead time.
4. As a rule of thumb, **natural period ≈ 4 × apparent dead time**.

**Tuning objective**: A well-tuned loop shows a **quarter-decay ratio** — each successive oscillation peak about 25% the magnitude of the prior peak — settling to a stable point after a few decaying oscillations following an upset. Loops that settle slowly need more P/I gain; loops that stay oscillatory have too much gain.

**Where to use P-only vs. full PID**: P-only is appropriate where high precision isn't economically warranted — the paper specifically cites **zone temperature control** as a prime P-only candidate, along with secondary/limit loops like mixed-air low-limit control. Integral action should be reserved for loops where precision matters or where offset causes real energy waste — **chilled water temperature control and building static pressure control** are the specific examples given. In cascaded/highly interactive loop sets, it can be preferable to apply full PID only to the critical (outer or most sensitive) loop and leave the others as simple P.

## Typical Starting Values by Loop Type

Use these only as starting points for commissioning — always validate against actual system response, and expect to retune after the first heating/cooling season transition.

| Loop | Typical mode | Typical gain characteristics | Rationale |
|---|---|---|---|
| Zone temperature | P-only or light PI | Wide throttling range (e.g., 4–8°F) | Sellers' named P-only example; comfort tolerance is wide, precision not economically warranted |
| Discharge/supply air temp (cascade inner loop) | PI | Fast response, moderate gain | Isolates fast coil/valve dynamics from slow zone dynamics |
| Chilled water supply temperature | PI | Moderate gain, integral time on the order of minutes | Sellers' named PI example — offset here costs real chiller energy |
| Hot water supply temperature (OA reset) | PI | Similar to CHWST | Same rationale — avoid steady-state offset from the reset curve |
| Duct static pressure | PI | Tuned to fan/duct time constant; watch for interaction with VAV box loops | Sellers' other named PI example |
| Building static pressure | PI | Slow-moving, small gain | Building envelope has large volume/slow response; avoid overreacting to transient door openings |
| VAV box airflow (cascade inner loop) | PI, fast | Fast response, sized to damper actuator stroke time | Must track setpoint changes from the outer zone-temp loop quickly |
| Mixed-air low-limit | P-only | Narrow throttling range for fast freeze protection response | Sellers' named secondary/limit-loop P-only example |
| Fume hood face velocity (VAV) | PI or manufacturer-specific | Fast, tuned to sash-position sensor response | Life-safety loop — must track sash movement quickly without hunting |

## Cascade Control

Cascade control nests a fast inner (secondary) loop inside a slower outer (primary) loop: the outer loop's output becomes the setpoint for the inner loop, rather than driving the final control element directly. Classic HVAC example: a **discharge (or supply) air temperature loop cascaded from a zone temperature loop** — the zone loop's output sets the AHU discharge-air-temperature setpoint, which a faster discharge-air PID loop then holds by modulating the valve/damper. This isolates the slow-responding, high-thermal-mass zone dynamics from the fast-responding coil/valve dynamics, generally producing tighter, more stable control than a single loop trying to manage both timescales at once ([oaktrust.library.tamu.edu, *Cascaded Control for Improved Building HVAC Performance*](https://oaktrust.library.tamu.edu/server/api/core/bitstreams/04175478-867d-4f93-a6f3-5794ffea0244/content)). VAV airflow control is itself a cascade: zone temperature (outer) sets an airflow setpoint, and an airflow loop (inner) modulates the damper to that flow setpoint regardless of upstream static pressure disturbances.

**Tuning order for cascades**: always tune the inner (fast) loop first, in isolation if possible, then tune the outer (slow) loop against the now-stable inner loop. Tuning outer-first against an untuned/unstable inner loop produces confusing, non-repeatable results.

## Reset Strategies (Cross-Reference)

Reset logic recurs throughout HVAC control precisely because most plant/AHU capacity is oversized for the majority of operating hours; trim-and-respond resets continuously find the minimum energy input that still satisfies the most-demanding zone/coil, rather than running at fixed design conditions year-round:

- CHWST / condenser water reset — see `chiller-plants.md`
- Chilled/hot water differential pressure reset — see `chiller-plants.md`
- Hot water supply temperature (OA) reset — see `heating-plants.md`
- Supply air temperature reset — see `airside-systems.md`
- Duct static pressure reset — see `airside-systems.md`

## Deadbands

A deadband is an intentional "no control action" zone between heating and cooling setpoints (or around a single setpoint) to prevent simultaneous heating and cooling and to reduce needless actuator cycling. Common commercial practice uses a 2–5°F deadband between occupied heating and cooling setpoints (e.g., heat to 70°F / cool to 75°F). Overly narrow deadbands increase energy use (simultaneous heat/cool) and actuator wear; overly wide deadbands compromise comfort — this is a direct analog to the throttling-range stability tradeoff discussed below.

## Causes of Hunting

Hunting (sustained oscillation) in HVAC control loops arises from an interaction between controller sensitivity (narrow throttling range/high gain) and system lag/inertia ([David Sellers/PECI, *PID Overview*](https://www.av8rdas.com/uploads/1/0/3/2/103277290/final_-_pid_paper.pdf)):

| Cause | What it looks like | Mitigation |
|---|---|---|
| Time lags/inertia (transport/dead time, sensor time constant, actuator stroke time, coil thermal mass, linkage/valve hysteresis) | Loop overshoots before it "sees" the effect of its last move | Reduce gain to match the system's actual response speed; consider cascade to isolate fast/slow dynamics |
| Excessively narrow throttling range/high gain relative to system response | Loop "outruns" the physical system, oscillates | Widen throttling range / reduce gain until oscillation stops |
| Periodic disturbances near the loop's natural frequency | Oscillation resonates rather than damps | Identify and address the disturbance source (e.g., a cycling upstream device) |
| Interacting loops (e.g., hunting mixed-air dampers disturbing duct static pressure loop) | One loop's oscillation shows up as noise/disturbance in another | Tune the source loop first; consider decoupling via cascade or sequencing |
| Nonlinearities in heat transfer devices, thermistors, or ΔP-based flow elements | Gain that's stable at one operating point isn't stable at another | Use gain scheduling or accept conservative tuning across the full range |
| Velocity limiting — process changes faster than the actuator can physically move | Output commands outpace actuator stroke time, producing lag-driven overshoot | Check actuator stroke time against loop update rate; slow the loop or upsize the actuator |
| Hysteresis/backlash in linkages and valve packing | Small-amplitude limit cycles that never fully settle | Mechanical maintenance/replacement; can't be tuned out purely in software |
| Mismatched control-signal span vs. actuator span | Behaves like a windup problem | Verify calibration/span mapping between controller output and actuator input |
| Digital filter/sampling artifacts | Aliasing with disturbance frequency, or filter reacting to insignificant noise | Adjust sample rate/filter time constant to match the physical process, not just default controller settings |

**Practical mitigation summary**: widen throttling range/reduce gain until oscillation stops, minimize lags where possible, and expect that the "ultimate gain" point shifts seasonally and with equipment wear — loops tuned in winter (or at part load) may need retuning for summer (or full load) operation; conservative tuning during the first year of a new system's operation is recommended practice.

## Common Mistakes (Control Loops)

- Adding integral action to a P-only loop without reducing proportional gain — a frequent path into hunting.
- Not freezing/zeroing the integral term when equipment is off — leads to integral windup and sluggish, overshoot-prone restart behavior.
- Applying derivative gain "just in case" — in HVAC, unnecessary D more often introduces problems than solves them.
- Tuning an outer cascade loop before the inner loop is stable — produces non-repeatable results; always tune inner-to-outer.
- Tuning once at commissioning and never revisiting — ultimate gain and natural period shift with season and equipment wear; retune after the first full heating/cooling cycle.
- Treating every loop as needing full PID — reserve PI for loops where offset costs real energy (CHWST, HWST, static pressure); P-only is correct and sufficient for zone temperature and limit loops.
