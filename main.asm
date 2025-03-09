
SCREEN	equ $4000

	org $0000

textptr	rmb 2 
cursor	rmb 2 ; x, y
origin	rmb 4 ; xorigin, yorigin, xorigin + 80, yorigin + 20
coords	rmb 5 ; x1, y1, x2, y2, length

	org $E00
start

	* Fix "Close File" hook and close file
	ldd #$176
	std $a42e
	jsr $a42d

	* Fast CPU
	sta $ffd9

	* Initialize graphics and MMU
	lbsr initgfx

	* Init viewport to center of map
	ldd #(WIDTH/2-40)*256+(HEIGHT/2-10)
	std origin
	ldd #SCREEN
	std textptr

	* Put some sample text into the status areas
	clra
	clrb
	lbsr curspos
	ldu #line1
	lbsr printline ; Status line one
	lbsr printline ; Status line one
	lbsr printline ; Status line one
	clra
	ldb #23
	lbsr curspos
	ldu #line2
	lbsr printline ; Status line two
	lbsr printline ; Status line two
	lbsr printline ; Status line two

	* Draw initial content of content area
	lbsr drawframe

	* Idle loop
loop@	lbsr keycheck
	cmpa #8
	bne notr@
	dec origin
	lbsr drawframe
notr@
	cmpa #9
	bne notl@
	inc origin
	lbsr drawframe
notl@
	cmpa #10
	bne notu@
	inc origin+1
	lbsr drawframe
notu@
	cmpa #94
	bne notd@
	dec origin+1
	lbsr drawframe
notd@
	bra loop@

line1	fcs /Status line one goes here /
line2	fcs /Status line two goes here /

* Draw frame
drawframe
	sync
	ldd origin
	adda #80
	addb #20
	std origin+2
	lbsr clrcontent
	lbsr vlines
	lbsr hlines
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
	lda #$36
	sta $ffa2
	ldd #$d800
	std $ff9d

	* Clear the screen
	lbsr clrstatus1
	lbsr clrcontent
	lbsr clrstatus2

	* Set palettes for text
	ldb #27		; cyan
	stb $ffb8
	ldb #54		; amber
	stb $ffb9
	rts

* Clear status area one
clrstatus1
	ldx #SCREEN
	ldd #$2008
loop@	std ,x++
	std ,x++
	cmpx #SCREEN+2*160
	bne loop@
	rts

* Clear status area two
clrstatus2
	ldx #SCREEN+23*160
	ldd #$2008
loop@	std ,x++
	std ,x++
	cmpx #SCREEN+24*160
	bne loop@
	rts

* Clear just the content area
clrcontent
	ldx #SCREEN+2*160
	ldd #$2000
loop@	std ,x++
	std ,x++
	cmpx #SCREEN+22*160
	bne loop@
	rts

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
	adca #SCREEN/512
	aslb
	rola
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
	cmpa #79
	bhi no@
	cmpb #20
no@	rts

* Poll keyboard
keycheck
	jsr [$a000]
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
loop@	lbsr vline
	leau 3,u
	lda 1,u
	cmpa origin+3	; all subsequent lines beyond viewport?
	blo loop@
exit@	rts

* Draw all horizontal lines visible in viewport
hlines
	leau hlist,pcr
loop@	lbsr hline
	leau 3,u
	lda ,u
	cmpa origin+2	; all subsequent lines beyond viewport?
	blo loop@
exit@	rts

* Draw vertical line, clipped to viewport
vline
	ldd ,u
	suba origin	; map to viewport
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
	sta coords+4
loop@
	ldd coords	; x1, y1
	lbsr isvisible
	bcc skip@	; if point not visible, skip it
	incb
	incb
	lbsr curspos
	ldx textptr	; where to put next point
	lda #'|'
setpoint@
	sta ,x		; draw next point
skip@
	inc coords+1	; y1 += 1
	dec coords+4	; length--
	bne loop@
xvline	rts

* Draw horizontal line, clipped to viewport
hline
	ldd ,u
	suba origin	; map to viewport
	subb origin+1
	std coords	; x1, y1
	lda 2,u		; x2
	subb origin	; map to viewport
	std coords+2	; x2, y2
	lbsr isvisible	; second endpoint visible?
	bcs okay@
	ldd coords
	lbsr isvisible	; first endpoint visible?
	bcc xhline	; neither visible, forget it
okay@
	lda 2,u		; length = x2 - x1
	suba ,u
	sta coords+4
loop@
	ldd coords	; x1, y1
	lbsr isvisible
	bcc skip@	; if point not visible, skip it
	incb
	incb
	lbsr curspos
	ldx textptr	; where to put next point
	lda #'-'-$20
	adda ,x
	bpl setpoint@
	lda #'+'
setpoint@
	sta ,x		; draw next point
skip@
	inc coords	; x1 += 1
	dec coords+4	; length--
	bne loop@
xhline	rts

	incl lines.asm

	* Intercept "Close File" hook to autostart program
	org $a42e
	fdb start

	end start
