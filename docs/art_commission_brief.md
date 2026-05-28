# Character Art Commission Brief — Crown & Wall

A spec for anyone commissioned to draw character sprites (heroes, enemies,
NPCs) for *Crown & Wall*. The goal: art that **drops into the game with no
rework** and **sits consistently** next to existing characters.

The shipped **Knight** is the reference standard. Everything new must match
its style, scale, perspective, and file format.

---

## 1. Project context

- **Engine:** Godot 4.6 — sprites become `AnimatedSprite2D` frames.
- **Genre/view:** top-down action-strategy, **low top-down / 3-quarter**
  perspective (you see the character's face and body, not the top of the head).
- **Base resolution:** 960 × 540. Pixel art, viewed at integer zoom.
- **Art style:** pixel art with a **dark outline** around the silhouette,
  saturated-but-grounded palette.

**Reference files** (hand these to the artist):
`art/characters/knight/knight-idle.png`, `-run`, `-attack-1/2/3`,
`-defend`, `-hurt`, `-death` — plus an in-game screenshot.

---

## 2. Technical format (non-negotiable)

Deliver in the **identical layout to the Knight sheets**:

| Spec | Value |
|---|---|
| Frame size | **96 × 84 px** |
| File | One PNG per animation, 32-bit with alpha |
| Sheet layout | Two rows — **row 0 = facing right, row 1 = facing left** |
| Figure size | Character fills ~**24 × 35 px** inside the frame (rest is transparent padding) |
| Figure anchor | Feet/root at the **same position in every frame** (~y60 in the frame) so the sprite doesn't jitter |
| Background | Fully transparent — **no anti-aliasing against a colored backdrop**, clean alpha edges |
| Grid | Frames on an exact pixel grid, no margins or padding between frames |

> If a character is meant to be larger or smaller than the Knight, keep the
> **96 × 84 frame** and change only the figure size inside it — state the
> target figure height in the per-character brief.

**Decision to make before commissioning:** hand-draw **both** left and
right facings (better for asymmetric weapons/shields, ~2× the work), or draw
**one** facing and let the game mirror it (cheaper). State which in the brief.

---

## 3. Animation set

Match the Knight's set. Frame counts are a guide, not a hard rule:

| Animation | Frames (per facing) | Loops |
|---|---|---|
| Idle | ~7 | yes |
| Run | ~8 | yes |
| Attack 1 / 2 / 3 | ~6 / 5 / 6 | no |
| Defend (block) | ~6 | no |
| Hurt | ~4 | no |
| Death | ~12 | no |

For each non-looping animation, note **where the key moment lands** (e.g.
"attack: weapon contact at frame 4 of 6") — the game times hits/effects to it.

Simple enemies may skip Defend and the extra attacks (Attack 1 only).

---

## 4. Style direction

- Pixel density must match the Knight — not smoother/HD, not chunkier.
- Low top-down / 3-quarter perspective, consistent with the Knight.
- Dark outline around the full silhouette.
- Palette harmonized with the Knight's.
- **Silhouette test:** the character must be readable as a solid black
  shape — distinct, recognizable pose.

---

## 5. Per-character brief (fill in, one per character)

```
Character name:
What it is:            (e.g. "Wood Wolf — a forest predator, drops wood")
Role:                  (hero / standard enemy / mini-boss / NPC)
Size vs Knight:        (figure height relative to the Knight's ~35 px)
Personality / shape:   (e.g. "lean and fast", "hulking bruiser")
Animations needed:     (from the table in §3)
Mood board:            (3-5 reference images attached)
```

---

## 6. Delivery & process

- File naming: `<character>-<animation>.png` (e.g. `wolf-idle.png`).
- A **contact sheet** — all animations in one preview image — for review.
- **Source files** included (layered Aseprite `.ase` or equivalent), not
  just flattened PNGs, so the art can be tweaked later.
- Revision rounds included: **2** (standard).
- Engine note for the artist: *"Sprites are sliced into uniform grid frames
  for Godot 4 AnimatedSprite2D — frames must be uniform and grid-aligned."*

---

## 7. The one rule that matters most

> Every character must sit at the **same pixel scale and perspective** as
> the Knight.

Inconsistent scale or perspective between characters is the single biggest
reason commissioned art looks wrong even when each piece is good on its own.
When in doubt, the artist should place their work-in-progress next to the
Knight sheet and check they belong in the same game.
