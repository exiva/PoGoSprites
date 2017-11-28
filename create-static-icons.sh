#!/bin/bash

# Path leading to cloned PogoAssets (https://github.com/ZeChrales/PogoAssets) repository.
ASSETS_ROOT="../PogoAssets"

# The target icon size (width and height)
# RocketMap uses an icon size of 80 pixels.
ICON_SIZE=96

# Apply sharpening to the final image (will take some time)
# 0 means "no sharpening". Values in between are possible.
SHARPEN_SIGMA=1

# =========================================

echo "Creating static icons for Pokemon."
echo "Target icon size is ${ICON_SIZE}x${ICON_SIZE} pixels."

# Create/clear output folder
mkdir -p out
rm out/*.png

echo Converting Icons

for file in $ASSETS_ROOT/decrypted_assets/pokemon_icon_*_00.png
do
    bname=$(basename $file)

    # Trim and resize
    convert $file \
        -fuzz 0.5% -trim +repage \
        -resize ${ICON_SIZE}x${ICON_SIZE}\> \
        -sharpen 0x${SHARPEN_SIGMA} \
        -background none -gravity center -extent ${ICON_SIZE}x${ICON_SIZE} \
        out/$bname
done

echo "Done."
exit
