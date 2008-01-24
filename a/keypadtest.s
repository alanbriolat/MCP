# LCD text display
.globl lcd_init, lcd_putchar, lcd_print
# Keypad
.globl kpd_getchar

KPD_DATA=0xb4
IL=0x33     # Interrupt vector Low
ITC=0x34    # INT/TRAP Control

start:
    #ld sp, 0xffff

init:
    call lcd_init
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
0:  halt
    jr 0b

.align 5
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
    jr z, 1f
    pop hl
    jr 2f

1:  ld d, 0xff
    call kpd_getchar
    call lcd_putchar

2:  ei
    nop
    nop
    nop
    ld d, 0x00
    reti
