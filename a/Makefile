%.o: %.s
	h180 as -o $@ defs.s $<

addmem: addmem.o
	h180 ld -T 8000 -C c000 -o $@ $<

lcdtest: lcdtest.o
	h180 ld -T 8000 -C c000 -o $@ $<
