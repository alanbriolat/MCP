LCD_CTRL=0xb8
LCD_DATA=0xb9
KPD_DATA=0xb4
IL=0x33     # Interrupt vector Low
ITC=0x34    # INT/TRAP Control

start:
    ld sp, 0xffff

init:
    call initdisplay
    # Set interrupt base vector
    ld hl, int_table
    ld a, h
    ld i, a
    ld a, l        # 3 most significant bits to go on
    and 0xe0
    out0 (IL), a  # IL (interrupt vector low)
    ld a, 0x07
    out0 (ITC), a  # INT/TRAP control register
    im 2
    ei
mainloop:
    nop
    nop
    nop
    nop
    ld d, 0x00
0:  nop
    jr 0b

initdisplay:
    ld a, 0x01          # Clear
    out (LCD_CTRL), a
    ld b, 0x20
    call delay
    ld a, 0x0f          # Display on, cursor on, blink on
    out (LCD_CTRL), a
    ret

putchar:
    push bc
    out (LCD_DATA), a
    ld b, 0x01
    call delay
    pop bc
    ret

.align 4
kpd_chars:
    .byte 'D','E','F','0','C','9','8','7'
    .byte 'B','6','5','4','A','3','2','1'

.align 8
int_table:
    .int int1
    .int int2
    .int int1
    .int int1
    .int int1
    .int int1
    .int int1
    .int int1

int1:
    reti

int2:
    di
    ld a, d
    cp 0x00
    jr nz, 1f
  
    inc d
    in0 a, (KPD_DATA)
    and 0x0f
    ld hl, kpd_chars
    or l
    ld l, a
    ld a, (hl)
    call putchar
    ld b, 0xff
    call delay

1:  ld hl, mainloop
    ex (sp), hl
    ei
    reti

putbyte:
    push af
    ld b, 0x08
0:  rlca
    push af
    jr c, 1f
    ld a, 0x30
    call putchar
    jr 2f
1:  ld a, 0x31
    call putchar
2:  pop af
    djnz 0b
    pop af
    ret

delay:
0:  ld a, 0x20
1:  dec a
    jr nz, 1b
    djnz 0b
    ret
