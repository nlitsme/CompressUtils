comp: compresstestclient32 compresstestclient64 compressserver
boost: testboost64 testboostsvr64 testboost32 testboostsvr32
shmem: testshmem64 testshmemsvr64 testshmem32 testshmemsvr32
pty: testpty testptysvr 
rest: testpopen testsocket testpstreams testsocksvr testpipe teststdiosvr

all: comp boost shmem rest pty

BOOSTLDFLAGS=-L/opt/local/lib
BOOSTCFLAGS=-I/opt/local/include
CFLAGS=-Wall -O0 -g -I ../../itsutils/common -I ../../itsutils/common/threading -I ../../itsutils/include/win32 -D_UNIX -D_NO_WINDOWS -D_NO_RAPI
CDEFS=-DUSE_SOCKET
M32FLAG=-m32 -mstackrealign
M64FLAG=-m64

compresstestclient32: compresstestclient32.o stringutils32.o vectorutils32.o debug32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ -L/usr/lib -liconv $(BOOSTLDFLAGS)
compresstestclient32.o: compresstestclient.cpp
	g++ $(CFLAGS) -c $(CDEFS) $(M32FLAG) $^ -o $@ $(BOOSTCFLAGS)

compresstestclient64: compresstestclient64.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -L/usr/lib -liconv $(BOOSTLDFLAGS)
compresstestclient64.o: compresstestclient.cpp
	g++ $(CFLAGS) -c $(CDEFS) $(M64FLAG) $^ -o $@ $(BOOSTCFLAGS)

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
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ -L/usr/lib -liconv $(BOOSTLDFLAGS)
compressserver.o: compressserver.cpp
	g++ $(CFLAGS) -c $(CDEFS) $(M32FLAG) $^ -o $@ $(BOOSTCFLAGS)
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
testboost64: testboost64.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -L/usr/lib -liconv $(BOOSTLDFLAGS)
testboost64.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_BOOST $(M64FLAG) $^ -o $@ $(BOOSTCFLAGS)
testboost32: testboost32.o stringutils32.o vectorutils32.o debug32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ -L/usr/lib -liconv $(BOOSTLDFLAGS)
testboost32.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_BOOST $(M32FLAG) $^ -o $@ $(BOOSTCFLAGS)

testshmem64: testshmem64.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
testshmem64.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_SHMEM $(M64FLAG) $^ -o $@
testshmem32: testshmem32.o stringutils32.o vectorutils32.o debug32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ -liconv
testshmem32.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_SHMEM $(M32FLAG) $^ -o $@

testpty: testpty.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
testpty.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_PTY $(M64FLAG) $^ -o $@





teststdiosvr: teststdiosvr.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
teststdiosvr.o: testsvr.cpp
	g++ $(CFLAGS) -c  $(M64FLAG) $^ -o $@
testsocksvr: testsocksvr.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
testsocksvr.o: testsvr.cpp
	g++ $(CFLAGS) -c -DUSE_SOCKET $(M64FLAG) $^ -o $@
testboostsvr64: testboostsvr64.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -L/usr/lib -liconv $(BOOSTLDFLAGS)
testboostsvr64.o: testsvr.cpp
	g++ $(CFLAGS) -c -DUSE_BOOST $(M64FLAG) $^ -o $@ $(BOOSTCFLAGS)
testboostsvr32: testboostsvr32.o stringutils32.o vectorutils32.o debug32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ -L/usr/lib -liconv $(BOOSTLDFLAGS)
testboostsvr32.o: testsvr.cpp
	g++ $(CFLAGS) -c -DUSE_BOOST $(M32FLAG) $^ -o $@ $(BOOSTCFLAGS)
runboost:
	ln -sf testboostsvr32 testboostsvr
	./testboost32
	ln -sf testboostsvr64 testboostsvr
	./testboost64

testshmemsvr64: testshmemsvr64.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
testshmemsvr64.o: testsvr.cpp
	g++ $(CFLAGS) -c -DUSE_SHMEM $(M64FLAG) $^ -o $@
testshmemsvr32: testshmemsvr32.o stringutils32.o vectorutils32.o debug32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ -liconv
testshmemsvr32.o: testsvr.cpp
	g++ $(CFLAGS) -c -DUSE_SHMEM $(M32FLAG) $^ -o $@
runshmem: testshmemsvr32 testshmemsvr64 testshmem32 testshmem64
	ln -sf testshmemsvr32 testshmemsvr
	./testshmem32
	./testshmem64
	ln -sf testshmemsvr64 testshmemsvr
	./testshmem32
	./testshmem64

testptysvr: testptysvr.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -liconv
testptysvr.o: testsvr.cpp
	g++ $(CFLAGS) -c -DUSE_PTY $(M64FLAG) $^ -o $@


clean:
	$(RM) -f $(wildcard *.o *.obj *.exe) compressserver compresstestclient32  compresstestclient64  testpopen  testsocket  testpstreams  testpipe        teststdiosvr  testsocksvr  testboost32  testboostsvr32  testboost64  testboostsvr64   testshmem64 testshmemsvr64 testshmem32 testshmemsvr32      testboostsvr testshmemsvr testptysvr testpty


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
