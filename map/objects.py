#!/usr/bin/python2

import sys

from PIL import Image

if len(sys.argv) == 1:
	filename = "map.gif"
else:
	filename = sys.argv[1]
img = Image.open(filename)

pix = img.load()

# Color swatches
BLACK = pix[0, 0]
WHITE = pix[1, 0]
BLUE = pix[2, 0]
RED = pix[3, 0]
GREEN = pix[4, 0]

# Remove color swatches
for x in range(1, 5):
	pix[x, 0] = BLACK

width = img.size[0]
height = img.size[1]

# Objects
n = 0
nobjects = 0
print
print "* List of objects"
print "objtable"
objects = []
for y in range(0, height):
    for x in range(0, width):
        color = pix[x, y]
        if color == BLUE:
	    objects.append({"x": x, "y": y, "objtype": "$"})
	    n += 3
	    nobjects += 1

for obj in sorted(objects, key=lambda obj: (obj["x"], obj["y"])):
    x = obj["x"]
    y = obj["y"]
    objtype = obj["objtype"]
    print ' fcb ' + str(x + 1) + ',' + str(y + 1)
    print ' fcc /' + objtype + '/'

print " fdb $ffff"

print

print "NOBJECTS equ " + str(nobjects)

print

print "objs"
print " rmb " + str(n + 2)
