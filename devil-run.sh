#!/bin/bash

INPUT_ROOT="$1"
OUTPUT_ROOT="$2"

# Define function that inverts the mask and converts from binary to RGB
function process-mask {
    env/bin/python -c "from PIL import Image, ImageOps; out = Image.open('$1').convert('RGB'); out = ImageOps.invert(out); out.save('$2')"
}

frames_dir="$INPUT_ROOT/frames"
mkdir "$frames_dir"
cp $INPUT_ROOT/*gt.png "$INPUT_ROOT/frames"

masks_dir="$INPUT_ROOT/masks"
mkdir "$masks_dir"
# Invert masks
for path in $INPUT_ROOT/*mask.png; do
    process-mask "$path" "$masks_dir/$(basename $path)"
done

export PYTHONPATH=
env/bin/python test.py \
    --video "$INPUT_ROOT/frames" \
    --mask "$INPUT_ROOT/masks" \
    --ckpt "checkpoints/sttn.pth" \
    -o "$OUTPUT_ROOT"
