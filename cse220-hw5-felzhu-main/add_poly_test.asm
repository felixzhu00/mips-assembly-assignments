############################ CHANGE THIS FILE AS YOU DEEM FIT ############################
.data
pairs1: .word -1 2 -3 4 0 -1
N1: .word 70

pairs2: .word 1 2 3 4 0 -1
N2: .word 70

.text
main:
la $a0, pairs1
lw $a1, N1
jal create_polynomial
move $s0, $v0

la $a0, pairs2
lw $a1, N1
jal create_polynomial
move $s1, $v0




move $a0, $s0
move $a1, $s1
jal add_polynomial





#write test code


exit:
	li $v0, 10
	syscall

.include "hw5.asm"
