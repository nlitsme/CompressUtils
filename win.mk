boost: testboost.exe testboostsvr.exe
BOOSTCFLAGS=-I$(BOOST)
BOOSTLDFLAGS=-link -libpath:$(BOOST)/lib-x86

CFLAGS=-Wall -EHsc -Zi -I ../../itsutils/common -D_NO_WINDOWS -D_NO_RAPI -DNOMINMAX
CDEFS=-DUSE_BOOST

stringutils.obj: ../../itsutils/common/stringutils.cpp
	cl $(CFLAGS) -c  $^ -Fo$@
vectorutils.obj: ../../itsutils/common/vectorutils.cpp
	cl $(CFLAGS) -c  $^ -Fo$@
debug.obj: ../../itsutils/common/debug.cpp
	cl $(CFLAGS) -c  $^ -Fo$@

testboost.exe: testboost.obj stringutils.obj vectorutils.obj debug.obj
	cl $(CFLAGS) -Fe$@ $^ $(BOOSTLDFLAGS)
testboost.obj: testipc.cpp
	cl $(CFLAGS) -c -DUSE_BOOST $^ -Fo$@ $(BOOSTCFLAGS)

testboostsvr.exe: testboostsvr.obj stringutils.obj vectorutils.obj debug.obj
	cl $(CFLAGS) -Fe$@ $^ $(BOOSTLDFLAGS)
testboostsvr.obj: testsvr.cpp
	cl $(CFLAGS) -c -DUSE_BOOST $^ -Fo$@ $(BOOSTCFLAGS)



clean:
	$(RM) -f *.obj *.exe

