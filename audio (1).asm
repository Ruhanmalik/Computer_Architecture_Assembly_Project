.data
# MIDI Parameters for sound effects
.globl flip_pitch
flip_pitch: .byte 72         # High C
.globl match_pitch
match_pitch: .byte 67, 70, 72  # Match notes (correct Match)
.globl wrong_pitch
wrong_pitch: .byte 50, 48    # Wrong match notes
.globl win_pitch
win_pitch: .byte 60, 64, 67, 72  # VICTORY NOISE!

# Background Music Notes
.globl bgm_notes
bgm_notes: .byte 60, 64, 67, 72, 67, 64, 60, 64, 67, 72, 67, 64  # A basic melody
.globl bgm_length
bgm_length: .word 12  # Number of notes

# Duration parameters
.globl short_duration
short_duration: .word 200    # 200 ms
.globl medium_duration
medium_duration: .word 300   # 300 ms
.globl long_duration
long_duration: .word 500     # 500 ms
.globl note_duration
note_duration: .word 200     # Duration for each background music note

.text
# Play sound for card flip
.globl playCardFlip
playCardFlip:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Setup MIDI parameters
    lb $a0, flip_pitch     # Load pitch
    li $a1, 200            # Duration
    li $a2, 0              # Piano
    li $a3, 100            # Volume 
    
    # Play the note
    li $v0, 31             # MIDI out syscall
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Play sound for match found
.globl playMatchFound
playMatchFound:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Play three ascending notes
    li $a2, 0              # Piano
    li $a3, 100            # Volume
    
    # First note
    lb $a0, match_pitch
    lw $a1, short_duration
    li $v0, 31
    syscall
    
    # Slight delay
    li $a0, 100
    li $v0, 32
    syscall
    
    # Second note
    lb $a0, match_pitch+1
    lw $a1, short_duration
    li $v0, 31
    syscall
    
    # Slight delay
    li $a0, 100
    li $v0, 32
    syscall
    
    # Third note
    lb $a0, match_pitch+2
    lw $a1, medium_duration
    li $v0, 31
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Play sound for wrong match
.globl playWrongMatch
playWrongMatch:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Play two descending notes
    li $a2, 0              # Piano
    li $a3, 80             # Volume
    
    # First note
    lb $a0, wrong_pitch
    lw $a1, short_duration
    li $v0, 31
    syscall
    
    # slight delay
    li $a0, 200
    li $v0, 32
    syscall
    
    # Second note
    lb $a0, wrong_pitch+1
    lw $a1, medium_duration
    li $v0, 31
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Play VICTORY MUSIC!
.globl playVictorySound
playVictorySound:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Play victory sounds
    li $a2, 0              # Piano
    li $a3, 127            # Full volume!
    
    # Play ascending melody
    lb $a0, win_pitch
    lw $a1, short_duration
    li $v0, 31
    syscall
    
    li $a0, 100
    li $v0, 32
    syscall
    
    lb $a0, win_pitch+1
    lw $a1, short_duration
    li $v0, 31
    syscall
    
    li $a0, 100
    li $v0, 32
    syscall
    
    lb $a0, win_pitch+2
    lw $a1, short_duration
    li $v0, 31
    syscall
    
    li $a0, 100
    li $v0, 32
    syscall
    
    lb $a0, win_pitch+3
    lw $a1, long_duration
    li $v0, 31
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra