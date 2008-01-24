.globl lcd_init, lcd_putchar, lcd_print

start:
    call lcd_init

    ld hl, helloworld
    call lcd_print
    halt

helloworld:
    .byte 'H','e','l','l','o',',',' '
    .byte 'w','o','r','l','d','!',0x00
