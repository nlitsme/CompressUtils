#if defined(USE_POPEN)
#include "popen_ipc_clt.h"
#elif defined(USE_PSTREAM)
#include "pstream_ipc_clt.h"
#elif defined(USE_SOCKET)
#include "socket_ipc_clt.h"
#elif defined(USE_PIPE)
#include "pipe_ipc_clt.h"
#endif

#include <stdio.h>
#include <string>

#include "stringutils.h"
#include "vectorutils.h"

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
#endif

    int n=0;
    for (int j=0 ; j<4 ; j++)
    {

        ByteVector req(IPCTESTSIZE);
        for (unsigned i=0 ; i<req.size() ; i++)
            req[i]= i*16+n;
        n++;

        if (!_ipc.write(&req[0], req.size()))
            break;

        ByteVector res(IPCTESTSIZE);
        if (!_ipc.read(&res[0], res.size()))
            break;

        fprintf(stderr, "result: %s\n", hexdump(res).c_str());

    }
}
#if defined(USE_SOCKET)
#define SVRNAME  "./testsocksvr"
#else
#define SVRNAME  "./teststdiosvr"
#endif

int main(int argc,char**argv)
{
    do_client(SVRNAME, StringList());

    return 0;
}
