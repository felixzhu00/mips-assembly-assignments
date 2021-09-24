################# Felix Zhu #################
################# felzhu #################
################# 113450017 #################

################# DO NOT CHANGE THE DATA SECTION #################


.data
arg1_addr: .word 0
arg2_addr: .word 0
num_args: .word 0
invalid_arg_msg: .asciiz "One of the arguments is invalid\n"
args_err_msg: .asciiz "Program requires exactly two arguments\n"
zero: .asciiz "Zero\n"
nan: .asciiz "NaN\n"
inf_pos: .asciiz "+Inf\n"
inf_neg: .asciiz "-Inf\n"
mantissa: .asciiz ""

.text
.globl hw_main
hw_main:
    sw $a0, num_args
    sw $a1, arg1_addr
    addi $t0, $a1, 2
    sw $t0, arg2_addr
    j start_coding_here

start_coding_here:
	# check if num_args is 2
	lw $t0, num_args
	li $t1, 2
	bne $t0, $t1, arg_err

	#check first argument is 2 character long and null
	lw $s0, arg1_addr
	lbu $t0, 0($s0)
	beqz $t0, invalid
	lbu $t0, 1($s0)
	bnez $t0, invalid
	
	#match "D", "F", "L", "X"
	lbu $t0, 0($s0)
	li $t1, 'D'
	li $a0, 0
	beq $t0, $t1, D_part_1
	li $t1, 'X'
	li $a0, 0
	beq $t0, $t1, X_part_1
	li $t1, 'F'
	li $a0, 0
	beq $t0, $t1, F_part_1
	li $t1, 'L'
	li $a0, 0
	beq $t0, $t1, L_part_1
	j invalid
	
D_part_1:			#Part2
	lw $s0, arg2_addr
	li $t3, '0'
	li $t4, '9'
	lbu $t2, 0($s0)
	beqz $t2, invalid
while:
	lbu $t2, 0($s0)
	beqz $t2, D_part_2
	blt $t2, $t3, invalid
	bgt $t2, $t4, invalid
	addi $s0, $s0, 1
	j while
D_part_2:
	lw $s0, arg2_addr
	li $t5, 10		#hold 10
	li $t6, 0		#store final
while2:
	lbu $t2, 0($s0)
	beqz $t2, D_part_3
	mul $t6,$t6,$t5
	addi $t2, $t2, -48	#convert to digit
	add $t6, $t6, $t2
	addi $s0, $s0, 1
	j while2
D_part_3:
	li $v0, 1
	move $a0, $t6
	syscall
	j end
X_part_1:
	lw $s0, arg2_addr
	li $t3, '0'
	li $t4, 'x'
	lbu $t1, 0($s0)
	addi $s0,$s0,1
	bne $t1, $t3, invalid
	lbu $t2, 0($s0)
	addi $s0,$s0,1
	bne $t2, $t4, invalid
	
X_part_2:
	li $t9,'0'
	li $t8,'9'
	li $t7,'A'
	li $t6,'F'
	li $t5, 0  #counter
	li $t4, 11
	li $s1, 0  #sum
	j while3
while3:
	addi $t5,$t5,1
	bge $t5, $t4, invalid
	lbu $t2, 0($s0)
	beqz $t2, X_part_3
	bltu $t2, $t9, notdig
	bltu $t8, $t2, notdig
	addi $t2,$t2, -48
	j inc
notdig:
	bltu $t2, $t7, invalid
	bltu $t6, $t2, invalid
	addi $t2,$t2, -55
	j inc
inc:
	sll $s1,$s1,4
	addu $s1,$s1,$t2
	addi $s0,$s0,1
	j while3
X_part_3:
	li $v0, 36
	move $a0, $s1
	syscall
	j end

F_part_1:
	lw $s0, arg2_addr
F_part_2:
	li $t9,'0'
	li $t8,'9'
	li $t7,'A'
	li $t6,'F'
	li $t4, 8
	li $s1, 0
	add  $s2, $0, $0
loop:				#check if the arg is 8 length
	lbu $s3, 0($s0)
	beqz $s3, exit
	bltu $s3, $t9, notdig2
	bltu $t8, $s3, notdig2
	j inc2
notdig2:
	bltu $s3, $t7, invalid
	bltu $t6, $s3, invalid
	j inc2
inc2:
	addi $s1, $s1, 1
	addi $s0,$s0,1
	j loop
exit:
	sub $s4, $s1, $t4
	bnez $s4, invalid
F_part_3:
	lw $s0, arg2_addr
	li $t9,'0'
	li $t8,'8'
	li $t7,'F'
	li $t6,'7'
	lbu $s3, 0($s0)
	addi $s0,$s0,1
	beq $s3, $t9, checkZero
	beq $s3, $t8, checkZero
	beq $s3, $t7, checkF
	beq $s3, $t6, check7
	j end
checkZero:
	beqz $s3, case_zero
	bne $s3, $t9, not_special 
	addi $s0,$s0,1
	lbu $s3, 0($s0)
	j checkZero
checkF:
	lbu $s3, 0($s0)
	addi $s0,$s0,1
	bne $s3, $t7, not_special
	lbu $s3, 0($s0)
	addi $s0,$s0,1
	blt $s3, $t8, not_special
innerloop:
	lbu $s3, 0($s0)
	addi $s0,$s0,1
	beqz $s3, case_neginf
	bne $s3, $t9, na
	addi $s0,$s0,1
	lbu $s3, 0($s0)
	j innerloop
check7:
	lbu $s3, 0($s0)
	addi $s0,$s0,1
	bne $s3, $t7, not_special
	lbu $s3, 0($s0)
	addi $s0,$s0,1
	blt $s3, $t8, not_special
innerloop2:
	lbu $s3, 0($s0)
	addi $s0,$s0,1
	beqz $s3, case_posinf
	bne $s3, $t9, na
	addi $s0,$s0,1
	lbu $s3, 0($s0)
	j innerloop2
case_zero:
	li $v0, 4
	la $a0, zero
	syscall
	j end
case_posinf:
	li $v0, 4
	la $a0, inf_pos
	syscall
	j end
case_neginf:
	li $v0, 4
	la $a0, inf_neg
	syscall
	j end
na:
	li $v0, 4
	la $a0, nan
	syscall
	j end
not_special:
	lw $s0, arg2_addr
	li $t9,'0'
	li $t8,'9'
	li $t7,'A'
	li $t6,'F'
	
quit:
	j end



L_part_1:
	lw $s0, arg2_addr
	li $t0, 0
	li $t1, 11
	li $t2, 0
	li $t3, '0'
	li $t4, '9'
	li $s1, 'M'
	li $s2, 'P'
	li $s3, 48
top:
	bgt $t2, $t1, print_score
	lbu $t5, 0($s0)
	beqz $t5, invalid
	blt $t5, $t3, invalid
	bgt $t5, $t4, invalid
	addi $s0,$s0,1
	lbu $t6, 0($s0)
	beqz $t6, invalid
	sub $t5, $t5, $s3
	beq $t6, $s1, m
	beq $t6, $s2, p
	j invalid
m:
	add $t0, $t0, $t5
	addi $s0, $s0, 1
	addi $t2, $t2, 2
	j top
p:
	sub $t0, $t0, $t5
	addi $s0, $s0, 1
	addi $t2, $t2, 2
	j top
print_score:
	move $a0, $t0
	li $v0, 1
	syscall
	j end

















arg_err:
	li $v0, 4
	la $a0, args_err_msg
	syscall
	j end
		
invalid:
	li $v0, 4
	la $a0, invalid_arg_msg
	syscall
	j end
end:
	li $v0, 10
	syscall
