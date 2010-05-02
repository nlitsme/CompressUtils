#if defined(USE_SOCKET)
#include "socket_ipc_svr.h"
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
#else
    stdio_ipc_server _ipc(STDOUT_FILENO,STDIN_FILENO);
#endif

    int n= 0;
    while (true)
    {
        ByteVector req(IPCTESTSIZE);
        if (!_ipc.read(&req[0], req.size()))
            break;

        fprintf(stderr, "req: %s\n", hexdump(req).c_str());

        ByteVector res(IPCTESTSIZE);
        for (unsigned i=0 ; i<res.size() ; i++)
            res[i]= n*16+i;
        n++;

        if (!_ipc.write(&res.front(), res.size()))
            break;
    }
}
int main(int argc,char**argv)
{
    do_server();

    return 0;
}

