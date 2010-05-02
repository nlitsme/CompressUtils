#ifndef _STDIO_IPC_SVR_H__
#define _STDIO_IPC_SVR_H__
#include <unistd.h>
#include <stdio.h>

#define ipclog(...)
//#define ipclog(...) fprintf(stderr,__VA_ARGS__)

class stdio_ipc_server {
    int _fds2c;
    int _fdc2s;
public:
    stdio_ipc_server(int fds2c, int fdc2s) : _fds2c(fds2c), _fdc2s(fdc2s) { }
    ~stdio_ipc_server()
    {
        close(_fdc2s);
        close(_fds2c);
    }
    bool read(void*p, size_t n)
    {
        ipclog("server-reading(%d) %d\n", _fdc2s, (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r= ::read(_fdc2s, (char*)p+total, n-total);
            if (r==-1) {
                perror("svr-read");
                return false;
            }
            total += r;
        }
        ipclog("server-read %d\n", (int)n);
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
};
#endif
