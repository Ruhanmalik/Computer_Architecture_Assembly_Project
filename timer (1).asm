.data
.globl startTime
startTime: .word 0          # Store start time (ms)
.globl endTime
endTime: .word 0           # Store end time (ms)
.globl timeMsg
timeMsg: .asciiz "\nTime taken: "
.globl minutesMsg
minutesMsg: .asciiz " minutes and "
.globl secondsMsg
secondsMsg: .asciiz " seconds\n"

.text
# Initialize timer
.globl startTimer
startTimer:
    # Get current system time
    li $v0, 30             # System call for time
    syscall                # Time in milliseconds now in $a0
    sw $a0, startTime      # Save start time
    jr $ra

# Stop timer and display time
.globl stopTimer
stopTimer:
    # Get end time
    li $v0, 30             # System call for time
    syscall
    sw $a0, endTime        # Save end time
    
    # Calc elapsed time
    lw $t0, startTime
    sub $t0, $a0, $t0      # Elapsed time in ms
    
    # Convert to seconds
    li $t1, 1000
    div $t0, $t1           # Convert to seconds
    mflo $t0               # Total seconds in $t0
    
    # Calculate minutes and remaining seconds
    li $t1, 60
    div $t0, $t1
    mflo $t2               # Minutes in $t2
    mfhi $t3               # Seconds in $t3
    
    # Display time message
    la $a0, timeMsg
    li $v0, 4
    syscall
    
    # Display minutes
    move $a0, $t2
    li $v0, 1
    syscall
    
    la $a0, minutesMsg
    li $v0, 4
    syscall
    
    # Display seconds
    move $a0, $t3
    li $v0, 1
    syscall
    
    la $a0, secondsMsg
    li $v0, 4
    syscall
    
    jr $ra
