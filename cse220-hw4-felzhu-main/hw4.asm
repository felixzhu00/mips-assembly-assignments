############## Felix Zhu ##############
############## 113450017 #################
############## felzhu ################

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:
.globl create_person
create_person:
#a0 = network addr
lw $t0 16($a0)		#curr_num_of_nodes (bytes 16 - 19)
lw $t1 0($a0)		#total_nodes (bytes 0 - 3)
bge $t0 $t1 numExceed	#current>=total

lw $t0 20($a0)		#curr_num_of_edges (bytes 20 - 23)
lw $t1 4($a0)		#total_edges (bytes 4- 7)
bgt $t0 $t1 numExceed	#current>total

#add Node to Array
#set of nodes (bytes 36 - 71) 36 + (cur_num_of_nodes * size_of_node)
lw $t0 16($a0)		#cur_num_of_nodes
lw $t1 8($a0)		#size_of_node
mult $t0 $t1		#mult
mflo $t0		#store
addi $t0, $t0, 36	#increment 36

add $t0 $a0 $t0	#return address

move $v0 $t0


#increment curr_num_of_nodes
lw $t0 16($a0)
addi $t0 $t0, 1
sw $t0 16($a0)
j complete
#error label
numExceed:
li $v0 -1
complete:
jr $ra

.globl is_person_exists
is_person_exists:
lw $t0 16($a0)		#curr_num_of_nodes (bytes 16 - 19)
lw $t1 0($a0)		#total_nodes (bytes 0 - 3)
bgt $t0 $t1 notexist	#current>total

lw $t0 20($a0)		#curr_num_of_edges (bytes 20 - 23)
lw $t1 4($a0)		#total_edges (bytes 4- 7)
bgt $t0 $t1 notexist	#current>total

#loop
li $t2 0		#counter
loop:
lw $t0 16($a0)		#curr_num_of_nodes (bytes 16 - 19)
bge $t2 $t0 notexist	#incr >= curr -> break

lw $t1 8($a0)		#size_of_node (bytes 8 - 11)	$t0?
mult $t2 $t1		#mult
mflo $t1		#store

add $t1 $t1 $a0		#compute address
addi $t1 $t1 36		#compute address
beq $t1 $a1 endloop	#addr reached

addi $t2 $t2 1		#++
j loop

#endloop
endloop:
li $v0 1
jr $ra

notexist:
li $v0 0
jr $ra

.globl is_person_name_exists
equals:
loopequals:
lbu $t0 0($a0)
lbu $t1 0($a1)

beqz $t0 endequals
beqz $t1 endequals

bne $t0 $t1 notequal
addi $a0 $a0 1
addi $a1 $a1 1
j loopequals

endequals:
lbu $t0 0($a0)
bnez $t0 notequal
lbu $t1 0($a1)
bnez $t1 notequal
li $v0 1
jr $ra
notequal:
li $v0 0
jr $ra


is_person_name_exists:
move $t9 $a0
move $t8 $a1

lw $t0 16($t9)		#curr_num_of_nodes (bytes 16 - 19)
lw $t1 0($t9)		#total_nodes (bytes 0 - 3)
bgt $t0 $t1 notnameexist#current>total

lw $t0 20($t9)		#curr_num_of_edges (bytes 20 - 23)
lw $t1 4($t9)		#total_edges (bytes 4- 7)
bgt $t0 $t1 notnameexist#current>total


li $t2 0		#counter
loop1:
lw $t0 16($t9)		#curr_num_of_nodes (bytes 16 - 19)
beq $t2 $t0 notnameexist#name not found

lw $t1 8($t9)		#size_of_node (bytes 8 - 11)
mult $t2 $t1		#mult
mflo $t1		#store

add $t1 $t1 $t9		#compute address
addi $t1 $t1 36		#compute address


move $t7 $t1		#store address

move $a0 $t1		#load Str1
move $a1 $t8		#load Str2

addi $sp $sp -4
sw $ra 0($sp)
jal equals		#equal check
lw $ra 0($sp)
addi $sp $sp 4

bgtz $v0 endloop1	#if equal end

addi $t2 $t2 1		#++
j loop1

notnameexist:
li $v0 0
j complete1
endloop1:
li $v0 1
move $v1 $t7
complete1:
jr $ra


.globl add_person_property
length:
li $t0 0
looplength:
lb $t1 0($a0)
beqz $t1 endlooplength
addi $t0 $t0 1
addi $a0 $a0 1
j looplength
endlooplength:
move $v0 $t0
jr $ra

copy:
move $t1 $a0
loopcopy:
lbu $t0 0($a0)
beqz $t0 endloopcopy
sb $t0 0($a1)

addi $a0 $a0 1
addi $a1 $a1 1
j loopcopy
endloopcopy:
addi $sp $sp -4
sw $ra 0($sp)

move $a0 $t1
jal length

lw $ra 0($sp)
addi $sp $sp 4

jr $ra





add_person_property:
addi $sp $sp -20
sw $ra 0($sp)		#addr
sw $a0 4($sp)		#network
sw $a1 8($sp)		#node
sw $a2 12($sp)		#prop_name
sw $a3 16($sp)		#prop_val

#check prop_name is equal to the string “NAME”
lw $a0 12($sp)
lw $a1 4($sp)
addi $a1 $a1 24		#Name property (bytes 24 - 28)
jal equals
beqz $v0 condition1

#check person exists in Network
lw $a0 4($sp)
lw $a1 8($sp)
jal is_person_exists
beqz $v0 condition2

#check The no. of characters in prop_val(excluding null character) < Network.size_of_node
lw $a0 16($sp)
jal length

lw $t0 4($sp)
lw $t1 8($t0)		#size_of_node (bytes 8 - 11)

bge $v0 $t1 condition3

#check prop_val is unique in the Network.
lw $a0 4($sp)
lw $a1 16($sp)
jal is_person_name_exists

bgtz $v0 condition4

#else
lw $a0 16($sp)
lw $a1 8($sp)
jal copy

li $v0 1
j done
condition1:
li $v0 0
j done
condition2:
li $v0 -1
j done
condition3:
li $v0 -2
j done
condition4:
li $v0 -3
j done

done:
lw $ra 0($sp)
addi $sp $sp 20
jr $ra

.globl get_person
get_person:
addi $sp $sp -20
sw $ra 0($sp)		#addr
sw $a0 4($sp)		#network
sw $a1 8($sp)		#char

lw $t0 16($a0)		#curr_num_of_nodes (bytes 16 - 19)
lw $t1 0($a0)		#total_nodes (bytes 0 - 3)
bgt $t0 $t1 notperson	#current>total

lw $t0 20($a0)		#curr_num_of_edges (bytes 20 - 23)
lw $t1 4($a0)		#total_edges (bytes 4- 7)
bgt $t0 $t1 notperson	#current>total

jal is_person_name_exists

beqz $v0 notperson
j complete3

complete3:
move $v0 $v1
j done2

notperson:
li $v0 0
j done2

done2:
lw $ra 0($sp)
addi $sp $sp 20
jr $ra


.globl is_relation_exists
is_relation_exists_helper:
lw $t0 16($a0)		#curr_num_of_nodes (bytes 16 - 19)
lw $t1 0($a0)		#total_nodes (bytes 0 - 3)
bgt $t0 $t1 notrelation	#current>total

lw $t0 20($a0)		#curr_num_of_edges (bytes 20 - 23)
lw $t1 4($a0)		#total_edges (bytes 4- 7)
bgt $t0 $t1 notrelation	#current>total

#calculation location of the edge array
#36 + total_node*size_of_node = start

lw $t0 0($a0)		#total node
lw $t1 8($a0)		#node size
mult $t0 $t1		#total_node*size_of_node
mflo $t0
addi $t2 $t0 36		#start

#check if node is in proper addr
li $t0 4
div $t2 $t0		#start/4
mfhi $t1		#$t2 mod 4

#check multiple of 4 and fix
beqz $t1 nofix
sub $t3 $t0 $t1		#4-($t2 mod 4) complement
add $t2 $t2 $t3		
nofix:
add $t2 $a0 $t2

li $t4 0		#counter
looprelation:
lw $t0 20($a0)		
beq $t0 $t4 notrelation

lw $t0 0($t2)
lw $t1 4($t2)
beqz $t0 notrelation
beqz $t1 notrelation

seq $t9 $t0 $a1
seq $t8 $t1 $a2
and $t9 $t9 $t8
bnez $t9 endrelationloop

seq $t9 $t0 $a2
seq $t8 $t1 $a1
and $t9 $t9 $t8
bnez $t9 endrelationloop

addi $t2 $t2 12
addi $t4 $t4 1
j looprelation

notrelation:
li $v0 0
move $v1 $t2

j done3
endrelationloop:
li $v0 1
j done3
done3:
jr $ra


is_relation_exists:
addi $sp $sp -4
sw $ra 0($sp)		#addr

jal is_relation_exists_helper
li $v1 0		#addr not needed

lw $ra 0($sp)
addi $sp $sp 4
jr $ra


.globl add_relation
add_relation:
addi $sp $sp -16
sw $ra 0($sp)		#addr
sw $a0 4($sp)		#network
sw $a1 8($sp)		#person1
sw $a2 12($sp)		#person2

#check condition 1
jal is_person_exists
beqz $v0 rcondition1
move $a1 $a2
jal is_person_exists
beqz $v0 rcondition1

#check condition 2
lw $t0 20($a0)
lw $t1 4($a0)
bge $t0 $t1 rcondition2
#bltz $t0 rcondition2


#check condition 3
lw $a0 4($sp)
lw $a1 8($sp)
lw $a2 12($sp)

jal is_relation_exists

bnez $v0 rcondition3

#check condition 4

lw $a0 8($sp)#
lw $a1 12($sp)#

beq $a0 $a1 rcondition4

jal equals

#bnez $v0 rcondition4

#else
lw $a0 4($sp)		#network
lw $a1 8($sp)		#person1
lw $a2 12($sp)		#person2

lw $t0 0($a0)
lw $t1 8($a0)
mult $t0 $t1
mflo $t0
addi $t2 $t0 36

#check multiple of 4
li $t0 4
div $t2 $t0		#start/4
mfhi $t1		#$t2 % 4
beqz $t1 skip		

sub $t0 $t0 $t1		#get complement
add $t2 $t2 $t0		#add to calculated

skip:
add $t2 $a0 $t2		#position of edge

lw $t0 20($a0)		#current edge
li $t1 12		
mult $t0 $t1
mflo $t0
add $t2 $t2 $t0		#next location

sw $a1 0($t2)
sw $a2 4($t2)

lw $t0 20($a0)
addi $t0 $t0 1
sw $t0 20($a0)

li $v0 1
j done4

rcondition1:
li $v0 0
j done4
rcondition2:
li $v0 -1
j done4
rcondition3:
li $v0 -2
j done4
rcondition4:
li $v0 -3
j done4

done4:
lw $ra 0($sp)
addi $sp $sp 16
jr $ra


.globl add_relation_property
add_relation_property:
addi $sp $sp -24
sw $ra 0($sp)		#addr
sw $a0 4($sp)		#newtwork
sw $a1 8($sp)		#person1
sw $a2 12($sp)		#person2
sw $a3 16($sp)		#prop_name

lw $t0 16($a0)		#curr_num_of_nodes (bytes 16 - 19)
lw $t1 0($a0)		#total_nodes (bytes 0 - 3)
bgt $t0 $t1 econdition1	#current>total

lw $t0 20($a0)		#curr_num_of_edges (bytes 20 - 23)
lw $t1 4($a0)		#total_edges (bytes 4- 7)
bgt $t0 $t1 econdition1	#current>total


#condition1
jal add_relation_property_helper
sw $v1 20($sp)
beqz $v0 econdition1
#condition2
lw $a0 16($sp)
lw $a1 4($sp)
addi $a1, $a1, 29
jal equals
beqz $v0 econdition2
#else
li $t0 1
lw $v1 20($sp)
sw $t0 8($v1)

li $v0 1
j done5
econdition1:
li $v0 0
j done5
econdition2:
li $v0 -1
j done5

done5:
lw $ra 0($sp)		#addr
addi $sp $sp -24
jr $ra

add_relation_property_helper:
lw $t0 20($a0) 
lw $t7 0($a0)
lw $t6 8($a0)

mult $t6 $t7
mflo $t1
addi $t1 $t1 36
add $t1 $t1 $a0
	
move $t2 $t0 

helperloop:
beqz $t2 helpernotfound
	
lw $t3 0($t1)
beq $t3 $a1 firstequal
beq $t3 $a2 secondequal
j ending
		
firstequal:
lw $t3 4($t1)
beq $t3 $a2 helperfound
j ending

secondequal:
lw $t3 4($t1)
beq $t3 $a1 helperfound
j ending

ending:
addi $t1 $t1 12
addi $t2 $t2 -1
j helperloop
	
helperfound:
move $v1 $t1
li $v0 1
jr $ra
			
helpernotfound:
li $v0 0
jr $ra


.globl is_friend_of_friend
is_friend_of_friend:
addi $sp $sp -32
sw $ra 0($sp)
sw $a0 4($sp)
sw $a1 8($sp)
sw $a2 12($sp)
	
#check if person exist
lw $a0 4($sp)
lw $a1 8($sp)
jal is_person_name_exists
beqz $v0 errorexist
sw $v1 16($sp)
	

lw $a0 4($sp)
lw $a1 12($sp)
jal is_person_name_exists
beqz $v0 errorexist
sw $v1 20($sp)



#Calculate the start of edge
lw $t0 4($sp)
lw $t1 0($t0)
lw $t2 8($t0)
mult $t1 $t2
mflo $t1
addi $t0 $t0 36
add $t0 $t0 $t1

#Loop
lw $t2 4($sp)
lw $t1 20($t2)
floop:
beqz $t1 isfalse

#compare
lw $t2 16($sp)
lw $t3 0($t0)
beq $t2 $t3 fequal		
lw $t3 4($t0)
beq $t2 $t3 sequal
j cont1

#first
fequal:
lw $t2 8($t0)
li $t3 1
bne $t2 $t3 cont1

lw $a1 4($t0)
lw $a0 4($sp)
lw $a2 20($sp)

sw $t0 24($sp)
sw $t1 28($sp)
jal friendexistshelper
lw $t0 24($sp)
lw $t1 28($sp)

beqz $v0 cont1
j next

#second
sequal:
lw $t2 8($t0)
li $t3 1
bne $t2 $t3 cont1
		
lw $a1 0($t0)
lw $a0 4($sp)
lw $a2 20($sp)
			
sw $t0 24($sp)
sw $t1 28($sp)
jal friendexistshelper
lw $t0 24($sp)
lw $t1 28($sp)

beqz $v0 cont1
j next

cont1:
addi $t0 $t0 12
addi $t1 $t1 -1
j floop


isfalse:
li $v0 0
j completeoperation
		
next:
lw $a0 4($sp)
lw $a1 16($sp)
lw $a2 20($sp)

sw $t0 24($sp)
sw $t1 28($sp)
jal friendexistshelper
lw $t0 24($sp)
lw $t1 28($sp)

li $t2 1
beq $v0 $t2 cont1
li $v0 1
j completeoperation
		
errorexist:
li $v0 -1
j completeoperation

completeoperation:
lw $ra 0($sp)
addi $sp $sp 32
jr $ra













































































friendexistshelper:
#calculate
lw $t0 20($a0)
lw $t1 0($a0)
lw $t2 8($a0)
mult $t2 $t1
mflo $t1
addi $t1 $t1 36
add $t1 $t1 $a0	#obtain addr

move $t2 $t0
friendhelperloop:
beqz $t2 fhelpernotfound
	
lw $t3 0($t1)
beq $t3 $a1 firstequal1 # Is first equal
beq $t3 $a2 secondequal1 # Is second equal
j endinghelperloop
		
firstequal1:
lw $t3 4($t1)
beq $t3 $a2 fhelperfound
j endinghelperloop

secondequal1:
lw $t3 4($t1)
beq $t3 $a1 fhelperfound
j endinghelperloop
			
endinghelperloop:
addi $t2 $t2 -1
addi $t1 $t1 12
j friendhelperloop
	
fhelperfound:
li $t0 1
lw $t1 8($t1)
beq $t0 $t1 istrue
j fhelpernotfound
		
istrue:
li $v0 1
jr $ra
			
fhelpernotfound:
li $v0 0
jr $ra




