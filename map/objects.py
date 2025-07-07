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
BACKGROUND = pix[0, 0]	# black
WALLS = pix[1, 0]	# white
DOOR1 = pix[2, 0]	# red
KEY1 = pix[3, 0]	# green
DOOR2 = pix[4, 0]	# blue
KEY2 = pix[5, 0]	# cyan
DOOR3 = pix[6, 0]	# magenta
GOLD = pix[7, 0]	# yellow
KEY3 = pix[8, 0]	# orange
DOOR4 = pix[9, 0]	# gray
KEY4 = pix[10, 0]	# maroon
ENEMY = pix[11, 0]	# crimson
POTION = pix[12, 0]	# springgreen
SWORD = pix[13, 0]	# mintcream
SHIELD = pix[14, 0]	# silver
ORB = pix[15, 0]	# steelblue

# Remove color swatches
for x in range(1, 15):
	pix[x, 0] = BACKGROUND

# Text color attributes
TWALLS = 0x00
TSTATUS = 0x08
TPLAYER = 0x10
TGOLD = 0x18
TKEY1 = 0x20
TDOOR1 = 0x20
TKEY2 = 0x28
TDOOR2 = 0x28
TKEY3 = 0x30
TDOOR3 = 0x30
TKEY4 = 0x38
TDOOR4 = 0x38
TENEMY = 0x10
TPOTION = 0x18
TSWORD = 0x18
TSHIELD = 0x18
TORB = 0x18

width = img.size[0]
height = img.size[1]

# Objects: gold, keys, potions, shields, swords
nobjects = 0
ngold = 0
print
print "* List of objects"
print "objtable"
objects = []
for y in range(0, height):
    for x in range(0, width):
        objtype = pix[x, y]
        if objtype == GOLD:
	    objects.append({"x": x, "y": y, "objtype": 0x18*256+TGOLD})
	    nobjects += 1
	    ngold += 1
        elif objtype == KEY1:
	    objects.append({"x": x, "y": y, "objtype": 0x5f*256+TKEY1})
	    nobjects += 1
        elif objtype == KEY2:
	    objects.append({"x": x, "y": y, "objtype": 0x5f*256+TKEY2})
	    nobjects += 1
        elif objtype == KEY3:
	    objects.append({"x": x, "y": y, "objtype": 0x5f*256+TKEY3})
	    nobjects += 1
        elif objtype == KEY4:
	    objects.append({"x": x, "y": y, "objtype": 0x5f*256+TKEY4})
	    nobjects += 1
        elif objtype == POTION:
	    objects.append({"x": x, "y": y, "objtype": 0x1d*256+TPOTION})
	    nobjects += 1
        elif objtype == SWORD:
	    objects.append({"x": x, "y": y, "objtype": 0x5e*256+TSWORD})
	    nobjects += 1
        elif objtype == SHIELD:
	    objects.append({"x": x, "y": y, "objtype": 0x1a*256+TSHIELD})
	    nobjects += 1
        elif objtype == ORB:
	    objects.append({"x": x, "y": y, "objtype": 0x1e*256+TORB})
	    nobjects += 1
for obj in sorted(objects, key=lambda obj: (obj["x"], obj["y"])):
    x = obj["x"]
    y = obj["y"]
    objtype = obj["objtype"]
    print ' fcb ' + str(x + 1) + ',' + str(y + 1)
    print ' fdb $' + format(objtype, 'x')

print ' fdb $ffff'

print
print "NGOLD equ " + str(ngold)
print

# Objects: doors
print '* List of door objects'
print 'doortbl'
ndoors = 0
doors = []
for y in range(0, height):
    for x in range(0, width):
        objtype = pix[x, y]
        if objtype == DOOR1:
	    doors.append({"x": x, "y": y, "objtype": ord('|')*256+TDOOR1})
	    ndoors += 1
        elif objtype == DOOR2:
	    doors.append({"x": x, "y": y, "objtype": ord('|')*256+TDOOR2})
	    ndoors += 1
        elif objtype == DOOR3:
	    doors.append({"x": x, "y": y, "objtype": ord('|')*256+TDOOR3})
	    ndoors += 1
        elif objtype == DOOR4:
	    doors.append({"x": x, "y": y, "objtype": ord('|')*256+TDOOR4})
	    ndoors += 1
for obj in sorted(doors, key=lambda obj: (obj["x"], obj["y"])):
    x = obj["x"]
    y = obj["y"]
    objtype = obj["objtype"]
    print ' fcb ' + str(x + 1) + ',' + str(y + 1)
    print ' fdb $' + format(objtype, 'x')
print ' fdb $ffff'

print

# Objects: enemies
print '* List of enemies'
print 'enemytbl'
nenemies = 0
enemies = []
for ycenter in range(0, height):
    for xcenter in range(0, width):
        objtype = pix[xcenter, ycenter]
        if objtype == ENEMY:
	    xdelta = 0
	    ydelta = 0
	    for x in range(xcenter, xcenter + 20):
		if pix[x, ycenter - 1] == WALLS:
		    break;
		xdelta += 1
	    for y in range(ycenter, ycenter + 20):
		if pix[xcenter - 2, y] == WALLS:
		    break;
		ydelta += 1
	    enemies.append({"x": xcenter, "y": ycenter, "xdelta": xdelta - 1, "ydelta": ydelta - 1})
	    nenemies += 1
for obj in sorted(enemies, key=lambda obj: (obj["x"], obj["y"])):
    x = obj["x"]
    y = obj["y"]
    xdelta = obj["xdelta"]
    ydelta = obj["ydelta"]
    print ' fcb ' + str(x + 1) + ',' + str(y + 1) + ',' + str(xdelta) + ',' + str(ydelta)
print ' fdb $ffff'
