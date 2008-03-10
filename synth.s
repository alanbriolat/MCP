######################################################
## MCP 2008 - networked MIDI instrument synthesiser ##
######################################################
#
# Notes:
#   
#   Network data not buffered, so buffer overruns not 
#   possible.
#
#   The network data counter B is used to check packet
#   length and discard incomplete packets.
#
#   B is allowed to be overwritten in rare cases, for 
#   example on keypad press.  This only causes packet
#   loss, which will happen during a keypad press 
#   anyway due to the continuous interrupt.
#
######################################################

### 
# Import functions from other files
###
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
# LCD Panel
.globl lcd_init
.globl lcd_clear
.globl lcd_putchar
.globl lcd_putbyte
.globl lcd_print
.globl lcd_setlocation
# Sound device
.globl output_init
.globl output_volume
.globl output_wave
# Utilities
.globl delay
# Note lookup table
.globl note_lookup


###
# Start of program
# Initialisation and entering the idle loop
###
start:
    # Make sure interrupts are disabled during setup
    di
    # Set the stack pointer
    ld sp, 0xffff
    # Disable DRAM refresh
    ld a, 0x00
    out0 (0x36), a

    ### Interrupt setup
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

    ### Device initialisation
    # Initialise the terminal interface
    call terminal_init
    # Initialise the network interface
    call network_init
    # Initialise the output interface
    call output_init
    # Initialise the LCD display
    call lcd_init

    # Reset the character count
    ld b, 0x00

    # Set the channel (default: 0)
    ld a, 0x00
    call set_channel

    # Write the "info" line to the LCD
    ld a, 0xc0
    call lcd_setlocation
    ld hl, lcdtextinit_info
    call lcd_print

    # Enable interrupts on PRT0
    ld a, PRT_ENABLED
    out0 (PRT_TCR), a

    # Enable interrupts
    im 2
    ei

    # Wait until something happens - using NOP because for some reason HALT
    # results in incorrect network data (even though the correct number of 
    # bytes is received
idleloop:
    nop
    jr idleloop


###
# Initial display data for the LCD text display
###
lcdtextinit_channel:
    .byte 'N','o',' ','i','n','s','t','r','u','m','e','n','t',' ',' ',' ',0x00
lcdtextinit_info:
    .byte 'N','o','t','e',':',' ',' ',' ',' ',' ','V','o','l',':',' ',' ',0x00


###
# Set the current channel
#
# Arguments: the 4-bit channel ID in the accumulator
#
# The channel number is stored left-shifted by one for efficiency reasons - 
# all usage of this value needs this form (16-bit lookup tables).  Interrupts
# must be disabled when this is called to avoid double-swapping.
###
channel:
    .byte 0x00
set_channel:
    # Shift and store the channel number
    sla a
    ld (channel), a
    
    ### Set the sample
    # Perform the table lookup
    ld hl, sample_lookup
    add a, l
    jr nc, 0f
    inc h
0:  ld l, a
    # Skip the low byte - .align 8 means we don't need it
    inc hl
    # Load into the "shadow" D register - the high byte of the sample
    # playback address (stop interrupts during this time to avoid
    # double-swapping of registers)
    ld a, (hl)
    exx
    ld d, a
    exx

    ### Show the instrument name
    # Set the LCD location
    ld a, LCD_INSTRUMENT
    call lcd_setlocation
    # Get the channel number back
    ld a, (channel)
    # Perform the table lookup
    ld hl, channelname_lookup
    add a, l
    jr nc, 0f
    inc h
0:  ld l, a
    ld e, (hl)
    inc hl
    ld d, (hl)
    ex de, hl
    # Print to the LCD
    call lcd_print

    ret


###
# Interrupt vector table, aligned to 5-bit boundary so that the 9
# bits of I + IL are the base of the vector table
###
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


int_int1: reti

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
    call set_channel

2:  ei
    nop
    nop
    nop
    ld a, 0x00
    ld (keypad_lockout), a
    reti

###
# PRT0 Interrupt handler - wave output
#
# Uses only the shadow registers, so that the interrupt handler finishes quickly
# and can happen during other interrupts without making a mess
###
int_prt0:
    # Disable interrupts, exchange registers
    di
    ex af, af
    exx

    # Clear the interrupt
    in0 a, (PRT_TCR)
    in0 a, (PRT0_DR_L)

    # Output the part of the wave
    ld a, (de)
    out0 (OUTPUT_WAVE), a

    ld a, e
    add a, c
    ld e, a

    exx
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

# 
# Network data interrupt handler
#
# Registers:
#   B = character counter
#   C = temp character holding
#
# Memory:
#   channel_pitch = most recent pitch value
#   channel_volume = most recent volume
#
channel_pitch:
    .byte 0x00
channel_volume:
    .byte 0x00

int_asci0:
    # Disable interrupts
    di
    # Clear the interrupt on the ASCI
    ld a, NETWORK_CTRLA_VALUE
    out0 (NETWORK_CTRLA), a
    # Get the character
0:  in0 a, (NETWORK_STAT)
    bit 7, a
    jr z, 0b
    in0 a, (NETWORK_RX)

    # Check for end of packet (carriage return)
    cp 0x0d
    # Re-enable interrupts to reduce effect on sound
    #ei
    # If not the end of the packet, go do something with the char
    jr nz, 1f

    # Reset the counter (but preserve it in A for now)
    ld a, b
    ld b, 0x00
    # Check if the packet was the correct length
    cp 0x21
    # If not, ignore it
    jr nz, 9f

    # Get the volume value
    ld a, (channel_volume)
    # 7-bit -> 8-bit
    sla a
    # Output the volume
    out0 (OUTPUT_VOL), a

    # Get the pitch value
    ld d, 0x00
    ld a, (channel_pitch)
    ld e, a
    # Load the base address
    ld hl, note_lookup
    # Shift value left twice (4-byte boundary)
    sla e
    sla e
    # Bring carry onto high byte
    rl d
    # Make the absolute address
    add hl, de
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
    #di
    exx
    ld c, a
    exx
    #ei
    
    # Skip over character handler
    jr 9f

1:  # Increment the character counter
    #inc b
    # Preserve the character
    ld c, a
    # Get the channel ID
    ld a, (channel)
    
    # Is this the pitch byte?
    cp b
    jr nz, 2f

    # Store it in the pitch variable
    ld a, c
    ld (channel_pitch), a

    # Skip over volume handler
    jr 8f

2:  # Is this the volume byte?
    inc a
    cp b
    jr nz, 8f

    # Store it in the volume variable
    ld a, c
    ld (channel_volume), a

8:  inc b

9:  ei
    reti

int_asci1:
    reti

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

###
# Channel names for the LCD text display
###
channelname_lookup:
    .int channelname_0
    .int channelname_1
    .int channelname_2
    .int channelname_3
    .int channelname_4
    .int channelname_5
    .int channelname_6
    .int channelname_7
    .int channelname_8
    .int channelname_9
    .int channelname_10
    .int channelname_11
    .int channelname_12
    .int channelname_13
    .int channelname_14
    .int channelname_15
channelname_0:
    .byte 'A','c','o','u','s','t','i','c',' ','B','a','s','s',' ','0','0',0x00
channelname_1:
    .byte 'C','e','l','l','o',' ',' ',' ',' ',' ',' ',' ',' ',' ','0','1',0x00
channelname_2:
    .byte 'C','h','u','r','c','h',' ','O','r','g','a','n',' ',' ','0','2',0x00
channelname_3:
    .byte 'P','i','a','n','o',' ',' ',' ',' ',' ',' ',' ',' ',' ','0','3',0x00
channelname_4:
    .byte 'S','a','x','o','p','h','o','n','e',' ',' ',' ',' ',' ','0','4',0x00
channelname_5:
    .byte 'M','e','l','o','d','y',' ',' ',' ',' ',' ',' ',' ',' ','0','5',0x00
channelname_6:
    .byte 'V','i','o','l','i','n',' ',' ',' ',' ',' ',' ',' ',' ','0','6',0x00
channelname_7:
    .byte 'T','r','o','m','b','o','n','e',' ',' ',' ',' ',' ',' ','0','7',0x00
channelname_8:
    .byte 'T','r','u','m','p','e','t',' ',' ',' ',' ',' ',' ',' ','0','8',0x00
channelname_9:
    .byte 'F','r','e','n','c','h',' ','H','o','r','n',' ',' ',' ','0','9',0x00
channelname_10:
    .byte 'S','y','n','t','h',' ',' ',' ',' ',' ',' ',' ',' ',' ','1','0',0x00
channelname_11:
    .byte 'E','l','e','c','.',' ','G','u','i','t','a','r',' ',' ','1','1',0x00
channelname_12:
    .byte 'A','c','o','u','s','.',' ','G','u','i','t','a','r',' ','1','2',0x00
channelname_13:
    .byte 'F','l','u','t','e',' ',' ',' ',' ',' ',' ',' ',' ',' ','1','3',0x00
channelname_14:
    .byte 'P','i','c','c','o','l','o',' ',' ',' ',' ',' ',' ',' ','1','4',0x00
channelname_15:
    .byte 'P','e','r','c','u','s','s','i','o','n',' ',' ',' ',' ','1','5',0x00


### 
# Instrument sample table
###
sample_lookup:
    .int sample_acbass_sustain      # 0
    .int sample_cello_sustain       # 1
    .int sample_organ_sustain       # 2
    .int sample_sine_sustain        # 3
    .int sample_sine_sustain        # 4
    .int sample_sine_sustain        # 5
    .int sample_sine_sustain        # 6
    .int sample_sine_sustain        # 7
    .int sample_sine_sustain        # 8
    .int sample_sine_sustain        # 9
    .int sample_synth_sustain       # 10
    .int sample_sine_sustain        # 11
    .int sample_acguitar_sustain    # 12
    .int sample_sine_sustain        # 13
    .int sample_sine_sustain        # 14
    .int sample_sine_sustain        # 15

###
# Instrument wavetable samples
###
.align 8
sample_acbass_sustain:
    .byte 0x80,0x8f,0xa0,0xaa,0xb4,0xbb,0xc3,0xc6,0xc6,0xc6
    .byte 0xc3,0xc0,0xbc,0xb4,0xad,0xa5,0xa0,0x9c,0x94,0x92
    .byte 0x8c,0x82,0x7b,0x74,0x6d,0x67,0x62,0x5b,0x56,0x53
    .byte 0x51,0x51,0x52,0x55,0x5c,0x66,0x6c,0x73,0x79,0x7d
    .byte 0x83,0x84,0x82,0x81,0x7f,0x83,0x8c,0x97,0xa2,0xb3
    .byte 0xbd,0xbd,0xc0,0xc5,0xcf,0xd5,0xd9,0xe3,0xec,0xef
    .byte 0xf2,0xf9,0xf7,0xf1,0xee,0xe7,0xe3,0xe0,0xdd,0xd9
    .byte 0xd0,0xc8,0xc3,0xbe,0xba,0xb6,0xb3,0xb1,0xaf,0xaf
    .byte 0xb4,0xb9,0xbb,0xb9,0xb7,0xb3,0xad,0xa5,0x9d,0x97
    .byte 0x91,0x8e,0x8c,0x89,0x86,0x82,0x79,0x6d,0x65,0x5b
    .byte 0x50,0x46,0x3e,0x33,0x25,0x1a,0x11,0x11,0x14,0x13
    .byte 0x11,0x0e,0x0b,0x07,0x01,0x03,0x0d,0x18,0x20,0x27
    .byte 0x2f,0x39,0x43,0x4d,0x56,0x61,0x69,0x77,0x80,0x8f
    .byte 0xa0,0xaa,0xb4,0xbb,0xc3,0xc6,0xc6,0xc6,0xc3,0xc0
    .byte 0xbc,0xb4,0xad,0xa5,0xa0,0x9c,0x94,0x92,0x8c,0x82
    .byte 0x7b,0x74,0x6d,0x67,0x62,0x5b,0x56,0x53,0x51,0x51
    .byte 0x52,0x55,0x5c,0x66,0x6c,0x73,0x79,0x7d,0x83,0x84
    .byte 0x82,0x81,0x7f,0x83,0x8c,0x97,0xa2,0xb3,0xbd,0xbd
    .byte 0xc0,0xc5,0xcf,0xd5,0xd9,0xe3,0xec,0xef,0xf2,0xf9
    .byte 0xf7,0xf0,0xee,0xe7,0xe3,0xe0,0xdd,0xd9,0xd0,0xc8
    .byte 0xc3,0xbe,0xba,0xb6,0xb3,0xb1,0xaf,0xaf,0xb4,0xb9
    .byte 0xbb,0xb9,0xb7,0xb3,0xad,0xa5,0x9d,0x97,0x91,0x8e
    .byte 0x8c,0x89,0x85,0x82,0x79,0x6d,0x65,0x5b,0x50,0x46
    .byte 0x3e,0x33,0x25,0x1a,0x11,0x11,0x14,0x13,0x11,0x0e
    .byte 0x0b,0x07,0x01,0x03,0x0d,0x18,0x20,0x27,0x2f,0x39
    .byte 0x43,0x4d,0x57,0x61,0x69,0x7f
sample_cello_sustain:
    .byte 0x7f,0x86,0x89,0x90,0x93,0x97,0x99,0x9a,0x9c,0x9e
    .byte 0x9e,0x9e,0x9e,0x9d,0x9c,0x9c,0x9e,0xa6,0xad,0xb2
    .byte 0xbc,0xc5,0xcd,0xd1,0xd2,0xc5,0xbc,0xbb,0xb9,0xb7
    .byte 0xb5,0xb4,0xb0,0xaa,0xa6,0xa3,0xa1,0x9f,0x9e,0x9c
    .byte 0x9a,0x9a,0x98,0x9a,0x9e,0x9f,0xa3,0xaf,0xb2,0xb9
    .byte 0xbc,0xbc,0xbc,0xb9,0xb5,0xb2,0xad,0xa8,0x9a,0x8e
    .byte 0x86,0x7f,0x78,0x75,0x75,0x77,0x78,0x7d,0x78,0x75
    .byte 0x73,0x6e,0x67,0x60,0x5b,0x51,0x4a,0x43,0x40,0x39
    .byte 0x36,0x34,0x2f,0x2c,0x27,0x21,0x1c,0x1c,0x1c,0x1b
    .byte 0x19,0x19,0x19,0x19,0x1b,0x20,0x21,0x23,0x23,0x23
    .byte 0x23,0x22,0x20,0x23,0x2a,0x2d,0x2f,0x33,0x34,0x39
    .byte 0x3d,0x3b,0x3b,0x3e,0x40,0x44,0x47,0x49,0x4c,0x53
    .byte 0x5a,0x62,0x67,0x71,0x7a,0x84,0x89,0x8d,0x92,0x9a
    .byte 0xa1,0xa4,0xa8,0xaa,0xb0,0xb2,0xb7,0xb7,0xbb,0xbc
    .byte 0xc3,0xcf,0xdb,0xe7,0xe8,0xe8,0xe8,0xe8,0xe5,0xe3
    .byte 0xde,0xd7,0xd1,0xcd,0xca,0xc8,0xc6,0xc6,0xc5,0xc1
    .byte 0xc1,0xc1,0xc0,0xbe,0xbe,0xbc,0xba,0xbb,0xba,0xb9
    .byte 0xb9,0xb7,0xb5,0xb2,0xb0,0xad,0xab,0xa8,0xa4,0xa1
    .byte 0x9e,0x98,0x97,0x8e,0x84,0x84,0x86,0x86,0x87,0x87
    .byte 0x88,0x84,0x7f,0x7a,0x73,0x6c,0x64,0x5a,0x53,0x4a
    .byte 0x47,0x40,0x3d,0x36,0x32,0x28,0x23,0x20,0x17,0x1e
    .byte 0x1d,0x1c,0x1c,0x20,0x22,0x23,0x22,0x1e,0x1e,0x1e
    .byte 0x1d,0x1c,0x1a,0x18,0x16,0x16,0x17,0x19,0x1e,0x22
    .byte 0x27,0x2d,0x32,0x38,0x40,0x42,0x45,0x47,0x4c,0x4e
    .byte 0x51,0x53,0x53,0x54,0x56,0x58,0x5a,0x5b,0x5b,0x5f
    .byte 0x62,0x65,0x6b,0x6e,0x73,0x7f
sample_organ_sustain:
    .byte 0x7f,0x8b,0x98,0xa4,0xad,0xb0,0xb0,0xad,0xa9,0xa8
    .byte 0xa6,0xa3,0xa1,0xa1,0xa4,0xa6,0xab,0xad,0xad,0xad
    .byte 0xad,0xad,0xaa,0xa4,0x9c,0x8e,0x89,0x89,0x8d,0x90
    .byte 0x93,0x9c,0x9f,0xa8,0xaf,0xb7,0xbc,0xc1,0xc3,0xc1
    .byte 0xc0,0xb7,0xaf,0x9e,0x93,0x90,0x95,0x95,0x97,0x92
    .byte 0x8b,0x89,0x89,0x90,0x93,0xa1,0xb0,0xc5,0xd6,0xdc
    .byte 0xd9,0xd1,0xcd,0xc1,0xc0,0xbe,0xbc,0xb7,0xad,0xa9
    .byte 0x9c,0x92,0x89,0x8d,0x93,0x92,0x90,0x8d,0x8b,0x81
    .byte 0x76,0x67,0x45,0x2c,0x21,0x1b,0x1b,0x1b,0x20,0x25
    .byte 0x2f,0x38,0x44,0x47,0x4a,0x56,0x54,0x4e,0x4e,0x4e
    .byte 0x4f,0x4c,0x43,0x2c,0x20,0x1b,0x1c,0x21,0x27,0x27
    .byte 0x27,0x25,0x1c,0x1c,0x1c,0x21,0x27,0x2c,0x3b,0x49
    .byte 0x56,0x60,0x71,0x7d,0x7a,0x7a,0x81,0x81,0x82,0x81
    .byte 0x7c,0x73,0x6b,0x6b,0x6e,0x77,0x7c,0x81,0x82,0x81
    .byte 0x7f,0x7d,0x75,0x6b,0x56,0x53,0x53,0x5a,0x67,0x73
    .byte 0x7f,0x86,0x8e,0x92,0x95,0x98,0x9c,0x9e,0x9c,0x99
    .byte 0x95,0x92,0x90,0x73,0x70,0x6e,0x6e,0x71,0x6e,0x6e
    .byte 0x6b,0x69,0x6e,0x6e,0x69,0x67,0x67,0x67,0x6c,0x7a
    .byte 0x88,0x9e,0xab,0xb4,0xb4,0xaf,0xa1,0x97,0x95,0x92
    .byte 0x90,0x89,0x7f,0x78,0x73,0x75,0x7d,0x7f,0x7d,0x78
    .byte 0x75,0x70,0x6b,0x64,0x5d,0x55,0x4f,0x44,0x38,0x23
    .byte 0x1c,0x19,0x1c,0x21,0x25,0x2a,0x31,0x39,0x47,0x4c
    .byte 0x56,0x54,0x53,0x4e,0x49,0x4a,0x4a,0x49,0x2c,0x27
    .byte 0x20,0x1c,0x19,0x19,0x1c,0x28,0x2c,0x2d,0x2a,0x27
    .byte 0x25,0x21,0x1e,0x23,0x2f,0x3d,0x49,0x53,0x5d,0x66
    .byte 0x73,0x8e,0x8d,0x86,0x76,0x7f
sample_synth_sustain:
    .byte 0x7f,0x8e,0x97,0x9f,0x9c,0x95,0x8d,0x89,0x8d,0x93
    .byte 0x95,0x9c,0xa3,0xad,0xb4,0xbb,0xbe,0xc3,0xc6,0xca
    .byte 0xcb,0xd1,0xd4,0xd7,0xd9,0xdb,0xdb,0xd6,0xcf,0xc8
    .byte 0xc0,0xaa,0x9c,0x8d,0x6e,0x64,0x5b,0x51,0x4a,0x47
    .byte 0x43,0x40,0x3e,0x3d,0x3b,0x3b,0x3b,0x3d,0x3e,0x3d
    .byte 0x34,0x31,0x2f,0x2f,0x36,0x3d,0x43,0x51,0x60,0x69
    .byte 0x6e,0x7c,0x82,0x8b,0x8e,0x8e,0x8b,0x8b,0x8e,0x93
    .byte 0x97,0x93,0x8b,0x81,0x7c,0x7d,0x82,0x86,0x8d,0x8e
    .byte 0x8d,0x81,0x7c,0x75,0x6e,0x6b,0x69,0x6c,0x75,0x81
    .byte 0x88,0x92,0x93,0x90,0x8d,0x90,0x92,0x9a,0xa1,0xa3
    .byte 0x98,0x93,0x8b,0x82,0x7a,0x75,0x70,0x6c,0x67,0x64
    .byte 0x62,0x62,0x66,0x6b,0x73,0x78,0x81,0x86,0x89,0x86
    .byte 0x7d,0x7a,0x7a,0x7d,0x86,0x89,0x88,0x82,0x7d,0x7a
    .byte 0x7c,0x7d,0x7d,0x7a,0x70,0x67,0x64,0x62,0x64,0x66
    .byte 0x6c,0x77,0x90,0x9a,0x9c,0x95,0x97,0xa4,0xb9,0xc1
    .byte 0xca,0xd2,0xd6,0xde,0xe3,0xe5,0xe7,0xea,0xea,0xed
    .byte 0xee,0xed,0xea,0xde,0xc8,0xc0,0xb7,0xa4,0x9a,0x87
    .byte 0x84,0x7d,0x75,0x70,0x69,0x64,0x55,0x4e,0x44,0x3e
    .byte 0x3b,0x39,0x31,0x2c,0x2a,0x31,0x39,0x42,0x4e,0x5a
    .byte 0x60,0x69,0x6e,0x78,0x7c,0x81,0x83,0x87,0x8b,0x8d
    .byte 0x90,0x8b,0x88,0x87,0x82,0x82,0x8d,0x90,0x93,0x93
    .byte 0x92,0x8d,0x87,0x7f,0x7a,0x71,0x6e,0x6c,0x6c,0x6c
    .byte 0x71,0x77,0x7f,0x82,0x84,0x7c,0x70,0x6c,0x6b,0x6b
    .byte 0x6b,0x6c,0x6e,0x78,0x78,0x7a,0x7c,0x7d,0x7d,0x7d
    .byte 0x7a,0x81,0x81,0x89,0x89,0x7c,0x76,0x70,0x6b,0x65
    .byte 0x64,0x64,0x62,0x66,0x67,0x7f
sample_acguitar_sustain:
    .byte 0x7f,0x88,0x93,0xaa,0xc5,0xc1,0xb7,0xca,0xcd,0xc5
    .byte 0xd5,0xb4,0xbe,0xa3,0xaa,0x9c,0xcc,0xc5,0xcf,0xed
    .byte 0xe5,0xcd,0xd7,0xd1,0xcd,0xaf,0xb0,0xd6,0xd7,0xdc
    .byte 0xde,0xde,0xd6,0xc3,0xb2,0xd1,0xcf,0xd9,0xed,0xe7
    .byte 0xcf,0xb4,0xd4,0xe2,0xef,0xd7,0xd9,0xb9,0x8d,0x76
    .byte 0x5f,0x5a,0x5d,0x7d,0x84,0x95,0x7a,0x92,0x96,0x9a
    .byte 0x77,0x89,0x6c,0x71,0x40,0x4e,0x75,0x4f,0x69,0x5f
    .byte 0x56,0x71,0x4c,0x51,0x55,0x58,0x62,0x53,0x6b,0x44
    .byte 0x71,0x7a,0x54,0x3d,0x5a,0x3e,0x5b,0x60,0x49,0x5d
    .byte 0x71,0x82,0x60,0x6e,0x58,0x7f,0x71,0x51,0x69,0x53
    .byte 0x7d,0x60,0x64,0x5a,0x6e,0x60,0x47,0x56,0x55,0x38
    .byte 0x21,0x2f,0x27,0x3e,0x52,0x65,0x4e,0x7d,0x5f,0x23
    .byte 0x2c,0x40,0x25,0x1c,0x1b,0x14,0x36,0x2c,0x47,0x81
    .byte 0xb0,0xb4,0xc3,0xc7,0xcb,0x9c,0x97,0xa8,0xb9,0xc8
    .byte 0xc3,0xc3,0xb4,0xc6,0xc5,0xc6,0xd1,0xc6,0xc0,0xb9
    .byte 0xe0,0xed,0xec,0xe7,0xd2,0xdb,0xcd,0xd4,0xca,0xdb
    .byte 0xc6,0xc6,0xca,0xe7,0xd2,0xd2,0xf3,0xec,0xdb,0xa3
    .byte 0x8e,0xa3,0x82,0x6b,0x65,0x73,0x60,0x7c,0x98,0xb4
    .byte 0x92,0x68,0x81,0x82,0x7a,0x84,0x84,0x6b,0x71,0x7d
    .byte 0x87,0x73,0x6b,0x7c,0x60,0x5a,0x70,0x86,0x7d,0x60
    .byte 0x71,0x5b,0x86,0x67,0x71,0x82,0x6e,0x81,0x5b,0x5f
    .byte 0x78,0x92,0x64,0x62,0x5f,0x9f,0xb0,0x58,0x82,0x7a
    .byte 0x87,0x56,0x8e,0x70,0x95,0x6c,0x7d,0x64,0x6e,0x62
    .byte 0x62,0x5d,0x68,0x75,0x1b,0x2f,0x36,0x31,0x1e,0x61
    .byte 0x54,0x44,0x5b,0x70,0x4e,0x58,0x1c,0x18,0x14,0x1b
    .byte 0x3d,0x50,0x60,0x64,0x25,0x7f
sample_sine_sustain:
    .byte 0x7f,0x85,0x8a,0x90,0x95,0x9b,0xa0,0xa6,0xab,0xb0
    .byte 0xb5,0xba,0xbf,0xc3,0xc8,0xcc,0xd0,0xd4,0xd8,0xdb
    .byte 0xde,0xe1,0xe4,0xe7,0xe9,0xeb,0xed,0xee,0xf0,0xf1
    .byte 0xf1,0xf2,0xf2,0xf2,0xf1,0xf1,0xf0,0xee,0xed,0xeb
    .byte 0xe9,0xe7,0xe4,0xe1,0xde,0xdb,0xd8,0xd4,0xd0,0xcc
    .byte 0xc8,0xc3,0xbf,0xba,0xb5,0xb0,0xab,0xa6,0xa0,0x9b
    .byte 0x95,0x90,0x8a,0x85,0x7f,0x79,0x74,0x6e,0x69,0x63
    .byte 0x5e,0x58,0x53,0x4e,0x49,0x44,0x3f,0x3b,0x36,0x32
    .byte 0x2e,0x2a,0x26,0x23,0x20,0x1d,0x1a,0x17,0x15,0x13
    .byte 0x11,0x10,0x0e,0x0e,0x0d,0x0c,0x0c,0x0c,0x0d,0x0d
    .byte 0x0e,0x10,0x11,0x13,0x15,0x17,0x1a,0x1d,0x20,0x23
    .byte 0x26,0x2a,0x2e,0x32,0x36,0x3b,0x3f,0x44,0x49,0x4e
    .byte 0x53,0x58,0x5e,0x63,0x69,0x6e,0x74,0x79,0x7f,0x85
    .byte 0x8a,0x90,0x95,0x9b,0xa0,0xa6,0xab,0xb0,0xb5,0xba
    .byte 0xbf,0xc3,0xc8,0xcc,0xd0,0xd4,0xd8,0xdb,0xde,0xe1
    .byte 0xe4,0xe7,0xe9,0xeb,0xed,0xee,0xf0,0xf1,0xf1,0xf2
    .byte 0xf2,0xf2,0xf1,0xf1,0xf0,0xee,0xed,0xeb,0xe9,0xe7
    .byte 0xe4,0xe1,0xde,0xdb,0xd8,0xd4,0xd0,0xcc,0xc8,0xc3
    .byte 0xbf,0xba,0xb5,0xb0,0xab,0xa6,0xa0,0x9b,0x95,0x90
    .byte 0x8a,0x85,0x7f,0x79,0x74,0x6e,0x69,0x63,0x5e,0x58
    .byte 0x53,0x4e,0x49,0x44,0x3f,0x3b,0x36,0x32,0x2e,0x2a
    .byte 0x26,0x23,0x20,0x1d,0x1a,0x17,0x15,0x13,0x11,0x10
    .byte 0x0e,0x0d,0x0d,0x0c,0x0c,0x0c,0x0d,0x0d,0x0e,0x10
    .byte 0x11,0x13,0x15,0x17,0x1a,0x1d,0x20,0x23,0x26,0x2a
    .byte 0x2e,0x32,0x36,0x3b,0x3f,0x44,0x49,0x4e,0x53,0x58
    .byte 0x5e,0x63,0x69,0x6e,0x74,0x79
