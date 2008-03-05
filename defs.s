### Interrupt registers
.set IL, 0x33
.set ITC, 0x334

### Programmable reload timers
.set PRT_TCR, 0x10
.set PRT0_DR_L, 0x0c
.set PRT0_DR_H, 0x0d
.set PRT0_RLD_L, 0x0e
.set PRT0_RLD_H, 0x0f

### Network interface on ASCI 0
# I/O addresses
.set NETWORK_CTRLA, 0x00
.set NETWORK_CTRLB, 0x02
.set NETWORK_STAT, 0x04
.set NETWORK_TX, 0x06
.set NETWORK_RX, 0x08
# Control A - receive enable, transmit disable, 8-bit, no parity, 1 stop bit
.set NETWORK_CTRLA_VALUE, 0x54
# Control B - 19200bps baud rate
.set NETWORK_CTRLB_VALUE, 0x01
# Status - Receive interrupt enabled, CTS enabled
.set NETWORK_STAT_VALUE, 0x0c

### Terminal interface on ASCI 1
# I/O addresses
.set TERMINAL_CTRLA, 0x01
.set TERMINAL_CTRLB, 0x03
.set TERMINAL_STAT, 0x05
.set TERMINAL_TX, 0x07
.set TERMINAL_RX, 0x09
# Control A - receive enable, transmit enable, 7-bit, parity, 1 stop bit
.set TERMINAL_CTRLA_VALUE, 0x72
# Control B - 4800bps baud rate
.set TERMINAL_CTRLB_VALUE, 0x03
# Status - Receive interrupt enabled, CTS enabled
.set TERMINAL_STAT_VALUE, 0x0c

### Keypad interface
# I/O addresses
.set KEYPAD_DATA, 0xb4

### Sound output device on Parallel I/O
# I/O addresses
.set OUTPUT_VOL, 0xb0
.set OUTPUT_WAVE, 0xb1
.set OUTPUT_CTRL, 0xb3

### Text LCD display
# I/O addresses
.set LCD_CTRL, 0xb8
.set LCD_DATA, 0xb9

# DDRAM addresses for parts of the display
.set LCD_INSTRUMENT, 0x80
.set LCD_NOTE, 0xc5
.set LCD_VOL, 0xce
