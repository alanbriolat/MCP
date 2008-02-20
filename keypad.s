.globl keypad_getchar
.globl keypad_getbyte
.globl KEYPAD_DATA

# 
# Get a character from the keypad
#
# Returns the ASCII representation of the current keypress into the
# accumulator.
#
keypad_getchar:
    push hl
    in0 a, (KEYPAD_DATA)
    and 0x0f
    ld hl, keypad_charmap
    add a, l
    jr nc, 0f
    inc h
0:  ld l, a
    ld a, (hl)
    pop hl
    ret

# 
# Get the actual value of the keypad key
#
keypad_getbyte:
    in0 a, (KEYPAD_DATA)
    and 0x0f
    ret

#
# Keypad character map
#
keypad_charmap:
    .byte 'D','E','F','0','C','9','8','7'
    .byte 'B','6','5','4','A','3','2','1'
