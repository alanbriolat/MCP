# Two possible ways of arranging note data:
#
#   1.  Table of 2-byte PRT values plus table of 1-byte dividers
#   2.  Table of PRT-low, PRT-high, divider, NULL

# Lookup for method 1
push af             # 11
ld hl, note_prt     # 9
ld b, 0x00          # 6
sla a               # 7
ld c, a             # 4
add hl, bc          # 7
ld a, (hl)          # 6
out0 (PRTL), a      # 13
inc hl              # 4
ld a, (hl)          # 6
out0 (PRTH), a      # 13
pop af              # 9
ld hl, note_div     # 9
ld c, a             # 4
add hl, bc          # 7
ld a, (hl)          # 6
ld d, a             # 4
# Total:              125

# Lookup for method 2
    ld hl, note_table   # 9
    sla a               # 7
    sla a               # 7
    jr nc, 0f           # 6
    inc h               # 4
0:  add a, l            # 4
    jr nc, 1f           # 6
    inc h               # 4
1:  ld l, a             # 4
    ld a, (hl)          # 6
    out0 (PRTL), a      # 13
    inc hl              # 4
    ld a, (hl)          # 6
    out0 (PRTH), a      # 13
    inc hl              # 4
    ld a, (hl)          # 6
    ld d, a             # 4
# Total:                  107

