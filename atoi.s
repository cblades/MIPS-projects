##############################
# Takes as input a string consisting of 4 digits and displays the 
# ascii value and decimal value for each given digit.
#
# Chris Blades
# 10/2/2010
# CS350
#
# Registers used:
# $a0:  address of the various strings defined in .data, individual values
# 	from string for printing ascii value as integer
# $a1:  length of strings for printing
# $a2:	converted value of individual digits
# $t0:  address of input string
##############################
    .data

# the number of characters to read
# extra 2 for newline character and \0
numChars: .word	6

# space to store user input
input:	  .space 6

# User prompt to enter values
prompt:   .asciiz "Please enter an integer > "

# seperator to use while printint conversions
seperator:    .asciiz " : "

# newline character
newline:    .asciiz "\n"

    
    .text
main:
        ##########
	#  Read user input
	##########

	# Prepare to print the prompt
	la $a0, prompt
	# Print prompt, print string system call
	li $v0, 4
	syscall

	#
	# Prepare for read string system call
	#
	# Prep $a0:  address to read to
	la $a0, input
	# prep $a1:  num chars to read
	la $a1, numChars
	lw $a1, 0($a1)

	
	# Execute read string system call
	li $v0, 8
	syscall

	##########
	# Do ascii -> decimal conversion and print both
	##########
	# move address of input to keep it around but free up
	# $a0
	add $t0, $zero, $a0

	#
 	# Print first number
	#
	# print ascii value
	lb $a0, 0($t0)
	li $v0, 1
	syscall
	
	# convert ascii to decimal by adding -48 (just the difference
	# between ascii value of any given digit and decimal value of
	# that digit)
	addi $a2, $a0, -48
	
	# print seperator
	la $a0, seperator
	li $v0, 4
	syscall
	
	# print converted number
	add $a0, $zero, $a2
	li $v0, 1
	syscall
	
	# print newline
	la $a0, newline
	li $v0 4
	syscall

	
	#
 	# Print second number
	#
	# print ascii value
	lb $a0, 1($t0)
	li $v0, 1
	syscall
	
	# convert ascii to decimal by adding -48 (just the difference
	# between ascii value of any given digit and decimal value of
	# that digit)
	addi $a2, $a0, -48
	
	# print seperator
	la $a0, seperator
	li $v0, 4
	syscall
	
	# print converted number
	add $a0, $zero, $a2
	li $v0, 1
	syscall
	
	# print newline
	la $a0, newline
	li $v0, 4 
	syscall


	#
 	# Print third number
	#
	# print ascii value
	lb $a0, 2($t0)
	li $v0, 1
	syscall
	
	# convert ascii to decimal by adding -48 (just the difference
	# between ascii value of any given digit and decimal value of
	# that digit)
	addi $a2, $a0, -48
	
	# print seperator
	la $a0, seperator
	li $v0, 4
	syscall
	
	# print converted number
	add $a0, $zero, $a2
	li $v0, 1
	syscall
	
	# print newline
	la $a0, newline
	li $v0 4
	syscall


	#
 	# Print fourth number
	#
	# print ascii value
	lb $a0, 3($t0)
	li $v0, 1
	syscall
	
	# convert ascii to decimal by adding -48 (just the difference
	# between ascii value of any given digit and decimal value of
	# that digit)
	addi $a2, $a0, -48
	
	# print seperator
	la $a0, seperator
	li $v0, 4
	syscall
	
	# print converted number
	add $a0, $zero, $a2
	li $v0, 1
	syscall
	
	# print newline
	la $a0, newline
	li $v0 4
	syscall


	# Exit nicely
	li $v0, 10
	syscall
