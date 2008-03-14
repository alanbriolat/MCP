############################################################
# Network
#
# Functions for handling the network device
############################################################

# Expose functions
.globl network_init
.globl network_getchar

# 
# Initialise the network interface (see defs.s for the actual
# settings being used - NETWORK_*_VALUE).  This includes 
# clearing the interrupt from the last character the monitor
# program read.
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
# Get the current character from the network interface, 
# returning it in the accumulator.
#
network_getchar:
    # Reset CTRLA - the combination of this, reading STAT and
    # reading the data has the effect of clearing the interrupt
    ld a, NETWORK_CTRLA_VALUE
    out0 (NETWORK_CTRLA), a
    # Wait until the receive buffer full flag is set
0:  in0 a, (NETWORK_STAT)
    bit 7, a
    jr z, 0b
    # Read in the character
    in0 a, (NETWORK_RX)
    ret
