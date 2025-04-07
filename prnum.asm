* Entry:
*	X buffer
*	B number
*
prnum	clra
	std number
	ldb #100
	bsr digit
	ldb  #10
	bsr digit
	ldb #1
	bsr digit
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

* Entry:
*	X buffer
nozeroes
	lda #3
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
