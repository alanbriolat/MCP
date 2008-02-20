.globl network_init
.globl network_clearint
.globl network_getchar

# 
# Initialise the network interface
#
network_init:
    # Clear interrupt, set operating mode
    ld a, NETWORK_CTRLA_VALUE
    out0 (NETWORK_CTRLA), a
    # Set baud rate
    ld a, NETWORK_CTRLB_VALUE
    out0 (NETWORK_CTRLB), a
    # Enable interrupts
    ld a, NETWORK_STAT_VALUE
    out0 (NETWORK_STAT), a
    ret

# 
# Clear the interrupt on the network interface
#
network_clearint:
    ld a, NETWORK_CTRLA_VALUE
    out0 (NETWORK_CTRLA), a
    ret

# 
# Get the current character from the network interface
#
network_getchar:
    call network_clearint
0:  in0 a, (NETWORK_STAT)
    bit 7, a
    jr z, 0b
    in0 a, (NETWORK_RX)
    ret
