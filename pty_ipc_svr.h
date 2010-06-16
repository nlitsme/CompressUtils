#ifndef __PTY_IPC_SVR_H__
#define __PTY_IPC_SVR_H__
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>

#include "stringutils.h"
#include "err/posix.h"
#include "readwriter.h"


class pty_ipc_server : public readwriter {
    int _pty;
public:
    pty_ipc_server(const char *ptyname)
    {
        std::string ptypath= ptyname[0]=='/' ? ptyname : (std::string("/dev/")+std::string(ptyname));
        _pty= open(ptypath.c_str(), O_RDWR);
        if (_pty==-1)
            throw posixerror("open(pty");
        fprintf(stderr, "child opened %s -> %d\n", ptypath.c_str(), _pty);
    }
    ~pty_ipc_server()
    {
        close(_pty);
    }
    virtual size_t readsome(void*p, size_t n)
    {
        return ::read(_pty, p, n);
    }

    virtual size_t writesome(const void*p, size_t n)
    {
        return ::write(_pty, p, n);
    }
};
#endif
