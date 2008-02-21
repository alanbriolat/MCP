# Networking
.globl network_init
.globl network_getchar

# Terminal
.globl terminal_init
.globl terminal_getchar
.globl terminal_putchar
.globl terminal_putbyte
.globl terminal_print
.globl terminal_newline

# Keypad
.globl keypad_getbyte

# Sound device
.globl output_init
.globl output_volume
.globl output_wave

# Note lookup tabel
.globl note_lookup

# PRT TCR values
.set PRT_ENABLED, 0x11
.set PRT_DISABLED, 0x00

start:
    # Make sure interrupts are disabled during setup
    di
    # Set the stack pointer
    ld sp, 0xffff
    # Initialise the terminal interface
    call terminal_init
    # Initialise the network interface
    call network_init
    # Initialise the output interface
    call output_init

    # Play an A (testing)
    ld a, 0xff
    call output_volume
    ld a, 0x39
    call set_note

    # Reset the network buffer pointer
    ld hl, netbuffer
    ld (netbufptr), hl

    # Set the instrument (channel 9)
    ld c, 0x12

    # Set the wave sample
    exx
    ld hl, sample_sine_sustain
    exx

    # Get the address of the interrupt table
    ld hl, interrupts
    # Set the  interrupt base vector
    ld a, h
    ld i, a
    # Set the interrupt low base vector
    ld a, l
    and 0xe0    # Paranoia, .align 5 should do this anyway
    out0 (IL), a
    # Enable INT0, INT1 and INT2
    ld a, 0x07
    out0 (ITC), a
    
    # Enable interrupts on PRT0
    ld a, PRT_ENABLED
    out0 (PRT_TCR), a

    # Enable interrupts
    im 2
    ei

    # Wait until something happens
0:  nop
    jr 0b

.align 5
interrupts:
    .int int_int1
    .int int_int2
    .int int_prt0
    .int int_prt1
    .int int_dma0
    .int int_dma1
    .int int_csio
    .int int_asci0
    .int int_asci1


int_int1:
    reti

# Keypad interrupt handler
keypad_lockout:
    .byte 0x00
int_int2:
    di
    ld a, (keypad_lockout)
    cp 0x00
    jr z, 1f
    pop hl
    jr 2f

1:  ld a, 0xff
    ld (keypad_lockout), a
    call keypad_getbyte
    # Change the instrument
    sla a
    ld c, a

2:  ei
    nop
    nop
    nop
    ld a, 0x00
    ld (keypad_lockout), a
    reti

#
# PRT0 Interrupt handler - wave output
#
# Uses only the shadow registers, so that the interrupt handler finishes quickly
# and can happen during other interrupts without making a mess
#
# D = position of the square wave
#
int_prt0:
    # Disable interrupts, exchange registers
    di
    ex af, af
    exx

    # Clear the interrupt
    in0 a, (PRT_TCR)
    in0 a, (PRT0_DR_L)

    # Output the part of the wave
    ld a, (hl)
    out0 (OUTPUT_WAVE), a

    # Load in the end pointer for comparison
    ex de, hl
    ld hl, sample_sine_sustain_end
    ex de, hl

    # Increment the pointer
    ld b, 0x00
    add hl, bc

    # Preserve the pointer while we check it's validity
    push hl

    # Reset the carry flag
    or a
    # current - end
    sbc hl, de
    
    # If the difference is negative, nothing needs to be done
    jp m, 0f

    # Reset the pointer and add the remainder to it
    ex de, hl
    ld hl, sample_sine_sustain
    add hl, de

    # Get rid of the item from the stack into DE
    pop de

    # Jump over the "if negative" section
    jr 1f

0:  # Restore the pointer - it's still within the sample
    pop hl

    # Exchange registers, enable interrupts, return
1:  exx
    ex af, af
    ei
    reti

int_prt1:
    reti
int_dma0:
    reti
int_dma1:
    reti
int_csio:
    reti
int_asci0:
    # Disable interrupts
    di
    # Get the character from the network
    ld a, NETWORK_CTRLA_VALUE
    out0 (NETWORK_CTRLA), a
8:  in0 a, (NETWORK_STAT)
    bit 7, a
    jr z, 8b
    in0 a, (NETWORK_RX)

    # If it's a carriage return, end of packet
    cp 0x0d
    ei
    jr nz, 0f

    # Handle the packet
    ld hl, netbuffer
    ld b, 0x00
    add hl, bc
    ld a, (hl)

    ex de, hl
    sla a
    ld hl, note_table
    add a, l
    jr nc, 8f
    inc h
8:  ld l, a
    ld a, (hl)
    out0 (PRT0_RLD_L), a
    inc hl
    ld a, (hl)
    out0 (PRT0_RLD_H), a
    ex de, hl

    inc hl
    ld a, (hl)
    sla a
    out0 (OUTPUT_VOL), a

    # Reset the buffer pointer
    ld hl, netbuffer
    ld (netbufptr), hl
    jr 1f
0:  ld hl, (netbufptr)
    ld (hl), a
    inc hl
    ld (netbufptr), hl
1:  
    reti

int_asci1:
    reti

# General flags
#  7 = had network packet already (for getting rid of the first)
flags:
    .byte 0x00

netbufptr:
    .int netbuffer
# This is massive because carelessly switching between channels really
# fast can cause buffer overflow if it is any smaller
netbuffer:
    .space 128

# 
# Set the frequency based on the MIDI note
#
set_note:
    # Preserve HL and BC
    push hl
    push bc
    # Load the base address
    ld hl, note_lookup
    ld b, 0x00
    # Shift left twice (for 4-byte boundary)
    sla a
    sla a
    # Bring the carry onto the high byte
    rl b
    # Load the low byte to C
    ld c, a
    # Do the offset
    add hl, bc
    # Low PRT byte
    ld a, (hl)
    out0 (PRT0_RLD_L), a
    # High PRT byte
    inc hl
    ld a, (hl)
    out0 (PRT0_RLD_H), a
    # Divisor
    inc hl
    ld a, (hl)
    # Store it in the registers used by the playback interrupt handler
    exx
    ld c, a
    exx
    # Restore registers
    pop bc
    pop hl
    # Return!
    ret

sample_sine_sustain:
    .byte 0x83,0xa0,0xc1,0xd6,0xe3,0xe4,0xd8,0xc3,0xa4,0x82
    .byte 0x60,0x40,0x29,0x1b,0x1a,0x25,0x38,0x57,0x77
sample_sine_sustain_end:
