# Asset Spec — Hero: Knight

Sourcing target for the Knight class. C5 (Hero Combat Prototype) is paused until this lands.

## Hard requirements

| Property | Value | Why |
|---|---|---|
| **Style** | 2D pixel art, top-down or top-down 3/4 perspective | Matches the rest of the game (Craftpix Epic RPG World biomes) |
| **Frame size** | 64×64 pixels per frame | GDD §10.7 spec for hero/large sprites; integer-scales cleanly with the 32×32 tile grid |
| **Background** | Transparent (PNG with alpha) | Required for layering on biome tilesets |
| **Color** | White/silver tabard preferred (royal-guard read) | Matches your shieldman_1 pick. Other palette swaps acceptable if recolorable. |
| **License** | Usable in a commercial Steam release | CC0 / CC-BY / paid commercial license. Avoid CC-BY-NC (non-commercial only) and CC-BY-SA (forces share-alike of the whole project). |

## Direction support — preference order

The Knight is controlled via WASD + mouse-aim. The sprite must communicate facing in some way.

**Best:** 8-direction sprites (N, NE, E, SE, S, SW, W, NW). 8 facing variants × every animation = ~336+ frames. Rare and expensive.

**Acceptable (more common):** 4-direction sprites (N, E, S, W) with **horizontal flip** producing W from E. The sprite's body facing follows movement direction; the mouse-aim drives only the attack hitbox direction, not body rotation. This is what most top-down pixel-art games use (Hyper Light Drifter, Tunic, etc).

**Last resort:** Single-facing (3/4 view) with horizontal flip for left/right. Body always faces camera, looks "tank-like" when moving north. Not preferred.

## Required animations

| Animation | Frames | Looping | Notes |
|---|---|---|---|
| **idle** | 4–8 | Yes | Slight breathing/shifting motion. Shield ready (not actively raised). |
| **walk** (or **run**) | 6–8 | Yes | Two foot-falls per loop is the norm. ~150ms per frame. |
| **attack** | 4–6 | No | Sword swing. Hit-connect should be on frame 3 of 5 (mid-swing apex). |
| **block** | 1–3 (or static) | Yes (or static) | Shield up, slight forward lean. Sustainable stance. |
| **parry_flash** | 1–3 | No | Brief shield-glow / star burst on successful parry. Can be a separate VFX overlay if the base block frame is reused. |
| **hurt** *(optional)* | 1–3 | No | Flinch. If absent, color-modulate red on hit instead. |
| **death** | 4–8 | No | Falls / staggers. Final frame stays on screen. |
| **cheer** *(optional)* | 4–6 | No | Victory pose for Siege completion. Defer if not available. |

If the asset bundles "attack-1", "attack-2", "attack-3" as a combo: take just attack-1 for the Knight. The Knight's design is one heavy committed strike, not a combo.

## File format preferences (most-to-least preferred)

1. **Aseprite source files (`.aseprite`)** with animation tags — best, gives us frame timings and tag names directly.
2. **Spritesheet PNGs** with a JSON sidecar (Aseprite-export format, TexturePacker JSON, or generic). The JSON lets me wire it up without manually entering frame rects.
3. **Spritesheet PNGs** with consistent grid layout (e.g. 64×64 cells in a known column/row ordering) and a README explaining which row is which animation. This is what the current `shieldman_pack` provides; workable but slowest to wire up.

If only the third format is available, document the grid clearly:

```
Row 0 (y=0..63):     idle, frames 0..N-1
Row 1 (y=64..127):   walk south, frames 0..N-1
... etc.
```

## Where to look

Suggested places to source from, roughly cheapest → most polished:

- **OpenGameArt.org** — search "knight top down 4 direction". Free, mostly CC-BY.
- **itch.io asset stores** — search "top-down knight pixel art", filter by "commercial use allowed". Many $5–$30 packs.
- **Craftpix.net** — already the source of your biome tilesets. They have a "Top Down Knight" character pack; check if it has the directions and animations above before buying.
- **Penzilla / Cup Nooble / Astrobob** (Aseprite community) — known for polished top-down RPG character packs.
- **Commission** — fiverr / artstation. Highest quality match to spec, typically $100–$500.

## Where to put the file once you have it

Drop the spritesheet PNG (and any sidecar files) at:

```
art/characters/knight/
    knight_spritesheet.png
    knight.aseprite          # if available
    knight.json              # if available
    LICENSE.txt              # required — copy of the asset's license terms
```

Then ping me and I'll wire it into `data/heroes/knight.tres` and the Hero scene.

## Validation checklist

When you've selected an asset, before purchase/download, confirm:

- [ ] License explicitly allows commercial use on Steam
- [ ] 64×64 frame size (or cleanly downscalable to it)
- [ ] At minimum: idle, walk, attack, block, death animations
- [ ] At minimum: 4-direction support (or single-facing if you've decided to accept the compromise after seeing options)
- [ ] PNG with alpha channel, not opaque background
- [ ] Total file size under ~2 MB (anything bigger likely has wasted padding)
