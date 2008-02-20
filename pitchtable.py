#!/usr/bin/env python

#
# Calculate PRT values for all of the MIDI notes, outputting them along
# with the increment values in a way that can be pasted into h180 source
# 
# The table contains 4 bytes per note: PRT Low, PRT High, Div, NULL
#

import sys, csv

dividers = {
        -5: 1.0,
        -4: 1.0,
        -3: 1.0,
        -2: 1.0,
        -1: 1.0,
        0:  1.0,
        1:  2.0,
        2:  4.0,
        3:  8.0,
        4:  16.0,
        5:  32.0,
}

source_freq = 440.0
source_rate = 8000.0
prt_freq = 6144000.0 / 20.0

for octave, midi, note, freq in csv.reader(sys.stdin):
    octave = int(octave)
    freq = float(freq)
    # Ft / Rt = (Fs * D) / Rs
    # => Rt / Ft = Rs / (Fs * D)
    # => Rt = (Rs * Ft) / (Fs * D)
    rate = (source_rate * freq) / (source_freq * dividers[octave])
    prt = int(round(prt_freq / rate))
    effective_freq = (source_freq * dividers[octave] * (prt_freq / prt)) / source_rate
    print "    .int 0x%04x, 0x00%02x  # Midi: %3s, Note: %5s (%2s), Div: %2s, Rate: %4s, Freq: %s (%s), Error: (%.2f%%)" \
            % (prt, dividers[octave], midi, note, octave, int(dividers[octave]), int(rate), freq, 
                    effective_freq, (abs(effective_freq - freq) / freq) * 100)
