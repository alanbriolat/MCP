.globl network_init
.globl network_getchar
#.globl NETWORK_RX
#.globl NETWORK_CTRLA
#.globl NETWORK_CTRLA_VALUE
#.globl NETWORK_STAT

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

.globl output_init
.globl output_volume
.globl output_wave
# I/O addresses of the PIO ports
.set OUTPUT_VOL,    0xb0
.set OUTPUT_WAVE,   0xb1
.set OUTPUT_CTRL,   0xb3

.globl terminal_init
.globl terminal_getchar
.globl terminal_putchar
.globl terminal_putbyte
.globl terminal_print
.globl terminal_newline

.globl keypad_getbyte

.set IL, 0x33
.set ITC, 0x34

.set PRT_TCR, 0x10
.set PRT_ENABLED, 0x11
.set PRT_DISABLED, 0x00
.set PRT0_RLD_L, 0x0e
.set PRT0_RLD_H, 0x0f
.set PRT0_DR_L, 0x0c
.set PRT0_DR_H, 0x0d

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
    ld a, 0xff
    call output_volume
    ld a, 0x6b
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

    # Put the pointer in the next place
    inc hl
    ld a, (hl)
    cp 0x00
    jr nz, 0f
    ld hl, sample_sine_sustain

    # Exchange registers, enable interrupts, return
0:  exx
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
    push hl
    sla a
    ld hl, note_table
    add a, l
    jr nc, 0f
    inc h
0:  ld l, a
    ld a, (hl)
    out0 (PRT0_RLD_L), a
    inc hl
    ld a, (hl)
    out0 (PRT0_RLD_H), a
    pop hl
    ret

sample_sine_sustain:
    .byte 0x83,0xa0,0xc1,0xd6,0xe3,0xe4,0xd8,0xc3,0xa4,0x82
    .byte 0x60,0x40,0x29,0x1b,0x1a,0x25,0x38,0x57,0x77,0x00
    
note_table:
    .int 0x0000    # C -5
    .int 0x0000    # C#/Db -5
    .int 0x0000    # D -5
    .int 0x0000    # D#/Eb -5
    .int 0x0000    # E -5
    .int 0x0000    # F -5
    .int 0x0000    # F#/Gb -5
    .int 0x0000    # G -5
    .int 0x0000    # G#/Ab -5
    .int 0x0000    # A -5
    .int 0x0000    # A#/Bb -5
    .int 0x0000    # B -5
    .int 0x0000    # C -4
    .int 0x0000    # C#/Db -4
    .int 0x0000    # D -4
    .int 0x0000    # D#/Eb -4
    .int 0x0000    # E -4
    .int 0x0000    # F -4
    .int 0x0000    # F#/Gb -4
    .int 0x0000    # G -4
    .int 0x0000    # G#/Ab -4
    .int 0x0000    # A -4
    .int 0x0000    # A#/Bb -4
    .int 0x0000    # B -4
    .int 0x0000    # C -3
    .int 0x0000    # C#/Db -3
    .int 0x0000    # D -3
    .int 0x0000    # D#/Eb -3
    .int 0x0000    # E -3
    .int 0x0dbd    # F -3
    .int 0x0cf7    # F#/Gb -3
    .int 0x0c03    # G -3
    .int 0x0b8f    # G#/Ab -3
    .int 0x0ae5    # A -3
    .int 0x0a4b    # A#/Bb -3
    .int 0x09bc    # B -3
    .int 0x092b    # C -2
    .int 0x08ab    # C#/Db -2
    .int 0x0824    # D -2
    .int 0x07b4    # D#/Eb -2
    .int 0x0746    # E -2
    .int 0x06de    # F -2
    .int 0x067b    # F#/Gb -2
    .int 0x0626    # G -2
    .int 0x05ce    # G#/Ab -2
    .int 0x056c    # A -2
    .int 0x0529    # A#/Bb -2
    .int 0x04de    # B -2
    .int 0x0499    # C -1
    .int 0x0459    # C#/Db -1
    .int 0x041c    # D -1
    .int 0x03dd    # D#/Eb -1
    .int 0x03a3    # E -1
    .int 0x0374    # F -1
    .int 0x0342    # F#/Gb -1
    .int 0x0310    # G -1
    .int 0x02e0    # G#/Ab -1
    .int 0x02b7    # A -1
    .int 0x0295    # A#/Bb -1
    .int 0x0270    # B -1
    .int 0x0249    # C 0
    .int 0x022b    # C#/Db 0
    .int 0x020d    # D 0
    .int 0x01eb    # D#/Eb 0
    .int 0x01d1    # E 0
    .int 0x01b8    # F 0
    .int 0x01a0    # F#/Gb 0
    .int 0x0189    # G 0
    .int 0x016e    # G#/Ab 0
    .int 0x015d    # A 0
    .int 0x0149    # A#/Bb 0
    .int 0x0135    # B 0
    .int 0x0124    # C 1
    .int 0x0113    # C#/Db 1
    .int 0x0104    # D 1
    .int 0x00f4    # D#/Eb 1
    .int 0x00e7    # E 1
    .int 0x00dc    # F 1
    .int 0x00ce    # F#/Gb 1
    .int 0x00c3    # G 1
    .int 0x00b8    # G#/Ab 1
    .int 0x00ac    # A 1
    .int 0x00a4    # A#/Bb 1
    .int 0x009b    # B 1
    .int 0x0094    # C 2
    .int 0x008b    # C#/Db 2
    .int 0x0080    # D 2
    .int 0x007b    # D#/Eb 2
    .int 0x0074    # E 2
    .int 0x006d    # F 2
    .int 0x0067    # F#/Gb 2
    .int 0x0061    # G 2
    .int 0x005c    # G#/Ab 2
    .int 0x0055    # A 2
    .int 0x0051    # A#/Bb 2
    .int 0x004d    # B 2
    .int 0x004b    # C 3
    .int 0x0046    # C#/Db 3
    .int 0x0041    # D 3
    .int 0x003d    # D#/Eb 3
    .int 0x0039    # E 3
    .int 0x0036    # F 3
    .int 0x0033    # F#/Gb 3
    .int 0x0031    # G 3
    .int 0x002e    # G#/Ab 3
    .int 0x002a    # A 3
    .int 0x0028    # A#/Bb 3
    .int 0x0026    # B 3
    .int 0x0024    # C 4
    .int 0x0022    # C#/Db 4
    .int 0x0020    # D 4
    .int 0x0000    # D#/Eb 4
    .int 0x0000    # E 4
    .int 0x0000    # F 4
    .int 0x0000    # F#/Gb 4
    .int 0x0000    # G 4
    .int 0x0000    # G#/Ab 4
    .int 0x0000    # A 4
    .int 0x0000    # A#/Bb 4
    .int 0x0000    # B 4
    .int 0x0000    # C 5
    .int 0x0000    # C#/Db 5
    .int 0x0000    # D 5
    .int 0x0000    # D#/Eb 5
    .int 0x0000    # E 5
    .int 0x0000    # F 5
    .int 0x0000    # F#/Gb 5
    .int 0x0000    # G 5
