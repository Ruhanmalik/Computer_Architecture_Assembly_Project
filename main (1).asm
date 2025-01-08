.data
# Game State Variables
.globl firstSelection
firstSelection: .word -1     # Index of first card selected (-1 = none)
.globl secondSelection
secondSelection: .word -1    # Index of second card selected 
.globl visibility
visibility: .space 16        # Card visibility array (0 = hidden, 1 = visible)
.globl pairsFound         
pairsFound: .word 0         # number of pairs found

# Display Messages
.globl gameWonMsg
gameWonMsg: .asciiz "\nCongratulations! You are a math GENIUS!\n"
.globl clearScreen
clearScreen: .asciiz "\n\n\n\n\n\n\n\n\n"  # Simple screen clear using newlines

# Audio State
.globl current_note
current_note: .word 0        # Index of current background music note

.text
.globl main
.globl start

# Program entry point
start:
    j main

# Main game loop and initialization
main:
    # Setup stack frame
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Initialize game components
    jal initializeGame       # Set up initial game state
    jal generateCards        # Generate and shuffle cards
    jal startTimer          # Start game timer
    
    # Show game board
    jal displayBoard      

# Main game loop
game_loop:
    # Update background music
    jal playNextBgNote
    
    #  player input and card selection
    jal userInput         
    jal processSelectionStable
    
    # Check for win (8 pairs found)
    lw $t0, pairsFound
    li $t1, 8             
    beq $t0, $t1, game_won
    
    # Refresh display
    la $a0, clearScreen
    li $v0, 4
    syscall
    jal displayBoard
    
    j game_loop

# Background music handler
# Updates and plays the next note
playNextBgNote:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Get current note position
    lw $t0, current_note
    
    # Load and setup next note
    la $t1, bgm_notes
    add $t1, $t1, $t0
    lb $a0, ($t1)          # pitch value
    
    # Configure MIDI parameters
    lw $a1, note_duration
    li $a2, 1              # Use piano instrument
    li $a3, 40             # volume = 40
    
    # Play current note
    li $v0, 31
    syscall
    
    # Update note index
    addi $t0, $t0, 1
    lw $t2, bgm_length
    blt $t0, $t2, save_note
    li $t0, 0              # Loop back to start
    
save_note:
    sw $t0, current_note
    
    # Restore and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Game completion handler
game_won:
    # Play victory music and stop timer
    jal playVictorySound
    jal stopTimer
    
    # Display victory message
    la $a0, gameWonMsg
    li $v0, 4
    syscall
    
    # exit
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 10
    syscall


# Sets up initial visibility array and trackers
.globl initializeGame
initializeGame:
    # Preserve return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Initialize visibility array to all hidden
    la $t0, visibility
    li $t1, 16             # Array size
    li $t2, 0              # Hidden state

clear_loop:
    sb $t2, ($t0)          # Mark card as hidden
    addi $t0, $t0, 1       # Next array position
    addi $t1, $t1, -1      # Decrement
    bnez $t1, clear_loop   # Continue until all are hidden
    
    # Reset tracking
    li $t0, -1             # No selection value
    sw $t0, firstSelection
    sw $t0, secondSelection
    
    # Reset match counter
    sw $zero, pairsFound
    
    # Restore and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra


# Handles the logic for selecting and matching cards
.globl processSelectionStable
processSelectionStable:
    # Save registers
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    # Convert input to array index
    jal convertToIndex
    move $s0, $v0          # Store converted index
    
    # Check if card is already visible
    lb $t0, visibility($s0)
    bnez $t0, process_stable_end  
    
    # Check if this is first or second selection
    lw $t0, firstSelection
    bgez $t0, check_second_stable 
    
    # Handle first card selection
    sw $s0, firstSelection
    li $t1, 1
    sb $t1, visibility($s0)
    jal playCardFlip
    j process_stable_end
    
# Handle second card selection
check_second_stable:
    sw $s0, secondSelection
    li $t1, 1
    sb $t1, visibility($s0)
    
    # Play sound and update display
    jal playCardFlip
    
    # Show both selected cards
    la $a0, clearScreen
    li $v0, 4
    syscall
    jal displayBoard
    
    # Delay to show cards
    li $a0, 1000          
    li $v0, 32
    syscall
    
    # Check if the pair matches
    lw $s1, firstSelection
    lw $s2, secondSelection
    lb $t1, pairs($s1)    
    lb $t2, pairs($s2)     
    
    bne $t1, $t2, no_match_stable
    
    # Process matching pair
    lw $t0, pairsFound
    addi $t0, $t0, 1      # Increment pairs found
    sw $t0, pairsFound
    jal playMatchFound
    
    # Reset selections
    li $t0, -1
    sw $t0, firstSelection
    sw $t0, secondSelection
    j process_stable_end
    
# Handle non-matching cards
no_match_stable:
    jal playWrongMatch
    
    # Hide both cards
    li $t0, 0
    sb $t0, visibility($s1)
    sb $t0, visibility($s2)
    
    # Reset selections
    li $t0, -1
    sw $t0, firstSelection
    sw $t0, secondSelection

# Clean up and return
process_stable_end:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra