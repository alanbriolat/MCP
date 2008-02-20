%.o: %.s
	h180 as -o $@ $<

all: synth


interfacetest: interfacetest.o terminal.o network.o keypad.o lcd.o utils.o
	h180 ld -T 8000 -C c000 -o $@ $^

paralleltest: paralleltest.o parallel.o utils.o
	h180 ld -T 8000 -C c000 -o $@ $^

synth: synth.o output.o terminal.o network.o keypad.o lcd.o utils.o note_lookup.o
	h180 ld -T 8000 -C c000 -o $@ $^

note_lookup.s: notes/pitchtable.csv
	./tools/pitchtable.py < $< > $@

clean:
	rm -f *.o
	rm -f interfacetest paralleltext synth
