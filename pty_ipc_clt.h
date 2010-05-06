#ifndef __PTY_IPC_CLT_H__
#define __PTY_IPC_CLT_H__
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#include "stringutils.h"
#include "posixerr.h"
#include "readwriter.h"

class pty_ipc_client : public readwriter {
    int _s;
public:
    pty_ipc_client(const std::string& svrname, const StringList& args)
    {
    }
    ~pty_ipc_client()
    {
    }
    virtual size_t readsome(void*p, size_t n)
    {
        // todo
    }

    virtual size_t writesome(const void*p, size_t n)
    {
        // todo
    }
};

#endif

