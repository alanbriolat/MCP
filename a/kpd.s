.globl kpd_getchar

KPD_DATA=0xb4

# 
# Get a character from the keypad
#
# Returns the ASCII representation of the current keypress into the
# accumulator.
#
kpd_getchar:
    push hl
    in0 a, (KPD_DATA)
    and 0x0f
    ld hl, kpd_charmap
    add a, l
    jr nc, 0f
    inc h
0:  ld l, a
    ld a, (hl)
    pop hl
    ret

#
# Keypad character map
#
kpd_charmap:
    .byte 'D','E','F','0','C','9','8','7'
    .byte 'B','6','5','4','A','3','2','1'
