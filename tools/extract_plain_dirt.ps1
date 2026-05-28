# Extracts a single clean 32x32 plain-dirt tile from the ERW fertilized soil
# sheet. Sample point sx=200, sy=80 — verified clean in preview_dirt_sample.ps1.
# Output: art/biomes/grasslands/plain_dirt.png  (32x32).

Add-Type -AssemblyName System.Drawing
$SRC = "C:\Users\nolan\OneDrive\Desktop\Map Tileset\ERW - Grass Land 2.0 v2.0\Tilesets\fertilized soil.png"
$OUTPATH = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")).Path "art\biomes\grasslands\plain_dirt.png")

$src = [System.Drawing.Bitmap]::FromFile($SRC)
$bmp = New-Object System.Drawing.Bitmap 32, 32, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$srcRect = New-Object System.Drawing.Rectangle 200, 80, 32, 32
$dstRect = New-Object System.Drawing.Rectangle 0, 0, 32, 32
$g.DrawImage($src, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$bmp.Save($OUTPATH, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose(); $src.Dispose()
Write-Output "Wrote $OUTPATH (32x32)"
