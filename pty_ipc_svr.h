#ifndef __PTY_IPC_CLT_H__
#define __PTY_IPC_CLT_H__
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#include "stringutils.h"
#include "posixerr.h"


class pty_ipc_server {
    int _s;
    int _a;
public:
    pty_ipc_server()
    {
    }
    ~pty_ipc_server()
    {
    }
    bool read(void*p, size_t n)
    {
//      fprintf(stderr, "server-reading %d\n", n);
        size_t total= 0;
        while (total<n)
        {
            int r= ::read(_a, (char*)p+total, n-total);
            if (r==-1)
                return false;
            total += r;
//          if (r)
//              fprintf(stderr, "server-read %d of %d\n", r, n);
        }
        return true;
    }

    bool write(const void*p, size_t n)
    {
        ipclog("server-writing(%d) %d\n", _fds2c, (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r=::write(_fds2c, (const char*)p+total, n-total);
            if (r==-1)
            {
                perror("svr-write");
                return false;
            }
            total += r;
        }
        ipclog("server-wrote %d\n", (int)n);
        return true;
    }
}
