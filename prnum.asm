* Entry:
*	D number
* Exit:
*	U pointer to string
*
prnum	ldu #value
	std number
	ldd #10000
	bsr digit
	ldd #1000
	bsr digit
	ldd #100
	bsr digit
	ldd #10
	bsr digit
	ldd #1
	bsr digit
	ldb #$80	; set bit on last digit
	orb -1,u
	stb -1,u
	ldu #value	; return pointer to value
	ldb #5
loop@	lda ,u
	cmpa #'0'	; suppress zeroes
	bne exit@
	leau 1,u
	decb
	bgt loop@
exit@	rts

digit	pshs d
	lda #'0'
	sta ,u
	ldd number
loop@	subd ,s
	blt done@
	std number
	inc ,u
	bra loop@
done@	leau 1,u
	leas 2,s
	rts
