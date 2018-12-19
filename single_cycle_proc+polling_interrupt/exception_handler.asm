# The file contains the assembly kernel code for handling polled interrupts.

save_registers:
	addiu	$sp, $sp, -96
	sw	    $2,   0($sp)
	sw	    $3,   4($sp)
	sw	    $4,   8($sp)
	sw	    $5,  12($sp)
	sw	    $6,  16($sp)
	sw	    $7,  20($sp)
	sw	    $8,  24($sp)
	sw	    $9,  28($sp)
	sw	    $10, 32($sp)
	sw	    $11, 36($sp)
	sw	    $12, 40($sp)
	sw	    $13, 44($sp)
	sw	    $14, 48($sp)
	sw	    $15, 52($sp)
	sw	    $16, 56($sp)
	sw	    $17, 60($sp)
	sw	    $18, 64($sp)
	sw	    $19, 68($sp)
	sw	    $20, 72($sp)
	sw	    $21, 76($sp)
	sw	    $22, 80($sp)
	sw	    $23, 84($sp)
	sw	    $24, 88($sp)
	sw	    $25, 92($sp)
	jr	    $ra

restore_registers:
	lw      $2,   0($sp)
	lw      $3,   4($sp)
	lw      $4,   8($sp)
	lw      $5,  12($sp)
	lw      $6,  16($sp)
	lw      $7,  20($sp)
	lw      $8,  24($sp)
	lw      $9,  28($sp)
	lw      $10, 32($sp)
	lw      $11, 36($sp)
	lw      $12, 40($sp)
	lw      $13, 44($sp)
	lw      $14, 48($sp)
	lw      $15, 52($sp)
	lw      $16, 56($sp)
	lw      $17, 60($sp)
	lw      $18, 64($sp)
	lw      $19, 68($sp)
	lw      $20, 72($sp)
	lw      $21, 76($sp)
	lw      $22, 80($sp)
	lw      $23, 84($sp)
	lw      $24, 88($sp)
	lw      $25, 92($sp)
	addiu	$sp, $sp, 96
	jr      $ra

exception_handler:
    jal     save_registers
    mfc0    $26, $13               # read cause, $t0 <- cause
    addiu   $t0, $0, 0x00000001
    addiu   $t1, $0, 0x00000002
    addiu   $t2, $0, 0x00000004
    addiu   $t3, $0, 0x00000008
    beq     $26, $t0, hw0
    beq     $26, $t1, hw1
    beq     $26, $t2, hw2
    beq     $26, $t3, hw3
    jal     restore_registers
    xor     $26, $0, $0
    eret
