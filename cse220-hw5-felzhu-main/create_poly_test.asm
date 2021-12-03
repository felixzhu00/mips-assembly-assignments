############################ CHANGE THIS FILE AS YOU DEEM FIT ############################
.data
pairs: .word 1 2 3 4 5 6 7 8 1 2 1 2 0 -1
N: .word 1

.text
main:
la $a0, pairs
lw $a1, N
jal create_polynomial
#write test code

lw $s0 0($v0)
lw $s1 4($v0)

exit:
	li $v0, 10
	syscall
.include "hw5.asm"
