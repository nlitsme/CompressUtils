all: compresstestclient32 compresstestclient64 compressserver   testpipe  teststdiosvr  
rest: testpopen testsocket testpstreams testsocksvr
CFLAGS=-Wall -g -I ../../itsutils/common  -I ../../itsutils/include/win32 -D_UNIX -D_NO_WINDOWS -D_NO_RAPI
CDEFS=-DUSE_PIPE
M32FLAG=-m32 -mstackrealign
M64FLAG=-m64

compresstestclient32: compresstestclient32.o stringutils32.o vectorutils32.o debug32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ -liconv
compresstestclient32.o: compresstestclient.cpp
	g++ $(CFLAGS) -c $(CDEFS) $(M32FLAG) $^ -o $@

compresstestclient64: compresstestclient64.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
compresstestclient64.o: compresstestclient.cpp
	g++ $(CFLAGS) -c $(CDEFS) $(M64FLAG) $^ -o $@

stringutils32.o: ../../itsutils/common/stringutils.cpp
	g++ $(CFLAGS) -c $(M32FLAG) $^ -o $@
stringutils64.o: ../../itsutils/common/stringutils.cpp
	g++ $(CFLAGS) -c $(M64FLAG) $^ -o $@
vectorutils32.o: ../../itsutils/common/vectorutils.cpp
	g++ $(CFLAGS) -c $(M32FLAG) $^ -o $@
vectorutils64.o: ../../itsutils/common/vectorutils.cpp
	g++ $(CFLAGS) -c $(M64FLAG) $^ -o $@
debug32.o: ../../itsutils/common/debug.cpp
	g++ $(CFLAGS) -c $(M32FLAG) $^ -o $@
debug64.o: ../../itsutils/common/debug.cpp
	g++ $(CFLAGS) -c $(M64FLAG) $^ -o $@



compressserver: compressserver.o dllloader.o stringutils32.o vectorutils32.o debug32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ -liconv
compressserver.o: compressserver.cpp
	g++ $(CFLAGS) -c $(CDEFS) $(M32FLAG) $^ -o $@
dllloader.o: dllloader.cpp
	g++ $(CFLAGS) -c $(M32FLAG) $^ -o $@

testpopen: testpopen.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
testpopen.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_POPEN $(M64FLAG) $^ -o $@
testsocket: testsocket.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
testsocket.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_SOCKET $(M64FLAG) $^ -o $@
testpstreams: testpstreams.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
testpstreams.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_PSTREAM $(M64FLAG) $^ -o $@
testpipe: testpipe.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
testpipe.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_PIPE $(M64FLAG) $^ -o $@

teststdiosvr: teststdiosvr.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
teststdiosvr.o: testsvr.cpp
	g++ $(CFLAGS) -c  $(M64FLAG) $^ -o $@
testsocksvr: testsocksvr.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
testsocksvr.o: testsvr.cpp
	g++ $(CFLAGS) -c -DUSE_SOCKET $(M64FLAG) $^ -o $@



clean:
	$(RM) -f dllloader.o compressserver.o compressserver compresstestclient32 compresstestclient32.o compresstestclient64 compresstestclient64.o testpopen testpopen.o testsocket testsocket.o testpstreams testpstreams.o testpipe testpipe.o debug32.o debug64.o stringutils32.o stringutils64.o vectorutils32.o vectorutils64.o teststdiosvr teststdiosvr.o testsocksvr testsocksvr.o


tests:
#compressserver
#teststdiosvr
#testsocksvr
	./compresstestclient32
	./compresstestclient64
	./testpopen
	./testsocket
	./testpstreams
	./testpipe
