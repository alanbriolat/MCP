############################################################
# Terminal
#
# Functions for interacting with the Seyon terminal on ASCI
# channel 1
############################################################

# Expose functions
.globl terminal_init
.globl terminal_getchar
.globl terminal_putchar
.globl terminal_putbyte
.globl terminal_print
.globl terminal_newline
.globl terminal_clearint

#
# Initialise the network interface (see defs.s for the actual
# settings being used - TERMINAL_*_VALUE).  This includes 
# clearing the interrupt from the last character the monitor
# program read.
#
terminal_init:
# Initialise the ASCI channel for the terminal
    # Clear interrupt, set operating mode
    ld a, TERMINAL_CTRLA_VALUE
    out0 (TERMINAL_CTRLA), a
    # Set baud rate
    ld a, TERMINAL_CTRLB_VALUE
    out0 (TERMINAL_CTRLB), a
    # Enable interrupts
    ld a, TERMINAL_STAT_VALUE
    out0 (TERMINAL_STAT), a
    ret

# 
# Clear the interrupt on the terminal
#
terminal_clearint:
    ld a, TERMINAL_CTRLA_VALUE
    out0 (TERMINAL_CTRLA), a
    ret

# 
# Get the current character from the terminal interface, 
# returning it in the accumulator
#
terminal_getchar:
    # Reset CTRLA - the combination of this, reading STAT and
    # reading the data has the effect of clearing the interrupt
    ld a, TERMINAL_CTRLA_VALUE
    out0 (TERMINAL_CTRLA), a
    # Wait until the receive buffer full flag is set
0:  in0 a, (TERMINAL_STAT)
    bit 7, a
    jr z, 0b
    # Read in the character
    in0 a, (TERMINAL_RX)
    ret
    
# 
# Write the character held in the accumulator to the 
# terminal interface
#
terminal_putchar:
    # Preserve the character while STAT is polled
    push af
    # Wait until the ASCI is ready to transmit
0:  in0 a, (TERMINAL_STAT)
    bit 1, a
    jr nz, 0b
    # Restore the character
    pop af
    # Send the character
    out0 (TERMINAL_TX), a
    ret

# 
# Write a null-terminated string of characters starting at 
# the address in HL to the terminal
#
terminal_print:
    # Get a character
0:  ld a, (hl)
    # Check for the end of the string
    cp 0x00
    jr z, 1f
    # Write the character
    call terminal_putchar
    # Go to next location and repeat
    inc hl
    jr 0b
1:  ret

#
# Write a Carriage-return Linefeed to the terminal
#
terminal_newline:
    ld a, 0x0d
    call terminal_putchar
    ld a, 0x0a
    call terminal_putchar
    ret

# 
# Write the binary representation of the accumulator to the 
# terminal, terminated by a newline (diagnostic tool)
# 
terminal_putbyte:
    push bc
    # Number of times to rotate (8, for 8 bits)
    ld b, 0x08
    # Rotate left, copying bit 7 to the carry flag
0:  rlca
    # Use the carry flag te decide between writing 1 or 0
    jr nc, 1f
    ex af, af
    # Write 1
    ld a, 0x31
    call terminal_putchar
    ex af, af
    jr 2f
1:  ex af, af
    # Write 0
    ld a, 0x30
    call terminal_putchar
    ex af, af
    # Loop until the whole byte is done
2:  djnz 0b
    pop bc
    # Terminate with a newline
    ex af, af
    call terminal_newline
    ex af, af
    ret
