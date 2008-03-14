############################################################
# Keypad
#
# Functions and data needed for keypad handling
############################################################

# Expose functions
.globl keypad_getbyte

# 
# Get the value of the key currently pressed (the value 
# represented on the key, not the value given by the 
# hardware)
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
# Lookup table to map between a hardware keypad value and
# the value represented on the key
#
keypad_bytemap:
    .byte 0x0d,0x0e,0x0f,0x00,0x0c,0x09,0x08,0x07
    .byte 0x0b,0x06,0x05,0x04,0x0a,0x03,0x02,0x01
