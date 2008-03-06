.globl lcd_init
.globl lcd_clear
.globl lcd_putchar
.globl lcd_putbyte
.globl lcd_print
.globl lcd_puthex
.globl lcd_setlocation

.globl delay

lcd_init:
    # Clear display
    call lcd_clear
    # Display on, cursor on, blink on
    ld a, 0x0c
    out0 (LCD_CTRL), a
    # Delay ~0.04ms
    ld b, 0x01
    call delay
    ret

lcd_clear:
    ld a, 0x01          
    out0 (LCD_CTRL), a      # Clear the display
    ld b, 0x20
    call delay              # Delay for ~1.7ms for the display to clear
    ret

# 
# Put a character to the LCD text display
#`
lcd_putchar:
    exx                     # Exchange registers to preserve B (faster than
                            # push/pop, and this is a common operation)
    out (LCD_DATA), a       # Put the character to the display
    ld b, 0x01              # Delay for ~0.04ms to allow display to catch up
    call delay
    exx                     # Exchange registers back again
    ret

lcd_print:
0:  ld a, (hl)
    cp 0x00
    jr z, 1f
    call lcd_putchar
    inc hl
    jr 0b
1:  ret

lcd_putbyte:
    push bc
    ld b, 0x08
0:  rlca
    jr nc, 1f
    ex af, af
    ld a, 0x31
    call lcd_putchar
    ex af, af
    jr 2f
1:  ex af, af
    ld a, 0x30
    call lcd_putchar
    ex af, af
2:  djnz 0b
    pop bc
    ret

lcd_puthex:
    push af
    push af
    rra
    rra
    rra
    rra
    cp 0x0a
    jr c, 0f
    add a, 0x37
    jr 1f
0:  add a, 0x30
1:  call lcd_putchar
    pop af
    and 0x0f
    cp 0x0a
    jr c, 0f
    add  a, 0x37
    jr 1f
0:  add a, 0x30
1:  call lcd_putchar
    pop af
    ret

#
# Set the DDRAM location to the value in A
#
lcd_setlocation:
    push bc
    out0 (LCD_CTRL), a
    ld b, 0x01
    call delay
    pop bc
    ret
