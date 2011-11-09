#-------------------------------------
#----fun.s
#----Assignment 2
#----CS350
#----Chris Blades
#
# Implementation of three functions:  strlen, mem_align, and strncpy as
# well as a driver to test them.  
#-------------------------------------

    .data
# Space for user input string, 246 max length 
input:     	.space  256
# Space to copy input to
copySpace:	.space 256
#  max allowed length of user input
maxLength:	.word   256
# 
# Various prompts for formatting output from driver tests
#
prompt:    	.asciiz "Please enter a string >  "
test1:      	.asciiz "Test1:\nThe length of the string \""
test1_b:      	.asciiz "\" is:  "
test2:		.asciiz "Test2:\nThe new String is:  "
test3:		.asciiz "Test 3:\n"
 five:		.asciiz "Five:  "
  six:		.asciiz "Six:  "
seven:		.asciiz "Seven:  "
eight:		.asciiz "Eight:  "
newLine:	.asciiz "\n"


    .text
main:
# prompt for user input
la $a0, prompt
li $v0, 4
syscall

# read user input
la $s0, maxLength
lw $a1, 0($s0)
la $a0, input
li $v0, 8
syscall

la $a0, newLine
li $v0, 4
syscall

#
# Remove newline from input
#
# strlen call
la $a0, input
la $a1, maxLength
lw $a1, 0($a1)
jal strlen

move $s2, $v0
la $s3, input
addi $s2, $s2, -1
add $s3, $s3, $s2
sb $0, 0($s3)

#
# Test 1
#

# print various static output
la $a0, test1
li $v0, 4
syscall

la $a0, input
li $v0, 4
syscall

la $a0, test1_b
li $v0, 4
syscall

# strlen call
la $a0, input
la $a1, maxLength
lw $a1, 0($a1)
jal strlen

# print result of strlen
move $a0, $v0
li $v0, 1
syscall

la $a0, newLine
li $v0, 4
syscall

la $a0, newLine
li $v0, 4
syscall


#
# Test 2
#

la $a0, test2
li $v0, 4
syscall

la $a0, copySpace
la $a1, input
la $a3, maxLength
lw $a3, 0($a3)
jal strncpy

la $a0, copySpace
li $v0, 4
syscall

la $a0, newLine
li $v0, 4
syscall

la $a0, newLine
li $v0, 4
syscall

#
# Test 3
#
la $a0, test3
li $v0, 4
syscall

la $a0, five
li $v0, 4
syscall

li $a0, 5
jal mem_align

move $a0, $v0
li $v0, 1
syscall

la $a0, newLine
li $v0, 4
syscall

la $a0, six
li $v0, 4
syscall

li $a0, 6
jal mem_align

move $a0, $v0
li $v0, 1
syscall

la $a0, newLine
li $v0, 4
syscall

la $a0, seven
li $v0, 4
syscall

li $a0, 7
jal mem_align

move $a0, $v0
li $v0, 1
syscall

la $a0, newLine
li $v0, 4
syscall

la $a0, eight
li $v0, 4
syscall

li $a0, 8
jal mem_align

move $a0, $v0
li $v0, 1
syscall

la $a0, newLine
li $v0, 4
syscall

li $v0, 10
syscall

#------mem_align-----------------
# $a0 - integer representing number of bytes
#
# Finds and returns the remainder of $a0 divided by 4 or 4 if the remainder
# is 0
#
# registers:
# s0 boolean, if $a0 is less than $s1
# s1 incrementing multiples of 4, used to find multiple of 4 closest to and
#    greater than $a0
mem_align:

# store registers on stack
addi $sp, $sp, -4
sw $s0, 0($sp)
addi $sp, $sp, -4
sw $s1, 0($sp)
li $s0, 0
li $s1, 0

memloop:
bne $s0, $zero, memDone
addi $s1, $s1, 4
slt $s0, $a0, $s1
j memloop

memDone:
addi $s1, $s1, -4
sub $v0, $a0, $s1

# if remainder is 0, should return 4
bne $v0, $0, cleanUp
li $v0, 4

# restore registers
cleanUp:
lw $s1, 0($sp)
addi $sp, $sp, 4
lw $s0, 0($sp)
addi $sp, $sp, 4

jr $ra

#------strncpy-------------------
# $a0  destination address to copy string to
# $a1  source address to copy string from
# $a3  max length of copied string
#
# Copies a string stored at the address stored in $a1 to memory starting at
# address $a0 up to $a3 characters.
#
# registers:
# $s0 boolean, if number of characters copied is less than max length
# $s1 current character being copied
# $s2 number of characters that have been copied
#
strncpy:

# store registers
addi $sp, $sp, -4
sw $s0, 0($sp)
addi $sp, $sp, -4
sw $s1, 0($sp)
addi $sp, $sp, -4
sw $s2, 0($sp)
li $s0, 0
li $s1, 0
li $s2, 0

# load first character from source string and go ahead and compare
# $s0 to the max length in case it's 0
lb $s1, 0($a1)
slt $s0, $s2, $a3
cpyLoop:
# done if we've copied the max number of characters or if we reach \0
beq $s0, $0, cpyClean
beq $s1, $0, cpyClean
# copy from source to destination
sb $s1, 0($a0)
# increment source and destination addresses and number of characters
# copied
addi $s2, $s2, 1
addi $a1, $a1, 1
addi $a0, $a0, 1
# load next character
lb $s1, 0($a1)
# check number of characters copied against max length
slt $s0, $s2, $a3
j cpyLoop

cpyClean:
# restore registers
lw $s2, 0($sp)
addi $sp, $sp, 4
lw $s1, 0($sp)
addi $sp, $sp, 4
lw $s0, 0($sp)
addi $sp, $sp, 4

jr $ra

#------strlen--------------------
# $a0  address of string to find the length of
# $a1  max length of string at address $a0
#
# Finds the length of the string at address $a0 up to a max length of $a3.
# Considers 0x00 to represent the end of a string.
#
# registers:
# $s0 used to count characters
# $s1 holds the current character being counted
#
strlen:

# store registers on the stack
addi $sp, $sp, -4
sw $s0, 0($sp)
addi $sp, $sp, -4
sw $s1, 0($sp)

# set current count to 0 and load the first character
li $s0 0
lb $s1 0($a0)

lenLoop:
# done if the current character equals 0x00 or if we've reached max length
beq $s1, $zero, lenDone
beq $s0, $a1, lenDone
# increment character count and address
addi $s0, $s0, 1
addi $a0, $a0, 1
# load next character
lb $s1, 0($a0)
j lenLoop

lenDone:
# restore registers from stack
move $v0, $s0
lw $s1, 0($sp)
addi $sp, $sp, 4
lw $s0, 0($sp)
addi $sp, $sp, 4

jr $ra
