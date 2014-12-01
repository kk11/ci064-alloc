CC = gcc -m32
AS = as --32

all:
	$(AS) meuAlocador.s -o meuAlocador.o
	$(CC) meuAlocador.o main.c -o meuAlocador

clean:
	rm -rf *.o meuAlocador