#!/usr/bin/python2

import PIL.ImageColor

for name, code in PIL.ImageColor.colormap.iteritems():
    print("{:<30} : {}".format(name, code))


