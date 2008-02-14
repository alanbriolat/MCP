.globl parallel_init, parallel_outa, parallel_outb
.globl delay

start:
    ld sp, 0xffff
    call parallel_init
    ld a, 0x90
    call parallel_outa
0:  ld a, 0x00
    call parallel_outb
    ld b, 0x06
    call delay
    ld a, 0x7f
    call parallel_outb
    ld b, 0x06
    call delay
    ld a, 0xff
    call parallel_outb
    ld b, 0x06
    call delay
    ld a, 0x7f
    call parallel_outb
    ld b, 0x06
    call delay
    jr 0b
