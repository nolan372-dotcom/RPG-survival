# Imports the full ERW Grass Land 2.0 atlas-style tileset library into the
# project as a self-contained "paint palette".
#
# For each chosen .tsx file:
#   1. Reads it, finds its <image source="..."/> reference
#   2. Copies the referenced PNG into art/biomes/grasslands/gl2/sprites/
#   3. Copies the .tsx into art/biomes/grasslands/gl2/tilesets/ with the
#      <image source> rewritten to point at "../sprites/<filename>.png"
#
# Skips collection-style "-sprites" .tsx files (each tile is its own PNG ->
# hundreds of files per tileset) and "-godot" variants (Godot-export
# duplicates of the same content). The atlas .tsx files cover all the same
# tiles via cell coordinates.

$SRC_ROOT = "C:\Users\nolan\OneDrive\Desktop\Map Tileset\ERW - Grass Land 2.0 v2.0"
$TSX_SRC  = Join-Path $SRC_ROOT "TiledMap Editor\Tilesets"

$PROJ_ROOT = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$OUT_TSX   = Join-Path $PROJ_ROOT "art\biomes\grasslands\gl2\tilesets"
$OUT_PNG   = Join-Path $PROJ_ROOT "art\biomes\grasslands\gl2\sprites"

# Ensure output dirs exist
foreach ($d in @($OUT_TSX, $OUT_PNG)) {
    if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

# Curated list — atlas-style tilesets only (each is ONE big PNG of tiles)
$wanted = @(
    "Tileset-Terrain-new grass - transparency.tsx",     # main grass+dirt+walls sheet
    "Tileset - wall1 - transparency.tsx",               # wall1 autotile
    "gl2-Tileset - wall 1-3tiles-transp.tsx",           # wall1 3-tile variant
    "hole1.tsx",                                        # holes set 1
    "hole2.tsx",                                        # holes set 2
    "hole3.tsx",                                        # holes set 3
    "fertilized soil.tsx",                              # dirt soil patches
    "platform - grass(transparency) to water.tsx",      # grass <-> water transitions
    "platform - water to grass(transparency) - river orientation.tsx", # river bends
    "platform - grass(transparency) - coast.tsx",       # grass coast tiles
    "beach - with thick foam.tsx",                      # beach (foamy)
    "beach - no thick foam.tsx",                        # beach (no foam)
    "Beach-transition tiles between coast platform and beach.tsx", # beach transitions
    "fence-straight.tsx",                               # wooden fence (straight)
    "fence-curved.tsx",                                 # wooden fence (curved corners)
    "Atlas-Props-sheet1.tsx",                           # props atlas 1 (barrels, debris)
    "Atlas-Props-sheet2.tsx",                           # props atlas 2 (orc camp stuff)
    "Atlas-Props-sheet3.tsx",                           # props atlas 3 (bridges, skeleton)
    "Atlas-Props-sheet4.tsx"                            # props atlas 4 (crops)
)

$copiedCount = 0
$skippedCount = 0
foreach ($tsxName in $wanted) {
    $tsxPath = Join-Path $TSX_SRC $tsxName
    if (-not (Test-Path -LiteralPath $tsxPath)) {
        Write-Output "  MISSING: $tsxName"
        $skippedCount++
        continue
    }

    [xml]$tsxDoc = Get-Content -LiteralPath $tsxPath -Encoding UTF8
    $imgRel = [string]$tsxDoc.tileset.image.source
    if ([string]::IsNullOrEmpty($imgRel)) {
        Write-Output "  NO IMAGE: $tsxName"
        $skippedCount++
        continue
    }

    # Resolve PNG relative to .tsx location
    $tsxDir = Split-Path -Parent $tsxPath
    $pngAbs = [System.IO.Path]::GetFullPath((Join-Path $tsxDir $imgRel))
    if (-not (Test-Path -LiteralPath $pngAbs)) {
        Write-Output "  PNG MISSING: $imgRel  (resolved to $pngAbs)"
        $skippedCount++
        continue
    }

    # Copy PNG into project
    $pngName = Split-Path -Leaf $pngAbs
    $pngDst = Join-Path $OUT_PNG $pngName
    Copy-Item -LiteralPath $pngAbs -Destination $pngDst -Force

    # Rewrite the .tsx <image source> to the new local path then copy
    $tsxDoc.tileset.image.source = "../sprites/$pngName"
    $tsxDst = Join-Path $OUT_TSX $tsxName
    # Save XML to disk in UTF-8 no-BOM
    $sw = New-Object System.IO.StringWriter
    $xw = New-Object System.Xml.XmlTextWriter($sw)
    $xw.Formatting = 'Indented'
    $tsxDoc.WriteTo($xw)
    [System.IO.File]::WriteAllText($tsxDst, $sw.ToString(), (New-Object System.Text.UTF8Encoding $false))
    $xw.Close(); $sw.Close()

    Write-Output ("  OK  " + $tsxName + " -> " + $pngName)
    $copiedCount++
}

Write-Output ""
Write-Output ("Copied $copiedCount tilesets, skipped $skippedCount")
Write-Output ("PNGs ->  $OUT_PNG")
Write-Output (".tsx ->  $OUT_TSX")
