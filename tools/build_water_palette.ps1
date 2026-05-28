# Builds a clean 32-grid water palette atlas for the grasslands TileSet.
# Cell (0,0) = full water (frame 1 of the animated water tile).
# Cells (1,0)..(7,3) = river/bank transition tiles, sampled as frame 1 of
# successive "Tile N" sprites from the river-orientation folder.
# Output: art/biomes/grasslands/water_palette.png  (256x128, 8x4 cells).

Add-Type -AssemblyName System.Drawing

$SRC = "C:\Users\nolan\OneDrive\Desktop\Map Tileset\ERW - Grass Land 2.0 v2.0\Tilesets\Platform - grass to water"
$OUT = Join-Path $PSScriptRoot "..\art\biomes\grasslands\water_palette.png"
$OUT = [System.IO.Path]::GetFullPath($OUT)

$COLS = 8; $ROWS = 4; $CELL = 32
$W = $COLS * $CELL; $H = $ROWS * $CELL

$bmp = New-Object System.Drawing.Bitmap $W, $H, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.PixelOffsetMode  = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.Clear([System.Drawing.Color]::Transparent)

function PasteCell([int]$col, [int]$row, [string]$file) {
    if (-not (Test-Path $file)) { return $false }
    $src = [System.Drawing.Image]::FromFile($file)
    $script:g.DrawImage($src, ($col * $script:CELL), ($row * $script:CELL), $script:CELL, $script:CELL)
    $src.Dispose()
    return $true
}

# Cell (0,0) — full water
PasteCell 0 0 (Join-Path $SRC "water full tile - sprites\water-full tile- frame1.png") | Out-Null

# Build a numerically-sorted list of "Tile N" base names (frame 1 only).
# Filenames look like:  "Tile 1 - frame 1.png", "Tile 12 - 1 - frame 1.png", etc.
$river_dir = Join-Path $SRC "water to grass(transparency)- sprites"
$frame1_files = Get-ChildItem -LiteralPath $river_dir -Filter "*frame 1.png" | Sort-Object {
    # Sort by the integer right after "Tile ", then by any sub-variant number.
    if ($_.Name -match "^Tile\s+(\d+)(?:\s*-\s*(\d+))?\s*-\s*frame") {
        $sub = 0
        if (-not [string]::IsNullOrEmpty($matches[2])) { $sub = [int]$matches[2] }
        [int]$matches[1] * 100 + $sub
    } else { 99999 }
}

# Paste up to 31 river tiles starting at cell (1,0)
$slot = 1
foreach ($f in $frame1_files) {
    if ($slot -ge ($COLS * $ROWS)) { break }
    $col = $slot % $COLS
    $row = [int]($slot / $COLS)
    PasteCell $col $row $f.FullName | Out-Null
    $slot++
}

$bmp.Save($OUT, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output "Wrote $OUT ($W x $H) - $slot cells filled"
