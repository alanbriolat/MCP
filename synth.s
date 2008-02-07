.globl network_init
.globl network_getchar

.globl terminal_init
.globl terminal_getchar
.globl terminal_putchar
.globl terminal_putbyte
.globl terminal_print
.globl terminal_newline

.set IL, 0x33
.set ITC, 0x34

start:
    # Make sure interrupts are disabled during setup
    di
    # Set the stack pointer
    ld sp, 0xffff
    # Initialise the terminal interface
    call terminal_init
    # Initialise the network interface
    call network_init

    # Get the address of the interrupt table
    ld hl, interrupts
    # Set the interrupt base vector
    ld a, h
    ld i, a
    # Set the interrupt low base vector
    ld a, l
    and 0xe0    # Paranoia, .align 5 should do this anyway
    out0 (IL), a
    # Enable INT0, INT1 and INT2
    ld a, 0x07
    out0 (ITC), a

    # Enable interrupts
    im 2
    ei

    # Wait until something happens
    halt

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
int_int2:
int_prt0:
int_prt1:
int_dma0:
int_dma1:
int_csio:
int_asci0:
int_asci1:
