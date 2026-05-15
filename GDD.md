# Crown & Wall — Game Design Document

**Version:** 1.0 (new vision, replaces v0.2 entirely)
**Status:** Living document. Expect changes during prototype.
**Working title.** Final name TBD.

---

## 1. Overview

### 1.1 One-Sentence Pitch

A single-player action-strategy game where you rule a kingdom under siege — explore a vast map as your hero, gather resources, build defenses, and survive three escalating Sieges that you choose how to handicap yourself for.

### 1.2 Longer Pitch

*Crown & Wall* is a 2-hour action-strategy game built around a 21-day calendar. The player controls a heroic ruler (Knight, Rogue, or Wizard) defending a castle in the grasslands of a much larger map. Between three scheduled Sieges, the player explores hand-crafted biomes radiating north from their home — gathering wood, food, and gold; defeating bosses for run-altering Heirlooms; and hauling everything back to the castle to build defenses, train armies, and hire mercenaries.

The map is structured but the player's path is free. There is no "begin Siege" button — Sieges arrive on the calendar whether the player is ready or not. The hero can be deep in a crypt when the warning horn sounds, forcing a real strategic choice: race home, or commit to the dungeon and accept that the castle will face the first wave understaffed.

Each Siege ends with a choice: pick a curse. Enemies grow stronger, or your markets stop producing gold, or your walls take double damage. The player chooses how the game escalates. This curse system is the primary difficulty layer, layered on top of natural enemy escalation.

A full playthrough is ~2 hours. Victory means surviving all three Sieges. Defeat means the castle falls. Either way, meta progression — Heirloom Vault, Bestiary, hero unlocks, cosmetics — pulls the player back for the next run.

### 1.3 Target Feel

**Three words: Explore. Prepare. Endure.**

The player should finish a winning campaign feeling three things simultaneously:

- **Triumphant** — they survived three Sieges while curses stacked against them.
- **Resourceful** — their exploration choices, build order, and resource trade-offs got them through.
- **Embodied** — as the hero, they personally adventured for the relics that won the run.

The game uses different parts of the brain at different scales:
- **Macro** (days/weeks): "Where do I explore next? What do I build? Which curse do I pick?"
- **Micro** (seconds): "Dash through this enemy, block the parry-able attack, position to backstab."

### 1.4 Reference Games

- **9 Kings** — base-building defense, escalating curse/decree system, castle-as-anchor.
- **Don't Starve** — constrained exploration loop, return-to-base rhythm, day/night structure (without the open-ended sandbox feel).
- **Hades** — hero classes with distinct movement mechanics, Boon-style relic acquisition from boss rewards.
- **Hollow Knight** — waypoint-based fast travel system.
- **Bellwright** / **Kingdoms and Castles** — open-area castle building with structures placed freely on terrain.
- **Slay the Spire** — discovery-driven Heirloom unlocks as long-tail retention.

### 1.5 Target Platform & Business

- **Primary launch platform:** Steam (Windows, Mac, Linux).
- **Secondary platform:** TBD post-launch. Co-op multiplayer is flagged as a potential post-launch direction.
- **Business model:** Premium. Target ~$20.
- **No ads, no IAP, no gacha, no battle pass, no global chat.**
- **Cosmetics:** earnable only.
- **Modding:** local mod folder support at launch, Steam Workshop integration as post-launch enhancement.

### 1.6 Team & Approach

- Team sized to scope. Full art, full audio, dedicated design, dedicated production.
- 6-month target to ship.
- Approach is **phase-based with calendar awareness** — phases must complete before next phase begins, but with the 6-month target driving aggressive parallelism and scope discipline.

---

## 2. World Structure

### 2.1 The Map

The world is a **hand-crafted map** of 12 biome tilesets arranged in a two-layer structure: surface biomes radiating outward from the castle, plus underground biomes that sit beneath specific surface zones.

The castle sits at the southern edge of the mainland. From there, the player can travel north, northeast (east coast), or northwest (sewer entrance in the Village). Difficulty escalates outward from the castle in all directions, with the Volcano as the final endgame zone at the far north of the map.

**Tile system:** all tiles are 32×32 pixels. Buildings occupy footprints in tile units (2×1, 2×2, 3×2, etc.).

**Surface map layout:**

```
                              [VOLCANO]                       ← endgame
                                  ↑
                ┌─────────────────┼─────────────────┐
                ↑                 ↑                 ↑
       [MOUNTAIN DEPTHS]   [ANCIENT DUNGEON]      [DESERT]
         (surface peak,       (surface peak,        (east)
          dark grey)           lavender)
                ↑                 ↑                 ↑
                ↑                 ↑                 ↑
          [HIGHLANDS]                          (east approach)
            (white)                                  ↑
                ↑                                    ↑
          [CEMETERY]                           [ANCIENT RUINS]
            (grey, west)                         (purple, east)
                ↑                                    ↑
                └────────[CRYPT — layer 2]───────────┘
                              connects underground
                              to Grasslands too
                                  ↑
                                  ↑
                      [GRASSLAND WILDS]              ← mini-bosses,
                          (lime green)                  Crypt entrance
                                  ↑
                                  ↑
                      [GRASSLANDS + VILLAGE]         ← Village POI,
                          (dark green)                  Sewers entrance
                                  ↑
                                  ↑
                          [CASTLE PLOT]              ← player's
                       (south edge, open)              fortress
                                  →
                                  → [BEACH] → [OCEAN BIOME]
                                                (lighthouse,
                                                 docks, pirate ship —
                                                 east coast)
```

**Layer 2 — underground biomes (sit beneath the surface map):**

- **Sewers** — entrance in the Village. Subterranean tunnel network beneath the southern Grasslands.
- **Crypt** — three surface entrances (one in the Grassland Wilds, one in the Cemetery, one in the Ancient Ruins). Acts as a **transit network** connecting these three biomes underground.
- **Mountain Depths** — interior of the dark grey peak. Surface entrance leads down into the alchemist lab, mummified king mini-boss, orc and goblin warrens.
- **Ancient Dungeon** — interior of the lavender peak. Surface entrance leads down into the red blood-stained dungeon with skeleton mages. The final fortress before the Volcano.

### 2.2 Biome Roles & Difficulty Tiers

**TIER 0 — Home (castle region):**

- **Castle Plot.** Player's fortress. Open buildable terrain. Castle at center, beach to the east, Sewers entrance to the north (in the Village), Grasslands open to the north. The only buildable space in the game.

**TIER 1 — Starter zones:**

- **Ocean / Beach.** East of the castle. The lighthouse, dock market, pirate ship, sandy beach. Coastal exploration. Friendly, naval-tinged enemies (pirates, sea monsters). Low danger. NPCs at the docks.
- **Grasslands.** North of the castle. Contains the **Village** as its southern sub-zone. Friendly biome with Wood Wolves, Bandits, Wild Boars at the wilder edges. The first real exploration biome.

**TIER 2 — Early exploration:**

- **Grassland Wilds.** Northern Grasslands. Harder enemies (Bandit Captain mini-boss, Alpha Wolf mini-boss). Crypt entrance is here.
- **Sewers (layer 2).** Entrance in the Village. Spider lair, toxic sludge, urban tunnel network. Optional dungeon route. Side rewards. Doesn't connect to other biomes — it's a self-contained Village-area dungeon.

**TIER 3 — Mid-tier exploration:**

- **Cemetery.** Northwest of Grassland Wilds. Above-ground graveyard with zombies, gothic mausoleum. Crypt entrance here too.
- **Ancient Ruins.** Northeast of Grassland Wilds. Overgrown stone walls, cherry blossom shrine with guardian statues, waterfall with moose-totem mini-bosses. Crypt entrance here too.
- **Crypt (layer 2).** Mid-tier dungeon. The **transit network** connecting the Grassland Wilds, Cemetery, and Ancient Ruins underground. Enter from any of the three surface entrances, exit at any of the others. Major exploration shortcut.

**TIER 4 — Late exploration:**

- **Highlands.** West, north of Cemetery. Snowy plateau with floating sky-islands, stone golems, viking-style ruins, runed ice crystals. Mystical-northern tone.
- **Desert.** East, north of Ancient Ruins. Egyptian-flavored ruins with Anubis statues, oasis tents, stepped pyramids. Treasure-hunting feel.

**TIER 5 — Endgame approach:**

- **Mountain Depths (surface peak + layer 2 interior).** Northwest peak. Interior contains alchemist labs, the mummified king mini-boss, orc/goblin warrens.
- **Ancient Dungeon (surface peak + layer 2 interior).** Central-north peak. Interior is the red blood-stained dungeon with skeleton mages and torture chambers. The gate to the Volcano.

**TIER 6 — Endgame:**

- **Volcano.** Far north. Demon-king final boss, lava castle wall, demon imps and demon mini-bosses. Convergence point — all paths lead here.

### 2.3 Three Viable Progression Routes

The map is designed so the player has **three distinct progression routes** that all converge at the Volcano:

1. **West route:** Castle → Grasslands → Cemetery → Highlands → Mountain Depths → Volcano. Cold, undead, mystical-northern flavor.
2. **East route:** Castle → Grasslands → Ancient Ruins → Desert → (Ancient Dungeon) → Volcano. Hot, ancient-civilization, treasure flavor.
3. **Central route via Crypt:** Castle → Grasslands → Grassland Wilds → Crypt → exit at Cemetery or Ancient Ruins → continue north. Underground shortcut that lets the player reach Tier 3+ biomes faster but with more dungeon-style combat.

Different hero classes naturally favor different routes (Knight tanks the dungeon-heavy central path; Rogue thrives in fast Highlands/Ancient Ruins exploration; Wizard's ranged combat suits open Desert and Volcano). This is by design — replayability emerges from class-route synergies.

### 2.4 The Village

The Village sits in the southern Grasslands, a short walk north of the castle plot. It is **safe territory** — never attacked, never targeted by Sieges, always accessible.

**Buildings in the Village (4–6 functional structures):**

- **Tavern** — Mercenary hire (in-person, more atmospheric than a Mercenary Camp), drink NPCs for flavor.
- **Blacksmith** — weapon and armor upgrades, equipment crafting.
- **Merchant tent** — consumables, rare resources, situational items.
- **Quest cottages** — 2–3 NPCs who hand out quests.
- **Central well or shrine** — visual anchor, possibly a Waypoint Shrine location.
- **Sewer entrance** — descent point to the Sewers (layer 2).

**Meta-progression hubs as physical buildings in the Village:**

- **Crown Court** — spend Crowns on permanent upgrades.
- **Heirloom Vault** — view discovered Heirlooms.
- **Bestiary** — view enemy codex.

Each is a physical building the player enters, with a **menu shortcut** from the main menu for fast access. Best of both worlds: atmospheric exploration *or* quick UI access.

**Village rules:**

- **Never attacked by enemies.** Not during Sieges, not at night, not ever.
- **Never destroyed.** Village buildings are persistent across Campaigns.
- **No build/demolish.** Player cannot place or destroy buildings in the Village.
- **Always accessible.** Village is a safe space the player can retreat to.

### 2.5 The Castle Plot vs. The Village — Spatial Separation

These are **two distinct spaces** with a meaningful walk between them.

**Castle Plot:**
- 100% player-controlled.
- Pre-placed structures only: the castle itself, the castle Waypoint Shrine.
- Free-form building placement.
- **Targeted by Siege enemies.**

**Village:**
- 100% non-player-controlled.
- All buildings pre-placed.
- Pure social/services hub.
- **Never targeted by Siege enemies.**

**Spatial relationship:**
- Castle Plot is south, at the edge of the mainland.
- Village is in the southern Grasslands, immediately north of the Castle Plot.
- A short path (~30–60 seconds of walking) separates them.
- A Waypoint Shrine in the Village allows fast travel back to it from anywhere.

This separation preserves:
- The "you are the last bastion" feeling during Sieges — the castle stands alone, no villagers to confuse the player.
- The free-form building mechanic — no pre-placed Village buildings competing for tile space.
- The "lived-in world" feeling — the Village gives the player NPCs, shops, and a friendly destination to visit.

### 2.6 The Waypoint System

The player establishes **Waypoint Shrines** while exploring. Each Shrine is a fast-travel anchor.

**Mechanics:**
- Castle has a permanent Waypoint Shrine.
- Village has a permanent Waypoint Shrine (always available).
- Each other biome contains 1–2 discoverable Shrine locations.
- Player activates a Shrine by clearing a small encounter at its location (combat + ritual interaction).
- Once activated, the player can fast-travel between any two activated Shrines via the world map screen.
- **Fast travel is only available from "safe" locations** — not during combat, not while being chased, not during Sieges.
- This solves the "jog back vs teleport abuse" problem cleanly: travel is convenient but not exploitable.

**Travel time:**

- Fast travel between Shrines: instantaneous.
- Walking between regions without Shrines: takes in-game time (minutes during day/night cycle ticks).

**Exploration target:** approximately 50% of each visited biome per playthrough. Procedural placement (resource nodes, enemy camps, mini-boss spawns) ensures replay variety even on a hand-crafted base map.

**Travel time:**
- Fast travel between Shrines: instantaneous.
- Walking between regions without Shrines: takes in-game time (minutes during day/night cycle ticks).

### 2.7 Day/Night Cycle and the Calendar

**Day/night cycle:** runs continuously during exploration. Day phase ~5–7 real-time minutes, night phase ~2–3 real-time minutes per in-game day.

**Daytime:** safe exploration. Resource nodes harvestable. Most enemies are in their camps; combat happens at the player's initiative.

**Nighttime:** dangerous. Wandering predators spawn outside camps. Wild biome bosses become active. The player is encouraged to return home or to a Shrine. The castle is still mostly safe at night between Sieges, but a small number of enemies may probe defenses (test damage on walls, but rarely break through).

**The 21-Day Calendar (the master clock):**

| Day | Phase | What Happens |
|---|---|---|
| 1–6 | Free Exploration | No Siege. Player explores, gathers, builds, trains, levels up. |
| **7 (Night)** | **SIEGE I** | First Siege begins at nightfall. Wave-based assault on the castle. |
| 8 | Pick Curse | Player chooses 1 of 3 curses from a tarot-card style draw. Curse persists for remaining campaign. |
| 8–13 | Free Exploration | Second exploration window. New biomes unlocked by player progress. |
| **14 (Night)** | **SIEGE II** | Second Siege. Larger, more varied, with Siege I's curse layered. |
| 15 | Pick Curse | Second curse stacked on top of first. |
| 15–20 | Free Exploration | Final prep. |
| **21 (Night)** | **SIEGE III** | Final Siege. Final boss. Two curses active. |

**A full playthrough is 21 in-game days = ~2 hours real-time.**

**Sieges arrive on the calendar regardless of player readiness.** Warning horn sounds in-world at Day 7 dawn, Day 14 dawn, Day 21 dawn. Player can be anywhere on the map. If they're far from home when night falls, the castle defends without them for the opening waves.

### 2.8 Castle Plot — Mechanical Details

The Castle Plot is the only buildable space in the game. It sits at the southern edge of the mainland, bounded by ocean to the south and east, the Sewers' surface entrance area to the northwest, and the open Grasslands path to the north.

**Plot dimensions:**
- Approximately 30×30 tiles (refine in prototype based on playtest).
- Bounded — not infinite. The bounds force layout decisions.

**Fixed pre-placed structures:**
- The castle itself (central, target of all Siege enemies).
- The Castle Waypoint Shrine (fixed, near castle, always activated).

**Player-controlled space:**
- All other tiles within the plot are open grass, freely buildable.
- Walls, towers, buildings (Farms, Markets, Barracks, etc.) all placed via the building system (see section 4.2).

**Enemy approach lanes:**
- Predefined spawn points at the northern edge of the plot (forest edge).
- Enemies during Sieges spawn here and path straight south toward the castle.
- The player's building layout determines what enemies hit on the way.

**Castle Plot is its own zone, not part of the Grasslands biome.** The player exits the Castle Plot northward to enter the Grasslands (and the Village). Walking back to the Castle Plot is always possible via the Castle Waypoint Shrine.

---

## 3. Heroes

### 3.1 The Three Classes

| Class | Unlock | Movement Ability | Passive | Combat Style |
|---|---|---|---|---|
| **Knight** | Starter | **Block / Parry** — directional block negates damage; perfect-timed parry staggers attacker | **Stalwart** — 15% damage reduction below 50% HP | Melee, sword and shield, tanky |
| **Rogue** | Beat Siege II | **Dash** — short i-frame dash with directional control | **Opportunist** — backstabs deal +50% damage | Melee, daggers, mobile, positioning |
| **Wizard** | Beat Siege III | **Blink** — short-range teleport through walls and enemies | **Arcane Recovery** — mana regenerates passively; basic attacks restore additional mana | Ranged, staff, mana-based spells |

**Class-locked per run.** The player picks their class at the start of a campaign. They cannot swap mid-run.

**Power expression scales differently per class:**
- Knight is durable from run start, scales linearly with gear and Heirlooms.
- Rogue is fragile early, scales explosively with mobility-based Heirlooms.
- Wizard is the steepest learning curve, highest skill ceiling.

### 3.2 Hero Combat Feel

Hero combat is real-time, top-down action. The hero is always the player's avatar — they directly control movement, attack, ability, and interaction.

**Common to all classes:**
- HP pool separate from castle HP.
- Hero death does not end the run; respawn at last Waypoint Shrine after ~10-second delay.
- Basic attack with weapon-class feel (heavy melee, fast melee, ranged staff).
- One active ability on cooldown (the class movement ability).
- One class-defining passive.

**Movement:**
- Top-down omni-directional.
- WASD keyboard, mouse aim.
- Controller support a launch requirement.

**Hero feel design rules:**
- **Knight feels heavy and certain.** Movements have weight. Block-active stance is committed. Parry windows are tight (8 frames at 60fps).
- **Rogue feels light and aggressive.** Movement is faster than knight. Dash i-frames feel generous (12 frames). Punish behind-the-back positioning.
- **Wizard feels precise and tactical.** Slower base movement. Blink is short-range (4 tiles) but no cooldown when mana available. Mana is the resource the wizard manages.

### 3.3 Hero Progression Within a Run

Heroes do not level up. Their power growth within a single playthrough comes from:

- **Heirlooms** acquired from bosses, mini-bosses, and quests (see section 5).
- **Equipment** crafted from gathered resources at the castle Forge.
- **Consumables** crafted or found (potions, scrolls, buffs).
- **Trained allies** (Recruits + Mercenaries — see section 4).

This is a deliberate Hades-style design: power comes from *choices*, not *grind*.

### 3.4 Hero Cross-Run Meta

Across runs, the player permanently unlocks:
- New hero classes (Rogue at Siege II clear, Wizard at Siege III clear).
- Heirlooms in the Vault.
- Enemy Codex entries.
- Cosmetic crowns, weapon skins.
- Meta upgrades purchased with Crowns currency (see section 8).

---

## 4. Resources, Buildings, and Units

### 4.1 The Three Resources

| Resource | Sources | Used For |
|---|---|---|
| **Wood** | Wood Monsters (forest enemies), Trees (harvestable nodes), Wood Stockpiles in camps | Buildings, walls, towers, tools, basic weapons |
| **Food** | Beast Monsters, Animal Bosses, Crops (Farm output), Foraged Berries | Training Recruits, hero consumables, settlement upkeep |
| **Gold** | Monster Bosses, Crypts, Caves, Markets (Market output), enemy drops | Hiring Mercenaries, advanced weapons, repair, upgrades |

**Resource cap:** the player has a shared Stockpile at the castle. Exploration loot must be hauled back (or fast-traveled back via Shrine) to deposit. Stockpiles have soft caps (e.g., max 999 wood) — players can't hoard infinitely.

**Resource decay:** none. Resources persist. Carrying capacity on the hero is the limit — they can carry, say, 50 wood at once, forcing trips back to base.

### 4.2 Buildings

Buildings have **variable tile footprints**. Building placement is free-form within the castle plot. Player drags-and-rotates the building ghost until satisfied, then commits.

**Building categories at launch:**

**Resource buildings:**

| Building | Footprint | Cost | Function |
|---|---|---|---|
| **Farm** | 2×2 | 30 wood | Produces 5 food per day. |
| **Lumber Mill** | 2×2 | 50 wood | Produces 4 wood per day (works on stored logs from your stockpile). |
| **Market** | 2×2 | 40 wood + 20 gold | Produces 3 gold per day. Multiplies coin gains. |
| **Storehouse** | 2×1 | 20 wood | Increases resource caps. |

**Military buildings:**

| Building | Footprint | Cost | Function |
|---|---|---|---|
| **Barracks** | 3×2 | 60 wood + 30 food | Trains 1 Recruit per day, costs food per training. |
| **Mercenary Camp** | 2×2 | 50 wood + 50 gold | Allows hero to hire Mercenaries on demand during Sieges, paid in gold. |
| **Watchtower** | 1×1 | 30 wood | Reveals incoming enemy waves before Siege starts. Required for advanced base intelligence. |

**Defense buildings:**

| Building | Footprint | Cost | Function |
|---|---|---|---|
| **Wall Segment** | 1×1 | 10 wood | Cheap dedicated damage soaker. 100 HP. The intended sacrificial layer. |
| **Gate** | 2×1 | 20 wood | Passable for friendlies, blocks enemies. 150 HP. |
| **Archer Tower** | 1×1 | 30 wood | Auto-fires at enemies in range. |
| **Cannon Tower** | 2×2 | 80 wood + 40 gold | AoE damage tower. |
| **Mage Tower** | 2×2 | 60 wood + 60 gold | Magic damage + slow. |

**Utility buildings:**

| Building | Footprint | Cost | Function |
|---|---|---|---|
| **Forge** | 2×2 | 50 wood + 20 gold | Hero crafts weapons and armor upgrades. |
| **Repair Building (Mason's Workshop)** | 2×1 | 40 wood | Required to repair castle and walls. Repair costs scale with damage. |
| **Heirloom Altar** | 2×2 | 30 wood + 30 gold | Display and equip discovered Heirlooms. Each campaign starts unequipped; player must equip Heirlooms from their unlocked pool. |

**Total building roster at launch: ~14 building types.** Refine in prototype.

### 4.3 Walls

Walls are **optional** — the player can leave the castle exposed if they want a more open layout. Walls work the same way as every other building (see section 6.7: enemies attack anything in their path), but walls are **purpose-built for the sacrificial role**:

- Wall Segment: 100 HP, 10 wood, 1×1 tile.
- Cheapest HP-per-resource in the game — designed to be destroyed and rebuilt.
- Walls take **double damage** if a specific late-game curse is selected (see Curse System).
- Repair cost scales with damage percentage. Heavily damaged walls cost more in raw resources to repair than rebuilding from scratch — but rebuilding loses placement memory.

**Defensive design philosophy:** the player should think of walls as the *outer* sacrificial layer that absorbs damage so enemies never reach expensive buildings behind them. A typical defensive layout looks like:

```
        [enemy spawn edge]
              ↓
        [wall layer]        ← cheap, expected to die
        [tower layer]       ← protected by walls
        [resource buildings]← protected by towers
        [castle]            ← the final goal
```

A player who skips walls is making a real trade-off: their Farms and Markets become the front line and get destroyed instead.

### 4.4 Units: Recruits and Mercenaries

**Two unit pipelines, deliberately distinct:**

**Recruits** (permanent army):
- Trained at the Barracks. 1 per day at base rate, costs food per training.
- Auto-deploy during Sieges. Path from Barracks toward enemies.
- Persist across Sieges within a campaign.
- Killed Recruits are lost; train more.
- Recruit types unlocked through Barracks tiers: Spearman (Tier 1), Swordsman (Tier 2), Crossbowman (Tier 3).

**Mercenaries** (emergency burst):
- Hired from Mercenary Camp during Day or Night phase.
- Expensive — pure gold sink.
- Temporary: contracts last 1 Siege only. Vanish after.
- Higher stats than Recruits, no training time required.
- Player chooses Mercenary type at hire (Knight Mercenary, Archer Mercenary, Cleric Mercenary for heals, etc.).
- Limited slots — castle can hire max N Mercenaries at once (capped to prevent gold-rushed wins).

**Towers** (third defense layer):
- Built with wood + sometimes gold.
- Permanent until destroyed.
- Auto-fire during Sieges. Cannot move.

**The three layers complement each other.** Recruits are your slow-built army. Mercenaries are your emergency reinforcements. Towers are your fixed defenses. A well-built castle uses all three.

---

## 5. Heirlooms

Heirlooms are powerful, build-defining passive modifiers acquired exclusively from **bosses, mini-bosses, and quest rewards** in the wider world.

### 5.1 Acquisition

**Sources only:**
- **Mini-boss kills:** ~8–12 mini-bosses per biome at varying difficulty. Each drops a guaranteed Heirloom (random from class pool, weighted by rarity).
- **Boss kills:** each biome has 1 named boss. Each drops a guaranteed Rare-or-better Heirloom.
- **Quest rewards:** ~3–5 quests per biome (rescue NPC, deliver item, ritual completion, etc.). Each rewards an Heirloom or other valuable.

**Total Heirlooms in the world per playthrough:** roughly 30–50 Heirlooms accessible if the player explored everything (which they won't — design target is ~50% biome coverage per run).

### 5.2 Heirloom Volume at Launch

- **20 Heirlooms per class** × 3 classes = **60 Heirlooms at launch**.
- Validate in prototype whether 20 per class delivers enough build variety. If not, scale to 30 per class (90 total).

### 5.3 Rarity Tiers

| Rarity | Drop Weight | Effect Scale |
|---|---|---|
| Common | 60% | Small, broadly useful. "+10% movement speed." |
| Rare | 30% | Medium, enables synergies. "Block consumes 0 stamina." |
| Epic | 10% | Build-defining. "Dash damages enemies. All movement abilities deal damage." |

### 5.4 Class-Specific Pools

Heirlooms are tied to hero class. A Wizard can find Wizard Heirlooms. A Knight finds Knight Heirlooms. They are not interchangeable.

This solves three problems:
1. Each class feels mechanically distinct (no melee Heirlooms on a Wizard).
2. Replay value (playing as a different class means a different Heirloom pool).
3. Discovery hook: "What Wizard Heirlooms are out there?" pulls players into the Wizard class once unlocked.

### 5.5 Heirloom Vault (Meta)

The Heirloom Vault is a permanent collection accessible from the main menu. Heirlooms the player has ever picked up are catalogued and visible. Filters by class, rarity, source.

**Important:** discovering an Heirloom in the Vault unlocks it for future runs to *potentially* drop. New players start with all Commons unlocked for their class. They expand the pool through play.

---

## 6. Sieges

### 6.1 The Three Sieges

Three Sieges per campaign, scheduled at fixed days on the 21-day calendar.

| Siege | Day | Theme |
|---|---|---|
| **Siege I** (name TBD — "The First Reckoning" is a placeholder) | 7 | Standard enemy roster. Siege I Boss. Teaches Siege mechanics. |
| **Siege II** (name TBD) | 14 | Larger waves, new enemy types, Curse I active. Siege II Boss. |
| **Siege III** (name TBD) | 21 | Final Siege. Siege III Boss (campaign-ending fight). Both curses active. |

### 6.2 Siege Structure

**A Siege begins at nightfall on its scheduled day.** A warning horn sounds at dawn that day, giving the player ~5–7 real-time minutes of final prep time during day phase. If the player is exploring far from home, they can use the Waypoint Shrine network to return — but only if there's a Shrine they've activated nearby.

**Siege duration:** approximately 5–10 minutes real-time.

**Wave structure:**
- 3–5 waves per Siege.
- Each wave grows in size and difficulty.
- Final wave includes the Siege boss.
- Brief inter-wave pauses (~10 seconds) for the player to reposition, heal, or buy Mercenaries.

**Player activity during Siege:**
- Hero is on the battlefield, fighting personally.
- Towers, Recruits, Mercenaries auto-fight.
- Hero can be anywhere within the castle plot.
- Hero can manage emergency Mercenary hires mid-Siege (Mercenary Camp must be active).

**Siege victory:** all waves defeated, boss defeated. Castle survives if HP > 0.
**Siege defeat:** castle HP reaches 0. Campaign over.

### 6.3 Bosses & Mini-Bosses

The game has two distinct boss tiers:

**Siege Bosses (3 total):** Unique characters that appear *only during Sieges*. Each is the climactic encounter of its Siege. They do not exist in the wider world — they only attack the castle when their Siege begins. Multi-phase, telegraphed attacks, distinct combat patterns, distinct music.

| Siege | Boss | Status |
|---|---|---|
| I | Siege I Boss | Name, visual identity, and mechanics TBD in Prototype phase. 3 phases. Teaches boss combat. |
| II | Siege II Boss | Name, visual identity, and mechanics TBD. 3 phases. Higher complexity. |
| III | Siege III Boss | Name, visual identity, and mechanics TBD. 4 phases. Final campaign boss. |

All Siege bosses drop a guaranteed Rare-or-better Heirloom on defeat.

**Mini-Bosses (3 total at launch):** Boss-tier encounters that live *in the world* during exploration. Each is biome-specific:

| Biome | Mini-Boss | Mandatory or Optional |
|---|---|---|
| Sewers | Sewers Mini-Boss | TBD — likely mandatory (gates Sewer completion / deep Shrine) |
| Mountain Depths | Mountain Depths Mini-Boss | TBD — likely mandatory (gates interior descent or deep loot) |
| Volcano | Volcano Mini-Boss | TBD — likely optional but high-value (the chained skull demon from art reference) |

Each mini-boss has its own sprite, animations, and mechanics. They are *not* reskinned versions of each other — each is unique to its biome.

All mini-bosses drop Heirlooms on defeat (rarity TBD per mini-boss; mandatory mini-bosses likely drop guaranteed Rare).

**Other biomes do not have mini-bosses at launch.** Most biomes are exploration-focused with regular enemies, resource nodes, NPCs, and quest hooks. Mini-bosses are highlights reserved for specific biomes where the encounter design supports them.

**Post-launch:** additional mini-bosses are a natural content update — one new mini-boss per content drop, added to a biome that currently has none.

### 6.4 Boss & Mini-Boss Open Questions (Prototype Phase)

To be decided during Prototype:

- **Siege boss names** — all three.
- **Siege boss visual identities** — concept art, sprite sheets, animation passes.
- **Siege boss specific mechanics** — phase transitions, attack patterns, retinue compositions.
- **Mini-boss names** — all three.
- **Mini-boss specific mechanics** — telegraphs, phase counts, encounter design.
- **Mandatory vs. optional designation for each mini-boss** — playtest reveals which feel right as required encounters and which feel right as skippable challenges.
- **Heirloom rarity drops per mini-boss** — tuned alongside the wider Heirloom rarity distribution.

### 6.5 Castle Damage Carryover

Castle HP **persists across Sieges and across days.** This is a centerpiece mechanic.

- Castle has 1000 HP at base (modified by meta upgrades).
- Damage during Siege I carries to Day 8 onward.
- Damage during exploration enemy probing also carries.
- The only way to restore castle HP is through the **Mason's Workshop** (Repair Building), which converts gold + wood into restored HP at a tunable rate.
- Strategic implication: managing castle wear becomes a resource trade-off. Spend gold repairing, or save for Mercenaries?

### 6.6 Walls and Building Damage

- All buildings (walls, towers, resource buildings, military buildings, utility buildings) have HP and can be destroyed.
- Destroyed buildings stop producing, training, or functioning. Towers stop firing. Walls leave a gap. Farms produce nothing.
- Repair cost scales with damage percentage. 50% damaged building costs ~30% of original cost to repair. Fully destroyed = must be rebuilt from scratch.
- Building damage carries day-to-day and Siege-to-Siege, same as castle damage.
- The Mason's Workshop (Repair Building) is required to perform repairs on any building.

### 6.7 Enemy Behavior

**Targeting rule:** all Siege enemies target the castle. The castle is the only objective. Enemies do not seek out buildings off their path.

**Engagement rule:** enemies attack anything in their direct path to the castle. If a Farm sits between an enemy's spawn point and the castle, the enemy stops, attacks the Farm until it is destroyed, then continues toward the castle. Same for walls, towers, every building.

**Practical implications:**

- **Every building is a hard obstacle.** Enemies cannot path around or through buildings. They must destroy them to pass.
- **No off-path seeking.** An enemy will not detour to attack a Farm that sits 5 tiles to the side of its path. It will only engage buildings directly in front of it.
- **Path recalculation when buildings die.** When a wall segment is destroyed mid-Siege, enemies behind it immediately update their path. They will now path through the gap toward the castle, potentially engaging new buildings exposed by the gap.
- **Walls are the intended sacrificial layer.** Cheap HP-per-resource. Designed to die so expensive buildings don't.
- **Building placement is defensive strategy.** Cluster expensive buildings (Forge, Heirloom Altar, Mason's Workshop) behind walls and towers. Place cheap buildings (Farms, Lumber Mills) as additional damage soakers if you can afford the rebuilds.

**Tower targeting (separate from enemy targeting):**

- Towers target the nearest enemy in range, by default.
- Specific tower types may have different rules (Cannon Tower may prefer dense enemy clusters; Mage Tower may prefer high-HP targets — TBD in prototype).

**Recruit and Mercenary behavior:**

- Auto-deploy from their building (Barracks or Mercenary Camp) when Siege begins.
- Path toward the nearest enemy threat and engage.
- Will defend buildings under attack if they are nearby.
- Will not actively patrol — they react to threats, not seek them.

**Exploration enemies (outside Sieges):**

- Wander within their camps during day.
- Some wander beyond camps at night.
- Engage the hero on sight if hero is in detection range.
- Do not attack the castle outside of Sieges. (Some specific mid-Siege probing events may exist — TBD in prototype if it adds tension or just frustrates the player.)

---

## 7. The Curse System

### 7.1 How Curses Work

After Siege I and Siege II, the player draws **3 curse cards** and picks 1 to activate for the rest of the campaign.

**Curses stack.** After Siege II's pick, both Siege I's and Siege II's curses are active for Siege III.

### 7.2 Curse Design Categories

**Enemy curses (make enemies stronger):**
- Enemies have +20% HP.
- Enemy waves spawn 25% faster.
- Boss has an extra phase.
- A new enemy type joins the roster.

**Economy curses (weaken your economy):**
- Markets no longer produce gold.
- Lumber Mills produce 50% less wood.
- Farm output halved.
- Mercenary costs +50%.

**Defense curses (weaken your defenses):**
- Walls take double damage.
- Towers fire 25% slower.
- Recruit training time doubled.
- Castle does not regenerate HP under any circumstance (Mason's Workshop disabled).

**Hero curses (weaken your hero):**
- Hero takes +25% damage during Sieges.
- Hero abilities have +50% cooldown.
- Heirloom effects 25% weaker.

### 7.3 Curse Volume

- **24 curses at launch** (6 per category × 4 categories).
- Each draw is 3 random curses from the unused pool — no repeats in a single campaign.
- Discovery hook: rare curses unlock as the player completes campaigns at various stacks.

### 7.4 Design Intent

The curse system is the **primary difficulty escalation mechanism.** Natural enemy escalation across Sieges is mild — most of the challenge curve comes from the curses the player chooses.

This means:
- New players ramp up slowly (they pick easier curses initially).
- Experienced players can chain hard curses for tougher runs.
- High-difficulty achievement runs naturally exist ("beat Siege III with all enemy curses").

This is also why the curse system replaces traditional Hades-style "Heat" / difficulty sliders. **The player crafts their own difficulty story per run.**

---

## 8. Meta Progression

### 8.1 Cross-Run Currency: Crowns

Earned every campaign (more for victory, less for defeat — scaled by Sieges survived).

**Spent on:**
- Permanent stat upgrades (starting wood, food, gold; starting castle HP; hero base HP; etc.).
- Unlock cosmetics.
- Unlock new starting buildings (e.g., "Begin every campaign with 1 free Watchtower").

10–12 meta upgrade tracks at launch, 3–5 tiers each.

### 8.2 Hero Class Unlocks

- **Knight:** starter, always available.
- **Rogue:** unlocked by completing Siege II for the first time.
- **Wizard:** unlocked by completing Siege III (winning a campaign) for the first time.

### 8.3 Heirloom Vault

See section 5.5. Permanent collection of discovered Heirlooms per class. New players start with all Commons unlocked.

### 8.4 Enemy Codex

Every enemy the player has encountered is logged in a Bestiary. Stats, lore, weaknesses, drop tables. Free discovery content with strong long-tail collection appeal.

### 8.5 Cosmetic Unlocks

Earnable only. Categories:

- Crown skins per hero class (3–5 per class).
- Castle banner colors and patterns.
- Castle visual variants (3–5 architectural styles).
- Weapon skins per hero class.

Unlocked through achievements, milestones, and seasonal events post-launch.

---

## 9. Save System

- **Save and resume mid-playthrough.** Player can quit at any time and resume exactly where they left off.
- Single autosave slot per active campaign (rogue-like convention — no save-scumming).
- Manual save permitted only between Sieges (between Day phases, never during a Siege).
- Cross-run meta progression saved separately and always persists.
- Versioned saves from day one with migration scaffolding.
- Steam Cloud sync compatible.

---

## 10. Game Feel & Presentation

### 10.1 The Three-Word Soul

**Explore. Prepare. Endure.**

Every design decision is evaluated against these three words. The game must do all three exceptionally well, not just one.

### 10.2 The Day/Night Rhythm

**Day exploration:** the open world feels open. Warm lighting, calm music, environmental ambient sound. Camera follows the hero with a slight lookahead. Resource nodes glint with subtle particle effects to aid spotting. NPC quest-givers visible from a distance.

**Night exploration:** the world becomes hostile. Cool blue lighting, predator silhouettes at the edge of vision, a distinct tense music bed. Visibility radius around the hero shrinks subtly. Wandering enemies more likely. The player is encouraged toward home, but not forced.

**Castle by day:** strategy-board feel. Camera slightly elevated, lighting golden. Buildings hum with worker activity. UI rich and visible.

**Castle by Siege:** all hell. Sirens, drums, drum-heavy music, screen shake from impacts, fire VFX, enemy roars, the hero's battle cry. UI minimal — only HP, resources, ability cooldowns, and the wave counter visible.

### 10.3 Siege Transition

When the Siege warning horn sounds at dawn of Day 7/14/21:
- Music swells into a tense pre-Siege motif.
- Sky color shifts subtly toward red over the entire day.
- A persistent UI banner appears: "SIEGE I — TONIGHT."
- Bird ambient SFX stop. Quiet falls over the world.

When night falls and the Siege begins:
- Camera snaps to the castle plot.
- Bass-heavy horn motif.
- Lights ignite in sequence on the castle walls and towers (if built).
- Enemy silhouettes appear at the northern edge of the plot.
- Music kicks into full Siege bed.
- "WAVE 1" banner unfurls.

### 10.4 Hero Combat Feel

Each class has distinct feel targets:

**Knight:**
- Sword swing: heavy 4-frame motion blur arc. ~3-frame hit-stop on enemy connection. Crunchy impact SFX.
- Block: hold-to-activate stance. Distinct visual (shield raised, slight forward lean).
- Parry: 8-frame window. Successful parry triggers slow-mo (~300ms) + bright VFX flash + dramatic sound stinger. Staggers attacker for ~1.5 seconds.

**Rogue:**
- Dagger strike: fast 2-frame swing. ~1-frame hit-stop. Sharp metallic impact.
- Dash: 12-frame i-frame window. Trail VFX during dash. Brief afterimage.
- Backstab proc: distinct sound + screen-flash + +50% damage particles. Player should immediately know "that was a backstab."

**Wizard:**
- Staff basic: ranged projectile, ~0.5s travel time. Particle trail.
- Blink: instant. Brief teleport VFX at origin and destination. Audio whoosh.
- Spell casts (channeled abilities via Heirlooms): visible windup, telegraphed AoE indicator on ground.

### 10.5 Building Placement Feel

- Drag a building from the build menu → ghost preview appears at cursor.
- Ghost rotates with R key (or controller equivalent).
- Ghost shows green tint where placement is valid, red where invalid.
- **Threat line preview:** when the ghost is placed near an enemy approach lane, a faint red line traces from the enemy spawn point through the building's position to the castle, telling the player "enemies coming from this spawn will hit this building first." Helps the player decide whether they're placing a building as a damage soaker or trying to put it safely behind defenses.
- Successful placement: satisfying construction VFX, wooden creak SFX, dust puff.
- Builders (animated NPCs) appear and work on the building over the next ~30 seconds of game time. Building is functional only after construction completes.

### 10.6 Resource Gathering Feel

- Resource nodes have subtle idle animations (trees rustling, ore glinting, berries bobbing).
- Player interacts with node → ~3-second harvest animation. Hero swings axe / picks / collects.
- Resource VFX bursts from node on harvest.
- Resources arc toward the hero's inventory icon, with a satisfying "ding" per pickup.
- Carrying-cap warnings: hero begins to glow / icon flashes when near cap. Carrying cap reached → no further harvest until deposited.

### 10.7 Visual Style

- 2D top-down pixel art.
- 32×32 base tile size.
- 64×64 character sprites (hero, large enemies, bosses).
- 32×32 smaller enemy sprites.
- Base game resolution: **960×540** (revised up from previous v0.2 spec, integer-scales cleanly to 1920×1080, 3840×2160).
- Palette: grounded fantasy. Warm grasslands, mossy forests, stark mountains, sickly swamps. Painterly limit palettes per biome for distinct identity.

### 10.8 Audio Direction

**Music:**
- Per-biome exploration themes (10 biomes × distinct music = 10 main exploration tracks).
- Castle ambient theme (day).
- Castle Siege theme (night, urgent).
- Boss themes (3 distinct, one per Siege boss).
- Curse selection theme.
- Menu theme.

**SFX:**
- Every resource type has a distinct gather sound.
- Every enemy type has distinct attack, hit, and death sounds.
- Every building has a distinct construction completion sound.
- Hero abilities are loud, celebratory, and distinct per class.

**Voice:**
- No VO at launch. Hero "battle cries" as voice-like SFX.
- Quest NPCs use text + atmospheric mumble sounds (Animal Crossing-style).

### 10.9 Accessibility

- Colorblind-safe resource and enemy color coding (always shape + color).
- Remappable keys (keyboard + controller).
- Adjustable text size.
- Screen shake toggle.
- Audio sliders: Music, SFX, UI, Ambience separately.
- Pause-anywhere during exploration (not during Sieges — Sieges are real-time challenges).

---

## 11. Architecture & Technical Direction

### 11.1 Engine and Language

- Godot 4.x, primarily GDScript.
- C# considered for hot paths if profiling justifies; not assumed at launch.
- No GDExtension at launch.

### 11.2 Data-Driven Content

All content defined as Godot custom Resources (`.tres`) under `res://data/`:

- `HeroData`, `HeroAbilityData`
- `BuildingData`, `WallData`, `TowerData`
- `UnitData` (Recruits, Mercenaries)
- `EnemyData`, `BossData`, `MiniBossData`
- `BiomeData`, `BiomeTilesetData`
- `WaveData`, `SiegeData`
- `HeirloomData`, `CurseData`
- `QuestData`, `WaypointShrineData`
- `ResourceNodeData`, `MetaUpgradeData`

ContentRegistry autoload loads all resources at startup. Adding new content = drop a `.tres` in the right folder, ship a Steam patch.

### 11.3 Mod Folder

Local `user://mods/` folder loaded alongside shipped content. Power users can drop custom `.tres` files. No official support, but enabled architecturally from day one. Steam Workshop integration is a post-launch enhancement.

### 11.4 Rendering and Platform

- Forward+ renderer on Steam.
- 960×540 base resolution, viewport stretch with aspect lock.
- InputAction-based input from day one. Controller-first input architecture.

### 11.5 Procedural Generation

The base map is hand-crafted. Procedural systems handle:
- Resource node placement within each biome (within designer-set zones).
- Enemy camp placement (within designer-set zones).
- Mini-boss spawn selection from a pool (one of N possible mini-bosses spawns per biome per run).
- Quest selection from a pool (each biome has 5–8 possible quests, 3–5 active per run).
- Heirloom drop tables (rarity-weighted per source).

### 11.6 Saves

- Single active campaign save slot.
- Meta-progression save separate, always loaded.
- JSON-based with `version` field and migration scaffolding.
- Steam Cloud compatible.

### 11.7 Platform Services Abstraction

All platform-specific calls (achievements, Steam Cloud, future leaderboards) route through a `PlatformServices` autoload for clean abstraction.

### 11.8 Version Control

Git + Git LFS from first commit.

---

## 12. Risks & Open Questions

### 12.1 Top Risks

1. **6-month timeline is aggressive for the scope.** Mitigation: aggressive team scaling, clear phase exit criteria, ruthless cut-list during prototype if features slip.

2. **Procedural generation balance.** Hand-crafted base + procedural placement is the right architecture but tuning it for varied-but-fair play is hard. Mitigation: prototype proc-gen early (Concept phase), playtest extensively, accept that the first version will need revision.

3. **Hero combat feel across three classes.** Each class needs to feel distinct and satisfying. That's effectively three combat systems. Mitigation: prototype Knight first to validate the feel target, then port the proven feel architecture to Rogue and Wizard.

4. **Exploration loop loneliness.** A 2-hour single-player game where you wander a map needs strong moment-to-moment engagement. Discovery (Heirlooms, Codex, quests, NPCs) must feel constant. Mitigation: prototype exploration density carefully, ensure no minute of exploration is dead time.

5. **Siege curse balance.** With 24 curses and 2-curse stacks, balance complexity is high. Mitigation: extensive playtesting, target-balanced rather than perfectly-balanced curve, allow players to retry curse picks if it feels punishing (TBD design decision).

### 12.2 Open Questions

- Final exact resource economy values (drop rates, gather rates, building costs).
- Whether Sieges can be skipped or delayed by certain Heirlooms/curses (probably no).
- Whether the hero can die *during* a Siege without ending the run (probably yes — respawn at castle).
- Exact map size in tiles. 50% biome coverage target needs concrete numbers.
- Whether Mercenary types should be discoverable/unlockable.
- Whether quests should be hand-written narrative or procedurally generated.

---

## 13. Post-Launch (Flagged, Not Planned)

Explicitly out of launch scope:

- Co-op multiplayer (flagged as potential post-launch direction).
- Endless mode after Siege III.
- Higher difficulty tiers (potentially "auto-stack all curses" mode).
- Additional hero classes.
- Additional biomes (3 expansion tilesets reserved).
- Steam Workshop mod integration.
- Mobile port (significant rework given input scheme).
- Daily Challenge with shared seed.
- Weekly leaderboards.

---

## 14. Not In This Game

Explicit out-of-scope list:

- **No global chat.** Ever.
- **No PvP at launch.** Co-op flagged, PvP no.
- **No paid loot boxes or gacha.** Ever.
- **No battle pass.**
- **No ads.**
- **No real-money gameplay purchases.**
- **No mandatory online.** Steam Cloud sync is the only network touchpoint at launch.
- **No mid-Siege save and resume.** Saves only between Sieges.
- **No leaderboards at launch.**
- **No Steam Workshop at launch.**
- **No mobile port at launch.**
- **No respec / class change mid-run.**

---

*End of document. Changes land here first, not in chat.*
