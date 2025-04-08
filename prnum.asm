* Entry:
*	X buffer
*	D number
*
prnum	std number
	ldd #1000
	bsr digit
	ldd #100
	bsr digit
	ldd #10
	bsr digit
	ldd #1
	bsr digit
	rts

digit	pshs d
	lda #'0'
	sta ,x
	ldd number
loop@	subd ,s
	blt done@
	std number
	inc ,x
	bra loop@
done@	leax 1,x
	leas 2,s
	rts

* Entry:
*	X buffer
nozeroes
	lda #4
	pshs a
	ldb #' '
loop@	dec ,s
	beq exit@
	lda ,x
	cmpa #'0'
	bne exit@
	stb ,x+
	bra loop@
exit@	puls a,pc
