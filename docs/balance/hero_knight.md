# Balance — Hero: Knight

Tuning values for the Knight, captured at the end of C5 (Hero Combat Prototype). These reflect what felt right in playtest, not what's mathematically optimal. Re-tune as the game accumulates real enemies and Heirlooms.

**Target feel (GDD §10.4):** *"Heavy and certain. Movements have weight. Block-active stance is committed. Parry windows are tight."*

## Base stats

| Stat | Value | Source | Notes |
|---|---|---|---|
| `base_hp` | 100 | `data/heroes/knight.tres` | Default; meta upgrades will raise this in later phases. |
| `base_damage` | 12 | `data/heroes/knight.tres` | Per sword swing connect. |
| `move_speed` | 80 px/s | `data/heroes/knight.tres` | Was 110 — felt zippy. 80 reads as heavier. Drop to 65 for "plate-armored", push to 95 if it feels sluggish next pass. |

## Movement

| Param | Value | Where | Notes |
|---|---|---|---|
| Velocity lerp factor (idle/walk) | `18 * delta` | `hero.gd:_handle_free_movement` | Higher = snappier acceleration. 18 gives a slight ramp without feeling floaty. |
| Velocity decay (attack) | `10 * delta` | `hero.gd:_physics_process` ATTACK | Slower decay than block — attack carries momentum. |
| Velocity decay (block_start) | `12 * delta` | `hero.gd:_physics_process` BLOCK_START | |
| Velocity decay (block_hold) | `18 * delta` | `hero.gd:_physics_process` BLOCK_HOLD | Tightest — block stance is committed. |

## Attack (LMB)

| Param | Value | Where | Notes |
|---|---|---|---|
| `ATTACK_HITBOX_DELAY` | 0.10 s | `hero.gd` | Windup before hitbox arms. Telegraphs the swing. |
| `ATTACK_HITBOX_DURATION` | 0.18 s | `hero.gd` | How long the hitbox is live. |
| `ATTACK_TOTAL_DURATION` | 0.45 s | `hero.gd` | Total state lockout (windup + active + recovery). |
| `HIT_STOP_DURATION` | 0.05 s | `hero.gd` | Engine.time_scale dips to 0.05 on connect for 50ms. |
| `melee` anim fps | 24 | `knight_animations.tres` | 15 frames × 24fps ≈ 625ms — slower than the state lockout so trail frames continue past recovery; visually fine. |
| Attack pivot offset | 28 px from hero center | `hero.tscn` | AttackHitbox position inside AttackPivot. |
| Attack hitbox size | 48×26 px | `hero.tscn` | Wider than tall — sword arc footprint. |

## Block / Parry (RMB)

| Param | Value | Where | Notes |
|---|---|---|---|
| `PARRY_WINDOW` | 0.20 s (12 frames at 60fps) | `hero.gd` | Was 0.13 — too tight. 0.20 feels achievable but rewarding. If parries are too easy, trim to 0.16. |
| `BLOCK_START_DURATION` | = PARRY_WINDOW | `hero.gd` | Windup state duration is the parry window itself — visual + mechanical timing aligned. |
| `BLOCK_COOLDOWN` | 0.35 s | `hero.gd` | After any block release (parry, sustained, attack-cancel). Prevents spam-tap parry. |
| `block_start` anim fps | 60 | `knight_animations.tres` | Was 30 — animation didn't snap into stance. 60 makes the windup feel like a deliberate move. |
| `block_mid` anim fps | 10 | `knight_animations.tres` | Held loop. Slow on purpose — the Knight is set, not jittering. |
| Block damage from front | 0% (full block) | `hero.gd:_block_multiplier` | Dot product > 0.5 between aim and incoming. |
| Block damage from sides | 50% | `hero.gd:_block_multiplier` | Dot product between -0.5 and 0.5. |
| Block damage from back | 100% (no block) | `hero.gd:_block_multiplier` | Dot product < -0.5. |
| Parry slow-mo | `Engine.time_scale = 0.3` for 0.3 s | `hero.gd:_parry` | Felt right at 0.3 / 300ms. 0.2 / 400ms would be more dramatic. |
| Parry flash modulate | `Color(2.0, 2.0, 1.0)` for 0.25 s | `hero.gd:_parry` | Hot-white flash on the hero sprite. |
| Parry stagger duration | 1.5 s | `hero.gd:_parry` → `attacker.on_parried(1.5)` | Matches GDD spec exactly. |

## Stalwart (passive)

| Param | Value | Where | Notes |
|---|---|---|---|
| `STALWART_HP_THRESHOLD` | 0.5 (50% HP) | `hero.gd` | GDD spec. |
| `STALWART_DAMAGE_REDUCTION` | 0.15 (-15%) | `hero.gd` | GDD spec. Stacks multiplicatively with block. |
| Visual indicator | Red radial gradient aura sprite | `hero.tscn` `StalwartAura` | Toggles `visible` on/off. |

## Camera

| Param | Value | Where | Notes |
|---|---|---|---|
| `Camera2D.zoom` | (2, 2) | `hero.tscn` | 2× game-pixel zoom. Hero takes ~25% of screen height at 1080p. |
| `position_smoothing_enabled` | true | `hero.tscn` | |
| `position_smoothing_speed` | 15.0 | `hero.tscn` | Sweet spot between floaty (8) and stepped (off). |
| Physics interpolation | enabled | `project.godot [physics] common/physics_interpolation` | Required to prevent the hero appearing "dragged a frame behind" the smoothed camera. |

## Hurt / Death

| Param | Value | Notes |
|---|---|---|
| `HURT_LOCKOUT` | 0.20 s | Brief stagger after taking damage. |
| Death | Disables HurtBox + AttackHitbox, plays `die` animation. No respawn yet (handled by run-flow in later phase). |

## Animation frame metadata (`knight_animations.tres`)

| Anim | Frames | FPS | Loop |
|---|---|---|---|
| idle | 15 | 12 | yes |
| walk | 15 | 14 | yes |
| run | 15 | 18 | yes |
| melee | 15 | 24 | no |
| block_start | 15 | 60 | no |
| block_mid | 15 | 10 | yes |
| hurt | 15 | 24 | no |
| die | 15 | 14 | no |

Row order (CW from E): `[e, se, s, sw, w, nw, n, ne]`. See [art/characters/knight/knight_animations.tres](../../art/characters/knight/knight_animations.tres).

## Knowns / not yet tuned

- **No audio at all.** Parry stinger, sword impact, block thud, hurt grunt — all deferred. Will land alongside the SFX library (CP8) before launch.
- **Hit-stop scope.** Currently global (`Engine.time_scale`). Affects everything in the scene including UI animation. Considered acceptable for now; revisit if it interacts badly with multi-enemy fights.
- **Block-cooldown UX.** No on-screen indicator in the production HUD yet (only the dev debug label). Add a small shield-icon-with-radial-fill above the HP bar when we build the production HUD.
- **Parry against melee enemies that contact-damage.** The aggressive `TestDummy` uses distance-based "damage on contact" — it doesn't telegraph an attack windup, so the parry feels reactive rather than predictive. Real enemies will have visible attack windups; expect parry to feel more skill-based then.
