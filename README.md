# Crown & Wall

> **Explore. Prepare. Endure.**
> A single-player action-strategy game where you rule a kingdom under siege — explore a vast map as your hero, gather resources, build defenses, and survive three escalating Sieges that you choose how to handicap yourself for.

![Engine](https://img.shields.io/badge/Godot-4.6-478CBF?logo=godotengine&logoColor=white)
![Language](https://img.shields.io/badge/GDScript-primary-355570)
![Platform](https://img.shields.io/badge/Steam-Win%20%7C%20Mac%20%7C%20Linux-1b2838?logo=steam&logoColor=white)
![Status](https://img.shields.io/badge/status-in%20development-orange)

<p align="center">
  <img src="art/biomes/grasslands/map_mockup_underlay.png" width="460" alt="Early grasslands blockout">
  <br>
  <em>Early grasslands blockout — concept art. (First playable in progress.)</em>
</p>

<!-- TODO: replace the image above with a real gameplay screenshot or GIF once the prototype is playable. -->

## What it is

*Crown & Wall* is a ~2-hour action-strategy run built around a 21-day calendar. You play a heroic ruler — **Knight, Rogue, or Wizard** — defending a castle in the grasslands of a much larger, hand-crafted world. Between three scheduled Sieges you explore outward, gather wood, food, and gold, hunt bosses for run-altering relics, and haul everything home to build walls, train armies, and hire mercenaries.

There is no "begin Siege" button — the Sieges arrive on the calendar whether you're ready or not. You can be deep in a crypt when the warning horn sounds, forcing a real choice: race home, or commit to the dungeon and accept that the castle faces the first wave understaffed.

If you like the base-building of *9 Kings*, the return-to-base exploration loop of *Don't Starve*, and the class-driven combat of *Hades*, that's the target.

## Features

- **Three heroes, three playstyles** — Knight, Rogue, and Wizard each move and fight differently: tank the dungeon-heavy route, dash through the wilds, or zone enemies from range.
- **A calendar you can't pause** — three Sieges land on a fixed 21-day schedule. No "start wave" button; the horn sounds whether you're home or three floors underground.
- **A hand-crafted world to explore** — 12 biome tilesets across a two-layer surface/underground map, difficulty radiating outward from your castle, and three distinct routes that all converge on the Volcano endgame.
- **Gather, then fortify** — the castle plot is the only buildable space in the game. Bring resources back to raise defenses, train armies, and hire mercenaries before the next wave hits.
- **You choose how it escalates** — after each Siege, pick a curse: tougher enemies, dried-up gold markets, or walls that take double damage. The difficulty curve is yours to set.
- **Relics & meta progression** — defeat bosses for run-altering Heirlooms, and unlock the Heirloom Vault, Bestiary, new heroes, and earnable cosmetics across runs.
- **Data-driven & moddable** — all content is `.tres` resources loaded at boot; drop files into a local mod folder to override anything by `id`.

Full design lives in **[GDD.md](GDD.md)**; the phased build roadmap is tracked openly in **[ImplementationPlan.md](ImplementationPlan.md)**.

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

## About

A personal project by **Nolan** ([@nolan372-dotcom](https://github.com/nolan372-dotcom)) — built in Godot 4.6, as both a game and a portfolio piece.

<!-- Add contact / portfolio links here — e.g. itch.io page, devlog, or email. -->
