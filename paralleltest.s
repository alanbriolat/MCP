.globl parallel_init, parallel_outa
.globl delay

start:
    ld sp, 0xffff
    call parallel_init
0:  ld a, 0x00
    call parallel_outa
    ld a, 0x7f
    call parallel_outa
    ld a, 0xff
    call parallel_outa
    ld a, 0x7f
    call parallel_outa
    jr 0b
