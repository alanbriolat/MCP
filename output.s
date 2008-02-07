############################################################
# Output device handler
#
# Output device consists of two DAC0832 chained together, 
# the first providing the Vref of the second.  The first 
# is on parallel port A and acts as a volume control, 
# scaling the range available to the second.  The second is
# the actual waveform output, connected to parallel port B.
############################################################

# Export the subroutines
.globl output_init
.globl output_volume
.globl output_wave

# I/O addresses of the PIO ports
.set OUTPUT_VOL,    0xb0
.set OUTPUT_WAVE,   0xb1
.set OUTPUT_CTRL,   0xb3

# 
# Initialise the parallel I/O controller to use both
# channels as outputs
#
output_init:
    # Set the mode to 0 - channels A, B and C are outputs
    ld a, 0x80
    out0 (OUTPUT_CTRL), a
    ret

# 
# Output a volume scaling level
#
output_volume:
    out0 (OUTPUT_VOL), a
    ret

#
# Output part of a wave
#
output_wave:
    out0 (OUTPUT_WAVE), a
    ret
