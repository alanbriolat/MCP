#!/usr/bin/env python

#
# Calculate PRT values for all of the MIDI notes, outputting them along
# with the increment values in a way that can be pasted into h180 source
# 
# The table contains 4 bytes per note: PRT Low, PRT High, Div, NULL
#
# Assumes the data is in low -> high order (why wouldn't it be?)
#

import sys, csv

# Source sample properties
source_freq = 2.0
source_rate = 256.0
# The countdown frequency of the PRT
prt_freq = 6144000.0 / 20.0

# Print the label for the table
print ".globl note_lookup"
print ".globl notename_lookup"

input = list(csv.reader(sys.stdin))

print "note_lookup:"
for octave, midi, note, freq in input:
    # Type cast the numeric values
    octave = int(octave)
    freq = float(freq)

    # Get a set of parameters for every divisor
    results = list()
    for div in xrange(1, 255):
        # Calculate the new sample rate
        # Ft / Rt = (Fs * D) / Rs
        # => Rt / Ft = Rs / (Fs * D)
        # => Rt = (Rs * Ft) / (Fs * D)
        rate = (source_rate * freq) / (source_freq * div)
        # Do not want sample rates above ~8kHz
        if rate > 8000: continue
        # Calculate the value for the PRT
        prt = int(round(prt_freq / rate))
        # Calculate the frequency given with the current parameters (to see the
        # error due to rounding)
        effective = (source_freq * div * (prt_freq / prt)) / source_rate
        # Calculate the error
        error = abs(effective - freq) / freq
        # Calculate an error factor that proritises high sample rate over 
        # accuracy (slightly)
        errorfactor = pow(rate, 1 - error)
        results.append((errorfactor, error, prt, div, rate, effective))

    # Rank the results with highest (most favourable) error factor first
    results.sort()
    results.reverse()
    
    # Get the best result
    errorfactor, error, prt, div, rate, effective = results[0]

    # Print the assembler for the entryOA
    print "    .int 0x%04x, 0x00%02x  # Midi: %3s, Note: %2s (%2s), Div: %2s, Rate: %4.2f, Freq: %4.2f, Error: (%.2f%%)" \
            % (prt, div, midi, note, octave, div, rate, freq, error * 100)

print "notename_lookup:"
for octave, midi, note, freq in input:
    print "    .byte '" + \
            "','".join([c for c in "%2ls%2s" % (note, octave)]) + "'"

