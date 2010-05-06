#ifndef _STDIO_IPC_SVR_H__
#define _STDIO_IPC_SVR_H__
#include <unistd.h>
#include <stdio.h>

#include "readwriter.h"
#include "ipclog.h"

class stdio_ipc_server : public readwriter {
    int _fds2c;
    int _fdc2s;
public:
    stdio_ipc_server(int fds2c, int fdc2s) : _fds2c(fds2c), _fdc2s(fdc2s) { }
    ~stdio_ipc_server()
    {
        close(_fdc2s);
        close(_fds2c);
    }
    virtual size_t readsome(void*p, size_t n)
    {
        return ::read(_fdc2s, p, n);
    }

    virtual size_t writesome(const void*p, size_t n)
    {
        return ::write(_fds2c, p, n);
    }
};
#endif
