################# Felix Zhu #################
################# felzhu #################
################# 113450017 #################

################# DO NOT CHANGE THE DATA SECTION #################

.text
.globl to_upper
to_upper:
    li $t2, 97
    li $t3, 122
    move $t4, $a0
loop:
    lb $t1, 0($a0)
    beqz $t1, exit
    blt $t1, $t2, incre
    bgt $t1, $t3, incre
    addi $t1, $t1, -32
    sb $t1, 0($a0)
incre: 
    addi $a0, $a0, 1
    j loop
exit:
 move $a0, $t4
 jr $ra
#####################################
.globl remove
remove:
    li $t2, 0
    li $t3, 1
    move $a3, $a0
loop2:
    lb $t1, 0($a0)
    beqz $t1, exit2
    beq $t2, $a1, way2
    beqz $t3, way2
way1:
    sb $t1, 0($a0)
    addi $a0, $a0, 1
    addi $t2, $t2, 1
    j loop2
way2:
    li $t3, 0
    lb $t1, 1($a0)
    sb $t1, 0($a0)
    addi $a0, $a0, 1
    addi $t2, $t2, 1
    j loop2
exit2:
bgt $a1, $t2, setv0
bltz $a1, setv0
li $v0, 1
j end
setv0:
li $v0, -1
end:
move $a0, $a3
 jr $ra
#####################################
.globl getRandomInt
getRandomInt:
blez $a0, other 
move $a1, $a0
li $a0, 0
li $v0 42
syscall
move $v0,$a0
li $v1, 1
j end2
other:
li $v0, -1
li $v1, 0
end2:
jr $ra
#####################################
.globl cpyElems
cpyElems: #t0,t1,t2
    move $t0, $a1
    li $t2, 0
    move $t4, $a0
loop3:
    lb $t1, 0($a0)
    beq $t0, $t2, copy
    beqz $t1, exit3
    addi $a0, $a0, 1
    addi $t2, $t2, 1
    j loop3
copy:
    sb $t1, 0($a2)
    addi $t2, $a2, 1
    move $v0, $t2

    j exit3
exit3:
move $a0,$t4
jr $ra
#####################################
.globl genKey
genKey:
addi $sp, $sp, -4
sw $ra, 0($sp)
li $t8, 26		#counter

move $t7, $a1
move $t6, $a0

loop5:
lb $t5, 0($a0)
beqz $t5, exit5         
move $a0, $t8
jal getRandomInt
addi $t8, $t8, -1
move $a0, $t6
move $a1, $v0
move $a2, $t7
jal cpyElems
move $t7, $v0
move $a0, $t6
jal remove
move $t6, $a0
j loop5
exit5:
move $a0, $s0
move $a1, $s1


lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra
#####################################
.globl contains
contains:#t0,t1,t2
     li $t0, 0
     move $t1, $a1
loop4:
     lb $t2, 0($a0)
     beq $t2, $t1, obtain
     beqz $t2, not_obtain
     addi $a0, $a0, 1
     addi $t0, $t0, 1
     j loop4
obtain:
     move $v0, $t0
     j exit4
not_obtain:
     li $v0, -1
     j exit4
exit4:
 jr $ra
 #####################################
.globl pair_exists
pair_exists:

loop6:

move $t9, $a0
move $t8, $a1
move $t7, $a2
move $t6, $ra

li $t1, 65
li $t2, 90

blt $t9,$t1, not_work
blt $t8,$t1, not_work

bgt $t9,$t2, not_work
bgt $t8,$t2, not_work

move $a0, $t7
move $a1, $t9
jal contains

move $t5, $v0

move $a0, $t7
move $a1, $t8
jal contains

move $t4, $v0

li $t2, -1
li $t1, 1
li $t9, 2

div $t4, $t9
mfhi $t8

div $t5, $t9
mfhi $t7

sub $t3, $t7, $t8

beq $t3, $t2, work
beq $t3, $t1, work
j not_work
work:
sub $t3, $t4, $t5

beq $t3, $t2, work1
beq $t3, $t1, work1

not_work:
li $v0, 0
j final

work1:
li $v0, 1

final:
move $ra, $t6
jr $ra
#####################################
.globl encrypt
encrypt:

addi $sp, $sp, -12
sw $a2, 8($sp) #final
sw $ra, 4($sp) #addr
jal to_upper

move $a3, $a0	#text
sw $a1, 0($sp)	#key	

li $t9, ' '


while:
lb $t8, 0($a3)
beqz $t8, null

move $a1, $t8
lw $a0, 0($sp)
beq $t9, $a1, space
jal contains
blt $v0, $0, fail

li $t4, 2
div $v0, $t4
mfhi $t6
beqz $t6, zero
bgt $t6, $0, one
zero:
addi $v0, $v0, 1
j cont
one:
addi $v0, $v0, -1

cont:
lw $a0, 0($sp)
move $a1, $v0
jal cpyElems
move $a2, $v0
j inc

space:
sb $t9, 0($a2)
addi $a2, $a2, 1

inc:
addi $a3, $a3, 1
j while

null:
li $v0, 1
j ending

fail:
lw $a2, 8($sp)
inner:
lb $t8, 0($a2)
beqz $t8, donedone
sb $0, 0($a2)
addi $a2, $a2, 1
j inner
donedone:
li $v0, 0
ending:
lw $ra, 4($sp)
lw $a2, 8($sp)
addi $sp, $sp, 12
jr $ra

#####################################

.globl decipher_key_with_chosen_plaintext
decipher_key_with_chosen_plaintext:

addi $sp, $sp, -12	#12 space
sw $a0, 8($sp)	#plain
sw $a1, 4($sp)	#crpt
sw $ra, 0($sp)	#addr
move $a3, $a2	#key


forevery:
lw $t0, 8($sp)
lw $t1, 4($sp)

lb $t2, 0($t0)
lb $t3, 0($t1)

li $t4 ' '
beq $t2, $t4, incc
beqz $t2, donedonedone
move $a0, $t2
move $a1, $t3

addi $sp, $sp, -8

sw $a0 0($sp)
sw $a1 4($sp)

jal pair_exists

lw $a0 0($sp)
lw $a1 4($sp)

addi $sp, $sp, 8

beqz $v0, notexist
j incc
notexist:
sb $a0, 0($a3)
addi $a3, $a3, 1
sb $a1, 0($a3)
addi $a3, $a3, 1
j incc
incc:
lw $t0, 8($sp)
lw $t1, 4($sp)

addi $t0, $t0, 1
addi $t1, $t1, 1

sw $t0, 8($sp)
sw $t1, 4($sp)
j forevery

donedonedone:
move $a2,$a3
lw $ra, 0($sp)
addi $sp, $sp, 12

 jr $ra


# plaintext ciphertext key
# for every t in plaintext
# if t and cipertext[t] is in key (checkpair)
# pass
# else
# key1 and key2 = (t, ciphertext[t])