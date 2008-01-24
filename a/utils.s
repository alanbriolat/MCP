.globl delay
.globl crlf
.globl helloworld

# Delay for approx. B * 55 microseconds
delay:
0:  ld a, 0x20
1:  dec a
    jr nz, 1b
    djnz 0b
    ret

crlf:
    .byte 0x0d, 0x0a,0x00

helloworld:
    .byte 'H','e','l','l','o',',',' '
    .byte 'w','o','r','l','d','!',0x00
