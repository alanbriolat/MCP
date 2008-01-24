.globl delay

# Delay for approx. B * 55 microseconds
delay:
0:  ld a, 0x20
1:  dec a
    jr nz, 1b
    djnz 0b
    ret
