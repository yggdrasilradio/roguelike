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
RED = pix[2, 0]
GREEN = pix[3, 0]
BLUE = pix[4, 0]
CYAN = pix[5, 0]
MAGENTA = pix[6, 0]
YELLOW = pix[7, 0]
ORANGE = pix[8, 0]
GRAY = pix[9, 0]
MAROON = pix[10, 0]
CRIMSON = pix[11, 0]

# Remove color swatches
for x in range(1, 12):
	pix[x, 0] = BLACK

width = img.size[0]
height = img.size[1]

print "WIDTH = " + str(width)
print "HEIGHT = " + str(height)

# Horizontal lines
print
print "* List of horizontal lines"
print "hlist "
lines = []
for y in range(0, height):
    flag = 0
    for x in range(0, width):
        color = pix[x, y]
        if color == WHITE and flag == 0:
            # Start of line
            flag = 1
            x1 = x
            y1 = y
        elif color != WHITE and flag == 1:
            # end of line
            length = x - x1
            flag = 0
            if length > 1:
                lines.append({"x1": x1, "y1": y1, "length": length})

for line in sorted(lines, key=lambda line: (line["x1"], line["y1"])):
    x1 = line["x1"]
    y1 = line["y1"]
    length = line["length"]
    print ' fcb ' + str(x1 + 1) + ',' + str(y1 + 1) + ',' + str(x1 + length + 1)

print " fdb $ffff"

print

# Vertical lines
print "* List of vertical lines"
print "vlist"
lines = []
for x in range(0, width):
    flag = 0
    for y in range(0, height):
        color = pix[x, y]
        if color == WHITE and flag == 0:
            # start of line
            flag = 1
            x1 = x
            y1 = y
        elif color != WHITE and flag == 1:
            # end of line
            length = y - y1
            flag = 0
            if length > 1:
                lines.append({"x1": x1, "y1": y1, "length": length})

for line in sorted(lines, key=lambda line: (line["y1"], line["x1"])):
    x1 = line["x1"]
    y1 = line["y1"]
    length = line["length"]
    print ' fcb ' + str(x1 + 1) + ',' + str(y1 + 1) + ',' + str(y1 + length + 1)

print " fdb $ffff"
