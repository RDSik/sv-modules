CC=arm-linux-gnueabihf-gcc

CFLAGS ?= -O2 -static

objects = axis_uart.o 

CHECKFLAGS = -Wall -Wuninitialized -Wundef

override CFLAGS := $(CHECKFLAGS) $(CFLAGS)

progs = axis_uart

.PHONY: clean

axis_uart: $(objects)
	$(CC) $(CFLAGS) -o $@ $(objects) 

clean:
	rm -f $(progs) $(objects)
	$(MAKE) -C clean
