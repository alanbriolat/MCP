.globl network_init
.globl network_getchar

NETWORK_CTRLA=0x00
NETWORK_CTRLB=0x02
NETWORK_STAT=0x04
NETWORK_TX=0x06
NETWORK_RX=0x08

CTRLA=0x54      # ASCI 0 Control A - receive enable, transmit disable
                #   8-bit, no parity, 1 stop bit
CTRLB=0x01      # ASCI 0 Control B - 19200bps baud rate
STAT=0x0c       # ASCI Status - Receive interrupt enabled, CTS enabled

# Pointer into the network buffer
.lcomm bufptr, 2

# 
# Initialise the network interface
#
network_init:
    # Clear interrupt, set operating mode
    ld a, CTRLA
    out0 (NETWORK_CTRLA), a
    # Set baud rate
    ld a, CTRLB
    out0 (NETWORK_CTRLB), a
    # Enable interrupts
    ld a, STAT
    out0 (NETWORK_STAT), a
    # Reset the buffer pointer
    ld hl, network_buffer
    ld (bufptr), hl
    ret

# 
# Clear the interrupt on the network interface
#
network_clearint:
    ld a, CTRLA
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

#
# Interrupt sub-handler for network data - add it to the buffer
#
# Post-condition:
#   Accumulator contains the character that was received
#
network_handler:
    # Clear the interrupt
    call network_clearint
    # Make sure the character is definitely here
0:  in0 a, (NETWORK_STAT)
    bit 7, a
    jr z, 0b
    # Get the character
    in0 a, (NETWORK_RX)
    # Add the character to the buffer
    ld hl, (bufptr)
    ld (hl), a
    # Check if this was a carriage return
    cp 0x0d
    jr nz, 1f
    # CR = go back to beginning of the buffer
    ld hl, network_buffer
    jr 2f
    # Not CR = go to next buffer location
1:  inc hl
2:  ld (bufptr), hl
    ret

#
# Network data buffer to store complete packet of data
#
network_buffer:
    .space 64
