# Modding (stub)

Crown & Wall ships with a data-driven content system. All gameplay content is defined as Godot `Resource` (`.tres`) files under `res://data/`, and the `ContentRegistry` autoload scans the user's mod folder at startup and merges those resources on top of the shipped content.

## Local mod folder

Path: `user://mods/`

On Windows this resolves to `%APPDATA%\Godot\app_userdata\Crown & Wall\mods\` (or similar; Godot prints the resolved path on first startup).

The folder is created automatically the first time you launch the game.

## Folder layout

Mod resources must live under a subfolder that matches their category:

```
user://mods/
    heroes/
    hero_abilities/
    buildings/
    walls/
    towers/
    units/
    enemies/
    bosses/
    mini_bosses/
    biomes/
    biome_tilesets/
    waves/
    sieges/
    heirlooms/
    curses/
    quests/
    waypoint_shrines/
    resource_nodes/
    meta_upgrades/
```

## Override behavior

Each `.tres` exposes a `StringName id` property. If a mod resource has the same `id` as a shipped resource, the mod version overrides it. A warning is logged to the console:

```
ContentRegistry: mod resource <path> overrides shipped <category>/<id>
```

## Stability

Not officially supported. Resource class layouts may change between versions. Steam Workshop integration is planned post-launch.
