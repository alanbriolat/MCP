.globl terminal_init
.globl terminal_getchar
.globl terminal_putchar
.globl terminal_putbyte
.globl terminal_print
.globl terminal_newline

#
# Initialise the ASCI channel for the terminal
#
terminal_init:
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
# Write a character to the terminal
#
terminal_putchar:
    push af
0:  in0 a, (TERMINAL_STAT)
    and 0x02
    cp 0x02
    jr nz, 0b
    pop af
    out0 (TERMINAL_TX), a
    ret

# 
# Print the string starting at HL to the terminal
#
terminal_print:
0:  ld a, (hl)
    cp 0x00
    jr z, 1f
    call terminal_putchar
    inc hl
    jr 0b
1:  ret

# 
# Get the character that has arrived at the ASCI and clear the interrupt
#
terminal_getchar:
    call terminal_clearint
0:  in0 a, (TERMINAL_STAT)
    bit 7, a
    jr z, 0b
    in0 a, (TERMINAL_RX)
    ret

# 
# Write the binary representation of A to the terminal, terminated by a newline
# 
terminal_putbyte:
    push bc
    ld b, 0x08
0:  rlca
    jr nc, 1f
    ex af, af
    ld a, 0x31
    call terminal_putchar
    ex af, af
    jr 2f
1:  ex af, af
    ld a, 0x30
    call terminal_putchar
    ex af, af
2:  djnz 0b
    pop bc
    call terminal_newline
    ret

#
# Write a newline to the terminal
#
terminal_newline:
    ld hl, crlf
    call terminal_print
    ret

# Carriage-return, line-feed
crlf:
    .byte 0x0d,0x0a,0x00
