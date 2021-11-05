######### FULL NAME ##########
######### SBU ID ##########
######### NET ID ##########

.text
.globl initialize
checkline:
lw $t0 0($a1)
sw $0 0($a1)
li $a2 1
li $v0 14
syscall
lw $t1 0($a1)
li $t2 13
beq $t1 $t2 CR
li $t2 10
beq $t1 $t2 LF
j error	
CR:
	li $v0 14
	syscall
	lw $t1 0($a1)
	li $t2 10
	beq $t1 $t2 LF
	j error
LF:
	sw $t0 0($a1)
	jr $ra


initialize:
addi $sp $sp -8
sw $ra 0($sp)
sw $a1 4($sp)
move $t7 $a1

#syscall 13
li $a1 0
li $v0 13
syscall
bltz $v0 error
	
#syscall 14
move $a0 $v0
move $a1 $t7
li $a2 1  
li $v0 14 
syscall
lw $t0 0($a1)
li $t1 49
blt $t0 $t1 error
li $t1 57
bgt $t0 $t1 error
	
addi $t0 $t0 -48
sw $t0 0($a1)
jal checkline
		
#syscall 14
addi $a1 $a1 4
li $v0 14
syscall
		
lw $t0 0($a1)
li $t1 49
blt $t0 $t1 error
li $t1 57
bgt $t0 $t1 error
		
addi $t0 $t0 -48
sw $t0 0($a1)
jal checkline

#loop prep
lw $t4 4($sp)
lw $t5 0($t4)
lw $t6 4($t4)
addi $a1 $a1 4

outloop:
move $t4  $t6
inloop:
	beqz $t4  inloopend
	sw $0 0($a1)
	li $v0 14
	syscall
	lw $t0 0($a1)
	li $t1 48
	blt $t0 $t1 error
	li $t1 57
	bgt $t0 $t1 error
	addi $t0 $t0 -48
	sw $t0 0($a1)
	addi $a1 $a1 4
	addi $t4 $t4 -1
	j inloop
inloopend:
addi $t5 $t5 -1
beqz $t5 outloopend
jal checkline	
j outloop

#check for once more
outloopend:
lw $t0 0($a1) 
sw $0 0($a1)
li $v0 14
syscall	
lw $t1 0($a1)
li $t2 10
beq $t1 $t2 case1
li $t2 13
beq $t1 $t2 case2
beqz $v0 case1	
j error
			
case2:
	li $v0 14
	sw $0 0($a1)
	syscall
	lw $t1 0($a1)
	li $t2 10
	beq $t1 $t2 case1
	j error
			
case1:
	li $v0 14
	syscall
	bnez $v0 error
	sw $t0 0($a1)
	j finished

#fill with zero if error
error:
li $v0 16
syscall
li $v0 -1
lw $a1 4($sp)
li $t0 81
revert:
	beqz $t0 revertend
	sw $0 0($a1)
	addi $a1 $a1 4
	addi $t0 $t0 -1
	j revert
revertend:
lw $a1 4($sp)
j done


finished:
li $v0  16
syscall
li $v0  1
j done
		
		
done:
lw $ra 0($sp)
addi $sp $sp 8	
jr $ra	
		
		
	
		
.globl write_file
newLine:
li $t3 10	#10
sw $t3 0($a1)	#\n
li $v0 15
syscall
jr $ra

write_file:
addi $sp $sp -16
sw $a1 0($sp)	#buffer
sw $ra 4($sp)	#ra
li $t3 10	#10


#syscall 13
li $a1 1
li $v0 13
syscall

#bltz $v0, error	#negative fd

#syscall 15
move $a0 $v0	#fp
lw $a1 0($sp)	#buffer
lw $t0 0($a1)	#row
lw $t1 4($a1)	#col

li $a2 1

sw $t0 8($sp)	#row
sw $t1 12($sp)	#col

li $v0 15
lw $t9 0($a1)
addi $t9 $t9 48
sw $t9 0($a1)
syscall
jal newLine
addi $a1 $a1 4

li $v0 15
lw $t9 0($a1)
addi $t9 $t9 48
sw $t9 0($a1)
syscall
jal newLine
addi $a1 $a1 4

loop2:
beqz $t0 end2
lw $t1 12($sp)
	loop3:
	li $v0 15
	lw $t9 0($a1)
	addi $t9 $t9 48
	sw $t9 0($a1)
	syscall
	addi $t1 $t1 -1
	beqz $t1 contloop
	addi $a1 $a1 4
	j loop3
contloop:
jal newLine
addi $a1 $a1 4
addi $t0 $t0 -1
j loop2

end2:
li $v0 16
syscall

lw $ra 4($sp)
addi $sp $sp 16
jr $ra


.globl rotate_clkws_90

rotate_clkws_90:
addi $sp $sp -24
sw $a0 0($sp)	#buffer
sw $ra 4($sp)	#return address
sw $a1 20($sp)	#name

move $a0 $a1	#name
lw $t0 0($sp)
move $a1 $t0	#buffer

#syscall 13
li $a1 1
li $v0 13
syscall

#bltz $v0, error	#negative fd

#syscall 15
move $a0 $v0
lw $a1 0($sp)
li $a2 1


addi $a1 $a1 4	#position 1(col) -> position 0(row)
li $v0 15
lw $t0 0($a1)
sw $t0 8($sp)	#oldcol
addi $t0 $t0 48
sw $t0 0($a1)
syscall
jal newLine



addi $a1 $a1 -4 #position 0(row) -> position 1(col)
li $v0 15
lw $t0 0($a1)
sw $t0 12($sp)	#oldrow
addi $t0 $t0 48
sw $t0 0($a1)
syscall
jal newLine

addi $a1 $a1 8	#position 3 - beginning of the array


lw $t0 12($sp)	#old row
lw $t1 8($sp)	#old col

addi $t2 $t0 -1	#oldrow-1
mult $t1 $t2	#oldrow-1 * oldcol
mflo $t0	#answer
li $t1 4	#x4
mult $t0 $t1
mflo $t0	#final answer

add $a1 $a1 $t0	#First index of file

sw $a1 16($sp)	#store





li $t7 0	#times outer loop runs
func2:

lw $t1 8($sp)	#oldcol
loop4:#run col times
beqz $t1 end3
lw $t2 12($sp)	#oldrow
	loop5:#run row times
	
	li $v0 15
	lw $t9 0($a1)	#convert
	
	li $v0 15
	
	addi $t9 $t9 48
	sw $t9 0($a1)
	syscall
	
	addi $t2 $t2 -1
	
	beqz $t2 continue
	
	lw $t9 8($sp)	#oldcol		2
	li $t8 4
	mult $t8 $t9
	mflo $t8
	sub $a1 $a1 $t8 #address change by t2 amount
	
	j loop5
	
continue:
jal newLine
addi $t1 $t1 -1
addi $t7 $t7 4
lw $a1 16($sp)	#reset buffer to place
add $a1 $a1 $t7	# adjust buffer for next row
j loop4


end3:
li $v0 16
syscall


lw $a1 0($sp)	#buffer
lw $a0 20($sp)	#name
jal initialize


lw $ra 4($sp)
addi $sp $sp 24
jr $ra
  

.globl rotate_clkws_180
rotate_clkws_180:
  
  addi $sp $sp -12
  sw $ra 0($sp)
  sw $a0 4($sp)
  sw $a1 8($sp)
  
  jal rotate_clkws_90
  
  lw $a0 4($sp)
  lw $a1 8($sp)
  jal rotate_clkws_90
  
  lw $ra 0($sp)
  addi $sp $sp 12
  jr $ra

.globl rotate_clkws_270
rotate_clkws_270:
  addi $sp $sp -12
  sw $ra 0($sp)
  sw $a0 4($sp)
  sw $a1 8($sp)
  
  jal rotate_clkws_180
  
  lw $a0 4($sp)
  lw $a1 8($sp)
  jal rotate_clkws_90
  
  lw $ra 0($sp)
  addi $sp $sp 12
  jr $ra 

.globl mirror
mirror:
 jr $ra
  

.globl duplicate
duplicate:
 jr $ra
