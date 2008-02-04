.globl parallel_init
.globl parallel_outa
.globl parallel_outb
.globl parallel_outc

PARALLEL_A=0xb0
PARALLEL_B=0xb1
PARALLEL_C=0xb2
PARALLEL_CTRL=0xb3

# 
# Initialise the parallel IO controller
#
parallel_init:
    # Set the mode - Mode 0, output on A, B and C
    ld a, 0x80
    out0 (PARALLEL_CTRL), a
    ret

parallel_outa:
    out0 (PARALLEL_A), a
    ret

parallel_outb:
    out0 (PARALLEL_B), a
    ret

parallel_outc:
    out0 (PARALLEL_C), a
    ret
