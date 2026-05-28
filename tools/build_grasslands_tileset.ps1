# Generates data/biome_tilesets/grasslands_tileset.tres for Godot 4.
# Two atlas sources:
#   0 = terrain.png    (scans for non-transparent 32x32 cells, skips empty ones)
#   1 = water_palette.png (all 32 cells, every one is filled)

Add-Type -AssemblyName System.Drawing

$ROOT = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$TERRAIN = Join-Path $ROOT "art\biomes\grasslands\terrain.png"
$WATER   = Join-Path $ROOT "art\biomes\grasslands\water_palette.png"
$OUTDIR  = Join-Path $ROOT "art\biomes\grasslands"
# NOTE: raw Godot TileSet .tres lives next to its textures, NOT under data/.
# The data/ tree is scanned by ContentRegistry expecting wrapper resources
# (BiomeTilesetData etc.) with an `id` property; a raw TileSet triggers a warning.
$OUT     = Join-Path $OUTDIR "grasslands_tileset.tres"

if (-not (Test-Path $OUTDIR)) { New-Item -ItemType Directory -Path $OUTDIR | Out-Null }

$CELL = 32
# A cell is considered non-empty if at least this many of its 1024 pixels
# have alpha > the threshold below. 10% coverage is a generous floor that
# keeps tiles like sparse grass tufts but drops empty padding cells.
$ALPHA_THRESHOLD = 32
$COVERAGE_MIN    = 0.10

function ScanNonEmptyCells([string]$pngPath) {
    $img = [System.Drawing.Bitmap]::FromFile($pngPath)
    $cols = [int]($img.Width  / $CELL)
    $rows = [int]($img.Height / $CELL)
    $cells = New-Object System.Collections.Generic.List[object]
    $rect = New-Object System.Drawing.Rectangle 0, 0, $img.Width, $img.Height
    $data = $img.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $stride = $data.Stride
    $bytes  = New-Object byte[] ($stride * $img.Height)
    [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
    $img.UnlockBits($data)

    $threshold = $script:ALPHA_THRESHOLD
    $minHits   = [int]([Math]::Floor($script:CELL * $script:CELL * $script:COVERAGE_MIN))
    for ($cy = 0; $cy -lt $rows; $cy++) {
        for ($cx = 0; $cx -lt $cols; $cx++) {
            $hits = 0
            $py0 = $cy * $CELL
            $px0 = $cx * $CELL
            for ($yy = 0; $yy -lt $CELL; $yy++) {
                $row = ($py0 + $yy) * $stride + $px0 * 4
                for ($xx = 0; $xx -lt $CELL; $xx++) {
                    # ARGB byte order in Format32bppArgb is B,G,R,A (little-endian)
                    $a = $bytes[$row + $xx * 4 + 3]
                    if ($a -gt $threshold) { $hits++ }
                }
            }
            if ($hits -ge $minHits) { $cells.Add([pscustomobject]@{ x = $cx; y = $cy }) }
        }
    }
    $img.Dispose()
    return @{ cells = $cells; cols = $cols; rows = $rows }
}

Write-Output "Scanning terrain.png..."
$terrainScan = ScanNonEmptyCells $TERRAIN
Write-Output ("  {0}x{1} cells, {2} non-empty" -f $terrainScan.cols, $terrainScan.rows, $terrainScan.cells.Count)

Write-Output "Scanning water_palette.png..."
$waterScan = ScanNonEmptyCells $WATER
Write-Output ("  {0}x{1} cells, {2} non-empty" -f $waterScan.cols, $waterScan.rows, $waterScan.cells.Count)

# Build the .tres ------------------------------------------------------------
$sb = New-Object System.Text.StringBuilder

[void]$sb.AppendLine('[gd_resource type="TileSet" load_steps=4 format=3]')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('[ext_resource type="Texture2D" path="res://art/biomes/grasslands/terrain.png" id="1_terrain"]')
[void]$sb.AppendLine('[ext_resource type="Texture2D" path="res://art/biomes/grasslands/water_palette.png" id="2_water"]')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_terrain"]')
[void]$sb.AppendLine('texture = ExtResource("1_terrain")')
[void]$sb.AppendLine('texture_region_size = Vector2i(32, 32)')
foreach ($c in $terrainScan.cells) {
    [void]$sb.AppendLine(("{0}:{1}/0 = 0" -f $c.x, $c.y))
}
[void]$sb.AppendLine('')
[void]$sb.AppendLine('[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_water"]')
[void]$sb.AppendLine('texture = ExtResource("2_water")')
[void]$sb.AppendLine('texture_region_size = Vector2i(32, 32)')
foreach ($c in $waterScan.cells) {
    [void]$sb.AppendLine(("{0}:{1}/0 = 0" -f $c.x, $c.y))
}
[void]$sb.AppendLine('')
[void]$sb.AppendLine('[resource]')
[void]$sb.AppendLine('tile_size = Vector2i(32, 32)')
[void]$sb.AppendLine('sources/0 = SubResource("TileSetAtlasSource_terrain")')
[void]$sb.AppendLine('sources/1 = SubResource("TileSetAtlasSource_water")')

# Write as UTF-8 (no BOM) so Godot is happy
[System.IO.File]::WriteAllText($OUT, $sb.ToString(), (New-Object System.Text.UTF8Encoding $false))
Write-Output "Wrote $OUT"
