# Sample a 32x32 dirt tile from various locations of fertilized soil.png and
# tile each sample into a 3x3 preview so I can see which sample point gives
# the cleanest tilable dirt (no white bg, no grass edges).

Add-Type -AssemblyName System.Drawing
$SRC = "C:\Users\nolan\OneDrive\Desktop\Map Tileset\ERW - Grass Land 2.0 v2.0\Tilesets\fertilized soil.png"
$OUTPATH = Join-Path $PSScriptRoot "dirt_samples.png"

$soil = [System.Drawing.Bitmap]::FromFile($SRC)
# Try a few sample points (px coords into the soil sheet)
$samples = @(
    @{ name="sx=80,sy=64";    x=80;  y=64  },
    @{ name="sx=128,sy=64";   x=128; y=64  },
    @{ name="sx=200,sy=80";   x=200; y=80  },
    @{ name="sx=300,sy=80";   x=300; y=80  },
    @{ name="sx=450,sy=80";   x=450; y=80  },
    @{ name="sx=80,sy=140";   x=80;  y=140 },
    @{ name="sx=200,sy=140";  x=200; y=140 },
    @{ name="sx=450,sy=140";  x=450; y=140 }
)

# Each preview = 3x3 tiles of the sample = 96x96, plus padding + label
$CELL = 32
$TILES = 3
$PADX = 12
$PADY = 28
$cellPxW = $CELL * $TILES + $PADX * 2
$cellPxH = $CELL * $TILES + $PADY + $PADX
$cols = 4
$rows = [int][Math]::Ceiling($samples.Count / $cols)
$W = $cellPxW * $cols
$H = $cellPxH * $rows

$bmp = New-Object System.Drawing.Bitmap $W, $H, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.Clear([System.Drawing.Color]::FromArgb(255, 40, 40, 45))

$font = New-Object System.Drawing.Font "Consolas", 11, ([System.Drawing.FontStyle]::Bold)
$labelBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)

for ($i = 0; $i -lt $samples.Count; $i++) {
    $s = $samples[$i]
    $col = $i % $cols
    $row = [int]($i / $cols)
    $px = $col * $cellPxW + $PADX
    $py = $row * $cellPxH + $PADY
    # Tile the 32x32 sample into 3x3
    for ($ty = 0; $ty -lt $TILES; $ty++) {
        for ($tx = 0; $tx -lt $TILES; $tx++) {
            $srcRect = New-Object System.Drawing.Rectangle $s.x, $s.y, $CELL, $CELL
            $dstRect = New-Object System.Drawing.Rectangle ($px + $tx * $CELL), ($py + $ty * $CELL), $CELL, $CELL
            $g.DrawImage($soil, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
        }
    }
    # Label below
    $g.DrawString($s.name, $font, $labelBrush, $px, ($py + $CELL * $TILES + 2))
}

$bmp.Save($OUTPATH, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose(); $soil.Dispose()
Write-Output "Wrote $OUTPATH ($W x $H)"
