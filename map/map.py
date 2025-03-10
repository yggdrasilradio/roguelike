#!/usr/bin/python2

import sys

from PIL import Image

BLACK = 1
WHITE = 0

arguments = sys.argv
img = Image.open(arguments[1])

pix = img.load()

width = img.size[0]
height = img.size[1]

BLACK = pix[0, 0]

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
        if color <> BLACK and flag == 0:
            # Start of line
            flag = 1
            x1 = x
            y1 = y
        elif color == BLACK and flag == 1:
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
        if color <> BLACK and flag == 0:
            # start of line
            flag = 1
            x1 = x
            y1 = y
        elif color == BLACK and flag == 1:
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
