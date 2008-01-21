#include "64180/64180.h"
 
start:
    ld hl, 0x9000
    call addmem
    jp (0x0000)

addmem:
    push af
    ld a, (hl)
    inc hl
    add a, (hl)
    inc hl
    ld (hl), a
    pop af
    ret
