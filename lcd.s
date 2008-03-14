############################################################
# LCD text display
#
# Functions and data for handling the LM016 (equiv.) LCD 
# text display.
############################################################

# Expose functions
.globl lcd_init
.globl lcd_putchar
.globl lcd_print
.globl lcd_puthex
.globl lcd_setlocation

#
# Initialise the display ready for use
#
lcd_init:
    # Clear display
    ld a, 0x01
    out0 (LCD_CTRL), a
    # Delay ~1.7ms for display to clear
    ld b, 0x20
    call delay
    # Display on, cursor off, blink off
    ld a, 0x0c
    out0 (LCD_CTRL), a
    # Delay ~0.04ms
    ld b, 0x01
    call delay
    ret

# 
# Write the character in the accumulator to the display
#`
lcd_putchar:
    # Send the character
    out (LCD_DATA), a
    # Delay for ~0.04ms for display to catch up
    ld b, 0x01
    call delay
    ret

#
# Write a null-terminated string of characters starting at 
# the address in HL to the display
#
lcd_print:
0:  ld a, (hl)
    cp 0x00
    jr z, 1f
    call lcd_putchar
    inc hl
    jr 0b
1:  ret

#
# Write the hexadecimal representation of the byte in the 
# accumulator to the display
#
lcd_puthex:
    # Preserve the byte
    ld d, a
    # Get the high nibble
    and 0xf0
    # Rotate the high nibble to the low nibble
    rra
    rra
    rra
    rra
    # For a value of 9 or less, add 0x30 to get the ASCII 
    # representation, for 'A' or above add 0x37
    cp 0x0a
    jr c, 0f
    add a, 0x37
    jr 1f
0:  add a, 0x30
    # Send the character to the display
1:  out (LCD_DATA), a
    # Delay for display sync
    ld b, 0x01
    call delay
    # Restore the byte
    ld a, d
    # Get the low nibble
    and 0x0f
    # For a value of 9 or less, add 0x30 to get the ASCII 
    # representation, for 'A' or above add 0x37
    cp 0x0a
    jr c, 0f
    add  a, 0x37
    jr 1f
0:  add a, 0x30
    # Send the character to the display
1:  out (LCD_DATA), a
    # Delay for display sync
    ld b, 0x01
    call delay
    # Restore the character again, in case it is needed
    ld a, d
    ret

#
# Set the DDRAM location ("cursor" location) to the value in
# the accumulator
#
lcd_setlocation:
    out0 (LCD_CTRL), a
    ld b, 0x01
    call delay
    ret

# 
# Delay loop, necessary for correct operation of the display
# (delay for approx. B * 55 microseconds)
# 
delay:
0:  ld a, 0x20
1:  dec a
    jr nz, 1b
    djnz 0b
    ret
