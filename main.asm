SCREEN1	equ $4000
SCREEN2	equ $5000
DOORS	equ $6000
ENEMIES	equ $6200
OBJS	equ $6400

	org $0000

textptr	rmb 2 
cursor	rmb 2 ; x, y
origin	rmb 4 ; xorigin, yorigin, xorigin + 80, yorigin + 20
coords	rmb 5 ; x1, y1, x2, y2, length
screen	rmb 2 ; current screen
pscreen	rmb 2 ; previous screen
playerx	rmb 1
playery	rmb 1
number	rmb 2
score	rmb 2
nobjs	rmb 1 ; number of objects left to find
value	rmb 5
key1	rmb 1
key2	rmb 1
key3	rmb 1
key4	rmb 1
nshield	rmb 1
nsword	rmb 1
nfound	rmb 1
vcount	rmb 1
secs	rmb 1
mins	rmb 1
hours	rmb 1
pmsg	rmb 2
timer	rmb 1
kbbusy	rmb 1 ; keyboard busy
player	rmb 2 ; global player coordinates
dead	rmb 1 ; player died flag
health	rmb 1 ; player health

KEYBUF equ $152

	org $E00
start
	* Disable interrupts
	orcc #$50

	* Restore "close file" hook and close file
	ldd #$176
	std $a42e
	jsr $a42d

	* Fast CPU
	sta $ffd9

	* Setup for IRQ
	lda $ff03
	ora #$01 ; enable VSYNC / IRQ
	sta $ff03
	lda #$7e ; set IRQ vector to JMP [IRQ]
	sta $fef7
	ldx #IRQ
	stx $fef8

	* Initialize graphics and MMU
	lbsr initgfx

	* Init viewport to center of map
	ldd #(WIDTH/2-40-7)*256+(HEIGHT/2-9)
	std origin
	ldd #SCREEN1
	std screen
	std textptr

	* Initial player position
	ldd #40*256+10
	std playerx

	* Init health
	lda #100
	sta health

	* Clear score
	clra
	clrb
	std score

	* Clear status message timer and pointer
	sta timer
	std pmsg

	* Clear player died flag
	sta dead

	* Clear keyboard busy timer
	sta kbbusy

	* Clear found object flags
	sta key1
	sta key2
	sta key3
	sta key4
	sta nsword
	sta nshield

	* Clear elapsed time
	sta secs
	sta mins
	sta hours

	* Number of objects
	lda #NOBJECTS
	sta nobjs

	* Initialize gold and key objects
	leax objtable,pcr
	ldy #OBJS
	lbsr tfrxy

	* Initialize door objects
	leax doortbl,pcr
	ldy #DOORS
	lbsr tfrxy

	* Initialize enemy objects
	leax enemytbl,pcr
	ldy #ENEMIES
loop@	ldd ,x++
	std ,y++ ; xpos, ypos
	cmpd #$ffff
	beq exit@
	std ,y++ ; xcenter, ycenter
	ldd ,x++
	std ,y++ ; xdelta, ydelta
	bra loop@
exit@

	* Draw initial frame
	lbsr drawframe

	* Turn on IRQ
	andcc #$ef

	* Idle loop
loop@
	lbsr prtime	; elapsed time
	lbsr keycheck
	tst dead	; end game if player has won or lost
	bne endgame
	tst nobjs
	beq endgame
	cmpa #8	   ; left arrow
	bne notl@
	ldd #$ff00 ; move player left
	lbsr moveplayer
	lbsr drawframe
	bra loop@
notl@
	cmpa #9    ; right arrow
	bne notr@
	ldd #$0100 ; move player right
	lbsr moveplayer
	lbsr drawframe
	bra loop@
notr@
	cmpa #10   ; down arrow
	bne notd@
	ldd #$0001
	lbsr moveplayer ; move player down
	lbsr drawframe
	bra loop@
notd@
	cmpa #94   ; up arrow
	bne notu@
	ldd #$00ff ; move player up
	lbsr moveplayer
	lbsr drawframe
notu@
	bra loop@

* Restart game on any key
endgame
	;jsr [$a000] ; wait for keyup
	;bne endgame
	clra	    ; clear keyboard
	clrb
	std KEYBUF
	std KEYBUF+2
	std KEYBUF+4
	std KEYBUF+6
loop@
	jsr [$a000] ; wait for keydown
	beq loop@
	cmpa #3	    ; is it BREAK?
	lbeq reset  ; exit to BASIC
	cmpa #8	    ; ignore all navigation keys
	beq loop@
	cmpa #9
	beq loop@
	cmpa #10
	beq loop@
	cmpa #94
	beq loop@
	cmpa #'H'
	beq loop@
	cmpa #'J'
	beq loop@
	cmpa #'K'
	beq loop@
	cmpa #'L'
	beq loop@
	lbra start  ; any other key will restart game

tfrxy	ldd ,x++
	std ,y++
	cmpd #$ffff
	bne tfrxy
exit@	rts

* Draw frame
drawframe
	ldd origin
	adda #80
	addb #20
	std origin+2
	sync
	lbsr cls
	lbsr vlines
	lbsr hlines
	lbsr drawdoors
	lbsr drawplayer
	lbsr drawenemies
	lbsr drawobjects
	lbsr status
	lbsr updstatus1
	bsr flipscreen
	rts

flipscreen
	ldd screen	; if screen is 4000
	cmpd #SCREEN1
	bne else@
	ldd #SCREEN1	;	previous screen = 4000
	std pscreen
	ldd #SCREEN2	;	screen = 5000
	std screen
	ldd #$d800	;	display 4000
	bra exit@
else@			; else
	ldd #SCREEN2	;	previous screen = 5000
	std pscreen
	ldd #SCREEN1	;	screen = 4000
	std screen
	ldd #$da00	;	display 5000
exit@	std $ff9d
	rts

* Initialize graphics
initgfx
	* Wait for VSYNC
	sync

	* Set all palettes to black
	clra
	clrb
	std $ffb0
	std $ffb2
	std $ffb4
	std $ffb6
	std $ffb8
	std $ffba
	std $ffbc
	std $ffbe

	* Set graphics mode to 80 columns
	clr $ff9c
	lda #$4e
	sta $ff90
	ldd #$031f
	std $ff98

	* Set graphics memory
	lda #$36	; map MMU $6C000 to $4000
	sta $ffa2
	ldd #$d800	; gfx memory at $6C000 ($4000)
	std $ff9d

	* Set palettes for text
	ldb #27		; cyan	$00	walls
	stb $ffb8
	ldb #54		; amber	$08	status
	stb $ffb9
	ldb #63		; white	$10	player
	stb $ffba
	ldb #63		; white $18	gold
	stb $ffbb
	ldb #52		; white $20	key1, door1
	stb $ffbc
	ldb #25		; blue $28	key2, door2
	stb $ffbd
	ldb #54		; yellow $30	key3, door3
	stb $ffbe
	ldb #45		; magenta $38	key4, door4
	stb $ffbf
	rts

* Text color attributes
WALLS equ $00
STATUS equ $08
PLAYER equ $10
GOLD equ $18
KEY1 equ $20
DOOR1 equ $20
KEY2 equ $28
DOOR2 equ $28
KEY3 equ $30
DOOR3 equ $30
KEY4 equ $38
DOOR4 equ $38

* Clear screen
cls
	ldx screen

	* Clear status area one
	lda #5*2
	pshs a
	ldd #' '*256+STATUS ; space, amber
loop@	std ,x++ ; clear 32 bytes
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	dec ,s
	bne loop@

	* Clear content area
	lda #5*20
	sta ,s
	ldd #' '*256+WALLS
loop@	std ,x++ ; clear 32 bytes
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	dec ,s
	bne loop@

	* Clear status area two
	lda #5*2
	sta ,s
	ldd #' '*256+STATUS ; space, amber
loop@	std ,x++ ; clear 32 bytes
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	std ,x++
	dec ,s
	bne loop@
	
	puls a,pc

* Display a line of text
printline
	pshs u
	ldy textptr
loop@	lda ,u+
	sta ,y++
	bpl loop@
exit@	sty textptr
	puls u,pc

* Position cursor to next line
crlf	ldd cursor
	clra
	incb
	lbsr curspos
	rts

* Position cursor
*
* Entry:
*	A is column 0 to 79
*	B is row 0 to 23
curspos
	std cursor
	lda #80
	mul
	addb cursor
	adca #0
	aslb
	rola
	addd screen
	std textptr
	rts

* Position cursor on previous screen
*
* Entry:
*	A is column 0 to 79
*	B is row 0 to 23
pcurspos
	std cursor
	lda #80
	mul
	addb cursor
	adca #0
	aslb
	rola
	addd pscreen
	std textptr
	rts

* Is point visible in viewport?
*
* Entry:
*	A is column in viewport
*	B is row in viewport
* Calling sequence:
*	lbsr isvisible
*	bcc notvisible
*	bcs visible
isvisible
	cmpa #80
	bhs no@
	cmpb #20
no@	rts

* Poll keyboard
keycheck
	lbsr keyin
	cmpa #3		; BREAK quit to BASIC
	bne exit@
	lbsr reset
exit@	rts

* Exit to BASIC
reset
	clra		; hard reset to RSDOS
	tfr a,dp
	lda #$88
	sta $ff90	; turn off MMU
	clr $ffd8	; slow CPU
	sta $ffde	; turn on ROMs
	clr $0071
	jmp [$fffe]

* Draw all vertical lines visible in viewport
vlines
	leau vlist,pcr
loop0@
	lda 2,u		; y2
	cmpa origin+1	; above viewport?
	bhs loop@	; no, so get started
	leau 3,u	; skip to the next line
	bra loop0@	; keep looking
loop@	lbsr vline	; draw this line
loop2@	leau 3,u	; skip to next line
	lda 1,u		; look at y1 for that line
	cmpa origin+3	; that line and all subsequent lines below viewport?
	blo loop@	; if so, we're all done
	rts

* Draw all horizontal lines visible in viewport
hlines
	leau hlist,pcr
loop0@
	lda 2,u		; x2
	cmpa origin	; to the left of viewport?
	bhs loop@	; no, so get started
	leau 3,u	; skip to the next line
	bra loop0@	; keep looking
loop@	lbsr hline	; draw this line
loop2@	leau 3,u	; skip to next line
	lda ,u		; look at x1 for that line
	cmpa origin+2	; that line and all subsequent lines to the right of viewport?
	blo loop@	; if so, we're all done
exit@	rts

* Draw vertical line, clipped to viewport
vline
	ldd ,u		; x1, y1
	suba origin	; map to viewport
	bcs xvline	; x1 to left of viewport, forget it
	cmpa #80
	bhs xvline	; x1 to right of viewport, forget it
	subb origin+1
	std coords	; x1, y1
	ldb 2,u		; y2
	subb origin+1	; map to viewport
	std coords+2	; x2, y2
	lbsr isvisible	; second endpoint visible?
	bcs okay@
	ldd coords
	lbsr isvisible	; first endpoint visible?
	bcc xvline	; neither visible, forget it
okay@
	lda 2,u		; length = y2 - y1
	suba 1,u
	ldb coords+1
	bpl y1okay@
	adda coords+1 ; negative amount already so add, not sub
	beq xvline
	clr coords+1
y1okay@
	sta coords+4
	ldd coords
	incb		; skip past status area
	incb
	lbsr curspos
	ldx textptr
loop@
	ldd coords	; x1, y1
	lbsr isvisible
	bcc skip@	; if point not visible, skip it
	lda #'|'
	sta ,x		; draw next point
skip@
	leax 160,x
	inc coords+1	; y1 += 1
	dec coords+4	; length--
	bne loop@
xvline	rts

* Draw horizontal line, clipped to viewport
hline
	ldd ,u
	suba origin	; map to viewport
	subb origin+1
	bcs xhline	; y1 above viewport, forget it
	cmpb #20
	bhs xhline	; y1 below viewport, forget it
	std coords	; x1, y1
	lda 2,u		; x2
	suba origin	; map to viewport
	std coords+2	; x2, y2
	lbsr isvisible	; second endpoint visible?
	bcs okay@
	ldd coords
	lbsr isvisible	; first endpoint visible?
	bcc xhline	; neither visible, forget it
okay@
	lda 2,u		; length = x2 - x1
	suba ,u
	ldb coords
	bpl x1okay@
	adda coords	; negative amount already so add, not sub
	beq xhline
	clr coords
x1okay@
	sta coords+4
	ldd coords
	incb		; skip past status area
	incb
	lbsr curspos
	ldx textptr	; where to put next point
loop@
	ldd coords	; x1, y1
	lbsr isvisible
	bcc skip@	; if point not visible, skip it
	lda #'-'-$20
	adda ,x
	bpl setpoint@
	lda #'+'
setpoint@
	sta ,x		; draw next point
skip@
	leax 2,x
	inc coords	; x1 += 1
	dec coords+4	; length--
	bne loop@
xhline	rts

drawplayer
	ldd playerx
	lbsr curspos
	ldx textptr
	lda ,x		; anything there already?
	cmpa #'|'+$80	; is it an unlocked door?
	bne draw@
door@
	leay gotdoor,pcr
	lbsr prstatus1	; "Door unlocked!"
draw@
	ldd #'O'*256+PLAYER
	std ,x
	rts

gotdoor	fcs /Door unlocked!/

* Move player
*
* A: deltax
* B: deltay
*
moveplayer
	leas -2,s
	adda playerx	; position to new location
	addb playery
	std ,s		; save new position
	lbsr pcurspos
	ldx textptr
	ldd textptr
	subd screen
	lda ,x
	cmpa #'-'	; is the new position clear?
	beq exit@	; if not, don't move player
	cmpa #'|'	; is the new position clear?
	beq exit@	; if not, don't move player
	cmpa #'+'	; is the new position clear?
	beq exit@	; if not, don't move player
	ldd ,s		; get new location again
* LEFT
	cmpa #3		; too far left?
	bhs xminok@
	dec origin	; scroll left
	bra exit@	; don't alter player position
* UP
xminok@	cmpb #5		; too far up?
	bhi yminok@
	dec origin+1	; scroll up
	bra exit@	; don't alter player position
* RIGHT
yminok@ cmpa #80-3	; too far right?
	blo xmaxok@
	inc origin	; scroll right
	bra exit@	; don't alter player position
* DOWN
xmaxok@ cmpb #24-5	; too far down?
	blo ymaxok@
	inc origin+1	; scroll down
	bra exit@	; don't alter player position
*
ymaxok@ std playerx	; save new position
exit@	leas 2,s
	rts

line1a	fcs /Score: /
line1b	fcs /  Health: /
line1c	fcs /%/
line1d	fcs /Found: /
line1e	fcs /nothing/
line2a	fcs /Temple of Rogue/
line2b	fcs /by Rick Adams/
youwon	fcs /You have conquered the Temple of Rogue!/
youlost	fcs /You have died in the Temple of Rogue!/

* Put text into the status areas
status	
	* Status line one
	clra
	clrb
	lbsr curspos
	leau line1a,pcr ; "Score: "
	lbsr printline
	ldd score	; {score}
	lbsr prnum
	lbsr printline

	leau line1b,pcr	; " Health: "
	lbsr printline
	clra
	ldb health	; {health}
	lbsr prnum
	lbsr printline
	leau line1c,pcr	; "%"
	lbsr printline

	* Count how many "Found:" icons to display
	clra
	sta nfound
	tst key1
	beq nokey1@
	inc nfound
nokey1@	tst key2
	beq nokey2@
	inc nfound
nokey2@	tst key3
	beq nokey3@
	inc nfound
nokey3@	tst key4
	beq nokey4@
	inc nfound
nokey4@
	tst nshield
	beq noshield@
	inc nfound
noshield@
	tst nsword
	beq nosword@
	inc nfound
nosword@

	lda #80-7
	suba nfound
	tst nfound
	bne keys@
	suba #7		; strlen("nothing")
keys@	clrb
	lbsr curspos
	leau line1d,pcr
	lbsr printline	; "Found: "
	tst nfound
	bne prkeys@
	leau line1e,pcr
	lbsr printline	; "nothing"
	bra done@
prkeys@ ldx textptr
	lda #$5f	; key icon
	* Show key1
	ldb key1
	beq no1@
	std ,x++
	* Show key2
no1@	ldb key2
	beq no2@
	std ,x++
	* Show key3
no2@	ldb key3
	beq no3@
	std ,x++
	* Show key4
no3@	ldb key4
	beq no4@
	std ,x++
	* Show shield
no4@	tst nshield
	beq noshd@
	ldd #$1a*256+$18
	std ,x++
	* Show sword
noshd@	tst nsword
	beq noswd@
	ldd #$5e*256+$18
	std ,x++
noswd@
done@
	* Status line two
	clra
	ldb #23
	lbsr curspos
	leau line2a,pcr
	lbsr printline		; "Temple of Rogue"
	tst nobjs
	bne notdone@
	leau youwon,pcr		; "You have conquered the Temple of Rogue!"
	lbsr prstatus2
	bra credits@
notdone@
	tst dead
	beq notdead@
	leau youlost,pcr	; "You have died in the Temple of Rogue!"
	lbsr prstatus2
	bra credits@
notdead@
	; "{nobjs} items remaining"
	lbsr pritems
credits@
	lda #80-13
	ldb #23
	lbsr curspos
	leau line2b,pcr
	lbsr printline ; "by Rick Adams"
	rts

* Draw objects
*
drawobjects
	ldu #OBJS
loop@	ldd ,u
	cmpd #$ffff
	lbeq exit@
	suba origin	; map to viewport
	subb origin+1
	lbsr isvisible
	lbcc next@
	incb
	incb
	lbsr curspos
	ldx textptr
	lda ,x		; is player there?
	cmpa #'O'
	lbne draw@
	clr ,u		; delete object
	clr 1,u
	dec nobjs	; one less object
	lda 2,u		; get object character
	cmpa #$18	; is it gold?
	beq gold@
	cmpa #$5f	; is it a key?
	beq key@
* Other objects (shield, sword) go here
	cmpa #$5e	; is it a sword?
	beq sword@
	cmpa #$1a	; is it a shield?
	beq shield@
	cmpa #$1d	; is it a potion?
	beq potion@
	bra next@	; ignore
potion@
	leay gotptn,pcr
	lbsr prstatus1	; "Drank a potion!"
	lda health
	adda #10	; increase health by 10%
	cmpa #100
	bls health@
	lda #100	; can't top off over 100%
health@	sta health
	bra next@
sword@
	inc nsword
	leay gotswd,pcr
	lbsr prstatus1	; "Found a sword!"
	bra next@
shield@
	inc nshield
	leay gotshd,pcr
	lbsr prstatus1	; "Found a shield!"
	bra next@
key@
	leay gotkey,pcr
	lbsr prstatus1	; "Found a key!"
	lda 3,u		; key type (KEY1, KEY2, KEY3, KEY4)
	cmpa #KEY1
	bne key2@
	sta key1
key2@	cmpa #KEY2
	bne key3@
	sta key2
key3@	cmpa #KEY3
	bne key4@
	sta key3
key4@	cmpa #KEY4
	bne next@
	sta key4
	bra next@
gold@
	ldd score	; add 50 to score
	addd #50
	std score
	leay gotgold,pcr
	lbsr prstatus1	; "Found +50 gold!"
	bra next@
draw@	ldd 2,u		; draw object
	ldx textptr
	std ,x
next@	leau 4,u
	lbra loop@
exit@	rts

gotgold fcs /Found +50 gold!/
gotkey fcs /Found a key!/
gotswd	fcs /Found a sword!/
gotshd	fcs /Found a shield!/
gotptn	fcs /Drank a potion!/

* Read keyboard
*
* Exit: char in A
*
keyin	ldd #$5ef7	; UP 94
	stb $ff02
	ldb $ff00
	andb #$7f
	cmpb #$77
	beq key@
	ldd #$0aef	; DOWN 10
	stb $ff02
	ldb $ff00
	andb #$7f
	cmpb #$77
	beq key@
	ldd #$08df	; LEFT 8
	stb $ff02
	ldb $ff00
	andb #$7f
	cmpb #$77
	beq key@
	ldd #$09bf	; RIGHT 9
	stb $ff02
	ldb $ff00
	andb #$7f
	cmpb #$77
	beq key@
	ldd #$5ef7	; K UP 94
	stb $ff02
	ldb $ff00
	andb #$7f
	cmpb #$7d
	beq key@
	ldd #$0afb	; J DOWN 94
	stb $ff02
	ldb $ff00
	andb #$7f
	cmpb #$7d
	beq key@
	ldd #$08fe	; H LEFT 8
	stb $ff02
	ldb $ff00
	andb #$7f
	cmpb #$7d
	beq key@
	ldd #$09ef	; L RIGHT 9
	stb $ff02
	ldb $ff00
	andb #$7f
	cmpb #$7d
	beq key@
	ldd #$03fb	; BREAK 3
	stb $ff02
	ldb $ff00
	andb #$7f
	cmpb #$3f
	beq key@
	clra		; no key pressed
	clr kbbusy	; clear keyboard busy timer
	rts
key@    tst kbbusy	; key pressed: ignoring keypresses?
	beq delay@
        clra            ; clear keystroke
        rts             ; get out of here
delay@	ldb #7		; going to ignore keypresses for a bit
	stb kbbusy	; store key delay
exit@   rts

	incl lines.asm
	incl prnum.asm
	incl objects.asm

* Length of string
*
* Entry:
*	X string
*
* Exit:
*	B length
*
strlen
	clrb
loop@	incb		; how many chars?
	tst ,x+
	bpl loop@
	rts

* Queue status message to display on status line 1
*
* leay msg,pcr
* lbsr prstatus1
*
* msg  fcs /This is a test/
*
prstatus1
	leay ,y
	beq exit@
	sty pmsg
	lda #130	; status message will persist for around 2 secs
	sta timer
exit@	rts

* Update status message on status line 1
*
updstatus1
	ldd pmsg
	beq exit@
	ldu pmsg
	tfr u,x
	bsr strlen
	lsrb
	negb
	addb #40
	aslb
	ldx screen	; center on line
	abx
loop@	lda ,u+
	sta ,x++
	bpl loop@
exit@	rts

remain	fcs / items remaining/ ; 16 chars

* Print remaining items
*
pritems
	ldb #16
	lda nobjs
	cmpa #100
	bls lt100@
	incb
lt100@	cmpa #10
	bls lt10@
	incb
lt10@	lsrb
	negb
	addb #40
	aslb
	ldx screen	; center on line
	abx
	leax 160*23,x
	stx textptr
	ldb nobjs
	clra
	lbsr prnum
	lbsr printline
	leau remain,pcr
	lbsr printline
	rts

* Print status message on status line 2
*
* leau msg,pcr
* lbsr prstatus2
*
* msg  fcs /This is a test/
*
prstatus2
	tfr u,x
	bsr strlen
	lsrb
	negb
	addb #40
	aslb
	ldx screen	; center on line
	abx
	leax 160*23,x
loop@	lda ,u+
	sta ,x++
	bpl loop@
	rts

* Draw doors
*
drawdoors
	ldu #DOORS
loop@	ldd ,u
	cmpd #$ffff
	beq exit@
	suba origin
	subb origin+1
	lbsr isvisible
	bcc next@
	incb
	incb
	lbsr curspos
	ldx textptr
	ldy #key3
	ldd 2,u
	cmpb #DOOR1
	bne door2@
	ldy #key1
door2@	cmpb #DOOR2
	bne door4@
	ldy #key2
door4@	cmpb #DOOR4
	bne unlock@
	ldy #key4
unlock@	tst ,y		; do we have the key for this door?
	beq draw@
	ora #$80	; unlock door
draw@	std ,x
next@	leau 4,u
	bra loop@
exit@	rts

IRQ	dec timer	; has status message timed out?
	bne irq1@
	clr pmsg	; yes, so clear it
	clr pmsg+1
irq1@	tst kbbusy	; keyboard busy?
	beq irq2@
	dec kbbusy	; decrement keyboard busy timer
irq2@	dec vcount	; decrement vsync counter
	bne exit@
	lda #60
	sta vcount
	tst nobjs	; stop counting if game over
	beq exit@
	tst dead
	bne exit@
	inc secs	; update seconds
	lda secs
	cmpa #60
	blo exit@
	clr secs
	inc mins	; update minutes
	lda mins
	cmpa #60
	blo exit@
	clr secs
	clr mins
	inc hours	; update hours
exit@	lda $ff02	; dismiss IRQ interrupt
	rti

time1	fcs /Time: /
time2	fcs /:/
time3	fcs /0/
time4	fcs /  /

* Display elapsed time
*
prtime
	ldd screen	; flip temporarily to other screen
	eora #$10
	std screen
	lda #35		; position cursor to status area 2
	tst hours
	beq noadj@	; adjust position if displaying hours?
	deca
noadj@	ldb #22
	lbsr curspos
	leau time1,pcr
	lbsr printline	; "Time: "
	clra
	ldb hours
	beq nohours@
	lbsr prnum
	lbsr printline	; {hours}
	leau time2,pcr
	lbsr printline	; ":"
nohours@
	ldb mins
	cmpb #10
	bhs nozero1@
	leau time3,pcr
	lbsr printline	; "0"
nozero1@
	clra
	ldb mins
	lbsr prnum
	lbsr printline	; {mins}
	leau time2,pcr
	lbsr printline	; ":"
	ldb secs
	cmpb #10
	bhs nozero2@
	leau time3,pcr
	lbsr printline	; "0"
nozero2@
	clra
	ldb secs
	lbsr prnum
	lbsr printline	; {secs}
	leau time4,pcr
	lbsr printline	; "  " (this shouldn't be necessary but it is)
	ldd screen
	eora #$10
	std screen	; flip back to original screen
	rts

drawenemies
	ldu #ENEMIES
loop@	ldd ,u
	beq next@
	cmpd #$ffff
	beq exit@
*
	ldd ,u
	ldy #0
	suba origin
	subb origin+1
	lbsr isvisible
	bcc next@
	incb
	incb
	lbsr curspos
	ldx textptr
	lbsr isaggro		; Is player in enemy aggro area?
	bcs aggro@
noaggro@
	ldd #$1b*256+$10	; No, draw without highlight
	bra draw@
aggro@
	leay yousee,pcr		; "You see a dragon!"
	ldd #$1b*256+$38	; Yes, draw with highlight
draw@
	pshs d			; save text and attributes
        ldd ,u
        suba origin
        subb origin+1
        incb
        incb
        lbsr curspos
        ldx textptr
	lda ,x
	cmpa #'O'
	bne nothit@
	* Dragon hits player
	tst nsword		; holding a sword?
	beq nosword@
	leay killed,pcr		; "You killed a dragon!"
	clr ,u			; kill dragon
	clr 1,u
	bra nothit@
nosword@
	leay gothurt,pcr	; "The dragon attacks you!"
	;dec health		; health = health - 1%
	tst nshield
	bne shielded@
	dec health		; health = health - 1%
	dec health		; health = health - 1%
shielded@
	bne nothit@
	inc dead		; Game over flag
nothit@
	lbsr prstatus1		; and display it
	puls d			; Retrieve text and attributes
	std ,x			; Draw enemy
next@	leau 6,u
	bra loop@
exit@	rts

gothurt	fcs /The dragon attacks you!/
yousee	fcs /You see a dragon!/
killed	fcs /You killed a dragon!/

* Is player within aggro area?
*
* Entry:
*	U points to enemy entry in table
*	    ,U	xpos
*	    1,U	ypos
*	    2,U	xcenter
*	    3,U	ycenter
*	    4,U	xdelta
*	    5,U	ydelta
* Calling sequence:
*	lbsr isaggro
*	bcc notaggro
*	bcs aggro
isaggro
	ldd playerx	; local coordinates of player
	adda origin
	addb origin+1
	std player	; global coordinates of player
*
	ldd 2,u		; xcenter, ycenter
	suba 4,u	; a = left edge of aggro area
	subb 5,u	; b = upper edge of aggro area
	incb
	incb
	cmpa player	; is left edge of aggro area to right of player?
	bhi notaggro@
	cmpb player+1	; is upper edge of aggro aread below player?
	bhi notaggro@
*
	ldd 2,u		; xcenter, ycenter
	adda 4,u	; a = right edge of aggro area
	addb 5,u	; b = lower edge of aggro area
	incb
	incb
	cmpa player	; is right edge of aggro area to left of player?
	blo notaggro@
	cmpb player+1	; is lower edge of aggro area above player?
	blo notaggro@
*
aggro@
	ldd player	; chase player
	decb
	decb
	lbsr chase
	coma		; set carry
	rts
notaggro@
	ldd 2,u		; return to home position
	lbsr chase
	clra		; clear carry
	rts

* Seek after player
chase
	cmpa ,u		; compare target x with current x
	bls no1@
	inc ,u		; chase right
no1@	bhs no2@
	dec ,u		; chase left
no2@	cmpb 1,u	; compare target y with current y
	bls no3@
	inc 1,u		; chase down
no3@	bhs no4@
	dec 1,u		; chase up
no4@	rts

* Decrement until zero
takeaway
	deca
	bge exit@
	clra
exit@	rts

zprog

	* Intercept "Close File" hook to autostart program
	org $a42e
	fdb start

	end start
