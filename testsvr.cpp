#if defined(USE_SOCKET)
#include "socket_ipc_svr.h"
#elif defined(USE_BOOST)
#include "boost_ipc_svr.h"
#elif defined(USE_SHMEM)
#include "shmem_ipc_svr.h"
#elif defined(USE_PTY)
#include "pty_ipc_svr.h"
#else
#include "stdio_ipc_svr.h"
#endif

#include <stdio.h>
#include <string>

#include "stringutils.h"
#include "vectorutils.h"
#include "util/HiresTimer.h"

int g_ctrlcpressed= 0;
void handlectrlc(int sig)
{
    fprintf(stderr, "ctrl-c pressed\n");
    if (g_ctrlcpressed++ > 2)
        signal(sig, SIG_DFL);
}
void do_server(int argc, char**argv)
{
#if defined(USE_SOCKET)
    socket_ipc_server _ipc;
#elif defined(USE_BOOST)
    boost_ipc_server _ipc;
#elif defined(USE_SHMEM)
    shmem_ipc_server _ipc;
#elif defined(USE_PTY)
    if (argc!=2) {
        fprintf(stderr, "Usage: testptysvr [ptydevname]\n");
        return;
    }
    pty_ipc_server _ipc(argv[1]);
#else
    stdio_ipc_server _ipc(STDOUT_FILENO,STDIN_FILENO);
#endif

    while (!g_ctrlcpressed)
    {
        DWORD s[2];
        if (!_ipc.read(s, sizeof(s)))
            break;

        ByteVector req(s[0]-8);
        if (s[0]>0x100000) {
            fprintf(stderr, "svr: %08x %08x\n", s[0], s[1]);
            break;
        }

        if (g_ctrlcpressed)
            break;
        if (!_ipc.read(&req[0], req.size()))
            break;

        ByteVector res(s[1]);

        if (g_ctrlcpressed)
            break;
        if (!_ipc.write(&res[0], res.size()))
            break;
    }
}
int main(int argc,char**argv)
{
    signal(SIGINT, handlectrlc);
    try {
    do_server(argc, argv);
    }
    catch(...)
    {
        fprintf(stderr, "EXCEPTION\n");
    }

    return 0;
}

