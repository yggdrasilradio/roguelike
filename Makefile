
all:	rogue

rogue: main.asm
	map/map.py map/map.gif > lines.asm
	lwasm -9 -b -o -l redistribute/rogue.bin main.asm > redistribute/rogue.lst
ifneq ($(wildcard /media/share1/COCO/drive0.dsk),)
	decb kill /media/share1/COCO/drive0.dsk,ROGUE.BIN
	decb copy -r -2 -b redistribute/rogue.bin /media/share1/COCO/drive0.dsk,ROGUE.BIN
endif
	rm -f redistribute/rogue.dsk
	decb dskini redistribute/rogue.dsk
	decb copy -r -2 -b redistribute/rogue.bin redistribute/rogue.dsk,ROGUE.BIN
