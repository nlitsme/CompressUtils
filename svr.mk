comp: compresstestclient32 compresstestclient64 compressserver
boost: testboost64 testboostsvr64 testboost32 testboostsvr32
shmem: testshmem64 testshmemsvr64 testshmem32 testshmemsvr32
pty: testpty testptysvr 
rest: testpopen testsocket testpstreams testsocksvr testpipe teststdiosvr

all: comp boost shmem rest pty

BOOSTLDFLAGS=-L/opt/local/lib
BOOSTCFLAGS=-I/opt/local/include
CFLAGS=-Wall -O0 -g -I ../../../itslib/include/itslib -D_NO_WINDOWS -D_NO_RAPI
SVRCDEFS=-DUSE_PIPE 
CLTCDEFS=-D_NO_IPC
M32FLAG=-m32 -mstackrealign
M64FLAG=-m64

# $1 = string
# $2 = def
has_def=$(filter $2,$1)
compresstestclient32: compresstestclient32.o stringutils32.o vectorutils32.o debug32.o $(if $(call has_def,$(CLTCDEFS),-D_NO_IPC),dllloader.o)
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ -L/usr/lib  $(BOOSTLDFLAGS)
compresstestclient32.o: compresstestclient.cpp
	g++ $(CFLAGS) -c $(CLTCDEFS) $(M32FLAG) $^ -o $@ $(BOOSTCFLAGS)
ifeq ($(call has_def,$(CLTCDEFS),-D_NO_IPC),)
compresstestclient64: compresstestclient64.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -L/usr/lib  $(BOOSTLDFLAGS)
compresstestclient64.o: compresstestclient.cpp
	g++ $(CFLAGS) -c $(CLTCDEFS) $(M64FLAG) $^ -o $@ $(BOOSTCFLAGS)
else
compresstestclient64:
	echo cant link 32bit dll to 64bit code >$@
endif
stringutils32.o: ../../../itslib/src/stringutils.cpp
	g++ $(CFLAGS) -c $(M32FLAG) $^ -o $@
stringutils64.o: ../../../itslib/src/stringutils.cpp
	g++ $(CFLAGS) -c $(M64FLAG) $^ -o $@
vectorutils32.o: ../../../itslib/src/vectorutils.cpp
	g++ $(CFLAGS) -c $(M32FLAG) $^ -o $@
vectorutils64.o: ../../../itslib/src/vectorutils.cpp
	g++ $(CFLAGS) -c $(M64FLAG) $^ -o $@
debug32.o: ../../../itslib/src/debug.cpp
	g++ $(CFLAGS) -c $(M32FLAG) $^ -o $@
debug64.o: ../../../itslib/src/debug.cpp
	g++ $(CFLAGS) -c $(M64FLAG) $^ -o $@



compressserver: compressserver.o dllloader.o stringutils32.o vectorutils32.o debug32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ -L/usr/lib  $(BOOSTLDFLAGS)
compressserver.o: compressserver.cpp
	g++ $(CFLAGS) -c $(SVRCDEFS) $(M32FLAG) $^ -o $@ $(BOOSTCFLAGS)
dllloader.o: dllloader.cpp
	g++ $(CFLAGS) -c $(M32FLAG) $^ -o $@

testpopen: testpopen.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ 
testpopen.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_POPEN $(M64FLAG) $^ -o $@
testsocket: testsocket.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ 
testsocket.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_SOCKET $(M64FLAG) $^ -o $@
testpstreams: testpstreams.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ 
testpstreams.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_PSTREAM $(M64FLAG) $^ -o $@
testpipe: testpipe.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ 
testpipe.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_PIPE $(M64FLAG) $^ -o $@
testboost64: testboost64.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -L/usr/lib  $(BOOSTLDFLAGS)
testboost64.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_BOOST $(M64FLAG) $^ -o $@ $(BOOSTCFLAGS)
testboost32: testboost32.o stringutils32.o vectorutils32.o debug32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ -L/usr/lib  $(BOOSTLDFLAGS)
testboost32.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_BOOST $(M32FLAG) $^ -o $@ $(BOOSTCFLAGS)

testshmem64: testshmem64.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ 
testshmem64.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_SHMEM $(M64FLAG) $^ -o $@
testshmem32: testshmem32.o stringutils32.o vectorutils32.o debug32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ 
testshmem32.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_SHMEM $(M32FLAG) $^ -o $@

testpty: testpty.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ 
testpty.o: testipc.cpp
	g++ $(CFLAGS) -c -DUSE_PTY $(M64FLAG) $^ -o $@





teststdiosvr: teststdiosvr.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ 
teststdiosvr.o: testsvr.cpp
	g++ $(CFLAGS) -c  $(M64FLAG) $^ -o $@
testsocksvr: testsocksvr.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ 
testsocksvr.o: testsvr.cpp
	g++ $(CFLAGS) -c -DUSE_SOCKET $(M64FLAG) $^ -o $@
testboostsvr64: testboostsvr64.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ -L/usr/lib  $(BOOSTLDFLAGS)
testboostsvr64.o: testsvr.cpp
	g++ $(CFLAGS) -c -DUSE_BOOST $(M64FLAG) $^ -o $@ $(BOOSTCFLAGS)
testboostsvr32: testboostsvr32.o stringutils32.o vectorutils32.o debug32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ -L/usr/lib  $(BOOSTLDFLAGS)
testboostsvr32.o: testsvr.cpp
	g++ $(CFLAGS) -c -DUSE_BOOST $(M32FLAG) $^ -o $@ $(BOOSTCFLAGS)
runboost:
	ln -sf testboostsvr32 testboostsvr
	./testboost32
	ln -sf testboostsvr64 testboostsvr
	./testboost64

testshmemsvr64: testshmemsvr64.o stringutils64.o vectorutils64.o debug64.o
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ 
testshmemsvr64.o: testsvr.cpp
	g++ $(CFLAGS) -c -DUSE_SHMEM $(M64FLAG) $^ -o $@
testshmemsvr32: testshmemsvr32.o stringutils32.o vectorutils32.o debug32.o
	g++ $(CFLAGS) $(M32FLAG) -o $@ $^ 
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
	g++ $(CFLAGS) $(M64FLAG) -o $@ $^ 
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
