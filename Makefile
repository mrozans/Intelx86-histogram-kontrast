CC=gcc
CFLAGS=-m32 -L/usr/lib32
ASM=nasm
AFLAGS=-f elf32

all:result

main.o: main.c
	$(CC) $(CFLAGS) -c main.c
func.o: func.asm
	$(ASM) $(AFLAGS) func.asm
func2.o: func2.asm
	$(ASM) $(AFLAGS) func2.asm
result: main.o func.o func2.o
	$(CC) $(CFLAGS) main.o func.o func2.o -o result -lallegro -lallegro_image
clean: 
	rm *.o
	rm result
