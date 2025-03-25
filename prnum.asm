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
