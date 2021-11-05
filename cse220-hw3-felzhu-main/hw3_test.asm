# This is a test file. Use this file to run the functions in hw3.asm
#
# Change data section as you deem fit.
# Change filepath if necessary.
.data
Filename: .asciiz "inputs/input5.txt"
OutFile: .asciiz "out.txt"
Buffer:
    .word 3	# num rows
    .word 2	# num columns
    # matrix
    .word 1 2 3 4 5 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0


.text
main:
 la $a0, Buffer
 la $a1, OutFile
 jal rotate_clkws_90

 # write additional test code as you deem fit.





 li $v0, 10
 syscall

.include "hw3.asm"
