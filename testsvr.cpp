#if defined(USE_SOCKET)
#include "socket_ipc_svr.h"
#elif defined(USE_BOOST)
#include "boost_ipc_svr.h"
#elif defined(USE_SHMEM)
#include "shmem_ipc_svr.h"
#else
#include "stdio_ipc_svr.h"
#endif

#include <stdio.h>
#include <string>

#include "stringutils.h"
#include "vectorutils.h"

#define IPCTESTSIZE 16
void do_server()
{
#if defined(USE_SOCKET)
    socket_ipc_server _ipc;
#elif defined(USE_BOOST)
    boost_ipc_server _ipc;
#elif defined(USE_SHMEM)
    shmem_ipc_server _ipc;
#else
    stdio_ipc_server _ipc(STDOUT_FILENO,STDIN_FILENO);
#endif

    while (true)
    {
        DWORD s[2];
        if (!_ipc.read(s, sizeof(s)))
            break;
        ByteVector req(s[0]-8);
        if (!_ipc.read(&req[0], req.size()))
            break;

        ByteVector res(s[1]);

        if (!_ipc.write(&res[0], res.size()))
            break;
    }
}
int main(int argc,char**argv)
{
    try {
    do_server();
    }
    catch(...)
    {
        fprintf(stderr, "EXCEPTION\n");
    }

    return 0;
}

