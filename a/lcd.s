.globl lcd_init, lcd_putchar, lcd_print, lcd_putbyte

.globl delay

LCD_CTRL=0xb8
LCD_DATA=0xb9

lcd_init:
    # Clear display
    ld a, 0x01
    out0 (LCD_CTRL), a
    # Delay ~1.7ms
    ld b, 0x20
    call delay
    # Display on, cursor on, blink on
    ld a, 0x0f
    out0 (LCD_CTRL), a
    # Delay ~0.04ms
    ld b, 0x01
    call delay
    ret

lcd_putchar:
    push bc
    out (LCD_DATA), a
    ld b, 0x01
    call delay
    pop bc
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
