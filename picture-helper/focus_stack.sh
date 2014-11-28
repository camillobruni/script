#!/bin/bash

# -m Optimize field of view for all images, except for first.
# 		Useful for aligning focus stacks with slightly different magnification.
# -c number of control points per grid square
# -g number of grid elements * grid elements
# -a prefix
/Applications/Hugin/HuginTools/align_image_stack -v -m -g 6 -c 8 -a ais_ $@

/Applications/Hugin/HuginTools/enfuse -o result.tif --exposure-weight=0 --saturation-weight=0 --contrast-weight=1 --hard-mask ais_*
