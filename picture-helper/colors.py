#!anaconda

from PIL import Image
import sys
import scipy
import scipy.cluster
import scipy.misc
from pprint import pprint
import webcolors
from webcolors import *
from operator import itemgetter


NUM_CLUSTERS = 5

basewidth = 500
image = Image.open(sys.argv[1])
wpercent = (basewidth/float(image.size[0]))
hsize = int((float(image.size[1])*float(wpercent)))
image = image.resize((basewidth,hsize), Image.NEAREST).convert('P', )
image = image.quantize(NUM_CLUSTERS).convert('RGB')


# Convert image into array of values for each point.
array = scipy.misc.fromimage(image)
shape = array.shape

# Reshape array of values to merge color bands.
if len(shape) > 2:
    array = array.reshape(scipy.product(shape[:2]), shape[2])

# Get NUM_CLUSTERS worth of centroids.
codes, _ = scipy.cluster.vq.kmeans(array, NUM_CLUSTERS)

# Pare centroids, removing blacks and whites and shades of really dark and really light.
original_codes = codes
for low, hi in [(60, 200), (35, 230), (10, 250)]:
    codes = scipy.array([code for code in codes 
                         if not ((code[0] < low and code[1] < low and code[2] < low) or
                                 (code[0] > hi  and code[1] > hi  and code[2] > hi))])
    if not len(codes):
        codes = original_codes
    else:
        break

# Assign codes (vector quantization). Each vector is compared to the centroids
# and assigned the nearest one.
vectors, _ = scipy.cluster.vq.vq(array, codes)

# Count occurences of each clustered vector.
counts, bins = scipy.histogram(vectors, len(codes))

# Show colors for each code in its hex value.
total = scipy.sum(counts)
color_dist = zip(codes, [float(count/float(total)) for count in counts])
color_dist = sorted(color_dist, key=itemgetter(1), reverse=True)

def closest_colour(requested_colour):
    min_colours = {}
    for key, name in webcolors.css3_hex_to_names.items():
        r_c, g_c, b_c = webcolors.hex_to_rgb(key)
        rd = (r_c - requested_colour[0]) ** 2
        gd = (g_c - requested_colour[1]) ** 2
        bd = (b_c - requested_colour[2]) ** 2
        min_colours[(rd + gd + bd)] = name
    return min_colours[min(min_colours.keys())]

for color, dist in color_dist:
    print "%s: %s: %s " % (closest_colour(color), rgb_to_hex(color), dist)

# Find the most frequent color, based on the counts.
index_max = scipy.argmax(counts)
peak = codes[index_max]
color = ''.join(chr(c) for c in peak).encode('hex')