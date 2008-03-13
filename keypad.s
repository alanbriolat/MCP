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
    push hl
    in0 a, (KEYPAD_DATA)
    and 0x0f
    ld hl, keypad_bytemap
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
keypad_charmap:
    .byte 'D','E','F','0','C','9','8','7'
    .byte 'B','6','5','4','A','3','2','1'
#
# Keypad byte map (from the actual keypad values to what is 
# represented on the keys)
#
keypad_bytemap:
    .byte 0x0d,0x0e,0x0f,0x00,0x0c,0x09,0x08,0x07
    .byte 0x0b,0x06,0x05,0x04,0x0a,0x03,0x02,0x01
