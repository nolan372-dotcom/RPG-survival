# Generates art/biomes/grasslands/grasslands.tmx — a Tiled map painted with
# the river-crossing layout we agreed on, in ERW Grass Land 2.0 style.
# 80x80 tiles at 32x32 (2560x2560 to match the world canvas).
#
# Layers:
#   - terrain   (painted: grass / dirt / water based on layout rules)
#   - props     (empty, for trees/rocks placed by hand in Tiled)
#   - overlay   (empty, for top-most decoration / shadows)
#   - points_of_interest (object layer with labeled POI rectangles)
#
# Tilesets (firstgid order):
#   grass_ground     1..9     plain grass variants (randomized)
#   plain_dirt       10       plain dirt tile
#   water_palette    11..42   water + river-edge tiles (cell 0 = full water)
#   terrain          43..4002 the big sheet for autotile edges (added but
#                             not auto-painted; you use it in Tiled to refine
#                             grass/dirt and grass/water transitions).
#
# Hard edges between terrain types are intentional in this starter pass —
# refine transitions in Tiled using the autotile rules that ship with the
# ERW pack (rules.txt) or by hand-picking transition tiles from terrain.

# NOTE: this generates the painted river-crossing starter as a REFERENCE
# file (grasslands_starter.tmx). The active map (grasslands.tmx) is now the
# blank canvas built by tools/build_blank_tmx.ps1 — running this script
# does NOT touch grasslands.tmx.
$OUTPATH = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")).Path "art\biomes\grasslands\grasslands_starter.tmx")

# ---- Constants --------------------------------------------------------------
$MAP_W = 80   # tiles
$MAP_H = 80
$TILE = 32
$CANVAS_W = $MAP_W * $TILE   # 2560
$CANVAS_H = $MAP_H * $TILE   # 2560
$CENTER_PX_X = $CANVAS_W / 2  # 1280 — hero spawn = world origin
$CENTER_PX_Y = $CANVAS_H / 2  # 1280

# GIDs after tileset declarations
$GID_GRASS_BASE = 1   # GIDs 1..9 are grass variants
$GID_GRASS_COUNT = 9
$GID_DIRT       = 10
$GID_WATER      = 11  # cell (0,0) of water_palette = full water

# ---- River centerline -------------------------------------------------------
# Sine-curved river running N-S, with the bend at hero spawn (where the bridge
# crosses). Matches the layout from paint_mockup_underlay.ps1.
function RiverCx([double]$py) {
    $t = $py / $CANVAS_H
    return 1280.0 - 120.0 + [Math]::Sin($t * [Math]::PI * 1.6) * 180.0 + [Math]::Sin($t * [Math]::PI * 3.2 + 0.7) * 60.0
}
$RIVER_HALF_WIDTH = 75.0
$BRIDGE_Y = [double]$CENTER_PX_Y
$BRIDGE_HALF_H = 48.0      # 3-tile bridge vertical band
$BRIDGE_HALF_W = 160.0     # bridge dirt corridor width

# ---- Clearings (canvas-pixel center + radius) -------------------------------
# ENEMY CAMP moved east (world x 300 -> 500) so the elaborate mockup layout
# of tents + watchtowers + palisade fits without overlapping the river, and
# radius expanded to 380 so the dirt clearing contains most of the props.
$clearings = @(
    @{ name="ENEMY CAMP";    cx=([double]($CENTER_PX_X + 500));  cy=([double]($CENTER_PX_Y + 350));  r=380.0 },
    @{ name="MINI-BOSS";     cx=([double] $CENTER_PX_X);          cy=([double]($CENTER_PX_Y - 850));  r=150.0 },
    @{ name="GOLD WEST";     cx=([double]($CENTER_PX_X - 850));  cy=([double]($CENTER_PX_Y - 200));  r=100.0 },
    @{ name="GOLD EAST";     cx=([double]($CENTER_PX_X + 850));  cy=([double]($CENTER_PX_Y + 250));  r=100.0 }
)
$CAMP_CX = [double]($CENTER_PX_X + 500)
$CAMP_CY = [double]($CENTER_PX_Y + 350)

# ---- Paths (canvas-pixel polylines as flat double arrays) -------------------
# Pre-compute bridge mouths anchored to where the river is at BRIDGE_Y.
$bridgeCx = [double](RiverCx $BRIDGE_Y)
$bridgeEastMouth = [double]($bridgeCx + $BRIDGE_HALF_W + 16)
$bridgeWestMouth = [double]($bridgeCx - $BRIDGE_HALF_W - 16)

# Comma has higher precedence than +/- in PowerShell, so wrap each scalar.
[double[]]$pathA = @(($bridgeEastMouth), ($BRIDGE_Y),
                     (180 + $CENTER_PX_X), (180 + $CENTER_PX_Y),
                     (500 + $CENTER_PX_X), (350 + $CENTER_PX_Y))
[double[]]$pathB = @(($bridgeWestMouth), ($BRIDGE_Y),
                     (-150 + $CENTER_PX_X), (180 + $CENTER_PX_Y),
                     (-400 + $CENTER_PX_X), (250 + $CENTER_PX_Y))
[double[]]$pathC = @(($bridgeCx - 16), ($BRIDGE_Y - 48),
                     (-150 + $CENTER_PX_X), (-350 + $CENTER_PX_Y),
                     (-60 + $CENTER_PX_X),  (-650 + $CENTER_PX_Y),
                     (0 + $CENTER_PX_X),    (-850 + $CENTER_PX_Y))
[double[]]$pathD = @((500 + $CENTER_PX_X), (350 + $CENTER_PX_Y),
                     (700 + $CENTER_PX_X), (300 + $CENTER_PX_Y),
                     (850 + $CENTER_PX_X), (250 + $CENTER_PX_Y))
[double[]]$pathE = @((-400 + $CENTER_PX_X), (250 + $CENTER_PX_Y),
                     (-650 + $CENTER_PX_X), (0 + $CENTER_PX_Y),
                     (-850 + $CENTER_PX_X), (-200 + $CENTER_PX_Y))
# Path to/from castle exits south edge
[double[]]$pathSouth = @(($bridgeCx), ($CENTER_PX_Y + $BRIDGE_HALF_H),
                         ($CENTER_PX_X), ($CANVAS_H - 16))
$paths = New-Object System.Collections.ArrayList
[void]$paths.Add($pathA); [void]$paths.Add($pathB); [void]$paths.Add($pathC)
[void]$paths.Add($pathD); [void]$paths.Add($pathE); [void]$paths.Add($pathSouth)
$PATH_HALF_WIDTH = 40.0   # ~2.5 tiles wide

function DistToSegment([double]$px, [double]$py, [double]$ax, [double]$ay, [double]$bx, [double]$by) {
    $dx = $bx - $ax; $dy = $by - $ay
    $len2 = $dx*$dx + $dy*$dy
    if ($len2 -lt 0.0001) {
        $ddx = $px - $ax; $ddy = $py - $ay
        [double]([Math]::Sqrt($ddx*$ddx + $ddy*$ddy)); return
    }
    $t = (($px - $ax) * $dx + ($py - $ay) * $dy) / $len2
    if ($t -lt 0) { $t = 0 } elseif ($t -gt 1) { $t = 1 }
    $cxp = $ax + $dx * $t; $cyp = $ay + $dy * $t
    $ddx = $px - $cxp; $ddy = $py - $cyp
    [double]([Math]::Sqrt($ddx*$ddx + $ddy*$ddy))
}

# ---- Generate the terrain layer CSV ----------------------------------------
$rng = New-Object System.Random 1337
$terrainRows = New-Object System.Collections.Generic.List[string]
for ($ry = 0; $ry -lt $MAP_H; $ry++) {
    $cy = [double]($ry * $TILE + $TILE / 2)
    $riverCxHere = [double](RiverCx $cy)
    $onBridgeRow = ([Math]::Abs($cy - $BRIDGE_Y) -lt $BRIDGE_HALF_H)
    $rowGids = New-Object System.Collections.Generic.List[int]
    for ($cx = 0; $cx -lt $MAP_W; $cx++) {
        $px = [double]($cx * $TILE + $TILE / 2)
        $kind = "grass"

        # 1. Clearings take priority (so mini-boss platform cuts the river)
        foreach ($cl in $clearings) {
            $ddx = $px - $cl.cx; $ddy = $cy - $cl.cy
            if (($ddx*$ddx + $ddy*$ddy) -lt ($cl.r * $cl.r)) { $kind = "dirt"; break }
        }

        # 2. Paths
        if ($kind -ne "dirt") {
            foreach ($path in $paths) {
                $segs = ($path.Length / 2) - 1
                for ($i = 0; $i -lt $segs; $i++) {
                    $ax = $path[$i*2];     $ay = $path[$i*2 + 1]
                    $bx = $path[$i*2 + 2]; $by = $path[$i*2 + 3]
                    if ((DistToSegment $px $cy $ax $ay $bx $by) -lt $PATH_HALF_WIDTH) {
                        $kind = "dirt"; break
                    }
                }
                if ($kind -eq "dirt") { break }
            }
        }

        # 3. River (only if still grass)
        if ($kind -eq "grass") {
            $distRiver = [Math]::Abs($px - $riverCxHere)
            if ($distRiver -lt $RIVER_HALF_WIDTH) {
                if ($onBridgeRow) { $kind = "dirt" }   # bridge deck
                else              { $kind = "water" }
            }
        }

        $gid = switch ($kind) {
            "grass" { $GID_GRASS_BASE + $rng.Next($GID_GRASS_COUNT) }
            "dirt"  { $GID_DIRT }
            "water" { $GID_WATER }
        }
        [void]$rowGids.Add($gid)
    }
    $terrainRows.Add(($rowGids -join ","))
}
# Stitch into CSV (Tiled wants comma-separated, newlines between rows OK)
$terrainCsv = "`n" + (($terrainRows | ForEach-Object {
    if ($_ -eq $terrainRows[$terrainRows.Count - 1]) { $_ } else { $_ + "," }
}) -join "`n") + "`n"

# Empty CSV for props + overlay layers
$emptyRow = (("0," * ($MAP_W - 1)) + "0")
$emptyRows = New-Object System.Collections.Generic.List[string]
for ($r = 0; $r -lt $MAP_H; $r++) {
    if ($r -eq $MAP_H - 1) { $emptyRows.Add($emptyRow) } else { $emptyRows.Add($emptyRow + ",") }
}
$emptyCsv = "`n" + ($emptyRows -join "`n") + "`n"

# ---- Build the points_of_interest object layer ------------------------------
# Helper that emits a labeled rectangle object with size + center comment.
function ObjRect([int]$id, [string]$name, [double]$cx, [double]$cy, [double]$w, [double]$h, [string]$color) {
    $x = [int]($cx - $w / 2); $y = [int]($cy - $h / 2)
    $iw = [int]$w; $ih = [int]$h
    return "  <object id=`"$id`" name=`"$name`" x=`"$x`" y=`"$y`" width=`"$iw`" height=`"$ih`"/>"
}

$objs = New-Object System.Collections.Generic.List[string]
$nextId = 1
# Spawn FOV rectangle (960x540 centered on hero spawn)
[void]$objs.Add((ObjRect $nextId "SPAWN_FOV (player's first view)" $CENTER_PX_X $CENTER_PX_Y 960 540 "yellow")); $nextId++
# Hero spawn point (small)
[void]$objs.Add((ObjRect $nextId "HERO_SPAWN" $CENTER_PX_X $CENTER_PX_Y 32 32 "red")); $nextId++
# Bridge
[void]$objs.Add((ObjRect $nextId "BRIDGE" $bridgeCx $BRIDGE_Y ($BRIDGE_HALF_W * 2) ($BRIDGE_HALF_H * 2) "brown")); $nextId++
# POI clearings
foreach ($cl in $clearings) {
    [void]$objs.Add((ObjRect $nextId $cl.name $cl.cx $cl.cy ($cl.r * 2) ($cl.r * 2) "orange"))
    $nextId++
}
# Berry zones (just markers, not painted as dirt)
[void]$objs.Add((ObjRect $nextId "BERRY EAST" ($CENTER_PX_X + 400) ($CENTER_PX_Y - 150) 460 360 "purple")); $nextId++
[void]$objs.Add((ObjRect $nextId "BERRY SOUTHWEST" ($CENTER_PX_X - 400) ($CENTER_PX_Y + 250) 460 360 "purple")); $nextId++
# Biome edge labels — small markers on each edge
$EDGE_MARGIN = 48
[void]$objs.Add((ObjRect $nextId "SOUTH exit -- to Castle Plot" $CENTER_PX_X ($CANVAS_H - $EDGE_MARGIN) 800 60 "blue")); $nextId++
[void]$objs.Add((ObjRect $nextId "NORTH exit -- to Grassland Wilds" $CENTER_PX_X $EDGE_MARGIN 800 60 "blue")); $nextId++
[void]$objs.Add((ObjRect $nextId "EAST exit -- to Ocean / Beach" ($CANVAS_W - $EDGE_MARGIN) $CENTER_PX_Y 60 800 "blue")); $nextId++
[void]$objs.Add((ObjRect $nextId "WEST exit -- to Cemetery / Village" $EDGE_MARGIN $CENTER_PX_Y 60 800 "blue")); $nextId++
$objectXml = $objs -join "`n"

# ---- Build the camp_objects tile-object layer -------------------------------
# Recreates the layout of orc-tents updt 2.0.png mockup using individual
# sprite extractions from sheet2-sprites. Tiled tile-objects anchor at the
# BOTTOM-LEFT corner of their render rectangle.
#
# camp_props GIDs (firstgid 4003):
#   4003 tent_dome (416x352)         4013 tent_green_small (160x160)
#   4004 tent_hut (416x352)          4014 watchtower (128x224)
#   4005 campfire (64x64)            4015 palisade_1 (96x64)
#   4006 bone_big_1 (64x128)         4016 palisade_2 (96x64)
#   4007 bone_big_2 (64x128)         4017 palisade_3 (64x96)
#   4008 bone_small_1 (32x32)        4018 workbench_cart (160x160)
#   4009 bone_small_2 (32x32)        4019 banner (96x128)
#   4010 tent_red (320x288)          4020 banner_alt (96x128)
#   4011 tent_green (320x288)        4021 weapon_rack (256x160)
#   4012 tent_red_small (160x160)    4022 weapon_axe (32x32)
function TileObj([int]$id, [int]$gid, [string]$name, [double]$centerX, [double]$centerY, [double]$w, [double]$h) {
    $x = [int]($centerX - $w / 2)
    $y = [int]($centerY + $h / 2)   # bottom-left for tile-objects
    $iw = [int]$w; $ih = [int]$h
    return "  <object id=`"$id`" gid=`"$gid`" name=`"$name`" x=`"$x`" y=`"$y`" width=`"$iw`" height=`"$ih`"/>"
}

$campObjs = New-Object System.Collections.Generic.List[string]
$campId = 1000   # high id so it doesn't collide with POI ids

# Render order matters — earlier in XML = behind, later = in front.
# Order roughly by Y (top of mockup -> back, bottom -> front).

# --- Back row (tall structures behind everything else) ---
# Watchtower (top-left corner of camp)
[void]$campObjs.Add((TileObj $campId 4014 "watchtower_NW" ($CAMP_CX - 280) ($CAMP_CY - 240) 128 224)); $campId++
# Watchtower (top-right corner)
[void]$campObjs.Add((TileObj $campId 4014 "watchtower_NE" ($CAMP_CX + 280) ($CAMP_CY - 240) 128 224)); $campId++
# Weapon rack (top center, displayed prominently)
[void]$campObjs.Add((TileObj $campId 4021 "weapon_rack" $CAMP_CX ($CAMP_CY - 270) 256 160)); $campId++

# --- Mid layer: small tents flanking the back ---
# Small green tent (top-left of mid area)
[void]$campObjs.Add((TileObj $campId 4013 "tent_green_small" ($CAMP_CX - 200) ($CAMP_CY - 130) 160 160)); $campId++
# Small red tent (top-right of mid area)
[void]$campObjs.Add((TileObj $campId 4012 "tent_red_small" ($CAMP_CX + 200) ($CAMP_CY - 110) 160 160)); $campId++

# --- Center layer: big tents (main visual features) ---
# Big red tent — center-left, dominant
[void]$campObjs.Add((TileObj $campId 4010 "tent_red_big" ($CAMP_CX - 140) ($CAMP_CY + 30) 320 288)); $campId++
# Big green tent — center-right
[void]$campObjs.Add((TileObj $campId 4011 "tent_green_big" ($CAMP_CX + 180) ($CAMP_CY + 80) 320 288)); $campId++

# --- Front layer: small props (in front of tents) ---
# Workbench cart (right side)
[void]$campObjs.Add((TileObj $campId 4018 "workbench_cart" ($CAMP_CX + 320) ($CAMP_CY + 20) 160 160)); $campId++
# Campfire (center, between tents)
[void]$campObjs.Add((TileObj $campId 4005 "campfire" $CAMP_CX $CAMP_CY 64 64)); $campId++
# Banner pole (skull totem, bottom-right)
[void]$campObjs.Add((TileObj $campId 4019 "banner" ($CAMP_CX + 250) ($CAMP_CY + 220) 96 128)); $campId++
# Second banner (bottom-left)
[void]$campObjs.Add((TileObj $campId 4020 "banner_alt" ($CAMP_CX - 320) ($CAMP_CY + 120) 96 128)); $campId++

# --- Bones scattered ---
[void]$campObjs.Add((TileObj $campId 4006 "bone_big_1" ($CAMP_CX - 80) ($CAMP_CY + 180) 64 128)); $campId++
[void]$campObjs.Add((TileObj $campId 4007 "bone_big_2" ($CAMP_CX + 120) ($CAMP_CY - 50) 64 128)); $campId++
[void]$campObjs.Add((TileObj $campId 4008 "bone_small_1" ($CAMP_CX - 60) ($CAMP_CY + 60) 32 32)); $campId++
[void]$campObjs.Add((TileObj $campId 4009 "bone_small_2" ($CAMP_CX + 70) ($CAMP_CY + 60) 32 32)); $campId++

# --- Palisade fence along south edge of camp ---
# Tile palisade_1 horizontally from -350 to +350 offset, every 96 px
$palisadeY = $CAMP_CY + 340
for ($px = -350; $px -le 350; $px += 96) {
    $gidPick = if ($px % 192 -eq -350 -or $px % 192 -eq 254) { 4016 } else { 4015 }   # alternate variants
    [void]$campObjs.Add((TileObj $campId $gidPick "palisade" ($CAMP_CX + $px) $palisadeY 96 64))
    $campId++
}

$campObjectXml = $campObjs -join "`n"

# ---- Build the .tmx --------------------------------------------------------
$tmx = @"
<?xml version="1.0" encoding="UTF-8"?>
<map version="1.10" tiledversion="1.11.2" orientation="orthogonal" renderorder="right-down" width="$MAP_W" height="$MAP_H" tilewidth="$TILE" tileheight="$TILE" infinite="0" nextlayerid="6" nextobjectid="$campId">
 <tileset firstgid="1" source="grass_ground.tsx"/>
 <tileset firstgid="10" source="plain_dirt.tsx"/>
 <tileset firstgid="11" source="water_palette.tsx"/>
 <tileset firstgid="43" source="terrain.tsx"/>
 <tileset firstgid="4003" source="camp_props.tsx"/>
 <layer id="1" name="terrain" width="$MAP_W" height="$MAP_H">
  <data encoding="csv">$terrainCsv</data>
 </layer>
 <layer id="2" name="props" width="$MAP_W" height="$MAP_H">
  <data encoding="csv">$emptyCsv</data>
 </layer>
 <layer id="3" name="overlay" width="$MAP_W" height="$MAP_H">
  <data encoding="csv">$emptyCsv</data>
 </layer>
 <objectgroup id="4" name="camp_objects" color="#ff5500">
$campObjectXml
 </objectgroup>
 <objectgroup id="5" name="points_of_interest" color="#ffaa00">
$objectXml
 </objectgroup>
</map>
"@

[System.IO.File]::WriteAllText($OUTPATH, $tmx, (New-Object System.Text.UTF8Encoding $false))
Write-Output "Wrote $OUTPATH ($MAP_W x $MAP_H tiles, painted terrain + $($nextId - 1) POI markers)"
