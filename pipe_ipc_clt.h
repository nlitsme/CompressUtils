#ifndef __PIPE_IPC_CLT_H__
#define __PIPE_IPC_CLT_H__
#include <stdio.h>
#include <unistd.h>
#include "stringutils.h"
#include "posixerr.h"
#include "readwriter.h"
#include "forkchild.h"
#include "ipclog.h"


class pipe_ipc_client : public readwriter, public fork_child {
    int _fds2c[2];
    int _fdc2s[2];
public:
    pipe_ipc_client(const std::string& svrname, const StringList& args)
    {
        if (-1==pipe(_fds2c)) 
            throw posixerror("pipe-s2c");
        ipclog("s2c: %d, %d\n", _fds2c[0], _fds2c[1]);
        if (-1==pipe(_fdc2s)) 
            throw posixerror("pipe-c2s");
        ipclog("c2s: %d, %d\n", _fdc2s[0], _fdc2s[1]);

        run_child(svrname, args);

        // parent

//      close(_fdc2s[0]);
//      close(_fds2c[1]);
    }
    ~pipe_ipc_client()
    {
    }
    virtual void initialize_child()
    {
        if (-1==dup2(_fdc2s[0],STDIN_FILENO)) 
            throw posixerror("dup2(stdin)");
        if (-1==dup2(_fds2c[1],STDOUT_FILENO)) 
            throw posixerror("dup2(stdout)");
        ipclog("svr: %d->stdin, %d->stdout\n", _fdc2s[0], _fds2c[1]);

        close(_fdc2s[0]);
        close(_fdc2s[1]);
        close(_fds2c[0]);
        close(_fds2c[1]);
    }

    virtual size_t readsome(void*p, size_t n)
    {
        return ::read(_fds2c[0], p, n);
    }

    virtual size_t writesome(const void*p, size_t n)
    {
        return ::write(_fdc2s[1], p, n);
    }
};
#endif
