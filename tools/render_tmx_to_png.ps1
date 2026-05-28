# Renders a Tiled .tmx map to a flattened PNG by parsing the XML and
# stamping each layer's tiles + each object's sprite from the referenced
# .tsx tilesets. Used to convert the ERW Grass Land 2.0 example map into
# our scene's underlay reference.

Add-Type -AssemblyName System.Drawing

# Default: render our project's grasslands.tmx. To render a different file,
# pass it as the first arg: powershell ... render_tmx_to_png.ps1 -TMX "path"
param([string]$TMX = "")
$ROOT = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrEmpty($TMX)) {
    $TMX_PATH = Join-Path $ROOT "art\biomes\grasslands\grasslands.tmx"
} else {
    $TMX_PATH = $TMX
}
$OUTPATH = (Join-Path $ROOT "tools\grasslands_tmx_preview.png")

# Tiled's GID flip bits
$FLIP_H = [uint32]"0x80000000"
$FLIP_V = [uint32]"0x40000000"
$FLIP_D = [uint32]"0x20000000"
$GID_MASK = [uint32]"0x1FFFFFFF"

# --- Parse the .tmx ----------------------------------------------------------
Write-Output "Reading $TMX_PATH"
[xml]$tmxDoc = Get-Content -LiteralPath $TMX_PATH -Encoding UTF8

$mapW = [int]$tmxDoc.map.width        # tiles
$mapH = [int]$tmxDoc.map.height
$tileW = [int]$tmxDoc.map.tilewidth
$tileH = [int]$tmxDoc.map.tileheight
$canvasW = $mapW * $tileW
$canvasH = $mapH * $tileH
Write-Output ("Map: {0}x{1} tiles ({2}x{3} px), tile {4}x{5}" -f $mapW, $mapH, $canvasW, $canvasH, $tileW, $tileH)

$tmxDir = Split-Path -Parent $TMX_PATH

# --- Build a GID -> tile info lookup -----------------------------------------
# Each entry is a hashtable: @{ ImagePath; SrcX; SrcY; SrcW; SrcH }
# Cache loaded Bitmap objects keyed by path to avoid re-loading huge sheets.
$gid_lookup = @{}
$image_cache = @{}

function LoadImage([string]$path) {
    if ($script:image_cache.ContainsKey($path)) { return $script:image_cache[$path] }
    if (-not (Test-Path -LiteralPath $path)) {
        Write-Output ("  WARN: image not found: " + $path)
        return $null
    }
    $img = [System.Drawing.Image]::FromFile($path)
    $script:image_cache[$path] = $img
    return $img
}

foreach ($tsRef in $tmxDoc.map.tileset) {
    $firstgid = [int]$tsRef.firstgid
    $tsxRel = [string]$tsRef.source
    $tsxAbs = [System.IO.Path]::GetFullPath((Join-Path $tmxDir $tsxRel))
    $tsxDir = Split-Path -Parent $tsxAbs

    if (-not (Test-Path -LiteralPath $tsxAbs)) {
        Write-Output ("  WARN: .tsx not found: " + $tsxAbs)
        continue
    }
    [xml]$tsx = Get-Content -LiteralPath $tsxAbs -Encoding UTF8
    $ts = $tsx.tileset
    $tw = [int]$ts.tilewidth
    $th = [int]$ts.tileheight
    $cols = [int]$ts.columns

    if ($cols -gt 0 -and $ts.image -ne $null) {
        # Atlas-style: one big image, tiles indexed left-to-right, top-to-bottom
        $imgRel = [string]$ts.image.source
        $imgAbs = [System.IO.Path]::GetFullPath((Join-Path $tsxDir $imgRel))
        $tilecount = [int]$ts.tilecount
        for ($lid = 0; $lid -lt $tilecount; $lid++) {
            $cx = $lid % $cols
            $cy = [int]($lid / $cols)
            $gid_lookup[$firstgid + $lid] = @{
                Path = $imgAbs; SrcX = $cx * $tw; SrcY = $cy * $th; SrcW = $tw; SrcH = $th
            }
        }
    } else {
        # Collection-of-images style: each <tile> has its own <image>.
        foreach ($tile in $ts.tile) {
            if ($null -eq $tile.image) { continue }
            $lid = [int]$tile.id
            $imgRel = [string]$tile.image.source
            $imgAbs = [System.IO.Path]::GetFullPath((Join-Path $tsxDir $imgRel))
            $iw = [int]$tile.image.width
            $ih = [int]$tile.image.height
            $gid_lookup[$firstgid + $lid] = @{
                Path = $imgAbs; SrcX = 0; SrcY = 0; SrcW = $iw; SrcH = $ih
            }
        }
    }
    Write-Output ("  Loaded tileset firstgid=" + $firstgid + " (" + (Split-Path -Leaf $tsxAbs) + ")")
}
Write-Output ("Total GIDs in lookup: " + $gid_lookup.Count)

# --- Create canvas -----------------------------------------------------------
$bmp = New-Object System.Drawing.Bitmap $canvasW, $canvasH, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
# Start with a deep grass green so missing edges still read as grassland
$g.Clear([System.Drawing.Color]::FromArgb(255, 122, 168, 92))

function StampTile([uint32]$rawGid, [int]$dstX, [int]$dstY, [int]$dstW, [int]$dstH) {
    if ($rawGid -eq 0) { return }
    $flipH = (($rawGid -band $script:FLIP_H) -ne 0)
    $flipV = (($rawGid -band $script:FLIP_V) -ne 0)
    $gid = [int]([uint32]$rawGid -band $script:GID_MASK)
    if (-not $script:gid_lookup.ContainsKey($gid)) { return }
    $info = $script:gid_lookup[$gid]
    $img = LoadImage $info.Path
    if ($null -eq $img) { return }
    $srcRect = New-Object System.Drawing.Rectangle ([int]$info.SrcX), ([int]$info.SrcY), ([int]$info.SrcW), ([int]$info.SrcH)
    if ($flipH -or $flipV) {
        $script:g.TranslateTransform($dstX + $dstW/2, $dstY + $dstH/2)
        $sx = if ($flipH) { -1.0 } else { 1.0 }
        $sy = if ($flipV) { -1.0 } else { 1.0 }
        $script:g.ScaleTransform($sx, $sy)
        $dst = New-Object System.Drawing.Rectangle ([int](-$dstW/2)), ([int](-$dstH/2)), $dstW, $dstH
        $script:g.DrawImage($img, $dst, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
        $script:g.ResetTransform()
    } else {
        $dst = New-Object System.Drawing.Rectangle $dstX, $dstY, $dstW, $dstH
        $script:g.DrawImage($img, $dst, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    }
}

# --- Render tile layers in source order --------------------------------------
foreach ($layer in $tmxDoc.map.layer) {
    $name = [string]$layer.name
    $lw = [int]$layer.width
    $lh = [int]$layer.height
    $csv = [string]$layer.data.'#text'
    # CSV may have whitespace/newlines; split on commas and trim
    $cells = $csv -split ','
    Write-Output ("  Layer '" + $name + "' " + $lw + "x" + $lh + " (" + $cells.Count + " cells)")
    $idx = 0
    for ($ry = 0; $ry -lt $lh; $ry++) {
        for ($cx = 0; $cx -lt $lw; $cx++) {
            $tok = $cells[$idx].Trim()
            $idx++
            if ([string]::IsNullOrEmpty($tok)) { continue }
            $raw = [uint32]$tok
            StampTile $raw ($cx * $tileW) ($ry * $tileH) $tileW $tileH
        }
    }
}

# --- Render object groups (tile objects only) --------------------------------
foreach ($og in $tmxDoc.map.objectgroup) {
    $name = [string]$og.name
    $objCount = 0
    if ($og.object -ne $null) {
        foreach ($obj in $og.object) {
            if ($obj.gid -eq $null) { continue }
            $raw = [uint32]([string]$obj.gid)
            $ox = [double]([string]$obj.x)
            $oy = [double]([string]$obj.y)
            $ow = if ($obj.width)  { [int]([double]([string]$obj.width))  } else { $tileW }
            $oh = if ($obj.height) { [int]([double]([string]$obj.height)) } else { $tileH }
            # Tiled tile-objects anchor at bottom-left, so subtract height for top-left
            StampTile $raw ([int]$ox) ([int]($oy - $oh)) $ow $oh
            $objCount++
        }
    }
    Write-Output ("  ObjectGroup '" + $name + "' (" + $objCount + " tile-objects)")
}

# --- Save --------------------------------------------------------------------
$bmp.Save($OUTPATH, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
foreach ($img in $image_cache.Values) { $img.Dispose() }
Write-Output ("Wrote " + $OUTPATH + " (" + $canvasW + "x" + $canvasH + ")")
