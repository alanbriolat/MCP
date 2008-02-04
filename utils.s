.globl delay
.globl helloworld

# Delay for approx. B * 55 microseconds
delay:
0:  ld a, 0x20
1:  dec a
    jr nz, 1b
    djnz 0b
    ret

helloworld:
    .byte 'H','e','l','l','o',',',' '
    .byte 'w','o','r','l','d','!',0x00
