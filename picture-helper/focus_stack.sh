#!/bin/bash


/Applications/Hugin/HuginTools/align_image_stack -a ais_ $@

/Applications/Hugin/HuginTools/enfuse -o result.tif --wExposure=0 --wSaturation=0 --wContrast=1 --HardMask ais_*
