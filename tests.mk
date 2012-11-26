all: testxph testxpr
testxph: testxph.o stringutils.o dllloader.o
testxpr: testxpr.o stringutils.o dllloader.o debug.o FileFunctions.o

CXX=clang++-mp-3.1

CFLAGS=-Wall -m32 -g -I ../../itsutils/common -D_UNIX -D_NO_RAPI
LDFLAGS=-m32 -g
%: %.o
	$(CXX) $(LDFLAGS) $^ -o $@
%.o: ../../itsutils/common/%.cpp
	$(CXX) -c $(CFLAGS) $^ -o $@

%.o: %.cpp
	$(CXX) -c $(CFLAGS) $^ -o $@

clean:
	$(RM) testxph testxph.o stringutils.o testxpr testxpr.o  dllloader.o debug.o FileFunctions.o
