.data
.globl equations
equations: .space 64    # Space for 8 equations [8 bytes each]

.globl answers
.align 2                # Ensure word alignment
answers: .space 32      # Space for 8 answers [4 bytes each]

# Array of equations
.globl equation_templates
equation_templates: .word 
    # Each equation stored as two numbers
    1, 2,    # 1 x 2 = 2
    2, 3,    # 2 x 3 = 6
    3, 3,    # 3 x 3 = 9
    2, 4,    # 2 x 4 = 8
    4, 4,    # 4 x 4 = 16
    3, 5,    # 3 x 5 = 15
    2, 5,    # 2 x 5 = 10
    1, 5     # 1 x 5 = 5

.globl card_types      # Array to track if card shows equation (0) or answer (1)
card_types: .space 16  # One byte per card

# To store which pair each card position represents
.globl pairs
pairs: .space 16       # One byte per card position

.text
.globl generateCards

generateCards:
    # Save return address and registers
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    # Initialize counters
    li $s0, 0    # Current equation index
    la $s1, equations
    la $s2, equation_templates
    
generate_loop:
    # Check if we've generated all equations
    li $t0, 8
    beq $s0, $t0, setup_pairs
    
    # Load multiplication numbers
    lw $t1, 0($s2)  
    lw $t2, 4($s2)   
    
    # Store equation string ["2 * 3"]
    addi $t3, $t1, 48    # Convert to ASCII
    sb $t3, 0($s1)       # Store first digit
    li $t3, ' '
    sb $t3, 1($s1)
    li $t3, 'x'
    sb $t3, 2($s1)
    li $t3, ' '
    sb $t3, 3($s1)
    addi $t3, $t2, 48    # Convert to ASCII
    sb $t3, 4($s1)
    sb $zero, 5($s1)     # Null terminator
    sb $zero, 6($s1)
    sb $zero, 7($s1)
    
    # Calculate and store answer
    mul $t4, $t1, $t2    # Calculate product
    la $t5, answers
    sll $t6, $s0, 2      # Multiply index by 4 for answer array offset
    add $t5, $t5, $t6
    sw $t4, 0($t5)       # Store answer
    
    # Update counters and pointers
    addi $s0, $s0, 1     # Next equation
    addi $s1, $s1, 8     # Next equation slot
    addi $s2, $s2, 8     # Next template
    
    j generate_loop

setup_pairs:
    # Initialize pairs array - alternating between equation and answer per pair
    la $t0, pairs        # pairs array address
    la $t1, card_types   # card types array address
    li $t2, 0            # pair 
    li $t3, 0            # positio
    li $t4, 16           # total positions

setup_loop:
    beq $t3, $t4, shuffle_cards  # Done when all positions filled

    # Store pair indexes
    sb $t2, ($t0)        # Store current pair index
    # Store card type [0, 1] described before
    sb $zero, ($t1)      # Store equation type

    # Move to next position
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    addi $t3, $t3, 1

    # Store matching answer
    sb $t2, ($t0)        # Store same pair index
    # Store card type (1 for answer)
    li $t5, 1
    sb $t5, ($t1)        # Store answer type

    # Move to next position and pair
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    addi $t2, $t2, 1     # Next pair
    addi $t3, $t3, 1

    j setup_loop

shuffle_cards:
    # Shuffle the arrays
    li $t1, 16           # Array size
    li $t2, 0            # Counter

shuffle_loop:
    beq $t2, $t1, shuffle_done

    # Generate random index
    li $v0, 42           # Random int range
    move $a1, $t1        # Upper bound
    syscall              # Random number in $a0

    # Swap pairs
    la $t3, pairs
    add $t4, $t3, $t2    # Current position
    add $t5, $t3, $a0    # Random position
    lb $t6, ($t4)        # Load current
    lb $t7, ($t5)        # Load random
    sb $t7, ($t4)        # Store random at current
    sb $t6, ($t5)        # Store current at random

    # Swap types
    la $t3, card_types
    add $t4, $t3, $t2
    add $t5, $t3, $a0
    lb $t6, ($t4)
    lb $t7, ($t5)
    sb $t7, ($t4)
    sb $t6, ($t5)

    addi $t2, $t2, 1
    j shuffle_loop

shuffle_done:
    # Validate no adjacent pairs 
    # note: this is because it was erroring and putting them right next to each other for some reason
    jal validate_shuffle

    # Restore registers and return
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

validate_shuffle:
    # Check for adjacent pairs
    li $t0, 0            # Counter
    li $t1, 15           # Last index to check

validate_loop:
    beq $t0, $t1, validate_done

    # Load current and next pair indices
    la $t2, pairs
    add $t3, $t2, $t0
    lb $t4, ($t3)        # Current pair index
    lb $t5, 1($t3)       # Next pair index

    # If pairs match, reshuffle
    beq $t4, $t5, shuffle_cards

    addi $t0, $t0, 1
    j validate_loop

validate_done:
    jr $ra
