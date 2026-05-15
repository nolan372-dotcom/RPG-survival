# Crown & Wall

A single-player action-strategy game where you rule a kingdom under siege — explore a vast map as your hero, gather resources, build defenses, and survive three escalating Sieges that you choose how to handicap yourself for.

See [GDD.md](GDD.md) for the full design document and [ImplementationPlan.md](ImplementationPlan.md) for the phased build plan.

## Stack

- **Engine:** Godot 4.6 (Forward+)
- **Language:** GDScript primarily; C# considered for hot paths if profiling justifies
- **Target platform:** Steam (Windows, Mac, Linux)
- **Base resolution:** 960×540, viewport stretch, aspect lock

## Project layout

```
/autoload          singletons (ContentRegistry, etc.)
/data              .tres content (heroes, buildings, enemies, biomes, waves, sieges, heirlooms, curses, quests, shrines, resource_nodes, meta_upgrades, units, towers, walls, hero_abilities, biome_tilesets, mini_bosses, bosses)
/entities          gameplay scene-objects (hero, enemies, buildings, projectiles)
/scenes            top-level scenes (bootstrap, main menu, castle, biomes)
/scripts           gameplay scripts
/scripts/data      Resource class definitions
/ui                UI scenes and themes
/art               sprites, tilesets, atlases
/audio             music and sfx
/maps              hand-crafted biome maps
/addons            third-party plugins (Git-tracked but isolated)
/docs              design notes, balance sheets, decision log
```

## Setup

1. Install **Godot 4.6 stable**. (This repo was scaffolded against `Godot_v4.6.2-stable_win64.exe`.)
2. Open `project.godot` in the editor. Godot will import all resources on first run; this takes ~30s.
3. Press F5 (or use the editor's Run button) to launch the bootstrap scene.

The bootstrap scene shows a count of every category loaded by `ContentRegistry`. Press **F1** in-game to dump the full registry contents to the console.

## Adding content

All gameplay content is data-driven. To add a hero, building, enemy, biome, etc:

1. Create a `.tres` file under the appropriate `/data` subfolder.
2. Attach the matching script (e.g. `res://scripts/data/hero_data.gd` for a hero).
3. Set a unique `id` (StringName) and the other fields.
4. The next time the project boots, `ContentRegistry` will load it automatically.

For local mods, drop `.tres` files into `user://mods/<category>/`. Mods override shipped resources by `id`, with a warning logged.

## Build / Export

(CI pipeline pending — Story C2-S3.)

## Status

Currently in **Phase 1: Concept**. See `ImplementationPlan.md` for the live checklist.
