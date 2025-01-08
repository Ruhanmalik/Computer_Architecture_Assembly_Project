.data
    # Display Elements and Formatting
    .globl board_header
board_header: 
    .asciiz "\n  Memory Game - Find the Matching Pairs!\n\n      1     2     3     4\n   -------------------------\n"
    
    .globl row_separator
row_separator: 
    .asciiz "   -------------------------\n"
    
    .globl row_start
row_start: 
    .asciiz " "
    
    .globl card_separator
card_separator: 
    .asciiz " | "
    
    .globl hidden_card
hidden_card: 
    .asciiz "   "            # Three spaces for hidden card display
    
    .globl newline
newline: 
    .asciiz "\n"

.text
    .globl displayBoard

displayBoard:
    # Save registers
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)          # For row counter
    sw $s1, 8($sp)          # For column counter

    # Display game header
    la $a0, board_header
    li $v0, 4
    syscall
    
    li $s0, 0               # Initialize row counter

# process each row through the outer loop
outer_loop:
    li $t0, 4
    beq $s0, $t0, display_done    # Check if all rows completed
    
    # Print row number and formatting
    la $a0, row_start
    li $v0, 4
    syscall
    
    addi $a0, $s0, 1        # Convert to 1-based row number
    li $v0, 1
    syscall
    
    la $a0, card_separator
    li $v0, 4
    syscall
    
    li $s1, 0               # Reset column counter
    
# process each card in current row through the inner loop
inner_loop:
    li $t0, 4
    beq $s1, $t0, row_end   # Check if row is complete
    
    # Calculate array index for current card
    mul $t1, $s0, 4         # Row offset
    add $t1, $t1, $s1       # Add column offset
    
    # Check card visibility
    lb $t2, visibility($t1)
    beqz $t2, show_hidden   # Show hidden card if not visible
    
    # Get card information
    lb $t3, pairs($t1)      # Get pair index
    lb $t4, card_types($t1) # Get card type (equation/answer)
    
    # Display appropriate card content
    bnez $t4, show_answer   # Branch if answer card
    
# Show equation card
show_equation:
    la $t5, equations
    sll $t6, $t3, 3         # Multiply pair index by equation string length
    add $a0, $t5, $t6
    li $v0, 4
    syscall
    j end_card
    
# Show answer card
show_answer:
    la $t5, answers
    sll $t6, $t3, 2         # Multiply pair index by word size
    add $t5, $t5, $t6
    lw $a0, ($t5)
    li $v0, 1
    syscall
    j end_card
    
# Show hidden card
show_hidden:
    la $a0, hidden_card
    li $v0, 4
    syscall
    
# Finish card display
end_card:
    la $a0, card_separator
    li $v0, 4
    syscall
    
    addi $s1, $s1, 1        # Next column
    j inner_loop
    
# Complete row display
row_end:
    la $a0, newline
    li $v0, 4
    syscall
    
    la $a0, row_separator
    li $v0, 4
    syscall
    
    addi $s0, $s0, 1        # Next row
    j outer_loop
    
# Clean up and return
display_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra