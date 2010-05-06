#if defined(USE_POPEN)
#include "popen_ipc_clt.h"
#elif defined(USE_PSTREAM)
#include "pstream_ipc_clt.h"
#elif defined(USE_SOCKET)
#include "socket_ipc_clt.h"
#elif defined(USE_PIPE)
#include "pipe_ipc_clt.h"
#elif defined(USE_BOOST)
#include "boost_ipc_clt.h"
#elif defined(USE_SHMEM)
#include "shmem_ipc_clt.h"
#endif

#include <stdio.h>
#include <string>

#include "stringutils.h"
#include "vectorutils.h"
#include "util/HiresTimer.h"

template<typename T>
bool runtest(T& ipc, int size)
{
    ByteVector req(size);
    *(DWORD*)&req[0]= size;
    *(DWORD*)&req[4]= size;

    ByteVector res(size);
    for (int i=0 ; i<10000 ; i++)
    {
        if (!ipc.write(&req[0], req.size()))
            return false;

        if (!ipc.read(&res[0], res.size()))
            return false;
    }

    return true;
}
#define IPCTESTSIZE 16
void do_client(const std::string& svrname, const StringList& args) 
{
#if defined(USE_POPEN)
    popen_ipc_client _ipc(svrname, args);
#elif defined(USE_PSTREAM)
    pstream_ipc_client _ipc(svrname, args);
#elif defined(USE_SOCKET)
    socket_ipc_client _ipc(svrname, args);
#elif defined(USE_PIPE)
    pipe_ipc_client _ipc(svrname, args);
#elif defined(USE_BOOST)
    boost_ipc_client _ipc(svrname, args);
#elif defined(USE_SHMEM)
    shmem_ipc_client _ipc(svrname, args);
#endif

    for (int size= 0x100 ; size<0x100000 ; size<<=1)
    {
        HiresTimer t;
        if (!runtest(_ipc, size))
            printf("test for size %d failed\n", size);
        printf("%08x -> %6d\n", size, t.msecelapsed());
    }
}

#if defined(USE_SOCKET)
#define SVRNAME  "./testsocksvr"
#elif defined(USE_BOOST)

#ifdef _WIN32
#define SVRNAME  "testboostsvr.exe"
#else
#define SVRNAME  "./testboostsvr"
#endif

#elif defined(USE_SHMEM)

#ifdef _WIN32
#define SVRNAME  "testshmemsvr.exe"
#else
#define SVRNAME  "./testshmemsvr"
#endif

#else
#define SVRNAME  "./teststdiosvr"
#endif

int main(int argc,char**argv)
{
    try {
    do_client(SVRNAME, StringList());
    }
    catch(...)
    {
        fprintf(stderr, "EXCEPTION\n");
    }

    return 0;
}
