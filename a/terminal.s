.globl terminal_enableint
.globl terminal_print
.globl terminal_putchar
.globl terminal_getchar

TERMINAL_STAT=0x05
TERMINAL_TX=0x07
TERMINAL_RX=0x09

terminal_enableint:
    in0 a, (TERMINAL_STAT)
    or 0x08
    out0 (TERMINAL_STAT), a
    ret

terminal_putchar:
    push af
0:  in0 a, (TERMINAL_STAT)
    and 0x02
    cp 0x02
    jr nz, 0b
    pop af
    out0 (TERMINAL_TX), a
    ret

terminal_print:
0:  ld a, (hl)
    cp 0x00
    jr z, 1f
    call terminal_putchar
    inc hl
    jr 0b
1:  ret

terminal_getchar:
0:  in0 a, (TERMINAL_STAT)
    and 0x80
    cp 0x80
    jr nz, 0b
    in0 a, (TERMINAL_RX)
    ret
