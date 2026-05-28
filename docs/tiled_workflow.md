# Tiled + YATI workflow for *Crown & Wall*

The biome maps are designed in **Tiled** (a standalone tilemap editor) and
imported into Godot via the **YATI** plugin (*Yet Another Tiled Importer*).
This doc covers first-time setup and the per-edit workflow.

> Why this instead of Godot's built-in TileMap editor? The ERW asset packs
> ship as `.tsx` Tiled tilesets with autotile rules. Tiled gives you Wang
> sets, automapping, and screen-by-screen design tools the Godot editor
> doesn't have. You design once in Tiled; YATI puts the result in-game.

---

## 1. One-time setup

### Install Tiled

1. Download from **https://www.mapeditor.org** (free, ~50 MB, Windows installer).
2. Run the installer. Default options are fine.
3. First launch: choose your preferred theme (Dark recommended).

### Install YATI in Godot

1. Open *Crown & Wall* in Godot 4.6.2.
2. Click **AssetLib** in the top tab bar.
3. Search **"Yet Another Tiled Importer"** (or just **"YATI"**).
4. Click the result → **Download** → **Install**.
5. **Project menu → Project Settings → Plugins** → enable **"YATI – Yet Another Tiled Importer"**.
6. Restart the editor when prompted.

That's it. Godot will now import `.tmx` files as TileMap scenes whenever they change.

---

## 2. Open your map for the first time

The active map is a **blank canvas with the full ERW Grass Land 2.0 toolkit** loaded:

```
art/biomes/grasslands/grasslands.tmx           (80 × 80 blank, all 19 tilesets loaded)
art/biomes/grasslands/grasslands_starter.tmx   (reference: painted river-crossing layout)
art/biomes/grasslands/gl2/tilesets/*.tsx       (19 tilesets — grass, walls, water, beach, fences, props)
art/biomes/grasslands/gl2/sprites/*.png        (the source PNGs each tileset references)
```

Open `grasslands.tmx` in Tiled — you'll see 19 tileset tabs in the Tilesets panel (everything from the GL 2.0 pack as paintable palettes) and three empty layers (terrain, props, overlay). Paint anything from any tileset; everything's available.

The `grasslands_starter.tmx` file is the painted river-crossing layout I generated earlier — open it for reference if you want to see one possible layout, but the active map is intentionally blank now.

To regenerate the blank canvas at any time, run:
```
powershell tools/build_blank_tmx.ps1
```

To regenerate the painted starter as a reference, run:
```
powershell tools/build_starter_tmx.ps1
```

1. Launch **Tiled** → **File → Open** → navigate to the project's `art/biomes/grasslands/` folder → open **`grasslands.tmx`**.
2. The map opens blank with three layers in the right-hand **Layers** panel:
   - **terrain** – paint grass / dirt / water here
   - **props** – paint trees / rocks / bushes (placed *on top* of terrain)
   - **overlay** – paint anything that needs to sit above everything else
3. The **Tilesets** panel (bottom-right) shows **terrain** and **water_palette**. Click a thumbnail then click a tile to select your "paint color."
4. Make sure **terrain** is the selected layer (left panel), then paint!

### Useful Tiled shortcuts

| Key | What it does |
|---|---|
| `B` | Brush (paint single tile) |
| `R` | Rectangle fill |
| `F` | Bucket fill |
| `S` | Selection rectangle |
| `E` | Eraser |
| `Z` | Tile flip horizontal |
| `X` | Tile flip vertical |
| Mouse wheel | Zoom |
| Middle-drag or Space-drag | Pan |
| `Ctrl+Shift+R` | Refresh tilesets (after editing PNGs externally) |

### Suggested first-time painting order

1. **Bucket-fill the whole terrain layer with plain grass.** Pick a clean grass tile from the *terrain* tileset (the grass cells are in the upper-left area), press `F`, click the map.
2. **Paint the river.** Switch to a water tile from *water_palette*, switch to brush, drag a river path.
3. **Paint dirt paths and clearings.** Pick a dirt tile from *terrain*, brush them onto the layer over the grass.
4. **Add props.** Switch to the **props** layer, pick a tree / rock tile, place them.
5. **Save** (`Ctrl+S`).

---

## 3. The per-edit workflow

Whenever you change the map in Tiled:

1. `Ctrl+S` in Tiled → the `.tmx` saves.
2. **Switch to Godot.** YATI sees the file change and re-imports.
3. The TileMapLayer in your scene updates automatically — no other action needed.

If the import doesn't happen automatically, force a re-import:

- In Godot's **FileSystem** panel, right-click `grasslands.tmx` → **Reimport**.

---

## 4. Adding more tilesets later

The starter only loads two tilesets (terrain + water palette). When you want fences, props, building materials, etc.:

1. Copy the desired source files into `art/biomes/grasslands/`:
   - `<name>.png` (the texture)
   - `<name>.tsx` (the Tiled tileset definition — usually ships in the asset pack's `TiledMap Editor/Tilesets/` folder)
2. Open the `<name>.tsx` in a text editor. Update its `<image source="..."/>` path so it points to the `.png` file you just copied (probably just the filename if you put them in the same folder).
3. In Tiled, with `grasslands.tmx` open: **Map → Add External Tileset** → pick the `.tsx`.
4. Save. New tileset shows up in the Tilesets panel and is available for painting.

Source tileset PNGs and .tsx files for the ERW Grass Land 2.0 pack live in:

```
C:\Users\nolan\OneDrive\Desktop\Map Tileset\ERW - Grass Land 2.0 v2.0\Tilesets\       <- .png files
C:\Users\nolan\OneDrive\Desktop\Map Tileset\ERW - Grass Land 2.0 v2.0\TiledMap Editor\Tilesets\   <- .tsx files
```

---

## 5. Wiring the imported map into the grasslands scene

*(Do this AFTER you've installed YATI and have a painted map.)*

1. In Godot, open `scenes/grasslands.tscn`.
2. YATI imports `grasslands.tmx` as a scene. Drag `art/biomes/grasslands/grasslands.tmx` from the FileSystem panel onto the scene tree, under a parent like `Map`.
3. Position the imported map's root at `(-1280, -1280)` so its center sits at world origin (the map is 2560×2560).
4. **Hide or delete** the existing `Map/TileMap` node and the `Map/Reference` Sprite2D — the YATI-imported scene replaces both.
5. Save the scene. Run the game (F5 or F11) — your painted map should appear under the hero.

---

## 6. Future: from one biome to the seamless world map

Once the grasslands map looks good, the same workflow scales up:

- Each biome (Castle Plot, Wilds, Cemetery, etc.) can be its own `.tmx` file in `art/biomes/<biome>/`.
- For a fully seamless world, **make one big .tmx** containing all surface biomes painted side-by-side (probably ~5000 × 5000 tiles arranged per the GDD's geographical layout).
- Or keep per-biome `.tmx` files and stitch them in Godot via positioned TileMapLayer nodes.

The architecture decision lives in the GDD; the tooling here supports either approach.

---

## Troubleshooting

**"YATI not in AssetLib"** — try searching just "Tiled". If still missing, install manually from https://github.com/Kiamo2/YATI/releases → copy the `addons/YATI/` folder into your project's `addons/`.

**"Tiled says it can't find an image"** — the `.tsx` file's `<image source="..."/>` path is wrong. Open the `.tsx` in a text editor and fix it to be relative to the `.tsx` file's location.

**"Map looks wrong after re-import"** — close and re-open the scene in Godot. YATI sometimes needs a scene reload to pick up tileset changes.

**"Performance lag while painting"** — Tiled handles huge maps fine; if Godot is slow, try disabling the `Map/Reference` underlay Sprite2D while you work.
