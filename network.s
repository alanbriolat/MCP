.globl network_init
.globl network_clearint
.globl network_getchar
.globl NETWORK_CTRLA
.globl NETWORK_CTRLB
.globl NETWORK_STAT
.globl NETWORK_TX
.globl NETWORK_RX
.globl NETWORK_CTRLA_VALUE
.globl NETWORK_CTRLB_VALUE
.globl NETWORK_STAT_VALUE

.set NETWORK_CTRLA, 0x00
.set NETWORK_CTRLB, 0x02
.set NETWORK_STAT, 0x04
.set NETWORK_TX, 0x06
.set NETWORK_RX, 0x08

# ASCI 0 Control A - receive enable, transmit disable 8-bit, 
#   no parity, 1 stop bit
.set NETWORK_CTRLA_VALUE, 0x54
# ASCI 0 Control B - 19200bps baud rate
.set NETWORK_CTRLB_VALUE, 0x01
# ASCI Status - Receive interrupt enabled, CTS enabled
.set NETWORK_STAT_VALUE, 0x0c

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
