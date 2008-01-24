%.o: %.s
	h180 as -o $@ $<

addmem: addmem.o
	h180 ld -T 8000 -C c000 -o $@ $^

lcdtest: lcdtest.o utils.o lcd.o
	h180 ld -T 8000 -C c000 -o $@ $^

keypadtest: keypadtest.o utils.o lcd.o kpd.o
	h180 ld -T 8000 -C c000 -o $@ $^

clean:
	rm -f *.o
	rm -f keypadtest lcdtest addmem
