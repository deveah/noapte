
CC = gcc
CFLAGS = -Wall -Wextra -g
LIBS = -lcurses -lluajit-5.1

SOURCE = src/noapte.c
EXECUTABLE = noapte

all:
	$(CC) $(SOURCE) -o $(EXECUTABLE) $(LIBS) $(CFLAGS)

clean:
	rm $(EXECUTABLE)

