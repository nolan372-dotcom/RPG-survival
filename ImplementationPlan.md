# Crown & Wall — Implementation Plan

**Version:** 1.0 (rewritten for new vision)
**Target:** Steam launch in ~6 months
**Team:** Sized to scope — programmers, artists, designers, audio, production
**Engine:** Godot 4.x, primarily GDScript

---

## How to use this document

- This plan lives in the repo as a markdown file. Read it in VS Code's preview pane — checkboxes render as clickable in most markdown viewers.
- Tick boxes as you complete tasks. Each task has acceptance criteria — "done" means the criteria are met.
- The plan is structured as **Phases → Epics → Stories → Tasks**.
- Phases end when their exit criteria are checked. The 6-month calendar puts pressure on phase durations but exit criteria still gate progression — shipping a broken Concept phase saves no time.
- When work reveals new tasks, add them to the document rather than doing them silently.
- Version the document when you make meaningful structural changes.

## Effort sizing

- **XS:** less than half a day
- **S:** 1–2 days
- **M:** 3–5 days
- **L:** 1–2 weeks
- **XL:** 2+ weeks (break down further)

## Phase summary

The 6-month target is roughly:

- **Phase 1: Concept** (~4–6 weeks) — foundation, prototyping, vision lock.
- **Phase 2: Vertical Slice** (~4–6 weeks) — one full biome, one hero, one Siege, end-to-end playable.
- **Phase 3: Content Production** (~8–10 weeks) — all biomes, all heroes, all bosses, all content.
- **Phase 4: Polish, Balance, Launch Prep** (~4–6 weeks) — content lock, balance, audio, marketing, launch.

These are targets, not commitments. Phases must complete to advance.

---

# PHASE 1: CONCEPT

**Goal:** Lock the vision, set up the team and tooling, prototype the highest-risk systems (hero combat feel, procedural placement, waypoint network), validate the loop works on paper *and* in a tiny build.

## Concept Phase Exit Criteria

All must be checked before proceeding to Vertical Slice.

- [ ] Repo, CI, Git LFS, Godot project operational  *(Godot project ✓ — repo/CI/LFS deferred pending remote choice)*
- [ ] Team fully assembled (or hiring plan locked with timeline)  *(N/A — solo)*
- [x] Content data architecture in place (Resources + ContentRegistry)
- [ ] Visual style guide locked and approved by team
- [ ] Hero combat prototype (Knight only) playable and feels weighty
- [ ] Procedural placement prototype works for one biome
- [ ] Waypoint Shrine fast-travel prototype works between two test Shrines
- [ ] Castle plot scene exists with placeholder buildable tiles
- [ ] One placeholder Siege wave plays end-to-end against a placeholder castle
- [ ] Concept retrospective documented
- [ ] Go/no-go decision made to proceed to Vertical Slice

---

## Epic C1 — Team Foundation

### Story C1-S1: Team and roles

- [ ] Finalize team composition: programmers, artists, designers, audio, producer
- [ ] Document role responsibilities and ownership areas in `/docs/team.md`
- [ ] Establish daily/weekly sync cadence
- [ ] Establish PR review rules (minimum: all architecture changes reviewed by another programmer)
- [ ] Establish design review process (proposed mechanics get reviewed before implementation)

### Story C1-S2: Project tracking

- [ ] Select task tracker (Linear / Jira / GitHub Projects / Notion)
- [ ] Import this plan into the tracker (or commit to markdown-as-tracker for at least Concept phase)
- [ ] Establish bug tracking process
- [ ] Establish playtest log location and template

### Story C1-S3: Decision log

- [x] Create `/docs/decisions.md`
- [x] Establish convention: every meaningful design or scope change logged here with date, decision, rationale
- [x] First entry: "v1.0 vision locked, replacing v0.2 rogue-like tower defense direction"  *(plus entries for solo-dev workflow, engine choice, git remote plan)*

---

## Epic C2 — Repo & Engine Setup

### Story C2-S1: Repository

- [x] Create Git repository  *(local `main`, commit `66c3f89` is the scaffold; GitHub remote pending user creating the repo on github.com)*
- [x] Add `.gitignore` for Godot
- [x] Set up Git LFS, tracking `.png`, `.jpg`, `.aseprite`, `.wav`, `.ogg`, `.mp3`, `.ttf`, `.psd`  *(also `.psd .kra .tga .bmp .gif .flac .otf .glb .gltf .mp4 .webm`)*
- [x] Write `README.md` with project overview, setup steps, branch strategy  *(branch strategy section TBD when remote is chosen)*
- [ ] Verify a binary asset commit round-trips correctly  *(pending Craftpix asset import)*

### Story C2-S2: Godot project

- [x] Create Godot 4.x project  *(Godot 4.6.2 stable)*
- [x] Set base resolution to 960×540
- [x] Set stretch mode to `viewport`, aspect `keep`
- [x] Enable pixel snap
- [x] Set renderer to Forward+
- [x] Configure project folder structure: `/autoload`, `/data`, `/entities`, `/scenes`, `/scripts`, `/ui`, `/art`, `/audio`, `/maps`, `/addons`, `/docs`
- [ ] Verify project exports cleanly to Windows, Mac, and Linux  *(Windows ✓ — `.exe` builds and ContentRegistry loads 9 resources at runtime. Mac/Linux deferred — need access to those OSes.)*

### Story C2-S3: CI

- [ ] Set up GitHub Actions workflow for headless Godot export check on push
- [ ] Configure separate workflow for full export build on tagged commits
- [ ] Document CI behavior in README

### Story C2-S4: Input architecture

- [x] Define all gameplay actions as InputActions in project settings  *(move_*, attack, ability, interact, dash, open_build_menu, open_map, rotate_placement, cancel, confirm, pause, debug_dump)*
- [x] Keyboard + mouse default bindings
- [x] Controller default bindings  *(gamepad face buttons, left stick, triggers)*
- [ ] Verify input remapping works correctly in test scene
- [ ] Document input layer conventions for the team

---

## Epic C3 — Data Architecture

### Story C3-S1: Resource classes

- [x] Write `HeroData.gd` (id, class_name, base_hp, base_damage, move_speed, ability_id, passive_id, sprite_frames)
- [x] Write `HeroAbilityData.gd` (id, type, cooldown, parameters)
- [x] Write `BuildingData.gd` (id, footprint_x, footprint_y, cost_wood, cost_food, cost_gold, hp, function_type, parameters)
- [x] Write `WallData.gd` extending BuildingData with wall-specific fields
- [x] Write `TowerData.gd` extending BuildingData with damage/range/fire_rate
- [x] Write `UnitData.gd` (Recruit and Mercenary variants)
- [x] Write `EnemyData.gd` (id, hp, speed, damage, armor_type, drop_table, sprite_frames)
- [x] Write `BossData.gd` (extends EnemyData; adds phase data, telegraph data, retinue)
- [x] Write `MiniBossData.gd` (extends EnemyData; adds heirloom_drop_pool)
- [x] Write `BiomeData.gd` (id, name, tileset_ref, music_ref, ambient_palette, resource_node_density, enemy_spawn_density, mini_boss_pool, quest_pool)
- [x] Write `BiomeTilesetData.gd` (tile assets, transition tiles)
- [x] Write `WaveData.gd` (enemy composition, spawn cadence, spawn lanes, duration)
- [x] Write `SiegeData.gd` (waves[], boss_ref, day_number, music_ref)
- [x] Write `HeirloomData.gd` (id, class_restriction, rarity, effect_modifiers, lore_text, icon)
- [x] Write `CurseData.gd` (id, category, effect_modifiers, lore_text)
- [x] Write `QuestData.gd` (id, biome, prerequisites, objectives, reward_table)
- [x] Write `WaypointShrineData.gd` (id, biome, location, activation_encounter)
- [x] Write `ResourceNodeData.gd` (id, type, harvest_yield, respawn_time)
- [x] Write `MetaUpgradeData.gd` (id, tiers[], cost_per_tier, effect_per_tier)
- [x] Add `class_name` to every Resource class

### Story C3-S2: ContentRegistry autoload

- [x] Create `ContentRegistry.gd` autoload
- [x] Implement directory scanner per resource type
- [x] Implement typed accessor methods (`get_hero`, `get_building`, `get_enemy`, etc.)
- [x] Handle unknown IDs with warnings, not crashes
- [x] Startup logging: counts of loaded resources per type
- [x] Register as autoload in project settings

### Story C3-S3: Mod folder support

- [x] Add mod folder path resolution (`user://mods/`)
- [x] Extend ContentRegistry to scan mod folders after shipped content
- [x] ID collision handling: mod overrides shipped, warning logged
- [x] Create empty `/docs/modding.md` stub
- [x] Test: drop a modified building `.tres` in mod folder, verify override works  *(smoke-tested 2026-05-14 — warning fires, mod count increments, removal returns to baseline)*

### Story C3-S4: Placeholder content

- [x] One `HeroData.tres` (Knight)
- [x] One `BuildingData.tres` (Farm)
- [x] One `WallData.tres`
- [x] One `TowerData.tres` (Archer Tower)
- [x] One `EnemyData.tres` (Grunt)
- [x] One `BiomeData.tres` (Grasslands)
- [x] One `WaveData.tres`
- [x] Two `HeirloomData.tres` (one Common, one Rare)
- [x] Verify all load in ContentRegistry on startup  *(9 shipped resources across 19 categories — headless boot confirms)*
- [x] Debug menu (F1) dumps registry contents  *(via `debug_dump` InputAction in bootstrap scene)*

---

## Epic C4 — Visual & Audio Direction Lock

### Story C4-S1: Visual style exploration

- [ ] Art director presents 3 style options (mood boards, sample sprites)
- [ ] Team reviews and selects direction
- [ ] First-pass hero sprite (Knight, all 8 directions, idle + walk + attack + death)
- [ ] First-pass castle sprite
- [ ] First-pass Grasslands biome tileset (10–15 tiles minimum)
- [ ] First-pass enemy sprite (Grunt, all directions + animations)

### Story C4-S2: Style guide

- [ ] Create `/docs/style_guide.md`
- [ ] Define final palette per biome (10 biomes total — Concept locks Grasslands; others spec'd, produced in later phases)
- [ ] Lighting direction rules (day vs. night, exploration vs. Siege)
- [ ] Outline rules
- [ ] UI color tokens
- [ ] Animation guidelines (frame counts, animation principles)
- [ ] Sign-off from art director and design lead

### Story C4-S3: Audio direction

- [ ] Music director defines audio direction document
- [ ] Sample exploration track (Grasslands)
- [ ] Sample Siege track
- [ ] Sample boss track
- [ ] SFX style references (sword swings, ability casts, enemy deaths)
- [ ] Audio bus architecture documented

---

## Epic C5 — Hero Combat Prototype (Knight)

### Story C5-S1: Hero base scene

- [x] Create `Hero.tscn` scene (CharacterBody2D)
- [x] Implement 8-directional WASD movement  *(diagonal-normalized, velocity-lerped)*
- [x] Implement mouse-aim  *(drives sprite facing + attack pivot rotation)*
- [x] Hero sprite controller (idle, walk, attack, ability, death states)  *(plus block_start, block_mid, hurt — all data-driven via CharacterAnimationSet)*
- [x] HP and death handling  *(hp_changed signal, `die` animation, HurtBox + AttackHitbox disabled on death)*
- [x] Camera follow with subtle lookahead  *(smoothing speed 15, lookahead removed per playtest — felt floaty)*

### Story C5-S2: Knight basic attack

- [x] Sword swing with hitbox  *(Area2D on a rotating AttackPivot, windup 0.10s / active 0.18s / total 0.45s)*
- [ ] 4-frame motion blur arc visual  *(deferred — asset's built-in slash trail covers the swing for now)*
- [x] ~3-frame hit-stop on enemy connection  *(50ms Engine.time_scale dip)*
- [ ] Crunchy impact SFX (placeholder OK)  *(deferred — audio bundle CP8)*
- [x] Damage numbers popup  *(entities/damage_number.tscn, float-up + fade)*
- [x] Hit flash on enemies  *(red modulate on take_damage)*

### Story C5-S3: Knight Block/Parry ability

- [x] Hold-to-activate block stance (visual: shield raised, slight forward lean)  *(RMB hold, block_start anim at 60fps then block_mid loop)*
- [x] Block reduces incoming damage to 0 from front, 50% from sides, no protection from back  *(dot-product against aim direction)*
- [x] Parry window: 8 frames at start of block hold  *(widened to 12 frames / 0.20s per playtest)*
- [x] Successful parry: ~300ms slow-mo, bright VFX flash, distinctive sound stinger  *(slow-mo + flash done; SFX deferred to CP8)*
- [x] Parried enemies stagger for ~1.5 seconds (vulnerable, animation override)  *(via `attacker.on_parried(1.5)`)*
- [x] Block cooldown 0.35s after release  *(added during playtest — prevents spam)*

### Story C5-S4: Knight passive (Stalwart)

- [x] 15% damage reduction when below 50% HP
- [x] Visual indicator: subtle red aura when active  *(StalwartAura Sprite2D with radial gradient, toggles `visible`)*
- [x] Tested and confirmed working in combat scenarios  *(verified by taking damage from aggressive dummy until below 50)*

### Story C5-S5: Combat feel tuning pass

- [x] Playtest extensively with team  *(solo playtests; documented decisions in tuning doc)*
- [x] Tune movement weight, attack timing, parry window  *(move_speed 110→80, parry 0.13→0.20, block fps 30→60, camera smoothing 8→0→15, physics interpolation enabled)*
- [x] Validate against "feels heavy and certain" target from GDD section 10.4
- [x] Document tuning values in `/docs/balance/hero_knight.md`

---

## Epic C6 — Procedural Placement Prototype

### Story C6-S1: Biome generator

- [ ] Define hand-crafted Grasslands base map (using Grasslands tileset)  *(deferred — flat-green placeholder in use; tileset pass is next)*
- [x] Mark designer zones: where resource nodes can spawn, where enemy camps can spawn, where mini-boss spawns can spawn
- [x] Implement procedural placement algorithm (seeded random, biased toward biome rules)  *(biome_generator.gd — seeded rejection sampling)*
- [x] Spawn resource nodes (trees, berry bushes) within zones  *(trees, berry bushes, and gold deposits)*
- [x] Spawn enemy camps within zones with composition from BiomeData  *(camps spawn 2-6 goblins; headcount randomized, not yet BiomeData-driven)*
- [x] Spawn one mini-boss from biome pool at a designated spawn zone  *(placeholder — scaled-up goblin)*

### Story C6-S2: Run-vs-run variation

- [x] Verify same biome, different seeds, produces different layouts  *(G key reseeds; layout differs per seed)*
- [ ] Visual debug: highlight zones, show density heat map  *(zone-rect highlight done via V key; density heatmap not done)*
- [ ] Document seed system in `/docs/procgen.md`

### Story C6-S3: Resource node interaction

- [x] Player interacts with tree → 3-second harvest animation  *(hold E; berry forage 1.5s / gold mine 4s)*
- [x] Resource VFX bursts from node  *(splinter / berry / gold particle bursts)*
- [x] Resources arc to hero inventory  *(loot icons pop up from the node)*
- [x] Node respawns after configured time (or stays consumed, TBD per node type)  *(consumed — tree → stump, bush → empty, gold → removed)*
- [x] Inventory UI shows wood/food/gold counts  *(ResourceHUD)*

---

## Epic C7 — Waypoint Network Prototype

### Story C7-S1: Shrine entity

- [ ] Create `WaypointShrine.tscn`
- [ ] Inactive state visual
- [ ] Activated state visual (glowing, particles)
- [ ] Interaction prompt when hero nearby
- [ ] Activation requires defeating a small encounter (placeholder: a few Grunts)
- [ ] Activated Shrines persist in save data

### Story C7-S2: Travel UI

- [ ] World map screen accessible from anywhere except combat/Sieges
- [ ] Activated Shrines visible as travel destinations
- [ ] Select Shrine → fade out, fade in at destination
- [ ] No travel during combat (verify input gating)
- [ ] No travel during Sieges (verify input gating)

### Story C7-S3: Two-Shrine test

- [ ] Place castle Shrine (default activated)
- [ ] Place second Shrine in Grasslands with placeholder encounter
- [ ] Verify travel works both directions
- [ ] Verify no abuse vectors (e.g., dying and respawning at a Shrine to flee combat without consequences)

---

## Epic C8 — Castle Plot Prototype

### Story C8-S1: Castle scene

- [x] Create `Castle.tscn` with castle sprite, Shrine, build plot bounds  *(scenes/castle_plot.tscn — castle 4×4 placeholder rect, Shrine 1×1 placeholder, 30×30 buildable area)*
- [x] Define enemy approach lanes (path nodes from northern edge to castle)  *(3 spawn markers wired into ThreatLinePreview; full enemy AI pathing comes in C9)*
- [x] Define buildable tile grid within plot (30×30 tile area, configurable)  *(GridManager.grid_cols/rows exported)*
- [ ] Castle HP property and HP bar  *(deferred — Castle is placeholder StaticBody; HP system gets wired when C9 Siege content actually damages it)*

### Story C8-S2: Building placement system

- [x] Build menu UI (placeholder visual)  *(ui/build_menu.tscn — three buttons at bottom of screen)*
- [x] Click building in menu → ghost cursor follows mouse
- [x] Ghost shows green/red based on placement validity  *(green = can_place + can_afford, red otherwise)*
- [x] R-key rotates building (for non-square footprints)  *(swaps footprint X/Y; no-op visible for square footprints)*
- [x] Placement validation: bounded plot, no overlap with other buildings, no overlap with castle
- [x] Confirm placement: deduct resources, spawn building entity, start construction animation  *(resources deducted; construction animation deferred to Phase 2 polish)*
- [x] Cancel placement: ESC returns to no-placement state

### Story C8-S3: Three placeholder buildings

- [x] Farm (2×2, generates 5 food per day)  *(2×2 placed; daily food yield activates with day clock in Phase 2)*
- [x] Archer Tower (1×1, fires at enemies during Siege)  *(1×1 placed; auto-fire logic activates with C9)*
- [x] Wall Segment (1×1, 100 HP, cheap damage soaker)

### Story C8-S4: Threat line preview

- [x] When ghost is placed, trace a faint red line from each enemy spawn point through the ghost position to the castle
- [x] Line is only visible if the ghost intersects a direct path from a spawn to the castle
- [x] Multiple lines if multiple spawn points feed through the ghost
- [x] Line fades to invisible when ghost is moved off a threat path  *(highlighted vs faint instead of visible/invisible; clearer to keep all lines drawn faintly)*
- [x] Helps the player decide: damage-soaker placement vs. behind-defenses placement

---

## Epic C9 — Placeholder Siege Prototype

### Story C9-S1: Wave system

- [ ] Implement `WaveSpawner.gd`
- [ ] Reads `WaveData` resource
- [ ] Spawns enemies at northern edge spawn points on cadence
- [ ] Signals "wave complete" when all spawned enemies dead

### Story C9-S2: Enemy AI

- [ ] Enemy targets castle as its only objective
- [ ] Enemy moves in a direct path toward castle (no pathing around obstacles)
- [ ] Enemy engages any building directly in its path — attacks until destroyed, then continues
- [ ] Enemy does NOT seek off-path buildings (e.g., a Farm 5 tiles to the side is ignored unless directly in front)
- [ ] When a building in the path is destroyed, enemy immediately resumes path to castle (potentially exposing new buildings further along)
- [ ] Enemy attacks castle on arrival
- [ ] Enemy dies on sufficient damage, drops resources

### Story C9-S3: Tower AI

- [ ] Archer Tower detects enemies in range
- [ ] Auto-fires projectile at nearest enemy
- [ ] Damage and fire rate from TowerData

### Story C9-S4: End-to-end placeholder Siege

- [ ] Start in Castle scene with placeholder buildings placed
- [ ] Trigger Siege via debug key (real trigger comes later)
- [ ] Wave spawns
- [ ] Hero, walls, towers, recruits engage
- [ ] Wave clears or castle falls
- [ ] Outcome screen (placeholder)

---

## Epic C10 — Concept Retrospective

### Story C10-S1: Internal playtest

- [ ] Whole team plays the Concept prototype
- [ ] Combat feel review against GDD section 10.4
- [ ] Procedural placement review: does the same biome feel different across seeds?
- [ ] Waypoint review: does fast travel feel right (not abusable, not tedious)?
- [ ] Building placement review: does free-form placement feel good?
- [ ] Placeholder Siege review: is the core combat satisfying?

### Story C10-S2: Concept retrospective document

- [ ] Document what worked, what didn't, what surprised the team
- [ ] List specific GDD revisions needed
- [ ] Apply revisions to GDD (version bump to 1.1)

### Story C10-S3: Go/no-go decision

- [ ] Review against Concept Phase Exit Criteria (top of phase)
- [ ] CEO + Lead Designer + Lead Programmer sign off on proceeding
- [ ] Document the decision

---

# PHASE 2: VERTICAL SLICE

**Goal:** Two complete biomes (Grasslands+Village and Ocean), one fully realized hero class (Knight), one complete Siege (Siege I), end-to-end playable. Demonstrates the full game shape at small content scale.

## Vertical Slice Exit Criteria

- [ ] Grasslands (with Village sub-zone) and Ocean biomes fully implemented with art, music, enemies, resources
- [ ] Knight class fully complete (combat, ability, passive, sprite work)
- [ ] Castle plot with full building roster (placeholder art OK for non-essential)
- [ ] Days 1–7 fully playable (exploration + Siege I)
- [ ] Resource economy functional (wood, food, gold gathering and spending)
- [ ] At least 5 Knight Heirlooms implemented
- [ ] Waypoint network with 3+ Shrines across both biomes
- [ ] Procedural placement working in both biomes
- [ ] Siege I plays with full wave structure and Siege I Boss (name TBD)
- [ ] Save and resume working
- [ ] External playtest with 3–5 testers completed
- [ ] Vertical Slice retrospective documented

---

## Epic VS1 — Grasslands Biome Complete

### Story VS1-S1: Grasslands art

- [ ] Final Grasslands tileset (terrain, decorations, transitions)
- [ ] Grasslands ambient creatures (visual flavor — birds, butterflies)
- [ ] Grasslands resource node sprites (oak trees, berry bushes, gold deposits)
- [ ] Day/night lighting variants

### Story VS1-S2: Grasslands enemies

- [ ] Implement Wood Wolf (basic enemy, drops wood)
- [ ] Implement Bandit (humanoid enemy, drops gold)
- [ ] Implement Wild Boar (animal, drops food)
- [ ] Each with unique sprite, attack pattern, drop table
- [ ] Each passes silhouette test

### Story VS1-S3: Grasslands — no mini-boss

- [ ] Grasslands has no mini-boss at launch (per boss design: only Sewers, Mountain Depths, and Volcano have mini-bosses)
- [ ] Elite enemy variants (tougher Bandit, larger Wolf) exist as visual highlights but are not boss-tier
- [ ] Heirloom rewards in Grasslands come from quest completion, not mini-boss drops

### Story VS1-S4: Grasslands quest

- [ ] One representative quest: "Help the Farmer" — rescue NPC from bandit camp, returns to castle as a recruitable
- [ ] NPC dialogue system (text-based, mumble audio)
- [ ] Quest tracking UI

### Story VS1-S5: Grasslands waypoint shrines

- [ ] Castle Shrine (default)
- [ ] Eastern Crossroads Shrine
- [ ] Forest Edge Shrine (border with Old Forest)
- [ ] Each with activation encounter

### Story VS1-S6: Grasslands music

- [ ] Final Grasslands exploration track (day variant)
- [ ] Final Grasslands night variant (tense)
- [ ] Implemented and integrated with day/night cycle

---

## Epic VS2 — Village & Ocean Biomes Complete

The Village is the southern Grasslands meta-hub. The Ocean is the eastern coastal exploration zone. Both are starter-tier and ship with the vertical slice.

### Story VS2-S1: Village implementation

- [ ] Village tileset (cobblestone paths, half-timbered cottage exteriors, etc.)
- [ ] Place 4–6 functional buildings: Tavern, Blacksmith, Merchant tent, 2 Quest cottages, central well/shrine
- [ ] Place meta-hub buildings: Crown Court, Heirloom Vault, Bestiary (interior scenes for each)
- [ ] Place Sewer entrance (grate or stairwell descent point)
- [ ] Place permanent Village Waypoint Shrine
- [ ] Mark Village as a "safe zone" — no enemy spawn, no Siege targeting

### Story VS2-S2: Village NPCs

- [ ] Tavern keeper (handles Mercenary hire UI)
- [ ] Blacksmith (handles equipment upgrade UI)
- [ ] Merchant (handles consumable shop UI)
- [ ] 2 quest-giver NPCs with placeholder quest dialogue
- [ ] All NPCs use mumble audio (no VO)

### Story VS2-S3: Meta-hub interior scenes

- [ ] Crown Court interior with upgrade tracks UI
- [ ] Heirloom Vault interior with collection display
- [ ] Bestiary interior with enemy codex
- [ ] Each accessible from the Village exterior

### Story VS2-S4: Ocean biome art

- [ ] Ocean/beach tileset (sand, water transitions, palm trees, dock planks)
- [ ] Lighthouse structure (the iconic landmark)
- [ ] Dock market with stalls
- [ ] Pirate ship (optional encounter location)
- [ ] Distinct ocean/coastal lighting palette

### Story VS2-S5: Ocean enemies

- [ ] Implement Bandit Pirate (humanoid, drops gold)
- [ ] Implement Sea Crab (drops food)
- [ ] Implement Shark (water enemy, encountered near piers — drops mixed)

### Story VS2-S6: Ocean — no mini-boss

- [ ] Ocean has no mini-boss at launch (per boss design: only Sewers, Mountain Depths, and Volcano have mini-bosses)
- [ ] Elite enemy variants (tougher Bandit Pirate, larger Shark) exist as visual highlights but are not boss-tier
- [ ] Heirloom rewards in Ocean come from quest completion, not mini-boss drops

### Story VS2-S7: Ocean quest

- [ ] One representative quest: "The Lost Captain" — find missing dock worker, return for Heirloom reward

### Story VS2-S8: Ocean waypoint shrines

- [ ] Lighthouse Shrine
- [ ] Dock Market Shrine

### Story VS2-S9: Ocean music

- [ ] Final Ocean exploration track (day + night)
- [ ] Lighthouse ambient theme

---

## Epic VS3 — Knight Class Complete

### Story VS3-S1: Final Knight sprite work

- [ ] Final hero sprite sheet (idle, 8-direction walk, attack, block, parry, ability, death, cheer)
- [ ] Equipment overlay system (Heirlooms / weapons can modify visual)
- [ ] Cape ripple animation on run

### Story VS3-S2: Knight Heirlooms (5 for vertical slice, 20 total at launch)

- [ ] Common: Soldier's Resolve (+10% block strength)
- [ ] Common: Iron Constitution (+15% max HP)
- [ ] Common: Steady Stance (parry window +2 frames)
- [ ] Rare: Bulwark (block costs 0 stamina, no stamina drain when blocking)
- [ ] Epic: Unbreakable (cannot fall below 1 HP once per Siege)
- [ ] All wired to combat systems
- [ ] All testable in vertical slice runs

### Story VS3-S3: Knight feel polish pass

- [ ] Combat tuning against full enemy roster (Grasslands + Forest)
- [ ] Parry window feels rewarding but not trivial
- [ ] Block feels protective but committed
- [ ] Document final balance numbers in `/docs/balance/hero_knight.md`

---

## Epic VS4 — Full Castle System

### Story VS4-S1: All buildings implemented

- [ ] Farm (2×2)
- [ ] Lumber Mill (2×2)
- [ ] Market (2×2)
- [ ] Storehouse (2×1)
- [ ] Barracks (3×2)
- [ ] Mercenary Camp (2×2)
- [ ] Watchtower (1×1)
- [ ] Wall Segment (1×1)
- [ ] Gate (2×1)
- [ ] Archer Tower (1×1)
- [ ] Cannon Tower (2×2)
- [ ] Mage Tower (2×2)
- [ ] Forge (2×2)
- [ ] Mason's Workshop (Repair Building) (2×1)
- [ ] Heirloom Altar (2×2)
- [ ] All with placeholder-or-final art, costs balanced, function working

### Story VS4-S2: Resource economy

- [ ] Wood, food, gold counters in HUD
- [ ] Carrying capacity for hero (configurable)
- [ ] Stockpile caps tied to Storehouse count
- [ ] Building costs deducted correctly
- [ ] Building production cycles (daily yield)

### Story VS4-S3: Construction system

- [ ] Building placement → workers spawn → ~30 second construction animation → building functional
- [ ] Buildings non-functional during construction
- [ ] Construction can be canceled (refund partial)
- [ ] Builders are visual NPCs that walk to building sites

### Story VS4-S4: Repair system

- [ ] Mason's Workshop required for repair
- [ ] Click damaged structure → repair cost preview → confirm
- [ ] Repair cost scales with damage percentage (50% damaged = ~30% original cost)
- [ ] Cannot repair without Mason's Workshop built and operational
- [ ] **Batch "Repair All" button** — since multiple buildings will likely be damaged after a Siege, offer a one-click repair-everything-affordable option
- [ ] Repair All shows total cost preview before confirming
- [ ] Visual: damaged buildings have crack overlays scaling with damage percentage

### Story VS4-S5: Recruit and Mercenary systems

- [ ] Barracks trains 1 Recruit per day at base rate
- [ ] Recruit unit AI: auto-deploys during Sieges
- [ ] Recruit follows pathing toward enemies
- [ ] Three Recruit tiers as Barracks upgrades
- [ ] Mercenary Camp hire menu (during Day or Night phase)
- [ ] Mercenary types: Knight, Archer, Cleric
- [ ] Mercenaries vanish after Siege ends

---

## Epic VS5 — The 21-Day Calendar

### Story VS5-S1: Day/night cycle

- [ ] Implement `WorldClock.gd` autoload
- [ ] Day duration: configurable (default 5–7 real-time minutes)
- [ ] Night duration: configurable (default 2–3 real-time minutes)
- [ ] Lighting transitions smoothly day-to-night and night-to-day
- [ ] Music transitions cross-fade between day and night tracks
- [ ] Wandering enemies more active at night

### Story VS5-S2: Calendar progression

- [ ] Days 1–7 trigger correctly
- [ ] Day 7 dawn → Siege warning horn
- [ ] Day 7 dusk → Siege I begins
- [ ] (Days 8+ deferred to Content Production phase)

### Story VS5-S3: Siege warning system

- [ ] Visual UI: "SIEGE I — TONIGHT" persistent banner on Day 7
- [ ] Audio: distinct warning horn motif on Day 7 dawn
- [ ] Sky color shift toward red over the course of Day 7
- [ ] Ambient bird SFX stops mid-day on Day 7

---

## Epic VS6 — Siege I Implementation

### Story VS6-S1: Siege state machine

- [ ] Implement `SiegeManager.gd` autoload
- [ ] Siege phases: PreSiege (warning), WaveActive, BetweenWaves, BossWave, SiegeComplete, SiegeFailed
- [ ] Signal-based transitions
- [ ] Hooks for save/load state

### Story VS6-S2: Wave content

- [ ] Wave 1: 8 Grunts (Wood Wolves), single lane
- [ ] Wave 2: 12 mixed (Wolves + Bandits), two lanes
- [ ] Wave 3: 16 mixed + 2 elites
- [ ] Boss Wave: Siege I Boss + retinue of 6
- [ ] All as `WaveData.tres` resources, fully editable in inspector

### Story VS6-S3: Siege I Boss (name TBD)

- [ ] Boss name, visual identity, and sprite sheet — TBD during design phase
- [ ] Boss entity scene with 3 HP phases
- [ ] Phase 1: aggressive advance toward gate, single heavy attack
- [ ] Phase 2: summons retinue (3 additional Bandits), uses ground-slam telegraphed attack
- [ ] Phase 3: berserk, faster attacks, lower defense
- [ ] Visual telegraphs for all major attacks
- [ ] Boss music swaps in on boss arrival
- [ ] Drops guaranteed Rare-or-better Heirloom on defeat

### Story VS6-S4: Siege presentation

- [ ] Camera handling during Siege (focused on castle plot)
- [ ] Wave banner UI ("WAVE 1", "WAVE 2", etc.)
- [ ] Boss arrival cinematic moment (horn motif, camera pause, boss name banner — name TBD)
- [ ] Siege victory sequence
- [ ] Siege defeat sequence (castle fall, run end)

---

## Epic VS7 — Save System

### Story VS7-S1: Save architecture

- [ ] Implement `SaveManager.gd` autoload
- [ ] JSON-based save format with top-level `version: 1`
- [ ] Single active campaign save slot (`user://campaign.save`)
- [ ] Meta progression save separate (`user://meta.save`)
- [ ] Migration scaffolding: `_migrate_campaign_from(old_v, new_v)`

### Story VS7-S2: Campaign save data

- [ ] Current day
- [ ] Hero class, HP, position, inventory
- [ ] Castle HP, all building states, repair states
- [ ] All placed buildings with positions and HP
- [ ] All trained Recruits
- [ ] Active Heirlooms
- [ ] World state: visited Shrines, completed quests, killed mini-bosses, harvested nodes
- [ ] Active curses (Siege II onwards)

### Story VS7-S3: Save and resume flow

- [ ] Auto-save at end of every in-game day
- [ ] Manual save permitted only between Sieges
- [ ] Quit-to-menu offers save option
- [ ] Resume loads exactly where the player left off

---

## Epic VS8 — Vertical Slice Playtest

### Story VS8-S1: Internal playtest

- [ ] Whole team plays at least 5 vertical slice runs each
- [ ] Combat feel review
- [ ] Exploration loop review (does it engage?)
- [ ] Resource economy review (does it feel meaningful?)
- [ ] Siege I review (is it satisfying?)
- [ ] Compile feedback in `/docs/playtests/vertical_slice.md`

### Story VS8-S2: External playtest

- [ ] Recruit 3–5 external testers
- [ ] 30–45 minute sessions
- [ ] Silent observation where possible
- [ ] Post-session structured feedback

### Story VS8-S3: Vertical Slice retrospective

- [ ] Document findings against Vertical Slice Exit Criteria
- [ ] Identify scope adjustments needed for Content Production
- [ ] Update GDD if necessary
- [ ] CEO + Lead Designer + Lead Programmer sign-off on proceeding to Content Production

---

# PHASE 3: CONTENT PRODUCTION

**Goal:** Build out the full game. All biomes, all heroes, all Sieges, all Heirlooms, all curses, all bosses, all content. Quality bar held against vertical slice.

## Content Production Exit Criteria

- [ ] All 12 biomes complete (art, music, enemies, resources, shrines, quests)
- [ ] All 3 heroes complete (Knight, Rogue, Wizard) with full Heirloom pools
- [ ] All 3 Sieges with all 3 bosses complete
- [ ] All 24 curses implemented
- [ ] All 60 Heirlooms implemented (20 per class)
- [ ] All meta progression unlocks implemented
- [ ] Full quest content (5–8 quests per biome)
- [ ] Full enemy roster (Bestiary content complete)
- [ ] Audio first pass complete (all music tracks, full SFX library)
- [ ] Initial balance pass complete
- [ ] External playtest with 10+ testers completed

---

## Epic CP1 — Biomes (12 total, 10 remaining after VS)

The Vertical Slice ships with Grasslands+Village and Ocean. Content Production builds the remaining 10 biomes. The asset packs already exist for all of them — work focuses on integration, enemy/quest implementation, and tuning.

Biomes are grouped here by tier. Implement in tier order so each subsequent biome benefits from the systems and tuning of the previous tier.

### Story CP1-S1: Grassland Wilds (Tier 2, surface)

- [ ] Lime-green wilds tileset variant of Grasslands base
- [ ] Position immediately north of the Village
- [ ] 3 enemy types: Bandit, larger Wolf packs, Wild Boar groups
- [ ] No mini-boss (regular enemies + resource nodes + quest hooks only)
- [ ] 5–8 quests (starting from Village NPCs)
- [ ] 2 Waypoint Shrines
- [ ] Crypt entrance landmark (descent point, see CP1-S3)

### Story CP1-S2: Sewers (Tier 2, layer 2 / underground)

- [ ] Sewer tileset (dark stone, green toxic sludge, cobwebs, gates)
- [ ] Entrance in the Village (descent grate/stairwell)
- [ ] Self-contained dungeon — does NOT connect to other biomes
- [ ] 3 enemy types: Sewer Rat, Cave Spider, Sewer Goblin
- [ ] **1 mini-boss: Sewers Mini-Boss** (name and mechanics TBD; sprite sheet exists)
- [ ] Mini-boss likely mandatory (gates deep Sewer Shrine and/or major Heirloom)
- [ ] 3–5 quests
- [ ] 1 Waypoint Shrine (deep Sewers)
- [ ] Resource focus: rare urban-style gold caches, alchemical food drops

### Story CP1-S3: Crypt (Tier 3, layer 2 / underground transit network)

- [ ] Crypt tileset (teal-blue stone, candles, statues, potion shelves)
- [ ] Three surface entrances: Grassland Wilds, Cemetery, Ancient Ruins
- [ ] Acts as transit shortcut — player can enter any entrance, exit any other
- [ ] 3 enemy types: Skeleton Warrior, Crypt Spider, Animated Armor
- [ ] No mini-boss (regular enemies + transit utility + quest hooks)
- [ ] 5–8 quests
- [ ] 2 Waypoint Shrines
- [ ] Resource focus: ancient gold, magical food (preserved offerings), enchanted wood

### Story CP1-S4: Cemetery (Tier 3, surface, west)

- [ ] Cemetery tileset (moonlit purple/blue, gravestones, dead trees, gothic mausoleum)
- [ ] Position northwest of the Grassland Wilds
- [ ] 3 enemy types: Zombie, Skull-flower, Bat
- [ ] No mini-boss (regular enemies + atmospheric exploration + quest hooks)
- [ ] 5–8 quests
- [ ] 2 Waypoint Shrines
- [ ] One Crypt entrance landmark

### Story CP1-S5: Ancient Ruins (Tier 3, surface, east)

- [ ] Ancient Ruins tileset (overgrown stone walls, autumn trees, mossy ruins)
- [ ] Position northeast of the Grassland Wilds
- [ ] 3 enemy types: Stone Sentinel, Vine Wraith, Ruin Imp
- [ ] No mini-boss (regular enemies + atmospheric ruins + quest hooks)
- [ ] 5–8 quests
- [ ] 2 Waypoint Shrines
- [ ] One Crypt entrance landmark

### Story CP1-S6: Highlands (Tier 4, surface, west)

- [ ] Highlands tileset (snowy plateau, floating sky-islands, ice formations)
- [ ] Position north of the Cemetery
- [ ] 3 enemy types: Stone Golem, Frost Wolf, Sky Raider
- [ ] No mini-boss (regular enemies + sky-island exploration + quest hooks)
- [ ] 5–8 quests
- [ ] 2 Waypoint Shrines
- [ ] Sky-island traversal (jumps between platforms, optional vertical movement)

### Story CP1-S7: Desert (Tier 4, surface, east)

- [ ] Desert tileset (sand, palm oases, Egyptian-flavored ruins, stepped pyramids)
- [ ] Position north of the Ancient Ruins
- [ ] 3 enemy types: Desert Bandit, Mummy, Scarab Swarm
- [ ] No mini-boss (regular enemies + treasure-hunting POIs + quest hooks)
- [ ] 5–8 quests
- [ ] 2 Waypoint Shrines
- [ ] Treasure-hunting theme — more chests, more rare drops

### Story CP1-S8: Mountain Depths (Tier 5, surface peak + layer 2 interior)

- [ ] Dark grey mountain peak surface tileset
- [ ] Interior tileset (alchemist lab, dark hedge maze, ritual circles)
- [ ] Position north of the Highlands
- [ ] Surface and interior are connected — surface entrance opens to interior dungeon
- [ ] 3 enemy types: Goblin Warrior, Orc Brute, Cave Alchemist
- [ ] **1 mini-boss: Mountain Depths Mini-Boss** (name and mechanics TBD; sprite sheet exists)
- [ ] Mini-boss likely mandatory (gates interior descent or major Heirloom)
- [ ] 5–8 quests
- [ ] 2 Waypoint Shrines (one surface, one interior)

### Story CP1-S9: Ancient Dungeon (Tier 5, surface peak + layer 2 interior)

- [ ] Lavender peak surface tileset (the central-north mountain)
- [ ] Interior tileset (red blood-stained, torture chambers, skull gates)
- [ ] Position central-north, between Mountain Depths and Volcano
- [ ] Surface and interior connected
- [ ] 3 enemy types: Skeleton Mage, Bone Knight, Soul Wraith
- [ ] No mini-boss (regular enemies + atmosphere + gate to Volcano)
- [ ] 5–8 quests
- [ ] 2 Waypoint Shrines (one surface, one interior)
- [ ] Acts as the gate to the Volcano — must clear to access endgame

### Story CP1-S10: Volcano (Tier 6, endgame)

- [ ] Volcano tileset (lava flows, basalt rock, demon altars, hellscape)
- [ ] Position at the far north — endgame zone
- [ ] Only accessible after clearing Ancient Dungeon
- [ ] 3 enemy types: Imp, Lava Salamander, Demon Brute
- [ ] **1 mini-boss: Volcano Mini-Boss** (the chained skull demon from art reference — name and mechanics TBD)
- [ ] Mini-boss likely optional but high-value (drops endgame-tier Heirloom)
- [ ] 3–5 quests (more streamlined, fewer side activities — this is the endgame push)
- [ ] 2 Waypoint Shrines (one entry, one near Siege III boss arena)
- [ ] Note: The Siege III boss (the actual final boss of the campaign) is a separate, unique character — see Epic CP4. The Volcano biome contains a mini-boss for exploration only.

---

## Epic CP2 — Rogue Class Complete

### Story CP2-S1: Rogue art

- [ ] Final Rogue sprite sheet (idle, walk, attack, dash, death, etc.)
- [ ] Equipment overlay support

### Story CP2-S2: Rogue mechanics

- [ ] Dagger basic attack (fast 2-frame swing, 1-frame hit-stop, sharp metallic SFX)
- [ ] Dash ability (12-frame i-frame, directional, trail VFX)
- [ ] Opportunist passive (backstabs +50% damage, distinct VFX/SFX on proc)

### Story CP2-S3: Rogue Heirlooms (20 total)

- [ ] 10 Commons (movement/dash variants, stealth modifiers, small damage buffs)
- [ ] 7 Rares (synergy enablers — combo bonuses, stamina/cooldown reductions)
- [ ] 3 Epics (build-defining: e.g., "Dash damages enemies", "First hit each combat is automatic backstab")

### Story CP2-S4: Rogue unlock flow

- [ ] Beating Siege II unlocks Rogue
- [ ] Unlock notification UI
- [ ] Available in King Select screen (renamed: Hero Select)

---

## Epic CP3 — Wizard Class Complete

### Story CP3-S1: Wizard art

- [ ] Final Wizard sprite sheet
- [ ] Spell VFX library
- [ ] Equipment overlay support

### Story CP3-S2: Wizard mechanics

- [ ] Staff basic attack (ranged projectile, ~0.5s travel time, particle trail)
- [ ] Blink ability (instant short-range teleport, 4-tile range, no cooldown if mana sufficient)
- [ ] Arcane Recovery passive (mana regen + bonus mana on basic attack hit)
- [ ] Mana resource system (HUD bar, drain on Blink, drain on spell casts)

### Story CP3-S3: Wizard Heirlooms (20 total)

- [ ] 10 Commons (mana modifiers, basic spell variants, small buffs)
- [ ] 7 Rares (spell unlock Heirlooms — chain lightning, fireball, etc.)
- [ ] 3 Epics (build-defining: e.g., "Blink leaves a damaging trail", "All spells crit when mana full")

### Story CP3-S4: Wizard unlock flow

- [ ] Beating Siege III (winning a campaign) unlocks Wizard
- [ ] Unlock notification UI

---

## Epic CP4 — Sieges II and III

### Story CP4-S1: Siege II (name TBD)

- [ ] Wave definitions (5 waves + boss wave, escalating from Siege I)
- [ ] New enemy types active (variants pulled from biomes player has explored)
- [ ] Curse I applied before Siege starts (already chosen at end of Siege I)

### Story CP4-S2: Siege II Boss (name TBD)

- [ ] Boss name, visual identity, sprite sheet — TBD, decided during prototype design phase
- [ ] Boss entity, 3 phases (recommended pattern: aggressive entrance, mid-fight complication, desperation)
- [ ] Distinct ability set differentiated from Siege I boss (avoid feeling like the same fight harder)
- [ ] Visible telegraphs on all major attacks
- [ ] Phase transitions add new mechanics
- [ ] Distinct boss music
- [ ] Drops guaranteed Rare-or-better Heirloom
- [ ] Open design questions: see GDD section 6.4

### Story CP4-S3: Siege III (name TBD — final Siege)

- [ ] Wave definitions (final escalation)
- [ ] Both curses active
- [ ] Mixed enemy roster from across all biomes

### Story CP4-S4: Siege III Boss (name TBD — final campaign boss)

- [ ] Boss name, visual identity, sprite sheet — TBD, decided during prototype design phase
- [ ] This is a unique character, NOT the Volcano mini-boss (which is a separate exploration encounter)
- [ ] 4-phase boss fight (final boss complexity)
- [ ] Multiple attack types with clear telegraphs
- [ ] Adds spawn between phases
- [ ] Distinct final-boss music (highest production value of any track in the game)
- [ ] Drops guaranteed Epic Heirloom
- [ ] Open design questions: see GDD section 6.4

---

## Epic CP5 — Curse System

### Story CP5-S1: Curse engine

- [ ] Curse modifier system (apply to game state on Siege end)
- [ ] Stack handling: Curse I + Curse II + (optional) Curse III
- [ ] Modifiers applied dynamically (e.g., "Markets stop producing" disables Market output mid-campaign)

### Story CP5-S2: Curse draw UI

- [ ] After each Siege victory (except final), draw 3 random curses
- [ ] Cards display name, effect, art
- [ ] Player picks one; others discarded
- [ ] Picked curse persists in active campaign state

### Story CP5-S3: All 24 curses

- [ ] 6 Enemy curses
- [ ] 6 Economy curses
- [ ] 6 Defense curses
- [ ] 6 Hero curses
- [ ] Each defined as `CurseData.tres`
- [ ] Each playtested for correct effect application

---

## Epic CP6 — Meta Progression

### Story CP6-S1: Crown earning

- [ ] Calculate Crowns at campaign end (scaled by Sieges survived)
- [ ] Persist to meta save
- [ ] Display earnings on end-of-campaign screen

### Story CP6-S2: Crown Court UI

- [ ] Main menu entry "Crown Court"
- [ ] 10–12 meta upgrade tracks
- [ ] 3–5 tiers each
- [ ] Visual: tracks unlock with progress, costs visible

### Story CP6-S3: Meta upgrade content

- [ ] Starting resources (wood, food, gold)
- [ ] Starting castle HP
- [ ] Hero base HP
- [ ] Hero base damage
- [ ] Starting building unlocks (begin with free Watchtower, etc.)
- [ ] All as `MetaUpgradeData.tres`

### Story CP6-S4: Apply meta upgrades

- [ ] Campaign start applies all purchased meta upgrade effects
- [ ] Verified in all 3 hero playthroughs

---

## Epic CP7 — Discovery Systems

### Story CP7-S1: Unlock tracking

- [ ] Generic condition system tracking player actions
- [ ] Conditions for hero unlocks (Siege II, Siege III)
- [ ] Conditions for Heirloom Vault entries (any Heirloom picked up unlocks Vault entry)
- [ ] Conditions for Bestiary (any enemy encountered)
- [ ] Conditions for cosmetics

### Story CP7-S2: Heirloom Vault UI

- [ ] Filter by class, rarity, source
- [ ] Silhouetted entries for undiscovered
- [ ] Full card for discovered (effect, lore, source)
- [ ] Progress counter

### Story CP7-S3: Bestiary UI

- [ ] All enemy entries
- [ ] Silhouetted if undiscovered
- [ ] Stats, lore, weaknesses on discovered entries

### Story CP7-S4: Quest log

- [ ] Active quests in-campaign
- [ ] Completed quests archive
- [ ] Quest history in main menu (cross-campaign)

---

## Epic CP8 — Audio Production

### Story CP8-S1: Music tracks (commission or compose)

- [ ] 10 biome exploration themes (day variants)
- [ ] 10 biome night variants
- [ ] Castle day theme
- [ ] Castle Siege theme
- [ ] 3 boss themes (one per Siege)
- [ ] Curse selection theme
- [ ] Menu theme
- [ ] Victory and defeat stingers

### Story CP8-S2: SFX library

- [ ] Hero combat SFX (per class — basic attack, ability, hit, death)
- [ ] All enemy SFX (attack, hit, death, ambient)
- [ ] All building construction completion SFX
- [ ] All resource gather SFX
- [ ] All UI SFX (click, hover, confirm, cancel)
- [ ] Environmental SFX (wind, weather, ambient creature)
- [ ] Horn motif variants (dawn warning, dusk Siege, boss arrival, victory)

### Story CP8-S3: Audio integration

- [ ] All music wired to game states
- [ ] All SFX wired to game events
- [ ] Audio bus mixing balanced
- [ ] Volume sliders functional in settings

---

## Epic CP9 — Initial Balance Pass

### Story CP9-S1: Resource economy balance

- [ ] Gather rates per biome tuned
- [ ] Building costs balanced against expected resource flow
- [ ] Stockpile caps tuned
- [ ] Hero carry capacity tuned

### Story CP9-S2: Hero balance

- [ ] All 3 heroes viable for full Campaign completion
- [ ] No single Heirloom dominates
- [ ] Each class has multiple build paths

### Story CP9-S3: Curse balance

- [ ] Every curse pickable with reasonable run viability
- [ ] No curse trivially better/worse than others in same category
- [ ] Stacked curses scale challenge appropriately

### Story CP9-S4: Siege difficulty

- [ ] Siege I beatable by new players with placeholder hero
- [ ] Siege II beatable by mid-skill players with some Heirloom collection
- [ ] Siege III beatable by skilled players with full Heirloom variety
- [ ] All values documented in `/docs/balance/`

---

## Epic CP10 — Mid-Production Playtest

### Story CP10-S1: External playtest

- [ ] Recruit 10+ external testers
- [ ] Full Campaign playthroughs across all 3 classes
- [ ] Structured feedback collected

### Story CP10-S2: Feel review

- [ ] Team plays against full content
- [ ] Compare experience to GDD section 10 targets
- [ ] Log gaps in `/docs/feel_gaps.md`
- [ ] Triage gaps: must-fix-for-launch vs. post-launch acceptable

---

# PHASE 4: POLISH, BALANCE & LAUNCH PREP

**Goal:** Get the game shippable. Fix bugs. Final balance. Audio polish. Marketing materials. Launch.

## Polish Phase Exit Criteria

- [ ] All P0/P1 bugs resolved
- [ ] All gameplay loops feel polished against GDD section 10 targets
- [ ] Steam store page complete (screenshots, trailers, description)
- [ ] Achievements implemented (target: ~30 achievements)
- [ ] Steam Cloud sync verified
- [ ] Build pipeline produces clean signed builds for Windows, Mac, Linux
- [ ] Launch trailer complete
- [ ] Press kit ready
- [ ] Launch date set

---

## Epic P1 — Bug Fix Pass

### Story P1-S1: Critical bug fixes

- [ ] Triage all open bugs into P0/P1/P2/P3
- [ ] Fix all P0 (crash, save corruption, progress loss)
- [ ] Fix all P1 (gameplay-breaking but recoverable)
- [ ] Document P2/P3 deferred to post-launch

### Story P1-S2: Edge case coverage

- [ ] Test save/load at all critical points
- [ ] Test ungraceful exit (alt-F4, force quit, power loss simulation)
- [ ] Test extreme play styles (no walls, max walls, all Mercenary, etc.)
- [ ] Test min-spec hardware

---

## Epic P2 — Final Balance

### Story P2-S1: Balance pass against playtest data

- [ ] Apply changes from CP10-S1 feedback
- [ ] Re-validate with internal playtests
- [ ] Lock balance values

### Story P2-S2: Difficulty validation

- [ ] New player tested through full campaign
- [ ] Veteran player tested with max curses
- [ ] Document balance numbers as final in `/docs/balance/`

---

## Epic P3 — Steam Launch Prep

### Story P3-S1: Steam page

- [ ] Steam Direct application submitted
- [ ] Store page: description, screenshots (10+), banner art
- [ ] Tags applied (Rogue-lite, Action, Strategy, Base Building, etc.)
- [ ] Genre and feature lists
- [ ] Pricing locked

### Story P3-S2: Achievements

- [ ] Design ~30 achievements
- [ ] Implement via Steamworks
- [ ] Test trigger reliability
- [ ] Localize achievement text (if multi-language)

### Story P3-S3: Steam features

- [ ] Steam Cloud sync verified
- [ ] Steam Workshop hooks stubbed (workshop integration post-launch)
- [ ] Controller config tested
- [ ] Big Picture mode tested

### Story P3-S4: Build pipeline

- [ ] Signed Windows build
- [ ] Signed Mac build (notarized for macOS)
- [ ] Linux build
- [ ] All upload to Steam beta branches for QA
- [ ] Final production builds tagged

---

## Epic P4 — Marketing

### Story P4-S1: Launch trailer

- [ ] Script and storyboard
- [ ] Record gameplay capture
- [ ] Editing and music
- [ ] Trailer published

### Story P4-S2: Press kit

- [ ] Game description
- [ ] Screenshots (high-res)
- [ ] GIFs of key gameplay moments
- [ ] Studio info
- [ ] Press contact
- [ ] Hosted at presskit() or equivalent

### Story P4-S3: Steam Next Fest (if available)

- [ ] Apply for nearest Steam Next Fest
- [ ] Prepare playable demo (limited content slice)
- [ ] Demo Steam page

### Story P4-S4: Community channels

- [ ] Steam community page configured
- [ ] Discord server (optional but recommended)
- [ ] Social media presence (Twitter/Bluesky/etc.)

---

## Epic P5 — Launch

### Story P5-S1: Final QA pass

- [ ] Full game playthrough on all 3 classes
- [ ] All 3 platforms tested
- [ ] All 30 achievements unlock correctly
- [ ] Save/load tested across version updates

### Story P5-S2: Launch day

- [ ] Build deployed to Steam
- [ ] Store page goes live
- [ ] Launch trailer goes live
- [ ] Press notified
- [ ] Community channels activated

### Story P5-S3: Day-one support

- [ ] Hotfix branch ready
- [ ] Monitor crash reports
- [ ] Respond to community feedback
- [ ] Post-launch retrospective scheduled (1 week post-launch)

---

## Top Risks Across All Phases

1. **6-month timeline is aggressive for the scope.** Team must scale fast and stay focused. Any major scope add pushes ship.

2. **Hero combat feel across three classes.** Three combat systems must each feel distinct and satisfying. Prototype Knight in Concept (done by C5), then port the proven architecture to Rogue and Wizard.

3. **Procedural placement tuning.** Hand-crafted base + procedural elements requires playtest iteration. Build the prototype early (C6), iterate continuously.

4. **Exploration loop engagement.** ~75 minutes of exploration per playthrough must stay engaging. Discovery density (Heirlooms, quests, codex entries) is the lever.

5. **Curse balance complexity.** 24 curses × 2-curse stacks = 276 unique stack combinations. Cannot perfectly balance all of them. Target "all viable, some harder than others" — not perfect parity.

6. **Audio production timeline.** Music and SFX cannot start at Polish phase. Audio must run alongside Content Production (Phase 3).

7. **Save versioning.** Implement migration scaffolding in vertical slice (VS7-S1). Do not defer.

---

## Open Questions (Resolve Before Concept Begins)

- [ ] Who's on the team? Final role assignments documented?
- [ ] Task tracker selection?
- [ ] Music: in-house, contractor, or licensed library?
- [ ] Voice acting: confirmed none for launch, NPCs use mumble audio?
- [ ] Localization: launch English-only, or multi-language at launch?
- [ ] Steam Direct fee paid and account set up?

---

*End of plan. Revisions live here. Scope changes require explicit decision log entry in `/docs/decisions.md`.*
