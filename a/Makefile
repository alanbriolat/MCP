%.o: %.s
	h180 as -o $@ $<

all: interfacetest


interfacetest: interfacetest.o terminal.o keypad.o lcd.o utils.o
	h180 ld -T 8000 -C c000 -o $@ $^

clean:
	rm -f *.o
	rm -f keypadtest lcdtest addmem
