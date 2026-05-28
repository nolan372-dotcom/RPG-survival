# Saves a labeled preview of the terrain sheet (or any region) at 4x zoom with
# a grid + (col,row) coords on every cell so I can identify which atlas cells
# contain plain grass, plain dirt, etc. by eye.

Add-Type -AssemblyName System.Drawing

$SRC  = (Resolve-Path (Join-Path $PSScriptRoot "..\art\biomes\grasslands\terrain.png")).Path
$OUTPATH = Join-Path $PSScriptRoot "terrain_preview_labeled.png"
$CELL = 32
$ZOOM = 4
# Region to preview (in cells)
$COL0 = 0; $ROW0 = 0
$COLS = 16; $ROWS = 16

$src = [System.Drawing.Bitmap]::FromFile($SRC)
$w_px = $COLS * $CELL * $ZOOM
$h_px = $ROWS * $CELL * $ZOOM
$bmp = New-Object System.Drawing.Bitmap $w_px, $h_px, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::Half

# Black backdrop so transparent cells are visible
$g.Clear([System.Drawing.Color]::FromArgb(255, 30, 30, 35))

# Draw the source region zoomed
$srcRect = New-Object System.Drawing.Rectangle ($COL0 * $CELL), ($ROW0 * $CELL), ($COLS * $CELL), ($ROWS * $CELL)
$dstRect = New-Object System.Drawing.Rectangle 0, 0, $w_px, $h_px
$g.DrawImage($src, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

# Grid lines
$gridPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 255, 255, 0)), 1
for ($c = 0; $c -le $COLS; $c++) { $x = $c * $CELL * $ZOOM; $g.DrawLine($gridPen, $x, 0, $x, $h_px) }
for ($r = 0; $r -le $ROWS; $r++) { $y = $r * $CELL * $ZOOM; $g.DrawLine($gridPen, 0, $y, $w_px, $y) }
$gridPen.Dispose()

# Cell coord labels (col,row) in top-left of each cell
$font = New-Object System.Drawing.Font "Consolas", 12, ([System.Drawing.FontStyle]::Bold)
$shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 0, 0, 0))
$fg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 0))
for ($r = 0; $r -lt $ROWS; $r++) {
    for ($c = 0; $c -lt $COLS; $c++) {
        $label = "$($COL0 + $c),$($ROW0 + $r)"
        $x = $c * $CELL * $ZOOM + 3
        $y = $r * $CELL * $ZOOM + 3
        $g.DrawString($label, $font, $shadow, ($x + 1), ($y + 1))
        $g.DrawString($label, $font, $fg, $x, $y)
    }
}

$bmp.Save($OUTPATH, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose(); $src.Dispose()
Write-Output "Wrote $OUTPATH  ($w_px x $h_px)"
