#!/usr/bin/python2

import sys

from PIL import Image

if len(sys.argv) == 1:
	filename = "objects.gif"
else:
	filename = sys.argv[1]
img = Image.open(filename)

pix = img.load()

BLACK = pix[0, 0]

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
        if color != BLACK:
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
