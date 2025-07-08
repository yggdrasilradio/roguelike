
all:	rogue

rogue:
	map/lines.py map/map.gif > lines.asm
	map/objects.py map/map.gif > objects.asm
	lwasm -9 -b -o -l redistribute/rogue.bin main.asm > redistribute/rogue.lst
ifneq ($(wildcard /media/share1/COCO/drive0.dsk),)
	decb kill /media/share1/COCO/drive0.dsk,ROGUE.BIN
	decb copy -r -2 -b redistribute/rogue.bin /media/share1/COCO/drive0.dsk,ROGUE.BIN
endif
	rm -f redistribute/rogue.dsk
	decb dskini redistribute/rogue.dsk
	decb copy -r -2 -b redistribute/rogue.bin redistribute/rogue.dsk,ROGUE.BIN

create:
	map/create.py map/map.gif
	$(MAKE) rogue
