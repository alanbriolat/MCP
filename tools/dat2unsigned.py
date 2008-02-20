#!/usr/bin/env python

import sys

# Convert all of the -1..1 values to 0..255 values
data = [int(((float(x) + 1) / 2) * 255) for x in sys.stdin]
# Add a null terminator
data.append(0)

# Print out the data in groups of 10 bytes in h180 ASM
while data:
    d = data[:10]
    data = data[10:]
    print ("    .byte " + ("0x%02x," * len(d))[:-1]) % tuple(d)
