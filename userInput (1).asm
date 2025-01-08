.data
.globl input
input: .space 8            # Space for input (row col\n)
.globl prompt
prompt: .asciiz "\nEnter coordinates (row col): "
.globl error_msg
error_msg: .asciiz "\nInvalid input! Please enter row and column (1-4)\n"

.text

.globl convertToIndex    

.globl userInput

userInput:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

input_loop:
    # Display prompt
    la $a0, prompt
    li $v0, 4
    syscall
    
    # Read input string
    la $a0, input
    li $a1, 8        # Maximum length
    li $v0, 8
    syscall
    
    # Validate input length
    la $t0, input
    lb $t1, ($t0)    # First character (row)
    lb $t2, 1($t0)   # space
    lb $t3, 2($t0)   # Second character (column)
    
    
    # Validation checking
    # Check if row is between 1-4
    li $t4, '1'
    blt $t1, $t4, invalid_input
    li $t4, '4'
    bgt $t1, $t4, invalid_input
    
    # Check for space
    li $t4, ' '
    bne $t2, $t4, invalid_input
    
    # Check if column is between 1-4
    li $t4, '1'
    blt $t3, $t4, invalid_input
    li $t4, '4'
    bgt $t3, $t4, invalid_input
    
    # Restore return address
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

invalid_input:
    # Display error message
    la $a0, error_msg
    li $v0, 4
    syscall
    j input_loop

# Convert row/column to array index
convertToIndex:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Load input characters
    la $t0, input
    lb $t1, ($t0)     # Row character
    lb $t2, 2($t0)    # Column character

    # Convert ASCII to integers (subtract 48, ascii '0')
    subi $t1, $t1, 48  # Convert row
    subi $t2, $t2, 48  # Convert column

    # Calc index (row-1) * 4 + (col-1)
    subi $t1, $t1, 1   # row-1
    subi $t2, $t2, 1   # col-1
    
    # Multiply by 4
    sll $t1, $t1, 2    # Same as multiplying by 4, 2^2
    
    # Add column offset
    add $v0, $t1, $t2  # Final index in $v0

    # Restore return address
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
