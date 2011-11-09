#####################################
# Match.s
#
# Chris Blades
# 24/3/2010
# CS350
# Dr. Kreahling
#
# Gets a string from the user and determines if the given string is a palindrome or not.
####################################

    .data
true:      .word   1				# value to use for 'true'
false:     .word   0				# value to use for 'false'
line:	   .space  256				# space allocated for user input
maxLength: .word   256				# max length of input
prompt:	   .asciiz "Please enter a string >"	# user input prompt
pattern:   .asciiz " is a pattern\n"		# pattern display
noPattern: .asciiz " is not a pattern\n"	# no pattern display

    .text
#
#----------main---------------
# Prompts for user input, reads user input, calls match, and then prints the 
# result of match (wether or not input is a palindrome)
#
# registers:
# 	t0 - used for comparison to true
# 	s2 - index of last character (besides \0) in line
# 	s3 - last character in line (besides \0)
#
main:

# prompt for user input
la $a0, prompt				# load address of prompt
li $v0, 4				# load read string system call
syscall					# print prompt

# read user input
la $a1, maxLength			# load address of maxLength
lw $a1, 0($a1)				# load value of maxLength
la $a0, line				# load address of line
li $v0, 8				# load value for read string
syscall					# read string system call

#
# Remove newline from input
#
# strlen call				
la $a0, line				# load address of line
la $a1, maxLength			# load address of maxLength
lw $a1, 0($a1)				# load value of maxLength
jal strlen				# call strlen

# put '\0' where newline character was
move $s2, $v0				# move size of line to $s2
la $s3, line				# load address of line
addi $s2, $s2, -1			# $s2 = size - 1
add $s3, $s3, $s2			# $s3 = &line[size - 2]
sb $0, 0($s3)				# overwrite '\n' with 0

# call match
la $a0, line			# load address of line
move $a1, $v0			# move old length of line in $a1
addi $a1, $a1, -1		# subtract 1 from length since I removed \n
jal match			# call match

la $t0, true			# load address of true
lw $t0, 0($t0)			# load value of true

bne $t0, $v0, no_match		# if match's return != true, go to false
la $a0, line			# load address of line
li $v0, 4			# load value for print string
syscall				# print line
la $a0, pattern			# load address of pattern
syscall				# print pattern

li $v0, 10			# exit
syscall				#

no_match:
la $a0, line			# load address of line
li $v0, 4			# load value for print string
syscall				# print line
la $a0, noPattern		# load address of noPattern
syscall				# print noPattern

li $v0, 10			# exit
syscall				#

#
#-----------end main--------------
#

#
#-----------match---------------
# $a0 - address of string to examine
# $a1 - size of string
#
#
# Recursively determines if the given string is a palindrome.
#
# Registers:
# 	$s0 - size of temp_line
# 	$s1 - address of line
# 	$s2 - size parameter
#	$s3 - size of alignment buffer
#
#	$t0 - hold constants for comparisons and line[size - 1] 
#	      for comparison to line[0]
#	$t1 - hold line[0] for comparison to line[size - 1]
#
#   Stack will look like:
#LOW
#       ------
#   	temp_line
#          |
#          |
#          |
#          |
#   	------
#	alignment buffer
#       ------
#       $ra
#       ------
#       $s3
#       ------
#       $s2
#       ------
#       $s1
#	------
#	$s0
#	------
#HIGH
#

match:
# push s registers onto stack
addi $sp, $sp, -16		# make room for registers on stack
sw $s0, 0($sp)			# push $s0 onto stack
sw $s1, 0($sp)			# push $s1 onto stack
sw $s2, 0($sp)			# push $s2 onto stack
sw $s3, 0($sp)			# push $s3 onto stack

# save return address
addi $sp, $sp, -4
sw $ra, 0($sp)

# Store parameters in registers that will be saved
move $s1, $a0
move $s2, $a1

# 
# make room on stack for temp_line
#
addi $s0, $a1, 2
sub $sp, $sp, $s0

# align on word boundry with memalign
move $a0, $s0			# load size of temp_line as parameter
jal mem_align			# call to mem-align
addi $s3, $v0, -4		# find out how much to increment $sp
add $sp, $sp, $s3		# align stack pointer



#
# bzero(temp_line, size + 2)
#
move $a0, $sp 			# load address to begin zeroing
move $a1, $s0			# load size
jal bzero			# call bzero

# if (size < 2) {
# 	return TRUE;
# }
#
li $t0, 2			# value to compare to
slt $t0, $s2, $t0		# $t0 = (size < 2)

bne $t0, $zero, match_true	# return true if size < 2

#
# if (line[0] == line[size - 1]) {
#
add $t0, $s1, $s2		# $t0 = &line[size]
addi $t0, $t0, -1		# $t0 = &line[size - 1]
lb $t0, 0($t0)			# $t0 = line[size - 1]
lb $t1, 0($s1)			# $t1 = line[0]
bne $t0, $t1, match_false	# if line[0] != line[size - 1], return false

# if (size == 2)
# 	return TRUE;
li $t0, 2			# load value to compare to
beq $s2, $t0, match_true	# if branch to true if size == 2

#
# strncpy(temp_line, &line[1], size - 1);
#

#
# set up call to strncpy
#
move $a0, $sp			# load address of templine
move $a1, $s1			# move &line[0] to $a1
addi $a1, $a1, 1		# add so that $a1 = &line[1]
move $a3, $s2			# move size to $a3 
addi $a3, $a3, -2		# $a3 = size - 2

jal strncpy			# call strncpy

#
# temp_line[size - 2] = '\0'
#
# this code no longer necessary because we strncpy size - 2 elements and 
# every element after taht is alread \0 from bzero
#

#
# return match(temp_line, size-2)
#
move $a0, $sp			# move address of temp_line into $a0
move $a1, $s2			# $a1 = size
addi $a1, $a1, -2		# $a1 = size-2
jal match			# call match


la $t0, true			# load address of true
lw $t0, 0($t0)			# load value of true

bne $t0, $v0, match_false	# if return from match isn't true, jump to false

match_true:
add $sp, $sp, $s0		# set stack pointer to be after temp_line
sub $sp, $sp, $s3		# set stack pointer to be after alignment buffer
				# subtract b/c we stored $s3 as an offset
lw $ra, 0($sp)			# restore return address
addi $sp, $sp, 4		# move stack pointer up

lw $s3, 0($sp)			# restore $s3
lw $s2, 4($sp)			# restore $s2
lw $s1, 8($sp)			# restore $s1
lw $s0, 12($sp)			# restore $s0

addi $sp, $sp, 16		# restore stack pointer, 16 because we store 4 registers

# return true
la $v0, true			
lw $v0, 0($v0)

jr $ra

match_false:
add $sp, $sp, $s0		# set stack pointer to be after temp_line
sub $sp, $sp, $s3		# set stack pointer to be after alignment buffer
				# subtract b/c we stored $s3 as an offset
				
lw $ra, 0($sp)			# restore  return address
addi $sp, $sp, 4		# move stack pointer up

lw $s3, 0($sp)			# restore $s3
lw $s2, 4($sp)			# restore $s2
lw $s1, 8($sp)			# restore $s1
lw $s0, 12($sp)			# restore $s0

addi $sp, $sp, 16		# restore stack pointer, 16 because we store 4 registers

# return false
la $v0, false
lw $v0, 0($v0)

jr $ra

#-------------end match-----------------------------


#
#---------------bzero--------------------
#
# $a0 address to begin zeroing
# $a1 number of bytes to zero out
#
# zeroes out $a1 bytes beginning at address $a0
#
bzero:
beq $a1, $zero, bzero_done		# while $a1 != 0....
sb $zero, 0($a0)			# load 0x00 at $a0
addi $a0, $a0, 1			# increment $a0
addi $a1, $a1, -1			# decrement $a1
j bzero

bzero_done:
jr $ra

#--------------------end bzero------------------------


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
#-------end strncpy--------------




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

#
#------end strlen----------------
#
#

#------mem_align-----------------
# $a0 - integer representing number of bytes
#
# Finds and returns the remainder of $a0 divided by 4 or 4 if the remainder
# is 0
#
# registers:
# t0 boolean, if $a0 is less than $s1
# t1 incrementing multiples of 4, used to find multiple of 4 closest to and
#    greater than $a0
mem_align:

li $t0, 0
li $t1, 0

memloop:
bne $t0, $zero, memDone
addi $t1, $t1, 4
slt $t0, $a0, $t1
j memloop

memDone:
addi $t1, $t1, -4
sub $v0, $a0, $t1

# if remainder is 0, should return 4
bne $v0, $0, mem_align_done
li $v0, 4

mem_align_done:
jr $ra
#-----------------end mem_align---------------
