all: compresstestclient32 compresstestclient64 compressserver
CFLAGS=-Wall -g
CDEFS=-DUSE_SOCKET
M32FLAG=-m32 -mstackrealign
M64FLAG=-m64

compresstestclient32: compresstestclient32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^
compresstestclient32.o: compresstestclient.cpp
	g++ $(CFLAGS) -c $(CDEFS) $(M32FLAG) $^ -o $@

compresstestclient64: compresstestclient64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^
compresstestclient64.o: compresstestclient.cpp
	g++ $(CFLAGS) -c $(CDEFS) $(M64FLAG) $^ -o $@

compressserver: compressserver.o dllloader.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^
compressserver.o: compressserver.cpp
	g++ $(CFLAGS) -c $(CDEFS) $(M32FLAG) $^ -o $@
dllloader.o: dllloader.cpp
	g++ $(CFLAGS) -c $(CDEFS) $(M32FLAG) $^ -o $@

clean:
	$(RM) -f dllloader.o compressserver.o compressserver compresstestclient32 compresstestclient32.o compresstestclient64 compresstestclient64.o
