# Builds the grasslands river-crossing concept underlay as a stamped composite
# of real ERW tile graphics (NOT painted blobs). Output:
#   art/biomes/grasslands/map_mockup_underlay.png  (2560x2240, 80x70 tiles)
#
# Per-tile logic: river curve -> water; bridge corridor -> dirt; near a path
# -> dirt; inside a clearing -> dirt; everything else -> grass. The user
# traces this in the editor by painting the equivalent tiles on the TileMap.

Add-Type -AssemblyName System.Drawing

$ROOT      = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$GRASS_SRC = Join-Path $ROOT "art\biomes\grasslands\grass_ground.png"        # 96x96 plain grass
$WATER_SRC = Join-Path $ROOT "art\biomes\grasslands\water_palette.png"       # 256x128, full water at (0,0)
$SOIL_SRC  = "C:\Users\nolan\OneDrive\Desktop\Map Tileset\ERW - Grass Land 2.0 v2.0\Tilesets\fertilized soil.png"
$OUTPATH   = Join-Path $ROOT "art\biomes\grasslands\map_mockup_underlay.png"

$CELL = 32
$COLS = 80
$ROWS = 70
$W = $COLS * $CELL  # 2560
$H = $ROWS * $CELL  # 2240

# World (X,Y) -> canvas px: sprite is centered at world (0,0), so add (1280, 1120).
# Use these as plain expressions inline — wrapping in helper functions confused
# PowerShell's type inference and produced array-typed results.

# Distance from point P to line segment A->B (inline-friendly, no return wrapping).
function DistToSegment([double]$px, [double]$py, [double]$ax, [double]$ay, [double]$bx, [double]$by) {
    $dx = $bx - $ax; $dy = $by - $ay
    $len2 = $dx*$dx + $dy*$dy
    if ($len2 -lt 0.0001) {
        $ddx = $px - $ax; $ddy = $py - $ay
        [double]([Math]::Sqrt($ddx*$ddx + $ddy*$ddy))
        return
    }
    $t = (($px - $ax) * $dx + ($py - $ay) * $dy) / $len2
    if ($t -lt 0) { $t = 0 } elseif ($t -gt 1) { $t = 1 }
    $cxp = $ax + $dx * $t; $cyp = $ay + $dy * $t
    $ddx = $px - $cxp; $ddy = $py - $cyp
    [double]([Math]::Sqrt($ddx*$ddx + $ddy*$ddy))
}

# --- Path definitions (canvas-pixel polylines, world+offset inlined) ---------
$BRIDGE_Y = [double](0 + 1120)  # world y=0 -> canvas py
# River centerline x at BRIDGE_Y
$t = $BRIDGE_Y / $H
$BRIDGE_CX = [double](1280 - 120 + [Math]::Sin($t * [Math]::PI * 1.6) * 180 + [Math]::Sin($t * [Math]::PI * 3.2 + 0.7) * 60)
$BRIDGE_HALF_W = [double]160
$PATH_HALF_WIDTH = [double]40   # ~2.5 tiles wide so paths read clearly

# Each path = flat array of doubles laid out as [x0,y0, x1,y1, ...].
# In PowerShell, `,` has HIGHER precedence than `+`/`-`, so every scalar
# expression in an array literal must be wrapped in parens; otherwise
# `a + b, c` parses as `a + (b, c)` — an array, which trips op_Addition.
[double[]]$pathA = @(($BRIDGE_CX + $BRIDGE_HALF_W + 16), ($BRIDGE_Y),
                     (180 + 1280), (180 + 1120),
                     (300 + 1280), (350 + 1120))
[double[]]$pathB = @(($BRIDGE_CX - $BRIDGE_HALF_W - 16), ($BRIDGE_Y),
                     (-150 + 1280), (180 + 1120),
                     (-400 + 1280), (250 + 1120))
[double[]]$pathC = @(($BRIDGE_CX - 16), ($BRIDGE_Y - 48),
                     (-150 + 1280), (-350 + 1120),
                     (-60 + 1280),  (-650 + 1120),
                     (0 + 1280),    (-850 + 1120))
[double[]]$pathD = @((300 + 1280), (350 + 1120),
                     (600 + 1280), (300 + 1120),
                     (850 + 1280), (250 + 1120))
[double[]]$pathE = @((-400 + 1280), (250 + 1120),
                     (-650 + 1280), (0 + 1120),
                     (-850 + 1280), (-200 + 1120))
# ArrayList stores each typed array as one element without flattening,
# unlike `@(, $pathA, , $pathB)` which ended up double-wrapping each entry.
$paths = New-Object System.Collections.ArrayList
[void]$paths.Add($pathA)
[void]$paths.Add($pathB)
[void]$paths.Add($pathC)
[void]$paths.Add($pathD)
[void]$paths.Add($pathE)

# Clearings (canvas-pixel center + radius)
$clearings = @(
    @{ cx = [double](300 + 1280);  cy = [double](350 + 1120);  r = [double]130 },   # camp
    @{ cx = [double](0 + 1280);    cy = [double](-850 + 1120); r = [double]150 },   # mini-boss
    @{ cx = [double](-850 + 1280); cy = [double](-200 + 1120); r = [double]100 },   # gold W
    @{ cx = [double](850 + 1280);  cy = [double](250 + 1120);  r = [double]100 }    # gold E
)

# --- Load source tiles -------------------------------------------------------
$grassImg = [System.Drawing.Bitmap]::FromFile($GRASS_SRC)
$waterImg = [System.Drawing.Bitmap]::FromFile($WATER_SRC)
$soilImg  = [System.Drawing.Bitmap]::FromFile($SOIL_SRC)

# Stamp source rectangles (each 32x32)
# Grass: pick from the 3x3 grass_ground (cells (0,0)..(2,2))
$grassCells = @(
    (New-Object System.Drawing.Rectangle  0,  0, 32, 32),
    (New-Object System.Drawing.Rectangle 32,  0, 32, 32),
    (New-Object System.Drawing.Rectangle 64,  0, 32, 32),
    (New-Object System.Drawing.Rectangle  0, 32, 32, 32),
    (New-Object System.Drawing.Rectangle 32, 32, 32, 32),
    (New-Object System.Drawing.Rectangle 64, 32, 32, 32),
    (New-Object System.Drawing.Rectangle  0, 64, 32, 32),
    (New-Object System.Drawing.Rectangle 32, 64, 32, 32),
    (New-Object System.Drawing.Rectangle 64, 64, 32, 32)
)
# Dirt: sx=200,sy=80 was the cleanest sample
$dirtRect  = New-Object System.Drawing.Rectangle 200, 80, 32, 32
# Water: cell (0,0) of water_palette
$waterRect = New-Object System.Drawing.Rectangle  0,  0, 32, 32

# --- Build the canvas --------------------------------------------------------
$bmp = New-Object System.Drawing.Bitmap $W, $H, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.Clear([System.Drawing.Color]::Transparent)

$rng = New-Object System.Random 1337

for ($r = 0; $r -lt $ROWS; $r++) {
    $cy = [double]($r * $CELL + 16)
    $tnorm = $cy / $H
    $river_x_here = [double](1280 - 120 + [Math]::Sin($tnorm * [Math]::PI * 1.6) * 180 + [Math]::Sin($tnorm * [Math]::PI * 3.2 + 0.7) * 60)
    $on_bridge_row = ([Math]::Abs($cy - $BRIDGE_Y) -lt 48)  # 3-tile vertical band
    for ($c = 0; $c -lt $COLS; $c++) {
        $cx = [double]($c * $CELL + 16)
        $dst = New-Object System.Drawing.Rectangle ($c * $CELL), ($r * $CELL), $CELL, $CELL

        # Decision order: clearings > paths > river > grass.
        # Clearings come first so the mini-boss platform / camps "cut into"
        # the river when they overlap, instead of being submerged in water.
        $tileKind = "grass"

        # 1. Clearings (highest priority)
        foreach ($cl in $clearings) {
            $ddx = $cx - $cl.cx; $ddy = $cy - $cl.cy
            if (($ddx*$ddx + $ddy*$ddy) -lt ($cl.r * $cl.r)) {
                $tileKind = "dirt"; break
            }
        }

        # 2. Paths (each path is a flat [x0,y0, x1,y1, ...] array)
        if ($tileKind -ne "dirt") {
            foreach ($path in $paths) {
                $segs = ($path.Length / 2) - 1
                for ($i = 0; $i -lt $segs; $i++) {
                    $ax = $path[$i*2];     $ay = $path[$i*2 + 1]
                    $bx = $path[$i*2 + 2]; $by = $path[$i*2 + 3]
                    if ((DistToSegment $cx $cy $ax $ay $bx $by) -lt $PATH_HALF_WIDTH) {
                        $tileKind = "dirt"; break
                    }
                }
                if ($tileKind -eq "dirt") { break }
            }
        }

        # 3. River (lowest priority — only if nothing else claimed this tile)
        if ($tileKind -eq "grass") {
            $dist_river = [Math]::Abs($cx - $river_x_here)
            if ($dist_river -lt 75) {
                if ($on_bridge_row) {
                    $tileKind = "dirt"   # bridge deck across river
                } else {
                    $tileKind = "water"
                }
            }
        }

        switch ($tileKind) {
            "grass" {
                $gc = $grassCells[$rng.Next($grassCells.Count)]
                $g.DrawImage($grassImg, $dst, $gc, [System.Drawing.GraphicsUnit]::Pixel)
            }
            "dirt"  { $g.DrawImage($soilImg,  $dst, $dirtRect,  [System.Drawing.GraphicsUnit]::Pixel) }
            "water" { $g.DrawImage($waterImg, $dst, $waterRect, [System.Drawing.GraphicsUnit]::Pixel) }
        }
    }
}

$bmp.Save($OUTPATH, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
$grassImg.Dispose(); $waterImg.Dispose(); $soilImg.Dispose()
Write-Output "Wrote $OUTPATH  ($W x $H, $COLS x $ROWS tiles)"
