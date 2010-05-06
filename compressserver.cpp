#include "win32compress_server.h"
#include <unistd.h>

int main(int,char**)
{
    try {
#if defined(USE_PIPE)
    win32compress_server svr(STDOUT_FILENO,STDIN_FILENO);
#else
    win32compress_server svr;
#endif

    while(svr.server())
        usleep(50000);

    }
    catch(...)
    {
        fprintf(stderr, "EXCEPTION\n");
    }
    return 0;
}
