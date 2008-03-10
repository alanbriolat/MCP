.globl note_lookup
.globl notename_lookup
note_lookup:
    .int 0x0126, 0x0001  # Midi:   0, Note:  C (-5), Div:  1, Rate: 1046.50, Freq: 8.18, Error: (0.15%)
    .int 0x0115, 0x0001  # Midi:   1, Note: C# (-5), Div:  1, Rate: 1108.73, Freq: 8.66, Error: (0.03%)
    .int 0x0106, 0x0001  # Midi:   2, Note:  D (-5), Div:  1, Rate: 1174.66, Freq: 9.18, Error: (0.18%)
    .int 0x00e9, 0x0001  # Midi:   3, Note: Eb (-5), Div:  1, Rate: 1318.51, Freq: 10.30, Error: (0.00%)
    .int 0x00e9, 0x0001  # Midi:   4, Note:  E (-5), Div:  1, Rate: 1318.51, Freq: 10.30, Error: (0.00%)
    .int 0x00dc, 0x0001  # Midi:   5, Note:  F (-5), Div:  1, Rate: 1396.91, Freq: 10.91, Error: (0.04%)
    .int 0x00d0, 0x0001  # Midi:   6, Note: F# (-5), Div:  1, Rate: 1479.98, Freq: 11.56, Error: (0.21%)
    .int 0x00c4, 0x0001  # Midi:   7, Note:  G (-5), Div:  1, Rate: 1567.98, Freq: 12.25, Error: (0.04%)
    .int 0x00b9, 0x0001  # Midi:   8, Note: G# (-5), Div:  1, Rate: 1661.22, Freq: 12.98, Error: (0.04%)
    .int 0x00af, 0x0001  # Midi:   9, Note:  A (-5), Div:  1, Rate: 1760.00, Freq: 13.75, Error: (0.26%)
    .int 0x00a5, 0x0001  # Midi:  10, Note: Bb (-5), Div:  1, Rate: 1864.66, Freq: 14.57, Error: (0.15%)
    .int 0x009c, 0x0001  # Midi:  11, Note:  B (-5), Div:  1, Rate: 1975.53, Freq: 15.43, Error: (0.32%)
    .int 0x0093, 0x0001  # Midi:  12, Note:  C (-4), Div:  1, Rate: 2093.00, Freq: 16.35, Error: (0.15%)
    .int 0x008b, 0x0001  # Midi:  13, Note: C# (-4), Div:  1, Rate: 2217.46, Freq: 17.32, Error: (0.33%)
    .int 0x0083, 0x0001  # Midi:  14, Note:  D (-4), Div:  1, Rate: 2349.32, Freq: 18.35, Error: (0.18%)
    .int 0x007b, 0x0001  # Midi:  15, Note: Eb (-4), Div:  1, Rate: 2489.02, Freq: 19.45, Error: (0.34%)
    .int 0x0074, 0x0001  # Midi:  16, Note:  E (-4), Div:  1, Rate: 2637.02, Freq: 20.60, Error: (0.43%)
    .int 0x006e, 0x0001  # Midi:  17, Note:  F (-4), Div:  1, Rate: 2793.83, Freq: 21.83, Error: (0.04%)
    .int 0x0068, 0x0001  # Midi:  18, Note: F# (-4), Div:  1, Rate: 2959.96, Freq: 23.12, Error: (0.21%)
    .int 0x0062, 0x0001  # Midi:  19, Note:  G (-4), Div:  1, Rate: 3135.96, Freq: 24.50, Error: (0.04%)
    .int 0x005c, 0x0001  # Midi:  20, Note: G# (-4), Div:  1, Rate: 3322.44, Freq: 25.96, Error: (0.50%)
    .int 0x0057, 0x0001  # Midi:  21, Note:  A (-4), Div:  1, Rate: 3520.00, Freq: 27.50, Error: (0.31%)
    .int 0x0052, 0x0001  # Midi:  22, Note: Bb (-4), Div:  1, Rate: 3729.31, Freq: 29.14, Error: (0.46%)
    .int 0x004e, 0x0001  # Midi:  23, Note:  B (-4), Div:  1, Rate: 3951.07, Freq: 30.87, Error: (0.32%)
    .int 0x0049, 0x0001  # Midi:  24, Note:  C (-3), Div:  1, Rate: 4186.01, Freq: 32.70, Error: (0.53%)
    .int 0x0045, 0x0001  # Midi:  25, Note: C# (-3), Div:  1, Rate: 4434.92, Freq: 34.65, Error: (0.39%)
    .int 0x0041, 0x0001  # Midi:  26, Note:  D (-3), Div:  1, Rate: 4698.64, Freq: 36.71, Error: (0.59%)
    .int 0x003e, 0x0001  # Midi:  27, Note: Eb (-3), Div:  1, Rate: 4978.03, Freq: 38.89, Error: (0.47%)
    .int 0x003a, 0x0001  # Midi:  28, Note:  E (-3), Div:  1, Rate: 5274.04, Freq: 41.20, Error: (0.43%)
    .int 0x0037, 0x0001  # Midi:  29, Note:  F (-3), Div:  1, Rate: 5587.65, Freq: 43.65, Error: (0.04%)
    .int 0x0034, 0x0001  # Midi:  30, Note: F# (-3), Div:  1, Rate: 5919.91, Freq: 46.25, Error: (0.21%)
    .int 0x0031, 0x0001  # Midi:  31, Note:  G (-3), Div:  1, Rate: 6271.93, Freq: 49.00, Error: (0.04%)
    .int 0x002e, 0x0001  # Midi:  32, Note: G# (-3), Div:  1, Rate: 6644.88, Freq: 51.91, Error: (0.50%)
    .int 0x002c, 0x0001  # Midi:  33, Note:  A (-3), Div:  1, Rate: 7040.00, Freq: 55.00, Error: (0.83%)
    .int 0x0029, 0x0001  # Midi:  34, Note: Bb (-3), Div:  1, Rate: 7458.62, Freq: 58.27, Error: (0.46%)
    .int 0x0027, 0x0001  # Midi:  35, Note:  B (-3), Div:  1, Rate: 7902.13, Freq: 61.74, Error: (0.32%)
    .int 0x0049, 0x0002  # Midi:  36, Note:  C (-2), Div:  2, Rate: 4186.01, Freq: 65.41, Error: (0.53%)
    .int 0x0045, 0x0002  # Midi:  37, Note: C# (-2), Div:  2, Rate: 4434.92, Freq: 69.30, Error: (0.39%)
    .int 0x0041, 0x0002  # Midi:  38, Note:  D (-2), Div:  2, Rate: 4698.64, Freq: 73.42, Error: (0.59%)
    .int 0x003e, 0x0002  # Midi:  39, Note: Eb (-2), Div:  2, Rate: 4978.03, Freq: 77.78, Error: (0.47%)
    .int 0x003a, 0x0002  # Midi:  40, Note:  E (-2), Div:  2, Rate: 5274.04, Freq: 82.41, Error: (0.43%)
    .int 0x0037, 0x0002  # Midi:  41, Note:  F (-2), Div:  2, Rate: 5587.65, Freq: 87.31, Error: (0.04%)
    .int 0x0034, 0x0002  # Midi:  42, Note: F# (-2), Div:  2, Rate: 5919.91, Freq: 92.50, Error: (0.21%)
    .int 0x0031, 0x0002  # Midi:  43, Note:  G (-2), Div:  2, Rate: 6271.93, Freq: 98.00, Error: (0.04%)
    .int 0x002e, 0x0002  # Midi:  44, Note: G# (-2), Div:  2, Rate: 6644.88, Freq: 103.83, Error: (0.50%)
    .int 0x002c, 0x0002  # Midi:  45, Note:  A (-2), Div:  2, Rate: 7040.00, Freq: 110.00, Error: (0.83%)
    .int 0x0029, 0x0002  # Midi:  46, Note: Bb (-2), Div:  2, Rate: 7458.62, Freq: 116.54, Error: (0.46%)
    .int 0x0027, 0x0002  # Midi:  47, Note:  B (-2), Div:  2, Rate: 7902.13, Freq: 123.47, Error: (0.32%)
    .int 0x0037, 0x0003  # Midi:  48, Note:  C (-1), Div:  3, Rate: 5581.35, Freq: 130.81, Error: (0.07%)
    .int 0x0034, 0x0003  # Midi:  49, Note: C# (-1), Div:  3, Rate: 5913.23, Freq: 138.59, Error: (0.09%)
    .int 0x0031, 0x0003  # Midi:  50, Note:  D (-1), Div:  3, Rate: 6264.85, Freq: 146.83, Error: (0.07%)
    .int 0x002e, 0x0003  # Midi:  51, Note: Eb (-1), Div:  3, Rate: 6637.38, Freq: 155.56, Error: (0.62%)
    .int 0x002c, 0x0003  # Midi:  52, Note:  E (-1), Div:  3, Rate: 7032.05, Freq: 164.81, Error: (0.71%)
    .int 0x0029, 0x0003  # Midi:  53, Note:  F (-1), Div:  3, Rate: 7450.20, Freq: 174.61, Error: (0.57%)
    .int 0x0027, 0x0003  # Midi:  54, Note: F# (-1), Div:  3, Rate: 7893.21, Freq: 185.00, Error: (0.21%)
    .int 0x0031, 0x0004  # Midi:  55, Note:  G (-1), Div:  4, Rate: 6271.93, Freq: 196.00, Error: (0.04%)
    .int 0x002e, 0x0004  # Midi:  56, Note: G# (-1), Div:  4, Rate: 6644.88, Freq: 207.65, Error: (0.50%)
    .int 0x002c, 0x0004  # Midi:  57, Note:  A (-1), Div:  4, Rate: 7040.00, Freq: 220.00, Error: (0.83%)
    .int 0x0029, 0x0004  # Midi:  58, Note: Bb (-1), Div:  4, Rate: 7458.62, Freq: 233.08, Error: (0.46%)
    .int 0x0027, 0x0004  # Midi:  59, Note:  B (-1), Div:  4, Rate: 7902.13, Freq: 246.94, Error: (0.32%)
    .int 0x002e, 0x0005  # Midi:  60, Note:  C ( 0), Div:  5, Rate: 6697.61, Freq: 261.63, Error: (0.29%)
    .int 0x002b, 0x0005  # Midi:  61, Note: C# ( 0), Div:  5, Rate: 7095.88, Freq: 277.18, Error: (0.68%)
    .int 0x0029, 0x0005  # Midi:  62, Note:  D ( 0), Div:  5, Rate: 7517.82, Freq: 293.66, Error: (0.33%)
    .int 0x0027, 0x0005  # Midi:  63, Note: Eb ( 0), Div:  5, Rate: 7964.85, Freq: 311.13, Error: (1.10%)
    .int 0x002c, 0x0006  # Midi:  64, Note:  E ( 0), Div:  6, Rate: 7032.05, Freq: 329.63, Error: (0.71%)
    .int 0x0029, 0x0006  # Midi:  65, Note:  F ( 0), Div:  6, Rate: 7450.20, Freq: 349.23, Error: (0.57%)
    .int 0x0027, 0x0006  # Midi:  66, Note: F# ( 0), Div:  6, Rate: 7893.21, Freq: 369.99, Error: (0.21%)
    .int 0x002b, 0x0007  # Midi:  67, Note:  G ( 0), Div:  7, Rate: 7167.92, Freq: 392.00, Error: (0.33%)
    .int 0x0028, 0x0007  # Midi:  68, Note: G# ( 0), Div:  7, Rate: 7594.14, Freq: 415.30, Error: (1.13%)
    .int 0x002c, 0x0008  # Midi:  69, Note:  A ( 0), Div:  8, Rate: 7040.00, Freq: 440.00, Error: (0.83%)
    .int 0x0029, 0x0008  # Midi:  70, Note: Bb ( 0), Div:  8, Rate: 7458.62, Freq: 466.16, Error: (0.46%)
    .int 0x0027, 0x0008  # Midi:  71, Note:  B ( 0), Div:  8, Rate: 7902.13, Freq: 493.88, Error: (0.32%)
    .int 0x0029, 0x0009  # Midi:  72, Note:  C ( 1), Div:  9, Rate: 7441.79, Freq: 523.25, Error: (0.68%)
    .int 0x0027, 0x0009  # Midi:  73, Note: C# ( 1), Div:  9, Rate: 7884.31, Freq: 554.37, Error: (0.09%)
    .int 0x0029, 0x000a  # Midi:  74, Note:  D ( 1), Div: 10, Rate: 7517.82, Freq: 587.33, Error: (0.33%)
    .int 0x0027, 0x000a  # Midi:  75, Note: Eb ( 1), Div: 10, Rate: 7964.85, Freq: 622.25, Error: (1.10%)
    .int 0x0028, 0x000b  # Midi:  76, Note:  E ( 1), Div: 11, Rate: 7671.33, Freq: 659.26, Error: (0.11%)
    .int 0x0029, 0x000c  # Midi:  77, Note:  F ( 1), Div: 12, Rate: 7450.20, Freq: 698.46, Error: (0.57%)
    .int 0x0027, 0x000c  # Midi:  78, Note: F# ( 1), Div: 12, Rate: 7893.21, Freq: 739.99, Error: (0.21%)
    .int 0x0028, 0x000d  # Midi:  79, Note:  G ( 1), Div: 13, Rate: 7719.29, Freq: 783.99, Error: (0.51%)
    .int 0x0028, 0x000e  # Midi:  80, Note: G# ( 1), Div: 14, Rate: 7594.14, Freq: 830.61, Error: (1.13%)
    .int 0x0029, 0x000f  # Midi:  81, Note:  A ( 1), Div: 15, Rate: 7509.33, Freq: 880.00, Error: (0.22%)
    .int 0x0027, 0x000f  # Midi:  82, Note: Bb ( 1), Div: 15, Rate: 7955.86, Freq: 932.33, Error: (0.99%)
    .int 0x0027, 0x0010  # Midi:  83, Note:  B ( 1), Div: 16, Rate: 7902.13, Freq: 987.77, Error: (0.32%)
    .int 0x0027, 0x0011  # Midi:  84, Note:  C ( 2), Div: 17, Rate: 7879.55, Freq: 1046.50, Error: (0.03%)
    .int 0x0027, 0x0012  # Midi:  85, Note: C# ( 2), Div: 18, Rate: 7884.31, Freq: 1108.73, Error: (0.09%)
    .int 0x0027, 0x0013  # Midi:  86, Note:  D ( 2), Div: 19, Rate: 7913.49, Freq: 1174.66, Error: (0.46%)
    .int 0x0027, 0x0014  # Midi:  87, Note: Eb ( 2), Div: 20, Rate: 7964.85, Freq: 1244.51, Error: (1.10%)
    .int 0x0028, 0x0016  # Midi:  88, Note:  E ( 2), Div: 22, Rate: 7671.33, Freq: 1318.51, Error: (0.11%)
    .int 0x002b, 0x0019  # Midi:  89, Note:  F ( 2), Div: 25, Rate: 7152.19, Freq: 1396.91, Error: (0.11%)
    .int 0x0027, 0x0018  # Midi:  90, Note: F# ( 2), Div: 24, Rate: 7893.21, Freq: 1479.98, Error: (0.21%)
    .int 0x0028, 0x001a  # Midi:  91, Note:  G ( 2), Div: 26, Rate: 7719.29, Freq: 1567.98, Error: (0.51%)
    .int 0x0027, 0x001b  # Midi:  92, Note: G# ( 2), Div: 27, Rate: 7875.41, Freq: 1661.22, Error: (0.02%)
    .int 0x0029, 0x001e  # Midi:  93, Note:  A ( 2), Div: 30, Rate: 7509.33, Freq: 1760.00, Error: (0.22%)
    .int 0x0028, 0x001f  # Midi:  94, Note: Bb ( 2), Div: 31, Rate: 7699.22, Freq: 1864.66, Error: (0.25%)
    .int 0x0027, 0x0020  # Midi:  95, Note:  B ( 2), Div: 32, Rate: 7902.13, Freq: 1975.53, Error: (0.32%)
    .int 0x0027, 0x0022  # Midi:  96, Note:  C ( 3), Div: 34, Rate: 7879.55, Freq: 2093.00, Error: (0.03%)
    .int 0x0027, 0x0024  # Midi:  97, Note: C# ( 3), Div: 36, Rate: 7884.31, Freq: 2217.46, Error: (0.09%)
    .int 0x0027, 0x0026  # Midi:  98, Note:  D ( 3), Div: 38, Rate: 7913.49, Freq: 2349.32, Error: (0.46%)
    .int 0x0027, 0x0028  # Midi:  99, Note: Eb ( 3), Div: 40, Rate: 7964.85, Freq: 2489.02, Error: (1.10%)
    .int 0x0027, 0x002b  # Midi: 100, Note:  E ( 3), Div: 43, Rate: 7849.74, Freq: 2637.02, Error: (0.35%)
    .int 0x0027, 0x002d  # Midi: 101, Note:  F ( 3), Div: 45, Rate: 7946.88, Freq: 2793.83, Error: (0.88%)
    .int 0x0027, 0x0030  # Midi: 102, Note: F# ( 3), Div: 48, Rate: 7893.21, Freq: 2959.96, Error: (0.21%)
    .int 0x0027, 0x0033  # Midi: 103, Note:  G ( 3), Div: 51, Rate: 7870.65, Freq: 3135.96, Error: (0.08%)
    .int 0x0027, 0x0036  # Midi: 104, Note: G# ( 3), Div: 54, Rate: 7875.41, Freq: 3322.44, Error: (0.02%)
    .int 0x0027, 0x0039  # Midi: 105, Note:  A ( 3), Div: 57, Rate: 7904.56, Freq: 3520.00, Error: (0.35%)
    .int 0x0028, 0x003e  # Midi: 106, Note: Bb ( 3), Div: 62, Rate: 7699.22, Freq: 3729.31, Error: (0.25%)
    .int 0x0027, 0x0040  # Midi: 107, Note:  B ( 3), Div: 64, Rate: 7902.13, Freq: 3951.07, Error: (0.32%)
    .int 0x0027, 0x0044  # Midi: 108, Note:  C ( 4), Div: 68, Rate: 7879.55, Freq: 4186.01, Error: (0.03%)
    .int 0x0027, 0x0048  # Midi: 109, Note: C# ( 4), Div: 72, Rate: 7884.31, Freq: 4434.92, Error: (0.09%)
    .int 0x0027, 0x004c  # Midi: 110, Note:  D ( 4), Div: 76, Rate: 7913.49, Freq: 4698.64, Error: (0.46%)
    .int 0x0027, 0x0051  # Midi: 111, Note: Eb ( 4), Div: 81, Rate: 7866.52, Freq: 4978.03, Error: (0.13%)
    .int 0x0027, 0x0056  # Midi: 112, Note:  E ( 4), Div: 86, Rate: 7849.74, Freq: 5274.04, Error: (0.35%)
    .int 0x0027, 0x005b  # Midi: 113, Note:  F ( 4), Div: 91, Rate: 7859.55, Freq: 5587.65, Error: (0.22%)
    .int 0x0027, 0x0060  # Midi: 114, Note: F# ( 4), Div: 96, Rate: 7893.21, Freq: 5919.91, Error: (0.21%)
    .int 0x0027, 0x0060  # Midi: 115, Note:  G ( 4), Div: 96, Rate: 7893.21, Freq: 5919.91, Error: (0.21%)
    .int 0x0027, 0x006c  # Midi: 116, Note: G# ( 4), Div: 108, Rate: 7875.41, Freq: 6644.88, Error: (0.02%)
    .int 0x0027, 0x0072  # Midi: 117, Note:  A ( 4), Div: 114, Rate: 7904.56, Freq: 7040.00, Error: (0.35%)
    .int 0x0027, 0x0079  # Midi: 118, Note: Bb ( 4), Div: 121, Rate: 7890.11, Freq: 7458.62, Error: (0.17%)
    .int 0x0027, 0x0080  # Midi: 119, Note:  B ( 4), Div: 128, Rate: 7902.13, Freq: 7902.13, Error: (0.32%)
    .int 0x0027, 0x0088  # Midi: 120, Note:  C ( 5), Div: 136, Rate: 7879.55, Freq: 8372.02, Error: (0.03%)
    .int 0x0027, 0x0090  # Midi: 121, Note: C# ( 5), Div: 144, Rate: 7884.31, Freq: 8869.84, Error: (0.09%)
    .int 0x0027, 0x0099  # Midi: 122, Note:  D ( 5), Div: 153, Rate: 7861.77, Freq: 9397.27, Error: (0.19%)
    .int 0x0027, 0x00a2  # Midi: 123, Note: Eb ( 5), Div: 162, Rate: 7866.52, Freq: 9956.06, Error: (0.13%)
    .int 0x0027, 0x00ab  # Midi: 124, Note:  E ( 5), Div: 171, Rate: 7895.64, Freq: 10548.08, Error: (0.24%)
    .int 0x0027, 0x00b6  # Midi: 125, Note:  F ( 5), Div: 182, Rate: 7859.55, Freq: 11175.30, Error: (0.22%)
    .int 0x0027, 0x00c0  # Midi: 126, Note: F# ( 5), Div: 192, Rate: 7893.21, Freq: 11839.82, Error: (0.21%)
    .int 0x0027, 0x00cc  # Midi: 127, Note:  G ( 5), Div: 204, Rate: 7870.65, Freq: 12543.85, Error: (0.08%)
notename_lookup:
    .byte ' ','C','-','5'
    .byte 'C','#','-','5'
    .byte ' ','D','-','5'
    .byte 'E','b','-','5'
    .byte ' ','E','-','5'
    .byte ' ','F','-','5'
    .byte 'F','#','-','5'
    .byte ' ','G','-','5'
    .byte 'G','#','-','5'
    .byte ' ','A','-','5'
    .byte 'B','b','-','5'
    .byte ' ','B','-','5'
    .byte ' ','C','-','4'
    .byte 'C','#','-','4'
    .byte ' ','D','-','4'
    .byte 'E','b','-','4'
    .byte ' ','E','-','4'
    .byte ' ','F','-','4'
    .byte 'F','#','-','4'
    .byte ' ','G','-','4'
    .byte 'G','#','-','4'
    .byte ' ','A','-','4'
    .byte 'B','b','-','4'
    .byte ' ','B','-','4'
    .byte ' ','C','-','3'
    .byte 'C','#','-','3'
    .byte ' ','D','-','3'
    .byte 'E','b','-','3'
    .byte ' ','E','-','3'
    .byte ' ','F','-','3'
    .byte 'F','#','-','3'
    .byte ' ','G','-','3'
    .byte 'G','#','-','3'
    .byte ' ','A','-','3'
    .byte 'B','b','-','3'
    .byte ' ','B','-','3'
    .byte ' ','C','-','2'
    .byte 'C','#','-','2'
    .byte ' ','D','-','2'
    .byte 'E','b','-','2'
    .byte ' ','E','-','2'
    .byte ' ','F','-','2'
    .byte 'F','#','-','2'
    .byte ' ','G','-','2'
    .byte 'G','#','-','2'
    .byte ' ','A','-','2'
    .byte 'B','b','-','2'
    .byte ' ','B','-','2'
    .byte ' ','C','-','1'
    .byte 'C','#','-','1'
    .byte ' ','D','-','1'
    .byte 'E','b','-','1'
    .byte ' ','E','-','1'
    .byte ' ','F','-','1'
    .byte 'F','#','-','1'
    .byte ' ','G','-','1'
    .byte 'G','#','-','1'
    .byte ' ','A','-','1'
    .byte 'B','b','-','1'
    .byte ' ','B','-','1'
    .byte ' ','C',' ','0'
    .byte 'C','#',' ','0'
    .byte ' ','D',' ','0'
    .byte 'E','b',' ','0'
    .byte ' ','E',' ','0'
    .byte ' ','F',' ','0'
    .byte 'F','#',' ','0'
    .byte ' ','G',' ','0'
    .byte 'G','#',' ','0'
    .byte ' ','A',' ','0'
    .byte 'B','b',' ','0'
    .byte ' ','B',' ','0'
    .byte ' ','C',' ','1'
    .byte 'C','#',' ','1'
    .byte ' ','D',' ','1'
    .byte 'E','b',' ','1'
    .byte ' ','E',' ','1'
    .byte ' ','F',' ','1'
    .byte 'F','#',' ','1'
    .byte ' ','G',' ','1'
    .byte 'G','#',' ','1'
    .byte ' ','A',' ','1'
    .byte 'B','b',' ','1'
    .byte ' ','B',' ','1'
    .byte ' ','C',' ','2'
    .byte 'C','#',' ','2'
    .byte ' ','D',' ','2'
    .byte 'E','b',' ','2'
    .byte ' ','E',' ','2'
    .byte ' ','F',' ','2'
    .byte 'F','#',' ','2'
    .byte ' ','G',' ','2'
    .byte 'G','#',' ','2'
    .byte ' ','A',' ','2'
    .byte 'B','b',' ','2'
    .byte ' ','B',' ','2'
    .byte ' ','C',' ','3'
    .byte 'C','#',' ','3'
    .byte ' ','D',' ','3'
    .byte 'E','b',' ','3'
    .byte ' ','E',' ','3'
    .byte ' ','F',' ','3'
    .byte 'F','#',' ','3'
    .byte ' ','G',' ','3'
    .byte 'G','#',' ','3'
    .byte ' ','A',' ','3'
    .byte 'B','b',' ','3'
    .byte ' ','B',' ','3'
    .byte ' ','C',' ','4'
    .byte 'C','#',' ','4'
    .byte ' ','D',' ','4'
    .byte 'E','b',' ','4'
    .byte ' ','E',' ','4'
    .byte ' ','F',' ','4'
    .byte 'F','#',' ','4'
    .byte ' ','G',' ','4'
    .byte 'G','#',' ','4'
    .byte ' ','A',' ','4'
    .byte 'B','b',' ','4'
    .byte ' ','B',' ','4'
    .byte ' ','C',' ','5'
    .byte 'C','#',' ','5'
    .byte ' ','D',' ','5'
    .byte 'E','b',' ','5'
    .byte ' ','E',' ','5'
    .byte ' ','F',' ','5'
    .byte 'F','#',' ','5'
    .byte ' ','G',' ','5'
