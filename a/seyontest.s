# Terminal
.globl terminal_enableint
.globl terminal_print
.globl terminal_putchar
.globl terminal_getchar

# LCD text display
.globl lcd_putchar, lcd_init

# Utils
.globl crlf, helloworld

INT_IL=0x33
INT_ITC=0x34

start:
    call lcd_init
    call int_init
    ld a, 0x30
    ld hl, crlf
    call terminal_print
    ld hl, helloworld
    call terminal_print
    ld hl, crlf
    call terminal_print
0:  nop
    jr 0b

int_init:
    # Get addr of interrupt table
    ld hl, int_table
    ld a, h
    # Set interrupt base vector
    ld i, a
    # Set interrupt low base vector
    ld a, l
    and 0xe0
    out0 (INT_IL), a
    # Enable INT0, INT1, INT2
    ld a, 0x07
    out0 (INT_ITC), a

    call terminal_enableint

    # Enable interrupts
    im 2
    ei
    ret

.align 5
int_table:
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
int_int2:
int_prt0:
int_prt1:
int_dma0:
int_dma1:
int_csio:
int_asci0:
int_asci1:
    di
    call terminal_getchar
    call terminal_putchar
    call lcd_putchar
    ei
    reti
