# Generates art/biomes/grasslands/grasslands.tmx as a BLANK CANVAS with all
# 19 ERW Grass Land 2.0 atlas tilesets loaded as paint palettes.
#
# Three empty tile layers (terrain / props / overlay) + one empty object
# layer (points_of_interest). No painted tiles — start from scratch in Tiled.

$ROOT     = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$OUTPATH  = Join-Path $ROOT "art\biomes\grasslands\grasslands.tmx"
$TSX_DIR  = Join-Path $ROOT "art\biomes\grasslands\gl2\tilesets"

$MAP_W = 80   # tiles
$MAP_H = 80
$TILE = 32

# Discover every .tsx in gl2/tilesets and assign sequential firstgids.
# Each tileset gets enough GID space for its tilecount + 1 buffer.
$tsxFiles = Get-ChildItem -LiteralPath $TSX_DIR -Filter "*.tsx" | Sort-Object Name

$gid = 1
$tsxRefs = New-Object System.Collections.Generic.List[string]
foreach ($f in $tsxFiles) {
    [xml]$ts = Get-Content -LiteralPath $f.FullName -Encoding UTF8
    $tilecount = [int]$ts.tileset.tilecount
    if ($tilecount -le 0) { $tilecount = 1 }
    # Path written into .tmx is RELATIVE to the .tmx location.
    # .tmx is at art/biomes/grasslands/grasslands.tmx
    # .tsx is at art/biomes/grasslands/gl2/tilesets/<name>.tsx
    # Relative: "gl2/tilesets/<name>.tsx"
    $rel = "gl2/tilesets/" + $f.Name
    $tsxRefs.Add(' <tileset firstgid="' + $gid + '" source="' + $rel + '"/>')
    $gid += $tilecount + 16   # buffer so editing tsx tile counts doesn't shift others
}
$tsxXml = $tsxRefs -join "`n"

# Empty CSV (all zeros) for each tile layer
$emptyRow = (("0," * ($MAP_W - 1)) + "0")
$emptyRowsList = New-Object System.Collections.Generic.List[string]
for ($r = 0; $r -lt $MAP_H; $r++) {
    if ($r -eq $MAP_H - 1) { $emptyRowsList.Add($emptyRow) } else { $emptyRowsList.Add($emptyRow + ",") }
}
$emptyCsv = "`n" + ($emptyRowsList -join "`n") + "`n"

$tmx = @"
<?xml version="1.0" encoding="UTF-8"?>
<map version="1.10" tiledversion="1.11.2" orientation="orthogonal" renderorder="right-down" width="$MAP_W" height="$MAP_H" tilewidth="$TILE" tileheight="$TILE" infinite="0" nextlayerid="5" nextobjectid="1">
$tsxXml
 <layer id="1" name="terrain" width="$MAP_W" height="$MAP_H">
  <data encoding="csv">$emptyCsv</data>
 </layer>
 <layer id="2" name="props" width="$MAP_W" height="$MAP_H">
  <data encoding="csv">$emptyCsv</data>
 </layer>
 <layer id="3" name="overlay" width="$MAP_W" height="$MAP_H">
  <data encoding="csv">$emptyCsv</data>
 </layer>
 <objectgroup id="4" name="points_of_interest" color="#ffaa00">
 </objectgroup>
</map>
"@

[System.IO.File]::WriteAllText($OUTPATH, $tmx, (New-Object System.Text.UTF8Encoding $false))
Write-Output ("Wrote BLANK " + $OUTPATH + " (" + $MAP_W + "x" + $MAP_H + " tiles, " + $tsxFiles.Count + " tilesets loaded)")
