#!/usr/bin/python2

import sys

from PIL import Image

if len(sys.argv) == 1:
	filename = "map.gif"
else:
	filename = sys.argv[1]
img = Image.open(filename)

pix = img.load()

BLACK = pix[0, 0]
WHITE = pix[1, 0]
BLUE = pix[2, 0]
RED = pix[3, 0]
GREEN = pix[4, 0]
for x in range(1, 5):
	pix[x, 0] = BLACK

width = img.size[0]
height = img.size[1]

# Objects
n = 0
print
print "* List of objects"
print "objtable"
lines = []
for y in range(0, height):
    for x in range(0, width):
        color = pix[x, y]
        if color == BLUE:
	    lines.append({"x": x, "y": y, "objtype": "$"})
	    n = n + 3

for line in sorted(lines, key=lambda line: (line["x"], line["y"])):
    x = line["x"]
    y = line["y"]
    objtype = line["objtype"]
    print ' fcb ' + str(x + 1) + ',' + str(y + 1)
    print ' fcc /' + objtype + '/'

print " fdb $ffff"

print

print "objs"
print " rmb " + str(n + 2)
