%.o: defs.s %.s
	h180 as -o $@ $^

all: synth


synth: synth.o output.o terminal.o network.o keypad.o lcd.o note_lookup.o
	h180 ld -T 8000 -C c000 -o $@ $^

note_lookup.s: tools/pitchtable.csv
	./tools/pitchtable.py < $< > $@

clean:
	rm -f *.o
	rm -f interfacetest synth
