start:
    call initdisplay

    ld hl, helloworld
    call print
    halt

initdisplay:
    ld a, 0x01          # Clear
    out (LCD_CTRL), a
    ld b, 0x20
    call delay
    ld a, 0x0f          # Display on, cursor on, blink on
    out (LCD_CTRL), a
    ret

# Implements a delay of approx. B * 55 microseconds
delay:
0:  ld a, 0x20
1:  dec a
    jr nz, 1b
    djnz 0b
    ret

print:
0:  ld a, (hl)
    cp 0x00
    jr z, 1f
    call putchar
    inc hl
    jr 0b
1:  ret

putchar:
    out (LCD_DATA), a
    ld b, 0x01
    call delay
    ret
    
helloworld:
    .byte 'H','e','l','l','o',',',' '
    .byte 'w','o','r','l','d','!',0x00
