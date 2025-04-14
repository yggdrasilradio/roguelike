#!/usr/bin/python2

from PIL import Image, ImageDraw
import random
import sys

HEIGHT = 240
WIDTH = 240

XSPACING = 17
YSPACING = 12

def CreateBarrier(doorcolor, keycolor):

	roomdeltas = {(xcenter, ycenter): (xdelta, ydelta) for xcenter, ycenter, xdelta, ydelta in roomlist}
	border = random.randint(10, len(pathlist) - 10)
	# Create door
	for i in range(border, len(pathlist)):
		x, y, xcenter1, ycenter = pathlist[i]
		c1 = maze[y][x + 1]
		c2 = maze[y][x - 1]
		if c1 == ' ':
			# Put a door in the corridor to the right
			xdelta1, ydelta1 = roomdeltas.get((xcenter1, ycenter), None)
			xcenter2 = xcenter1 + XSPACING
			xdelta2, ydelta2 = roomdeltas.get((xcenter2, ycenter), None)
			wall1x = xcenter1 + xdelta1
			wall2x = xcenter2 - xdelta2
			objx = xcenter1 + xdelta1 + (wall2x - wall1x) / 2
			draw.point((objx, ycenter), fill=doorcolor)
			break;
		elif c2 == ' ':
			# Put a door in the corridor to the left
			xdelta1, ydelta1 = roomdeltas.get((xcenter1, ycenter), None)
			xcenter2 = xcenter1 - XSPACING
			xdelta2, ydelta2 = roomdeltas.get((xcenter2, ycenter), None)
			wall1x = xcenter1 - xdelta1
			wall2x = xcenter2 + xdelta2
			objx = xcenter1 - xdelta1 - (wall1x - wall2x) / 2
			draw.point((objx, ycenter), fill=doorcolor)
			break;

	# Create key for that door
	x, y, xcenter, ycenter = random.choice(pathlist[:border])
	xdelta, ydelta = roomdeltas.get((xcenter, ycenter), None)
	CreateObject(xcenter, ycenter, xdelta, ydelta, keycolor)

def CreateObject(x, y, xdelta, ydelta, objcolor):

    xchoices = []
    for xvalue in range(x - xdelta + 1, x + xdelta):
        if xvalue != x:
            xchoices.append(xvalue)
    ychoices = []
    for yvalue in range(y - ydelta + 1, y + ydelta):
        if yvalue != y:
            ychoices.append(yvalue)
    while True:
        objx = random.choice(xchoices)
        objy = random.choice(ychoices)
        color = image.getpixel((objx, objy))
        if color == (0, 0, 0):
            draw.point((objx, objy), fill=objcolor)
            break
    return

def GenerateMaze(x, y):

    # Mark the current cell as visited
    maze[y][x] = " "
    random.shuffle(directions)  # Randomize directions for the maze

    for dx, dy in directions:
        nx, ny = x + 2 * dx, y + 2 * dy

        # Check if the new position is within bounds and unvisited
        if 1 <= nx < 2 * ncolumns and 1 <= ny < 2 * nrows and maze[ny][nx] == "#":
            maze[y + dy][x + dx] = " "  # Visit the next cell
	    xcenter = 10 + (int(nx / 2)) * XSPACING
	    ycenter = 10 + (int(ny / 2)) * YSPACING
	    pathlist.append((nx, ny, xcenter, ycenter))
            GenerateMaze(nx, ny)  # Recurse to generate the maze from the next cell

def EastExit(xcenter, ycenter):

    # Search for the rightmost wall of this room
    for xwall1 in range(xcenter + 1, WIDTH):
        if image.getpixel((xwall1, ycenter - 1)) != (0, 0, 0):
            # x now points to rightmost wall
            # does exit already exist?
            if image.getpixel((xwall1, ycenter)) != (0, 0, 0):
                # Exit doesn't exist yet
                # Find the leftmost wall of next room
                for xwall2 in range(xwall1 + 1, min(xwall1 + XSPACING, WIDTH)):
                    if image.getpixel((xwall2, ycenter - 1)) != (0, 0, 0):
                        # Next room found, now draw the exit
                        draw.point((xwall1, ycenter), fill="black") # Break through wall
                        draw.line((xwall1, ycenter - 1, xwall2, ycenter - 1), fill="white")
                        draw.line((xwall1, ycenter + 1, xwall2, ycenter + 1), fill="white")
                        draw.point((xwall2, ycenter), fill="black") # break through wall
                        break;
            break;
    return

def NorthExit(xcenter, ycenter):

    # Search for the highest wall of this room
    for ywall1 in range(ycenter - 1, 0, -1):
        if image.getpixel((xcenter - 2, ywall1)) != (0, 0, 0):
            # ywall1 now points to upper wall
            # does exit already exist?
            if image.getpixel((xcenter, ywall1)) != (0, 0, 0):
                # Exit doesn't exist yet
                # Find the bottom wall of next room
                for ywall2 in range(ywall1 - 1, max(ywall1 - YSPACING, 0), -1):
                    if image.getpixel((xcenter - 2 , ywall2)) != (0, 0, 0):
                        # Next room found, now draw the exit
                        draw.line((xcenter - 1, ywall2, xcenter + 1, ywall2), fill="black") # break through wall
                        draw.line((xcenter - 2, ywall2, xcenter - 2, ywall1), fill="white")
                        draw.line((xcenter + 2, ywall2, xcenter + 2, ywall1), fill="white")
                        draw.line((xcenter - 1, ywall1, xcenter + 1, ywall1), fill="black") # break through wall
                        break;
            break;
    return

def DrawRoom(xcenter, ycenter):
    xdeltas = [3, 4, 5, 6]
    ydeltas = [2, 3, 4]
    xdelta = random.choice(xdeltas)
    ydelta = random.choice(ydeltas)
    draw.rectangle((xcenter - xdelta, ycenter - ydelta, xcenter + xdelta, ycenter + ydelta), outline="white")
    roomlist.append((xcenter, ycenter, xdelta, ydelta))
    return;

if len(sys.argv) == 1:
	filename = "map.gif"
else:
	filename = sys.argv[1]

# Room list
roomlist = []

# Path list
pathlist = []

# Initialize image
image = Image.new("RGB", (HEIGHT, WIDTH), "black")
draw = ImageDraw.Draw(image)

# Color swatches
draw.point((0, 0), fill="black")	# BACKGROUND
draw.point((1, 0), fill="white")	# WALLS
draw.point((2, 0), fill="red")		# DOOR1
draw.point((3, 0), fill="green")	# KEY1
draw.point((4, 0), fill="blue")		# DOOR2
draw.point((5, 0), fill="cyan")		# KEY2
draw.point((6, 0), fill="magenta")	# DOOR3
draw.point((7, 0), fill="yellow")	# GOLD
draw.point((8, 0), fill="orange")	# KEY3
draw.point((9, 0), fill="gray")		# DOOR4
draw.point((10, 0), fill="maroon")	# KEY4

# How many rooms will fit?
ncolumns = 0
for x in range(10, WIDTH - XSPACING, XSPACING):
    ncolumns += 1
    nrows = 0
    for y in range(10, HEIGHT - YSPACING, YSPACING):
        nrows += 1

# Initialize maze
maze = [["#"] * (2 * ncolumns + 1) for _ in range(2 * nrows + 1)]
directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

# Suppress some rooms randomly
centerx = int(ncolumns / 2)
centery = int(nrows / 2)
homex = centerx * 2 + 1
homey = centery * 2 + 1
for i in range(1, 40):
    row = random.choice(range(1, len(maze), 2))
    column = random.choice(range(1, len(maze[0]), 2))
    if row != homey and column != homex:
        maze[row][column] = "X"

# Generate maze, starting from the center
GenerateMaze(homex, homey)

# Draw rooms
column = -1
for x in range(10, WIDTH - XSPACING, XSPACING):
    column += 2
    row = -1
    for y in range(10, HEIGHT - YSPACING, YSPACING):
        row += 2
        if maze[row][column] == " ":
            DrawRoom(x, y)

# Print the maze
for y in range(0, nrows * 2 + 1):
    for x in range(0, ncolumns * 2 + 1):
        sys.stdout.write(maze[y][x])
    print

# Draw maze exits
column = -1
for x in range(10, WIDTH - XSPACING, XSPACING):
    column += 2
    row = -1
    for y in range(10, HEIGHT - YSPACING, YSPACING):
        row += 2
        if maze[row][column] != "X":
            if maze[row][column + 1] != "#":
                EastExit(x, y)
            if maze[row - 1][column] != "#":
                NorthExit(x, y)

# Create doors and keys
CreateBarrier("red", "green")
CreateBarrier("blue", "cyan")
CreateBarrier("magenta", "orange")
CreateBarrier("gray", "maroon")

# Create objects
nrooms = len(roomlist)
print(str(nrooms) + " rooms generated")
nobjects = int(nrooms / 2)
for _ in range(0, nobjects):
    xcenter, ycenter, xdelta, ydelta = random.choice(roomlist)
    roomlist.remove((xcenter, ycenter, xdelta, ydelta))
    CreateObject(xcenter, ycenter, xdelta, ydelta, "yellow")
print(str(nobjects) + " objects generated")

# Save map
image.save(filename, "GIF")

