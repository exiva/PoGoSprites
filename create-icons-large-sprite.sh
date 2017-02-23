#!/bin/bash

# Path relative to current directory where source images are located.
# Icons will be sorted by filename numerically interpreted,
# so that 9.png will be in front of 10.png.
SOURCE_FOLDER="src"

# The target icon size (width and height)
# RocketMap uses an icon size of 80 pixels.
ICON_SIZE=80

# How many icons will be put in one row.
# RocketMap assumes 28 icons in a row.
ICONS_PER_ROW=28

# How thick the black stroke around the icons will be (before resizing to final size).
STROKE_WIDTH=2

# A value of 1 keeps the small icons small and the large ones large
# resulting in tiny icons for small Pokemon.
# A value of 0 shrinks the large icons down to the target size.
# Values in between are possible.
KEEP_PROPORTIONS=0.3

# Apply sharpening to the final sheet (will take some time)
# 0 means "no sharpening". Values in between are possible.
SHARPEN_SIGMA=2

# Additional options for Imagemagick 'convert'
# applied to the sprite sheet before resizing to final size.
# e.g. "-modulate 100,140" to apply 120% saturation
CONVERT_OPTIONS="-modulate 100,120"

# =========================================

# RocketMap requires this many icons in the sheet
TOTAL_ICONS=493

echo "Target icon size is ${ICON_SIZE}px."

MAX_WIDTH=$(identify -format "%w\n" src/*.png | sort -n -r | head -1)
MAX_HEIGHT=$(identify -format "%h\n" src/*.png | sort -n -r | head -1)
MAX_EDGE=$(( $MAX_WIDTH > $MAX_HEIGHT ? $MAX_WIDTH : $MAX_HEIGHT ))
echo "Largest icon has edge ${MAX_EDGE}px."

# Calculate the intermediate size to work with
MID_SIZE=$(echo "$ICON_SIZE + ($MAX_EDGE - $ICON_SIZE) * $KEEP_PROPORTIONS" | bc)
MID_SIZE=$(python -c "from math import ceil; print int(ceil($MID_SIZE))")
(( BORDER_WIDTH = STROKE_WIDTH + 2 ))
(( BORDER_SIZE = MID_SIZE + 2 * BORDER_WIDTH ))
echo "Shrinking bigger icons to size ${MID_SIZE}px before assembling the sheet."

# Create/clear output folder
mkdir -p out
rm out/*.png

echo Converting Icons
i=0
for file in src/*.png
do
    convert $file \
        -trim \
        -resize ${MID_SIZE}x${MID_SIZE}\> \
        -background none -gravity center -extent ${BORDER_SIZE}x${BORDER_SIZE} \
        -background black -alpha background -channel A -blur 0x${STROKE_WIDTH} -level 0,10% \
        out/$(basename $file)
    (( i++ ))
done

echo "Creating blank icons for Generation 3+4"
for (( c=$i+1; c<=$TOTAL_ICONS; c++))
do
    convert -size ${BORDER_SIZE}x${BORDER_SIZE} xc:none out/$c.png
done

echo "Assembling the sheet with ${ICONS_PER_ROW} icons per row into intermediate sheet."
cd out
montage $(ls -1 *.png | sort -g) -mode concatenate -tile ${ICONS_PER_ROW}x -background none icons-intermediate-sprite.png

echo "Resizing (and sharpening) to final sheet."
(( SHEET_WIDTH = ICONS_PER_ROW * ICON_SIZE ))
convert icons-intermediate-sprite.png $CONVERT_OPTIONS -sharpen 0x${SHARPEN_SIGMA} -resize ${SHEET_WIDTH}x icons-large-sprite.png
rm icons-intermediate-sprite.png

echo "Done. Find your sheet at out/icons-large-sprite.png"