#include "win32compress_server.h"
#include <unistd.h>

int main(int,char**)
{
    //fprintf(stderr, "compressserver started\n");
    win32compress_server svr(STDOUT_FILENO,STDIN_FILENO);

    while(svr.server())
        usleep(50000);

    return 0;
}
