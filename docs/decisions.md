# Decision Log

Every meaningful design or scope change lands here with date, decision, and rationale. Treat this file like a code commit log for game-shaping decisions — the WHY is the point.

Conventions:
- Append new entries at the bottom.
- Use ISO date format (YYYY-MM-DD).
- Don't edit historical entries. If you change your mind, write a new entry that supersedes the old one and link to it.

---

## 2026-05-14 — v1.0 vision locked

**Decision:** GDD v1.0 ("Crown & Wall" — explore/prepare/endure with hand-crafted map, three Sieges, curse-driven difficulty) replaces v0.2 (rogue-like tower defense direction).

**Rationale:** v0.2 was a pure tower defense rogue-like. v1.0 layers exploration and base-building on top, gives the player narrative anchoring through the hero, and uses the curse system as a player-authored difficulty curve in place of traditional Heat/difficulty sliders. The shift trades scope for design coherence — every system now serves the explore/prepare/endure feel target.

**Implications:**
- 12 biomes, 3 heroes, 3 Sieges, 24 curses, 60 Heirlooms, ~24 buildings, ~30 enemies all become launch scope.
- 6-month target with phased plan (Concept → Vertical Slice → Content Production → Polish).
- The Sieges-as-fixed-calendar mechanic creates the central tension; do not rework lightly.

---

## 2026-05-14 — Solo-dev workflow accepted

**Decision:** Project is solo-dev + AI pair programmer. Epic C1 (team foundation) is skipped. C4 (visual/audio direction lock) is largely N/A because Craftpix asset packs already define the style. CI is deferred until Phase 2.

**Rationale:** ImplementationPlan.md was written assuming a team. Most of its team-coordination work (role assignments, PR review rules, design review process, art director sign-off) has no analog in a solo workflow and would be busywork to perform.

**Kept from the team-shaped plan:**
- Decision log (this file).
- ImplementationPlan.md as the live checklist.
- "Strict box-check" rule: only mark items that demonstrably meet their acceptance criteria.

---

## 2026-05-14 — Engine: Godot 4.6.2 stable

**Decision:** Engine is Godot 4.6.2 stable on Windows. GDScript primary; no C# or GDExtension at launch unless profiling justifies.

**Rationale:** GDScript is enough for 2D pixel-art top-down. Avoids C# build complexity and the cross-platform pain of .NET-on-Mac/Linux. GDExtension is a niche; revisit only for hot paths.

---

## 2026-05-14 — Git remote: GitHub (deferred)

**Decision:** Local git initialized 2026-05-14. GitHub will be the eventual remote; LFS via GitHub LFS. Push deferred until user creates the repo on github.com.

**Rationale:** Local commit history is the immediate need (revert/bisect on broken changes). Remote push is asynchronous to scaffolding work. LFS configured in `.gitattributes` from commit 1 so binary art doesn't get committed raw later.

**Tradeoff:** GitHub's free LFS quota is 1GB storage + 1GB/month bandwidth. May need to revisit if total binary asset size exceeds this — GitLab (10GB free) is the fallback.

---

## 2026-05-14 — ContentRegistry handles `.tres.remap` in exported builds

**Decision:** `ContentRegistry._scan_dir` accepts `.tres`, `.res`, `.tres.remap`, and `.res.remap` extensions. When it sees a `.remap` file it strips that suffix before calling `load()`.

**Rationale:** Godot 4's exporter converts text `.tres` resources to binary form and replaces the original entry in the pack with `<name>.tres.remap`, which Godot's `load()` follows transparently. A naive scanner that only looks for `.tres`/`.res` finds 0 files in an exported build, while the editor build works fine. This was caught by running the exported `.exe` headless after the first Windows export — load count went from 9 (editor) to 0 (export). The fix preserves editor behavior and also handles the export path.

**Discovered:** during C2-S2 export verification. Worth recording because the bug is silent — the game ships, runs, and crashes only when something asks ContentRegistry for content. Future content additions must remain compatible with this scan logic.
