############## Felix Zhu ##############
############## 113450017 #################
############## felzhu ################

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:
.globl create_term
create_term:
#create_term(int coeff, int exp)
beqz $a0 create_term_error	#check if coefficent is 0
bltz $a1 create_term_error	#exponent is less than 0

move $t0 $a0			#save a0 to temp

li $a0 12			#allocate memory
li $v0 9
syscall				#obtain memeroy addr in v0

sw $t0 0($v0)			#coeff
sw $a1 4($v0)			#exp
sw $zero 8($v0)			#0

jr $ra
create_term_error:
li $v0 -1
jr $ra

.globl create_polynomial
length:
li $t0 0
get_length:
lw $t1 0($a0)
seq $t1 $t1 $0 
lw $t2 4($a0)
li $t3 -1
seq $t2 $t2 $t3

and $t1 $t1 $t2		#loop end condition

bnez $t1 end_get_length

addi $a0 $a0 8
addi $t0 $t0 1		#inc

j get_length

end_get_length:
move $v0 $t0
jr $ra

###########

bubble_sort:
addi $sp $sp -12
sw $a0 0($sp)


addi $sp $sp -4
sw $ra 0($sp)
jal length
lw $ra 0($sp)
addi $sp $sp 4

move $t0 $v0

sw $t0 4($sp)		#size
addi $t0 $t0 -1		#size - 1

li $t1 0		#i
outer_loop:
lw $a0 0($sp)
bgt $t1 $t0 end_outer_loop
li $t2 0		#j
	inner_loop:
	sub $t3 $t0 $t1
	bgt $t2 $t3 end_inner_loop
		#condition		$a0 + $t2 * 4 = arr[j]
		lw $t3 4($a0)		#exp1
		lw $t4 12($a0)		#exp2
		lw $t5 0($a0)		#coeff1
		lw $t6 8($a0)		#coeff2
		
		blt $t3 $t4 swap1
		beq $t3 $t4 preswap
		
		j inner_cont
		
		preswap:
		blt $t5 $t6 swap1
		j inner_cont
		
		swap1:
		sw $t5 8($a0)
		sw $t6 0($a0)
		
		sw $t3 12($a0)
		sw $t4 4($a0)
		
		
	inner_cont:
	addi $a0 $a0 8
	addi $t2 $t2 1
	j inner_loop

end_inner_loop:
addi $t1 $t1 1
j outer_loop


end_outer_loop:
addi $sp $sp 12
jr $ra

############

remove_dup:
addi $sp $sp -12
sw $a0 0($sp)	#a0 

addi $sp $sp -4
sw $ra 0($sp)
jal length
lw $ra 0($sp)
addi $sp $sp 4

sw $v0 4($sp)	#length

lw $t8 4($sp)	#length
li $t9 8
mult $t8 $t9
mflo $t8 

#calculate space need=
addi $t8 $t8 8
move $a0 $t8
li $v0 9
syscall

#v0 is the new heap

sw $v0 8($sp)		#store head of heap

li $t9 1
lw $t7 4($sp)		#size before end
addi $t7 $t7 1
lw $a0 0($sp)



rd_loop:
beqz $t7 end_rd_loop
beqz $t9 fill_zero
lw $t1 0($a0)		#coeff1
lw $t2 4($a0)		#exp1
lw $t3 8($a0)		#coeff2
lw $t4 12($a0)		#exp2


seq $t5 $t1 $t3
seq $t6 $t2 $t4
and $t5 $t5 $t6		#they are equal

bnez $t5 dup_found

li $t8 -1

seq $t5 $t1 $0
seq $t6 $t2 $t8
and $t5 $t5 $t6		#if 0 , -1 has not yet been reached

bnez $t5 met_end




sw $t1 0($v0)
sw $t2 4($v0)

addi $a0 $a0 8
addi $v0 $v0 8
addi $t7 $t7 -1
j rd_loop
dup_found:
addi $a0 $a0 8
j rd_loop

met_end:
li $t9 0
sw $t1 0($v0)
sw $t2 4($v0)

addi $a0 $a0 8
addi $v0 $v0 8
addi $t7 $t7 -1
j rd_loop

fill_zero:
sw $0 0($v0)
sw $0 4($v0)
addi $a0 $a0 8
addi $v0 $v0 8
addi $t7 $t7 -1
j rd_loop

end_rd_loop:
#v0 is array with no dup
lw $v0 8($sp)	
lw $a0 0($sp)
lw $t0 4($sp)
addi $t0 $t0 1
copy_array:
beqz $t0 end_copy_array
lw $t1 0($v0)
lw $t2 4($v0)

sw $t1 0($a0)
sw $t2 4($a0)

addi $a0 $a0 8
addi $v0 $v0 8
addi $t0 $t0 -1

j copy_array

end_copy_array:

addi $sp $sp 12
jr $ra
########

create_polynomial:
addi $sp $sp -12
sw $ra 0($sp)		#initial return addr
sw $a0 4($sp)		#int[]
sw $a1 8($sp)		#N	

jal bubble_sort
jal remove_dup

lw $ra 0($sp)		#initial return addr
lw $a0 4($sp)		#int[]
lw $a1 8($sp)		#N

addi $sp $sp 12

li $t2 0
li $t9 0		#linklist to be returned
li $t8 0		#counter for terms created



cp_loop:
blez $a1 cont_condition
beq $a1 $t8 end_cp_loop
j cont_condition

cont_condition:
lw $t0 0($a0)		#coeff1
lw $t1 4($a0)		#exp1


add $t2 $t2 $t0		#starting coeff

#1 is 0, -1 -> end
li $t4 -1
seq $t5 $t0 $0
seq $t6 $t1 $t4
and $t5 $t5 $t6		#1 if it is else 0

bnez $t5 end_cp_loop

#2 is 0, -1 -> create 1 and end
li $t4 -1
seq $t5 $t2 $0
seq $t6 $t3 $t4
and $t5 $t5 $t6		#1 if it is else 0

bnez $t5 term_add

lw $t3 12($a0)		#exp2
beq $t1 $t3 same_exp
j check_for_zero

check_for_zero:
beqz $t2 zero
j term_add
zero:
addi $a0 $a0 8
j cp_loop		
	
same_exp:
lw $t4 8($a0)		#coeff2
addi $a0 $a0 8
j cp_loop

term_add:
addi $sp $sp -12
sw $ra 0($sp)		#initial return addr
sw $a0 4($sp)		#int[]
sw $a1 8($sp)		#N



move $a0 $t2
move $a1 $t1

jal create_term
li $t2 0

lw $ra 0($sp)		#initial return addr
lw $a0 4($sp)		#int[]
lw $a1 8($sp)		#N

addi $sp $sp 12

beqz $t9 initialize
sw $v0 8($t9)		#link
move $t9 $v0
j cp_cont

initialize:
move $t9 $v0		#make head
addi $sp $sp -4
sw $t9 0($sp)

cp_cont:
addi $t8 $t8 1
addi $a0 $a0 8
j cp_loop
end_cp_loop:

li $a0 8
li $v0 9
syscall

lw $t9 0($sp)
addi $sp $sp 4
sw $t9 0($v0)			#head addr
sw $t8 4($v0)			#number of terms

jr $ra

create_polynomial_ignore_dup:
addi $sp $sp -12
sw $ra 0($sp)		#initial return addr
sw $a0 4($sp)		#int[]
sw $a1 8($sp)		#N	

jal bubble_sort

lw $ra 0($sp)		#initial return addr
lw $a0 4($sp)		#int[]
lw $a1 8($sp)		#N

addi $sp $sp 12

li $t2 0
li $t9 0		#linklist to be returned
li $t8 0		#counter for terms created



cp_loop_id:
bltz $a1 cont_condition_id
beq $a1 $t8 end_cp_loop_id
j cont_condition_id

cont_condition_id:
lw $t0 0($a0)		#coeff1
lw $t1 4($a0)		#exp1


add $t2 $t2 $t0		#starting coeff

#1 is 0, -1 -> end
li $t4 -1
seq $t5 $t0 $0
seq $t6 $t1 $t4
and $t5 $t5 $t6		#1 if it is else 0

bnez $t5 end_cp_loop_id

#2 is 0, -1 -> create 1 and end
li $t4 -1
seq $t5 $t2 $0
seq $t6 $t3 $t4
and $t5 $t5 $t6		#1 if it is else 0

bnez $t5 term_add_id

lw $t3 12($a0)		#exp2
beq $t1 $t3 same_exp_id
j check_for_zero_id

check_for_zero_id:
beqz $t2 zero_id
j term_add_id
zero_id:
addi $a0 $a0 8
j cp_loop_id		
	
same_exp_id:
lw $t4 8($a0)		#coeff2
addi $a0 $a0 8
j cp_loop_id

term_add_id:
addi $sp $sp -12
sw $ra 0($sp)		#initial return addr
sw $a0 4($sp)		#int[]
sw $a1 8($sp)		#N



move $a0 $t2
move $a1 $t1

jal create_term
li $t2 0

lw $ra 0($sp)		#initial return addr
lw $a0 4($sp)		#int[]
lw $a1 8($sp)		#N

addi $sp $sp 12

beqz $t9 initialize_id
sw $v0 8($t9)		#link
move $t9 $v0
j cp_cont_id

initialize_id:
move $t9 $v0		#make head
addi $sp $sp -4
sw $t9 0($sp)

cp_cont_id:
addi $t8 $t8 1
addi $a0 $a0 8
j cp_loop_id
end_cp_loop_id:

li $a0 8
li $v0 9
syscall

lw $t9 0($sp)
addi $sp $sp 4
sw $t9 0($v0)			#head addr
sw $t8 4($v0)			#number of terms

jr $ra



.globl add_polynomial
check_polynomial_zero:
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp)
sw $a1 8($sp)

lw $t0 4($a0)	#length
lw $t1 4($a1)	#length

bne $t0 $t1 false

lw $t1 0($a0)	#addr1
lw $t2 0($a1)	#addr2

lw $t0 4($a0)	#length
loop_through_link:
beqz $t0 end_loop_though_link
beqz $t1 false
beqz $t2 false

lw $t3 0($t1)	#coef1
lw $t4 4($t1)	#exp1
lw $t5 0($t2)	#cef2
lw $t6 4($t2)	#exp2

seq $t7 $t4 $t6
add $t8 $t3 $t5
seq $t8 $t8 $0

and $t7 $t7 $t8	#if they are that

bnez $t7 false

addi $t0 $t0 -1
lw $t1 8($t1)	#next
lw $t2 8($t2)
j loop_through_link

end_loop_though_link:
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
li $v0 1
jr $ra

false:
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
li $v0 0
jr $ra

add_polynomial:
addi $sp $sp -20
sw $ra 0($sp)
sw $a0 4($sp)
sw $a1 8($sp)

#check if p or q is null
seq $t0 $a0 $zero
seq $t1 $a1 $zero
and $t2 $t1 $t0		#1 if both are null

bgtz $t2 return_null

beqz $a0 return_q
beqz $a1 return_p

#check address if null
lw $t0 0($a0)
lw $t1 0($a1)

seq $t0 $t0 $0
seq $t1 $t1 $0
and $t2 $t1 $t0		#1 if both are null
bgtz $t2 return_null


lw $t0 0($a0)
beqz $t0 return_q
lw $t0 0($a1)
beqz $t0 return_p


#jal check_polynomial_zero

#beqz $v0 return_null

lw $t0 4($a0)		#size of p
lw $t1 4($a1)		#size of q

add $t0 $t0 $t1		#
li $t1 8
mult $t0 $t1
mflo $t0		#byte need for all terms


addi $t0 $t0 8		#to append 0 and -1 later

sw $t0 12($sp)		#space


move $a0 $t0
li $v0 9
syscall

sw $v0 16($sp)		#store head

lw $a0 4($sp)		#load back
lw $a1 8($sp)		#load back

lw $a0 0($a0)		#load head
lw $a1 0($a1)		#load head
#v0 is now the address of our heap array


#p loop
ap_loop_p:
lw $t1 0($a0)		#coeff
lw $t2 4($a0)		#exp
lw $t3 8($a0)		#address
beqz $t3 end_ap_loop_p
sw $t1 0($v0)
sw $t2 4($v0)

addi $a0 $a0 12
addi $v0 $v0 8
j ap_loop_p

end_ap_loop_p:
sw $t1 0($v0)
sw $t2 4($v0)
addi $v0 $v0 8


#q loop
ap_loop_q:
lw $t1 0($a1)		#coeff
lw $t2 4($a1)		#exp
lw $t3 8($a1)		#address
beqz $t3 end_ap_loop_q
sw $t1 0($v0)
sw $t2 4($v0)

addi $a1 $a1 12
addi $v0 $v0 8
j ap_loop_q

end_ap_loop_q:
sw $t1 0($v0)
sw $t2 4($v0)
addi $v0 $v0 8



#append 0 and -1
li $t1 -1
sw $0 0($v0)
sw $t1 4($v0)
 
#prepare for method

lw $a0 16($sp)
lw $a1 12($sp)

lw $t7 0($sp)

jal create_polynomial_ignore_dup

lw $t0 4($v0)

bnez $t0 skip_to_end
li $v0 0

skip_to_end:
move $ra $t7
addi $sp $sp 20
jr $ra

return_p:
lw $ra 0($sp)
addi $sp $sp 20
move $v0 $a0
jr $ra

return_q:
lw $ra 0($sp)
addi $sp $sp 20
move $v0 $a1
jr $ra

return_null:
lw $ra 0($sp)
addi $sp $sp 20
li $v0 0
jr $ra

.globl mult_polynomial

mult_polynomial:
addi $sp $sp -20
sw $ra 0($sp)	#return address
sw $a0 4($sp)	#p
sw $a1 8($sp)	#q


#check if p or q is null
seq $t0 $a0 $0
seq $t1 $a1 $0
and $t2 $t1 $t0		#1 if both are null

bgtz $t2 return_null_m
beqz $a0 return_q_m
beqz $a1 return_p_m

#check address if null
lw $t0 0($a0)
lw $t1 0($a1)

seq $t0 $t0 $0
seq $t1 $t1 $0
and $t2 $t1 $t0		#1 if both are null

bgtz $t2 return_null_m

lw $t0 0($a0)
beqz $t0 return_q_m
lw $t0 0($a1)
beqz $t0 return_p_m

#calculate space need for heap
#(p.size * q.size * 8) + 8
lw $t0 4($a0)	#number of terms p
lw $t1 4($a1)	#number of terms q


mult $t0 $t1
mflo $t0	#p.size * q.size

sll $t0 $t0 3	#x8

addi $t0 $t0 8	#+8

sw $t0 12($sp)	#save for maybe later use

move $a0 $t0
li $v0 9
syscall

sw $v0 16($sp)	#array created in heap

#v0 is the head of the array
#multiply terms and add to array

#load everything back
lw $a0 4($sp)
lw $a1 8($sp)


lw $t9 0($a0)	#address of p
lw $t8 0($a1)	#address of q

move $t0 $t9	#copy
move $t1 $t8	#copy

####LOOP START
mult_outer:
beqz $t0 end_mult_outer	#if coeff hit 0
lw $t2 0($t0)	#coeff1
lw $t3 4($t0)	#exp1


move $t1 $t8	#reset inner loop
mult_inner:
beqz $t1 end_mult_inner #if coeff hit 0
lw $t4 0($t1)	#coeff2
lw $t5 4($t1)	#exp2


#compute new term to add to heap
mult $t2 $t4
mflo $t4	#product of the coefficents

add $t5 $t5 $t3#sum of the exponents

sw $t4 0($v0)	#store term
sw $t5 4($v0)

lw $t1 8($t1) #next term of p
addi $v0 $v0 8	#go to next term in array

j mult_inner
end_mult_inner:
lw $t0 8($t0) #next term of p
j mult_outer


end_mult_outer:
##WHEN LOOP IS DONE
#append 0 and -1
li $t1 -1
sw $0 0($v0)
sw $t1 4($v0)

##CREATE POLY

lw $a0 16($sp)	#Start of the array
lw $a1 12($sp)	#N this this will always be the biggest

lw $t7 0($sp)

jal create_polynomial_ignore_dup

lw $t0 0($v0)
lw $t1 0($t0)
lw $t2 4($t0)


seq $t1 $t1 $0
seq $t2 $t2 $0
and $t1 $t1 $t2 

beqz $t1 skip_to_end_m
li $v0 0

skip_to_end_m:
move $ra $t7	#return address
addi $sp $sp 20
jr $ra

return_p_m:
lw $ra 0($sp)
addi $sp $sp 20
move $v0 $a0
jr $ra

return_q_m:
lw $ra 0($sp)
addi $sp $sp 20
move $v0 $a1
jr $ra

return_null_m:
lw $ra 0($sp)
addi $sp $sp 20
li $v0 0
jr $ra




