.globl network_init
.globl network_getchar

.globl output_init
.globl output_volume
.globl output_wave

.globl terminal_init
.globl terminal_getchar
.globl terminal_putchar
.globl terminal_putbyte
.globl terminal_print
.globl terminal_newline

.globl keypad_getchar
.globl keypad_getbyte

.globl lcd_putchar

.set IL, 0x33
.set ITC, 0x34

.set PRT_TCR, 0x10
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
    ld a, 0x39
    call set_note

    # Reset the network buffer pointer
    ld hl, netbuffer
    ld (netbufptr), hl

    # Set the instrument (channel 9)
    ld d, 0x12

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
    ld a, 0x11
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

squarewave:
    .byte 0x00

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
    ld d, a

2:  ei
    nop
    nop
    nop
    ld a, 0x00
    ld (keypad_lockout), a
    reti

int_prt0:
    di
    ex af, af
    in0 a, (PRT_TCR)
    in0 a, (PRT0_DR_L)
    ex af, af
    ld a, (squarewave)
    and a
    jr nz, 0f
    dec a
    jr 1f
0:  inc a
1:  call output_wave
    ld (squarewave), a
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
    call network_getchar
    # If it's a carriage return, end of packet
    cp 0x0d
    jr nz, 0f
    # Handle the packet
    call dopacket
    # Reset the buffer pointer
    ld hl, netbuffer
    ld (netbufptr), hl
    jr 1f
0:  ld hl, (netbufptr)
    ld (hl), a
    inc hl
    ld (netbufptr), hl
1:  ei
    reti

dopacket:
    ld hl, netbuffer
    ld l, d
    ld a, (hl)
    call set_note
    inc hl
    ld a, (hl)
    sla a
    call output_volume
    ret

int_asci1:
    reti

# General flags
#  7 = had network packet already (for getting rid of the first)
flags:
    .byte 0x00

netbufptr:
    .int netbuffer
.align 8
netbuffer:
    .space 70

# 
# Set the frequency based on the MIDI note
#
set_note:
    push hl
    sla a
    ld hl, note_table
    ld l, a
    ld a, (hl)
    out0 (PRT0_RLD_L), a
    inc hl
    ld a, (hl)
    out0 (PRT0_RLD_H), a
    pop hl
    ret
    
.align 8
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
