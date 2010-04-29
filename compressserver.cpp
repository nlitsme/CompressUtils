#include "win32compress_server.h"
#include <unistd.h>

int main(int,char**)
{
    win32compress_server svr;

    while(svr.server())
        usleep(50000);

    return 0;
}
