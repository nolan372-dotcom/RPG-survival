# Crops just the ENEMY CAMP area from the rendered .tmx preview so we can
# see the placed tents/campfire/bones up close.

Add-Type -AssemblyName System.Drawing
$ROOT = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$SRC = Join-Path $PSScriptRoot "grasslands_tmx_preview.png"
$OUTPATH = Join-Path $PSScriptRoot "camp_close_up.png"

# Camp moved east to canvas (1780, 1630), radius 380 → crop 1100x1000 around it
$cx = 1780; $cy = 1630
$size = 1100
$srcRect = New-Object System.Drawing.Rectangle ($cx - $size/2), ($cy - $size/2), $size, $size

$src = [System.Drawing.Bitmap]::FromFile($SRC)
$bmp = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$dstRect = New-Object System.Drawing.Rectangle 0, 0, $size, $size
$g.DrawImage($src, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$bmp.Save($OUTPATH, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose(); $src.Dispose()
Write-Output "Wrote $OUTPATH"
