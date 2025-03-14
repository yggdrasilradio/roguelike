* Entry:
*	B number
*
prnum	clra
	std number
	ldx #buffer
	ldb #100
	bsr digit
	ldb  #10
	bsr digit
	ldb #1
	bsr digit
	leax -1,x
	ldb ,x
	orb #$80
	stb ,x
	rts

digit	lda #'0'
	sta ,x
	clra
	pshs d
	ldd number
loop@	subd ,s
	blt done@
	std number
	inc ,x
	bra loop@
done@	leax 1,x
	leas 2,s
	rts
