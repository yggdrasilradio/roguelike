#!/usr/bin/python2

from PIL import Image, ImageDraw
import random
import sys

HEIGHT = 240
WIDTH = 240

XSPACING = 17
YSPACING = 12

def CreateObject(x, y, xdelta, ydelta):
    
    xchoices = []
    for xvalue in range(x - xdelta + 1, x + xdelta):
        if xvalue != x:
            xchoices.append(xvalue)
    ychoices = []
    for yvalue in range(y - ydelta + 1, y + ydelta):
        if yvalue != y:
            ychoices.append(yvalue)
    if random.random() < 0.4:
        objx = random.choice(xchoices)
        objy = random.choice(ychoices)
        draw.point((objx, objy), fill="blue")
    return

def GenerateMaze(x, y):

    # Mark the current cell as a path
    maze[y][x] = " "
    random.shuffle(directions)  # Randomize directions for the maze

    for dx, dy in directions:
        nx, ny = x + 2 * dx, y + 2 * dy

        # Check if the new position is within bounds and unvisited
        if 1 <= nx < 2 * ncolumns and 1 <= ny < 2 * nrows and maze[ny][nx] == "#":
            maze[y + dy][x + dx] = " "  # Carve a path to the next cell
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
                        draw.point((xwall1, ycenter), fill="black") # break through wall
                        draw.line((xwall1, ycenter - 1, xwall2, ycenter - 1), fill="white")
                        draw.line((xwall1, ycenter + 1, xwall2, ycenter + 1), fill="white")
                        draw.point((xwall2, ycenter), fill="black") # break through wall
                        break;
            break;
    return

def NorthExit(xcenter, ycenter):

    # Search for the rightmost wall of this room
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
    draw.rectangle((xcenter - xdelta, ycenter - ydelta, xcenter + xdelta, ycenter + ydelta), fill="black", outline="white")
    CreateObject(xcenter, ycenter, xdelta, ydelta)
    return;

if len(sys.argv) == 1:
	filename = "map.gif"
else:
	filename = sys.argv[1]

# Initialize image
image = Image.new("RGB", (HEIGHT, WIDTH), "black")
draw = ImageDraw.Draw(image)

# Color swatches
draw.point((0, 0), fill="black")
draw.point((1, 0), fill="white")
draw.point((2, 0), fill="blue")
draw.point((3, 0), fill="red")
draw.point((4, 0), fill="green")

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
homex = centerx * 2 - 1
homey = centery * 2 - 1
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

image.save(filename, "GIF")

